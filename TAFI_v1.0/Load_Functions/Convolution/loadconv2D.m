% [fullW,plotx] = loadconv2D(wgreen, apload,loadtype,spacing,x)
%
% Computes the flexural deflection due to a spatially distributed load. 
% This function, flips the flexural response of green's function
% calculated for a selected load geometry, and convolves with load vector
% describing the load distribution
%
% RETURN
%  fullW = vector containing discretized flexural deflection due to
%  spatially distributed load
%  plotx = vector containing the plot positions corresponding to each
%  flexural deflection magnitude.
% ARGUMENTS
%  All arguments are provided in SI units
%  wgreen = discretized flexural deflection Green's function (Unit - m)
%  apload = spatially distributed load (Unit - N/m or N/m^2)
%  loadtype = the type of load specified by user. If distributed
%  axisymmetric load, then flip the flexural deflection vector to agree
%  with sign convention being used in TAFI.
%  spacing = discretization interval being used for convolution (Unit - m)
%  x = vector containing the plot positions corresponding the flexural
%  deflection green's function (Unit - m);
%
% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [fullW,plotx] = loadconv2D(wgreen, apload,loadtype,spacing,x)
% Flip Wgreen, to obtain complete green signal over -x to +x. 
    if loadtype == 5
        wgreen = -1*wgreen;
    end 
nw = length(wgreen);
w(nw+1:2*nw-1) = wgreen(2:nw);
w(1:nw) = fliplr(wgreen(1:nw));

% Convolve the flipped W with the distributed load.
fullW = conv(w,apload);
%Scale the convolved flexural deflection vector with spacing to finish
%convolution
fullW = spacing*fullW;
% Create x vector of the same size and direction as flexural deflection
% vector
plotx(1:nw) = fliplr(-x);
plotx(nw+1:2*nw-1) = x(2:nw);