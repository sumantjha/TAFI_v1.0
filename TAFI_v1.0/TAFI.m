function varargout = TAFI(varargin)
% TAFI MATLAB code for TAFI.fig
% This code allows a user to compute the
% flexural response to loading for various plate types. The parameters can
% be adjusted using sliders or input boxes. The responses are displayed in
% form of 2-D plots. The gravity responses for such flexural basin shapes
% are also displayed. This program allows a user to import their own data
% to compare it with the flexure and gravity profile. The data so imported
% can be shifted up and down to aid modeling.

%%TAFI (Toolbox for Analysis of Flexural Isostasy)
% From the Matlab Command Window, execute TAFI.m Requires the
% accompanying GUI template TAFI.fig in the same directory as TAFI.m

% TAFI.m launches a GUI to access the TAFI toolbox. The TAFI GUI
% supports calculation of the deformation and gravity responses to flexural
% loading of the lithosphere. The following flexural models are supported:
%    Elastic plate    unbroken plate under a 2D impulse load Elastic plate
%    unbroken plate under a 3D impulse load Elastic plate    unbroken plate
%    under a 2D periodic load Elastic plate    unbroken plate under 2D
%    distributed load Elastic plate    unbroken plate under 3D distributed
%    load Elastic plate    broken plate under 2D impulse load Elastic plate
%    broken plate under 2D distributed load
%

% As model constraints, users may optionally read from ascii files:
%       gravity data, mGals
%               profiles in rows of {x,gz for 2D; x,y,gz for 3D}
%       deflection data, meters
%               profiles in rows of {x,w for 2D; x,y,w for 3D}

% Deflection for distributed loads is calculated by convolving the point or
% line load response with a distributed load function that is optionally
% provided by the user in an ascii file:
%       2D load profile, N/m; 3D areally distributed load, N/m^2
%               2D profiles as {X,P}. 3D load profiles as (delta X, delta
%               Y, Nx, Ny, P}

% A concise summary of all the variables used in this program is available
% in the help file which can be accessed from About, Program Description of
% the TAFI.

% Prgrammed by -- Sumant Jha,Department of Geosciences, Warner College of
% Natural Resources, Colorado State University, 2016

% Last Modified by GUIDE v2.5 14-Jun-2016 17:14:26

%% Begin initialization code

% User is referred to Matlab help file and website for detailed
% descriptions of initialization code components  and other common
% arguments (e.g. handles, hObjects, createfcn, etc) used throughout this
% code. Basics of building a GUI in matlab and GUI code structures are
% discussed here:
% http://www.mathworks.com/help/matlab/gui-building-basics.html
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TAFI_OpeningFcn, ...
                   'gui_OutputFcn',  @TAFI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%Set working directory, add to current path,clear all warnings, global and
%workspace variables.
currentFolder = pwd;
warning('off','all');
addpath(genpath(currentFolder));
clearvars global;
evalin('base', 'clearvars *');
% End initialization code - DO NOT EDIT
%% Executes just before TAFI is
% made visible. This part of code sets the default variables, curves, GUI
% layout etc. Everything you see, once TAFI starts is initialized here.
% The functions flexure and gravity callbacks plot the initial default
% plots, based on default physical and model parameters.
function TAFI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

%Set and update default parameter values of TAFI
TAFI_defaults(handles);

% Calculate default flexure and gravity model an flexure_Callback is the
% flexure computation and plot function and gravity_Callback is gravity
% (bouguer, free-air) computation and plot function
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);

% axes 1 refer to the flexural plot window, axes 2 refer to gravity plot
% window. Setting default plot window attributes here.
axes(handles.axes1);
grid on;
set(gca, 'GridLineStyle', '-');
grid(gca,'minor');
ylabel('Flexural Deflection', 'FontSize',12,'FontWeight','bold');
axes(handles.axes2);
grid on;
set(gca, 'GridLineStyle', '-');
grid(gca,'minor');

% Allowing user to run 1000000 recursions, as the default matlab recursion
% limit is 500, which is inconvenient and results in warnings.
set(0, 'RecursionLimit', 1000000);


% The primary state of the GUI will not show the data or plot shift panel.
% So, these are being turned off and disabled here. They will be enabled
% and turned on, once the user imports data.
set(handles.Datapanel,'Visible', 'off');
set(handles.plottype,'Value',1,'String',{'Flexure','Gravity'});
set(handles.shiftdata,'Enable', 'off');
set(handles.downdata,'Enable', 'off');
set(handles.updata,'Enable', 'off');
set(handles.rightshift,'Enable','off');
set(handles.leftshift,'Enable','off');
set(handles.PlusZ,'Enable', 'off','Visible', 'off');
set(handles.MinusZ,'Enable', 'off','Visible', 'off');
% The imported gravity or flexure data can be shifted using the data shift
% panel and buttons therein. The user will select which of the data he
% wants to shift by selecting the radio buttons. The default values of
% radio buttons is unselected (0). Once selected the value will change to
% 1. Only one button can be selected at one time.
set(handles.flexurebutton, 'Value',0);
set(handles.gravitybutton,'Value',1);

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line. The
% current command does not returns anything to the command line, but if the
% user needs some variables to be returned to the command line, a simple
% change of replacing handles.output by relevant code will do the trick
function varargout = TAFI_OutputFcn(hObject, ~, handles) 
varargout{1} = handles.output;
guidata(hObject, handles);


% --- Executes on selection change in plategeometrymenu. The Plate geometry
% menu is to be used to select the type of plate geometry being used to
% model the elastic thin plate. Here case 1 = infinite plate geometry and
% case 2 = semi-infinite plate geometry. On selecting one of the cases, the
% variable 'Plate' is updated with a numerical value which is used in later
% functions to identify which geodynamic function to use.

function plategeometrymenu_Callback(hObject, eventdata, handles)
popup_sel_index = get(hObject,'Value');
switch popup_sel_index
    case 1
        Plate = 1;
        set(handles.loadshapemenu,'Value',1,'String',{'2-D Impulse load',...
            '3-D Impulse Load','2-D Periodic load','Import 2-D Distributed load',...
            'Import Distributed Axisymmetric load', 'Import Load Grid' });
        axes(handles.axes1);
        cla reset;
        axes(handles.axes2);
        cla reset;
    case 2
        Plate = 2;
        set(handles.loadshapemenu,'Value', 1,'String',...
            {'2-D Impulse load','Import 2-D Distributed load'});
        axes(handles.axes1);
        cla reset;
        axes(handles.axes2);
        cla reset;
    otherwise
