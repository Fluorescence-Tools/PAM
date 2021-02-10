function logL = GP_logL_3C_burst(t_2C,c_2C,t_3C,c_3C,K,E_2C,E_3C,kT,E_TS)
% t -   Macrotimes of photons (cell array)
% c -   Color of photons (1->BB,2->BG,3->BR,4->GG,5->GR) (cell array)
% K -   transition rate matrix
% E -   FRET efficiencies of states
% optional:
% kT - if given, transition time is included in the model
% generate transiton rate matrix

if nargin < 8
    kT = 0;
    E_TS = [0,0,0];
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
	E_2C = [E_2C(1) E_TS(1) E_2C(2)];
    E_3C = [E_3C(1) E_TS(2) E_3C(2) E_3C(3) E_TS(3) E_3C(4)];
end
% fill in diagonals of K matrix
if all(diag(K) == 0)
    for i = 1:size(K,1)
        K(i,i) = -sum(K(:,i));
    end
end

%%% two color part
% convert E vector to matrix
E2C = diag(E_2C);

% calculate likelihoods
logL_2C = zeros(numel(t_2C),1);
parfor i = 1:numel(t_2C)
    logL_2C(i) = GP_logL_mex(t_2C{i},c_2C{i},K,E2C);
end
logL_2C = sum(logL_2C);

%%% three color part
E3C(:,:,1) = diag(E_3C(1:size(K,1)));
E3C(:,:,2) = diag(E_3C(end+1-size(K,1):end));
if (sum(E3C(1,1,:)) > 1) || (sum(E3C(2,2,:)) > 1)
    logL = -Inf;
    return;
end
    
% calculate likelihoods
logL_3C = zeros(numel(t_2C),1);
parfor i = 1:numel(t_2C)
    logL_3C(i) = GP_logL_3C_mex(t_3C{i},c_3C{i},K,E3C);
end
logL_3C = sum(logL_3C);

logL = logL_2C+logL_3C;