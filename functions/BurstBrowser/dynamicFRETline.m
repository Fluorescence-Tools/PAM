%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates dynamic FRET line between two states  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func, xval] = dynamicFRETline(tauD,tau1,tau2,R0,s)
res = 1000;

if nargin == 3 %%% array of E and tau values is passed
    tau = tau1; % ratio of second to first moment, m2/m1
    E = tau2; % 1-m1/tauD
    % calculate moments
    m1 = (1-E).*tauD; m1_1 = m1(1); m1_2 = m1(2);
    m2 = tau.*m1; m2_1 = m2(1); m2_2 = m2(2);
else
    if numel(s) == 1
        %%% only one global sigma specified, assign to all states
        s = ones(2,1)*s;

        RDA1 = conversion_tau(tauD,R0,s(1),tau1);
        RDA2 = conversion_tau(tauD,R0,s(2),tau2);
    else
        %%% input was distances, not lifetimes
        RDA1 = tau1;
        RDA2 = tau2;
    end

    %%% calculate distributions
    r = linspace(0*R0,3*R0,res);
    p1 = exp(-((r-RDA1).^2)./(2*s(1)^2));p1 = p1./sum(p1);
    p2 = exp(-((r-RDA2).^2)./(2*s(2)^2));p2 = p2./sum(p2);
    %%% convert r to lifetime
    tau = tauD./(1+((R0./r).^6));

    %%% calculate first and second moments
    m1_1 = sum(p1.*tau); m2_1 = sum(p1.*tau.^2);
    m1_2 = sum(p2.*tau); m2_2 = sum(p2.*tau.^2);
end

%%% calculate state lifetimes
tau1 = m2_1./m1_1; tau2 = m2_2./m1_2;
%%% mix moments
x = linspace(0,1,res);
m1 = m1_1.*x+m1_2.*(1-x);
m2 = m2_1.*x+m2_2.*(1-x);

%%% convert back to species and intensity weighted lifetimes
taux = m1;
tauf = m2./m1;

if tau1 > tau2
    xval  = linspace(tau2,tau1,1000);
else
    xval  = linspace(tau1,tau2,1000);
end

out = 1-interp1(tauf,taux,xval)./tauD;
if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end

%%%%%%%%%%%%%%%%%%%
%%% legacy code %%%
%%%%%%%%%%%%%%%%%%%

%%% Calculate two distance distribution for two states
%%% convert input lifetime (intensity-weighted) to center distance given sigmaR

%%% Generate mixed distributions
% x = linspace(0,1,res);
% p = zeros(res,res);
% for i = 1:numel(x)
%     p(i,:) = x(i).*p1 + (1-x(i)).*p2;
% end
% 
% %calculate lifetime distribution
% tau = tauD./(1+((R0./r).^6));
% 
% 
% %calculate species weighted taux
% taux = zeros(1,numel(x));
% for j = 1:numel(x)
%     taux(j) = sum(p(j,:).*tau);
% end
% 
% %calculate intensity weighted tauf
% tauf = zeros(1,numel(x));
% for j = 1:numel(x)
%     tauf(j) = sum(p(j,:).*(tau.^2))./taux(j);
% end
