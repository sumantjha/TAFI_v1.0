% IMPORTLOAD MATLAB code for ImportLoad.fig
%   The ImportLoad code allows a user to import 2D distributed load
%   to create 2D flexure models due to distributed load. The loadfile needs
%   to be formatted as (X, P) in two columns.
%  
%   ARGUMENTS
%   All arguments are provided in SI units
%   X = Position of discretized load (Unit - km)
%   P = distributed load magnitude (Unit - N/m^2)
%   
%   Discretization interval can be non uniform and is specified by X
%   positions. However, the load is interpolated back to uniform spacing as
%   specified in TAFI GUI using loadspacinginterp.m function.
%  
%   TAFI - Toolbox for Analysis of Flexural Isostasy
%   Programmed by S. Jha
  
function varargout = ImportLoad(varargin)
% 
% The ImportLoad code allows a user to import their bathymetric, seismic or
% topographic data to the model. These data have to be in format of text or
% excel file with position in first column and values in second column.

% Edit the above text to modify the response to help ImportLoad

% Last Modified by GUIDE v2.5 13-Jan-2016 14:46:30

% Begin initialization code
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImportLoad_OpeningFcn, ...
                   'gui_OutputFcn',  @ImportLoad_OutputFcn, ...
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


% --- Executes just before ImportLoad is made visible.
function ImportLoad_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
% Declare cache for selection, which starts out empty
handles.currSelection = [];
% Update handles structure
guidata(hObject, handles);
table = get(handles.data_table,'Data');



% --- Outputs from this function are returned to the command line.
function varargout = ImportLoad_OutputFcn(hObject, ~, handles) 
varargout{1} = handles.output;
guidata(hObject,handles)



% --- Executes on button press in Open.
function Open_Callback(hObject, eventdata, handles)
[filename, pathname, filterindex] = uigetfile({'*.txt';'*.csv';'*.xlsx';'*.xls'}, 'Select input data file');
% Following check in case the cancel button was pressed in the file import
% dialogue box
if (~isempty(filterindex) && ~isempty(pathname) && ~isempty(filename))
    setappdata(0,'filename',filename);
    setappdata(0,'pathname',pathname);
    setappdata(0,'filterindex',filterindex);
else
    cancel_Callback(hObject, eventdata, handles);
end

if filterindex == 1 || filterindex == 2
    loaddata = fullfile([pathname,filename]);
    data_array = load(loaddata);
     
else
    data_array = xlsread([pathname,filename]);
end
set(handles.data_table,'Data',num2cell(data_array));
guidata(hObject, handles)

setappdata(0,'Position',data_array(:,1));
setappdata(0,'loaddata',data_array(:,2));
guidata(hObject,handles);

% --- Executes when selected cell(s) is changed in data_table.
function data_table_CellSelectionCallback(hObject, ~, handles)
global table
table = get(hObject,'Data');
guidata(hObject,handles);


% --- Executes on button press in Import.
function Import_Callback(hObject, ~, handles)
table = get(handles.data_table,'data');
point = cell2mat(table);
setappdata(0,'loadingfn',point(:,2));
setappdata(0,'loadingfnpos',point(:,1));
setappdata(0,'figureframe',1);
guidata(hObject,handles);
delete(handles.ImportLoad)


% --- Executes when user attempts to close ImportLoad.
function ImportLoad_CloseRequestFcn(~, ~, ~)
%delete(hObject);


% --- Executes on button press in cancel.
function cancel_Callback(~, ~, handles)
setappdata(0,'loadingfn',0);
setappdata(0,'loadingfnpos',0);
delete(handles.ImportLoad)
