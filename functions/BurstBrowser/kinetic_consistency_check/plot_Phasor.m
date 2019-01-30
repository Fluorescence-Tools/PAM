function plot_Phasor(g,s)
global UserValues
h = guidata(findobj('Tag','BurstBrowser'));
%%% plot phasors
[H,x,y] = histcounts2(g,s,UserValues.BurstBrowser.Display.NumberOfBinsX,'XBinLimits',[-0.1,1.1],'YBinLimits',[0,0.75]);
H = H./max(H(:));
f = figure('Color',[1,1,1],'Position',[100,100,600,600]); hold on;
contourf(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'EdgeColor','none');
ax = gca;
ax.CLimMode = 'auto';
ax.CLim(1) = 0;
ax.CLim(2) = max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100;
colormap(f,colormap(h.BurstBrowser));
%%% plot circle
g_circle = linspace(0,1,1000);
s_circle = sqrt(0.25-(g_circle-0.5).^2);
plot(g_circle,s_circle,'-','LineWidth',2,'Color',[0,0,0]);

ax.XLim = [-0.1,1.1];
ax.YLim = [0,0.75];
xlabel('g');
ylabel('s');
set(gca,'FontSize',24,'LineWidth',2,'Box','on','XColor',[0,0,0],'YColor',[0,0,0],'Layer','top');