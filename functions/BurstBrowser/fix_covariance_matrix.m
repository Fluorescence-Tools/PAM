function [covNew] = fix_covariance_matrix(cov)
%find eigenvalue smaller 0
k = min(eig(cov));
%add to matrix to make positive semi-definite
A = cov - k*eye(size(cov))+1E-6; %add small increment because sometimes eigenvalues are still slightly negative (~-1E-17)

%rescale A to match the standard deviations on the diagonal

%convert to correlation matrix
Acorr = corrcov(A);
%get standard deviations
sigma = sqrt(diag(cov));

covNew = zeros(2,2);
for i = 1:2
    for j = 1:2
        covNew(i,j) = Acorr(i,j)*sigma(i)*sigma(j);
    end
end