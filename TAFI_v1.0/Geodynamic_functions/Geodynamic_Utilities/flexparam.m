% [alpha] = flexparam(D,gamma, g, E, Te, R, loadtype,Plate)
%
% Computes the flexural paramter for a given plate and load geometry.
%
% RETURN
% alpha = flexural paramter (Unit - meter)
% ARGUMENTS
% All arguments in SI units except loadtype and Plate, which are unit less 
% numerical values used for identifying plate and load type.
% D = flexural rigidity (Unit - N-m)
% gamma = density contrast between mantle and infill (Unit - kg/m^3)
% g = acceleration due to gravity (Unit - m/s^2)
% E = Young's Modulus (Unit - N/m^2)
% Te = Elastic thickness (Unit - meter)
% R = Earth's radius (Unit - m)
% Plate = Type of plate geometry selected from Plate Geometry drop down
% menu of TAFI 1 = Infinite plate, 2 = Semi-Infinite plate
% loadtype = type of load geometry selected from the load geometry dropdown
% menu after plate geometry has been selected. Plate = 1, Loadtype: 1 = 2D
% Impulse load, 2 = 3D Impulse load, 3 = Sinusoidal load, 4 = 2D
% Distributed load, 5 = 3D distributed load; Plate = 2, Loadtype: 1 = 2D
% Impulse load, 2 = 2D Distributed load.

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [alpha] = flexparam(D,gamma, g, E, Te, R, loadtype,Plate)

% Convert density of mantle from Kg/m3 to N/m3
gamma = (gamma)*g; 

%Calculate flexural parameter based on Plate and Load Type option

if Plate == 1 && (loadtype == 2 || loadtype == 5 || loadtype == 6)
        alpha=(D/((E*Te/R^2)+gamma))^0.25;
else
    alpha = (4*(D)/(gamma))^0.25;  
end

% Set Flex_param variable in app data. Setting variables in app data
% enables their use from anywhere in the main GUI code.
setappdata(0,'Flex_param',alpha/1000); 
