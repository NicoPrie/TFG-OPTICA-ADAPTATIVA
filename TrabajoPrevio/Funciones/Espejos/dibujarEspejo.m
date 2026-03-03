function [] = dibujarEspejo(tiempo,AltAzEsp,AltAzObj)
figure
pause(1)
rEsp=[0,0,0];
tstep=tiempo(2)-tiempo(1);

for i=1:length(tiempo)
    clf
    tic

    %Dibujo
    tiledlayout(2,2)

    nexttile([2,1])
    hold on
    constantplane([0,0,1],0,"FaceAlpha",0.1)
    v=VerticesEspejo(rEsp,AltAzEsp(i,[1,3]));
    [cAlt,cAz]=CoordCirculosEsp(rEsp,AltAzEsp(i,[1,3]));

    patch([v(1,:)],[v(2,:)],[v(3,:)],[0.8 0.8 0.9])
    plot3(cAz(1,:),cAz(2,:),cAz(3,:),'k')
    plot3(cAz(1,1),cAz(2,1),cAz(3,1),'r.')
    plot3(cAlt(1,:),cAlt(2,:),cAlt(3,:),'k')
    plot3(cAlt(1,1),cAlt(2,1),cAlt(3,1),'r.')

    view(-37.5,20)
    axis equal
    title('Simulación del controlador PID')
    xlabel('x')
    ylabel('y')
    zlabel('z')
    xlim([-.5,.5])
    ylim([-.5,.5])
    zlim([-.5,.5])

    nexttile
    hold on
    plot(tiempo,AltAzEsp(:,[1,2]))
    plot(tiempo,AltAzObj(:,1))
    plot([tiempo(i),tiempo(i)],[(min(min(AltAzEsp(:,1)))+min(min(AltAzEsp(:,1)))*0.2),(max(max(AltAzEsp(:,1)))+max(max(AltAzEsp(:,1)))*0.2)],'k:')
    title('Ángulo altitud')
    xlabel('t(s)')
    ylabel('ángulo (º)')
    xlim([0,tiempo(end)])
    ylim([(min(min(AltAzEsp(:,1)))+min(min(AltAzEsp(:,1)))*0.2),(max(max(AltAzEsp(:,1)))+max(max(AltAzEsp(:,1)))*0.2)])
    legend('Posición','Velocidad','Posición Obj')    

    nexttile
    hold on
    plot(tiempo,AltAzEsp(:,[3,4]))
    plot(tiempo,AltAzObj(:,2))
    plot([tiempo(i),tiempo(i)],[(min(min(AltAzEsp(:,3)))+min(min(AltAzEsp(:,3)))*0.2),(max(max(AltAzEsp(:,3)))+max(max(AltAzEsp(:,3)))*0.2)],'k:')
    title('Ángulo acimutal')
    xlabel('t(s)')
    ylabel('ángulo (º)')
    xlim([0,tiempo(end)])
    ylim([(min(min(AltAzEsp(:,3)))+min(min(AltAzEsp(:,3)))*0.2),(max(max(AltAzEsp(:,3)))+max(max(AltAzEsp(:,3)))*0.2)])
    legend('Posición','Velocidad','Posición Obj')

    p=toc;
    disp(tstep-p)
    pause(tstep-p)
end