capas=2;
draw=true;
s=0;

rt=2.560/2;%Radio del espejo principal (m): ref. Nordic Optical Telescope (NOT) -> 2.560 m
r=rt/(capas*2+1);%
%f=1;%Distancia focal del espejo completo.
f=5.12; %(NOT) -> 5.12 m
t=@(capas) linspace(0,2*pi,capas*6+1); %Coloca posiciones para n espejos en 2pi radianes

T={}; %Cell array donde cada elemento es un vector de radianes donde colocaremos cada fila de espejos
for i=1:capas
    T{end+1}=t(i);
    T{end}(end)=[]; %Elimina el ultimo elemento redundante (T(1)=T(end))
end


rESP0=[zeros(3*capas*(capas+1),3)];

if 3*capas*(capas+1)>2500
    input("Nº de segmentos:" + (3*capas*(capas+1)+1) + ", continuar? ")
end

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
    xlim([-rt*(1+0.2),rt*(1+0.2)])
    ylim([-rt*(1+0.2),rt*(1+0.2)])
    zlim([-rt*(1+0.2),rt*(1+0.2)])

    xlabel('x(m)')
    ylabel('y(m)')
    zlabel('z(m)')
    patch(v(1,:),v(2,:),v(3,:),[0.8 0.8 0.9])

    title("Nº Capas:" + capas + " Nº Segmentos:" + (3*capas*(capas+1)+1))
    %annotation('textbox', [0.77, 0.5, 0.7, 0.1], 'String', {"PARAMETROS DEL ESPEJO","Distancia focal: " + f + "m", "Diametro del espejo: " + rt*2 + "m", "Diametro por segmento:" + rt/(capas*2+1), "Porcentaje de superficie cubierta:" + round(((3*capas*(capas+1)+1)*r^2)/(rt^2)*100,2) + "%"}, 'FitBoxToText', 'on');
end

k=0; %Guarda cuantos objetos habia en las capas anteriores
for i=1:capas
    for j=1:length(T{i})
        rj=[i*2*r*sin(T{i}(j)),(i*2*r)^2/(4*f),i*2*r*cos(T{i}(j))];
        rESP0(k+j,:)=rj; %Añade a la lista de posiciones despues de los k anteriores elementos
        vj=v+rj';
        if draw
            patch(vj(1,:),vj(2,:),vj(3,:),[0.8 0.8 0.9])
        end
    end
    k=k+6*i; %Actualiza k con el numero de elementos de la capa
end

view(0,0)
rESP0=[0,f,0;0,0,0;rESP0];

if s
exportgraphics(gca,'C:\Users\priet\OneDrive - Universidad Complutense de Madrid (UCM)\Escritorio\Carrera\4 - Cuarto\TFG\Figuras\Segmentos15.png','Resolution',300)
end

clearvars -except rESP0 v

writematrix(rESP0,'Telescopio completo\Datos\coordenadasESP') %[Coordenadas del foco; Coordenadas de los espejos]
writematrix(v,'Telescopio completo\Datos\verticesESPvertical') %Coordenadas de los vertices de un hexagono centrado en [0,0,0]