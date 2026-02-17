% 1. Configuración del video
tic
nombreArchivo = 'mi_animacion_2.mp4';
videoObj = VideoWriter(nombreArchivo, 'MPEG-4'); 
videoObj.FrameRate = 30; % Ajustado a tus fps de cálculo
open(videoObj);

% Parámetros
ti = 0;
tf = 5;
fps = 30;
t = linspace(ti, tf, (tf-ti)*fps);

% 2. PRE-CONFIGURACIÓN (Fuera del bucle)
circulo = figure('Visible', 'off'); 
% Creamos el objeto gráfico UNA SOLA VEZ
hPunto = plot(sin(360*t(1)), cos(360*t(1)), 'r.', 'MarkerSize', 20); 
axis equal
xlim([-1.5, 1.5])
ylim([-1.5, 1.5])
grid on;

% 3. BUCLE DE ANIMACIÓN OPTIMIZADO
for i = 1:length(t)
    % ACTUALIZAMOS solo las coordenadas, no redibujamos todo
    set(hPunto, 'XData', sin(360*t(i)), 'YData', cos(360*t(i)));
    
    % Captura y escritura
    frame = getframe(circulo);
    writeVideo(videoObj, frame);
    
    % Mostrar progreso cada 10% para no saturar la consola
    if mod(i, floor(length(t)/10)) == 0
        fprintf('Progreso: %.0f%%\n', (i/length(t))*100);
    end
end

close(videoObj);
fprintf('Proceso finalizado en: %.2f segundos\n', toc);