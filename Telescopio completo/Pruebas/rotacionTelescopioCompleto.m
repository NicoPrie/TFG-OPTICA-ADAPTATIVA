rESP0=readmatrix('coordenadasESP.txt');
v=readmatrix('verticesESPvertical.txt');

Alt=[zeros(1,45),linspace(0,90,45)];
%Alt=0*Alt;
Az=[linspace(0,270,60),270*ones(1,30)];
%Az=0*Az;

figure

for i=1:length(Alt)
    AltAz=[Alt(i),Az(i)];
    %AltAz=[Alt(i),0];
    %AltAz=[0,Az(i)];
    
    Rx=[1,0,0;0,cosd(AltAz(1)),-sind(AltAz(1));0,sind(AltAz(1)),cosd(AltAz(1))]; %Matriz de rotacion antihoraria alrededor de x
    Rz=[cosd(AltAz(2)),-sind(AltAz(2)),0;sind(AltAz(2)),cosd(AltAz(2)),0;0,0,1]; %Matriz de rotación antihoraria alrededor de z
    
    %Aplicamos las rotaciones en el origen. Transponemos Rz para hacer la rotación horaria.
    rESP=Rz'*Rx*rESP0';
    rESP=rESP';
    
    plot3(rESP(1,1),rESP(1,2),rESP(1,3),'b.')
    hold on
    %plot3(rESP(2:end,1),rESP(2:end,2),rESP(2:end,3),'r*')
    for j=2:length(rESP)
        vr=Rz'*Rx*v;
        patch(vr(1,:)+rESP(j,1),vr(2,:)+rESP(j,2),vr(3,:)+rESP(j,3),[0.8 0.8 0.9])
    end
    hold off
    axis equal
    
    xlim([-6,6])
    ylim([-6,6])
    zlim([-6,6])

    xlabel('x')
    ylabel('y')
    zlabel('z')

    pause(0.1)
end