end
setappdata(0,'Plate',Plate);

% Calling the flexure and gravity callbacks again to update the plots based
% on the plate geometry selection.
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function plategeometrymenu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% --- Executes on selection change in loadshapemenu. --- The load shape
% menu allows selection of periodic, 2-D and 3D impulse and distributed
% loads. The drop down menu allows the user to select from case 1 = 2-D
% Impulse
%load, case 2 = 3-D impulse load, case 3 = 2-D sinusoidal load
% case 4 = 2-D distributed load and case 5 = 3-D distributed load and 6 =
% 3-D distributed grid.

% The load shape menu also sets some of the GUI element to respective
% parameters which allows better handling of the shape. For e.g, in case of
% 2D impulse load (case 1) the load magnitude is selected from the load
% magnitude slider with range of 10 to 10^14 N/m. The resulting model can
% be constrained by importing data which is formatted as "position" and
% "values" (e.g. bathymetric data - x, z; bouguer anomaly - x, g). Since,
% the loadshape is a 2D impulse, there is no loading function (used in case
% 4,5,6 - 2D,3D distributed loads and imported loadgrids). So, the rmload
% callback removes any values that are present in loading function to
% preserve memory.

function loadshapemenu_Callback(hObject, eventdata, handles)
Plate = get(handles.plategeometrymenu, 'Value');
popup_sel_index = get(hObject,'Value');
if Plate == 1
    switch popup_sel_index
        case 1
            loadshapemenu = 1;
        case 2
            loadshapemenu = 2;
        case 3
            loadshapemenu = 3;
        case 4
            loadshapemenu = 4;
        case 5
            loadshapemenu = 5;
        case 6
            loadshapemenu = 6;
             
   end
else
    switch popup_sel_index
        case 1
            loadshapemenu = 1;
         case 2
            loadshapemenu = 2;
            
    end
end

% Clear the plots each time load geometry is changed.
axes(handles.axes1);
cla reset;
axes(handles.axes2);
cla reset;


%Set the loadslider limits based on load geometry

loadshape = popup_sel_index;
if ((Plate == 1)&& (loadshapemenu == 1 || loadshapemenu == 2 || loadshapemenu == 3)) || (Plate == 2 && loadshapemenu == 1)
         set(handles.loadslider,'Min',0,'Max',20,'Value',11.699);

else
         set(handles.loadslider,'Min',0,'Max',10,'Value',1); 
end

% Set the load input box to default values based on load geometry
if ((Plate == 1)&& (loadshapemenu == 1 || loadshapemenu == 2)) || (Plate == 2 && loadshapemenu == 1)
         set(handles.Load,'String',(10^11.699));

elseif (Plate == 1 && loadshapemenu == 3)
         set(handles.Load,'String',1);
         set(handles.lambda,'String',125);
else
         set(handles.Load,'String',1); 
end

% Set the spacings to 1, if not periodic
if ((Plate == 1)&& (loadshapemenu ~=3))
         set(handles.spacing,'String',num2str(1)); 
end
    

% Calling the flexure and gravity callbacks again to update the plots based
% on the load shape selection, based on previously selected plate geometry
% selection.
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject,handles);

function loadshapemenu_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);


% --- Executes on Flexural Rigidity (D) slider movement. Allows to change
% the values of flexural rigidity. The slider limits are from 10^19 to
% 10^27 as estimated from Watts, 2001. The slider step is 10^15 which means
% that each time a user clicks on slider the value of flexslider changes by
% 10^15. The values on flexslider are exponents, which are then expressed
% as power to 10 in the display box for D. To enable realtime plotting,
% flexure and gravity callbacks with each shift in slider position. The
% flexure and gravity callbacks will be repeated several times in this
% program to enable the realtime behavior with changes in parameters.

function flexslider_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
value = 10^value;
set(handles.D,'String',value);
% Calculating elastic thickness, which will be updated in the Te box of
% TAFI GUI
DefConstant;
Te = ((12*value*(1-pr^2))/E)^(1/3); 
set(handles.Te,'String',(Te/1000));
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function flexslider_CreateFcn(hObject, ~, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject,handles);


%-----Display box for Flexural Rigidity values-----

function D_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
set(handles.flexslider, 'Value',log10(input));
%checks to see if input is empty. if so, default to zero
if (isempty(input))
     set(hObject,'String','0')
end
% Calculating elastic thickness, which will be updated in the Te box TAFI
% GUI
DefConstant;
Te = ((12*input*(1-pr^2))/E)^(1/3); 
set(handles.Te,'String',(Te/1000));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function D_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


%-----Display box for Minimum X position of the plot. The model can be
%plotted between two positions (minimum and maximum) which are specified
%using the input boxes. The following callback reads the minimum plot
%position.
function xmin_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xmin_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);


% ---- Display box for Maximum X plot position.

function xmax_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function xmax_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);

% --- Executes on slider movement. Lambda values are be used for specifying
% the wavelength of sinusoidal load. The range of lambda slider are 1 -
% 6370 km. The step size of the slider is 0.01 km.

function lambdaslider_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
set(handles.lambda,'String',value);
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lambdaslider_CreateFcn(hObject, ~, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject, handles);

% --- Display box for lambda values as determined from slider position.
% Again, this value too can be edited manually in the same notation as
% xmin.
function lambda_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lambda_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% --- Specifying the load being applied on the model. The magnitude of the
% load for 2D/3D impulse load and 2D sinusoidal loads are specified here.
% For line load, the units will be in N/m, for point load the units will be
% N/m^2. This slider serves dual purpose. In case of 2D/3D impulse loads
% and 2D sinusoidal loads, the slider can be used to specify the load
% magnitude. In case of distributed load the slider changes to scaling
% mode, where the imported load can be scaled within 1-10 range.
function loadslider_Callback(hObject, eventdata, handles)
value = get(hObject,'Value');
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');
if (Plate ==1 && (loadtype ==1 || loadtype == 2 || loadtype ==3))||(Plate == 2 && loadtype ==1)
    set(handles.Load,'String',(10^value));
else
    set(handles.Load,'String',(value));
end

flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function loadslider_CreateFcn(hObject, ~, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject, handles);

