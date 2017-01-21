% [x] = x_vector(alpha,l,xmin, spacing, xmax, plate, loadtype,loadfilemin,loadfilemax)
%
% This function returns the x vector for use in Green's function. The
% function reads in several position parameters and decides which of them
% to use based on the conditions used in this function. The x vector always
% starts from 0. 
% 
% RETURN
% x = vector of positions (Unit - meter)
% ARGUMENTS
% alpha = flexural parameter (Unit - meter)
% l = wavelength of sinusoidal load (Unit - meter)
% xmin = minimum of plot position specified by user (Unit - meter)
% spacing = the discretization interval specified by user (Unit - meter)
% xmax = maximum of plot position specified by user (Unit - meter)
% Plate = type of plate geometry selected (No units. See flexure Callback
% function for description)
% loadtype = type of load geometry selected (No units. See flexure Callback
% function for description)
% loadfilemin = minimum position specified in imported load file (specified
% here for future use. Current configuration of load file reads all minimum
% load position as zero)
% loadfilemax = maximum position specified in imported load file.

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha


function [x] = x_vector(alpha,l,xmin, spacing, xmax, plate, loadtype,loadfilemin,loadfilemax)
%% Check if the spacing are provided, if not, set to 1 km (1000 m).
if isempty(spacing)
    spacing = 1000;
end

% Decision making about what value to use in the [x] vector starts here.
% Note that the decisions are based on the plate and loadtype, as well as
% on the magitude of maximum and minimum plot positions, load positions in
% the load file, wavelength of topography and the flexural parameter. There
% can be several combinations of decisions, and I have tried to guess all
% of them here. I might have missed some as well, in case you can think of
% something let me know.

if (plate == 1&& (loadtype ==4 || loadtype == 5) )|| (plate == 2 && loadtype ==2)
    if abs(loadfilemax)>abs(loadfilemin)
        if abs(xmax)>abs(xmin)
            if abs(loadfilemax)>abs(xmax)
                x = 0:spacing:loadfilemax;
            else
                x = 0:spacing:abs(xmax);
            end
        elseif abs(xmax)<abs(xmin)
            if abs(loadfilemax)>abs(xmin)
                x = 0:spacing:loadfilemax;
            else
                x = 0:spacing:abs(xmin);
            end
        else 
                x = 0:spacing:abs(xmax);
        end
    else
        if abs(xmax)<abs(xmin)
            if abs(loadfilemin)>abs(xmin)
                x = 0:spacing:abs(loadfilemin);
            else
                x = 0:spacing:abs(xmin);
            end
        elseif abs(xmax)>abs(xmin)
            if abs(loadfilemin)>abs(xmax)
                x = 0:spacing:abs(loadfilemin);
            else
                x = 0:spacing:abs(xmax);
            end
        else
            x = 0:spacing:abs(xmax);
        end
    end

elseif plate == 1 && loadtype == 3
    spacing = 5*l/(2^10-1);
    if abs(xmax)>abs(xmin)
        if xmax>5*l && xmin>-5*l
            x = 0:spacing:xmax;
        elseif xmax<5*l && xmin<-5*l
            x = 0:spacing:abs(xmin);
        elseif xmax>5*l && xmin<-5*l
            x = 0:spacing:xmax;
        elseif xmax<5*l && xmin>-5*l
            x = 0:spacing:xmax;
        else
            x = 0:spacing:5*l;
        end
    elseif abs(xmax)<abs(xmin)
        if xmax>5*l && xmin>-5*l
            x = 0:spacing:abs(xmin);
        elseif xmax<5*l && xmin<-5*l
            x = 0:spacing:abs(xmax);
        elseif xmax>5*l && xmin<-5*l
            x = 0:spacing:abs(xmin);
        elseif xmax<5*l && xmin>-5*l
            x = 0:spacing:abs(xmin);
        else
            x = 0:spacing:5*l;
        end
    elseif xmax<5*l && xmin>-5*l
            x = 0:spacing:5*l;
    end
    setappdata(0,'h_spacing',spacing);
else      
% Check if xmin, xmax are within the ranges of - or +4 alpha
    if abs(xmax)>abs(xmin)
        if xmax>4*alpha && xmin>-4*alpha
            x = 0:spacing:xmax;
        elseif xmax<4*alpha && xmin<-4*alpha
            x = 0:spacing:abs(xmin);
        elseif xmax>4*alpha && xmin<-4*alpha
            x = 0:spacing:xmax;
        elseif xmax<4*alpha && xmin>-4*alpha
            x = 0:spacing:xmax;
        end
    elseif abs(xmax)<abs(xmin)
        if xmax>4*alpha && xmin>-4*alpha
            x = 0:spacing:abs(xmin);
        elseif xmax<4*alpha && xmin<-4*alpha
            x = 0:spacing:abs(xmax);
        elseif xmax>4*alpha && xmin<-4*alpha
            x = 0:spacing:abs(xmin);
        elseif xmax<4*alpha && xmin>-4*alpha
            x = 0:spacing:abs(xmin);
        end
    elseif abs(xmax) == abs(xmin)
        if xmax>4*alpha
            x = 0:spacing:abs(xmax);
        elseif xmax <4*alpha
            x = 0:spacing:4*alpha;
        end
    elseif xmin>-4*alpha && xmax<4*alpha
            x = -4*alpha:spacing:4*alpha;
    end
end
