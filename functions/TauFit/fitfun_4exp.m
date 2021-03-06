function [z] = fitfun_4exp(param, xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};
p = xdata{4};
y = xdata{5};
c = param(end);%xdata{6}; %IRF shift
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
%Scatter = Scatter( (ShiftParams(1)+1):ShiftParams(3) );


n = length(irf);
%t = 1:n;
tp = (1:p)';
A1 = param(5);
A2 = param(6);
A3 = param(7);
if (A1+A2+A3) > 1
    norm = A1 + A2 + A3;
    A1 = A1./norm;
    A2 = A2./norm;
    A3 = A3./norm;
end
sc = param(8);
bg = param(9);
tau = param(1:4);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width
x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
%%% combine the three exponentials
x = A1*x(:,1) + A2*x(:,2)+ A3*x(:,3)+(1-A1-A2-A3)*x(:,4);
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