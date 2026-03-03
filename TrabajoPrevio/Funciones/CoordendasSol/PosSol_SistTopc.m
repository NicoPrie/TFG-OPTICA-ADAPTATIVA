function [alpha_s, gamma_s] = PosSol_SistTopc(phi_0, lmbd_0, T_gmt, delta, E_min)
%PosSol_SistTopc calcula la posición del sol en coordenadas Topocéntricas
%del Observador dada una fecha
%Estas coordenadas están centradas en la posición del observador y dependen
%por lo tanto de la posición del observador y del tiempo.
%
%[phi_0,lmbd_0] -> Coordenadas del observador sobre la tierra [latitud,longitud]
%
%T_gmt -> Hora exácta en UTC. 
%T_gmt = hora_UTC+minutos_UTC/60+segundos_UTC/3600
%
%El resto de inputs salen de la función PosSol_EclGeo

phi_s=delta;
lmbd_s=-15*(T_gmt-12+E_min/60);

Sx=cosd(phi_s)*sind(lmbd_s-lmbd_0);
Sy=cosd(phi_0)*sind(phi_s)-sind(phi_0)*cosd(phi_s)*cosd(lmbd_s-lmbd_0);
Sz=sind(phi_0)*sind(phi_s)+cosd(phi_0)*cosd(phi_s)*cosd(lmbd_s-lmbd_0);

alpha_s=90-acosd(Sz); %Ángulo del horizonte al sol. Positivo durante el día y negativo durante la noche.
gamma_s = mod(atan2d(Sx, Sy), 360);  
end