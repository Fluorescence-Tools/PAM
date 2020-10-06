function [cm_data]=blues(m)
if nargin < 1
    m = [];
end
cm_data = brewermap(m,'Blues');