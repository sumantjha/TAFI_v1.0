%rmload_Callback(hObject, ~, handles)
%
% Removes the imported 3D load grid.
% At times, the user will need to remove the imported load and start
% modeling again using different load. rmload function removes any imported
% load into TAFI and clears the plotted flexure and gravity models.
% 
% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

% --------------------------------------------------------------------
function rmload_Callback(hObject, eventdata, handles)
setappdata(0,'loadgrid',[]);
setappdata(0,'dx',[]);
setappdata(0,'dy',[]);
setappdata(0,'nx',[]);
setappdata(0,'ny',[]);
axes(handles.axes1)
cla reset;
axes(handles.axes2)
cla reset;
guidata(hObject,handles)
