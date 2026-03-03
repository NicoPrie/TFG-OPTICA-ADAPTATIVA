function [v] = VerticesEspejo(rEsp,AltAz)
%Vertices del rectángulo en el origen
a=0.2;
b=0.2;
v=[[-a;0;-b],[a;0;-b],[a;0;b],[-a;0;b]];

%Matrices de rotacion
Rx=[1,0,0;0,cosd(AltAz(1)),-sind(AltAz(1));0,sind(AltAz(1)),cosd(AltAz(1))]; %Matriz de rotacion antihoraria alrededor de x
Rz=[cosd(AltAz(2)),-sind(AltAz(2)),0;sind(AltAz(2)),cosd(AltAz(2)),0;0,0,1]; %Matriz de rotación antihoraria alrededor de z

%Aplicamos las rotaciones en el origen. Transponemos Rz para hacer la rotación horaria.
v=Rz'*Rx*v;

%Movemos el espejo a su sitio
v=v+rEsp';

end