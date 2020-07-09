function [cm_data]=redblue(m)
if nargin < 1
    m = [];
end
cm_data = flipud(brewermap(m,'RdBu'));