%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% General 1D-Gauss Fit Function  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mean,GaussFun,Gauss1,Gauss2] = GaussianFit(x_data,y_data,mean_new)
%%% Inputs:
%%% xdata/ydata     : Data to Fit
%%% mean_new        : User-defined mean value
%%%
%%% Outputs:
%%% mean            : Determined Mean Value
%%% GaussFun        : The Values of the FitFunction at xdata
%%% Gauss1/2        : The Values of Gauss1/2 at xdata for multi-Gauss fit
if any(size(x_data) ~= size(y_data))
    y_data = y_data';
end
%% fit with 1 Gaussian
Gauss = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;

A = max(y_data);%set amplitude as max value
m = sum(y_data.*x_data)./sum(y_data);%mean as center value
s = sqrt(sum(y_data.*(x_data-m).^2)./sum(y_data));%std as sigma
if s == 0
    s = 1;
end
b=0;%assume zero background
param = [A,m,s,b];

if nargin == 3 %%% output the Gauss with new mean value
    GaussFun = Gauss(A,mean_new,s,b,x_data);
    [mean,Gauss1,Gauss2] = deal([]);
    return;
end

if sum(y_data) <= 10 %%% low amount of data, take mean and std instead
    mean = m;
    GaussFun = Gauss(A,m,s,0,x_data);
    GaussFun = (GaussFun./max(GaussFun)).*max(y_data);
    return;
end
[gauss, gof] = fit(x_data,y_data,Gauss,'StartPoint',param,'Lower',[0,-Inf,0,0],'Upper',[Inf,Inf,Inf,A/4]);
coefficients = coeffvalues(gauss);
mean = coefficients(2);
GaussFun = Gauss(coefficients(1),coefficients(2),coefficients(3),coefficients(4),x_data);

if gof.adjrsquare < 0.95 %%% fit was bad
    %%% fit with 2 Gaussians
    Gauss2fun = @(A1,m1,s1,A2,m2,s2,b,x) (A1./sqrt(2*pi*s1)).*exp(-(x-m1).^2./s1^2)+(A2./sqrt(2*pi*s2)).*exp(-(x-m2).^2./s2^2)+b;
    if nargin <5 %no start parameters specified
        A1 = max(y_data);%set amplitude as max value
        A2 = A1;
        m1 = sum(y_data.*x_data)./sum(y_data);%mean as center value
        m2 = m1;
        s1 = sqrt(sum(y_data.*(x_data-m1).^2)./sum(y_data));%std as sigma
        s2 = s1;
        b=0;%assume zero background
        param = [A1,m1,s1,A2,m2,s2,b];
    end
    LB = zeros(1,numel(param)); LB([2,5]) = -1;
    [gauss,~] = fit(x_data,y_data,Gauss2fun,'StartPoint',param,'Lower',LB,'Upper',[inf(1,numel(param)-1),A1/4]);
    coefficients = coeffvalues(gauss);
    %get maximum amplitude
    [~,Amax] = max([coefficients(1) coefficients(4)]);
    if Amax == 1
        mean = coefficients(2);
    elseif Amax == 2
        mean = coefficients(5);
    end
    GaussFun = Gauss2fun(coefficients(1),coefficients(2),coefficients(3),coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
    G1 = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
    Gauss1 = G1(coefficients(1),coefficients(2),coefficients(3),coefficients(7)/2,x_data);
    Gauss2 = G1(coefficients(4),coefficients(5),coefficients(6),coefficients(7)/2,x_data);
    if nargin == 3 %%% output the Gauss with new mean value
        if Amax == 1
            coefficients(2) = mean_new;
        elseif Amax == 2
            coefficients(5) = mean_new;
        end
        GaussFun = Gauss2fun(coefficients(1),coefficients(2),coefficients(3),coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
    end
end
if mean < 0
    mean = 0;
end