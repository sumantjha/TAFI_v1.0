%[wgreen] = Halfspace2D_flex(alpha,D,x)
%
% Computes the 2D Green's function for a broken elastic plate under
% 2D line load (Broken plate model)
%
% RETURN
%  wgreen = vector containing discretized Green's function
% ARGUMENTS
%  All arguments are provided in SI units
%  alpha = flexural parameter (Unit- meters)
%  D = flexural rigidity (Unit - Newton-meter)
%  x = vector of positions at which to calculate Green's function (Unit -
%  meter)

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha
function [wgreen] = Halfspace2D_flex(alpha,D,x)

% Initialize empty Green's Function
nx=length(x);
wgreen = zeros(1, nx);

% Compute Green's Function
for i = 1:nx
     wgreen(i) = ((alpha^3)/(4*D))*exp((-x(i))/alpha)*(cos((x(i))/alpha));
end