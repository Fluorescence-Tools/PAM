function out = jetvar(m)

% JETVAR Variant of Jet colormap.
%
% Usage: OUT = JETVAR(M)
%
% This returns an M-by-3 matrix containing a variant of the Jet colormap.
% Instead of starting at dark blue as Jet does, it starts at white. It goes
% to pure blue from white, and then continues exactly as Jet does, ranging
% through shades blue, cyan, green, yellow, and red, and ending with dark
% red. M should be at least 10 to ensure there is at least one white color.
%
% Inputs:
%   -M: Length of colormap (optional, default is the length of the current
%   figure's colormap).
%
% Outputs:
%   -OUT: M-by-3 colormap.
%
% See also: JET, HSV, HOT, PINK, FLAG, COLORMAP, RGBPLOT.

if nargin < 1
    m = size(get(gcf, 'colormap'), 1);
end
out = jet(m);
% Modify the output starting at 1 before where Jet outputs pure blue.
n = find(out(:, 3) == 1, 1) - 1;
%%% code changed to not output pure white at start (Anders, 07/2017)
out(1:n, 1:2) = repmat((n:-1:1)'/(n+1), [1 2]);
out(1:n, 3) = 1;