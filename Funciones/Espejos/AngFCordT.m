function [AngEsp,AngSol] =AngFCordT(LatLon,rEsp,rObj,time)
arguments (Input)
    LatLon (1,2) double %Latitud y longitud del espejo.
    rEsp (1,3) double %Coordenadas del espejo.
    rObj (1,3) double %Coordenadas del objetivo.
    time %[], 'now', o un vector [Year,Day,T_gmt]
end

%Procesar parametro time:
if nargin < 4 || isempty(time) || (isstring(time) && strcmpi(time,"now"))
    % Caso 1: Si tiempo vacío usar el momento actual UTC
    t = datetime("now","TimeZone","UTC");
    Year  = year(t);
    Day   = day(t,"dayofyear");
    T_gmt = hour(t) + minute(t)/60 + second(t)/3600;

elseif isnumeric(time) && numel(time)==3
    % Caso 2: tiempo = [Year, Day, T_gmt]
    Year  = time(1);
    Day   = time(2);
    T_gmt = time(3);

else
    error("El parámetro 'tiempo' debe ser [], 'now', o un vector [Year,Day,T_gmt].");
end

%Caclulo de los angulos:
[~, delta, ~, E_min] = PosSol_EclGeo(Year,Day,T_gmt);

[alpha_s, gamma_s] = PosSol_SistTopc(LatLon(1),LatLon(2),T_gmt,delta,E_min);
AngSol=[alpha_s,gamma_s];

[Az,El] = AnguloEspejo(rEsp,rObj,AngSol(1),AngSol(2));
AngEsp=[Az,El];
end