function [z] = fitfun_2dist_donly_global(param,xdata)
%%% global fit of donor-only and DA sample
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
irf = [irf; zeros(size(y,2)+ignore-1-numel(irf),1)];
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
tau0 = param(10); % this is the lifetime of the "unquenced" donor used to determine the specified R0
tau0(tau0==0) = 1; %%% set minimum lifetime to TACbin width
tauD01 = param(11);
tauD01(tauD01==0) = 1; %%% set minimum lifetime to TACbin width
tauD02 = param(12);
tauD02(tauD02==0) = 1; %%% set minimum lifetime to TACbin width
f1_donly = param(13);
sc_donly = param(14);
bg_donly = param(15);

%%% Determine distribution of lifetimes
%dR = 0.25;
R_res = 100; %%% sampling points between -4sigma and +4sigma
xdist = zeros(2,n);

%%% Homogenous model or not?
homogenous = true;
if homogenous
    %%% Assume that the fluorescence properties are identical in the different
    %%% conformational states, i.e. each states has contributions from both
    %%% quenched and unquenched donor-only lifetimes.
    for j = 1:2
        switch j
            case 1
                meanR = meanR1;
                sigmaR = sigmaR1;            
            case 2
                meanR = meanR2;
                sigmaR = sigmaR2;
        end
        xR = linspace(meanR-4*sigmaR,meanR+4*sigmaR,R_res);%(meanR-4*sigmaR):dR:(meanR+4*sigmaR);
        xR = xR(xR > 0)';
        pR = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR-meanR).^2)./(2*sigmaR.^2));
        
        t = repmat((0:n-1),[numel(pR),1]); % time axis
        
        k_RET = (1./tau0).*((R0./xR).^6); % k_RET as a function of R
        kD1 = (1./tauD01) + repmat(k_RET,[1,size(t,2)]);
        kD2 = (1./tauD02) + repmat(k_RET,[1,size(t,2)]);

        xdist(j,:) = sum(repmat(pR,[1,size(t,2)]).*...
                         (f1_donly*exp(-t.*kD1) + ...
                         (1-f1_donly)*exp(-t.*kD2)),1);
        xdist(j,:) = xdist(j,:)./sum(pR);
    end
    xdist = (fraction1*xdist(1,:)+(1-fraction1)*xdist(2,:));
else
    %%% Assume that the quenched species belongs to one of the
    %%% conformational states!
    %%% In this case, the distribution over the two species (quenched and
    %%% unqueched) is determined by the fraction of the two conformational
    %%% states.
    %%% Fluorescence properties and quenching are coupled.
    for j = 1:2
        switch j
            case 1
                meanR = meanR1;
                sigmaR = sigmaR1;
                tauD0 = tauD01;
            case 2
                meanR = meanR2;
                sigmaR = sigmaR2;
                tauD0 = tauD02;
        end
        xR = linspace(meanR-4*sigmaR,meanR+4*sigmaR,R_res);%(meanR-4*sigmaR):dR:(meanR+4*sigmaR);
        xR = xR(xR > 0)';
        pR = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR-meanR).^2)./(2*sigmaR.^2));
        
        t = repmat((0:n-1),[numel(pR),1]); % time axis
        
        k_RET = (1./tau0).*((R0./xR).^6); % k_RET as a function of R, evaluated based on the respective tau0
        kD = (1./tauD0) + repmat(k_RET,[1,size(t,2)]);

        xdist(j,:) = sum(repmat(pR,[1,size(t,2)]).*...
                         exp(-t.*kD),1);
        xdist(j,:) = xdist(j,:)./sum(pR);
    end
    xdist = (fraction1*xdist(1,:)+(1-fraction1)*xdist(2,:));
end

%%% Add donor only contribution
xDonly = f1_donly*exp(-(0:n-1)./tauD01)+(1-f1_donly)*exp(-(0:n-1)./tauD02);    
x = fraction_donly.*xDonly + (1-fraction_donly).*xdist;
switch conv_type
    case 'linear'
        z = conv(irf, x); z = z(1:n)';
        zDonly = conv(irf,xDonly); zDonly = zDonly(1:n)';
    case 'circular'
        z = convol(irf,x(1:n));
        zDonly = convol(irf,xDonly(1:n));
end
z = z./repmat(sum(z,1),size(z,1),1);
z = (1-sc).*z + sc*Scatter;
z = z(ignore:end);
z = z./sum(z);
z = z.*(1-bg)+bg./numel(z);z = z.*sum(y(1,:));
z=z';

zDonly = zDonly./sum(zDonly);
zDonly = (1-sc_donly).*zDonly + sc_donly*Scatter;
zDonly = zDonly(ignore:end);
zDonly = zDonly./sum(zDonly);
zDonly = zDonly.*(1-bg_donly)+bg_donly./numel(zDonly);
zDonly = zDonly.*sum(y(2,:));

z = [z zDonly'];


%%% old approach with using separate Förster distances
function old()
%%% correct Förster radius for quenching
%%% assume, that the longer donor-only lifetime belongs to the unquenched species
tauD0 = [tauD01;tauD02];
tic
R0_q = R0*ones(2,1);
quenched = 1 + (tauD01 > tauD02);
unquenched = 3-quenched;
R0_q(quenched) = R0*(tauD0(quenched)./tauD0(unquenched)).^(1/6);
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
    xR = (meanR-4*sigmaR):dR:(meanR+4*sigmaR);
    xR = xR(xR > 0);
    pR = (1/(sqrt(2*pi())*sigmaR))*exp(-((xR-meanR).^2)./(2*sigmaR.^2));
    
    xdist(j,:) = zeros(1,n);
    for i = 1:numel(xR)
        xdist(j,:) = xdist(j,:) + pR(i).*...
            (f1_donly*exp(-((0:n-1)./tauD01).*(1+(R0_q(1)./xR(i)).^6))+...
             (1-f1_donly)*exp(-((0:n-1)./tauD02).*(1+(R0_q(2)./xR(i)).^6)));
    end
    xdist(j,:) = xdist(j,:)./sum(pR);
end
xdist_old = xdist';
toc
