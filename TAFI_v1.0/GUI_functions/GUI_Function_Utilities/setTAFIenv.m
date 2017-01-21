% setTAFIenv (handles)
%
% setTAFIenv function sets the TAFI gui environment based on selected Plate
% and load geometries.
%
% GUI elements being set:
% Plotparameterpanel: Disabled for grid load geometry, enabled for all else
% Plus/Minus Z : Data shift buttons in Z. Enabled only for grid load
% Column name, Data table: X,Y,Z for grid load
% Loadlabel: Label of load slider - scale for grid load
% Harmonic off/on: Enable/Disable harmonic GUI components of TAFI for
% periodic loads

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha
function setTAFIenv(handles, Plate, loadtype)
if Plate == 1
    if loadtype == 1
        setappdata(0,'loadingfn',[]);
        setappdata(0,'loadingfnpos',[]);
        set(handles.plotparameterpanel, 'Visible', 'on');
        set(handles.PlusZ,'Enable', 'off','Visible', 'off');
        set(handles.MinusZ,'Enable', 'off','Visible', 'off');
        set(handles.data_table,'ColumnName',{'Position';'Values'});
        set(handles.LoadLabel,'String','Load Magnitude (N)');
        set(handles.flexbulgelab,'Enable','on');
        set(handles.perbulgelab,'Enable','on');
        set(handles.zerocrosslab,'Enable','on','Foreground',[0 0 0]);
        set(handles.xb,'Enable','on');
        set(handles.ZeroCross,'Enable','on');
        set(handles.Wb,'Enable','on');
        clear w x
        % the load geometry selected here is of line load. Switch off wavelength
        % slider as that was for harmonic load and switch on load position slider
        harmonicoff(handles);
    elseif loadtype == 2
        setappdata(0,'loadingfn',[]);
        setappdata(0,'loadingfnpos',[]);
        set(handles.plotparameterpanel, 'Visible', 'on');
        set(handles.PlusZ,'Enable', 'off','Visible', 'off');
        set(handles.MinusZ,'Enable', 'off','Visible', 'off');
        set(handles.data_table,'ColumnName',{'Position';'Values'});
        set(handles.LoadLabel,'String','Load Magnitude (N)');
        set(handles.flexbulgelab,'Enable','on');
        set(handles.perbulgelab,'Enable','on');
        set(handles.zerocrosslab,'Enable','on','Foreground',[1 0 0]);
        set(handles.xb,'Enable','on');
        set(handles.ZeroCross,'Enable','on');
        set(handles.Wb,'Enable','on');
        clear w x
        % the load geometry selected here is of point load. Switch off wavelength
        % slider as that was for harmonic load and switch on load position slider
        harmonicoff(handles);
    elseif loadtype == 3
        setappdata(0,'loadingfn',[]);
        setappdata(0,'loadingfnpos',[]);
        set(handles.plotparameterpanel, 'Visible', 'on');
        set(handles.PlusZ,'Enable', 'off','Visible', 'off');
        set(handles.MinusZ,'Enable', 'off','Visible', 'off');
        set(handles.data_table,'ColumnName',{'Position';'Values'});
        set(handles.LoadLabel,'String','Load Magnitude (N)');
        % Make the harmonic loading components visible and turn off the
        % load position slider
        harmonicon(handles);
        set(handles.flexbulgelab,'Enable','on');
        set(handles.perbulgelab,'Enable','on');
        set(handles.zerocrosslab,'Enable','on','Foreground',[0 0 0]);
        set(handles.xb,'Enable','on');
        set(handles.ZeroCross,'Enable','on');
        set(handles.Wb,'Enable','on');
    elseif loadtype == 4 || loadtype ==5
        set(handles.plotparameterpanel, 'Visible', 'on');
        set(handles.PlusZ,'Enable', 'off','Visible', 'off');
        set(handles.MinusZ,'Enable', 'off','Visible', 'off');
        set(handles.data_table,'ColumnName',{'Position';'Values'});
        set(handles.LoadLabel,'String','Scale Load Magnitude by');
        % the load geometry selected here is of point load. Switch off wavelength
        % slider as that was for harmonic load and switch on load position slider
        harmonicoff(handles);
        set(handles.flexbulgelab,'Enable','on');
        set(handles.perbulgelab,'Enable','on');
        set(handles.zerocrosslab,'Enable','on','Foreground',[1 0 0]);
        set(handles.xb,'Enable','on');
        set(handles.ZeroCross,'Enable','on');
        set(handles.Wb,'Enable','on');
    elseif loadtype == 6
        set(handles.plotparameterpanel, 'Visible', 'off');
        set(handles.PlusZ,'Enable', 'on','Visible', 'on');
        set(handles.MinusZ,'Enable', 'on','Visible', 'on');
        set(handles.data_table,'ColumnName',{'X';'Y';'Values'});
        set(handles.LoadLabel,'String','Scale Load Magnitude by');
        % the load geometry selected here is of point load. Switch off wavelength
        % slider as that was for harmonic load and switch on load position slider
        harmonicoff(handles);
        set(handles.loadposslider,'Enable','off');
        set(handles.loadpos,'Enable','off');
        set(handles.flexbulgelab,'Enable','off');
        set(handles.perbulgelab,'Enable','off');
        set(handles.zerocrosslab,'Enable','off','Foreground',[1 0 0]);
        set(handles.xb,'Enable','off');
        set(handles.ZeroCross,'Enable','off');
        set(handles.Wb,'Enable','off');
else
% If the plate geometry selected is semi-infinite, then the loading options
% are 2-D Impulse load and 2-D distributed loads. Following function computes flexural deflection
% for semi-infinite plate with two loading options.
    %clear w x;
    set(handles.plotparameterpanel, 'Visible', 'on');
    set(handles.PlusZ,'Enable', 'off','Visible', 'off');
    set(handles.MinusZ,'Enable', 'off','Visible', 'off');
    set(handles.LoadLabel,'String','Load Magnitude (N)');
    %Set harmonic components of toolbox off.
    harmonicoff(handles);
    set(handles.flexbulgelab,'Enable','on');
    set(handles.perbulgelab,'Enable','on');
    set(handles.zerocrosslab,'Enable','on','Foreground',[0 0 0]);
    set(handles.xb,'Enable','on');
    set(handles.ZeroCross,'Enable','on');
    set(handles.Wb,'Enable','on');
    if loadtype == 1
        setappdata(0,'loadingfn',[]);
        setappdata(0,'loadingfnpos',[]);
    elseif loadtype == 2
        set(handles.LoadLabel,'String','Scale Load Magnitude by');
    end
    end
end
        