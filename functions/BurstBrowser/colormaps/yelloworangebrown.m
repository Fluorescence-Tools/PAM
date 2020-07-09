function [cm_data]=yelloworangebrown(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'YlOrBr');