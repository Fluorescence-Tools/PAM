function plot_BVA(E,sSelected,BinCenters,sPerBin)
global UserValues
%h = guidata(findobj('Tag','BurstBrowser'));

%%% create BVA plot
%hfig = gcf;%a=gca;a.FontSize=14;a.LineWidth=1.0;a.Color =[1 1 1];
%hold on;
%X_expectedSD = linspace(0,1,1000);          
%xlabel('Proximity Ratio, E*'); 
%ylabel('SD of E*, s');
BinCenters = BinCenters';
%sigm = sqrt(X_expectedSD.*(1-X_expectedSD)./UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA);

[H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);

switch UserValues.BurstBrowser.Display.PlotType
    case 'Contour'
    % contourplot of per-burst STD
        contour(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'LineWidth',1.5,'EdgeColor','k');
        axis('xy')
        caxis([0 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
    case 'Image'       
        Alpha = H./max(max(H)) > UserValues.BurstBrowser.Display.ImageOffset/100;
        imagesc(x(1:end-1),y(1:end-1),H','AlphaData',Alpha');axis('xy');     
        %imagesc(x(1:end-1),y(1:end-1),H','AlphaData',isfinite(H));axis('xy');
        caxis([UserValues.BurstBrowser.Display.ImageOffset/100 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
    case 'Scatter'
        scatter(E,sSelected,'.','CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
    case 'Hex'
        hexscatter(E,sSelected,'xlim',[-0.1 1.1],'ylim',[0 max(sSelected)],'res',UserValues.BurstBrowser.Display.NumberOfBinsX);
end        
%patch([-0.1 1.1 1.1 -0.1],[0 0 max(sSelected) max(sSelected)],'w','FaceAlpha',0.2,'edgecolor','none','HandleVisibility','off');
%colormap(hfig,colormap(h.BurstBrowser));
% plot of expected STD
%plot(X_expectedSD,sigm,'k','LineWidth',1);

% Plot STD per Bin
sPerBin(sPerBin == 0) = NaN;
scatter(BinCenters,sPerBin,70,UserValues.BurstBrowser.Display.ColorLine2,'d','filled');

