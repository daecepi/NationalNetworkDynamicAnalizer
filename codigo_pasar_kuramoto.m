clear all; close all; clc;

global N alpha K_strength

% N = Numero de nodos a simular.
N = 125;
% p_conn: prbabilidad de conexión
p_conn = 0.05;
% Parámetro de inercia
alpha = 0.1;

% Inicializo la matriz de conectividad tamaño NxN
K = zeros(N);
% Verifico el grado (numero de conexiones) de cada nodo
deg = sum(K,2);

% Mientras que que haya algún nodo con grado 0 (la matriz es disconexa, lo
% cual no nos sirve) genero una matriz de conectividad aleatoria hasta
% que la matriz sea completamente conexa.
while(ismember(0,deg))
    % La matriz es simétrica
    for i = 1:N
        for j = i+1:N
            r = rand;
            % Esta es la condición para crear matrices aleatorias con
            % probabilidad de conexión p_conn.
            if(r<p_conn)
                K(i,j)=1;
                K(j,i)=1;
            end
        end
    end
    
    % reviso nuevamente el grado y vigilo que se cumpla la condición de ser
    % matrix conexa (con el while)
    deg = sum(K,2);
    
end

% Este es el vector de "Potencias" generadas y consumidas por la red
P = zeros(N,1);
% Caso del paper Rhoden y Timme de 5 plantas grandes y 20 pequeñas y el
% resto consumidores.
P(1:5) = 10; P(6:25) = 2.5; P(26:N)=-1;
% La suma de P's debe ser igual a 0!
sum(P)

K_strength = 3;
A = K_strength*K;

%%% DE AQUI EN ADELANTE SON CÁLCULOS NECESARIOS
%%% PARA EL PUNTO DE EQUILIBRIO

% 1. Defino el Laplaciano, para ello calculo primero el grado de cada nodo
% incluyendo su "fuerza de acople" y coloco estos valores en una matriz
% diagonal
degMat = diag(sum(A,2));
% Y el Laplaciano es por definición
Lap = degMat - A;

% 2. Para el pto de equilibrio de las fases calculo primero la
% pseudoinversa del laplaciano (por definición el laplaciano no es
% invertible, por eso la pseudoinversa). (Pseudo Inversa Moore-Penrose)
Lcross = pinv(Lap);

% 3. El punto de equilibrio de las fases es
thetaSteady = Lcross*P;
% Ojo, este punto de equilibrio es aproximado porque las cuentas se
% pueden hacer por la aproximacion de angulo pequeño de
% sin(theta) ~ theta.
% El equilibrio de \dot{theta} es 0!!

%%% DE AQUI EN ADELANTE SON CÁLCULOS ANALÍTICOS PARA SABER A PRIORI SI
%%% EL SISTEMA SINCRONIZA O NO (DORFLER, PNAS 2012)

% 1. Me sirve para este cálculo hacer uso de la estructura de datos
% tipo "grafo", que es una forma de manipular grafos de matlab:
G = graph(A);

% 2. Calculo la matriz de incidencia, que es una forma diferente de
% representar un grafo. Todo esto es siguiendo el paper de Dorffler:
Inc = incidence(G);
% El comando full me transforma entre la estructura de datos tipo grafo
% a las matrices que sabemos usar
B = full(Inc);

% 3. La condición de sincronización es en pocas palabras que la
% PEOR DIFERENCIA de los equilibrios entre nodos conectados sea
% menor que 1.
theta_diff_worst = norm(B'*thetaSteady,Inf);
% Imprimo en pantalla la pareja de valores de acople y peor diferencia
% para ver en qué momento es que esperamos que sincronice.
[K_strength theta_diff_worst]

%%% AHORA SI VIENEN LAS SIMULACIONES:

% Condiciones iniciales de las fases (primeras N variables). Inicio las
% fases en el punto de equilibrio
x0 = thetaSteady;
% Condiciones iniciales de las frecuancias (N+1:2*N)
xDot0 = zeros(N,1);
theta0 = [x0;xDot0];

% Tiempo máximo de simulación
tmax = 50;

% Integro las ecuaciones kuramoto_inercia (ver abajo)
[t,y] = ode45(@(t,x)kuramoto_inercia(x,P,K),[0 tmax],theta0);

% Extraigo el verdadero equilibrio (ultimos puntos de la simulacion)
x0_original = y(end,1:N);
xDot0_original = y(end,N+1:end);

% Para la Basin Stability debo perturbar la fase y la frecuencia de UN nodo
% Voy a hacer un espacio de perturbaciones de tamaño Nx X Ny 
Nx = 10;
Ny = 10;

% Las perturbaciones en fase tomarán Nx valores entre -pi a pi
pertTheta = linspace(-pi,pi,Nx);
% Las perturbaciones en frecuencia tomarán Ny valores entre -5 a 5
pertVel = linspace(-15,15,Ny);

% Los elementos de la matrix Sb(i,j) son 1 si la perturbacion 
% [perTheta(i),perVel(j)] en el nodo sobre el que estamos haciendo el 
% análisis vuelve al punto de equilibrio, o zero otherwise
Sb = zeros(Nx,Ny);

% Para cada perturbación debo simular el sistema un tiempo suficiente
tmax = 100;

% Este es el nodo que voy a elegir
node_number = 20;

for i = 1:Nx
    i
    for j = 1:Ny        
        x0 = x0_original;
        xDot0 = xDot0_original;
        % Únicamente cambio la condicion inicial del nodo que estamos
        % estudiando:
        x0(node_number)=pertTheta(i);
        xDot0(node_number)=pertVel(j);
        % Esta es la nueva condición inicial:
        theta0 = [x0;xDot0];
        
        % Integro las ecuaciones kuramoto_inercia (ver abajo)
        [t,y] = ode45(@(t,x)kuramoto_inercia(x,P,K),[0 tmax],theta0);
        % Esto es para discutir: según mi criterio, el mejor indicador si
        % la cosa está funcionando bien o no es si la velocidad más grande en la
        % red al final de la simulacion es mayor que una cierta tolerancia 
        % es que el sistema se voló (recordando que el sistema está en 
        % equilibrio cuando las velocidades son 0)
        
        velocity = y(end,N+1:end);
        norm(velocity,Inf)
        
        plot(t,y(:,N+1:end))
        drawnow
        
        if(norm(velocity,Inf)<1)
            Sb(i,j)=1;
        end
    end
end




%% Estas son las ecuaciones de kuramoto_inercia

function y = kuramoto_inercia(x,P,c)

global N alpha K_strength

theta = x(1:N); theta2 = x(N+1:end);

sumContribution = K_strength*sum(c.*sin(meshgrid(theta)-meshgrid(theta)'),2);

x1_dot = theta2;
x2_dot = P-alpha*theta2+sumContribution;

y = [x1_dot;x2_dot];
end