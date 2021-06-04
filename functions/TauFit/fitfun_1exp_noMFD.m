function [z] = fitfun_1exp(param, xdata)
% noMFD model for single exponential where Ipar+Iperp is measured on one detector
ShiftParams = xdata{1};
IRFPattern = xdata{2}; %for convolution
Scatter = xdata{3}; %for accounting for scatter in the actual decay
p = xdata{4};
y = xdata{5};
c = param(end-1); %IRF shift
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern
irf = shift_by_fraction(IRFPattern,c);
irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
irf = irf./sum(irf);
irf = [irf; zeros(numel(y)+ignore-1-numel(irf),1)];

n = length(irf);
tp = (1:p)';
bg = param(6);
sc = param(5);
l1 = param(7);
l2 = param(8);
tau = param(1);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width
rho = param(2);
rho(rho==0) = 1;
r0 = param(3);
rinf = param(4);

% fluorescence decay
xf = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));

% anisotropy decay
rt = (r0-rinf).*exp(-(tp-1)./rho)+rinf;
xpar = xf.*(1+(2-3*l1)*rt);
xper = xf.*(1-(1-3*l2)*rt);
x = (xpar+xper)/2; % combine parallel plus perpendicular 1:1
switch conv_type
    case 'linear'
        z = conv(irf, x); z = z(1:n);
    case 'circular'
        z = convol(irf,x(1:n));
end
%%% new
z = param(end)*z(ignore:end)+sc*sum(y)*Scatter(ignore:end)+bg;
z = z';