% -- Display box for applied load (or load scale) as determined from load
% slider. The load can be fine tuned as well, like xmin and other slider
% inputs, by entering numbers in scientific format.
function Load_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');
if (Plate ==1 && (loadtype ==1 || loadtype == 2 || loadtype ==3))||(Plate == 2 && loadtype ==1)
    set(handles.loadslider, 'Value',log10(input));
else
    set(handles.loadslider,'Value',input);
end
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Load_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% --- Infill density of the model. This is the density of topmost layer of
% the 3 layer model. It can be either sediment or water. The user should
% make sure to use correct density value.Unit is kg/m^3.
function rhoi_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String')); 
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rhoi_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% ---- Crustal density of the model. The density of the 2nd layer. Unit is
% kg/m^3.
function rhocrust_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rhocrust_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% ---- Mantle density of the model. Density of the 3rd layer of the model.
% Unit is kg/m^3.
function rhom_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function rhom_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

%--- Depth of the 1st interface, the boundary between infill and crust
function cflrdepth_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String')); 
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cflrdepth_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

%--- Depth of the 2nd interface, the boundary between crust and mantle
function crustalT_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function crustalT_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% --- Spacing of the plot. For periodic load, the spacing is fixed at
% lamda/100. If the load distribution file is imported the spacing changes
% to whether the load spacing is greater than, equal to or less than the
% spacing specified here.
function spacing_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function spacing_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

%-------Position of the load. The position can only be shifted for point,
%2-D and 3-D loads
% This is different than the plot shift button, explained later in the
% code.
function loadposslider_Callback(hObject, eventdata, handles)
loadposdata = get(hObject,'Value');
set(handles.loadpos,'String',loadposdata);
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function loadposslider_CreateFcn(hObject, ~, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject,handles);

%---- Display box for load position. Can also be edited manually for
%precision
function loadpos_Callback(hObject, eventdata, handles)
loadposdata = str2double(get(hObject,'String'));

if (isempty(loadposdata))
     set(hObject,'String','0')
end
set(handles.loadposslider,'Value',loadposdata);
flexure_Callback(hObject, eventdata, handles);
gravity_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function loadpos_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);



%%
%The title of the figures is updated based on the type of plate geometry
%being used
function Title_Callback(hObject, ~, handles)
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Title_CreateFcn(hObject, ~, handles)
guidata(hObject,handles)

% --- Find and update the exponent of the flexural deflection magnitude for
% display. The current oaxes.m used to enable axis crossing at 0,0 is not
% allowing proper label display.
function flex_exp_Callback(hObject, ~, handles)
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function flex_exp_CreateFcn(hObject, ~, handles)
guidata(hObject,handles)

%The load magnitude slider is dual purpose. For modeling where the load is
%being specified directly from inside TAFI, the slider allows the user to
%choose load between 10 to 10^14. In case of load file being imported the
%slider changes to scale and can be used to modify the imported load by a
%set value between 1 and 10.
% --- Executes during object creation, after setting all properties.
function LoadLabel_CreateFcn(hObject, ~, handles)
guidata(hObject, handles)


% The zero crossing is the point, where the flexural curve crosses y = 0.
% Every iteration of computations updates this value.
function ZeroCross_Callback(hObject, ~, handles)
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function ZeroCross_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% Maximum depth of the flexural curve, updated on each iteration.
function Wmax_Callback(hObject, ~, handles)
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function Wmax_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% Position of the flexural bulge, calculated on the basis of numerical and
% analytical solutions available for the plate geomtery
function xb_Callback(hObject, ~, handles)
guidata(hObject,handles);
% --- Executes during object creation, after setting all properties.
function xb_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% The flexural rigidity is converted to elastic thickness and is updated to
% Te.
function Te_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default input1_editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function Te_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% Alpha is the flexural parameter, being used in the model.
function alpha_Callback(hObject, ~, handles)
guidata(hObject,handles)
% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject,handles);

% % This is the label of -4 alpha to 4 alpha, within which the flexural
% % deflection has been calculated
% function Plotlabel_CreateFcn(hObject, ~, handles)
% guidata(hObject,handles);

% The callback function which updates the peripheral bulge magnitude in
% corresponding box
function Wb_Callback(hObject, ~, handles)
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function Wb_CreateFcn(hObject, ~, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles)

%% At times the user might want to start afresh and clear all plots. 
% This button clears all the plots. The sliders need to be manually reset,
% since I think a user might want to keep sliders at their last position.
% --- Executes on button press in reset.
function reset_Callback(hObject,~, handles)

% resetting flexure plot
axes(handles.axes1);
cla reset;
grid on;
set(gca, 'GridLineStyle', '-');
grid(gca,'minor');

% resetting gravity plot
axes(handles.axes2);
cla reset;
grid on;
set(gca, 'GridLineStyle', '-');
grid(gca,'minor');

%removing all imported 2-D data and clear the data table, if they exist
%Clearing data import table
set(handles.data_table,'Data',[]);

%removing all imported data
if isappdata(0,'loadingfn')==1
    rmappdata(0,'loadingfn');
end
if isappdata(0,'g_constraint')==1
    rmappdata(0,'g_constraint');
end
if isappdata(0,'f_constraint')==1
    rmappdata(0,'f_constraint');
end

% hiding the data shift and plot shift panels again, since all the imported
% data has been removed, so there is no data to shift.
set(handles.Datapanel,'Visible', 'off');
set(handles.shiftdata,'Enable', 'off');
set(handles.downdata,'Enable', 'off');
set(handles.updata,'Enable', 'off');


set(handles.rightshift,'Enable','off');
set(handles.leftshift,'Enable','off');

%bringing back the load input box and slider
set(handles.loadslider,'Enable','on');
set(handles.Load,'Enable','on');

%Reset the flexural exponent display box
set(handles.flex_exp, 'String', []);

guidata(hObject,handles)

%------------------------------------------------------------------------
% The user might want to shift data up or down or the plots to the left and
% right based to match the position with the shape of the curve. These
% buttons and input box allow that. The buttons are acitvated only when the
% flexure or gravity point data are imported. The shift are independent for
% gravity and flexure plots and depend on which radio button is selected by
% the user.

% THE FOLLOWING CODE ALL DEALS WITH SHIFTING DATA. PROBABLY SHOULD BE
% GROUPED TOGETHER IN A STANDALONE FUNCTION
%---------------------------------------------------------------------

