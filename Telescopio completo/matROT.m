function [R] = matROT(theta,u)
% theta - angulo a rotar
% u - vector unitario (ux,uy,uz) del eje alrededor del que se rota.
u = u / norm(u);
R=[cosd(theta)+u(1)^2*(1-cosd(theta)), u(1)*u(2)*(1-cosd(theta))-u(3)*sind(theta), u(1)*u(3)*(1-cosd(theta))+u(2)*sind(theta)
u(2)*u(1)*(1-cosd(theta))+u(3)*sind(theta), cosd(theta)+u(2)^2*(1-cosd(theta)), u(2)*u(3)*(1-cosd(theta))-u(1)*sind(theta)
u(3)*u(1)*(1-cosd(theta))-u(2)*sind(theta), u(3)*u(2)*(1-cosd(theta))+u(1)*sind(theta), cosd(theta)+u(3)^2*(1-cosd(theta))];
end