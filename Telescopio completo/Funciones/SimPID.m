function [tiempo, AltAz] = SimPID(tiempo,AltAzObj, opciones)
arguments (Input)
    tiempo
    AltAzObj
    opciones.AzPV = [0;0] %[Pos;Vel]
    opciones.AltPV = [0;0] %[Pos;Vel]
    %opciones.Kp = 8
    %opciones.Ki = 0.001
    %opciones.Kd = 80
    % opciones.Kp = 182.1158/123.6927
    % opciones.Ki = 0.0127/123.6927
    % opciones.Kd = 1.0000e+03/123.6927
    % opciones.Kp = 15.5786
    % opciones.Ki = 1.2995e-12
    % opciones.Kd = 36.6375
    opciones.Kp = 18.5847
    opciones.Ki = 7.4917e-11
    opciones.Kd = 36.5524
    opciones.planta = "compl" %"compl" -> Telescopio completo. "seg" -> Segmento
    opciones.viento = false
    opciones.limT = 20000000
    opciones.NCapas = 0
end
    AzPV = opciones.AzPV;
    AltPV = opciones.AltPV;
    Kp = opciones.Kp;
    Ki = opciones.Ki;
    Kd = opciones.Kd;
    planta = opciones.planta;
    viento = opciones.viento;
    limT = opciones.limT;
    NCapas = opciones.NCapas;

%Preasignamos memoria para las soluciones
PIDstep=tiempo(2)-tiempo(1);
N=length(tiempo);
%t = zeros(N,1); disp(size(t))
AltAz = zeros(N,4); %disp(size(AltAz))

clear N
%Datos de la planta + PID:
PIDDataAz=[0,0,0,0,0,0]; %Inicializacion del objeto PID Azimutal [angREF,Kp,Ki,Kd,last_error,integral]
PIDDataAlt=[0,0,0,0,0,0]; %Inicializacion del objeto PID Altitud
%nu_fun= @(t) (3+0.8*sind(0.9*t)+0.9+sind(0.5*t)+0.3*sind(0.7*t))*0.0001; %Ruido (Viento)
nu_fun= @(t) (-0.5+0.8*sin(0.9*t)+0.9+sin(0.5*t)+0.3*sin(0.7*t))*10^2; %Ruido (Viento)

%Definición de las constantes de la planta.
if planta == "compl"
    R=1.28;
    M=19025;
    
    I=[1/4*M*R^2 0 0; 0 1/4*M*R^2 0; 0 0 1/2*M*R^2];

    Jalt=1/4*M*R^2;
    Jaz=@(tht) I(2,2)*cosd(tht)^2 + I(3,3)*sind(tht)^2;
    D=1000;
    K=0;

    anglimAlt=[-180,180];
    anglimAz=[0,360];

    Kp=Kp*Jalt;
    Ki=Ki*Jalt;
    Kd=Kd*Jalt;

elseif planta == "seg"
    assert(NCapas ~= 0, 'Se debe especificar número de segmentos con.');

    R=1.28;
    M=19025;
    R=R/(NCapas*2+1);
    M=M/(3*NCapas*(NCapas+1)+1);

    I=[1/4*M*R^2 0 0; 0 1/4*M*R^2 0; 0 0 1/2*M*R^2];

    Jalt = 1/4*M*R^2;
    Jaz = @(tht) I(2,2)*cosd(tht)^2 + I(3,3)*sind(tht)^2;
    D=Jalt/10;
    K=0;

    anglimAlt=[-45,45];
    anglimAz=[-360,360];

    Kp=Kp*Jalt;
    Ki=Ki*Jalt;
    Kd=Kd*Jalt;
end

%paso_progreso = round(length(tiempo) / 10); % Calcula el número de pasos para un 10%
for i=1:length(tiempo)

    %Cálculo del torque en el ángulo altitud.
    PIDDataAlt=[AltAzObj(i,1),Kp,Ki,Kd,PIDDataAlt(5),PIDDataAlt(6)];
    [TAlt,PIDDataAlt] = calcularPID(PIDDataAlt,AltPV(1),PIDstep,limT, anglimAlt);
    %TAlt=0*TAlt;
    
    %Cálculo del torque en el ángulo acimutal.
    PIDDataAz=[AltAzObj(i,2),Kp,Ki,Kd,PIDDataAz(5),PIDDataAz(6)];
    [TAz,PIDDataAz] = calcularPID(PIDDataAz,AzPV(1),PIDstep,limT, anglimAz);
    %TAz=0*TAz;

    %Cálculo de la evolucion de la planta.
    if viento
        nu=nu_fun(tiempo(i));
    else
        nu=0;
    end
    plantaAz=EDOplanta(Jaz(AltPV(1,1)),D,K,nu,TAz);
    plantaAlt=EDOplanta(Jalt,D,K,nu,TAlt);
    [~,X1]=ode45(plantaAlt, [0,PIDstep],AltPV);
    [~,X2]=ode45(plantaAz, [0,PIDstep], AzPV);
    AltPV=X1(end,:);
    AzPV=X2(end,:);
    AltAz(i,:)=[X1(end,:),X2(end,:)];
    
    %Enseña el porcentaje de simulación completado.
    % if mod(i, paso_progreso) == 0
    % fprintf('Progreso: %.0f%%\n', (i / length(tiempo)) * 100);
    % end
end