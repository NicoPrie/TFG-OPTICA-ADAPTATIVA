d=linspace(1,365);
Year=2026;
T_gmt=12;  
phi_0=40.437271;
lmbd_0=-3.714715;
alpha_s_t=zeros(1,length(d));
gamma_s_t=zeros(1,length(d));

for i=1:length(d)
    Day = d(i);
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
plot3(x, y, z,'r',LineWidth=1)
constantplane([0,0,1],0)
sphere(FaceColor= 'white', FaceAlpha='0.5', LineWidth=0.1, LineColor=[1,1,1,0.2])

text(0,1,0,'N',Color='r')
text(0,-1.1,0,'S',Color='b')
text(1.1,0,0,'E')
text(-1,0,0,'O')

axis('equal', 'off')
xlim([-1,1])
ylim([-1,1])
zlim([-1,1])

title({'Analema para el 2026', 'a las 12 UTC desde Madrid'})

grid off
view(30,15)

exportgraphics(gcf,'C:\Users\priet\OneDrive - Universidad Complutense de Madrid (UCM)\Escritorio\Carrera\4 - Cuarto\TFG\Figuras\Analema12h2026.png','Resolution',300)