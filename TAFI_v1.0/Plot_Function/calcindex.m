% [flexcolor]= calcindex(w,plotx, xmin,spacing,xmax)
%
% Calculates the index number of user specified xmin and xmax to be used in
% TAFIPlot2D.m. Also, determines the color of the flexural deflection plot
%
% RETURN
% flexcolor = color of flexural deflection curve. A matrix of 1x3.
% ARGUMENT
% w = vector of discretized flexural deflection values (Unit - km)
% plotx = vector of discretized plot positions (Unit - km)
% xmin = user specified minimum plot position (Unit - km)
% spacing = discretization interval (Unit - km)
% xmax = user specified maximum plot position (Unit - km)
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [flexcolor]= calcindex(w,plotx, xmin,spacing,xmax)

%Calculate the index for xmin and xmax in x vector
Nxplotmin = ((xmin-(min(plotx)))/spacing)+1;
Nxplotmax = ((xmax-(min(plotx)))/spacing)+1;

%If the index positions as calculated above are less than one, it means,
%that the index numbers start at 1.

if Nxplotmin < 1
    Nxplotmin = 1;
end
if Nxplotmax < 1
    Nxplotmax = 1;
end

% Setting application data to be read from TAFI.m and other functions.
setappdata(0,'Nxplotmax',Nxplotmax);
setappdata(0,'Nxplotmin',Nxplotmin);



%Setting data for plotting and export in km
x = plotx/1000;
w = w/1000;
setappdata(0,'x',x);
setappdata(0,'w',w);
    
% Plotting flexural curve
flexcolor = rand(1,3);
setappdata(0,'flexcolor',flexcolor);

