function [cm_data]=purpleredgreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'PRGn');