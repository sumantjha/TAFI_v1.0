% [G] = parkg_3D(nx,ny,dx,dy,z0,contrast, flexuregrid)
%
% Computes the gravity due to a deflected plate, using Parker
% (1973) method.
%
% RETURN
%  G = grid containing discretized gravity values
% ARGUMENTS
%  All arguments are provided in SI units
%  nx = number of nodes in X direction
%  ny = number of nodes in Y direction
%  dx = discretization interval along X direction
%  dy = discretization interval along Y direction
%  z0 = mean depth of layer (unit-m)
%  contrast = density contrast (Unit - kg/m^3)
%  flexuregrid = grid containing discretized flexural deflection (Unit - m)
%  

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [G] = parkg_3D(nx,ny,dx,dy,z0,contrast, flexuregrid)

% This version of Parker will read the unadulterated flexural grid.
%Number of terms, parker series will be calculated to:
n = 4;
GU=6.67e-11; % Gravitational constant


%Normalize flexuregrid
maxw = max(max(flexuregrid));
wgrid = flexuregrid/maxw;

% We create wavenumber grid, of the size same as the flexure green's function grid
[Nx, Ny] = size(flexuregrid);
knx = pi/dx; kny = pi/dy;
dkx = knx/(Nx - 1); dky = kny/(Ny - 1);
kx = 0:dkx:knx; ky = 0:dky:kny;
% Create Wavenumber grid which will be padded 
for i = 1:1:length(kx)
    for j = 1:1:length(ky)
        wavegrid (i,j) = sqrt(kx(i)^2+ky(j)^2);
    end
end



%Fourier transform requires the signal to be symmetrical on both positive and 
% negative sides. So, flip w grid to create a uniformally distributed grid
% spanning negative x and y. 
% We flip both the padded wavegrid and flexure grid. Working on flexure
% grid first
FlippedWGrid(1:Nx,1:Ny) = wgrid;
FlippedWGrid(Nx+1:2*Nx,1:Ny) = flipud(wgrid);
FlippedWGrid(1:Nx,Ny+1:2*Ny) = fliplr(wgrid);
FlippedWGrid(Nx+1:2*Nx,Ny+1:2*Ny) = rot90(wgrid,2);

%Now flipping wavegrid
FlippedWaveGrid(1:Nx,1:Ny) = wavegrid;
FlippedWaveGrid(Nx+1:2*Nx,1:Ny) = flipud(wavegrid);
FlippedWaveGrid(1:Nx,Ny+1:2*Ny) = fliplr(wavegrid);
FlippedWaveGrid(Nx+1:2*Nx,Ny+1:2*Ny) = rot90(wavegrid,2);



%the constant term of the series is computed
% and converted to mGal.

constantbou=-(2*pi*GU*contrast*1.e05)*(exp(-(z0).*(FlippedWaveGrid)));  


%The sum of fourier transforms starts here. At each step, a new term of the series is computed and added to 
% the previous one. Then, if the number of sums is lower than the number of iterations, the process continues.


%First term of the parker series, FFT in later versions of 
%matlab does not necessarily needs the signal to be in power of two.
% However, the program will be faster, if the length of signal and the
% its transform length is in the power of twos. The above FFT
% implementation of w will be better expressed as Gk1 = fft(w, n)
sumtotal = 0;


%Calculating the terms inside summation of equation 4
for i = 1:n
    W=fft2(FlippedWGrid.^i);
    K = FlippedWaveGrid.^(i-1);
    sumtotal=sumtotal+(maxw^i)*(K.*W)/factorial(i);
end

% Calculating the gravity due to the terrain, remaining terms of parker's
% equation 4, and converted to mGal.

G = constantbou.*sumtotal;

G = real(ifft2(G));