function [gamma,beta] = gamma_from_ES(E,S,sE,sS)
%%% fit 1/S vs E with f(x) = m*x+b

if numel(E) ~= numel(S)
    disp('Input values must have same number of elements!');
    return;
end
if numel(E) == 1
    disp('Need at least two datapoints.');
    return;
end
if nargin < 4 %%% no weights are specified
    if numel(E) == 2
        %%% calculation
        m = (1/S(1)-1/S(2))/(E(1)-E(2));
        b = 1/S(1) - m*E(1);
    else
        %%% perform a fit
        if size(E,1) < size(E,2); E = E';end
        if size(S,1) < size(S,2); S = S';end 
        fitres = fit(E,1./S,'poly1');
        c = coeffvalues(fitres);
        m = c(1); b = c(2);
    end
    gamma =  (b - 1)/(b + m - 1);
    beta = b + m -1;
else %%% do a fit with weights
    if numel(S) ~= numel(sS) || numel(E) ~= numel(sE)
        disp('Wrong number of weights');
        return;
    end
    %%% make everything row vectors
    if size(E,2) < size(E,1); E = E';end
    if size(S,2) < size(S,1); S = S';end 
    if size(sE,2) < size(sE,1); sE = sE';end
    if size(sS,2) < size(sS,1); sS = sS';end
    %%% use error propagation to determine the error in 1/S
    sS_rec = sS./(S.^2);
    S_rec = 1./S;
    %%% use york_fit.m for linear regression with both x and y errorbars
    [b, m, sigma_b, sigma_m] = york_fit(E,S_rec,sE,sS_rec);
    
    gamma =  (b - 1)/(b + m - 1);
    beta = b + m -1;
    
    %%% use error propagation to estimate the error in gamma and beta
    sbeta = sqrt(sigma_m^2+sigma_b^2);
    sgamma = sqrt( (sigma_b/beta)^2 + ((b-1)^2/beta^4)*sbeta^2 );
end


%%% plot the result
x = linspace(0,1); y = b + m.*x;
f = figure();
ax = axes(f,'NextPlot','add','FontSize',14);
xlabel(ax,'E'); ylabel(ax,'1/S');
if nargin < 4 %%% plot without errorbars
    plot(E,1./S,'+');
    plot(x,y,'-k');
    text(0.05,0.9*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1),sprintf('\\gamma = %.3f\n\\beta = %.3f',gamma,beta),'FontSize',14);
else
    errorbar(E,S_rec,sS_rec,sS_rec,sE,sE,'.');
    plot(x,y,'-k');
    text(0.05,0.9*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1),sprintf('\\gamma = %.3f \\pm %.2f\n\\beta = %.3f \\pm %.3f',gamma,sgamma,beta,sbeta),'FontSize',14);
end
