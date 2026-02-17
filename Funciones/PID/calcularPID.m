function [output,PIDData] =calcularPID(PIDData,angRN,dt,Tmax)
%PIDData=[angREF,Kp,Ki,Kd,last_error,integral]
angREF = PIDData(1);
Kp = PIDData(2);
Ki = PIDData(3);
Kd = PIDData(4);
last_error = PIDData(5);
integral = PIDData(6);
%jajaj

%Calculamos el error:
error=angREF-angRN;

%Término proporcional:
P=Kp*error;

%Término integral:
integral = integral + error*dt;
I = Ki*integral;

%Término derivativo:
D = Kd*(error-last_error)/dt;

%Salida del PID:
output = P + I + D;
if abs(output)>Tmax
    output=Tmax*sign(output);
end

%Actualizamos PIDData:
PIDData(5) = error;
PIDData(6) = integral;