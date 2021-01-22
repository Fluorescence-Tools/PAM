% Gopich Szabo likelihood function
function logL = GP_logL_3C(t,c,K,E)
% t -   Macrotimes of photons
% c -   Color of photons (1->D,2->A)
% K -   transition rate matrix
% E -   FRET efficiencies of states

% diagonalize K matrix
[U,Lambda] = eig(K); % U is the right eigenvector
% i.e. U*Lambda*U^(-1) yields K

ev = diag(Lambda);
% get equilibrium fraction
[~,idx_ev0] = min(abs(diag(Lambda)));
p_eq = U(:,idx_ev0)./sum(U(:,idx_ev0));

% convert macotimes to delay times
dt = diff(t);

% transform E matrix using U
Phi_A1 = U^(-1)*E(:,:,1)*U;
Phi_A2 = U^(-1)*E(:,:,2)*U;
Phi_D = eye(size(Phi_A1))-Phi_A1-Phi_A2;
Phi = zeros(size(Phi_D,1),size(Phi_D,2),3);
Phi(:,:,1) = real(Phi_D);
Phi(:,:,2) = real(Phi_A1);
Phi(:,:,3) = real(Phi_A2);

% transform p_qe
p0 = U^(-1)*p_eq;

% initialize first factor
c1 = c(1);
c = c(2:end);

% initialize logL
L = Phi(:,:,c1)*p0;
% initialize scaling correction
a = zeros(numel(dt),1);
for i = 1:numel(dt)
    L = Phi(:,:,c(i))*diag(exp(ev*dt(i)))*L;
    % scaling to avoid underflow
    a(i) = abs(1/sum(L));
    L = L*a(i);
end
% sum over states
L = ones(1,size(E,1))*U*L;
% return logL, corrected for the scaling
logL = real(log(L) - sum(log(a)));
% sometimes, logL can have a small (1E-12) complex part.
% It is not clear why this may occur. (Numeric instabilities?)
