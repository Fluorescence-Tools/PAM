function model = MultiGaussFit(x,xdata)
global BurstMeta
xbins = xdata{1};
ybins = xdata{2};
N_datapoints = xdata{3};
fixed = xdata{4};
nG = xdata{5};
plot = xdata{6};
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
[X,Y] = meshgrid(xbins,ybins);
model = zeros(numel(ybins),numel(xbins));
for i = 1:nG
    COV = [P(4+(i-1)*6),P(6+(i-1)*6);P(6+(i-1)*6),P(5+(i-1)*6)];
    [~,f] = chol(COV);
    if f~=0 %%% error
        COV = fix_covariance_matrix(COV);
    end
    pdf = P(1+(i-1)*6)*mvnpdf([X(:) Y(:)],P([2:3]+(i-1)*6)',COV);
    model = model + reshape(pdf,[numel(ybins),numel(xbins)]);
end
model = model./max([1,sum(sum(model))]);
model = model.*N_datapoints;
if numel(xdata) > 6 %%% sigma is last parameter
    %%% divide by sigma
    model = model./xdata{7};
end