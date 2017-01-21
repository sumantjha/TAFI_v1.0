%[calcW,calcX]=TAFIPlot2D(data, plotx,loadposdata,color,figurepanel, handles)
%
% Plots the flexural and gravity curve within user specified minimum and
% maximum plot positions.
%
% RETURN
% calcW = vector of flexural deflection within the user specified minimum
% and maximum positions
% calcX = vector of positions within the user specified minimum
% and maximum.
% ARGUMENT
% data = vector of discretized flexural deflection or calculate total
% gravity
% plotx = vector of position over which the flexural deflection or gravity
% was calculated
% loadposdata = position of load
% color = color of the flexural or gravity curve as determined earlier
% figurepanel = flexural curve is plotted in panel 1, gravity in panel 2.
% Values given as "1" or "2"
% handles = handles of GUI elements in TAFI. 
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [calcW,calcX]=TAFIPlot2D(data, plotx,loadposdata,color,figurepanel, handles)
% % Read plot position window data
Nxplotmax = getappdata(0,'Nxplotmax');
Nxplotmin = getappdata(0,'Nxplotmin');



%Reading imported flexure and gravity data, and the color used to plot them
%
f_constraint = getappdata(0,'f_constraint');
g_constraint = getappdata(0,'g_constraint');
f_color = getappdata(0,'f_color');
g_color = getappdata(0,'g_color');


%generating new position data
x_new = plotx + loadposdata;

calcX = x_new(fix(Nxplotmin):fix(Nxplotmax))/1000;

%Set calcw to be used with "Data Shift" panel, if needed
setappdata(0,'calcX',calcX);

% If figurepanel variable is 1, plot flexure curve. If figurepanel variable
% is 2, plot gravity curve.
if figurepanel == 1
    axes(handles.axes1);
    %cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    % plot is in km/km units
    calcW = data(fix(Nxplotmin):fix(Nxplotmax))/1000;
    plot(calcX,calcW,'-k','LineWidth',2,'Color',color);
    if ~isempty(f_constraint)
            plot(f_constraint(:,1),f_constraint(:,2),'.','Color',f_color,'markersize',10);
    end
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    set(gca,'YDir','reverse');
    xlabel('Distance (km)');
    ylabel('Flexural Deflection (km)');
    
    %Set calcw to be used with "Data Shift" panel, if needed
    setappdata(0,'calcW', calcW)
else
    axes(handles.axes2);
    %cla reset
    hold on
    grid on
    set(gca, 'GridLineStyle', '-');
    %plot is km/mGal units. Gravity was calculated on the basis of flexural
    % deflection plot window extent. 
    plot(calcX,data,'LineWidth',2,'Color',color);
        if ~isempty(g_constraint)
            plot(g_constraint(:,1),g_constraint(:,2),'.','Color',g_color);
        end
    set(gca,'XaxisLocation','origin');
    set(gca,'YaxisLocation','origin');
    ylabel ('Gravity (mGal)');    
    
end