% Shifting data to left or right. Check if gravity button is selected.

function gravitybutton_Callback(hObject, ~, handles)
value = get(hObject,'Value');
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');
if value==1
    set(handles.flexurebutton, 'Value',0)
    setappdata(0,'Datashifthandle',1);
    if Plate == 1 && loadtype == 6
        set(handles.PlusZ,'Enable', 'on','Visible', 'on');
        set(handles.MinusZ,'Enable', 'on','Visible', 'on');
    else
        set(handles.PlusZ,'Enable', 'off','Visible', 'off');
        set(handles.MinusZ,'Enable', 'off','Visible', 'off');
    end
end
guidata(hObject,handles)

% ----- Check if flexure button is selected.
function flexurebutton_Callback(hObject, ~, handles)
value = get(hObject,'Value');
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');
if value==1
    set(handles.gravitybutton, 'Value',0)
    setappdata(0,'Datashifthandle',2);
    if Plate == 1 && loadtype == 6
        set(handles.PlusZ,'Enable', 'on','Visible', 'on');
        set(handles.MinusZ,'Enable', 'on','Visible', 'on');
    else
        set(handles.PlusZ,'Enable', 'off','Visible', 'off');
        set(handles.MinusZ,'Enable', 'off','Visible', 'off');
    end
end
guidata(hObject,handles)

% Get the magnitude by which the data shift is desired.
function shiftdata_Callback(hObject, ~, handles)
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);

function shiftdata_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on button press when shifting the plot to right. To shift
% the plot, the program needs to read w, x, Gtotal, f_constraint,
% g_constraint, f_color, g_color, gravitycolor, and flexcolor which were
% determined by previous functions.The amount of shift to right is
% determined by plotshift variable.
function rightshift_Callback(hObject, ~, handles)
datashiftpos = str2double(get(handles.shiftdata,'String'));
Datashifthandle = getappdata(0,'Datashifthandle');
f_constraint = getappdata(0,'f_constraint');
g_constraint = getappdata(0,'g_constraint');

nx = getappdata(0,'nx');
ny = getappdata(0,'ny');
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');

%set default value for data shift radio buttons if empty
if isempty(Datashifthandle)
    Datashifthandle =1;
end
% Shifting gravity data, if the gravity data shift button is checked

if Datashifthandle == 1 && ~isempty(g_constraint)
        % Shift data right
        xconstraint = g_constraint(:,1)+datashiftpos;
        % repopulate gravity data
        g_constraint(:,1) = xconstraint;
        clear xconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'g_constraint',g_constraint);
        % Read and plot current gravity curve and data
        Gtotal = getappdata(0,'Gtotal');
        x = getappdata(0,'x')*1000;
        gravitycolor = getappdata(0,'gravitycolor');

        if Plate == 1 && loadtype == 6
            TAFIPlot3D(Gtotal, 2, handles);
        else
            TAFIPlot2D(Gtotal,x,0,gravitycolor,2, handles); 
        end
end


% Shifting flexure data, if the flexure data shift button is checked

if Datashifthandle==2 && ~isempty(f_constraint)
        % Shift data left
        xconstraint = f_constraint(:,1)+datashiftpos;
        % repopulate gravity data
         f_constraint(:,1) = xconstraint;
        clear xconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'f_constraint',f_constraint);
        % Read and plot current flexure curve and data
        w = getappdata(0,'w')*1000;
        x = getappdata(0,'x')*1000;
        flexurecolor = getappdata(0,'flexcolor');

        if Plate == 1 && loadtype == 6
            flexuregrid = getappdata(0,'flexuregrid');
            TAFIPlot3D(flexuregrid, 1, handles);
            
        else
            TAFIPlot2D(w,x,0,flexurecolor,1, handles);
        end
        
end
guidata(hObject,handles);


% --- Executes on button press when shifting the plot to left. This is
% coded the same way as the right shift function except for the part where
% the plot shift magnitude was added. Here, we substract the plot shift
% magnitude to shift the plot to left.
function leftshift_Callback(hObject, ~, handles)
datashiftpos = str2double(get(handles.shiftdata,'String'));
Datashifthandle = getappdata(0,'Datashifthandle');
f_constraint = getappdata(0,'f_constraint');
g_constraint = getappdata(0,'g_constraint');
nx = getappdata(0,'nx');
ny = getappdata(0,'ny');

Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');

%set default value for data shift radio buttons if empty
if isempty(Datashifthandle)
    Datashifthandle =1;
end

% Shifting gravity data, if the gravity data shift button is checked

if Datashifthandle == 1 && ~isempty(g_constraint)
        % Shift data left
        xconstraint = g_constraint(:,1)-datashiftpos;
        % repopulate gravity data
        g_constraint(:,1) = xconstraint;
        clear xconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'g_constraint',g_constraint);
        % Read and plot current gravity curve and data
        Gtotal = getappdata(0,'Gtotal');
        x = getappdata(0,'x')*1000;
        gravitycolor = getappdata(0,'gravitycolor');

        if Plate == 1 && loadtype == 6
            TAFIPlot3D(Gtotal, 2, handles);
           
        else
             TAFIPlot2D(Gtotal,x,0,gravitycolor,2, handles); 
        end   
end


% Shifting flexure data, if the flexure data shift button is checked

if Datashifthandle==2 && ~isempty(f_constraint)
        % Shift data left
        xconstraint = f_constraint(:,1)-datashiftpos;
        % repopulate gravity data
        f_constraint(:,1) = xconstraint;
        clear xconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'f_constraint',f_constraint);
        % Read and plot current flexure curve and data
        w = getappdata(0,'w')*1000;
        x = getappdata(0,'x')*1000;
        flexurecolor = getappdata(0,'flexcolor');

        if Plate == 1 && loadtype == 6
            flexuregrid = getappdata(0,'flexuregrid');
            TAFIPlot3D(flexuregrid, 1, handles)
        else
            TAFIPlot2D(w,x,0,flexurecolor,1, handles);
        end
end
guidata(hObject,handles);


%% Shifting data up or down. This function is programmed the same way as 
% the plot shift part. The difference being the shift is applied to the
% imported data points. Shift point data up. The function reads the
% variables needed to shift the data point up.
function updata_Callback(hObject, ~, handles)
datashiftpos = str2double(get(handles.shiftdata,'String'));
Datashifthandle = getappdata(0,'Datashifthandle');
f_constraint = getappdata(0,'f_constraint');
g_constraint = getappdata(0,'g_constraint');
nx = getappdata(0,'nx');
ny = getappdata(0,'ny');
Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');

