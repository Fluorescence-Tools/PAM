function [cm_data]=yellowgreenblue(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'YlGnBu');