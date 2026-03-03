function [El,Az] = AnguloEspejo(rEsp,rObj,alpha_s,gamma_s)
arguments (Input)
    rEsp (1,3) double
    rObj (1,3) double
    alpha_s (1,1) double
    gamma_s (1,1) double
end

S_r=(rObj-rEsp)/norm(rObj-rEsp);

x=cosd(alpha_s) * sind(gamma_s);
y=cosd(alpha_s) * cosd(gamma_s);
z=sind(alpha_s);
S_i=[x,y,z];

S_n=(S_r+S_i)/norm(S_r+S_i); %Como los vectores de los rayos incidente y reflejado son unitarios, el vector bisectriz se calucla de esta manera.


Az=atan2d(S_n(1),S_n(2));
El=asind(S_n(3));
end