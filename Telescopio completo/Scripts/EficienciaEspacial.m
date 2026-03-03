lim=80;
capas=0:lim;
rt=2.560/2;
r=rt./(capas*2+1);
eficiencia=((3*capas.*(capas+1)+1).*r.^2)./(rt.^2)*100;

capasl=linspace(0,lim,1000);
rl=rt./(capasl*2+1);
eficiencial=((3*capasl.*(capasl+1)+1).*rl.^2)./(rt.^2)*100;

figure
hold on
plot(capasl,eficiencial,'k')
plot(capas,eficiencia, 'or')
plot([0,lim],[75,75], '--b')
yticks([0 10 20 30 40 50 60 70 75 80])