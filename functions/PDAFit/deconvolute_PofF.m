function PofF = deconvolute_PofF(S,bg,resolution)
%%% deconvolutes input PofF using a sum of Poisson distributios as kernel
%%% to obtain background-free fluorescence signal distribution PofF
%%%
%%% See: Kalinin, S., Felekyan, S., Antonik, M. & Seidel, C. A. M. Probability Distribution Analysis of Single-Molecule Fluorescence Anisotropy and Resonance Energy Transfer. J. Phys. Chem. B 111, 10253?10262 (2007).

%%% Input parameter:
%%% S   -   the experimentally observed burst sizes
%%% bg  -   the total background
%%% resolution - resolution for brightness vector

if nargin < 3
    resolution = 200;
end
%%% Construct the histogram PF
xS = 0:1:max(S)+1;
PS= histcounts(S,xS);
xS = xS(1:end-1);
%%% vector of brightnesses to consider
b = linspace(0,max(S),resolution);

%%% Establish Poisson library based on brightness vector INCLUDING background
%%% convolution of model PofF with Poissonian background simplifies to
%%% using a modified brightness b' = b + bg
%%% This follows because the convolution of two Poissonian distributions
%%% equals again a Poissonian with sum of rate parameters.
%%% see equation 12 of reference
PS_ind = poisspdf(repmat(xS,numel(b),1),repmat(bg+b',1,numel(xS)));

%%% Calculate error estimate based on poissonian counting statistics
error = sqrt(PS); error(error == 0) = 1;

%%% equation 12 of reference to calculate PofS from library
% sum(PS_ind.*repmat(p,1,numel(xS),1)) = P(S)
%%% scaling parameter for the entropy term
v = 10;
mem = @(p) -(v*sum(p-p.*log(p)) - sum( (PS-sum(PS_ind.*repmat(p,1,numel(xS),1)).*numel(S)).^2./error.^2)./(numel(PS)));
%%% initialize p
p0 = ones(numel(b),1)./numel(b);
p=p0;

%%% initialize boundaries
Aieq = -eye(numel(p0)); bieq = zeros(numel(p0),1);
lb = zeros(numel(p0),1); ub = inf(numel(p0),1);

%%% specify fit options
opts = optimoptions(@fmincon,'MaxFunEvals',1E5,'Display','iter','TolFun',1E-3);
p = fmincon(mem,p,Aieq,bieq,[],[],lb,ub,@nonlcon,opts); 

%%% construct distribution PofF from distribution over brightnesses
%%% this time, we exculde background to obtain the "purified" fluorescence
%%% count distribution
PF_ind = poisspdf(repmat(xS,numel(b),1),repmat(b',1,numel(xS)));
PofF = sum(PF_ind.*repmat(p,1,numel(xS),1));
PofF = PofF./sum(PofF);

function [c,ceq] = nonlcon(x)
%%% nonlinear constraint for deconvolution
c = [];
ceq = sum(x) - 1;