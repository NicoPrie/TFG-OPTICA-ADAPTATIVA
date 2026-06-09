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
    opciones.longlat=[-3.714715,40.437271];
    opciones.fps=60
    opciones.vel=1
    opciones.trayectoria=false
    opciones.record=false
    opciones.view=1 %Elige que representación mostrar.
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

%close all

%Transformación de los datos a n fps
AltAzESP=interp1(tiempo,AltAzESP,0:1/fps:tiempo(end));
AltAzESPobj=interp1(tiempo,AltAzESPobj,0:1/fps:tiempo(end));
AltAzSEG=interp1(tiempo,AltAzSEG,0:1/fps:tiempo(end));
AltAzSEGobj=interp1(tiempo,AltAzSEGobj,0:1/fps:tiempo(end));
Pint=interp1(tiempo,Pint(),0:1/fps:tiempo(end));
tiempo=(0:1/fps:tiempo(end));

if opciones.view == 1

    if opciones.record
        nombreArchivo = strcat('VideosGuardados/',string(datetime('now','Format','d_MMMM_y_HH''h''mm''m''','TimeZone','local')),'_',string(fps),'fps','.mp4');
        videoObj = VideoWriter(nombreArchivo, 'MPEG-4'); % Formato MP4
        videoObj.FrameRate = fps; % Fotogramas por segundo
        open(videoObj);

        hMAIN=figure('Visible','off');
    else
        hMAIN=figure;
    end

    tiles=tiledlayout(2,3);
    sgtitle({'Espejo segmentado','Simulación de seguimiento del sol.'})
    timeSeparation=15;

    ThDtile=nexttile(tiles,[1,1]); %Tile en 3D con la animación del ESPEJO COMPLETO.
        plot3(0,0,0); hold on; axis equal; axis on; grid on
        l=2;
        xlim(ThDtile,[-l,l]); ylim(ThDtile,[-l,l]); zlim(ThDtile,[-l,l]);
        xlabel("x"); ylabel("y"); zlabel("z")
        camproj("perspective")

        %Circulillos y puntos cardinales
        fontsz=6;
        txtrad=2.560/2*1.4;
        text(txtrad*sin(0),txtrad*cos(0),0,'0º (N)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','none')
        text(txtrad*sin(pi/2),txtrad*cos(pi/2),0,'90º (E)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','none')
        text(txtrad*sin(pi),txtrad*cos(pi),0,'180º (S)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','none')
        text(txtrad*sin(3*pi/2),txtrad*cos(3*pi/2),0,'270º (O)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','none')

        [cAlt_init, cAz_init] = CoordCirculosEsp_v2(0, AltAzESP(1,[1,3]));
        [cAlt_obj, cAz_obj] = CoordCirculosEsp_v2(0, AltAzESPobj(1,[1,2]));

        hAltCirc = plot3(ThDtile, cAlt_init(1,:), cAlt_init(2,:), cAlt_init(3,:), '--', 'LineWidth',0.3,'Color',[0,0,0,0.5]); %In circulo altitud
        hAltpos  = plot3(ThDtile, cAlt_init(1,1), cAlt_init(2,1), cAlt_init(3,1), 'r.'); %In punto posicion altitud
        hAzCirc = plot3(ThDtile, cAz_init(1,:), cAz_init(2,:), cAz_init(3,:), '--', 'LineWidth',0.3,'Color',[0,0,0,0.5]); %In circulo acimutal
        hAzPos  = plot3(ThDtile, cAz_init(1,1), cAz_init(2,1), cAz_init(3,1), 'r.'); %In punto posicion acimutal
        hAltobjPos = plot3(ThDtile, cAlt_obj(1,1), cAlt_obj(2,1), cAlt_obj(3,1), 'kp');
        hAzobjPos = plot3(ThDtile, cAz_obj(1,1), cAz_obj(2,1), cAz_obj(3,1), 'k.');

        for i=2:length(rESP0)
            vi=v+rESP0(i,:)';
            hSEG(i-1)=patch(ThDtile,vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9]); %Objeto que guarda los patchs de los segmentos
            if tray
                hTRAY(i-1)=plot3([rESP0(i,1),squeeze(Pint(1,1,i-1))],[rESP0(i,2),squeeze(Pint(1,2,i-1))],[rESP0(i,3),squeeze(Pint(1,3,i-1))],':','Color',[1,0,0,0.75]);
            end
            clear vi
        end
        %view(-15,10)
        view(AltAzESP(end,3)+45,10)
        zoom(1)

    ALTtileSEG=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Altitud Segmentos");
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        for i=1:size(AltAzSEG,3)
            h = plot(ALTtileSEG,tiempo,AltAzSEGobj(:,1,i),'--');
            plot(ALTtileSEG,tiempo(1:1:end), AltAzSEG(1:1:end,1,i), '-', 'Color', h.Color)
        end
        drawnow
        hLINE(1)=plot([tiempo(1),tiempo(1)],ylim,'--k');
        xlim(ALTtileSEG, [0, timeSeparation])

    ALTtileESP=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Altitud Espejo");
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        h = plot(ALTtileESP,tiempo,AltAzESPobj(:,1),'--');
        %plot(ALTtileESP,tiempo, AltAzESP(:,1),'Color', h.Color, 'Marker','*')
        plot(ALTtileESP,tiempo(1:1:end), AltAzESP(1:1:end,1),'-')
        drawnow
        hLINE(2)=plot([tiempo(1),tiempo(1)],ylim,'--k');
        xlim(ALTtileESP, [0, timeSeparation])

    intPLfocal=nexttile(tiles,[1,1]);
        convint=1e6;
        hFOC=plot(intPLfocal,squeeze(Pint(1,1,:))*convint,squeeze(Pint(1,3,:))*convint,'.r');
        xlabel("X ($\mu m$)","Interpreter","latex"); ylabel("Y ($\mu m$)","Interpreter","latex");
        axis equal; grid on
        %lim=.0015;
        %lim=0.005;
        %lim=0.01;
        lim=10;
        title({"Intersecciones con el plano focal",""})
        xlim([-lim,lim]);ylim([-lim,lim])

    AZtileSEG=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Acimutal Segmentos")
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        for i=1:size(AltAzSEG,3)
            h = plot(AZtileSEG,tiempo,AltAzSEGobj(:,2,i),'--');
            plot(AZtileSEG,tiempo(1:1:end), AltAzSEG(1:1:end,3,i), '-', 'Color', h.Color)
        end
        drawnow
        hLINE(3)=plot([tiempo(1),tiempo(1)], ylim,'--k');
        xlim(AZtileSEG, [0, timeSeparation])

    AZtileESP=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Acimutal Espejo");
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        h = plot(AZtileESP,tiempo,AltAzESPobj(:,2),'--');
        plot(AZtileESP,tiempo(1:1:end), AltAzESP(1:1:end,3),'-', 'Color', h.Color)

        drawnow
        hLINE(4)=plot([tiempo(1),tiempo(1)],ylim,'--k');
        xlim(AZtileESP, [0, timeSeparation])

    pause(1)

    tStart = tic;
    tLastUpdate = tic;
    totalFrames = length(1:vel:length(tiempo));
    frameCount = 0;

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

        %Circulos y puntos
        [cAlt, cAz] = CoordCirculosEsp_v2(0, AltAzESP(i,[1,3]));
        hAzCirc.XData = cAz(1,:); hAzCirc.YData = cAz(2,:); hAzCirc.ZData = cAz(3,:);
        hAzPos.XData = cAz(1,1);  hAzPos.YData = cAz(2,1);  hAzPos.ZData = cAz(3,1);
        hAltCirc.XData = cAlt(1,:); hAltCirc.YData = cAlt(2,:); hAltCirc.ZData = cAlt(3,:);
        hAltpos.XData = cAlt(1,1);  hAltpos.YData = cAlt(2,1);  hAltpos.ZData = cAlt(3,1);

        hFOC.XData=squeeze(Pint(i,1,:))*convint;
        hFOC.YData=squeeze(Pint(i,3,:))*convint;

        if tiempo(i)>timeSeparation
            xlim(ALTtileSEG, [0, tiempo(end)])
            xlim(AZtileSEG, [0, tiempo(end)])
            xlim(ALTtileESP, [0, tiempo(end)])
            xlim(AZtileESP, [0, tiempo(end)])
        end
        hLINE(1).XData=[tiempo(i),tiempo(i)];
        hLINE(2).XData=[tiempo(i),tiempo(i)];
        hLINE(3).XData=[tiempo(i),tiempo(i)];
        hLINE(4).XData=[tiempo(i),tiempo(i)];

        if opciones.record
            frame=getframe(hMAIN);
            writeVideo(videoObj, frame);

            frameCount = frameCount + 1;

            if toc(tLastUpdate) >= 120
                elapsed = toc(tStart);
                framesLeft = totalFrames - frameCount;
                secPerFrame = elapsed / frameCount;
                etaSec = framesLeft * secPerFrame;

                fprintf('Progreso: %d/%d frames (%.1f%%) — Tiempo restante estimado: %s\n', ...
                    frameCount, totalFrames, ...
                    100*frameCount/totalFrames, ...
                    duration(0,0,round(etaSec),'Format','hh:mm:ss'));

                tLastUpdate = tic;
            end
        else
            pause(1/fps)
        end
    end

    if opciones.record
    close(videoObj);
    disp("Video guardado")
    end

