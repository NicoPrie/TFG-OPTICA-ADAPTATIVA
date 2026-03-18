function [Pint] = CoordReflPlanoFocal(rESP, alt_i, az_i, alt_m, az_m)

rFOCO=rESP(1,:);
rSEG=rESP(2:end,:);

%Calculo del rayo reflejado:
    d = [cosd(alt_i).*sind(az_i), cosd(alt_i).*cosd(az_i), sind(alt_i)];
    
    n = [cosd(alt_m).*sind(az_m), cosd(alt_m).*cosd(az_m), sind(alt_m)];
    
    dot_dn = sum(d.*n, 2);
    r = d - 2*dot_dn.*n;  %Vector unitario de cada rayo reflejado.

%Cálculo de la intersección en el plano focal
    num = sum((rFOCO - rSEG).*rFOCO/norm(rFOCO),2);
    den = sum(r.*rFOCO/norm(rFOCO),2);
    
    t = num ./ den;
    
    Pint = rSEG + t.*r;
end