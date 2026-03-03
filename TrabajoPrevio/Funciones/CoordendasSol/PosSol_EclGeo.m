function [alpha, delta, R_TS, E_min] = PosSol_EclGeo(Year,Day,T_gmt)
%PosSol_EclGeo calcula la posición del sol en coordenadas eclípticas
%geocéntricas dada una fecha así como la distancia Sol-Tierra y la ecuación del tiempo.
%Estas coordenadas están centradas en la tierra pero no dependen de la posición local.
%
%Year -> Año
%
%Day -> Número de día en el año. El día actual:
%t=datetime("now","TimeZone","UTC") -> Day=day(t,"dayofyear")
%
%T_gmt -> Hora exacta en UTC. 
%T_gmt = hora_UTC+minutos_UTC/60+segundos_UTC/3600

%Número de años bisisestos desde J2000 y días desde J2000.
Nleap=sum( (mod(2000:(Year-1),4)==0 & mod(2000:(Year-1),100)~=0) | mod(2000:(Year-1),400)==0 );
n=-1.5+(Year-2000)*365+Nleap+Day+(T_gmt)/24;

%Parámetros orbitales (Sol geocentrista).
L=mod(280.466+0.9856474*n,360); %Grados
g=mod(357.528+0.9856003*n,360); %Grados
lmbd=mod(L+1.915*sind(g)+0.020*sind(2*g),360); %Grados
eps=23.440-0.0000004*n; %Grados

%Coordenadas eclípticas geocéntricas.
alpha=mod(atan2d(cosd(eps)*sind(lmbd),cosd(lmbd)),360);
delta=asind(sind(eps)*sind(lmbd));

R_TS=1.00014-0.01671*cosd(g)-0.00014*cosd(2*g); %au
E_min=(L-alpha)*4; %min
end