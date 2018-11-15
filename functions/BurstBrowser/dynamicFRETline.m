%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates dynamic FRET line between two states  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func, xval] = dynamicFRETline(tauD,tau1,tau2,R0,s)
res = 1000;
if tau1 > tau2
    xval  = linspace(tau2,tau1,1000);
else
    xval  = linspace(tau1,tau2,1000);
end
%%% Calculate two distance distribution for two states
%%% convert input lifetime (intensity-weighted) to center distance given sigmaR


%%% legacy:
%RDA1 = R0*((tauD/tau1)-1)^(-1/6);
%RDA2 = R0*((tauD/tau2)-1)^(-1/6);
%%% convert to intensity weighted lifetime
%E1 = conversion_tau(tauD,R0,s,tau1);
%E2 = conversion_tau(tauD,R0,s,tau2);
%RDA1 = R0.*(1/E1-1)^(1/6);if E1 == 0;RDA1 = 5*R0-2*s;end;
%RDA2 = R0.*(1/E2-1)^(1/6);if E2 == 0;RDA2 = 5*R0-2*s;end;

RDA1 = conversion_tau(tauD,R0,s,tau1);
RDA2 = conversion_tau(tauD,R0,s,tau2);
r = linspace(0*R0,3*R0,res);
p1 = exp(-((r-RDA1).^2)./(2*s^2));p1 = p1./sum(p1);
p2 = exp(-((r-RDA2).^2)./(2*s^2));p2 = p2./sum(p2);
%%% Generate mixed distributions
x = linspace(0,1,res);
p = zeros(res,res);
for i = 1:numel(x)
    p(i,:) = x(i).*p1 + (1-x(i)).*p2;
end

%calculate lifetime distribution
tau = tauD./(1+((R0./r).^6));


%calculate species weighted taux
taux = zeros(1,numel(x));
for j = 1:numel(x)
    taux(j) = sum(p(j,:).*tau);
end

%calculate intensity weighted tauf
tauf = zeros(1,numel(x));
for j = 1:numel(x)
    tauf(j) = sum(p(j,:).*(tau.^2))./taux(j);
end

%coefficients = polyfit(tauf,taux,3);

%out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
out = 1-interp1(tauf,taux,xval)./tauD;
if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end