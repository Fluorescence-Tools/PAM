function [cm_data]=purplebluegreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'PuBuGn');