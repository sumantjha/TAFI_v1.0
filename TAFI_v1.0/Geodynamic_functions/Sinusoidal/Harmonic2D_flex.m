% [w]= Harmonic2D_flex(x,l,apload,g,gamma, D)
%
% Computes the flexural deflection of a continous plate due to 2D sinusoidal load.
%
% RETURN
%  w = vector containing discretized flexural deflection
% ARGUMENTS
%  All arguments are provided in SI units
%  x = vector of positions at which to calculate flexural deflection (Unit -
%  meter)
%  l = wavelength of sinusoidal load (Unit - meter)
%  apload = sinusoidal load magnitude (Unit- Newton)
%  g = acceleration due to gravity (Unit - m/s^2)
%  gamma = density constrast between mantle and infill (Unit - kg/m^3)
%  D = flexural rigidity (Unit - Newton-meter)
%  

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [w]= Harmonic2D_flex(x,l,apload,g,gamma, D)
% Calculate the amplitude of deflection of the lithosphere
w0 = apload/(g*gamma+D*(2*pi/l)^4);
nx = length(x);

% Because the loading is perodic in 'x', the deflection of the lithosphere
% will also vary sinsoidally in x. Calculate the deflection of lithosphere
for i=1:nx
        w(i) = w0* sin(2*pi*x(i)/l); %unit is meters
end

 