% DefConstant_bkp
%
% This is backup file for default values for various parameters are stored 
% in this program.
% This file restores the values of physical constant and the DefConstant.m
% to its original state.
% 
%  g is the acceleration due to gravity (m/s^2)
%  E is Young's Modulus   (N/m^2)
%  pr is the Poisson's ratio (No units)
%  R is earth's radius (m)

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha







 
%%% CHANGE THESE VALUES IF NEEDED
    g = 10;
    E = 8.35*1e10;
    pr = 0.25;
    eta = 1e18;
    R = 6370000;
%%%% DO NOT CHANGE ANYTHING BELOW THIS LINE








setappdata(0,'g',g);
setappdata(0,'E',E);
setappdata(0,'pr',pr);
setappdata(0,'eta',eta);
setappdata(0,'R',R);