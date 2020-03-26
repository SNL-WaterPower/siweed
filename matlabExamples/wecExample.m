% this script is meant to provide an example for the functionality of the
% WEC, both for GUI and Arduino Due programming.

clc
clear
close all

%% GUI

% 0: off
% 1: feedback
% 2: function generator (same as sea state for wave maker)
% 3: torque tracking (others can use this as interface to MC)
mode = 1;

switch mode
    case 0
    case 1
        kP = -1.4;
        kD = 1.2;
    case 2
        % see fsTimeseries.m example
    case 3
        tau = 5;
end

% pass to DUE: mode, kP, kD, [w0, Amp, fs_indices, phase], tau
        
%% DUE

dt = 0.01; % time step (not sure what the right number is, just using 0.01 an example)

switch mode
    case 0
        % disable motor controller if possible
    case 1
        ii = 2;
        pos(ii-1) = 3.9;
        pos(ii) = 4;
        vel(ii) = (pos(ii) - pos(ii-1)) / dt;
        tau = kP * pos(ii) + kD * vel(ii);
    case 2
        % see fsTimeseries.m example
    case 3
        tau = tau; % just directly setting from GUI, mostly for debugging
end
    
% command torque to motor
disp(tau)

% measure position from encoder

pow = -1 * tau * vel(ii);
disp(pow)

% pass to GUI: pos, vel, pow (pow is the basis for the town lights)
