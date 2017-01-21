% [G] = parkg(Plate, loadtype, w,drho,z,spacing)
%
% Computes the gravity due to a deflected plate, using Parker
% (1973) method. 
%
% RETURN
%  G = vector containing discretized gravity values
% ARGUMENTS
%  All arguments are provided in SI units
%  Plate = Type of plate geometry selected. See, flexure_callback.m for more
%  details
%  loadtype = Type of load geometry selected. See, flexure_callback.m for more
%  details
%  w = vector containing discretized flexural deflection (Unit - m)
%  drho = density contrast (Unit - kg/m^3)
%  z = mean depth of layer (Unit - m);
%  spacing = discretization interval (Unit - m);
%  

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [G] = parkg(Plate, loadtype, w,drho,z,spacing)
dx = getappdata(0,'dx');

%Number of terms, parker series will be calculated to:
n = 2;
GU=6.67e-11; % Gravitational constant
% if Plate ==1 && loadtype == 2
%     w = -1*w;
% end

% Normalize W
MaxW = max(w);
w = w/MaxW;

%Read the length of w
len = length(w);
if Plate ==1 && loadtype == 3
    NFFT = 2*len;
%Fourier transform requires the signal to be symmetrical on both positive and 
% negative sides. So, flip w to create negative fourier domain
    w(len+1:2*len) = fliplr(w);
    %We are going to do computations in the wavenumber domain. 
    % Creating wavenumbers with the same spacing and length as input signal
    ks = len+1;
    kn = pi/spacing;
    dk = kn/(ks-1);
    k = 0:dk:kn;

else
% If the plate geometry is not harmonic, it means the w vector is not a
% power of 2, which means we need to Pad to next power of two length 
% and flip symmetrically
    Npad = 2^(nextpow2(len));
    NFFT=2*Npad;
    w(len+1:Npad)=0.;
    w(Npad+1:NFFT)=fliplr(w);
    ks = fix(NFFT/2)+1;
    kn = pi/spacing;
    dk = kn/(ks-1);
    k=0:dk:kn;
    
end


%Calculate the fourier transform of signal (last term of the parker(1973)
%equation 4.
dg1 = MaxW*fft(w,NFFT);%First term of the parker series, FFT in later versions of 
% matlab does not necessarily needs the signal to be in power of two.
% However, the program will be faster, if the length of signal and the
% its transform length is in the power of twos. The above FFT
% implementation of w will be better expressed as Gk1 = fft(w, n)

%Calculating the terms inside summation of equation 4
for i = 2:n
    W=fft(w.^i,NFFT);
    K = k.^(i-1);
    dg=dg1(1:ks)+(MaxW^i)*(K.*W(1:ks))/factorial(i);
end

% Calculating the gravity due to the terrain, remaining terms of parker's
% equation 4, and converted to mGal.

G0 = -2*pi*drho*GU; % unit is s^-2
Gf= 1.e05*G0*exp(-k*(z)).*dg;   %dg is in m, so, dg*G0 is in m/s^2. 
                                % By multiplying with 1e5, it is converted 
                                % to mGal

%Create symmetric signal and Inverse fourier transform to get the gravity. 
Gf(ks+1:NFFT) = fliplr(conj(Gf(2:ks-1)));
G = ifft(Gf);
% Use only upto the length of topography
G = G(1:len);