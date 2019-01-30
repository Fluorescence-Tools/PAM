function out = parulavar(m)

% PARULAVAR Variant of Parula colormap.
%
% Usage: OUT = parulavar(M)
%
% This returns an M-by-3 matrix containing a variant of the Parula colormap.
% Instead of starting at dark blue as Parula does, it starts at white. It goes
% to pure blue from white, and then continues exactly as Parula does.
% M should be at least 10 to ensure there is at least one white color.
%
% Inputs:
%   -M: Length of colormap (optional, default is the length of the current
%   figure's colormap).
%
% Outputs:
%   -OUT: M-by-3 colormap.
%
% See also: PARULA.

if nargin < 1
    m = size(get(gcf, 'colormap'), 1);
end
n = floor(m/10);
out = parula(m-n);
% fill offset from white to the starting color
c = out(1,:);
start = zeros(n,3);
beta = linspace(1,0,n+1);
beta = beta(2:end); % don't start from white, but light blue
for i = 1:n
    start(i,:) = c.^(1-beta(i));
end
out = [start; out];