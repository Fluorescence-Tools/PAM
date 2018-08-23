function model = tailfit_3exp(x,xdata)
% 3 component fit model for tail-fitting

% fix amplitudes
if (x(5)+x(6)) > 1
    norm = x(5)+x(6);
    x(5) = x(5)./norm;
    x(6) = x(6)./norm;
end

%calculate model
model = x(1)*(x(5)*exp(-xdata./x(2))+x(6)*exp(-xdata./x(3))+max([0 (1-x(5)-x(6))])*exp(-xdata./x(4)))+x(7);

