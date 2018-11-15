function model = MultiGaussFit_1D(x,xdata)
global BurstMeta
xbins = xdata{1};
N_datapoints = xdata{2};
fixed = xdata{3};
nG = xdata{4};
plot = xdata{5};

%%% x contains the parameters for fitting in order
%%% fraction,mu1,mu2,var1,var2,cov12
%%% i.e. 6*n_species in total
if ~plot
    %%% deal with fixed parameters
    P=zeros(numel(fixed),1);
    %%% Assigns fitting parameters to unfixed parameters of fit
    P(~fixed)=x;
    %%% Assigns parameters from table to fixed parameters
    P(fixed)=BurstMeta.GaussianFit.Params(fixed);
else
    P = x';
end
%%% A total of 3 2D gauss are considered
model = zeros(1,numel(xbins));
for i = 1:nG
    pdf = P(1+(i-1)*3)*normpdf(xbins,P(2+(i-1)*3),P(3+(i-1)*3));
    model = model + pdf;
end
model = model./max([1,sum(model)]);
model = model.*N_datapoints;
if numel(xdata) > 5 %%% sigma is last parameter
    %%% divide by sigma
    model = model./xdata{6};
end