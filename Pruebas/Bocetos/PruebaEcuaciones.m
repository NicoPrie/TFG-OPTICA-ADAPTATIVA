%Definimos constantes
fi=(40+25/60)*pi/180;
D=days(datetime('today')-datetime(year(datetime('today')),3,20));
disp(D)

%Ecuaciones
sigma=asin(sin((2*pi*D)/(365))*sin(2*pi/360*23.45));
ST=linspace(0,24,1000);
w=pi/12*(ST-12);

sin_alpha_s=(cos(sigma)*cos(fi).*cos(w)+sin(sigma).*sin(fi));
cos_gamma_s=((sin(sigma)-sin_alpha_s.*sin(fi))./(cos(asin(sin_alpha_s)).*cos(fi)));

figure
plot(ST,sin_alpha_s)

figure
plot(ST,cos_gamma_s)

plot3(sin(gamma_s).*cos(alpha_s),sin(gamma_s).*sin(alpha_s),cos(gamma_s))

x = cos(alpha_s).*sin(gamma_s);
y = cos(alpha_s).*cos(gamma_s);
z = sin(alpha_s);

figure
plot3(x, y, z)
axis equal
grid on