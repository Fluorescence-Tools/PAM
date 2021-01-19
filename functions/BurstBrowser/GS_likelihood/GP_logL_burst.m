function logL = GP_logL_burst(t,c,K,E,kT)
% t -   Macrotimes of photons (cell array)
% c -   Color of photons (1->D,2->A) (cell array)
% K -   transition rate matrix
% E -   FRET efficiencies of states
% optional:
% kT - if given, transition time is included in the model
% generate transiton rate matrix

if nargin < 5
    kT = 0;
end

if kT == 0
    switch numel(K)
        case 2% 2 state network
            K = rot90(diag(K));
        case 6 % 3 state network
            K = [0,K(1),K(2);...
                 K(3),0,K(4);...
                 K(5),K(6),0];
    end
else % transition time model
    % transition rate matrix with kT to and from the transition state
    % k12 and k21 are doubled because the probability to pass the
    % transition state is 0.5!
    K = [0,kT,0;
        2*K(1),0,2*K(2);
        0,kT,0];
    % set E of intermediate state to average
    E = [E(1),sum(E)/2,E(2)];
end
% fill in diagonals of K matrix
if all(diag(K) == 0)
    for i = 1:size(K,1)
        K(i,i) = -sum(K(:,i));
    end
end
% convert E vector to matrix
E = diag(E);

% calculate likelihoods
logL = zeros(numel(t),1);
parfor i = 1:numel(t)
    logL(i) = GP_logL_mex(t{i},c{i},K,E);
end
logL = sum(logL);