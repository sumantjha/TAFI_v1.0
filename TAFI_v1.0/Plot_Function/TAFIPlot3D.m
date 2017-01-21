%TAFIPlot3D(data, plotx, figurepanel, handles)
%
% Plots the flexural and gravity surface 
%
% RETURN
% Flexural and Gravity plots, along with data constraints if available.
% ARGUMENT
% data = grid of flexural deflection or calculate total gravity
% figurepanel = flexural curve is plotted in panel 1, gravity in panel 2.
% Values given as "1" or "2"
% handles = handles of GUI elements in TAFI. 
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function TAFIPlot3D(data, loadgrid, figurepanel, hObject, eventdata,handles)
  if length(loadgrid) ~= 1
        nx = getappdata(0,'nx');
        ny = getappdata(0,'ny');
        f_constraint = getappdata(0,'f_constraint');
        g_constraint = getappdata(0,'g_constraint');
        
        if figurepanel == 1
            axes(handles.axes1)
            cla reset
            surf(data(1:nx,2*ny:3*ny)./1000);
            if ~isempty(f_constraint)
                 hold on
                 plot3(f_constraint(:,1),f_constraint(:,2),f_constraint(:,3),'k+');
            end

            set(gca,'XaxisLocation','origin');
            set(gca,'YaxisLocation','origin');
            xlabel('Distance (km)');
            ylabel('Distance (km)');
            zlabel('Flexural Deflection (km)');
            shading interp;
            view(3);grid on;
        else
            axes(handles.axes2)
            cla reset
            surf(data(1:nx,2*ny:3*ny));
            set(gca,'XaxisLocation','origin');
            set(gca,'YaxisLocation','origin');
            xlabel('Distance (km)');
            ylabel('Distance (km)');
            zlabel('Gravity (mGal)');
            shading interp;
            view(3);
            if ~isempty(g_constraint)
                hold on
                plot3(g_constraint(:,1),g_constraint(:,2),g_constraint(:,3),'k+');
            end
        end
  else
      rmload_Callback(hObject, eventdata, handles)
      
  end
end

            
            