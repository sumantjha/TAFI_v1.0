% [flexuregrid] = loadconv3D(wgreen, loadscale, loadgrid, nx,ny)    
%
% Computes the 3D flexural deflection due to a 3D spatially distributed load. 
% This function, flips the 3D flexural response grid of green's function
% and convolves with 3D distributed load grid describing the load distribution
%
% RETURN
%  flexuregrid = grid containing discretized flexural deflection due to
%  spatially distributed 3D load
% ARGUMENTS
%  All arguments are provided in SI units
%  wgreen = discretized flexural deflection Green's function grid (Unit - m)
%  loadscale = scaling magnitude selected by user
%  loadgrid = vector specifying the load magnitude at each node
%  nx = number of nodes of load grid in X direction
%  ny = number of nodes of load grid Y direction
%  dx = discretization interval in X direction
% dy =  discretization interval in Y direction

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [flexuregrid] = loadconv3D(wgreen, loadscale, loadgrid, nx,ny,dx,dy)    

%Before convolving flip the green's function grid
    [gx,gy] = size(wgreen);
        FlippedGreen(1:gx,1:gy) = fliplr(wgreen);
        FlippedGreen(1:gx,gy+1:2*gy) = wgreen;
        FlippedGrid(1:gx,1:2*gy) = flipud(FlippedGreen);
        FlippedGrid(gx+1:2*gx,1:2*gy) = FlippedGreen;
    % Create the load grid with loads placed at nodes. The load
    % magnitude slider is converted to load scale slider with range of
    % 1 to 10, which can be used to scale the input load grid.
    K = 1;
    for i = 1:1:nx
          for j = 1:1:ny
              NewLoadGrid(i,j) = loadscale*loadgrid((K-1)+j);
          end
          K = K+j;
    end
    setappdata(0,'NewLoadGrid',NewLoadGrid);
        %Convolve the Flipped and Padded Green's function grid with load grid
        gridconv = conv2(FlippedGrid,NewLoadGrid,'full');
        gridconv  = dx*dy*gridconv;
        % Set twice the size of convolved grid in appdata to be used later for gravity
        % calculations.
        flexuregrid = gridconv(gx:2*gx,1:2*gy);
        setappdata(0,'flexuregrid',flexuregrid);
        
end