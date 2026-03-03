function [] = dibujarEspejo_v2(tiempo,AltAzEsp,AltAzObj)
    fig = figure;
    tstep = tiempo(2) - tiempo(1);
    rEsp = [0,0,0];

    %Pre dibujo
    tlo = tiledlayout(2,2);
    
    % Tile principal 3D
    ESPtile = nexttile(tlo, [2,1]);
    hold(ESPtile, 'on');
    constantplane([0,0,1], 0,"FaceAlpha",0.1);
    fontsz=6;
    txtrad=0.33;
    text(txtrad*sin(0),txtrad*cos(0),0,'0º (N)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','white')
    text(txtrad*sin(pi/2),txtrad*cos(pi/2),0,'90º (E)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','white')
    text(txtrad*sin(pi),txtrad*cos(pi),0,'180º (S)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','white')
    text(txtrad*sin(3*pi/2),txtrad*cos(3*pi/2),0,'270º (O)','FontSize',fontsz,'HorizontalAlignment','center','BackgroundColor','white')

    % Inicializamos el patch y los plots con datos vacíos o iniciales
    v_init = VerticesEspejo(rEsp, AltAzEsp(1,[1,3]));
    [cAlt_init, cAz_init] = CoordCirculosEsp(rEsp, AltAzEsp(1,[1,3]));
    
    hEspejo = patch(ESPtile, v_init(1,:), v_init(2,:), v_init(3,:), [0.8 0.8 0.9]); %In superficie espejo
    hAltCirc = plot3(ESPtile, cAlt_init(1,:), cAlt_init(2,:), cAlt_init(3,:), 'k'); %In circulo altitud
    hAltpos  = plot3(ESPtile, cAlt_init(1,1), cAlt_init(2,1), cAlt_init(3,1), 'r.'); %In punto posicion altitud
    hAzCirc = plot3(ESPtile, cAz_init(1,:), cAz_init(2,:), cAz_init(3,:), 'k'); %In circulo acimutal
    hAzPos  = plot3(ESPtile, cAz_init(1,1), cAz_init(2,1), cAz_init(3,1), 'r.'); %In punto posicion acimutal
    
    view(ESPtile, -37.5, 20); axis(ESPtile, 'equal');
    xlim(ESPtile, [-.5,.5]); ylim(ESPtile, [-.5,.5]); zlim(ESPtile, [-.5,.5]);
    title(ESPtile, 'Simulación del controlador PID');

    %Plot Altitud
    ALTtile = nexttile(tlo);
    hold(ALTtile, 'on');
    plot(ALTtile, tiempo, AltAzEsp(:,1), tiempo, AltAzEsp(:,2), tiempo, AltAzObj(:,1));
    hLineAlt = xline(ALTtile, tiempo(1), 'k:');
    title(ALTtile, 'Ángulo altitud');

    %Plot Acimutal
    AZtile = nexttile(tlo);
    hold(AZtile, 'on');
    plot(AZtile, tiempo, AltAzEsp(:,3), tiempo, AltAzEsp(:,4), tiempo, AltAzObj(:,2));
    hLineAz = xline(AZtile, tiempo(1), 'k:');
    title(AZtile, 'Ángulo acimutal');

    %Bucle animación
    for i = 1:length(tiempo)
        tic
        
        %Coordenadas nuevas espejo y circulos
        v = VerticesEspejo(rEsp, AltAzEsp(i,[1,3]));
        [cAlt, cAz] = CoordCirculosEsp(rEsp, AltAzEsp(i,[1,3]));
        
        %Actualizacion de las posiciones
        hEspejo.Vertices = v';
        hAzCirc.XData = cAz(1,:); hAzCirc.YData = cAz(2,:); hAzCirc.ZData = cAz(3,:);
        hAzPos.XData = cAz(1,1);  hAzPos.YData = cAz(2,1);  hAzPos.ZData = cAz(3,1);
        hAltCirc.XData = cAlt(1,:); hAltCirc.YData = cAlt(2,:); hAltCirc.ZData = cAlt(3,:);
        hAltpos.XData = cAlt(1,1);  hAltpos.YData = cAlt(2,1);  hAltpos.ZData = cAlt(3,1);
        
        %Actualizacion de las lineas verticales
        hLineAlt.Value = tiempo(i);
        hLineAz.Value = tiempo(i);
        
        % Forzar refresco visual mínimo
        %drawnow limitrate
        
        % Control de tiempo real
        p = toc;
        disp(tstep - p)
        if (tstep - p) > 0
            pause(tstep - p)
        end
    end
end