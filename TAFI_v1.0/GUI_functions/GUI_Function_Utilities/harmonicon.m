% harmonicon(handles)
%
% Harmonic on ENABLES the following handles in TAFI. These handles are
% only needed when computing the flexural deflection due to sinusoidal
% load.
%
% GUI elements being ENABLED:
% Spacing - the spacing for a sinusoidal load is calculated intrinsically
% so as to make sure that the number of terms in the flexural deflection
% calculation are always a power of two.
% SpacingPeriodic - The label informing the magnitude of discretization
% interval
% lambdaslider - Slider specifying the range of wavelength of sinusoidal
% load 
% lambda - Edit box displaying the selected wavelength value from
% lambdaslider
% loadposslider - Slider specifying the position of applied load.
% loadpos - Edit box displaying the selected load position.
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function harmonicon(handles)
        set(handles.Spacingperiodic,'Visible','on');
        set(handles.spacing, 'Enable','off');
        set(handles.lambdaslider,'Enable','on');
        set(handles.lambda,'Enable','on');
        set(handles.loadposslider,'Enable','off');
        set(handles.loadpos,'Enable','off');
end