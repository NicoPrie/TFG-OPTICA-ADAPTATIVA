t=datetime("now","TimeZone","UTC");
%t=datetime(2004,4,18,3,0,0);
Year=year(t);
Day=day(t,"dayofyear");
T_gmt=hour(t)+minute(t)/60+second(t)/3600;

[alpha, delta, R_TS, E_min] = PosSol_EclGeo(Year,Day,T_gmt);

phi_0=40.4373;
lmbd_0=-3.7154;

[alpha_s, gamma_s] = PosSol_SistTopc(phi_0,lmbd_0,T_gmt,delta,E_min);

x = cosd(alpha_s).*sind(gamma_s);
y = cosd(alpha_s).*cosd(gamma_s);
z = sind(alpha_s);

figure
plot3(0,0,0,'r*')
hold on
plot3(x, y, z,'b*')
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