tic
phi_0=40.437271;
lmbd_0=-3.714715;
LatLon=[phi_0,lmbd_0];
rEsp=[3,0,0];
rObj=[0,0,2];

[AltAzEsp,AngSol]=AngFCordT(LatLon,rEsp,rObj,[]);
toc

figure
plot3(rEsp(1),rEsp(2),rEsp(3),'r*')
hold on
plot3(rObj(1),rObj(2),rObj(3),'ob')
plot3([rObj(1),rObj(1)],[rObj(2),rObj(2)],[0,rObj(3)],'b')
rC=[0,5];
plot3(rC.*cosd(AngSol(1)).*sind(AngSol(2))+rEsp(1)*ones(1,length(rC)), rC.*cosd(AngSol(1)).*cosd(AngSol(2))+rEsp(2)*ones(1,length(rC)), rC.*sind(AngSol(1))+rEsp(3)*ones(1,length(rC)),'k')
rn=[0,.5];
plot3(rn.*cosd(AltAzEsp(1)).*sind(AltAzEsp(2))+rEsp(1)*ones(1,length(rn)), rn.*cosd(AltAzEsp(1)).*cosd(AltAzEsp(2))+rEsp(2)*ones(1,length(rn)), rn.*sind(AltAzEsp(1))+rEsp(3)*ones(1,length(rn)),'k')
plot3([rEsp(1),rObj(1)],[rEsp(2),rObj(2)],[rEsp(3),rObj(3)],'k')
constantplane([0,0,1],0)
%sphere(FaceColor='white', FaceAlpha='0.5')
v=VerticesEspejo(rEsp,AltAzEsp);
patch([v(1,:)],[v(2,:)],[v(3,:)],[0.8 0.8 0.9])

v=VerticesEspejo(rEsp,AltAzEsp);
patch([v(1,:)],[v(2,:)],[v(3,:)],[0.8 0.8 0.9])

text(0,rC(end),0,'N')
text(0,-rC(end),0,'S')
text(rC(end),0,0,'E')
text(-rC(end),0,0,'O')

axis equal
xlim([-1,rC(end)])
ylim([-1,1])
zlim([-1,3])

xlabel('x')
ylabel('y')
zlabel('z')

grid on