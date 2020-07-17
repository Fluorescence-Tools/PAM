function s = viterbi(t,c,K,E)
% t -   Macrotimes of photons
% c -   Color of photons (1->D,2->A)
% K -   transition rate matrix
% E -   FRET efficiencies of states
%
% s -   states visited at time t

% generate transiton rate matrix
switch numel(K)
    case 2% 2 state network
        K = rot90(diag(K));
    case 6 % 3 state network
        K = [0,K(1),K(2);...
             K(3),0,K(4);...
             K(5),K(6),0];
end
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

% initialize E matrix
F(:,:,1) = eye(size(E)) - E;
F(:,:,2) = E;

% convert macotimes to delay times
dt = diff(t);

delta = zeros(size(K,1),numel(dt)+1);
sigma = zeros(size(K,1),numel(dt)+1);

% initialize first factor
c1 = c(1);
c = c(2:end);
delta(:,1) = F(:,:,c1)*p_eq;

for i = 1:numel(dt)
    for j = 1:size(K,1)
        expMat = expm(K*dt(i)).*repmat(delta(:,i),1,size(K,1));
        delta(:,i+1) = diag(F(:,:,c(i))).*max(expMat,[],1)';
        [~,sigma(:,i+1)] = max(expMat,[],1);
    end
end

% backtracking
s = zeros(1,numel(dt)+1);
[~,s(end)] = max(delta(:,end));
for i = (numel(s)-1):-1:1
    s(i) = sigma(s(i+1),i+1);
end

plt = true;
if plt
    c = [c1;c];
    figure('Color',[1,1,1]); hold on;
    scatter(t(c==1),1.25*ones(size(t(c==1))),100,[0,1,0],'LineWidth',2);
    scatter(t(c==2),0.75*ones(size(t(c==2))),100,[1,0,0],'LineWidth',2);
    plot(t,1/(2*size(K,1))+s/size(K,1),'--','LineWidth',2,'Color',[0,0,1]);
    ylim([1,size(K,1)+1]/size(K,1));
    set(gca,'Color',[1,1,1],'LineWidth',2,'FontSize',18);
    xlabel('Time');
    ylabel('States');
    set(gca,'YTick',(1/2+(1:size(K,1)))/size(K,1),'YTickLabels',cellfun(@(x) num2str(x),num2cell(1:size(K,1)),'UniformOutput',false));
end
