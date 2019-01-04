function BVA_dynamic_FRET(E1,E2,n)

% the variance in the presence of conformational dynamics is the sum of the
% shot-noise variance and the variance due to conformational dynamics (see
% e.g. Gopich IV, Szabo A (2007) Single-Molecule FRET with Diffusion and
% Conformational Dynamics. J Phys Chem B 111(44):12925?12932.)

% variance under the assumption of simple addtion:
% var_c = p1.*(E1-E_dyn).^2 + (1-p1).*(E2-E_dyn).^2;
% var_static = E_dyn.*(1-E_dyn)./n;
% sig_dyn = sqrt(var_c + var_static);

%E = 0:0.001:1;
%static_line = sqrt(E.*(1-E)./n);

p1 = 0:0.001:1;
E_dyn = p1.*E1 + (1-p1).*E2;
var_dyn = p1.*((E1*(1-E1)/n + E1^2)) + (1-p1).*((E2*(1-E2)/n) + E2^2) - E_dyn.^2;
sig_dyn = sqrt(var_dyn);
plot(E_dyn,sig_dyn,'--k','LineWidth',2);