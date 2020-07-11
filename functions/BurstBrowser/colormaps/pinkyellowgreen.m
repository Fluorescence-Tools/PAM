function [cm_data]=pinkyellowgreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'PiYG');