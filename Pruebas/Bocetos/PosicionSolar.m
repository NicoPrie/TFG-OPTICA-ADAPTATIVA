%Número de dias terrestres desde J2000.0 UT:
t=datetime("now","TimeZone","UTC");
Year=year(t);
Nleap=sum( (mod(2000:(Year-1),4)==0 & mod(2000:(Year-1),100)~=0) | mod(2000:(Year-1),400)==0 );
Day=day(t,"dayofyear");

T_gmt=hour(t)+minute(t)/60+second(t)/3600;
n=-1.5+(Year-2000)*365+Nleap+Day+(T_gmt)/24;

%Parámetros orbitales (Sol geocentrista)
L=mod(280.466+0.9856474*n,360); %Grados
g=mod(357.528+0.9856003*n,360); %Grados
lmbd=mod(L+1.915*sind(g)+0.020*sind(2*g),360); %Grados
eps=23.440-0.0000004*n; %Grados

alpha=mod(atan2d(cosd(eps)*sind(lmbd),cosd(lmbd)),360);
delta=asind(sind(eps)*sind(lmbd));

Res=1.00014-0.01671*cosd(g)-0.00014*cosd(2*g); %au
E_min=(L-alpha)*4; %min

%Coordenadas referidas a la tierra
phi_0=40.437271;
lmbd_0=-3.714715;

phi_s=delta;
lmbd_s=-15*(T_gmt-12+E_min/60);

Sx=cosd(phi_s)*sind(lmbd_s-lmbd_0);
Sy=cosd(phi_0)*sind(phi_s)-sind(phi_0)*cosd(phi_s)*cosd(lmbd_s-lmbd_0);
Sz=sind(phi_0)*sind(phi_s)+cosd(phi_0)*cosd(phi_s)*cosd(lmbd_s-lmbd_0);

alpha_s=90-acosd(Sz);
gamma_s = mod(atan2d(Sx, Sy), 360);

disp(alpha_s)
disp(gamma_s)

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