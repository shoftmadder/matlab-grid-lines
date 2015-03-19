function h = AddInfiniteLine( m, b, c, varargin )
%AddInfiniteLine Add an infinite line to a plot.
%
%   AddInfiniteLine(m, b, c, ...) adds a black line with equation
%       (y - c) = m (x - b)
%   As the axes limits are changed, the line is re-plotted such that it 
%   doesn't extend beyond the rectangle defined by the axes.  This allows
%   the figure limits to auto-size to user-data, and for the line to remain
%   in place as the plot is zoomed in or out, or translated.
%
%   AddInfiniteLine(m, b, c, ...), AddInfiniteLine(val, hAx, ...) plots a 
%   line, with all other arguments passed directly to the plot function.
%   (Note that using AddInfiniteLine in this way doesn't set the colour of 
%   plotted line by default)
%
%   h = AddInfiniteLine(...) returns a handle to the plotted line.

%% Deal with the input arguments

% We need at least 3 arguments (m, b, c)
if( nargin < 3 )
    error('Too few arguments');
end

% varargin contains the properties which will be passed to plot.
% The first element of these might be our axes.
%
% If it is, we need to take this out of varargin, and pass it to plot as
% the first argument.
%
% Otherwise, use gca for our axes handle.

isHandleToAxes = @(x) isscalar(x) && ishghandle(x) && strcmp(get(x, 'type'), 'axes');

if( nargin < 4 || ~isHandleToAxes(varargin{1}) )
    % No handle to axes defined in input.
    % Use gca as a default axes handle.
    hAx = gca;
else
    % We have found a handle to axes.
    % Use this as our axes handle.
    % Remove it from the rest of the arguments.
    hAx = varargin{1};
    varargin(1) = [];
end


% If we have an empty varargin (or if it consists only of hAx), 
% then add a linespec of 'k'.  
%
% Otherwise, assume the caller is taking care of the linespec, and do 
% nothing.
if length(varargin) < 1
    varargin = {'k'};
end

%% Plot the line

% Save the hold state.
holdstate = ishold(hAx);

% If we're not already holding, then turn hold on.
if( ~holdstate )
    hold on
end

% Plot the line (dummy co-ordinates for now).
hLine = plot(hAx, [0;0], [0;0], varargin{:});

% Update the co-ordinates based on the axes limits.
UpdateLineLimits(0, 0, hAx, hLine, m, b, c)

% remove the line from the legend
hAnnotation = get(hLine,'Annotation');
hLegendEntry = get(hAnnotation','LegendInformation');
set(hLegendEntry,'IconDisplayStyle','off')

%% Add listeners
% This defines functions to be called when the axes are re-sized.
% This resizes the line when the axes are resized
hXLimProp = findprop(hAx, 'XLim');
hYLimProp = findprop(hAx, 'YLim');

hXListener = event.proplistener(hAx, hXLimProp, 'PostSet', @(src, evt) UpdateLineLimits(src, evt, hAx, hLine, m, b, c) );
hYListener = event.proplistener(hAx, hYLimProp, 'PostSet', @(src, evt) UpdateLineLimits(src, evt, hAx, hLine, m, b, c) );

% Store the listener in the UserData of hLine, so that the listener is
% deleted if and when the line is deleted.
set(hLine, 'UserData', [hXListener, hYListener]);

%% Reset the hold status
% If hold was off to start with, turn it back off now we've finished.
if( ~holdstate )
    hold(hAx, 'off');
end

%% Assign outputs.
% If the user has requested an output, give them the handle to the line.
if( nargout > 0 )
    h = hLine;
end

end

function UpdateLineLimits( ~, ~, hAx, hLine, m, b, c)
%UpdateLineLimits
%
% Updates the co-ordinates of the line hLine, defined by
%       (y - c) = m (x - b)
% to only plot the portion of the line which lies within the XLim and YLim 
% of axes hAx.

	[X,Y] = GetLineLimitsInRectangle(m,b,c,get(hAx, 'XLim'), get(hAx, 'YLim'));
	set(hLine, 'XData', X);
    set(hLine, 'YData', Y);
end

function [X, Y] = GetLineLimitsInRectangle( m, b, c, Xs, Ys )
%GetLineLimitsInRectangle 
% Find the co-ordinates where the line defined by
%
%   (y - c) = m * (x - b)
%
% intersects the rectangle defined by (Xs, Ys), where
%	Xs -- x-coordinates of the two sides of the rectangle.
%   Ys -- y-coordinates of the top and bottom of the rectangle.
%
% m, b, c are scalars.
% Xs, Ys are vectors with at least 2 elements.

%% Redefine (x0 y0), (x1, y1) so x0 < x1, y0 < y1
x0 = min(Xs);
x1 = max(Xs);
y0 = min(Ys);
y1 = max(Ys);

% Special cases -- m = 0, m = inf.
% Handle these separately for speed, since I'm guessing they will be the
% most common cases.
if( m == 0 )
    if (y0 < c) && (c < y1)
        X = [x0; x1];
        Y = [c ; c ];
        return
    else
        X = [];
        Y = [];
        return;
    end
elseif( isinf(m) )
    if (x0 < b) && (b < x1)
        X = [b ; b ];
        Y = [y0; y1];
        return;
    else
        X = [];
        Y = [];
        return;
    end
end


% The line must intersect 2 of the sides.
%              2      (x1, y1)
%          +-------+ 
%          |       |
%        1 |       |  3
%          |       |
%          +-------+
%   (x0,y0)    4
%
% The plotted line intersects side 1 if the equation of the line, evaluated
% at the x = x0 yields a y value in the range y0 < y < y1
%
% This can be extended to all 4 sides.
%
% Possible outcomes -- 
% - The line intersects 0 sides.
%   => Do not plot a line.
%
% - The line intersects 2 sides
%   => Plot the line between the points where it intersects the sides.

nFound = 0;
X = zeros(2,1);
Y = zeros(2,1);
if (y0 <= (m * (x0 - b) + c)) && ((m * (x0 - b) + c) <= y1)
    nFound = nFound +1;
    X(nFound) = x0;
    Y(nFound) = m * (x0 - b) + c;
end

if (y0 <= (m * (x1 - b) + c)) && ((m * (x1 - b) + c) <= y1)
    nFound = nFound +1;
    X(nFound) = x1;
    Y(nFound) = m * (x1 - b) + c;
end

if (x0 <= ((y0 - c)/m + b)) &&  (((y0 - c)/m + b) <= x1)
    nFound = nFound +1;
    X(nFound) = ((y0 - c)/m + b);
    Y(nFound) = y0;    
end

if (x0 <= ((y1 - c)/m + b)) &&  (((y1 - c)/m + b) <= x1)
    nFound = nFound +1;
    X(nFound) = ((y1 - c)/m + b);
    Y(nFound) = y1;    
end

if nFound == 2
    return;
elseif nFound == 0
    % Line doesn't intersect the rectangle
    % Nothing to plot
    X = [];
    Y = [];
    return;
else
    % Should never reach here...
    error('Line should intersect either 2 or 0 sides of the rectangle')
end


end