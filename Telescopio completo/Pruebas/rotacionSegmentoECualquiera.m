v=readmatrix('verticesESPvertical.txt');
ux=[-1;0;0];
uy=[0;0;1];

a1t=[linspace(0,45,20),45*ones(1,20)];
%a1t=[0*ones(1,20),linspace(0,45,20)];
%a1t=0*a1t;
a2t=[zeros(1,20),linspace(0,-45,20)];
%a2t=[linspace(0,-45,20),-45*ones(1,20)];
%a2t=0*a2t;


%Rx=[1,0,0;0,cosd(90),-sind(90);0,sind(90),cosd(90)];
%v=Rx*v;
figure

for i=1:length(a1t)
    a1=a1t(i);
    a2=a2t(i);
    
    Rx=matROT(a1,uxi);
    uyi=Rx*uy;
    disp(uyi)
    Ry=matROT(a2,uyi);
    uxi=Ry*Rx*ux;

    %vi=Rx*Ry'*v;
    vi=Ry*Rx*v;

    plot3(0,0,0)
    hold on
    patch(vi(1,:),vi(2,:),vi(3,:),[0.8 0.8 0.9])
    plot3([0,uxi(1)],[0,uxi(2)],[0,uxi(3)])
    plot3([0,uyi(1)],[0,uyi(2)],[0,uyi(3)])
    axis equal

    xlim([-1,1])
    ylim([-1,1])
    zlim([-1,1])

    xlabel('x')
    ylabel('y')
    zlabel('z')
    hold off

    pause(0.1)
end