function [cm_data]=yelloworangered(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'YlOrRd');