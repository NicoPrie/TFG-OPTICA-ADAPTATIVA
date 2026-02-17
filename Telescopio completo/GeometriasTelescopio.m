r=8.5;%Radio de los espejos (m): ref. Giant Magellan Telescope (GMT)
%f=131.4;%Distancia focal del espejo completo.
f=300; %(GMT) -> 18
t=@(capas) linspace(0,2*pi,capas*6+1);
t1=t(1); t1(end)=[]; %Primer círculo de espejos
t2=t(2); t2(end)=[];
t3=t(3); t3(end)=[];
t4=t(4); t4(end)=[];
rESP0=[zeros(length(t1),3)];

draw=true;
capas=4;

k=linspace(0,2*pi,50);
x=@(r,theta) r*cos(theta);
y=@(r,theta) r*sin(theta);
%v=[[x(r,0);y(r,0);0],[x(r,1);y(r,1);0],[x(r,2);y(r,2);0],[x(r,3);y(r,3);0],[x(r,4);y(r,4);0],[x(r,5);y(r,5);0]];
v=[x(r,k);0*k;y(r,k)];

if draw
    figure
    plot3(0,0,0)
    hold on

    axis equal
    xlim([-(capas+1)*2*r,(capas+1)*2*r])
    ylim([-(capas+1)*2*r,(capas+1)*2*r])
    zlim([-(capas+1)*2*r,(capas+1)*2*r])

    xlabel('x')
    ylabel('y')
    zlabel('z')
end

patch(v(1,:),v(2,:),v(3,:),[0.8 0.8 0.9])

for i=1:length(t1)
    ri=[2*r*sin(t1(i)),(r)^2/(f),2*r*cos(t1(i))];
    rESP0(i,:)=ri;
    vi=v+ri';
    if draw
        patch(vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9])
    end
end

if capas>=2
    for i=1:length(t2)
        ri=[2*2*r*sin(t2(i)),(r)^2/(f),2*2*r*cos(t2(i))];
        rESP0(length(t1)+i,:)=ri;
        vi=v+ri';
        if draw
            patch(vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9])
        end
    end
end

if capas>=3
    for i=1:length(t3)
        ri=[3*2*r*sin(t3(i)),(r)^2/(f),3*2*r*cos(t3(i))];
        rESP0(length(t1)+length(t2)+i,:)=ri;
        vi=v+ri';
        if draw
            patch(vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9])
        end
    end
end

if capas>=4
    for i=1:length(t4)
        ri=[4*2*r*sin(t4(i)),(r)^2/(f),4*2*r*cos(t4(i))];
        rESP0(length(t4)+length(t4)+length(t4)+i,:)=ri;
        vi=v+ri';
        if draw
            patch(vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9])
        end
    end
end

rESP0=[0,f,0;rESP0];

clearvars -except rESP0 v

writematrix(rESP0,'coordenadasESP') %[Coordenadas del foco; Coordenadas de los espejos]
writematrix(v,'verticesESPvertical') %Coordenadas de los vertices de un hexagono centrado en [0,0,0]