elseif opciones.view == 2
    FIG1 = figure('WindowStyle','normal','WindowState','maximized');
    pause(.2)
    FIG2 = figure('WindowStyle','normal', 'Units',  'normalized', 'Position', [0.5-0.1, 0.62, 0.2, 0.3]);
    tiles1=tiledlayout(FIG1,1,2);
    tiles2=tiledlayout(FIG2,1,1);

    %Para FIG1. Muestra el modelo de los espejos y su posición sobre la
    %tierra.
    modelo=nexttile(tiles1);
        plot3(0,0,0); hold on; axis equal; axis on; grid on
        l=5.3;
        xlim(modelo,[-l,l]); ylim(modelo,[-l,l]); zlim(modelo,[-l,l]);
        xlabel("x"); ylabel("y"); zlabel("z")
        camproj("perspective")

        for i=2:length(rESP0)
            vi=v+rESP0(i,:)';
            hSEG(i-1)=patch(modelo,vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9]); %Objeto que guarda los patchs de los segmentos
            if tray
                hTRAY(i-1)=plot3([rESP0(i,1),squeeze(Pint(1,1,i-1))],[rESP0(i,2),squeeze(Pint(1,2,i-1))],[rESP0(i,3),squeeze(Pint(1,3,i-1))],'r:');
            end
            clear vi
        end
        view(-15,10)

    intPLfocal=nexttile(tiles1);
        hFOC=plot(intPLfocal,squeeze(Pint(1,1,:)),squeeze(Pint(1,3,:)),'.r');
        axis equal; grid on; xlabel("X (m)"); ylabel("Y (m)");
        lim=.025;
        title("Intersecciones con el plano focal")
        xlim([-lim,lim]);ylim([-lim,lim])

    tierra=nexttile(tiles2);
        longlat=opciones.longlat;
        [hLight1, hLight2, hLight3] = drawEarth(longlat, tierra);

    pause(3)

        for i=1:vel:length(tiempo)
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


            %Actualización de la iluminación del planeta
            Year=2026;
            Day=93;
            T_gmt=7+tiempo(i)/(60*60);
            [~, delta, ~, E_min] = PosSol_EclGeo(Year,Day,T_gmt);
            phi_s=delta;
            lmbd_s=-15*(T_gmt-12+E_min/60);

            [xl,yl,zl] = sph2cart((lmbd_s)*pi/180,phi_s*pi/180,1);
            hLight1.Position = [xl, yl, zl];
            hLight2.Position = [xl, yl, zl];
            hLight3.Position = [xl, yl, zl];

            if opciones.record
                frame=getframe(hMAIN);
                writeVideo(videoObj, frame);
            else
                pause(1/fps)
            end
        end
