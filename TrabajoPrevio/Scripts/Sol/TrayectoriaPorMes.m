t=datetime("now","TimeZone","UTC");
Year=year(t);
m=1:12; %Calcular para hoy
d=day(datetime(2025,m,1),"dayofyear");
Horas=linspace(0,24,100);
phi_0=40.437271;
lmbd_0=-3.714715;
alpha_s_t=zeros(12,length(Horas));
gamma_s_t=zeros(12,length(Horas));

for j=1:length(d)
    for i=1:length(Horas)
        T_gmt = Horas(i);
        Day=d(j);
        [alpha, delta, R_TS, E_min] = PosSol_EclGeo(Year,Day,T_gmt);
        [alpha_s, gamma_s] = PosSol_SistTopc(phi_0,lmbd_0,T_gmt,delta,E_min);
        alpha_s_t(j,i)=alpha_s;
        gamma_s_t(j,i)=gamma_s;
    end
end

x = cosd(alpha_s_t).*sind(gamma_s_t);
y = cosd(alpha_s_t).*cosd(gamma_s_t);
z = sind(alpha_s_t);

figure
plot3(0,0,0,'r*')
hold on
constantplane([0,0,1],0)
sphere(FaceColor='white', FaceAlpha='0.5')
text(0,1,0,'N')
text(0,-1,0,'S')
text(1,0,0,'E')
text(-1,0,0,'O')
    
axis equal
xlim([-1,1])
ylim([-1,1])
zlim([-1,1])

for i=1:12
    plot3(x(i,:), y(i,:), z(i,:))
    grid on
    pause(1)
end