%set default value for data shift radio buttons if empty
if isempty(Datashifthandle)
    Datashifthandle =1;
end
% Shifting gravity data, if the gravity data shift button is checked

if Datashifthandle == 1 && ~isempty(g_constraint)
        % Shift data up
        yconstraint = g_constraint(:,2)+datashiftpos;
        % repopulate gravity data
        g_constraint(:,2) = yconstraint;
        clear yconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'g_constraint',g_constraint);
        % Read and plot current gravity curve and data
        Gtotal = getappdata(0,'Gtotal');
        x = getappdata(0,'x')*1000;
        gravitycolor = getappdata(0,'gravitycolor');

        if Plate == 1 && loadtype == 6
            TAFIPlot3D(Gtotal, 2, handles);
        else
            TAFIPlot2D(Gtotal,x,0,gravitycolor,2, handles); 
        end   

end
% Shifting flexure data, if the flexure data shift button is checked

if Datashifthandle==2 && ~isempty(f_constraint)
        % Shift data up
        yconstraint = f_constraint(:,2)-datashiftpos;
        % repopulate gravity data
         f_constraint(:,2) = yconstraint;
        clear yconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'f_constraint',f_constraint);
        % Read and plot current flexure curve and data
        w = getappdata(0,'w')*1000;
        x = getappdata(0,'x')*1000;
        flexurecolor = getappdata(0,'flexcolor');

        if Plate == 1 && loadtype == 6
            flexuregrid = getappdata(0,'flexuregrid');
            TAFIPlot3D(flexuregrid, 1, handles)
            
        else
            TAFIPlot2D(w,x,0,flexurecolor,1, handles);
        end
end
guidata(hObject, handles);

%Shift point data down. Everything same as shifting up, except that data
%shift position is substracted this time.

function downdata_Callback(hObject, ~, handles)
datashiftpos = str2double(get(handles.shiftdata,'String'));
Datashifthandle = getappdata(0,'Datashifthandle');

g_constraint = getappdata(0,'g_constraint');
f_constraint = getappdata(0,'f_constraint');

nx = getappdata(0,'nx');
ny = getappdata(0,'ny');

Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');

%set default value for data shift radio buttons if empty
if isempty(Datashifthandle)
    Datashifthandle =1;
end

%Shifting gravity data
if Datashifthandle==1 && ~isempty(g_constraint)
        
        %Shift data down
        yconstraint = g_constraint(:,2)-datashiftpos;
        % repopulate gravity data
        g_constraint(:,2) = yconstraint;
        
        %set it up to use with TAFI's plot function
        setappdata(0,'g_constraint',g_constraint);
        clear yconstraint;
         % Read and plot current gravity curve
        Gtotal = getappdata(0,'Gtotal');
        x = getappdata(0,'x')*1000;
        gravitycolor = getappdata(0,'gravitycolor');

        if Plate == 1 && loadtype == 6
            TAFIPlot3D(Gtotal, 2, handles);
            
        else
            TAFIPlot2D(Gtotal,x,0,gravitycolor,2, handles); 
        end           
end
        
%Shifting flexure data
if Datashifthandle==2 && ~isempty(f_constraint)

       % Shift data down
        yconstraint = f_constraint(:,2)+datashiftpos;
        % repopulate the flexure data
        f_constraint(:,2) = yconstraint;
        % set it up to use with TAFI's plot function
        setappdata(0,'f_constraint',f_constraint);
        clear yconstraint;
        % Read and plot current flexure curve and data
        w = getappdata(0,'w')*1000;
        x = getappdata(0,'x')*1000;
        flexurecolor = getappdata(0,'flexcolor');
        if Plate == 1 && loadtype == 6
            flexuregrid = getappdata(0,'flexuregrid');
            TAFIPlot3D(flexuregrid, 1, handles)
            
        else
            TAFIPlot2D(w,x,0,flexurecolor,1, handles);
        end
        
end
guidata(hObject, handles);

% --- Executes on button press in MinusZ.
function MinusZ_Callback(hObject, ~, handles)
datashiftpos = str2double(get(handles.shiftdata,'String'));
Datashifthandle = getappdata(0,'Datashifthandle');
f_constraint = getappdata(0,'f_constraint');
g_constraint = getappdata(0,'g_constraint');
nx = getappdata(0,'nx');
ny = getappdata(0,'ny');

Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');

%set default value for data shift radio buttons if empty
if isempty(Datashifthandle)
    Datashifthandle =1;
end

% Shifting gravity data, if the gravity data shift button is checked

if Datashifthandle == 1 && ~isempty(g_constraint)
        % Shift data down
        zconstraint = g_constraint(:,3)-datashiftpos;
        % repopulate gravity data
        g_constraint(:,3) = zconstraint;
        clear zconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'g_constraint',g_constraint);
        % Read and plot current gravity curve and data
        Gtotal = getappdata(0,'Gtotal');
        TAFIPlot3D(Gtotal, 2, handles);
end


% Shifting flexure data, if the flexure data shift button is checked

if Datashifthandle==2 && ~isempty(f_constraint)
        % Shift data down
        zconstraint = f_constraint(:,3)-datashiftpos;
        % repopulate gravity data
        f_constraint(:,3) = zconstraint;
        clear zconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'f_constraint',f_constraint);
        % Read and plot current flexure curve and data
        flexuregrid = getappdata(0,'flexuregrid');
        TAFIPlot3D(flexuregrid, 1, handles);
        
end
guidata(hObject,handles)


% --- Executes on button press in PlusZ.
function PlusZ_Callback(hObject, ~, handles)
datashiftpos = str2double(get(handles.shiftdata,'String'));
Datashifthandle = getappdata(0,'Datashifthandle');
f_constraint = getappdata(0,'f_constraint');
g_constraint = getappdata(0,'g_constraint');
nx = getappdata(0,'nx');
ny = getappdata(0,'ny');

Plate = get(handles.plategeometrymenu, 'Value');
loadtype = get(handles.loadshapemenu,'Value');

%set default value for data shift radio buttons if empty
if isempty(Datashifthandle)
    Datashifthandle =1;
end

% Shifting gravity data, if the gravity data shift button is checked

