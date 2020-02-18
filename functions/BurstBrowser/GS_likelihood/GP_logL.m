% Gopich Szabo likelihood function
function logL = GP_logL(t,c,K,E)
% t -   Macrotimes of photons
% c -   Color of photons (1->D,2->A)
% K -   transition rate matrix
% E -   FRET efficiencies of states

K = rot90(diag(K));
% fill in diagonals of K matrix
if all(diag(K) == 0)
    for i = 1:size(K,1)
        K(i,i) = -sum(K(:,i));
    end
end

% convert E vector to matrix
E = diag(E);

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
Phi_r = U^(-1)*E*U;
Phi_g = eye(size(Phi_r))-Phi_r;
Phi = zeros(size(Phi_g,1),size(Phi_g,2),2);
Phi(:,:,1) = real(Phi_g);
Phi(:,:,2) = real(Phi_r);

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
L = [1,1]*U*L;
% return logL, corrected for the scaling
logL = log(L) - sum(log(a));
