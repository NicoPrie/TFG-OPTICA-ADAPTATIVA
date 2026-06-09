s=1;

%t=datetime("now","TimeZone","UTC");
t=datetime(2026,08,03); %Calcular para día concreto
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

%%
figure
tiles=tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
sgtitle({'','','\bf Trayectoria del sol - 08/06/2026',''})

idx_pos = z >= 0;
idx_neg = z < 0;

threeDplot=nexttile(tiles,[2,1]);
plot3(0,0,0,'b.', 'MarkerSize',9)
hold on
plot3(x(idx_pos), y(idx_pos), z(idx_pos), 'r', 'LineWidth', 1)
plot3(x(idx_neg), y(idx_neg), z(idx_neg), 'k', 'LineWidth', 1)
constantplane([0,0,1],0, FaceAlpha=0.1)
sphere(FaceColor='white', FaceAlpha='0.4', EdgeAlpha='0.3')
axis('equal', 'off')
camzoom(1.24)
view(-115,20)

text(0,1.2,0,'N', 'Color','r')
text(0,-1.1,0,'S','Color','b')
text(1.1,0,0,'E','Color','k')
text(-1.2,0,0,'O','Color','k')
plot3([1.1,-1.1], [0,0], [0,0],'k--')
plot3([0,0], [1.1,-1.1], [0,0],'k--')

axis equal
xlim([-1.1,1.1])
ylim([-1.1,1.1])
zlim([-1.1,1.1])

grid on

altplot=nexttile(tiles,[1,1]);
plot(Horas,alpha_s_t); xlabel('Hora'); ylabel('Altitud solar (º)')
xlim([Horas(1),Horas(end)])
ylim([min(alpha_s_t),max(alpha_s_t)+5])
grid on

azplot=nexttile(tiles,[1,1]);
plot(Horas,unwrap(gamma_s_t)-360); xlabel('Hora'); ylabel('Acimut solar (º)')
xlim([Horas(1),Horas(end)])
ylim([min(unwrap(gamma_s_t)-360),max(unwrap(gamma_s_t)-360)])
grid on


if s
exportgraphics(gcf,'C:\Users\priet\OneDrive - Universidad Complutense de Madrid (UCM)\Escritorio\Carrera\4 - Cuarto\TFG\Figuras\TRAYECTORIASOL_08_06_2026.png','Resolution',300)
end

%%
figure
tiles=tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
sgtitle({'','','\bf Trayectoria del sol - 08/06/2026',''})

idx_pos = z >= 0;
idx_neg = z < 0;

x_pos = x; y_pos = y; z_pos = z;
x_pos(idx_neg) = NaN; y_pos(idx_neg) = NaN; z_pos(idx_neg) = NaN;

x_neg = x; y_neg = y; z_neg = z;
x_neg(idx_pos) = NaN; y_neg(idx_pos) = NaN; z_neg(idx_pos) = NaN;

threeDplot=nexttile(tiles,[2,1]);
plot3(0,0,0,'b.', 'MarkerSize',9, 'HandleVisibility','off')
hold on
h_pos = plot3(x_pos, y_pos, z_pos, 'r', 'LineWidth', 1);
h_neg = plot3(x_neg, y_neg, z_neg, 'k', 'LineWidth', 1);
legend([h_pos, h_neg], {'Sobre el horizonte', 'Bajo el horizonte'}, 'Location', 'best')
constantplane([0,0,1],0, FaceAlpha=0.1,HandleVisibility='off')
sphere(FaceColor='white', FaceAlpha='0.4', EdgeAlpha='0.3',HandleVisibility='off')
axis('equal', 'off')
camzoom(1.24)
view(-115,20)
text(0,1.2,0,'N', 'Color','r')
text(0,-1.1,0,'S','Color','b')
text(1.1,0,0,'E','Color','k')
text(-1.2,0,0,'O','Color','k')
plot3([1.1,-1.1], [0,0], [0,0],'k--', 'HandleVisibility','off')
plot3([0,0], [1.1,-1.1], [0,0],'k--', 'HandleVisibility','off')
axis equal
xlim([-1.1,1.1])
ylim([-1.1,1.1])
zlim([-1.1,1.1])
grid on

altplot=nexttile(tiles,[1,1]);
plot(Horas,alpha_s_t); xlabel('Hora UTC'); ylabel('Altitud solar (º)')
xlim([Horas(1),Horas(end)])
ylim([min(alpha_s_t),max(alpha_s_t)+5])
grid on

azplot=nexttile(tiles,[1,1]);
plot(Horas,unwrap(gamma_s_t)-360); xlabel('Hora UTC'); ylabel('Acimut solar (º)')
xlim([Horas(1),Horas(end)])
ylim([min(unwrap(gamma_s_t)-360),max(unwrap(gamma_s_t)-360)])
grid on

if s
exportgraphics(gcf,'C:\Users\priet\OneDrive - Universidad Complutense de Madrid (UCM)\Escritorio\Carrera\4 - Cuarto\TFG\Figuras\TRAYECTORIASOL_08_06_2026.png','Resolution',300)
end