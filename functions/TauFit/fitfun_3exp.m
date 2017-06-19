function [z] = fitfun_3exp(param, xdata)
%	LSFIT(param, irf, y, p) returns the Least-Squares deviation between the data y 
%	and the computed values. 
%	LSFIT assumes a function of the form:
%
%	  y =  yoffset + A(1)*convol(irf,exp(-t/tau(1)/(1-exp(-p/tau(1)))) + ...
%
%	param(1) is the color shift value between irf and y.
%	param(2) is the irf offset.
%	param(3:...) are the decay times.
%	irf is the measured Instrumental Response Function.
%	y is the measured fluorescence decay curve.
%	p is the time between to laser excitations (in number of TCSPC channels).
ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};
p = xdata{4};
y = xdata{5};
c = xdata{6};
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
%irf = circshift(IRFPattern,[c, 0]);
irf = shift_by_fraction(IRFPattern,c);
irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
irf = irf-min(irf(irf~=0));
irf = irf./sum(irf);
irf = [irf; zeros(numel(y)+ignore-1-numel(irf),1)];
%A shift in the scatter is not needed in the model
%Scatter = Scatter( (ShiftParams(1)+1):ShiftParams(3) );


n = length(irf);
%t = 1:n;
tp = (1:p)';
A1 = param(4);
A2 = param(5);
if (A1+A2) > 1
    A1 = A1./(A1+A2);
    A2 = A2./(A1+A2);
end
sc = param(6);
bg = param(7);
tau = param(1:3);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width
x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
%%% combine the three exponentials
x = A1*x(:,1) + A2*x(:,2) + (1-A1-A2)*x(:,3);
switch conv_type
    case 'linear'
        z = zeros(size(x,1)+size(irf,1)-1,size(x,2));
        for i = 1:size(x,2)
            z(:,i) = conv(irf, x(:,i));
        end
        z = z(1:n,:);
    case 'circular'
        z = convol(irf,x(1:n));
end
z = z./repmat(sum(z,1),size(z,1),1);
z = (1-sc).*z + sc*Scatter;
z = z./sum(z);
z = z(ignore:end);
z = z./sum(z);
z = z.*(1-bg)+bg./numel(z);z = z.*sum(y);
z=z';