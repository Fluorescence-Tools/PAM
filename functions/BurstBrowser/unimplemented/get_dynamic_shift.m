%%% determines the dynamic shift from fitting the population in the E-tau plot
%%% Perform a fit of E vs tauD(A) first!
global BurstMeta BurstData UserValues
h = guidata(findobj('Tag','BurstBrowser'));

if ~strcmp(BurstMeta.Fitting.ParamX,'Lifetime D [ns]') || ~strcmp(BurstMeta.Fitting.ParamY,'FRET Efficiency') 
    disp('Perform a 2D fit of FRET efficiency vs Lifetime D [ns]');
    return;
end
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);

% get tauD0
tauD0 = BurstData{BurstMeta.SelectedFile}.Corrections.DonorLifetime;

% BurstMeta.Fitting.FitResults contains the result in order:
% (amp, mu1, mu2, sigma1, simga2, cov12)*Nspecies LogL BIC
nGauss = numel(BurstMeta.Fitting.FitResult(1:end-2))/6;
res = reshape(BurstMeta.Fitting.FitResult(1:end-2),[6,nGauss]);
% find main population by amplitude and get muTau, muE, sTau, sE
[~,ix] = max(res(1,:));
res = res(:,ix);
A = res(1);
muTau = res(2)/tauD0;
muE = res(3);
sTau = res(4)/tauD0;
sE = res(5);

% get total number of bursts in population
Nbursts = A*size(BurstData{BurstMeta.SelectedFile}.DataCut,1);
% get SEM towards static FRET line
sigma = sqrt(sE.^2+sTau.^2)./sqrt(2);
SEM = sigma./sqrt(Nbursts);

f = figure('Color',[1,1,1]);
copyobj(h.axes_lifetime_ind_2d,f);
colormap(colormap(h.BurstBrowser));
set(gca,'Color',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Position',[0.15,0.15,0.65,0.74],'FontSize',14);
ax = gca;
% change XData to normalized lifetime
c = ax.Children;
for i = 1:numel(c)
    c(i).XData = c(i).XData./tauD0;
end
xlabel('\tau_{D(A)}/\tau_{D(0)}');
ax.XLim(2) = ax.XLim(2)./tauD0;

point = [muTau,muE];
% get the static FRETline
x_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./tauD0;
y_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData;

% find closest distance = dynamic shift
d = sqrt((x_line-point(1)).^2+(y_line-point(2)).^2);
[ds,ix_ds] = min(d);

%fprintf('Dynamic shift: %.3f\n',ds);
hold on;
scatter(point(1),point(2),200,'x','MarkerEdgeColor','k','LineWidth',2);
plot([point(1),x_line(ix_ds)],[point(2),y_line(ix_ds)],'k--','LineWidth',2);

%%% add population
if nGauss == 1
    ix = 0;
end
x = BurstMeta.Plots.Mixture.Main_Plot(ix+1).XData./tauD0;
y = BurstMeta.Plots.Mixture.Main_Plot(ix+1).YData;
z = BurstMeta.Plots.Mixture.Main_Plot(ix+1).ZData; z = z./max(z(:));
LevelList = 0.32;
[c,hC] = contour(x,y,z,'LevelList',LevelList,'Fill','off','LineColor',[0,0,0],'LineWidth',2,'ShowText','off');
viscircles([point;point],[SEM,sigma],'LineStyle','-');

title(sprintf('dynamic shift = %.3f\nSEM of population = %.4f',ds,SEM),'FontSize',14);
Mat2clip([ds,SEM]);