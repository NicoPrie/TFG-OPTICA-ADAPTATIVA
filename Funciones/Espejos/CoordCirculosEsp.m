function [cAlt,cAz] = CoordCirculosEsp(rEsp,AltAz)
%Puntos del circuo centrado en el origen.
r=0.3;
t=linspace(0,2*pi,50);
cAlt=[0*t;r*cos(t);r*sin(t)];
cAz=[r*sin(t);r*cos(t);0*t];

%Matrices de rotacion
Rx=[1,0,0;0,cosd(AltAz(1)),-sind(AltAz(1));0,sind(AltAz(1)),cosd(AltAz(1))]; %Matriz de rotacion antihoraria alrededor de x
Rz=[cosd(AltAz(2)),-sind(AltAz(2)),0;sind(AltAz(2)),cosd(AltAz(2)),0;0,0,1]; %Matriz de rotación antihoraria alrededor de z

%Aplicamos las rotaciones en el origen. Transponemos Rz para hacer la rotación horaria.
cAlt=Rz'*Rx*cAlt;
cAz=Rz'*cAz;

%Movemos los circulos con el espejo
cAlt=cAlt+rEsp';
cAz=cAz+rEsp';

end