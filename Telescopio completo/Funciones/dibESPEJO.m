function [] = dibESPEJO(tiempo, AltAzESP, AltAzESPobj, AltAzSEG, AltAzSEGobj, rESP0, v)

arguments (Input)
    tiempo
    AltAzESP
    AltAzESPobj
    AltAzSEG
    AltAzSEGobj
    rESP0=readmatrix("Telescopio completo\Datos\coordenadasESP.txt");
    v=readmatrix("Telescopio completo\Datos\verticesESPvertical.txt");
end

    function [vj] = rot(AngEspSeg, AltAzESP,rESP0, v)
        %Matrices de rotación para el segmento
        RxS=matROT(AngEspSeg(1), [1,0,0]);
        RzS=matROT(AngEspSeg(2), [0,0,-1]);

        %Matrices de rotación para el espejo
        RxE=matROT(AltAzESP(1), [1,0,0]);
        RzE=matROT(AltAzESP(2), [0,0,-1]);
        
        vj=RzS*RxS*v;
        vj=RzE*RxE*(vj+rESP0');
    end

figure; 
tiles=tiledlayout(2,3);

ThDtile=nexttile(tiles,[1,1]); %Tile en 3D con la animación del ESPEJO COMPLETO.
    plot3(0,0,0); hold on; axis equal
    xlim(ThDtile,[-1.5,1.5]); ylim(ThDtile,[-1.5,1.5]); zlim(ThDtile,[-1.5,1.5]);
    xlabel("x"); ylabel("y"); zlabel("z")
    
    for i=2:length(rESP0)
        vi=v+rESP0(i,:)';
        hSEG(i-1)=patch(ThDtile,vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9]); %Objeto que guarda los patchs de los segmentos
        clear vi
    end

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

PLACEHOLDER2=nexttile(tiles,[1,1]);

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

for i=1:length(tiempo)
    %Actualización de ThDtile
    for j=1:length(hSEG)
        vj=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);
        hSEG(j).XData=vj(1,:);
        hSEG(j).YData=vj(2,:);
        hSEG(j).ZData=vj(3,:);
    end

    hLINE(1).XData=[tiempo(i),tiempo(i)];
    hLINE(2).XData=[tiempo(i),tiempo(i)];
    hLINE(3).XData=[tiempo(i),tiempo(i)];
    hLINE(4).XData=[tiempo(i),tiempo(i)];

    pause(1/25)
end
end