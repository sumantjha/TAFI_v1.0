% GRIDIMPORT MATLAB code for GridImport.fig
% The GridImport code allows a user to import distributed load in grid
% format to create 3D flexure models. The grid needs to be reformatted as
% (nx;ny;dx;dy; P1;P2;....), in a single column.
%
% ARGUMENTS
% All arguments are provided in SI units
% nx = number of nodes in X direction
% ny = number of nodes in Y direction
% dx = discretization interval along X direction 
% dy = discretization interval along Y direction
% P1, P2, ... = distributed load magnitude
% 
% Discretization interval have to be uniform in X and Y directions.
% Currently TAFI does not allows for non-uniform discretization intervals.
%
% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function varargout = GridImport(varargin)
% GRIDIMPORT MATLAB code for GridImport.fig
% The GridImport code allows a user to import their bathymetric, seismic or
% topographic data to the model. These data have to be in format of text or
% excel file with position in first column and values in second column.

% Edit the above text to modify the response to help GridImport

% Last Modified by GUIDE v2.5 20-June-2016 11:38:54

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GridImport_OpeningFcn, ...
                   'gui_OutputFcn',  @GridImport_OutputFcn, ...
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
% End initialization code


% --- Executes just before GridImport is made visible.
function GridImport_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
% Declare cache for selection, which starts out empty
handles.currSelection = [];
% Update handles structure
guidata(hObject, handles);
table = get(handles.data_table,'Data');



% --- Outputs from this function are returned to the command line.
function varargout = GridImport_OutputFcn(hObject, ~, handles) 
varargout{1} = handles.output;
guidata(hObject,handles)


% --- Executes on button press in Open.
function Open_Callback(hObject, ~, handles)
[filename, pathname, filterindex] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.xls'}, 'Select input data file');
    if (~isempty(filterindex) && ~isempty(pathname) && ~isempty(filename))
        setappdata(0,'filename',filename);
        setappdata(0,'pathname',pathname);
        setappdata(0,'filterindex',filterindex);
    else
        cancel_Callback(hObject, eventdata, handles);
    end

    if filterindex == 3 || filterindex == 4
        pl = xlsread([pathname,filename]);
    else
     loaddata = fullfile([pathname,filename]);
        pl = load(loaddata);
    end
    delx = pl(1);
    dely = pl(2);
    nx = pl(3);
    ny = pl(4);
    data_array(1,1) = delx;data_array(2,1) = dely;data_array(3,1) = nx; data_array(4,1) = ny;
    for i = 5:(length(pl))
            data_array(i,1)= pl(i);
    end 
set(handles.data_table,'Data',num2cell(data_array));

setappdata(0,'dx',delx);
setappdata(0,'dy',dely);
setappdata(0,'nx',nx);
setappdata(0,'ny',ny);

guidata(hObject,handles);

% --- Executes when selected cell(s) is changed in data_table.
function data_table_CellSelectionCallback(hObject, ~, handles)
global table
table = get(hObject,'Data');

guidata(hObject,handles);


% --- Executes on button press in Import.
function Import_Callback(hObject, ~, handles)
table = get(handles.data_table,'data');
loadgrid = cell2mat(table);
setappdata(0,'loadgrid',loadgrid(5:length(loadgrid)));
setappdata(0,'figureframe',1);
guidata(hObject,handles);
delete(handles.GridImport)


% --- Executes when user attempts to close GridImport.
function GridImport_CloseRequestFcn(~, ~, ~)
%delete(hObject);


% --- Executes on button press in cancel.
function cancel_Callback(~, ~, handles)
setappdata(0,'dx',1);
setappdata(0,'dy',1);
setappdata(0,'nx',1);
setappdata(0,'ny',1);
setappdata(0,'loadgrid',0);
delete(handles.GridImport)
