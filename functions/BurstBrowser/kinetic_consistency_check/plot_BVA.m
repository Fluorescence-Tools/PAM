function plot_BVA(E,sSelected,BinCenters,sPerBin)
global UserValues
BinCenters = BinCenters';
[H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);

switch UserValues.BurstBrowser.Display.PlotType
    case 'Contour'
    % contourplot of per-burst STD
        contour(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'LineWidth',1,'EdgeColor','k');
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

%%% Plot STD per Bin
sPerBin(sPerBin == 0) = NaN;
scatter(BinCenters,sPerBin,70,UserValues.BurstBrowser.Display.ColorLine2,'d','filled');

