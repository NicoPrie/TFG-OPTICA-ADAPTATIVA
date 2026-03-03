%LatLon=[0,0];
LatLon=[40.437271,-3.714715];
rEsp=[3,0,0];
rObj=[0,0,2];

t=datetime("now","TimeZone","UTC");
Year=year(t);
Day=day(t,"dayofyear"); %Calcular para hoy
%Day=day(datetime(2025,6,20),"dayofyear"); %Calcular para día concreto
n=400;
Horas=linspace(0,2*24,n);
data = zeros(n,4);

figure
for i=1:length(Horas)
    
    hold off
    plot3(rObj(1),rObj(2),rObj(3),'ob')
    hold on
    plot3([rObj(1),rObj(1)],[rObj(2),rObj(2)],[0,rObj(3)],'b')

    [AltAzEsp,AngSol]=AngFCordT(LatLon,rEsp,rObj,[Year,Day,Horas(i)]);

    if AngSol(1)<=0
        AltAzEsp(1)=90;
        AltAzEsp(2)=0;
    end

    data(i,1)=(Horas(i));
    data(i,2)=AltAzEsp(1);
    data(i,3)=AngSol(1);
    data(i,4)=AltAzEsp(2);

    
    
    %Plot Rayo incidente
    rI=[0,3.5];
    plot3(10*rI.*cosd(AngSol(1)).*sind(AngSol(2))+rEsp(1)*ones(1,length(rI)), 10*rI.*cosd(AngSol(1)).*cosd(AngSol(2))+rEsp(2)*ones(1,length(rI)), 10*rI.*sind(AngSol(1))+rEsp(3)*ones(1,length(rI)),'r')
    %plot3(10*rI.*cosd(AngSol(1)).*sind(AngSol(2))+rEsp(1)*ones(1,length(rI)), 10*rI.*cosd(AngSol(1)).*cosd(AngSol(2))+rEsp(2)*ones(1,length(rI)), [0,0],'r')
    
    %Plot dirección de la normal
    rN=[0,1.5];
    plot3(rN.*cosd(AltAzEsp(1)).*sind(AltAzEsp(2))+rEsp(1)*ones(1,length(rN)), rN.*cosd(AltAzEsp(1)).*cosd(AltAzEsp(2))+rEsp(2)*ones(1,length(rN)), rN.*sind(AltAzEsp(1))+rEsp(3)*ones(1,length(rN)),'b')
    %plot3(rN.*cosd(AltAzEsp(1)).*sind(AltAzEsp(2))+rEsp(1)*ones(1,length(rN)), rN.*cosd(AltAzEsp(1)).*cosd(AltAzEsp(2))+rEsp(2)*ones(1,length(rN)), [0,0],'b')
    
    %Plot Rayoreflejado 
    plot3([rEsp(1),rObj(1)],[rEsp(2),rObj(2)],[rEsp(3),rObj(3)],'k')
    %plot3([rEsp(1),rObj(1)],[rEsp(2),rObj(2)],[0,0],'k')
    
    constantplane([0,0,1],0)
    %sphere(FaceColor='white', FaceAlpha='0.5')
    
    v=VerticesEspejo(rEsp,AltAzEsp);
    patch([v(1,:)],[v(2,:)],[v(3,:)],[0.8 0.8 0.9])
    
    text(0,rI(end),0,'N')
    text(0,-rI(end),0,'S')
    text(rI(end),0,0,'E')
    text(-rI(end),0,0,'O')
    
    axis equal
    xlim([-rI(end),rI(end)])
    ylim([-rI(end),rI(end)])
    zlim([-rI(end),rI(end)])
    
    xlabel('x')
    ylabel('y')
    zlabel('z')
    
    grid on

    view(-35,30)
    pause(1/60)
end

figure
plot(data(:,1),data(:,2))
hold on
plot(data(:,1),data(:,3))
plot([data(1,1),data(end,1)],[0,0])
xlim([data(1,1),data(end,1)])

figure
plot(data(:,1),data(:,4))
hold on
plot(data(:,1),data(:,3))
plot([data(1,1),data(end,1)],[0,0])
xlim([data(1,1),data(end,1)])