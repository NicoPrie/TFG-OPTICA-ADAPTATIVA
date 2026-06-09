 %LatLon=[0,0];
LatLon=[40.437271,-3.714715];
%LatLon = [85, -3.714715];
rObj=[0,0,3];
%todos_rEsp=[1,0,0;-1,0,0];

%Circulo de espejos en radio r.
r1=3;
n1=6;
z1=0.2;
k1=linspace(0,2*pi,n1+1);
k1(end)=[];
todos_rEsp=[r1*cos(k1'),r1*sin(k1'),z1*ones(length(k1),1)];

r2=5;
n2=6;
z2=0.2;
k2=linspace(0,2*pi,n2+1);
k2(end)=[];
todos_rEsp=[todos_rEsp;r2*cos(k2'),r2*sin(k2'),z2*ones(length(k2),1)];
clear k1 k2 n1 n2

n=30;
k1=linspace(0,2*pi,n);
C1=[r1*cos(k1'),r1*sin(k1'),zeros(length(k1),1)];
k2=linspace(0,2*pi,n);
C2=[r2*cos(k2'),r2*sin(k2'),zeros(length(k2),1)];
clear k1 k2 n

%Definimos el tiempo
t=datetime("now","TimeZone","UTC");
Year=year(t);
%Day=day(t,"dayofyear"); %Calcular para hoy
Day=day(datetime(2025,6,20),"dayofyear"); %Calcular para día concreto
ti=0;
tf=1*24;
fps=30;
velsim=10*3600;

n=fps*(tf-ti)*3600/velsim;
Horas=linspace(ti,tf,n);

tsim=zeros(1,length(Horas));
figure
for i=1:length(Horas)
    
    tic
    hold off
    plot3(rObj(1),rObj(2),rObj(3),'ob')
    hold on
    plot3([rObj(1),rObj(1)],[rObj(2),rObj(2)],[0,rObj(3)],'b')

    for j=1:size(todos_rEsp,1)
    rEsp=todos_rEsp(j,:);
    [AltAzEsp,AngSol]=AngFCordT(LatLon,rEsp,rObj,[Year,Day,Horas(i)]);

    if AngSol(1)<=0
        AltAzEsp(1)=90;
        AltAzEsp(2)=0;
    else
        %Plot Rayoreflejado 
        plot3([rEsp(1),rObj(1)],[rEsp(2),rObj(2)],[rEsp(3),rObj(3)],'Color', [1 0.5 0])
        %plot3([rEsp(1),rObj(1)],[rEsp(2),rObj(2)],[0,0],'k')
    end

    %Plot Rayo incidente
    rI=[0,r2+2];
    plot3(10*rI.*cosd(AngSol(1)).*sind(AngSol(2))+rEsp(1)*ones(1,length(rI)), 10*rI.*cosd(AngSol(1)).*cosd(AngSol(2))+rEsp(2)*ones(1,length(rI)), 10*rI.*sind(AngSol(1))+rEsp(3)*ones(1,length(rI)),'r')
    %plot3(10*rI.*cosd(AngSol(1)).*sind(AngSol(2))+rEsp(1)*ones(1,length(rI)), 10*rI.*cosd(AngSol(1)).*cosd(AngSol(2))+rEsp(2)*ones(1,length(rI)), [0,0],'r')
    
    %Plot dirección de la normal
    rN=[0,.3];
    plot3(rN.*cosd(AltAzEsp(1)).*sind(AltAzEsp(2))+rEsp(1)*ones(1,length(rN)), rN.*cosd(AltAzEsp(1)).*cosd(AltAzEsp(2))+rEsp(2)*ones(1,length(rN)), rN.*sind(AltAzEsp(1))+rEsp(3)*ones(1,length(rN)),'b')
    %plot3(rN.*cosd(AltAzEsp(1)).*sind(AltAzEsp(2))+rEsp(1)*ones(1,length(rN)), rN.*cosd(AltAzEsp(1)).*cosd(AltAzEsp(2))+rEsp(2)*ones(1,length(rN)), [0,0],'b')
    
    constantplane([0,0,1],0, "FaceAlpha",1-(AngSol(1)+90)/180,"FaceColor",[0.11, 0.15, 0.38])
    constantplane([0,0,1],-0.001, "FaceAlpha",1,"FaceColor",[0.50, 0.74, 0.36])
    %sphere(FaceColor='white', FaceAlpha='0.5')
    
    v=VerticesEspejo(rEsp,AltAzEsp);
    patch([v(1,:)],[v(2,:)],[v(3,:)],[0.8 0.8 0.9])
    end
    
    %Dibujar circunferencia de los espejos
    plot3(C1(:,1),C1(:,2),C1(:,3),':k')
    plot3(C2(:,1),C2(:,2),C2(:,3),':k')

    X = [todos_rEsp(:,1)'; todos_rEsp(:,1)'; NaN(1,size(todos_rEsp,1))];
    Y = [todos_rEsp(:,2)'; todos_rEsp(:,2)'; NaN(1,size(todos_rEsp,1))];
    Z = [zeros(1,size(todos_rEsp,1)); z1*ones(1,size(todos_rEsp,1)); NaN(1,size(todos_rEsp,1))];
    plot3(X(:),Y(:),Z(:),'k');

    text(0,rI(end),0,'N')
    text(0,-rI(end),0,'S')
    text(rI(end),0,0,'E')
    text(-rI(end),0,0,'O')
    
    axis equal
    xlim([-rI(end),rI(end)])
    ylim([-rI(end),rI(end)])
    zlim([-(rObj(end)+0.10*rObj(end)),rObj(end)+0.10*rObj(end)])
    
    xlabel('x')
    ylabel('y')
    zlabel('z')
    
    h = floor(Horas(i));
    m = round((Horas(i) - h)*60);
    title(sprintf("Hora: %02d:%02d", h, m));

    grid on

    view(-45,25)
    tsim(i)=toc;
    pause(1/fps)
end

figure
hold on
plot(Horas,tsim)
plot([Horas(1),Horas(end)],[1/fps,1/fps])