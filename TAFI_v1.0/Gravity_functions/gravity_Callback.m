% gravity_Callback(hObject, eventdata, handles)
% 
% Computes the gravity of a flexed plate using Parker's method.
%
% RETURN
% Gtotal = total gravity due to a flexed plate. The value is passed to the
% TAFIPlot2D function for plotting the gravity.
% ARGUMENTS
% 1. Infill Density - rhoinfill, 
% 2. Mantle Density - rhomantle, 
% 3. Crust Density - rhocrust, 
% 4. 1st Interface depth (depth of infill crustboundary) - cflrdepth, 
% 5. 2nd Interface depth (depth of crust mantle boundary) - crustalT. 
% 6. Flexural deflection profile - w.
%
% The function passes the calculated gravity values, along with the
% position of load and x vector to the plotting function, so as to plot the
% gravity model. 
% The arguments passed to the plotting function are:
% 1. Gtotal - total gravity calculated from the parker code for all
% interfaces, 
% 2. X - the X vector 
% 3. Loadpos - position of the load 4.
% Gravity color - the color of the gravity plot (if not passed, the curves
% will all be plotted in the same color and cause confusion), 
% 5.FigurePanel - reference to the plot panel in which the model will be
% plotted.
%
% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function gravity_Callback(hObject, eventdata, handles)
% Clear any previously stored variable
clear rhomantle rhoinfill rhocrust cflrdepth crustalT loadpos xmin xmax spacing D G g Plate loadtype

% Read the arguments
rhoinfill = str2double(get(handles.rhoi,'String'));
rhomantle = str2double(get(handles.rhom,'String'));
rhocrust = str2double(get(handles.rhocrust,'String'));
cflrdepth = str2double(get(handles.cflrdepth,'String'));
crustalT = str2double(get(handles.crustalT,'String'));

loadpos = str2double(get(handles.loadpos,'String'))*1000;
loadtype = get(handles.loadshapemenu, 'Value');
spacing = str2double(get(handles.spacing,'String'))*1000;

dx = getappdata(0,'spacing');  % get the spacing from the load interpolation. 
 if ~isempty(dx)               % If it exists, then replace the spacing 
    spacing = dx;              % specified in gravity with this.Same is done 
end                            % in flexure callback too
                              
                              
Plate = get(handles.plategeometrymenu, 'Value');

% Read flexural data
if loadtype ~=3
    w = getappdata(0,'calcW')*1000;
else
    w = getappdata(0,'w')*1000;
    Nxplotmax = getappdata(0,'Nxplotmax');
    Nxplotmin = getappdata(0,'Nxplotmin');
end

x = getappdata(0,'x')*1000;
% 

% Read the density structure of the plate
drho = [(rhocrust-rhoinfill),(rhomantle-rhocrust)]; %kg/m^3
z = [cflrdepth,crustalT];   %m


% Use parker's method to calculate gravity
if loadtype == 6
    loadgrid= getappdata(0,'loadgrid');
    if length(loadgrid) ~= 1
        flexuregrid = -1*getappdata(0,'flexuregrid');
        dx = getappdata(0,'dx')*1000;
        dy = getappdata(0,'dy')*1000;
        nx = getappdata(0,'nx');
        ny = getappdata(0,'ny');
         % calculate the mean interface depth of flexural curve
        dm = mean(mean(flexuregrid));
    
        [BG1] = parkg_3D(nx,ny,dx,dy,z(1),drho(1), flexuregrid);
        [BG2] = parkg_3D(nx,ny,dx,dy,((z(2)-z(1))+dm),drho(2), flexuregrid);
        Gtotal = BG1+BG2;
        setappdata(0,'Gtotal',Gtotal);
    else
        Gtotal = 0;
    end
    % Plotting the gravity model.
    TAFIPlot3D(Gtotal,loadgrid, 2, hObject, eventdata, handles)
else

    [BG1] = parkg(Plate, loadtype, w,drho(1),z(1),spacing); 
    [BG2] = parkg(Plate, loadtype, w,drho(2),((z(2)-z(1))+mean(w)),spacing);
    Gtotal = BG1 + BG2;

    % Set total gravity value and color of plot in TAFI for use from any function
    setappdata(0,'Gtotal',Gtotal);

    gravitycolor = rand(1,3);
    setappdata(0,'gravitycolor',gravitycolor)
    if loadtype == 3
        Gtotal = Gtotal(fix(Nxplotmin):fix(Nxplotmax));
    end
    % Plot the gravity in the gravity plot panel
    TAFIPlot2D(Gtotal,x,loadpos,gravitycolor,2,handles);
end

guidata(hObject,handles);