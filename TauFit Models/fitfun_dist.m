function [z] = fitfun_dist(param,xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2};
ScatterPattern = xdata{3};
p = xdata{4};
y = xdata{5};
c = xdata{6};
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
irf = circshift(IRFPattern,[c, 0]);
irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
irf = irf-min(irf(irf~=0));
irf = irf./sum(irf);
irf = [irf; zeros(numel(y)+ignore-1-numel(irf),1)];
Scatter = circshift(ScatterPattern,[c, 0]);
Scatter = Scatter( (ShiftParams(1)+1):ShiftParams(3) );

n = length(irf);
%t = 1:n;
%tp = (1:p)';

meanR = param(1); %%% Center distance
sigmaR = param(2); %%% Sigma R
sc = param(3);
bg = param(4);
R0 = param(5);
tauD0 = param(6);

%%% Determine distribution of lifetimes
xR = floor(meanR-5*sigmaR):0.1:ceil(meanR+5*sigmaR);
c_gauss = zeros(numel(xR),n);
for i = 1:numel(xR)
    c_gauss(i,:) = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR(i)-meanR).^2)./(2*sigmaR.^2)).*exp(-((1:n)./tauD0).*(1+(R0./xR(i)).^6));
end
x = sum(c_gauss,1);
switch conv_type
    case 'linear'
        z = conv(irf, x); z = z(1:n)';
    case 'circular'
        z = convol(irf,x);
end
z = z./repmat(sum(z,1),size(z,1),1);
z = (1-sc).*z + sc*Scatter;
z = z./sum(z);
z = z(ignore:end);
z = z./sum(z);
z = z.*sum(y)+bg;
z=z';