% [apload, loadingpos] = loadspacinginterp (loadingfn,loadingpos,spacing,handles)
%
% Interpolates the user specified distributed load to user specified
% discretization interval.
%
% RETURN
%  apload = Interpolated discretized load
%  spacing = Discretization interval, depending on if user specified
%  interval is less than, more than or equal to the discretization interval specified
%  in the load file. Lesser of the two is returned.
% ARGUMENTS
%  loadingfn = User specified discretized load
%  delx = discretization interval of the load file
%  spacing = discretization interval of Green's function specified through
%  TAFI's main interface
%  handles = GUI element handles needed to read load scaling paramter. Can
%  be used with other elements, when needed.
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [apload, loadingfnpos] = loadspacinginterp (loadingfn,loadingfnpos,spacing,handles)
%The imported load magnitudes are always interpolated to the discretization
%interval specified through TAFI, which was used in calculating Green's
%function.

% Find the length of loading function
nload = length(loadingfnpos);

%If the loadingfn is not empty and not 0 (known by checking of nload is 1)
% interpolate. Otherwise, cancel button was
% pressed in importload, which means no loading.
   
    if (~isempty(loadingfnpos) && ~isempty(loadingfn) && (nload ~=1))
         
        % Read the scaling magnitude for distributed load
        loadscale = str2double(get(handles.Load,'String'));
        % If the scaling magnitude is 0 or 1, the user does not want to scale
        % the imported load. If the scaling magnitude is anything between 0 and
        % 1 or between 1 and 10, then scale the imported load with scaling
        % magnitude.
            if loadscale == 0 || loadscale == 1
                apload = loadingfn;
            else
                apload = loadscale*loadingfn;
            end
    
            % Interpolate the imported load to Green's function discretization
            % interval
            % Create interpolation vector discretized at spacing used for
            % calculating Green's function.
            yload = loadingfnpos(1):spacing:loadingfnpos(nload);
            % Use matlab's "interp1" to interpolate
            newloadfn = interp1(loadingfnpos,apload,yload);
            newloadfnpos = interp1(loadingfnpos,loadingfnpos,yload);
            % if the new load function returns "NaN", change it to 0.
            newloadfn(isnan(newloadfn))=0;
            newloadfn(isnan(newloadfnpos)) = 0;
            % Return new load function to main load variable "apload"
            apload = newloadfn';
            loadingfnpos = newloadfnpos';
    else
        apload = 0;
        loadingfnpos = 0;
    end