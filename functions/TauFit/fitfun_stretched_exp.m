function [z] = fitfun_1exp(param, xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2}; %for convolution
Scatter = xdata{3}; %for accounting for scatter in the actual decay
p = xdata{4};
y = xdata{5};
c = xdata{6}; %IRF shift
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
%irf = circshift(IRFPattern,[c, 0]);
irf = shift_by_fraction(IRFPattern,c);
irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
irf(irf~=0) = irf(irf~=0)-min(irf(irf~=0));
irf = irf./sum(irf);
irf = [irf; zeros(numel(y)+ignore-1-numel(irf),1)];
%A shift in the scatter is not needed in the model
%Scatter = Scatter((ShiftParams(1)+1):ShiftParams(3) );

n = length(irf);
%t = 1:n;
tp = (1:p)';
bg = param(4);
sc = param(3);
beta = param(2);
tau = param(1);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width
x = exp(-((tp-1)./tau).^beta);%*diag(1./(1-exp(-p./tau)));
switch conv_type
    case 'linear'
        z = conv(irf, x); z = z(1:n);
    case 'circular'
        z = convol(irf,x(1:n));
end
z = z./sum(z);
z = (1-sc).*z + sc*Scatter; 
%z = z./sum(z);
z = z(ignore:end);
z = z./sum(z);
z = z.*(1-bg)+bg./numel(z);z = z.*sum(y);
z=z';