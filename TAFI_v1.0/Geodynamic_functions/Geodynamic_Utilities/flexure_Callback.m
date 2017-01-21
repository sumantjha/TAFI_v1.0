%% flexure_Callback(hObject, eventdata, handles)
%
% To understand what "callback" functions are, check Matlab help file.
% This function is used when ever a user changes any parameter on the GUI. 
% The function reads all the variables and calls geodynamic subroutines,
% continuous_flex, discontinuous_flex or axisymmetric_point depending on
% the combination of plate geometry and load shape selected. 
% The combinations are:
% Infinite plate geometry & 2D Impulse load - call Continuous2D_flex.m
%                         & 3D Impulse load - call Continuous3D_flex.m
%                         & 2D Sinusoidal load - call Harmonic2D_flex.m
%                         & 2D Distributed load - call Continuous2D_flex.m
%                         & 3D Distributed load - call Continuous3D_flex.m
%
% Semi-Infinite plate geometry & 2-D Impulse load   - call Halfspace2D_flex.m
%                              & 2-D Distributed load - call Halfspace2D_flex.m
%
% ARGUMENTS (Read from GUI)
% D = flexural rigidity (Unit - Nm)
% rhomantle = density of mantle (Unit - kg/m^3)
% rhoinfill = density of infill (Unit - kg/m^3)
% xmin = minimum plot position  (Unit - km)
% xmax = maximum plot position  (Unit - km)
% apload = applied load         (Unit - N)
% Plate = selected plate geometry expressed as 1 for infinite and 2
% for semi-infinite
% g = acceleration due to gravity
% w0 = variable to store harmonic load deflection
% gamma = variable to store density contrast
% alpha = flexural parameter
% Te = elastic thickness
% E = Young's modulus
% pr =Poisson's ration
% spacing = plot spacing interval
% x = position
% w = deflection
% loadtype = selected load geometry type (harmonic, line or point)
% loadpos = position of the load
% xcross = cross-over distance for flexure curve
% The plots are made in the flexure plot window (axes 1)
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function flexure_Callback(hObject, eventdata, handles)
% setting which plot window, the flexure plot will be created
%TAFI_defaults(handles);
global rhomantle rhoinfill xmin xmax apload Plate g gamma D alpha Te l E pr spacing x w loadtype loadpos xcross xb wmax ExpW

% Reading inputs.
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu, 'Value');
D = str2double(get(handles.D,'String'));
rhomantle = str2double(get(handles.rhom,'String'));
rhoinfill = str2double(get(handles.rhoi,'String'));
xmin = str2double(get(handles.xmin,'String'))*1000; %converting input to meters
xmax = str2double(get(handles.xmax,'String'))*1000; %converting input to meters
if xmin>xmax
    errordlg('Xmax should be greater than Xmin');
end
loadpos = str2double(get(handles.loadpos,'String'))*1000;
l = str2double(get(handles.lambda,'String'))*1000;
apload = str2double(get(handles.Load,'String'));
Te = str2double(get(handles.Te,'String'))*1000;
rhocrust = str2double(get(handles.rhocrust,'String'));
cflrdepth = str2double(get(handles.cflrdepth,'String'));
crustalT = str2double(get(handles.crustalT,'String'));
gamma = rhomantle-rhoinfill;

% set data variables to be used for exporting parameters to text file when
% called
setappdata(0,'D',D);
setappdata(0,'Load',apload);
setappdata(0,'Xmin',xmin);
setappdata(0,'Xmax',xmax);
setappdata(0,'Loadpos',loadpos);
setappdata(0,'Infill_Den',rhoinfill);
setappdata(0,'C_den',rhocrust);
setappdata(0,'M_den',rhomantle);
setappdata(0,'First_intdep',cflrdepth);
setappdata(0,'Sec_intdep',crustalT);

% ***********Initialising geodynamic modeling *****************
% The default values for acceleration due to gravity, young's modulus and 
% poisson's ration and earth's radius are stored in an external matlab 
% file called DefConstant, which can be edited, if needed from the TAFI 
% interface by selecting Change Defaults.

DefConstant;
g = getappdata(0,'g');
E = getappdata(0,'E');
pr = getappdata(0,'pr');
R = getappdata(0,'R');


%Calculate flexural parameter, alpha. The flexparam function reads in the
%loadtype and computes the flexural parameter accordingly.
[alpha] = flexparam(D,gamma, g, E, Te, R, loadtype,Plate);

