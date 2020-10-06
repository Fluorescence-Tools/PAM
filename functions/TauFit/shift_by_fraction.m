%%% Shift data by a fraction of the grid
function [ data_shifted ] = shift_by_fraction( data, shift)
%%% return shifted data, allowing any input value for shift (i.e.
%%% fractional shifts)
shift_floor = floor(shift);
shift_float = shift-shift_floor;

%%% calculate fraction-weighted sum of integer-shifted IRFs
data_shifted = circshift(data,shift_floor).*(1-shift_float)+...
    circshift(data,shift_floor+1).*shift_float;

%%% restore original dimensions
if ~all(size(data) == size(data_shifted))
    data_shifted = data_shifted';
end

%%% Thomas' Python Code from Chisurf
% def shift_array(
%         y: np.array,
%         shift: float
% ) -> np.array:
%     """Calculates an array that is shifted by a float. For non-integer shifts
%     the shifted array is interpolated.
%     :return:
%     """
%     ts = -shift
%     ts_f = np.floor(ts)
%     if np.isnan(ts_f):
%         ts_f = 0
%     tsi = int(ts_f)
% 
%     tsf = shift - tsi
%     ysh = np.roll(y, tsi) * (1 - tsf) + np.roll(y, tsi + 1) * tsf
%     if ts > 0:
%         ysh[:tsi] = 0.0
%     elif ts < 0:
%         ysh[tsi:] = 0.0
%     return ysh
%     
    
%%% old implementation
function [ data_shifted ] = shift_by_fraction_old( data, shift , resolution)
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