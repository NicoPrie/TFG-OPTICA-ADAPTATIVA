% function J = pid_cost(K,n)
%     %K=[Kp,Ki,Kd] Variables iniciales
%     %n -> número de capas.
% 
%     if any(K < 0) || any(K > 1000)
%         J = 1e6;
%         return;
%     end
% 
%     tfin = 25;
%     dt = 1/100;
%     t = 0:dt:tfin;
% 
%     [~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", K(1), "Ki", K(2), "Kd", K(3), "planta", "seg","NCapas",n);
% 
%     y = AltAzESP(:,1)';
% 
%     % Error
%     e = 1 - y;
% 
%     % Integral squared error
%     J = trapz(t, e.^2);
% 
%     % Overshoot (only positive)
%     overshoot = max(0, max(y) - 1);
%     %overshoot = trapz(t(e<0), -e(e<0));
% 
%     % Settling time (proper)
%     idx = find(abs(e) > 0.02, 1, 'last');
%     if isempty(idx)
%         settling_time = 0;
%     else
%         settling_time = t(idx);
%     end
% 
%     % Final cost
%     J = J + 10*overshoot^2 + settling_time;
% 
% end

% function J = pid_cost(K, n)
%     if any(K < 0) || any(K > 1000)
%         J = 1e6;
%         return;
%     end
% 
%     tfin = 25;
%     dt = 1/100;
%     t = 0:dt:tfin;
% 
%     [~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, ...
%                            "Kp", K(1), "Ki", K(2), "Kd", K(3), ...
%                            "planta", "seg", "NCapas", n);
%     y = AltAzESP(:,1)';
% 
%     % Error
%     e = 1 - y;
% 
%     % Integral squared error
%     ise = trapz(t, e.^3);
% 
%     % Overshoot
%     overshoot = max(0, max(y) - 1);
% 
%     % Settling time
%     idx = find(abs(e) > 0.02, 1, 'last');
%     if isempty(idx)
%         settling_time = 0;
%     else
%         settling_time = t(idx);
%     end
% 
%     % --- Aggressive overshoot strategy ---
%     % 1. Hard return: any overshoot > 5% is just rejected outright
%     if overshoot > 0.05
%         J = 1e6;
%         return;
%     end
% 
%     % 2. Multiplicative penalty: overshoot scales up the entire cost
%     %    even 1% overshoot doubles the total cost
%     overshoot_multiplier = 1 + 100*overshoot;
% 
%     % 3. Residual additive term for fine-grained pressure near zero
%     overshoot_penalty = 1000*overshoot^2;
% 
%     % Final cost
%     J = (ise + settling_time + overshoot_penalty) * overshoot_multiplier;
% end

% function J = pid_cost(K, n) %WORKS PRETTY GOOD
%     if any(K < 0) || any(K > 1000)
%         J = 1e6;
%         return;
%     end
% 
%     tfin = 25;
%     dt = 1/100;
%     t = 0:dt:tfin;
%     [~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, ...
%         "Kp", K(1), "Ki", K(2), "Kd", K(3), ...
%         "planta", "seg", "NCapas", n);
%     y = AltAzESP(:,1)';
% 
%     % Error
%     e = 1 - y;
% 
%     % ISE — squared, symmetric
%     ise = trapz(t, e.^2);
% 
%     % Overshoot
%     overshoot = max(0, max(y) - 1);
% 
%     % Settling time
%     idx = find(abs(e) > 0.02, 1, 'last');
%     if isempty(idx)
%         settling_time = 0;
%     else
%         settling_time = t(idx);
%     end
% 
%     % Hard reject large overshoot
%     if overshoot > 0.05
%         J = 1e6;
%         return;
%     end
% 
%     overshoot_multiplier = 1 + 100 * overshoot;
%     overshoot_penalty    = 1000 * overshoot^2;
% 
%     % Steady-state error over last 20% of simulation
%     ss_idx = round(0.8 * length(t)):length(t);
%     steady_state_bias  = abs(mean(e(ss_idx)));   % DC offset — catches persistent bias
%     steady_state_noise = mean(e(ss_idx).^2);     % residual ripple
% 
%     % Final cost
%     J = (ise + settling_time + overshoot_penalty ...
%          + 50000 * steady_state_bias ...
%          + 500   * steady_state_noise) ...
%         * overshoot_multiplier;
% end

function J = pid_cost(K, n)

    if any(K < 0) || any(K > 1000)
        J = 1e6;
        return;
    end

    tfin = 25;
    dt = 1/100;
    t = 0:dt:tfin;
    [~, AltAzESP] = SimPID(t, ones(length(t),2), "viento", false, "Kp", K(1), "Ki", K(2), "Kd", K(3), "planta", "seg", "NCapas", n);
    y = AltAzESP(:,1)';

    % Error
    e = 1 - y;

    % ITAE — time-weighted absolute error
    % Late errors cost far more than early ones, naturally pushes Ki up
    itae = trapz(t, t .* abs(e));

    % Overshoot
    overshoot = max(0, max(y) - 1);

    % Cuanto tarda en llegar a la posicion objetivo y equilibrarse
    idx = find(abs(e) > 0.02, 1, 'last');
    if isempty(idx)
        settling_time = 0;
    else
        settling_time = t(idx);
    end

    % Hard reject large overshoot
    if overshoot > 0.05
        J = 1e6;
        return;
    end

    overshoot_multiplier = 1 + 100 * overshoot;
    overshoot_penalty    = 1000 * overshoot^2;

    % Error en el último 20% de la simulcaión 
    ss_idx = round(0.8 * length(t)):length(t);
    steady_state_bias  = abs(mean(e(ss_idx)));
    steady_state_noise = mean(e(ss_idx).^2);

    % Error en el último 1% de la simulación
    % Ejerceremos más castigo si justo al final no hemos llegado al
    % objetivo.
    term_idx = round(0.99 * length(t)):length(t);
    terminal_penalty = abs(mean(e(term_idx)));

    % Coste final ponderado
    J = (itae + settling_time + overshoot_penalty + 50000  * steady_state_bias + 500    * steady_state_noise + 900000 * terminal_penalty) * overshoot_multiplier;
end