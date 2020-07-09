function [cm_data]=purpleorange(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'PuOr');