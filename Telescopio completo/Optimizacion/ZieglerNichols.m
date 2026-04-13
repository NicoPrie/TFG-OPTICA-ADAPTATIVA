%Ziegler Nichols
n=1;

Kp=2510;
Ki=0;
Kd=0;

tfin = 25;
dt = 1/100;
t = 0:dt:tfin;

[~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", Kp, "Ki", Ki, "Kd", Kd, "planta", "seg","NCapas",n);

Ku=Kp;

h=figure;
hold on
plot(t,AltAzESP(:,1))

%%
fun=@(x, xdata) x(1)+x(2)*sin(x(3)*xdata+x(4));
x0=[1 1 2*pi/1.4, pi/2];
[x,resnorm,~,exitflag,output] = lsqcurvefit(fun,x0,t,AltAzESP(:,1)');
Tu=2*pi/x(3);

figure(h)
plot(t,fun(x,t))

%%
Kp=1.2*Ku;
Ki=0.6*Ku/Tu;
Kd=0.6*Ku*Tu;

[~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", Kp, "Ki", Ki, "Kd", Kd, "planta", "seg","NCapas",n);

figure
hold on
plot(t,AltAzESP(:,1))

clearvars -except Kp Ki Kd