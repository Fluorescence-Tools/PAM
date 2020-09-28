function [cm_data]=purpleblue(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'PuBu');