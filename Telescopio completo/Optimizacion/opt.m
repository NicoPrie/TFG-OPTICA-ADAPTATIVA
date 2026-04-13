n=1;
cost = @(K) pid_cost(K,n);

%K0 = [182.1158 0.0127 1.0000e+03];  % initial guess
%K0 = [8 0.001 80];  % initial guess
%K0 = [15 0.001 180];  % initial guess
%K0 = [Kp Ki Kd];
K0 = [182.1158 0.0127 1.0000e+03]/123.6927;

options = optimset('Display','iter');

K_opt = fminsearch(cost, K0, options);

Kp = K_opt(1);
Ki = K_opt(2);
Kd = K_opt(3);

%%
tfin = 25;
dt = 1/100;
t = 0:dt:tfin;

[~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", Kp, "Ki", Ki, "Kd", Kd, "planta", "seg","NCapas",n);

figure
hold on
plot(t,AltAzESP(:,1))
plot([t(1),t(end)],[1,1])