elseif opciones.view == 3

    tiles=tiledlayout(2,2);
    sgtitle({'Espejo segmentado','Simulación de seguimiento del sol.'})

    ALTtileSEG=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Altitud Segmentos");
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        for i=1:size(AltAzSEG,3)
            h = plot(ALTtileSEG,tiempo,AltAzSEGobj(:,1,i),'--');
            plot(ALTtileSEG,tiempo(1:fps:end), AltAzSEG(1:fps:end,1,i), '-', 'Color', h.Color)
        end
        drawnow
        %hLINE(1)=plot([tiempo(1),tiempo(1)],ylim,'--k');

    ALTtileESP=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Altitud Espejo");
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        h = plot(ALTtileESP,tiempo,AltAzESPobj(:,1),'--');
        %plot(ALTtileESP,tiempo, AltAzESP(:,1),'Color', h.Color, 'Marker','*')
        plot(ALTtileESP,tiempo(1:fps:end), AltAzESP(1:fps:end,1),'-')
        drawnow
        %hLINE(2)=plot([tiempo(1),tiempo(1)],ylim,'--k');

    AZtileSEG=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Acimutal Segmentos")
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        for i=1:size(AltAzSEG,3)
            h = plot(AZtileSEG,tiempo,AltAzSEGobj(:,2,i),'--');
            plot(AZtileSEG,tiempo(1:fps:end), AltAzSEG(1:fps:end,3,i), '-', 'Color', h.Color)
        end
        drawnow
        %hLINE(3)=plot([tiempo(1),tiempo(1)], ylim,'--k');

    AZtileESP=nexttile(tiles,[1,1]);
        hold on; title("Ángulo Acimutal Espejo");
        xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])

        h = plot(AZtileESP,tiempo,AltAzESPobj(:,2),'--');
        plot(AZtileESP,tiempo(1:fps:end), AltAzESP(1:fps:end,3),'-', 'Color', h.Color)

        drawnow
        %hLINE(4)=plot([tiempo(1),tiempo(1)],ylim,'--k');
      
