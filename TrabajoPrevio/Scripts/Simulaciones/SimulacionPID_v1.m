tic
tfin=60*4;
PIDstep=0.01;
tiempo=0:PIDstep:tfin;
PIDDataAz=[0,0,0,0,0,0];
PIDDataAlt=[0,0,0,0,0,0];
AzPos=[0;0]; %[Pos;Vel]
AltPos=[0;0]; %[Pos;Vel]
rEsp=[0,0,0];
rObj=[3,0,2];

ObjAltAzTot=[];

nu_fun= @(t) (0+0.8*sin(0.9*t)+0.9+sin(0.5*t)+0.3*sin(0.7*t))*10^2;

savet=0;
saveT=[];
saveTot=[];
saveAltAz=[];

for i=1:length(tiempo)
    %Obtenemos el ángulo objetivo.
    [AltAzEsp,~]= AngFCordT([40.437271,-3.714715],rEsp,rObj,[2025, 12, 12+tiempo(i)/(60*60)]);
    ObjAltAzTot=[ObjAltAzTot;AltAzEsp];
    
    %Parámetros del PID
    Kp=8;
    Kd=0.0001;
    Ki=80;

    %Cálculo del torque en el ángulo altitud.
    PIDDataAlt=[AltAzEsp(1),Kp,Kd,Ki,PIDDataAlt(5),PIDDataAlt(6)];
    [TAlt,PIDDataAlt] = calcularPID(PIDDataAlt,AltPos(1),PIDstep,20000);
    %TAlt=0;

    %Cálculo del torque en el ángulo acimutal.
    PIDDataAz=[AltAzEsp(2),Kp,Kd,Ki,PIDDataAz(5),PIDDataAz(6)];
    [TAz,PIDDataAz] = calcularPID(PIDDataAz,AzPos(1),PIDstep,20000);
    %TAz=0;

    saveT=[saveT; TAlt, TAz];

    %nu=nu_fun(tiempo(i));
    nu=0;
    plantaAz=EDOplanta(100,10,0,nu,TAz);
    plantaAlt=EDOplanta(100,10,0,nu,TAlt);
    [t1,X1]=ode45(plantaAlt,0:0.001:PIDstep,AltPos);
    [t2,X2]=ode45(plantaAz, 0:0.001:PIDstep, AzPos);
    AltPos=X1(end,:);
    AzPos=X2(end,:);
    savet=[savet;t1+savet(end,1)];
    saveAltAz=[saveAltAz;X1,X2];

    if mod(i, 1000) == 0
        % Equivalente a f'Iteración {i}: Ángulo = {AzPos(i)}'
        fprintf('Progreso: %.0f%%\n ', tiempo(i)/tiempo(end)*100);
    end
end

clearvars -except savet saveAltAz saveT tiempo ObjAltAzTot nu_fun
savet(1)=[];
toc

figure
hold on
plot(savet,saveAltAz(:,:)) %Posiciones simuladas de la planta
plot(tiempo',ObjAltAzTot(:,:)) %Posiciones objetivo para la planta
xlim([0,tiempo(end)])

figure
hold on
plot(tiempo,saveT)
plot(tiempo,nu_fun(tiempo))
xlim([0.2,tiempo(end)])

input('Presiona enter para ver la animación del proceso.')
dibujarEspejo(savet(1:150:end),saveAltAz(1:150:end,:),tiempo',ObjAltAzTot(:,:))