% [xcross] = numcal_xcross(x,w,loadpos)
%
% Calculates the zero crossing by sequentially searching the output vector.
% This part is removed from main code because of the "break" function.
%
% RETURN
% xcross = zero crossing position of the flexural deflection
% ARGUMENT
% x = vector with discretized position values
% w = discretized flexural deflection vector
% loadpos = position of load
%

% TAFI - Toolbox for Analysis of Flexural Isostasy
% Programmed by S. Jha

function [xcross] = numcal_xcross(x,w,loadpos)
% numcal_xcross calculates zero crossing numerically for Infinite plate, point load
% when there is no analytical solution. 
    for i = 1:length(x)
        if w(i) == 0;
            %If flexure deflection vector has a zero somewhere in profile,
            %read the first instance and return corresponding position.
                xcross = x(i);
         elseif i<length(x) && w(i)<0 && w(i+1)>0
             % If flexure vector has no zeros in profile, determine the
             % first instance when the slope changes sign from positive to
             % negative, and determine approximate corresponding position,
             % where flexure is 0.
                xcross = ((loadpos)+(x(i)-(w(i)*(x(i+1)-x(i))/(w(i+1)-w(i)))));
                % Using break is a bad practice, but suitable here.
                break;
        else
            xcross = 0;
        end
    end
end