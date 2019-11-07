function [z] = fitfun_2dist_donly(param,xdata)
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
%Scatter = circshift(ScatterPattern,[ShiftParams(5), 0]);
%Scatter = Scatter((ShiftParams(1)+1):ShiftParams(3) );

n = length(irf);
%t = 1:n;
%tp = (1:p)';

meanR1 = param(1); %%% Center distance
sigmaR1 = param(2); %%% Sigma R
meanR2 = param(3);
sigmaR2 = param(4);
fraction1 = param(5);
fraction_donly = param(6);
sc = param(7);
bg = param(8);
R0 = param(9);
tauD0 = param(10);
tauD0(tauD0==0) = 1; %%% set minimum lifetime to TACbin width

%%% Determine distribution of lifetimes
range_lower = min([meanR1-5*sigmaR1,meanR2-5*sigmaR2]);
range_upper = max([meanR1+5*sigmaR1,meanR2+5*sigmaR2]);
dR = 0.1;
xR = floor(range_lower):dR:ceil(range_upper);
xR = xR(xR > 0);
c_gauss = zeros(numel(xR),n);
xdist = zeros(2,n);
for j = 1:2
    switch j
        case 1
            meanR = meanR1;
            sigmaR = sigmaR1;
        case 2
            meanR = meanR2;
            sigmaR = sigmaR2;
    end
    for i = 1:numel(xR)
        c_gauss(i,:) = c_gauss(i,:) + (1/(sqrt(2*pi())*sigmaR))*exp(-((xR(i)-meanR).^2)./(2*sigmaR.^2)).*exp(-((0:n-1)./tauD0).*(1+(R0./xR(i)).^6));
    end
    pR = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR-meanR).^2)./(2*sigmaR.^2));
    xdist(j,:) = sum(c_gauss,1);xdist(j,:) = xdist(j,:)./sum(pR);
end
xDonly = exp(-(0:n-1)./tauD0);    
x = fraction_donly.*xDonly + (1-fraction_donly).*(fraction1*xdist(1,:)+(1-fraction1)*xdist(2,:));
switch conv_type
    case 'linear'
        z = conv(irf, x); z = z(1:n)';
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