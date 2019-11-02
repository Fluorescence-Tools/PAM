%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates dynamic FRET line between two states  %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func, xval] = dynamicFRETline_3C(tauD,tau1,tau2,R0BG,R0BR,sBG,sBR)
res = 1000;
if tau1 > tau2
    xval  = linspace(tau2,tau1,1000);
else
    xval  = linspace(tau1,tau2,1000);
end
%%% Calculate dynamic FRET line for 3C FRET between two states

% tau1 and tau2 are the clicked points in the plot, i.e. the
% intensity-weighted average lifetimes

% determine the corresponding FRET efficiencies
[~,tau_to_E] = conversion_tau_3C(tauD,R0BG,R0BR,sBG,sBR);
E1 = tau_to_E(tau1);
E2 = tau_to_E(tau2);

% convert tau and E to the moments of the distribution
m1_1 = (1-E1)*tauD; m1_2 = (1-E2)*tauD;
m2_1 = tau1*m1_1; m2_2 = tau2*m1_2; 

%%% Mix moments
x = linspace(0,1,res);
m1 = m1_1.*x+m1_2.*(1-x);
m2 = m2_1.*x+m2_2.*(1-x);

% convert back to lifetimes and FRET efficiencies
E_dyn = 1-m1./tauD;
tau_dyn = m2./m1;

out = 1-interp1(tau_dyn,(1-E_dyn).*tauD,xval)./tauD;
if nargout > 1
    func = @(x) 1-interp1(tau_dyn,(1-E_dyn).*tauD,xval)./tauD;
end