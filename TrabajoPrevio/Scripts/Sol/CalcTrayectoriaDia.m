t=datetime("now","TimeZone","UTC");
%t=datetime(2004,4,18); %Calcular para día concreto
Year=year(t);
Day=day(t,"dayofyear"); %Calcular para hoy
Horas=linspace(0,24,10000);
phi_0=40.437271;
lmbd_0=-3.714715;
alpha_s_t=zeros(1,length(Horas));
gamma_s_t=zeros(1,length(Horas));

for i=1:length(Horas)
    T_gmt = Horas(i);
    [alpha, delta, R_TS, E_min] = PosSol_EclGeo(Year,Day,T_gmt);
    [alpha_s, gamma_s] = PosSol_SistTopc(phi_0,lmbd_0,T_gmt,delta,E_min);
    alpha_s_t(i)=alpha_s;
    gamma_s_t(i)=gamma_s;
end

x = cosd(alpha_s_t).*sind(gamma_s_t);
y = cosd(alpha_s_t).*cosd(gamma_s_t);
z = sind(alpha_s_t);

figure
plot3(0,0,0,'r*')
hold on
plot3(x, y, z,'b')
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

grid on
