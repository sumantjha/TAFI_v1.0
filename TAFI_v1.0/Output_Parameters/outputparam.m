% [xcross,xb,wmax,ExpW,wb] = outputparam(x, w, l, D, g,gamma, alpha, apload, Plate, loadtype,loadpos) 
%
% Calculates the output parameters characterizing the shape of flexural
% basin
%
% * N.A. stands for "Not Applicable". Used where input arguments have no
% units.
% RETURN
% xcross = zero crossing position (Unit - km)
% xb = flexural bulge position (Unit - km)
% wmax = maximum deflection amplitude (Unit - km)
% ExpW =  exponent of maximum deflection magnitude (Unit - N.A.)
% wb = peripheral bulge magnitude (Unit - km)
% ARGUMENTS
% x = vector with discretized position values (Unit - km)
% w = discretized flexural deflection vector (Unit - km)
% l = topographic wavelength (Unit - km)
% D = Flexural rigidity (Unit - N-m)
% g = acceleration due to gravity (Unit - m/s^2)
% gamma = density contrast between mantle and infill (Unit - kg/m^3)
% alpha = flexural parameter (Unit -m)
% apload = applied load magnitude (Unit - N/m or N/m^2)
% Plate = selected plate geometry (Unit - N.A.)
% loadtype = select load geometry (Unit - N.A.)
% loadpos = position of load (Unit - km)
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [xcross,xb,wmax,ExpW,wb] = outputparam(x, w, l, D, g,gamma, alpha, apload, Plate, loadtype,loadpos) 
if Plate == 1 
    if loadtype == 1 || loadtype == 4
%Infinite plate, line load
        % Calculate flexural bulge position
        xb = pi*alpha/1000;
        % Calculate zero crossing position
        xcross = (3*pi/4)*alpha;
        % Calculate peripheral bulge amplitude
        [wb] = Continuous2D_flex(alpha,D,xb*1000);
        wb = max(apload)*wb;
        % Calculate maximum flexural deflection magnitude
        wmax = max(w);
    elseif loadtype == 2 || loadtype == 5 || loadtype == 6 || loadtype == 3
        if loadtype == 2 || loadtype == 5
            w = -1*w;
            % Calculate flexural bulge position
            for i = 1:length(x)
                if w(i) == max(w(1:length(x)))
                xb = x(i);
                end
            end
            % Calculate zero crossing position
            [xcross] = numcal_xcross(x,w,0);
            xcross = xcross*1000;
            % Calculate peripheral bulge amplitude
            [wb] = Continuous3D_flex(alpha,D,xb*1000);
            wb = max(apload)*wb;
            % Calculate maximum flexural deflection magnitude
            wmax = abs(min(w));
        elseif loadtype == 3
           % Calculate flexural bulge position
           xb = 3*l/4000;
           % Calculate zero crossing position
           xcross = l/2;
           % Calculate peripheral bulge amplitude
           [wb]= Harmonic2D_flex(xb*1000,l,apload,g,gamma, D);
           % Calculate maximum flexural deflection magnitude
           wmax = max(w);
        elseif loadtype == 6
             nx = getappdata(0,'nx');
             ny = getappdata(0,'ny');
             flexuregrid = getappdata(0,'flexuregrid');
             w = flexuregrid./1000;
             wmax = abs(min(min(w)));
             xb = 0; xcross = 0;wb = 0;
        end
    end
else 
%Semi-Infinite plate
    % Calculate flexural bulge position
    xb = 0.75*pi*alpha/1000;
    % Calculate zero crossing position
    xcross = pi*alpha/2;
    % Calculate peripheral bulge amplitude
    [wb] = Halfspace2D_flex(alpha,D,xb*1000);
    % Calculate maximum flexural deflection magnitude
    wmax = max(w);
end

%Calculate the exponent for flexural plot Y axis
ExpW = floor(log10(wmax));
%Set application data for access of these variables outside of 
%function
setappdata(0,'Xb',xb);
