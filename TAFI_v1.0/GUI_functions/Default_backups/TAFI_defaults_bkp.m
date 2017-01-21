% TAFI_defaults(handles)
%
% Set the default values of GUI elements in TAFI. This is a backup file and
% is used when restoring the TAFI defaults to its original state. These 
% defaults values should not be confused with the default physical
% constant values which are set in DefConstants.m 
%
% Elements set in this function are:
% Default flexural rigidity = 1e15;
% Default infill density = 2280 kg/m^3;
% Default crustal density = 2800 kg/m^3;
% Default mantle density = 3200 kg/m^3;
% Default depth of 1st interface = 5000 m;
% Default depth of 2nd interface = 12000 m;
% Default load magnitude = 1e11 N/m;
% Default load position = 0 km;
% Default wavelength of sinusoidal load = 10 km;
% Default minimum plot position = 0 km;
% Default discretization interval = 0.03 km;
% Default maximum plot position = 100 km;

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function TAFI_defaults(handles)
% This function will set default values of parameters in TAFI.
% These defaults values should not be confused with the default physical
% constant values which are set in DefConstants.m 

%% Setting the default parameter values of editboxes first


flexslider_default = 20.3010;
D_default = 20.3010;
rhoi_default = 1000;
rhoc_default = 2800;
rhom_default = 3200;
cflrdepth_default = 5000;
crustalT_default = 12000;
load_default = 11.699;
loadpos_default = 0;
loadwavelength_default = 10;
xmin_default = 0;
spacing_default = 1;
xmax_default = 500;



%% Now setting the default ranges of slidere
% The flexural rigidity slider range are given as exponents of 10. So, for
% example if the minimum and maximum value desired is 10^12 to 10^20, the
% flexmin and flexmax needs to be set at 12 and 20, respectively.
flexmin = 15; flexmax = 26;

% The load sliders are set in similar manner as the flexural rigidity
% sliders with minimum and maximum exponent to 10 forming the range of
% sliders
loadmin = 1; loadmax = 20;

% The load position slider are set to range from positive earth's radius to
% negative earth's radius, with the default value set at 0.
loadposmin = -6370; loadposmax = 6370;

% The load wavelength is set to vary between minimum and maximum of 1 and
% earth's radius 6370 km. 
loadlambdamin = 1; loadlambdamax = 6370;






%% ************************************************************************
%% ************************************************************************
%% ************************************************************************
%% ************************************************************************
%% ************************************************************************
%% DO NOT CHANGE ANYTHING BELOW THIS LINE 
% The following lines of code update the respective GUI component in TAFI. 
% Do not change anything here.
% Populating defaults in TAFI. This and the part of code below
% will go into yet another script, leaving only the default values here, so
% that a user can change these if needed without seeing or bothering how
% it is being updated in TAFI.

set(handles.D,'String',num2str(10^D_default,'%.2e'));
set(handles.rhoi,'String',num2str(rhoi_default));
set(handles.rhocrust,'String',num2str(rhoc_default));
set(handles.rhom,'String',num2str(rhom_default));
set(handles.cflrdepth,'String',num2str(cflrdepth_default));
set(handles.crustalT,'String',num2str(crustalT_default));

set(handles.Load,'String',num2str(10^load_default,'%.2e'));

set(handles.loadpos,'String',num2str(loadpos_default,'%.2e'));

set(handles.lambda,'String',num2str(loadwavelength_default,'%.2e'));
set(handles.xmin,'String',num2str(xmin_default));
set(handles.spacing,'String',num2str(spacing_default));
set(handles.xmax,'String',num2str(xmax_default));

set(handles.flexslider,'Min', flexmin,'Value',flexslider_default,'Max',flexmax);
set(handles.loadslider,'Min',loadmin,'Value',load_default,'max',loadmax);
set(handles.loadposslider,'Min',loadposmin,'Value',loadpos_default,'Max',loadposmax);
set(handles.lambdaslider,'Min',loadlambdamin,'Value',loadwavelength_default,'Max',loadlambdamax);

%Elastic thickness has to be calculated from the default D values. The
%calculation uses default values of physical constants specified in
%DefConstants.m

DefConstant;
Te_default = ((12*(10^D_default)*(1-pr^2))/E)^(1/3);
set(handles.Te,'String',num2str(Te_default/1000, '%.2e'));
setappdata(0,'Te',Te_default);