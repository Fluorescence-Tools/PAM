%% Code for burstwise correlation function fitting
%% Set breakpoint in CrossCorrelation.m before bootstrapping
range = x>1e-6;
x = x(range);
model = @(x,xdata) x(1)./(1+xdata./x(2));
G = zeros(numel(c),1); taud = zeros(numel(c),1);
options = optimoptions('lsqcurvefit','Display','none','FunctionTolerance',1E-3);
for i = 1:numel(c)
    y = c{i}(range);
    valid = isfinite(y) & (y > -1);
    res = lsqcurvefit(model,[1,1e-3],x(valid),y(valid),[0,1E-4],[Inf,Inf],options);
    G(i) = res(1);
    taud(i) = res(2);
    i
end
