clear
clc

%PIDs sobre los fragmentos de telescopio.
rESP0=readmatrix("Telescopio completo\Datos\coordenadasESP.txt"); %[Coordenadas punto focal; Coordenadas centroide de cada espejo]
v=readmatrix("Telescopio completo\Datos\verticesESPvertical.txt"); % Vertices para dibujar el segmento [xi;yi;zi]

%Definimos el tiempo total de simulación.
tfin=5; %Segundo final de la simulación.
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
[t, AltAz]=SimPID(tiempo,AltAzSol);
disp(size(t))
disp(size(AltAz))

%A partir de las posiciones del ESPEJO COMPLETO traducimos las coordenadas
%angulares objetivo al sistema de referencia propio de los SEGMENTOS. Los
%SEGMENTOS tratan de reflejar la imagen proviniente de las coordenadas
%angulares objetivo sobre rESP0[1,:]. Guardamos las posiciones en el
%sistema de referencia propio de los SEGMENTOS.
%for t in
for i=1:length(t)
    [~, AltAzSolt(i,:)]=AngFCordT([40.437271,-3.714715],[0,0,0],[0,0,0],[2025, 12, 12+t(i)/(60*60)]);
end

AltAzSol_SisSegm=AltAzSolt-[AltAz(:,1),AltAz(:,3)];
plot(AltAzSol_SisSegm)

%Ejercemos control sobre cada uno de los SEGMENTOS y guardamos su posición
%para cada paso de tiempo.
AltAzSeg=[];
for i=2:length(rESP0)
    AngEsp=zeros(length(t),2);
    for j=1:length(t)
        [Az,El] = AnguloEspejo(rESP0(i,:)',rESP0(1,:),AltAzSol_SisSegm(j,1),AltAzSol_SisSegm(j,2));
        AngEsp(j,:)=[Az,El];
    end
    [t, AltAz]=SimPID(t,AngEsp,planta="seg");
    AltAzSeg(:,:,i)=AltAz;
end

%Dibujamos la evolución del ESPEJO COMPLETO y SEGMENTOS.
figure
plot(tiempo,AltAzSol)
hold on
plot(t, [AltAz(:,1),AltAz(:,3)])

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