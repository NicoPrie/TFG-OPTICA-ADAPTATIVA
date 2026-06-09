n=1;
cost = @(K) pid_cost(K,n);

%K0 = [182.1158 0.0127 1.0000e+03];  % initial guess
%K0 = [8 0.001 80];  % initial guess
K0 = [15 0 30];  % initial guess
%K0 = [Kp Ki Kd];
%K0 = [182.1158 0.0127 1.0000e+03]/123.6927;

%K0 = [18.5847, 7.4917e-11, 36.5524];
%K0 = [0.12	0.0171	0.2107]; %PARÁMETROS DE ZIEGLER NICHOLS

options = optimset(Display="iter",PlotFcns=@optimplotfval);

K_opt = fminsearch(cost, K0, options);

Kp = K_opt(1); disp(Kp)
Ki = K_opt(2); disp(Ki)
Kd = K_opt(3); disp(Kd)

box on
xlabel('Iteración')
ylabel('Valor de J')
title('Evolución de la función de coste - Nelder-Mead')

%%
tfin = 7;
dt = 1/100;
t = 0:dt:tfin;

[~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", Kp, "Ki", Ki, "Kd", Kd, "planta", "seg","NCapas",n);

%%
figure
title({'Respuesta del sistema + PID a un escalón', 'con los parámetros de la función de coste'})
hold on; grid on; box on

RGB = orderedcolors("gem");
yline(1,'-',Color=RGB(2,:))
plot(t,AltAzESP(:,1), '-.', LineWidth=1,Color=RGB(1,:))
legend('Escalón','Trayectoria del sistema','Location','southeast')

xlabel('Tiempo (s)')
ylabel('Ángulo (º)')

exportgraphics(gcf,'C:\Users\priet\OneDrive - Universidad Complutense de Madrid (UCM)\Escritorio\Carrera\4 - Cuarto\TFG\Figuras\RespuestaFCoste.png','Resolution',300)
