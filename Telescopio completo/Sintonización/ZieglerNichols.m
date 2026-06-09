%Ziegler Nichols
n=1;

Kp=0.2;
Ki=0;
Kd=0;

tfin = 60*5;
dt = 1/100;
t = 0:dt:tfin;

[~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", Kp, "Ki", Ki, "Kd", Kd, "planta", "seg","NCapas",n);

Ku=Kp;

h=figure;
hold on
plot(t,AltAzESP(:,1))

%%
fun=@(x, xdata) x(1)+x(2)*sin(x(3)*xdata+x(4));
x0=[1, 1, 2*pi/14, pi/2];
[x,resnorm,~,exitflag,output] = lsqcurvefit(fun,x0,t,AltAzESP(:,1)');
Tu=2*pi/x(3);

figure(h)
plot(t(1:30:end),fun(x,t(1:30:end)),'*')

%%
Kp=0.6*Ku;
Ki=1.2*Ku/Tu;
Kd=0.075*Ku*Tu;

[~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", Kp, "Ki", Ki, "Kd", Kd, "planta", "seg","NCapas",n);

%%
figure
title({'Respuesta del sistema + PID a un escalón', 'con los parámetros de Ziegler-Nichols'})
hold on; grid on; box on

RGB = orderedcolors("gem");
yline(1,'-',Color=RGB(2,:))
plot(t(1:100:end),AltAzESP(1:100:end,1), '-.',LineWidth=1,Color=RGB(1,:))
legend('Escalón','Trayectoria del sistema','Location','southeast')

xlabel('Tiempo (s)')
ylabel('Ángulo (º)')

exportgraphics(gcf,'C:\Users\priet\OneDrive - Universidad Complutense de Madrid (UCM)\Escritorio\Carrera\4 - Cuarto\TFG\Figuras\RespuestaZiegler.png','Resolution',300)
%clearvars -except Kp Ki Kd Ku Tu