%%
% If the plate geometry selected is infinite
if Plate==1
    % Title of the plots
        title = 'Gravity and flexure model of Lithosphere for a Continous Plate';
        set(handles.Title,'String',title);
    % if the load shape is harmonic
    if loadtype == 1
        setTAFIenv(handles, Plate, loadtype);
        % Read plot spacing
        spacing = str2double(get(handles.spacing,'String'))*1000;
        % Determine X vector. See x_vector help for decision tree
        [x] = x_vector(alpha,l,xmin, spacing, xmax, Plate, loadtype,0,0);
        % Calculate the green's function for infinite plate and 2-D line
        % load
        [wgreen] = Continuous2D_flex(alpha, D,x);
        
    % if the load geometry selected is 2-D line load
    elseif loadtype == 2
        setTAFIenv(handles, Plate, loadtype);
        % Read plot spacing
        spacing = str2double(get(handles.spacing,'String'))*1000;
        % Determine X vector. See x_vector help for decision tree
        [x] = x_vector(alpha,l,xmin, spacing, xmax, Plate, loadtype,0,0);
        % Calculate the flexural deflection, positions, cross over
        % position,flexural parameter and the color with which the flexure is being plotted
        [wgreen] = Continuous3D_flex(alpha,D,x);

    elseif loadtype == 3
        setTAFIenv(handles, Plate, loadtype);

        % Determine X vector. See x_vector help for decision tree. Plot
        % spacing computed inherently for harmonic loads.
        [x] = x_vector(alpha,l,xmin, spacing, xmax, Plate, loadtype,0,0);
        
        % Flip x vector to twice the length. Helps in minimizing aliasing
        % in gravity calculations.
        nx = length(x);
        x2(nx+1:2*nx) = x;
        x2(1:nx) = fliplr(-x);
        
        % Calculate the flexural deflection, positions, cross over
        % position, and the color with which the flexure is being plotted
        [w]= Harmonic2D_flex(x2,l,apload, g, gamma, D);
         
        % GET THE SPACING BEING USED IN HARMONIC FLEX CODE AND DISPLAY IT
        spacing = getappdata(0,'h_spacing');
        set(handles.spacing,'String',num2str(spacing/1000));
        Message = sprintf('Spacing parameter set to %5f km',spacing/1000);
        set(handles.Spacingperiodic,'String',Message);
        
    elseif loadtype == 4 || loadtype ==5
        setTAFIenv(handles, Plate, loadtype);
        spacing = str2double(get(handles.spacing,'String'))*1000;
        % Read load 2D function reads the 2-D distributed load file using
        % the ImportLoad.fig and ImportLoad.m functions and interpolates
        % load magnitudes based on load or plot spacing as described in loadspacinginterp.
        [apload,loadingfnpos] = ReadLoad2D(spacing,handles);
        % Adding a check here to ensure program still runs even if the user
        % hit cancel button while importing load
        if length(apload) == 1 && apload == 0
            loadfilemin = 0;
            loadfilemax = 0;
        else
            loadfilemin = loadingfnpos(1);
            loadfilemax = loadingfnpos(length(apload));           
        end
        % Determine X vector. See x_vector help for decision tree. 
        [x] = x_vector(alpha,l,xmin, spacing, xmax, Plate, loadtype,loadfilemin,loadfilemax);
            if loadtype ==4
            % Calculate the green's function for infinite plate and line
            % load
                [wgreen] = Continuous2D_flex(alpha, D,x);
            elseif loadtype ==5
            % Calculate the green's function for infinite plate and point
            % load
                [wgreen] = Continuous3D_flex(alpha,D,x);
            end
    elseif loadtype == 6
        setTAFIenv(handles, Plate, loadtype);
        
        %Get the loadscale. As of now, it does not changes the load much.
        %Can be adjusted by changing the Default parameter file.
        loadscale = str2double(get(handles.Load,'String'));
        if loadscale == 0 || loadscale == 1
            loadscale = 1;
        end
        % READLOAD3D function reads load grid. If the load grid is already 
        % into TAFI along with other components
        % of the grid, those values are read. Else, it calls another sub-GUI to
        % read the load file.
        [loadgrid, dx,dy,nx,ny] = ReadLoad3D;
        % Create grid's X and Y vectors, which is twice the length of input
        % x and y. This is because, we want to pad the green's function
        % grid to twice the size with actual green's function values.
        x = 0:dx:2*dx*nx;
        y = 0:dy:2*dy*ny;
        
        % Calculate green's function for the grid using point load
        % algorithm
        [wgreen] = Continuous3Dgrid_flex(D, alpha, x, y);
        
        
    end
