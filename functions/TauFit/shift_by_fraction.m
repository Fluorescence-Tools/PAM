%%% Shift data by a fraction of the grid
function [ data_shifted ] = shift_by_fraction( data, shift , resolution)
%%% return shifted data, allowing any input value for shift (i.e.
%%% fractional shifts)
if nargin < 3
    resolution = 2; % default to 1/100
end
res = 10^(resolution); %%% maximum resolution of grid

%%% interpolate data to finer grid given by shift
%%% round to units of 1/100
shift = round(shift*res);

grid = 1:(1/res):numel(data);

data_interpolated = interp1(1:numel(data),data,grid); % this will always make data into a 1xN array
data_shifted = circshift(data_interpolated,[0,shift]);

%%% interpolate back to the coarse grid
data_shifted = interp1(grid,data_shifted,1:numel(data));
%%% restore original dimensions
if ~all(size(data) == size(data_shifted))
    data_shifted = data_shifted';
end