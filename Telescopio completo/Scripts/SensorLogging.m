%ANTES DE CORRER ESTA CELDA APUNTAR TELEFONO AL NORTE PARA CALIBRAR
%CORRECTAMENTE.
clear
clc

m = mobiledev;
m.OrientationSensorEnabled = 1;
m.SampleRate=100;

tic
m.Logging = 1;
pause(0.5)
step=1/20;
t=60;
to=0;

figure
az=plot(0, 0);

figure
alt=plot(0, 0);

figure
azalt=plot(0,0);
%xlim([-40,40])
%ylim([-25,25])
xlim([-180,180])
ylim([-90,90])

%figure
%plot(to, o(:,3))

while to(end) < t
[o,to] = orientlog(m);

%Azimutal angle
o(:,1) = unwrap(deg2rad(o(:,1)));
o(:,1) = rad2deg(o(:,1));
o(:,1) = o(:,1) + 90;

%Altitude angle
o(:,2) = -o(:,2);
%o(:,2) = unwrap(deg2rad(o(:,2)));
%o(:,2) = rad2deg(o(:,2));


az.YData=to;
az.XData = o(:,1);
alt.XData = to;
alt.YData = o(:,2);
azalt.XData=o(:,1);
azalt.YData = o(:,2);
drawnow;

pause(step)
end

m.Logging = 0;

%%
%Suavizado de los datos
[o,to] = orientlog(m);
figure
hold on
o(:,1) = unwrap(deg2rad(o(:,1)));
o(:,1) = rad2deg(o(:,1));
o(:,1) = o(:,1) + 90;
plot(to, o(:,1))
o(:,1) = smoothdata(o(:,1), 'gaussian', 500);
%o(:,1) = sgolayfilt(o(:,1), 3, 301); % orden 3, ventana 51 puntos
%o(:,1) = smoothdata(o(:,1), 'gaussian', 5);
%o(:,1) = smoothdata(o(:,1), 'movmean', 50);
plot(to, o(:,1))

figure
hold on
o(:,2) = -o(:,2);
plot(to, o(:,2))
o(:,2) = smoothdata(o(:,2), 'gaussian', 500);
%o(:,2) = sgolayfilt(o(:,2), 3, 301);
%o(:,2) = smoothdata(o(:,2), 'gaussian', 5);
%o(:,2) = smoothdata(o(:,2), 'movmean', 50);
plot(to, o(:,2))
toc
%%
tstart=tic;

%PIDs sobre los fragmentos de telescopio.
rESP0=readmatrix("Telescopio completo\Datos\coordenadasESP.txt"); %[Coordenadas punto focal; Coordenadas centroide de cada espejo]
v=readmatrix("Telescopio completo\Datos\verticesESPvertical.txt"); % Vertices para dibujar el segmento [xi;yi;zi]

%Definimos el tiempo total de simulación.
tfin=to(end); %Segundo final de la simulación.
PIDstep=1/100; %Periodo de tiempo entre ejecuciones del PID
tiempo=0:PIDstep:tfin; %Tiempos en los que se calculan los PID

%Tenemos todos los centroides de los espejos. Definimos las coordenadas
%angulares objetivo para cada instante de tiempo. El ESPEJO COMPLETO trata
%de observar el objetivo directamente.
AltAzSol=zeros(length(tiempo),2);
AltAzSol(:,1)=interp1(to,o(:,2),tiempo);
AltAzSol(:,2)=interp1(to,o(:,1),tiempo);

%Calculamos primero las posiciones del ESPEJO COMPLETO para cada instante
%de tiempo. Guardamos las posiciones angulares para cada paso de tiempo.
[~, AltAzESP]=SimPID(tiempo, AltAzSol, "viento", true);
disp("Posiciones del telecopio calculadas.")
%disp(size(t))
%disp(size(AltAzESP))

%A partir de las posiciones del ESPEJO COMPLETO traducimos las coordenadas
%angulares objetivo al sistema de referencia propio de los SEGMENTOS. Los
%SEGMENTOS tratan de reflejar la imagen proviniente de las coordenadas
%angulares objetivo sobre rESP0[1,:]. Guardamos las posiciones en el
%sistema de referencia propio de los SEGMENTOS.
AltAzSol_SisSegm=AltAzSol-[AltAzESP(:,1),AltAzESP(:,3)];
% plot(AltAzSol_SisSegm)

%Ejercemos control sobre cada uno de los SEGMENTOS y guardamos su posición
%para cada paso de tiempo.
disp("Calculando posiciones de los segmentos.")
AltAzSEG=zeros(length(tiempo),4,length(rESP0)-1);
AltAzSEGobj=zeros(length(tiempo),2,length(rESP0)-1);

tseg=tic;
for i=2:length(rESP0)
    
    AngEsp=zeros(length(tiempo),2);
    for j=1:length(tiempo)
        [Az,El] = AnguloEspejo(rESP0(i,:)',rESP0(1,:),AltAzSol_SisSegm(j,1),AltAzSol_SisSegm(j,2));
        AngEsp(j,:)=[Az,El];
    end
    [tSeg, AltAz]=SimPID(tiempo,AngEsp,planta="seg", limT=100, Ki=0.001, NCapas=(-3+sqrt(12*(length(rESP0)-1)-3))/6);
    AltAzSEGobj(:,:,i-1)=AngEsp;
    AltAzSEG(:,:,i-1)=AltAz;

    tsegEND=toc(tseg);
    fprintf('Segmentos calculados: %.0f / %.0f\n', i-1, (length(rESP0)-1));
    left=tsegEND/(i-1)*(length(rESP0)-i+1);
    if left<60
        fprintf('Tiempo restante estimado: %.0f s\n',left)
        disp('')
    elseif left>60 && left<3600
        fprintf('Tiempo restante estimado: %.0f m %.0f s\n',left/60, mod(left,60))
        disp('')
    else
        fprintf('Tiempo restante estimado: %.0f h %.0f m %.0f s\n',left/3600, mod(left,3600)/60, mod(mod(left,3600),60))
        disp('')
    end
end
disp("Posiciones de los segmentos calculados.")


%Cálculo de la intersección de los rayos reflejados con el plano focal del
%espejo completo.
Pint=zeros(length(rESP0)-1,3,length(tiempo));
for i=1:length(tiempo)
    Pint(:,:,i) = CoordReflPlanoFocal(rESP0, repmat(AltAzSol_SisSegm(i,1),length(rESP0)-1,1), repmat(AltAzSol_SisSegm(i,2),length(rESP0)-1,1), squeeze(AltAzSEG(i,1,:)), squeeze(AltAzSEG(i,3,:)));
    %(rESP0, alt_i, az_i, alt_m, az_m)
end
Pint=permute(Pint,[3 2 1]);
tEND=toc(tstart);

if tEND<60
    fprintf('Tiempo total de simulación: %.0f s\n',tEND)
    disp('')
elseif tEND>60 && tEND<3600
    fprintf('Tiempo total de simulación: %.0f m %.0f s\n',tEND/60, mod(tEND,60))
    disp('')
else
    fprintf('Tiempo total de simulación: %.0f h %.0f m %.0f s\n',tEND/3600, mod(tEND,3600)/60, mod(mod(tEND,3600),60))
    disp('')
end
%%
dibESPEJO(tiempo, AltAzESP, AltAzSol, AltAzSEG, AltAzSEGobj, Pint, vel=1, fps=20, trayectoria=1, rESP0=rESP0, record=0, view=1)