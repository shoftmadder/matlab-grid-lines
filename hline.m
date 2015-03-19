function h = hline( val, varargin )
%HLINE Add a horizontal line to a plot.
%   HLINE() adds a horizontal line to a plot at y = 0.
%
%   HLINE(val) adds a horizontal line at y = val.
%
%   HLINE(val, hAx) adds a horizontal line at y = val to the axes hAx.
%
%   HLINE(val, ...), HLINE(val, hAx, ...) plots a line, with all other
%   arguments passed directly to the plot function.  Note that using HLINE
%   in this way doesn't set the colour of the line by default, so don't
%   forget to set it in the arguments.
%
%   h = HLINE(...) returns a handle to the plotted line.

% Default line y-value is 0
if nargin < 1
    val = 0;
end

% Plot the line
hLine = AddInfiniteLine(0, 0, val, varargin{:});

% If the user has requested an output, give them the handle to the line.
if( nargout > 0 )
    h = hLine;
end

end
