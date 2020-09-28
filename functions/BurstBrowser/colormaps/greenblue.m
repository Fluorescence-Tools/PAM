function [cm_data]=greenblue(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'GnBu');