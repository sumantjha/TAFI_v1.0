% ReadLoad3D
%
% Checks if a user specified load grid is already present.
% If the load grid is not present, this function opens up a new app
% to read the user specified, spatially distributed 3D load grid
% and returns to the flexure_callback.m for further processing.Open 
% ImportGrid application if loading function not present. Else, return
% number of X and Y nodes, discretization intervals in X, Y direction
% and distributed load magnitudes to flexure_callback.
%
% RETURN
%   loadgrid, ... = distributed load magnitudes, formatted as vector.
%   dx = discretization interval along X direction 
%   dy = discretization interval along Y direction
%   nx = number of nodes in X direction
%   ny = number of nodes in Y direction
%
% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha
%
function [loadgrid, dx,dy,nx,ny] = ReadLoad3D
% READLOAD3D function reads load grid. If the load grid is already into TAFI along with other components
% of the grid, those values are read. Else, it calls another sub-GUI to
% read the load file. The units of imported parameters are: x - km, y - km,
% load - N.
        loadgrid= getappdata(0,'loadgrid');
        %Grid spacing given in km, change that to meters.
        dx = getappdata(0,'dx')*1000; % Convert km to m
        dy = getappdata(0,'dy')*1000; % Convert km to m.
        
        nx = getappdata(0,'nx');
        ny = getappdata(0,'ny');
        
        if isempty(loadgrid)
            % if not imported, import the data
            ad=GridImport;
            waitfor(ad);
            % Since, loading function was not imported earlier, and the
            % above pointinput now created the loading function, we import
            % them again to use these
            loadgrid = getappdata(0,'loadgrid');
            dx = getappdata(0,'dx')*1000;
            dy = getappdata(0,'dy')*1000;
            nx = getappdata(0,'nx');
            ny = getappdata(0,'ny');
        end