if Datashifthandle == 1 && ~isempty(g_constraint)
        % Shift data up
        zconstraint = g_constraint(:,3)+datashiftpos;
        % repopulate gravity data
        g_constraint(:,3) = zconstraint;
        clear zconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'g_constraint',g_constraint);
        % Read and plot current gravity curve and data
        Gtotal = getappdata(0,'Gtotal');
        TAFIPlot3D(Gtotal, 2, handles);
end


% Shifting flexure data, if the flexure data shift button is checked

if Datashifthandle==2 && ~isempty(f_constraint)
        % Shift data up
        zconstraint = f_constraint(:,3)+datashiftpos;
        % repopulate gravity data
        f_constraint(:,3) = zconstraint;
        clear zconstraint;
        %set it up to use with TAFI's plot function
        setappdata(0,'f_constraint',f_constraint);
        % Read and plot current flexure curve and data
        flexuregrid = getappdata(0,'flexuregrid');
        TAFIPlot3D(flexuregrid, 1, handles);
        
end
guidata(hObject,handles)


%% Menu components
% These are menus which appear on the top of TAFI. A user can use these
% menu functions to save data, export and edit figures, change default
% parameters and exit the program.
% -------------------------------------------------------------------- File
% menu - contains several sub menus.
function file_Callback(hObject, ~, handles)
guidata(hObject,handles);

% -------------------------------------------------------------------- Use
% this to change the default parameters.
function Ch_def_Callback(hObject, ~, handles)
guidata(hObject,handles);

% Changes physical constants used like the young's modulus, poisson's
% ratio, acceleration due to gravity, Gravitational constant,
% etc.---------------------------------------------------------------
function Phys_const_Callback(hObject, ~, handles)
edit DefConstant
guidata(hObject,handles)

% Changes TAFI default parameters like values and ranges of sliders, and
% edit boxes. BE VERY CAREFUL CHANGING THESE. PREFERABLY DO NOT CHANGE
% THESE AT ALL.
function TAFI_def_Callback(hObject, ~, handles)
edit TAFI_defaults
guidata(hObject,handles)

%Restore program defaults that was originally put in TAFI
function res_default_Callback(hObject, ~, handles)
copyfile ('./GUI_functions/Default_backups/DefConstant_bkp.m','./Geodynamic_functions/DefConstant.m');
copyfile ('./GUI_functions/Default_backups/TAFI_defaults_bkp.m','./GUI_functions/TAFI_defaults.m');
guidata(hObject, handles)

% -------------------------------------------------------------------- TAFI
% help manual and citation information can be found from the about menu.
function about_Callback(hObject, ~, handles)
guidata(hObject,handles);


% -------------------------------------------------------------------- Help
% manual
function pdesc_Callback(hObject, ~, handles)
open('Toolbox for Analysis of Flexural Isostasy (TAFI).pdf');
guidata(hObject,handles);

% --------------------------------------------------------------------
% Citation information
function cite_Callback(hObject, ~, handles)
guidata(hObject,handles);

% --------------------------------------------------------------------
% Export menu
function export_Callback(hObject, ~, handles)
 guidata(hObject,handles);
 
 
