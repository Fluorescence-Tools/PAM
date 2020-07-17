function [cm_data]=redyellowgreen(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'RdYlGn');