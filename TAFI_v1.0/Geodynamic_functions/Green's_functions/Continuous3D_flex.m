% [wgreen] = Continuous3D_flex(alpha,D,x)
%
% Computes the 3D Green's function for a continuous elastic plate under
% point load (Axisymmetric model)
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

function [wgreen] = Continuous3D_flex(alpha,D,x)

% Normalize alpha and intilize empty Green's Function
nx = length(x);
v = x/alpha;
wgreen = zeros(1,nx);
z = zeros(1,nx);
y = zeros(1,nx);

%Compute Green's Function
for i = 1:nx
    if x(i) == 0
        v(i)=(10^-18)/alpha;
    end
    z(i) = v(i)*(1+1i)/sqrt(2); % Calculating exponent
    y(i) = imag(besselk(0,z(i))); % Calculating the Kelvin Kei function
    wgreen(i) = (((alpha)^2)/(2*pi*D))*y(i); % Calculating w due to point load
end


