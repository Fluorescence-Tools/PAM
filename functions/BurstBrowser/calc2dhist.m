%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General Functions for plotting 2d-Histogram of data %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H,xbins,ybins,xbins_hist,ybins_hist, bin_out] = calc2dhist(x,y,nbins,limx,limy)
%%% ouput arguments:
%%% H:                      Image Data
%%% xbins/ybins:            corrected xbins for image plot
%%% xbins_hist/ybins_hist:  use these x/y values for 1d-bar plots
%%% bin:                    a list of the x and y bins of all selected bursts
global UserValues
if nargin <2
    return;
end
%%% if number of bins is not specified, read from UserValues struct
if nargin < 3
    nbins = [UserValues.BurstBrowser.Display.NumberOfBinsX,...
        UserValues.BurstBrowser.Display.NumberOfBinsY];
end
%%% if no limits are specified, set limits to min-max
if nargin < 5
    limx = [min(x(isfinite(x))) max(x(isfinite(x)))];
    limy = [min(y(isfinite(y))) max(y(isfinite(y)))];
end
%%% fix limits for inf boundary
if ~isfinite(limx(2))
    limx(2) = max(x(isfinite(x)));
end
if ~isfinite(limy(2))
    limy(2) = max(y(isfinite(y)));
end

valid = (x >= limx(1)) & (x <= limx(2)) & (y >= limy(1)) & (y <= limy(2));
x = x(valid);
y = y(valid);

bin_out = NaN(size(valid,1),2);
if (~UserValues.BurstBrowser.Display.KDE) || (sum(x) == 0 || sum(y) == 0) %%% no smoothing
    %%% prepare bins
    Xn = nbins(1)+1;
    Yn = nbins(2)+1;
    xbins_hist = linspace(limx(1),limx(2),Xn);
    ybins_hist = linspace(limy(1),limy(2),Yn);
    Zbins = linspace(1, Xn+(1-1/(Yn+1)), Xn*Yn);
    % convert data
    x = floor((x-limx(1))/(limx(2)-limx(1))*(Xn-1))+1;
    y = floor((y-limy(1))/(limy(2)-limy(1))*(Yn-1))+1;
    z = x + y/(Yn) ;

    % calculate histogram
    if nargout < 6 % Bin assignment is not requested
        h = histc(z, Zbins);
    elseif nargout == 6
        [h, bin]  = histc(z, Zbins);
        [biny,binx] = ind2sub([Yn,Xn],bin);
        binx(binx == Xn) = Xn -1;
        biny(biny == Yn) = Yn -1;
        binx(binx == 0) = 1;
        biny(biny == 0) = 1;
        bin_out(valid,:) = [biny,binx];
    end
    H = reshape(h, Yn, Xn);
    
    H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
    H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
    xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
    ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
elseif UserValues.BurstBrowser.Display.KDE %%% smoothing
    [~,H, xbins_hist, ybins_hist] = kde2d([x y],nbins(1),[limx(1) limy(1)],[limx(2), limy(2)]);
    H = (H./sum(H(:))).*numel(x);
    xbins_hist = xbins_hist(1,:);
    ybins_hist = ybins_hist(:,1);
    H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
    H(end-1,:) = H(end-1,:) + H(end,:); H(end,:) = [];
    xbins = xbins_hist(1:end-1);% + diff(xbins_hist)/2;
    ybins = ybins_hist(1:end-1);% + diff(ybins_hist)/2;
    ybins = ybins';
end