% --------------------------------------------------------------------
% Export flexure profile data. Results in creation of a text file in the
% current directory called FlexureProfile. The file has two columns W
% (deflection) and X (position).
function exflxdata_Callback(hObject, ~, handles)
 [file,path] = uiputfile('FlexureProfile.txt','Export Flexure Profile');
 loadtype = get(handles.loadshapemenu, 'Value');
 if loadtype ~= 6
    x = getappdata(0,'x');
    w = getappdata(0,'w');
    % Read plot position data
    Nxplotmax = getappdata(0,'Nxplotmax');
    Nxplotmin = getappdata(0,'Nxplotmin');
    matrix = [x(fix(Nxplotmin):fix(Nxplotmax))',w(fix(Nxplotmin):fix(Nxplotmax))'];
 else
     flexuregrid = getappdata(0,'flexuregrid');
     dx = getappdata(0,'dx');
     dy = getappdata(0,'dy');
     
     nx = getappdata(0,'nx');
     ny = getappdata(0,'ny');
     [nfx,nfy] = size(flexuregrid(1:nx,2*ny:4*ny));
     flexurevec = reshape((flexuregrid(1:nx,2*ny:4*ny))',[nfx*nfy,1]);
     matrix = vertcat(dx,dy,nfx,nfy,flexurevec);
 end
 if file ~=0
    dlmwrite([path,file],matrix); 
 end
 guidata(hObject,handles);

% --------------------------------------------------------------------
% Export gravity profile data. Results in creation of a text file in the
% current directory called GravityProfile. The file has two columns Gtotal
% (gravity in mGal) and X (position).
function expgrvdata_Callback(hObject, ~, handles)

 [file,path] = uiputfile('GravityProfile.txt','Export Bouguer Anomaly model');
 loadtype = get(handles.loadshapemenu, 'Value');
Gtotal = getappdata(0,'Gtotal');
 if loadtype ~= 6
    x = getappdata(0,'x');
    % Read plot position data
    Nxplotmax = getappdata(0,'Nxplotmax');
    Nxplotmin = getappdata(0,'Nxplotmin');

    matrix = [x(fix(Nxplotmin):fix(Nxplotmax))',Gtotal'];
 else
     dx = getappdata(0,'dx');
     dy = getappdata(0,'dy');
     
     nx = getappdata(0,'nx');
     ny = getappdata(0,'ny');
     [nfx,nfy] = size(Gtotal(1:nx,2*ny:4*ny));
     Grav_vec = reshape((Gtotal(1:nx,2*ny:4*ny))',[nfx*nfy,1]);
     matrix = vertcat(dx,dy,nfx,nfy,Grav_vec);
 end
 if file ~=0
    dlmwrite([path,file],matrix); 
 end
 guidata(hObject,handles);
 

% -------------------------------------------------------------------- On
% On the fly exporting plot figures as png files in current directory
function expfig_Callback(hObject, ~, handles)
fig1 = handles.axes1;
fig2 = handles.axes2;
export_fig(fig1, 'Flexure.png');
export_fig(fig2,'Gravity.png');
msgbox('Figures Saved in Current Directory', 'Done !!');
guidata(hObject,handles);

% -------------------------------------------------------------------- Edit
% figure menu
function edfig_Callback(hObject, ~, handles)
guidata(hObject,handles)

% -------------------------------------------------------------------- The
% function allows a user to open the gravity plot in a new matlab figure
% window and use matlab's native tools to edit plot components.
function ed_grav_Callback(hObject, ~, handles)
fig=figure;ax=handles.axes2;clf;
new_handle=copyobj(ax,fig);
set(gca,'ActivePositionProperty','outerposition')
set(gca,'Units','normalized')
set(gca,'OuterPosition',[0 0 1 1])
set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
guidata(hObject,handles);


% -------------------------------------------------------------------- The
% function allows a user to open the flexure plot in a new matlab figure
% window and use matlab's native tools to edit plot components.
function ed_flex_Callback(hObject, ~, handles)
fig=figure;ax=handles.axes1;clf;
new_handle=copyobj(ax,fig);
set(gca,'ActivePositionProperty','outerposition')
set(gca,'Units','normalized')
set(gca,'OuterPosition',[0 0 1 1])
set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
guidata(hObject,handles);

% -------------------------------------------------------------------- The
% corner cross icon is disabled and the program can be closed from using
% only the exit option.
function exit_Callback(hObject,eventdata,handles)
reset_Callback(hObject,eventdata, handles);
rmload_Callback(hObject, eventdata, handles)
loadgrid = [];
closereq;


% -------------------------------------------------------------------- To
% export the parameter data used in elastic thin plate model
function export_param_Callback(hObject, ~, handles)
guidata(hObject, handles);


% --------------------------------------------------------------------
%The input data can be exported from this function - flexural rigidity,
%Load, Xmin, Xmax, Position of load, Infill density, Crustal density,
%mantle density, depth to infill crust interface and depth to crust mantle
%interface,
function exp_inputs_Callback(hObject, ~, handles)
[file,path] = uiputfile('Input_Parameters.txt','Export Input Parameters Used');
 D = getappdata(0,'D');
 Load = getappdata(0,'Load');
 Xmin = getappdata(0,'Xmin');
 Xmax = getappdata(0,'Xmax');
 Loadpos = getappdata(0,'Loadpos');
 Spacing = getappdata(0,'Spacing');
 Infill_Den = getappdata(0,'Infill_Den');
 C_den = getappdata(0,'C_den');
 M_den = getappdata(0,'M_den');
 First_intdep = getappdata(0,'First_intdep');
 Sec_intdep = getappdata(0,'Sec_intdep');
 matrix2 = [D,Load,Xmin,Xmax,Loadpos,Spacing,Infill_Den,C_den,M_den,First_intdep,Sec_intdep];
 if file ~= 0
    dlmwrite([path,file],matrix2);
 end
guidata(hObject, handles);



% -------------------------------------------------------------------- The
% output parameters can be exported from this function, Output parameters
% are - flexural parameter (Flex_param), flexural bulge position (xb), Zero
% crossing position and maximum flexure depth
function exp_outputs_Callback(hObject, ~, handles)
[file,path] = uiputfile('Output_Parameters.txt','Export Outputs');
 Flex_param = getappdata(0,'Flex_param');
 xb = getappdata(0,'Xb');
 ZeroCross = getappdata(0,'ZeroCross');
 Wmax = getappdata(0,'Wmax');
 matrix2 = [Flex_param,xb,ZeroCross,Wmax];
 if file ~=0
    dlmwrite([path,file],matrix2);
 end
 guidata(hObject, handles);

%---------------------------------------------------------------------------
% Using a Key press function which allows the user to modify both
% gravitybutton and flexurebutton plots by pressing enter key. However, the
% main interface needs to be highlighted for this, instead of individual
% components. Working on improving this.

function Flexure_Main_KeyPressFcn(hObject, eventdata, handles)
currChar = get(handles.Flexure_Main,'CurrentCharacter');
if isequal(currChar, char(13))
    flexure_Callback(hObject, eventdata, handles);
    gravity_Callback(hObject, eventdata, handles);
end


%% The following callbacks are tied to the buttons which clear the plot or the plot data
% from the plot figure. Please note that the data is still there in TAFI,
% just that it is not being plotted. These are different from the reset
% button as these do not clear the loaded data.

% --- Executes on button press in cCurve. The plot curves (not the data)
% are removed. The user can resume curve fitting from their last inputs
function cCurve_Callback(hObject, ~, handles)

%Read gravity and flexure data
g_constraint = getappdata(0,'g_constraint');
f_constraint = getappdata(0,'f_constraint');
%Read the color in which gravity and flexure data were plotted
g_color = getappdata(0,'g_color');
f_color = getappdata(0,'f_color');

% Make data shift panel visible and ready to go.
set(handles.Datapanel,'Visible', 'on');
set(handles.shiftdata,'Enable', 'on');
set(handles.downdata,'Enable', 'on');
set(handles.updata,'Enable', 'on');
set(handles.leftshift,'Enable', 'on');
set(handles.rightshift,'Enable', 'on');

% Clear the gravity plot and plot the gravity data, so that it will appear
% that the gravity line plot was removed.
if ~isempty(g_constraint)
    axes(handles.axes2)
    cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    plot(g_constraint(:,1),g_constraint(:,2),'.','Color',g_color);
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    ylabel('Gravity (mGal)');
    xlabel('Distance (km)');
    
elseif isempty(g_constraint)
    axes(handles.axes2)
    cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    ylabel('Gravity (mGal)');
    xlabel('Distance (km)');
    
end

% Clear the flexure plot and plot the flexure data, so that it will appear
% that the flexure line plot was removed.
if ~isempty(f_constraint)
    axes(handles.axes1)
    cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    plot(f_constraint(:,1),f_constraint(:,2),'.','Color',f_color,'markersize',10);
    set(gca,'Ydir','reverse');
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    ylabel('Flexural Deflection (km)');
    xlabel('Distance (km)');
elseif isempty(f_constraint)
    axes(handles.axes1)
    cla reset
    grid on
    hold on
    ylabel('Flexural Deflection (km)');
    xlabel('Distance (km)');
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    
end

guidata(hObject,handles);
 
% The plot data are removed on calling cData (short for clear Data). The
% user can import fresh or new data sets now
% 
% --- Executes on button press in cData.
function cData_Callback(hObject, eventdata, handles)
% clear everything from the flexure plot window.
    axes(handles.axes1)
    cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    % plot the flexure curve back
    flexure_Callback(hObject, eventdata,handles)
    set(gca,'Ydir','reverse');
    ylabel('Flexural Deflection (km)');
    xlabel('Distance (km)');
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    f_constraint = getappdata(0,'f_constraint');
    if ~isempty(f_constraint)
        f_constraint = [];
        setappdata(0,'f_constraint',f_constraint)
    end
% Clear everything from the gravity plot window.
    axes(handles.axes2)
    cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    %plot the gravity curve back
    gravity_Callback(hObject, eventdata,handles);
    ylabel('Gravity (mGal)');
    xlabel('Distance (km)');
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    g_constraint = getappdata(0,'g_constraint');
    if ~isempty(g_constraint)
        g_constraint = [];
        setappdata(0,'g_constraint', g_constraint);
    end
    % Since the data was removed from the plots, they can not be shifted
    % anywhere and hence the data shift and plot shift buttons are
    % disabled.
    set(handles.Datapanel,'Visible', 'off');
    set(handles.shiftdata,'Enable', 'off');
    set(handles.downdata,'Enable', 'off');
    set(handles.updata,'Enable', 'off');

    set(handles.rightshift,'Enable','off');
    set(handles.leftshift,'Enable','off');
    
    % Also remove the data in the data import table
    set(handles.data_table,'Data',[]);
guidata(hObject, handles);


% --- Executes when user attempts to close TAFI. On pressing the cross
% button on the top corner, all variables are erased and the plots are
% reset, to make sure no global variables remain in the active matlab
% workspace.
function TAFI_CloseRequestFcn(hObject, eventdata, handles)
reset_Callback(hObject,eventdata, handles);
rmload_Callback(hObject, eventdata, handles);
delete(hObject);


%%%%%%%%%%%% TO IMPORT FLEXURE AND GRAVITY DATA%%%%%%%%%%%%%%%%%%%%%
% --- Executes on selection change in plottype.
function plottype_Callback(hObject, ~, handles)
popup_sel_index = get(hObject,'Value');
switch popup_sel_index
    case 1
        plottype = 1;
    case 2
        plottype = 2;

    otherwise
end
setappdata(0,'plottype',plottype);
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function plottype_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles)

% --- Executes on button press in Opendatafile.
function Opendatafile_Callback(hObject, ~, handles)
[filename, pathname, filterindex] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.xls'}, 'Select input data file');
setappdata(0,'filename',filename);
setappdata(0,'pathname',pathname);
setappdata(0,'filterindex',filterindex);
plottype = getappdata(0,'plottype');

if filterindex == 1 || filterindex == 2
    loaddata = fullfile([pathname,filename]);
    data_array = load(loaddata);
else
    data_array = xlsread([pathname,filename]);
end
set(handles.data_table,'Data',num2cell(data_array));
guidata(hObject, handles)



% --- Executes when selected cell(s) is changed in data_table.
function data_table_CellSelectionCallback(hObject, ~, handles)
global table
table = get(hObject,'Data');

guidata(hObject,handles)

%% Import data button press allows user to import their own point data. 
% The user needs to select whether the data are gravitybutton or
% flexurebutton (seismic, bathymetric, topographic). Unless that option has
% been specified, the import window will not close. --- Executes on button
% press in importdata.
function importdata_Callback(hObject, ~, handles)
loadtype = get(handles.loadshapemenu,'Value');
% this function imports 2-D data that are needed (bathymetry, gravity,
% topographic, load distribution) to constrain the flexure model. The data
% and plot manipulation panels which were disabled earlier are now enabled,
% as the user will need to interact with these panels now. the units for
% imported file are in km, km/mGal (position, values).
set(handles.Datapanel,'Visible', 'on');
set(handles.shiftdata,'Enable', 'on');
set(handles.downdata,'Enable', 'on');
set(handles.updata,'Enable', 'on');
set(handles.rightshift,'Enable','on');
set(handles.leftshift,'Enable','on');
loadtype = get(handles.loadshapemenu,'Value');
table = get(handles.data_table,'data');
point = cell2mat(table);
plottype = getappdata(0,'plottype');
if isempty(plottype)
    plottype = 1;
end
if~isempty(point)
    if plottype==1
        axes(handles.axes1)
        hold on
        flexurecolor = rand(1,3);
            if loadtype == 6
            plot3(point(:,1),point(:,2),point(:,3),'.','markersize',10,'Color',flexurecolor);    
            else
            plot(point(:,1),point(:,2),'.','markersize',10,'Color',flexurecolor);
            set(gca,'Ydir','reverse');
            end
            set(gca,'XaxisLocation','origin');
            set(gca,'YaxisLocation','origin');
            setappdata(0,'f_color',flexurecolor);
            setappdata(0,'f_constraint',point);
    else
        axes(handles.axes2)
        hold on
            gravitycolor = rand(1,3);
            if loadtype == 6
            plot3(point(:,1),point(:,2),point(:,3),'.','markersize',10,'Color',gravitycolor);    
            else
            plot(point(:,1),point(:,2),'.','markersize',10,'Color',gravitycolor);
            end
            %set(gca,'Ydir','reverse');
            set(gca,'XaxisLocation','origin');
            set(gca,'YaxisLocation','origin');
            setappdata(0,'g_color',gravitycolor)
            setappdata(0,'g_constraint',point);
    end
end
guidata(hObject,handles)

%%%%%%%%END OF IMPORT FLEXURE AND GRAVITY DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% PLOT IMPORTED LOAD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting the load helps in visualizing and if needed, correcting the load
% geometry for desired flexural deflection calculations

% Create a function for Utility contextual menu.
function utils_Callback(hObject, ~, handles)
guidata(hObject,handles)

% Plot the imported load
function PlotImLoad_Callback(hObject, ~, handles)
loadtype = get(handles.loadshapemenu,'Value');
if loadtype == 4 || loadtype == 5
    loaddata = getappdata(0,'loaddata');
    figure; stem(loaddata); title('Plot of Imported 2-D distributed load file'); xlabel('Position (km)'); ylabel('Load');
elseif loadtype == 6
    LoadGrid = getappdata(0,'NewLoadGrid');
    figure; surf(LoadGrid); shading interp;
    title('Plot of Imported 3-D distributed load grid'); xlabel('Position (km)'); ylabel('Position (km)'); zlabel('Load');
end
guidata(hObject,handles)
