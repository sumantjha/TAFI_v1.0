% [wgreen] = Continuous3Dgrid_flex(alpha,D,x,y)
%
% Computes the 3D Green's function grid for a 2D continuous elastic plate under
% point load (Axisymmetric model)
%
% RETURN
%  wgreen = grid containing discretized Green's function
% ARGUMENTS
%  All arguments are provided in SI units
%  alpha = flexural parameter (Unit- meters)
%  D = flexural rigidity (Unit - Newton-meter)
%  x = vector of x positions at which to calculate Green's function (Unit -
%  meter)
%  y = vector of y positions at which to calculate Green's function (Unit -
%  meter)
%
% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [wgreen] = Continuous3Dgrid_flex(D,alpha,x,y)

% Modified from Continuous3D_flex.m to return grid instead of vector using
% x and y coordinates. Flexural parameter values based on Brotchie and
% Sylvester, 1969.


for i = 1:1:length(x)
    for j = 1:1:length(y)
        %Compute polar coordinates from cartesian, as axisymmetric flexure
        %is based on polar coordinates.
        r(i,j) = sqrt(x(i).^2+ y(j).^2)/alpha;
        %If r = 0, the kelvin function yields erroneous results. So,
        %assuming that at r = 0, r is minuscule but not exactly zero.
        if r(i,j) == 0
            r(i,j)=10^-6/alpha;
        end
        
        p(i,j) = r(i,j)*(1+1i)/sqrt(2); % Calculating exponent
        q(i,j) = imag(besselk(0,p(i,j))); % Calculating the Kelvin Kei function
        wgreen(i,j) = (((alpha)^2)/(2*pi*D))*q(i,j); % Calculating w due to point load
    end
end

%Use Wgreen to convolve with load