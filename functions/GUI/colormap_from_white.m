function out = colormap_from_white(cmap_string,flip,m)
% Usage: OUT = colormap_from_white(cmap_string,m)
%
% This returns an M-by-3 matrix containing a variant of the input colormap.
% Instead of starting at the initial value of the colormap, it starts at white.
%
% Inputs:
%   -cmap_string: Name of the colormap as used to call it in MATLAB
%   -M: Length of colormap (optional, default is the length of the current
%   figure's colormap).
%
% Outputs:
%   -OUT: M-by-3 colormap.
if nargin < 2
    flip = false;
end
if nargin < 3
    m = size(get(gcf, 'colormap'), 1);
end
n = floor(m/10);
try
    eval(['out = ' cmap_string '(m-n);']);
catch
    disp('Invalid colormap name provided.');
    out = get(gcf, 'colormap');
    return;
end
% flip
if flip
    out = flipud(out);
end
% fill offset from white to the starting color
c = out(1,:);
start = zeros(n,3);
if all( c == 0 | c == 1) %%% we start with a pure color
    start(:,c ~= 1) = repmat((n:-1:1)'/(n+1), [1 sum(c ~=1)]);
    start(:,c == 1) = repmat(c(c==1), [n 1]);
else
    if any(c == 0)
        c(c == 0) = min(c(c>0)); %%% fill zeros with smallest value
    end
    
    start_from_white = false;
    if start_from_white
        beta = linspace(1,0,n);
    else
        beta = linspace(1,0,n+1);
        beta = beta(2:end); % don't start from white, but one step after
    end

    for i = 1:n
        start(i,:) = c.^(1-beta(i));
    end
end
out = [start; out];