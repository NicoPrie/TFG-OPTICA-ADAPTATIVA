clear
clc

m = mobiledev;
m.OrientationSensorEnabled = 1;
m.SampleRate=100;

tic
m.Logging = 1;
pause(0.5)
step=1/20;
t=300;
to=0;

figure
az=plot(0, 0);

figure
alt=plot(0, 0);

figure
azalt=plot(0,0);
xlim([-40,40])
ylim([-25,25])

%figure
%plot(to, o(:,3))

while to(end) < t
[o,to] = orientlog(m);

%Azimutal angle
o(:,1) = unwrap(deg2rad(o(:,1)));
o(:,1) = rad2deg(o(:,1));
o(:,1) = smoothdata(o(:,1), 'movmean', 50);
o(:,1) = o(:,1) + 90;

%Altitude angle
o(:,2) = smoothdata(o(:,2), 'movmean', 50);
o(:,2) = -o(:,2);
%o(:,2) = unwrap(deg2rad(o(:,2)));
%o(:,2) = rad2deg(o(:,2));

o(:,3) = smoothdata(o(:,3), 'movmean', 50);
%o(:,3) = unwrap(deg2rad(o(:,3)));
%o(:,3) = rad2deg(o(:,3));


az.YData=to;
az.XData = o(:,1);
alt.XData = to;
alt.YData = o(:,2);
azalt.XData=o(:,1);
azalt.YData = o(:,2);
drawnow;

pause(step)
end

m.Logging = 0;
toc