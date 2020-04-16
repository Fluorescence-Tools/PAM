function [z] = fitfun_dist(param,xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};
p = xdata{4};
y = xdata{5};
c = param(end-1);%xdata{6}; %IRF shift
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
%Scatter = circshift(ScatterPattern,[ShiftParams(5), 0]);
%Scatter = Scatter((ShiftParams(1)+1):ShiftParams(3) );

n = length(irf);
%t = 1:n;
%tp = (1:p)';

meanR = param(1); %%% Center distance
sigmaR = param(2); %%% Sigma R
sc = param(3);
bg = param(4);
R0 = param(5);
tauD0 = param(6);
tauD0(tauD0==0) = 1; %%% set minimum lifetime to TACbin width

%%% Determine distribution of lifetimes
dR = .25;
xR = floor(meanR-5*sigmaR):dR:ceil(meanR+5*sigmaR);
xR = xR(xR > 0);

c_gauss = zeros(numel(xR),n);
for i = 1:numel(xR)
    c_gauss(i,:) = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR(i)-meanR).^2)./(2*sigmaR.^2)).*exp(-((0:n-1)./tauD0).*(1+(R0./xR(i)).^6));
end

pR = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR-meanR).^2)./(2*sigmaR.^2));
x = sum(c_gauss,1)./sum(pR);
switch conv_type
    case 'linear'
        z = conv(irf, x); z = z(1:n)';
    case 'circular'
        z = convol(irf,x(1:n));
end

%%% new:
z = param(end)*z(ignore:end)+sc*sum(y)*Scatter(ignore:end)+bg;
z = z';

% %%% old
% z = z./repmat(sum(z,1),size(z,1),1);
% z = (1-sc).*z + sc*Scatter;
% z = z./sum(z);
% z = z(ignore:end);
% z = z./sum(z);
% z = z.*(1-bg)+bg./numel(z);z = z.*sum(y);
% z=z';