function [t, AltAz] = SimPID(tiempo,AltAzObj, AzPV, AltPV, Kp, Kd, Ki, planta)
arguments (Input)
    tiempo
    AltAzObj
    AzPV=[0;0]; %[Pos;Vel]
    AltPV=[0;0]; %[Pos;Vel]
    Kp=8;
    Kd=0.001;
    Ki=80;
    planta="compl"; %"compl" -> Telescopio completo. "seg" -> Segmento
end

%Preasignamos memoria para las soluciones
PIDstep=tiempo(2)-tiempo(1);
nSIMsteps=10;
Nt = length(tiempo);
N = (nSIMsteps-1)*(Nt) + 1;

t = zeros(N,1); disp(size(t))
AltAz = zeros(N,4); disp(size(AltAz))

%Datos de la planta + PID:
PIDDataAz=[0,0,0,0,0,0]; %Inicializacion del objeto PID Azimutal [angREF,Kp,Ki,Kd,last_error,integral]
PIDDataAlt=[0,0,0,0,0,0]; %Inicializacion del objeto PID Altitud
nu_fun= @(t) (0+0.8*sin(0.9*t)+0.9+sin(0.5*t)+0.3*sin(0.7*t))*10^2; %Ruido (Viento)

k=1;
for i=1:length(tiempo)
    %Cálculo del torque en el ángulo altitud.
    PIDDataAlt=[AltAzObj(i,1),Kp,Kd,Ki,PIDDataAlt(5),PIDDataAlt(6)];
    [TAlt,PIDDataAlt] = calcularPID(PIDDataAlt,AltPV(1),PIDstep,20000000);
    
    %Cálculo del torque en el ángulo acimutal.
    PIDDataAz=[AltAzObj(i,2),Kp,Kd,Ki,PIDDataAz(5),PIDDataAz(6)];
    [TAz,PIDDataAz] = calcularPID(PIDDataAz,AzPV(1),PIDstep,20000000);
    
    %Definición de las constantes de la planta.
    if planta=="compl"
        J=100;
        D=10;
        K=0;
    elseif planta=="seg"
        J=1;
        D=0.1;
        K=0;
    end

    %Cálculo de la evolucion de la planta.
    %nu=nu_fun(tiempo(i));
    nu=0;
    plantaAz=EDOplanta(J,D,K,nu,TAz);
    plantaAlt=EDOplanta(J,D,K,nu,TAlt);
    [t1,X1]=ode45(plantaAlt, linspace(0,PIDstep, nSIMsteps),AltPV);
    [~,X2]=ode45(plantaAz, linspace(0,PIDstep, nSIMsteps), AzPV);
    AltPV=X1(end,:);
    AzPV=X2(end,:);
    t(k:(k+nSIMsteps-1),:)=t1+t(k);
    AltAz(k:(k+nSIMsteps-1),:)=[X1,X2];

    k=k+nSIMsteps-1;
end