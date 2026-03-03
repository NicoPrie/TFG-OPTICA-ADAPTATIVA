function [ode_fun] = EDOplanta(J,D,K,nu,T)
%J Inercia
%D Amortiguamiento
%K Rigidez
arguments (Input)
    J
    D
    K
    nu
    T
end

%Definición de la EDO
A=[0,1;-K/J,-D/J];
B=[0;1/J];

ode_fun=@(t,X) A*X + B*(T+nu);
end