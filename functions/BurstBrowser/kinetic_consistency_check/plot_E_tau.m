function plot_E_tau(E,tauD)
global UserValues BurstMeta BurstData
file = BurstMeta.SelectedFile;
% h = guidata(findobj('Tag','BurstBrowser'));
%%% plot smoothed dynamic FRET line
[H,x,y] = histcounts2(E,tauD,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,1.2]);
H = H./max(H(:)); %H(H<UserValues.BurstBrowser.Display.ContourOffset/100) = NaN;
contour(y(1:end-1),x(1:end-1),H,'LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'LineWidth',1,'EdgeColor','k');
ax = gca;
ax.CLimMode = 'auto';
ax.CLim(1) = 0;
ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
% plot patch to phase contour plot out
%patch([0,1.2,1.2,0],[-0.1,-0.1,1.1,1.1],[1,1,1],'FaceAlpha',0.5,'EdgeColor','none');
%%% add static FRET line
%plot(linspace(0,1,1000),1-linspace(0,1,1000),'-','LineWidth',2,'Color',[0,0,0]);
plot(BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData,'-','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
%plot(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).XData./BurstData{file}.Corrections.DonorLifetime,BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1).YData,'--','LineWidth',2,'Color',UserValues.BurstBrowser.Display.ColorLine1);
ax.XLim = [0,1.2];
ax.YLim = [0,1];

xlabel('\tau_{D,A}/\tau_{D,0}');
ylabel('FRET Efficiency');
set(gca,'FontSize',24,'LineWidth',2,'Box','on','DataAspectRatio',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');
