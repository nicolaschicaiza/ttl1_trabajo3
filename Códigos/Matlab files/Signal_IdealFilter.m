clear; %Limpio Espacio de trabajo
clc;

narm=82; %Número de armónicos tomados para reconstruir la señal

A=1;
sh=0.5;
Tr=2;
To=100;
T=Tr+To;

f=1/T; %Frecuencia
fs=(1/T):1/T:(narm/T); %Normalización vector de Frecuencia

np=T*0.001; %Espacio numérico definido en el periodo de la función (np=Numero de muestras en un periodo)
t=-(2*T):np:(2*T); %Limites del espacio numérico (eje de abscisas ¨tiempo¨)

parsacum=0;

ramp=(A/Tr)*(t+sh); %Defino la pendiente de las rampas y creo el vector rampa con respecto al tiempo
ps=ramp.*rectpuls((t+sh)-(Tr/2),Tr); %Acoto el vector rampa con un pulso rectangular de origen en 0 y ancho Tr
dds=zeros(size(t)); %Incializo variable
shft=0; % Incializo variable
for k=-2:1:1 %en este ciclo roto el vector rampa ps y voy generando la función diente de sierra repetida por 4 periodos
    shft=T*k*(1/np);
    dds=dds+circshift(ps,fix(shft)); %sumatoria de generación
end

plot(t,dds,'b',t,Sefu,'r'),grid on,xlabel 'Tiempo (Seg)', ylabel Amplitud;xlim([-2*T 2*T]); %Gráficas de Resultados
title(['\bf Señal Original vs Señal Reconstruida - Numero de Armónicos: ',num2str(n),'']);

%% CALCULO DE COEFICIENTES

% |Bn| 
syms x n;
dib=(A*x/Tr)*sin(2*pi*n*f*x); %Expresión dentro de la integral b 'dib'
bn=(2/T)*int(dib,[0 Tr]); %Integral definida en el periodo de la rampa
bn=simplify(bn)

% |An|
syms x n;
dia=(A*x/Tr)*cos(2*pi*n*f*x); %Expresión dentro de la integral a 'día'
an=(2/T)*int(dia,[0 Tr]);
an=simplify(an)

% |Ao|
syms x n;
diao=(A*x/Tr); %Expresion dentro de la integral a 'diao'
ao=(2/T)*int(diao,[0 Tr])

%% Ciclo sumatoria coeficientes
Sefu=ao/2;% Inicializo con el nivel DC
for n=1:narm %Ciclo de sumatoria (desde n=1 hasta el numero de armónicos deseados (narm))
    anf=subs(an);%Evaluo el coeficiente a en n
    anf=double(anf);%Convierto el coeficiente en numero para optimizar cálculos
    Sefua=anf*cos(2*pi*n*f*(t+sh));
    bnf=subs(bn);%Evaluo el coeficiente b en n
    bnf=double(bnf);%Convierto el coeficiente en numero para optimizar cálculos
    Sefub=bnf*sin(2*pi*n*f*(t+sh));
    mag(n)=sqrt(bnf^2+anf^2);%Vector del espectro de magnitud
    Sefu=Sefu+(Sefua+Sefub);
    parsacum=parsacum+(mag(n)^2);
end

%% Convergencia de la serie a la función

% |Igualdad de Parseval|
dipc=(abs(A*x/Tr))^2; %Expresion dentro de la integral pc 'dipc'
parscon=(2/(T))*int(dipc,[0 Tr]); %Integral del lado continuo de la igualdad de Parseval
parscon=double(parscon) %Valor del lado continuo de la igualdad de Parseval
parsdiscre=((ao^2)/2)+parsacum %Valor del lado serial de la igualdad de Parseval
relpars=(parsdiscre/parscon)*100 %porcentaje de convergencia en la igualdad de Parseval

% |Fenómeno de Gibbs|
%La señal original presenta un punto de desigualdad en t=3.5 (este valor
%cambia dependiendo del periodo de la rampa), la simulación permite cambiar
%este valor en la variable sh
gibborig=(0+A)/2 %Valor medio entre dos puntos (anterior y posterior) de la discontinuidad
indicet = find(abs(t-(Tr-sh)) < 1); %Busco la posición en el vector tiempo que corresponde a la discontinuidad
gibbrecons=Sefu(indicet); %Encuentro el/los valores la serie de Fourier en los puntos cercanos a la discontinuidad
[errgibs vgibbs]=min(abs(gibbrecons-gibborig)); %uso la función min para encontrar el valor mas cercano al punto medio entre los valores de la serie de Fourier cercanos a la discontinuidad y el error entre el valor continuo y el valor discreto
gibbsaprox=gibbrecons(vgibbs) %valor de la serie de Fourier mas cercano a la discontinuidad
errgibs %valor del error en unidades de amplitud entre la serie de Fourier y el valor medio entre la discontinuidad

%% Gráficas de Resultados
plot(t,dds,'b',t,Sefu,'r'),grid on,xlabel 'Tiempo (Seg)', ylabel Amplitud;xlim([-2*T 2*T]); %Gráficas de Resultados
title(['\bf Señal Original vs Señal Reconstruida - Numero de Armónicos: ',num2str(n),'']);
figure,
stem(fs,mag),grid on,xlabel 'Frecuencia (Hz)', ylabel Amplitud; %Gráficas de Resultados
title('\bf Espectro de Amplitud');
