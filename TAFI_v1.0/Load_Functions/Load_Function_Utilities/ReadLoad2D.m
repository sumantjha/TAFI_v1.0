% [apload,loadingpos] = ReadLoad2D(spacing,handles)
%
% Checks if a user specified load function is already present.
% If the load function is not present, this function opens up a new app
% to read the user specified, spatially distributed 2D or axisymmetric load
% data and returns to the flexure_callback.m for further processing.Open 
% ImportLoad application if loading function not present. Else, return
% loading function and positions to flexure_callback.
%
% RETURN
% apload = vector of distributed load magnitudes
% loadingpos = vector of distributed load position
% ARGUMENTS
% spacing = discretized interval of Green's function specified through TAFI
% handles = GUI element handles to pass on current values for each element

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha
function [apload,loadingfnpos] = ReadLoad2D(spacing,handles)
        % Read loading function data if it has been imported
        loadingfn = getappdata(0,'loadingfn');
        loadingfnpos = getappdata(0,'loadingfnpos')*1000;
        if isempty(loadingfn)
            % if not imported, import the data
            ad=ImportLoad;
            waitfor(ad);
            % Since, loading function was not imported earlier, and the
            % above ImportLoad now created the loading function, we import
            % them again to use these
            loadingfn = getappdata(0,'loadingfn');
            loadingfnpos = getappdata(0,'loadingfnpos')*1000;
        end
        %Interpolate plot and load spacings based on pre-set criteria. Read
        %more about it in the loadspacinginterp function.
        [apload,loadingfnpos] = loadspacinginterp (loadingfn,loadingfnpos,spacing,handles);