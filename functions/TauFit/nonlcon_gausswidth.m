function [c,ceq] = nonlcon_gausswidth(x,R_E_exp)
%%% restrict the parameters (distance, width) of a distance distribution
%%% fit to match a provided FRET-averaged distance
% R_E_exp: experimentally determined FRET-averaged distance
% empty inequality constraint
c = [];

%%% calculate the FRET averaged model distance R_E_m
R = x(1); % center R
s = x(2); % sigmaR = width
R0 = x(5); % Förster radius

% calcualte the distance distribution
r = linspace(max([R-3*s,0]),R+3*s,1000);
pR = normpdf(r,R,s); pR = pR./sum(pR);
E = (1+(r/R0).^6).^(-1);
mE = sum(pR.*E);
R_E_m = R0.*(1./mE-1)^(1/6);

ceq = R_E_m-R_E_exp;