end

end

% function [] = dibESPEJO(tiempo, AltAzESP, AltAzESPobj, AltAzSEG, AltAzSEGobj, Pint, opciones)
% 
% arguments (Input)
%     tiempo
%     AltAzESP
%     AltAzESPobj
%     AltAzSEG
%     AltAzSEGobj
%     Pint
%     opciones.rESP0=readmatrix("Telescopio completo\Datos\coordenadasESP.txt")
%     opciones.v=readmatrix("Telescopio completo\Datos\verticesESPvertical.txt")
%     opciones.longlat=[-3.714715,40.437271];
%     opciones.fps=60
%     opciones.vel=1
%     opciones.trayectoria=false
%     opciones.record=false
%     opciones.view=1
%     opciones.colorerror=false
%     opciones.error_max=2
% end
% 
% rESP0=opciones.rESP0;
% v=opciones.v;
% fps=opciones.fps;
% vel=opciones.vel;
% tray=opciones.trayectoria;
% 
%     function [vj,R] = rot(AngEspSeg, AltAzESP,rESP0, v)
%         RxS=matROT(AngEspSeg(1), [1,0,0]);
%         RzS=matROT(AngEspSeg(2), [0,0,-1]);
%         RxE=matROT(AltAzESP(1), [1,0,0]);
%         RzE=matROT(AltAzESP(2), [0,0,-1]);
%         vj=RzS*RxS*v;
%         vj=RzE*RxE*(vj+rESP0');
%         R=RzE*RxE;
%     end
% 
% AltAzESP=interp1(tiempo,AltAzESP,0:1/fps:tiempo(end));
% AltAzESPobj=interp1(tiempo,AltAzESPobj,0:1/fps:tiempo(end));
% AltAzSEG=interp1(tiempo,AltAzSEG,0:1/fps:tiempo(end));
% AltAzSEGobj=interp1(tiempo,AltAzSEGobj,0:1/fps:tiempo(end));
% Pint=interp1(tiempo,Pint(),0:1/fps:tiempo(end));
% tiempo=(0:1/fps:tiempo(end));
% 
% if opciones.view == 1
% 
%     if opciones.record
%         nombreArchivo = 'mi_animacion_1.mp4';
%         videoObj = VideoWriter(nombreArchivo, 'MPEG-4');
%         videoObj.FrameRate = fps;
%         open(videoObj);
%         hMAIN=figure('Visible','off');
%     else
%         hMAIN=figure;
%     end
% 
%     tiles=tiledlayout(2,3);
%     sgtitle({'Espejo segmentado','Simulación de seguimiento del sol.'})
% 
%     ThDtile=nexttile(tiles,[1,1]);
%         plot3(0,0,0); hold on; axis equal; axis on; grid on
%         l=1.5;
%         xlim(ThDtile,[-l,l]); ylim(ThDtile,[-l,l]); zlim(ThDtile,[-l,l]);
%         xlabel("x"); ylabel("y"); zlabel("z")
%         camproj("perspective")
% 
%         for i=2:length(rESP0)
%             vi=v+rESP0(i,:)';
%             hSEG(i-1)=patch(ThDtile,vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9]);
%             if tray
%                 hTRAY(i-1)=plot3([rESP0(i,1),squeeze(Pint(1,1,i-1))],[rESP0(i,2),squeeze(Pint(1,2,i-1))],[rESP0(i,3),squeeze(Pint(1,3,i-1))],'r:');
%             end
%             clear vi
%         end
%         view(-15,10)
% 
%         if opciones.colorerror
%             cmap = parula(256);
%             colormap(ThDtile, cmap);
%             cb = colorbar(ThDtile);
%             cb.Label.String = 'Error (°)';
%             clim(ThDtile, [0, opciones.error_max]);
%         end
% 
%     ALTtileSEG=nexttile(tiles,[1,1]);
%         hold on; title("Ángulo Altitud Segmentos");
%         xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])
%         for i=1:size(AltAzSEG,3)
%             h = plot(ALTtileSEG,tiempo,AltAzSEGobj(:,1,i),'--');
%             plot(ALTtileSEG,tiempo(1:fps:end), AltAzSEG(1:fps:end,1,i), '-', 'Color', h.Color)
%         end
%         drawnow
%         hLINE(1)=plot([tiempo(1),tiempo(1)],ylim,'--k');
% 
%     ALTtileESP=nexttile(tiles,[1,1]);
%         hold on; title("Ángulo Altitud Espejo");
%         xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])
%         h = plot(ALTtileESP,tiempo,AltAzESPobj(:,1),'--');
%         plot(ALTtileESP,tiempo(1:fps:end), AltAzESP(1:fps:end,1),'-')
%         drawnow
%         hLINE(2)=plot([tiempo(1),tiempo(1)],ylim,'--k');
% 
%     intPLfocal=nexttile(tiles,[1,1]);
%         hFOC=plot(intPLfocal,squeeze(Pint(1,1,:))*1000,squeeze(Pint(1,3,:))*1000,'.r');
%         xlabel("X (mm)"); ylabel("Y (mm)");
%         axis equal; grid on
%         lim=2.5;
%         title({"Intersecciones con el plano focal",""})
%         xlim([-lim,lim]);ylim([-lim,lim])
% 
%     AZtileSEG=nexttile(tiles,[1,1]);
%         hold on; title("Ángulo Acimutal Segmentos")
%         xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])
%         for i=1:size(AltAzSEG,3)
%             h = plot(AZtileSEG,tiempo,AltAzSEGobj(:,2,i),'--');
%             plot(AZtileSEG,tiempo(1:fps:end), AltAzSEG(1:fps:end,3,i), '-', 'Color', h.Color)
%         end
%         drawnow
%         hLINE(3)=plot([tiempo(1),tiempo(1)], ylim,'--k');
% 
%     AZtileESP=nexttile(tiles,[1,1]);
%         hold on; title("Ángulo Acimutal Espejo");
%         xlabel("tiempo (s)"); ylabel("Ángulo (º)"); xlim([tiempo(1),tiempo(end)])
%         h = plot(AZtileESP,tiempo,AltAzESPobj(:,2),'--');
%         plot(AZtileESP,tiempo(1:fps:end), AltAzESP(1:fps:end,3),'-', 'Color', h.Color)
%         drawnow
%         hLINE(4)=plot([tiempo(1),tiempo(1)],ylim,'--k');
% 
%     if opciones.colorerror
%         cmap = parula(256);
%     end
% 
%     pause(1)
% 
%     for i=1:vel:length(tiempo)
%         for j=1:length(hSEG)
%             if tray
%                 [vj,R]=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);
%                 rESPi=R*rESP0';
%                 Pinti=R*squeeze(Pint(i,:,:));
%                 hTRAY(j).XData=[rESPi(1,j+1),Pinti(1,j)];
%                 hTRAY(j).YData=[rESPi(2,j+1),Pinti(2,j)];
%                 hTRAY(j).ZData=[rESPi(3,j+1),Pinti(3,j)];
%             else
%                 [vj,~]=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);
%             end
%             hSEG(j).XData=vj(1,:);
%             hSEG(j).YData=vj(2,:);
%             hSEG(j).ZData=vj(3,:);
% 
%             if opciones.colorerror
%                 error_j = abs(AltAzSEG(i,1,j) - AltAzSEGobj(i,1,j)) + ...
%            abs(AltAzSEG(i,3,j) - AltAzSEGobj(i,2,j));
%                 idx = max(1, min(256, round(error_j/opciones.error_max * 255) + 1));
%                 hSEG(j).FaceColor = cmap(idx,:);
%             end
%         end
% 
%         hFOC.XData=squeeze(Pint(i,1,:))*1000;
%         hFOC.YData=squeeze(Pint(i,3,:))*1000;
% 
%         hLINE(1).XData=[tiempo(i),tiempo(i)];
%         hLINE(2).XData=[tiempo(i),tiempo(i)];
%         hLINE(3).XData=[tiempo(i),tiempo(i)];
%         hLINE(4).XData=[tiempo(i),tiempo(i)];
% 
%         if opciones.record
%             frame=getframe(hMAIN);
%             writeVideo(videoObj, frame);
%         else
%             pause(1/fps)
%         end
%     end
% 
%     if opciones.record
%         close(videoObj);
%         disp("Video guardado")
%     end
% 
% elseif opciones.view == 2
%     FIG1 = figure('WindowStyle','normal','WindowState','maximized');
%     pause(.2)
%     FIG2 = figure('WindowStyle','normal', 'Units', 'normalized', 'Position', [0.5-0.1, 0.62, 0.2, 0.3]);
%     tiles1=tiledlayout(FIG1,1,2);
%     tiles2=tiledlayout(FIG2,1,1);
% 
%     modelo=nexttile(tiles1);
%         plot3(0,0,0); hold on; axis equal; axis on; grid on
%         l=5.3;
%         xlim(modelo,[-l,l]); ylim(modelo,[-l,l]); zlim(modelo,[-l,l]);
%         xlabel("x"); ylabel("y"); zlabel("z")
%         camproj("perspective")
% 
%         for i=2:length(rESP0)
%             vi=v+rESP0(i,:)';
%             hSEG(i-1)=patch(modelo,vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9]);
%             if tray
%                 hTRAY(i-1)=plot3([rESP0(i,1),squeeze(Pint(1,1,i-1))],[rESP0(i,2),squeeze(Pint(1,2,i-1))],[rESP0(i,3),squeeze(Pint(1,3,i-1))],'r:');
%             end
%             clear vi
%         end
%         view(-15,10)
% 
%     intPLfocal=nexttile(tiles1);
%         hFOC=plot(intPLfocal,squeeze(Pint(1,1,:)),squeeze(Pint(1,3,:)),'.r');
%         axis equal; grid on; xlabel("X (m)"); ylabel("Y (m)");
%         lim=.025;
%         title("Intersecciones con el plano focal")
%         xlim([-lim,lim]);ylim([-lim,lim])
% 
%     tierra=nexttile(tiles2);
%         longlat=opciones.longlat;
%         [hLight1, hLight2, hLight3] = drawEarth(longlat, tierra);
% 
%     pause(3)
% 
%     for i=1:vel:length(tiempo)
%         for j=1:length(hSEG)
%             if tray
%                 [vj,R]=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);
%                 rESPi=R*rESP0';
%                 Pinti=R*squeeze(Pint(i,:,:));
%                 hTRAY(j).XData=[rESPi(1,j+1),Pinti(1,j)];
%                 hTRAY(j).YData=[rESPi(2,j+1),Pinti(2,j)];
%                 hTRAY(j).ZData=[rESPi(3,j+1),Pinti(3,j)];
%             else
%                 [vj,~]=rot(AltAzSEG(i,[1,3],j), AltAzESP(i,[1,3]),rESP0(j+1,:) ,v);
%             end
%             hSEG(j).XData=vj(1,:);
%             hSEG(j).YData=vj(2,:);
%             hSEG(j).ZData=vj(3,:);
%         end
% 
%         hFOC.XData=squeeze(Pint(i,1,:));
%         hFOC.YData=squeeze(Pint(i,3,:));
% 
%         Year=2026;
%         Day=93;
%         T_gmt=7+tiempo(i)/(60*60);
%         [~, delta, ~, E_min] = PosSol_EclGeo(Year,Day,T_gmt);
%         phi_s=delta;
%         lmbd_s=-15*(T_gmt-12+E_min/60);
% 
%         [xl,yl,zl] = sph2cart((lmbd_s)*pi/180,phi_s*pi/180,1);
%         hLight1.Position = [xl, yl, zl];
%         hLight2.Position = [xl, yl, zl];
%         hLight3.Position = [xl, yl, zl];
% 
%         if opciones.record
%             frame=getframe(hMAIN);
%             writeVideo(videoObj, frame);
%         else
%             pause(1/fps)
%         end
%     end
% end
% 
% end