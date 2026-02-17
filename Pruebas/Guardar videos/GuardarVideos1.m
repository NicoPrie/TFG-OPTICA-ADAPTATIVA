% 1. Configuración del video
tic
nombreArchivo = 'mi_animacion_1.mp4';
videoObj = VideoWriter(nombreArchivo, 'MPEG-4'); % Formato MP4
videoObj.FrameRate = 30; % Fotogramas por segundo
open(videoObj);

%Animación
ti=0;
tf=5;
fps=30;
fpstot=(tf-ti)*fps;
t=linspace(ti,tf,fpstot);
circulo=figure('Visible','off');

for i=1:length(t)
    %tic
    plot(sind(360/5*t(i)),sind(360/5*t(i)),'r.')
    axis equal
    xlim([-1.5,1.5])
    ylim([-1.5,1.5])
    %pause(1/fps-toc)
    frame=getframe(circulo);
    writeVideo(videoObj, frame);
    disp(t(i)/tf*100)
end

close(videoObj);
fprintf('Proceso finalizado en: %.2f segundos\n', toc);
