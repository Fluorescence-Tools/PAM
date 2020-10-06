function [cm_data]=grayfromgray(m)
if nargin < 1
    m = size(colormap(gcf),1);
end
offset = ceil(0.3*m);
cm_data = brewermap(m+offset,'Greys');
cm_data = cm_data(offset:end,:);