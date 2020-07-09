function [cm_data]=spectral(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Spectral');