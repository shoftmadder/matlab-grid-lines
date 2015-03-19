function h = vline( val, varargin )
%VLINE Add a horizontal line to a plot.
%   VLINE() adds a vertical line to a plot at x = 0.
%
%   VLINE(val) adds a vertical line at x = val.
%
%   VLINE(val, hAx) adds a vertical line at x = val to the axes hAx.
%
%   VLINE(val, ...), VLINE(val, hAx, ...) plots a line, with all other
%   arguments passed directly to the plot function.  Note that using VLINE
%   in this way doesn't set the colour of the line by default, so don't
%   forget to set it in the arguments.
%
%   h = VLINE(...) returns a handle to the plotted line.


% Default line x-value is 0
if nargin < 1
    val = 0;
end

% Plot the line
hLine = AddInfiniteLine(inf, val, 0, varargin{:});

% If the user has requested an output, give them the handle to the line.
if( nargout > 0 )
    h = hLine;
end

end
