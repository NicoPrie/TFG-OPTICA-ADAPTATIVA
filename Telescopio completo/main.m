clear
clc

tic
%PIDs sobre los fragmentos de telescopio.
rESP0=readmatrix("Telescopio completo\Datos\coordenadasESP.txt"); %[Coordenadas punto focal; Coordenadas centroide de cada espejo]
v=readmatrix("Telescopio completo\Datos\verticesESPvertical.txt"); % Vertices para dibujar el segmento [xi;yi;zi]

%Definimos el tiempo total de simulación.
tfin=60*4; %Segundo final de la simulación.
PIDstep=1/100; %Periodo de tiempo entre ejecuciones del PID
tiempo=0:PIDstep:tfin; %Tiempos en los que se calculan los PID

%Tenemos todos los centroides de los espejos. Definimos las coordenadas
%angulares objetivo para cada instante de tiempo. El ESPEJO COMPLETO trata
%de observar el objetivo directamente.
for i=1:length(tiempo)
    [~, AltAzSol(i,:)]=AngFCordT([40.437271,-3.714715],[0,0,0],[0,0,0],[2025, 12, 12+tiempo(i)/(60*60)]);
end

%Calculamos primero las posiciones del ESPEJO COMPLETO para cada instante
%de tiempo. Guardamos las posiciones angulares para cada paso de tiempo.
[~, AltAzESP]=SimPID(tiempo,AltAzSol,"viento",true);
disp("Posiciones del telecopio calculadas.")
%disp(size(t))
%disp(size(AltAzESP))

%A partir de las posiciones del ESPEJO COMPLETO traducimos las coordenadas
%angulares objetivo al sistema de referencia propio de los SEGMENTOS. Los
%SEGMENTOS tratan de reflejar la imagen proviniente de las coordenadas
%angulares objetivo sobre rESP0[1,:]. Guardamos las posiciones en el
%sistema de referencia propio de los SEGMENTOS.
%for t in
for i=1:length(tiempo)
    [~, AltAzSolt(i,:)]=AngFCordT([40.437271,-3.714715],[0,0,0],[0,0,0],[2025, 12, 12+tiempo(i)/(60*60)]);
end

AltAzSol_SisSegm=AltAzSolt-[AltAzESP(:,1),AltAzESP(:,3)];
% plot(AltAzSol_SisSegm)

%Ejercemos control sobre cada uno de los SEGMENTOS y guardamos su posición
%para cada paso de tiempo.
disp("Calculando posiciones de los segmentos.")
AltAzSEG=zeros(length(tiempo),4,length(rESP0)-1);
AltAzSEGobj=zeros(length(tiempo),2,length(rESP0)-1);

for i=2:length(rESP0)
    AngEsp=zeros(length(tiempo),2);
    for j=1:length(tiempo)
        [Az,El] = AnguloEspejo(rESP0(i,:)',rESP0(1,:),AltAzSol_SisSegm(j,1),AltAzSol_SisSegm(j,2));
        AngEsp(j,:)=[Az,El];
    end
    [tSeg, AltAz]=SimPID(tiempo,AngEsp,planta="seg", limT=100, Ki=0.001);
    AltAzSEGobj(:,:,i-1)=AngEsp;
    AltAzSEG(:,:,i-1)=AltAz;

    fprintf('Segmentos calculados: %.0f / %.0f\n', i-1, (length(rESP0)-1));
end
disp("Posiciones de los segmentos calculados.")

%%
%Cálculo de la intersección de los rayos reflejados con el plano focal del
%espejo completo.
for i=1:length(tiempo)
Pint(i,:) = CoordReflPlanoFocal(rESP0, repmat(AltAzSol_SisSegm(i,1),length(tiempo),1), repmat(AltAzSol_SisSegm(i,2),length(tiempo),1), squeeze(AltAzSEG(i,1,:)), squeeze(AltAzSEG(i,3,:)));
%(rESP0, alt_i, az_i, alt_m, az_m)
end
toc
%%
skip=20;
dibESPEJO(tiempo(1:skip:end),AltAzESP(1:skip:end,:), AltAzSol(1:skip:end,:), AltAzSEG(1:skip:end,:,:),AltAzSEGobj(1:skip:end,:,:))

%%
%Dibujamos la evolución del ESPEJO COMPLETO y SEGMENTOS.
% figure
% plot(tiempo,AltAzSol)
% hold on
% plot(t, [AltAzESP(:,1),AltAzESP(:,3)])

k=1:1:size(AltAzSEGobj,3);
figure

subplot(2,1,1)
hold on
%for i=1:size(AngEspSeg,3)
for i=k
h = plot(t,AltAzSEGobj(:,1,i),'--');
plot(tSeg, AltAzSEG(:,1,i),'Color', h.Color)
%ylim([-20,20])
end
title("Ángulo Altitud")

subplot(2,1,2)
hold on
%for i=1:size(AngEspSeg,3)
for i=k
h = plot(t,AltAzSEGobj(:,2,i),'--');
plot(tSeg, AltAzSEG(:,3,i),'Color', h.Color)
%ylim([-20,20])
end
title("Ángulo Acimutal")

toc

% %Reducir datos
% fps=60;
% saveAltAz=interp1(t,AltAz,0:1/fps:tfin);
% savet=(0:1/fps:tfin)';
% 
% for i=1:length(savet)
%     [~, ObjAltAz(i,:)]=AngFCordT([40.437271,-3.714715],[0,0,0],[0,0,0],[2025, 12, 12+savet(i)/(60*60)]);
% end
% 
% input('Presiona enter para ver la animación del proceso.')
% dibujarEspejo_v2(savet,saveAltAz,ObjAltAz)