function [cm_data]=yellowgreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'YlGn');