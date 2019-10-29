function tau = lifetime_correction_anisotropy(tau,r0,rho)
% correct the lifetime for the anisotropy
% errors occur because we use the average lifetime of parallel and
% perpendicular intensity, instead of Par+2*Perp.
% The error can be estimated from the anisotropy decay by the implemented
% formula.
% The formula calculates the expected value of the I_par+Iperp intensity
% decay.
tau = (2*tau + (r0/tau)*(1/tau+1/rho)^(-2))/(2+(r0/tau)*(1/tau+1/rho)^(-1));