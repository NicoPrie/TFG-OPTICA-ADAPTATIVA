function [] = dibESPEJO(tiempo, AltAzESP, AltAzESPobj, AltAzSEG, AltAzSEGobj, Pint, opciones)

arguments (Input)
    tiempo
    AltAzESP
    AltAzESPobj
    AltAzSEG
    AltAzSEGobj
    Pint
    opciones.rESP0=readmatrix("Telescopio completo\Datos\coordenadasESP.txt")
    opciones.v=readmatrix("Telescopio completo\Datos\verticesESPvertical.txt")
    opciones.fps=60
    opciones.vel=1
    opciones.trayectoria=false
end

rESP0=opciones.rESP0;
v=opciones.v;
fps=opciones.fps;
vel=opciones.vel;
tray=opciones.trayectoria;

    function [vj,R] = rot(AngEspSeg, AltAzESP,rESP0, v)
        %Matrices de rotación para el segmento
        RxS=matROT(AngEspSeg(1), [1,0,0]);
        RzS=matROT(AngEspSeg(2), [0,0,-1]);

        %Matrices de rotación para el espejo
        RxE=matROT(AltAzESP(1), [1,0,0]);
        RzE=matROT(AltAzESP(2), [0,0,-1]);
        
        vj=RzS*RxS*v;
        vj=RzE*RxE*(vj+rESP0');
        R=RzE*RxE;
    end
%Transformación de los datos a n fps
AltAzESP=interp1(tiempo,AltAzESP,0:1/fps:tiempo(end));
AltAzESPobj=interp1(tiempo,AltAzESPobj,0:1/fps:tiempo(end));
AltAzSEG=interp1(tiempo,AltAzSEG,0:1/fps:tiempo(end));
AltAzSEGobj=interp1(tiempo,AltAzSEGobj,0:1/fps:tiempo(end));
Pint=interp1(tiempo,Pint(),0:1/fps:tiempo(end));
tiempo=(0:1/fps:tiempo(end));


figure; 
tiles=tiledlayout(2,3);
sgtitle({'Main Title','Subtitle'})

ThDtile=nexttile(tiles,[1,1]); %Tile en 3D con la animación del ESPEJO COMPLETO.
    plot3(0,0,0); hold on; axis equal; grid on
    xlim(ThDtile,[-1.5,1.5]); ylim(ThDtile,[-1.5,1.5]); zlim(ThDtile,[-1.5,1.5]);
    xlabel("x"); ylabel("y"); zlabel("z")
    camproj("perspective")
    
    for i=2:length(rESP0)
        vi=v+rESP0(i,:)';
        hSEG(i-1)=patch(ThDtile,vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9]); %Objeto que guarda los patchs de los segmentos
        if tray
            hTRAY(i-1)=plot3([rESP0(i,1),squeeze(Pint(1,1,i-1))],[rESP0(i,2),squeeze(Pint(1,2,i-1))],[rESP0(i,3),squeeze(Pint(1,3,i-1))],'r:');
        end
        clear vi
    end
    view(-50,20)

ALTtileSEG=nexttile(tiles,[1,1]);
    hold on; title("Ángulo Altitud Segmentos");
    xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

    for i=1:size(AltAzSEG,3)
    h = plot(ALTtileSEG,tiempo,AltAzSEGobj(:,1,i),'--');
    plot(ALTtileSEG,tiempo, AltAzSEG(:,1,i),'Color', h.Color)
    end
    drawnow
    hLINE(1)=plot([tiempo(1),tiempo(1)],ylim,'--k');

ALTtileESP=nexttile(tiles,[1,1]);
    hold on; title("Ángulo Altitud Espejo");
    xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

    h = plot(ALTtileESP,tiempo,AltAzESPobj(:,1),'--');
    plot(ALTtileESP,tiempo, AltAzESP(:,1),'Color', h.Color)

    drawnow
    hLINE(2)=plot([tiempo(1),tiempo(1)],ylim,'--k');

intPLfocal=nexttile(tiles,[1,1]);
    hFOC=plot(intPLfocal,squeeze(Pint(1,1,:)),squeeze(Pint(1,3,:)),'.r');
    axis equal; grid on
    lim=.5;
    title("Intersecciones con el plano focal")
    xlim([-lim,lim]);ylim([-lim,lim])

AZtileSEG=nexttile(tiles,[1,1]);
    hold on; title("Ángulo Acimutal Segmentos")
    xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

    for i=1:size(AltAzSEG,3)
    h = plot(AZtileSEG,tiempo,AltAzSEGobj(:,2,i),'--');
    plot(AZtileSEG,tiempo, AltAzSEG(:,3,i),'Color', h.Color)
    end
    drawnow
    hLINE(3)=plot([tiempo(1),tiempo(1)],ylim,'--k');

AZtileESP=nexttile(tiles,[1,1]);
    hold on; title("Ángulo Altitud Espejo");
    xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

    h = plot(AZtileESP,tiempo,AltAzESPobj(:,2),'--');
    plot(AZtileESP,tiempo, AltAzESP(:,3),'Color', h.Color)

    drawnow
    hLINE(4)=plot([tiempo(1),tiempo(1)],ylim,'--k');

pause(1)

for i=1:vel:length(tiempo)
    %Actualización de ThDtile
    for j=1:length(hSEG)
        if tray
            [vj,R]=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);

            rESPi=R*rESP0';
            Pinti=R*squeeze(Pint(i,:,:));
            hTRAY(j).XData=[rESPi(1,j+1),Pinti(1,j)];
            hTRAY(j).YData=[rESPi(2,j+1),Pinti(2,j)];
            hTRAY(j).ZData=[rESPi(3,j+1),Pinti(3,j)];
        else
            [vj,~]=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);
        end
        hSEG(j).XData=vj(1,:);
        hSEG(j).YData=vj(2,:);
        hSEG(j).ZData=vj(3,:);
    end
    
    hFOC.XData=squeeze(Pint(i,1,:));
    hFOC.YData=squeeze(Pint(i,3,:));

    hLINE(1).XData=[tiempo(i),tiempo(i)];
    hLINE(2).XData=[tiempo(i),tiempo(i)];
    hLINE(3).XData=[tiempo(i),tiempo(i)];
    hLINE(4).XData=[tiempo(i),tiempo(i)];

    pause(1/fps)
end
end