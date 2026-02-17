%Resolucion de EDO
%Definicion de los parámetros de la planta.
J=100; %Inercia
D=10; %Amortiguamiento
K=0; %Rigidez

%Definición de la EDO
A=[0,1;-K/J,-D/J];
B=[0;1/J];
nu=0;
T=12000;

tic
ode_fun1=EDOplanta(J,D,K,nu,T);
ode_fun2=EDOplanta(J,D,K,nu,0);
toc

%Solución
fps=10;
step=1/fps;
tiempoTorque=2;
[t1,X1]=ode45(ode_fun1, 0:step:tiempoTorque, [0;0]);
[t2,X2]=ode45(ode_fun2,0:step:30,[X1(end,:)]);

figure
plot([t1;t2+tiempoTorque],[0*[X1;X2],[X1;X2]])

dibujarEspejo([t1;t2+tiempoTorque],[0*[X1;X2],[X1;X2]])

figure
plot([t1;t2+tiempoTorque],[X1;X2])
legend('Posición','Velocidad')