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
f = figure('Color',[1,1,1]);
ax = axes(f,'NextPlot','add','FontSize',18,'Color',[1,1,1],'LineWidth',1,'Box','on');
xlabel(ax,'E_{app}'); ylabel(ax,'1/S_{app}');
if nargin < 4 %%% plot without errorbars
    plot(E,1./S,'+','MarkerSize',25);
    plot(x,y,'-k');
    text(0.05,0.9*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1),sprintf('\\gamma = %.3f\n\\beta = %.3f',gamma,beta),'FontSize',18);
else
    errorbar(E,S_rec,sS_rec,sS_rec,sE,sE,'.');
    plot(x,y,'-k');
    text(0.05,0.9*(ax.YLim(2)-ax.YLim(1))+ax.YLim(1),sprintf('\\gamma = %.3f \\pm %.2f\n\\beta = %.3f \\pm %.3f',gamma,sgamma,beta,sbeta),'FontSize',18);
end
%%% add button to use values in BurstBrowser
bt = uicontrol('Style','pushbutton','Units','normalized','Parent',f,...
    'Position',[0.75,0.01,0.24,0.06],'String','Apply Values','FontSize',18,...
    'Callback',{@ApplyGammaBeta,gamma,beta});


function ApplyGammaBeta(~,~,gamma,beta)
global UserValues BurstMeta BurstData
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;
%%% Update UserValues
UserValues.BurstBrowser.Corrections.Gamma_GR = gamma;
UserValues.BurstBrowser.Corrections.Beta_GR = beta;

if ~h.MultiselectOnCheckbox.UserData
    BurstData{file}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
    BurstData{file}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
else %%% Update for all files contributing
    sel_file = BurstMeta.SelectedFile;
    Files = get_multiselection(h);
    for i = 1:numel(Files)
        BurstMeta.SelectedFile = Files(i);
        BurstData{Files(i)}.Corrections.Gamma_GR = UserValues.BurstBrowser.Corrections.Gamma_GR;
        BurstData{Files(i)}.Corrections.Beta_GR = UserValues.BurstBrowser.Corrections.Beta_GR;
        ApplyCorrections([],[],h,0);
    end
    BurstMeta.SelectedFile = sel_file;
end

%%% Quantify the consistency of the corrected data
%%% Agreement with E-tau plot
%%% Deviation from S=0.5 line
check_gamma_beta_consistency(h);
%%% Save and Update GUI
% Save UserValues
LSUserValues(1);
% Update Correction Table Data
UpdateCorrections([],[],h);
% Apply Corrections
ApplyCorrections(h.FitGammaButton,[]);