else
% If the plate geometry selected is semi-infinite, then the loading options
% are 2-D Impulse load and 2-D distributed loads. Following function computes flexural deflection
% for semi-infinite plate with two loading options.
    setTAFIenv(handles, Plate, loadtype);
    % Set titles
    title = 'Gravity and flexure model of Lithosphere for a Discontinous Plate';
    set(handles.Title,'String',title);
    % Read plot spacing
        spacing = str2double(get(handles.spacing,'String'))*1000;
    % Determine X vector. See x_vector help for decision tree.
    if loadtype == 1
        [x] = x_vector(alpha,l,xmin, spacing, xmax, Plate, loadtype,0);
    elseif loadtype == 2
        % Read the 2-D distributed load
        [apload,loadingfnpos] = ReadLoad2D(spacing,handles);
        % Adding a check here to ensure program still runs even if the user
        % hit cancel button while importing load
        if length(apload) == 1 && apload == 0
            loadfilemin = 0;
            loadfilemax = 0;
        else
            loadfilemin = loadingfnpos(1);
            loadfilemax = loadingfnpos(length(apload));           
        end
        [x] = x_vector(alpha,l,xmin, spacing, xmax, Plate, loadtype,loadfilemin,loadfilemax);
    end
    
    
    % Calculate green's function of semi-infinite plate depending on chosen
    % load geometry.
    [wgreen] = Halfspace2D_flex(alpha,D,x);
    

end
% All wgreen's have been calculated in meters.

% ******** CONVOLUTION PART ************
% **************************************
 
% Convolve/Scale the Green's function with load

if (Plate == 1 && (loadtype == 1 || loadtype == 2 || loadtype == 3)) || (Plate ==2 && (loadtype == 1))
    % Correct for sign conventions and variable name. Axisymmetric is
    % upside down in green's function, and periodic is calculated not as
    % green's function. 
    if Plate == 1 && loadtype == 2
        wgreen = -1*wgreen;
    elseif Plate == 1 && loadtype == 3
        wgreen = w;
    end
    % Read the length of flexural deflection vector
    nw = length(wgreen);
    
    % Scale the load. No scaling needed for periodic loading as it is
    % already taken into account while calculating the flexural deflection
    % vector.
    if Plate == 1 && loadtype == 3
        plotx = x2;
    elseif (Plate == 1 && (loadtype == 1 || loadtype ==2)) || (Plate == 2 && loadtype == 1)
        w2 = apload*wgreen;
        w(nw+1:2*nw-1)=w2(2:nw);
        w(1:nw)=fliplr(w2(1:nw));
        plotx(nw+1:2*nw-1) = x(2:nw);
        plotx(1:nw) = fliplr(-x);
    end

elseif (Plate == 1 && (loadtype == 4 || loadtype == 5))||(Plate == 2 && loadtype == 2)
    
    [w,plotx]=  loadconv2D(wgreen, apload,loadtype,spacing,x);
    
elseif (Plate ==1 && loadtype == 6)
    [flexuregrid] = loadconv3D(wgreen, loadscale, loadgrid, nx,ny,dx,dy);
end

% W (flexure) is in meters
        
%% Plot flexural response
if loadtype == 6
    % Use the 3D plot function to plot the flexural surface. If data
    % constraints are available, plot them too. 
    TAFIPlot3D(flexuregrid, loadgrid, 1, hObject, eventdata, handles)
else 
% In this part, the plotflex sets the flexure (w) and distance (x) for use
% in later part of TAFI using getappdata in kilometers.
[flexcolor]= calcindex(w,plotx, xmin,spacing,xmax);
setappdata(0,'flexcolor',flexcolor);

% Shift the position of load by the amount set by load position slider.
% This means that if the load position slider is at 0, then the plot will
% not be shifted at all. 
% Another important thing to note here, is that the data variable in
% shiftloadpos is set to w, which is in meters.
% Furthermore, in case of imported load, the load is shifted during
% convolution while in case of impulse load, the shift is equal to shifting
% the plot.
%figurepanel = 1;
TAFIPlot2D(w,plotx,loadpos,flexcolor,1,handles);
end

%% Find output parameters
calcX = getappdata(0,'calcX');
calcW = getappdata(0,'calcW');
[xcross, xb,wmax,ExpW,wb] = outputparam(calcX, calcW, l,D, g,gamma,alpha,apload, Plate, loadtype, loadpos);

%% Declare flexural parameter variable and covert to string for displaying
global FParam
FParam = num2str(alpha/1000);

% Update the alpha, flexural bulge position, Zero Crossing and 
% Maximum flexural depth values in the output panel.
    %Update the output panel
    set(handles.ZeroCross,'String',num2str((xcross+loadpos)/1000));
    set(handles.Wmax,'String',num2str(wmax));

    setappdata(0,'ZeroCross',xcross/1000);
    setappdata(0,'Wmax',wmax);
    set(handles.flex_exp,'String',num2str(ExpW));
    set(handles.alpha,'String',FParam);
    set(handles.xb,'String',xb);
    set(handles.Wb,'String',num2str(abs(-1*wb/1000)));
    
    
guidata(hObject, handles);