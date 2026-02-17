function [AltAzEsp] = posObj(t,tfin,met)
    AltAzEsp=zeros(length(t),2);

    for i=1:length(t)
        if met == 'step'
            temp=linspace(0,tfin,5);
            if t(i)<temp(2)
                AltAzEsp(i,:)=[45,0];
                %AltAzEsp=[0.1,-45+360];
            elseif t(i)>=temp(2) && t(i)<temp(3)
                AltAzEsp(i,:)=[45,-30];
                %AltAzEsp=[0.1,0.1];
            elseif t(i)>=temp(3) && t(i)<temp(4)
                AltAzEsp(i,:)=[45,-60];
                %AltAzEsp=[0.1,0.1];
            elseif t(i)>=temp(4)
                AltAzEsp(i,:)=[45,-90];
                %AltAzEsp=[0.1,0.1];
            end

        elseif met == 'flor'
            AltAzEsp(i,:)=[45+10*sind(180/20*t(i)),360/30*t(i)];

        elseif met == 'circ'
            AltAzEsp(i,:)=[45+30*sind(360/5*t(i)),-135+30*cosd(360/5*t(i))];
        elseif met == 'solp'
            rEsp=[0,0,0];
            rObj=[3,0,2];
            AltAzEsp(i,:)=AngFCordT([40.437271,-3.714715],rEsp,rObj,[2025, 12, 12+t(i)/(60*60)]);
            %AltAzEsp(i,:)=AngFCordT([40.437271,-3.714715],rEsp,rObj,[2025, 12, 0+t(i)/2]);
            %AltAzEsp(i,:)=AngFCordT([40.437271,-3.714715],rEsp,rObj,[]);
        end
    end
end