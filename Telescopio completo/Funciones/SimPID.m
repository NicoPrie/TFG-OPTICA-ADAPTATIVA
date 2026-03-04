function [t, AltAz] = SimPID(tiempo,AltAzObj, opciones)
arguments (Input)
    tiempo
    AltAzObj
    opciones.AzPV = [0;0] %[Pos;Vel]
    opciones.AltPV = [0;0] %[Pos;Vel]
    opciones.Kp = 8
    opciones.Ki = 0.001
    opciones.Kd = 80
    opciones.planta = "compl" %"compl" -> Telescopio completo. "seg" -> Segmento
    opciones.viento = false
    opciones.limT = 20000000
end
    AzPV=opciones.AzPV;
    AltPV=opciones.AltPV;
    Kp=opciones.Kp;
    Ki=opciones.Ki;
    Kd=opciones.Kd;
    planta=opciones.planta;
    viento=opciones.viento;
    limT=opciones.limT;

%Preasignamos memoria para las soluciones
PIDstep=tiempo(2)-tiempo(1);
nSIMsteps=20;
Nt = length(tiempo);
N = (nSIMsteps-1)*(Nt) + 1;

t = zeros(N,1); disp(size(t))
AltAz = zeros(N,4); disp(size(AltAz))

clear Nt N
%Datos de la planta + PID:
PIDDataAz=[0,0,0,0,0,0]; %Inicializacion del objeto PID Azimutal [angREF,Kp,Ki,Kd,last_error,integral]
PIDDataAlt=[0,0,0,0,0,0]; %Inicializacion del objeto PID Altitud
nu_fun= @(t) (0+0.8*sin(0.9*t)+0.9+sin(0.5*t)+0.3*sin(0.7*t))*10^2; %Ruido (Viento)

k=1;
paso_progreso = round(length(tiempo) / 10); % Calcula el número de pasos para un 10%
for i=1:length(tiempo)
    %Cálculo del torque en el ángulo altitud.
    PIDDataAlt=[AltAzObj(i,1),Kp,Ki,Kd,PIDDataAlt(5),PIDDataAlt(6)];
    [TAlt,PIDDataAlt] = calcularPID(PIDDataAlt,AltPV(1),PIDstep,limT);
    
    %Cálculo del torque en el ángulo acimutal.
    PIDDataAz=[AltAzObj(i,2),Kp,Ki,Kd,PIDDataAz(5),PIDDataAz(6)];
    [TAz,PIDDataAz] = calcularPID(PIDDataAz,AzPV(1),PIDstep,limT);
    
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
    if viento
        nu=nu_fun(tiempo(i));
    else
        nu=0;
    end
    plantaAz=EDOplanta(J,D,K,nu,TAz);
    plantaAlt=EDOplanta(J,D,K,nu,TAlt);
    [t1,X1]=ode45(plantaAlt, linspace(0,PIDstep, nSIMsteps),AltPV);
    [~,X2]=ode45(plantaAz, linspace(0,PIDstep, nSIMsteps), AzPV);
    AltPV=X1(end,:);
    AzPV=X2(end,:);
    t(k:(k+nSIMsteps-1),:)=t1+t(k);
    AltAz(k:(k+nSIMsteps-1),:)=[X1,X2];

    k=k+nSIMsteps-1;

    if mod(i, paso_progreso) == 0
    fprintf('Progreso: %.0f%%\n', (i / length(tiempo)) * 100);
    end
end