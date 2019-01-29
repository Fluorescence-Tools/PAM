function plot_BVA(E,sSelected,MarkerColor)
global UserValues BurstMeta
[H,x,y] = histcounts2(E,sSelected,UserValues.BurstBrowser.Display.NumberOfBinsX);
% contourplot of per-burst STD
%         contour(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'LineWidth',1,'EdgeColor','k','Handlevisibility','off');
%         contour(x(1:end-1),y(1:end-1),H','LevelList',max(H(:))*linspace(UserValues.BurstBrowser.Display.ContourOffset/100,1,UserValues.BurstBrowser.Display.NumberOfContourLevels),'LineWidth',1,'EdgeColor','k','Handlevisibility','off');
%         axis('xy')
%         caxis([0 max(H(:))*UserValues.BurstBrowser.Display.PlotCutoff/100]);
        
[C,contour_plot] = contour(x(1:end-1),y(1:end-1),H',UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none'); 
alpha = 2/(UserValues.BurstBrowser.Display.NumberOfContourLevels);
level = 1;
while level < size(C,2)
    n_vertices = C(2,level);
    if UserValues.BurstBrowser.Display.PlotContourLines
        BurstMeta.Plots.Multi.ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),MarkerColor,'FaceAlpha',alpha,'EdgeColor',MarkerColor,'HandleVisibility','off');
    else
        BurstMeta.Plots.Multi.ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),MarkerColor,'FaceAlpha',alpha,'EdgeColor','none','HandleVisibility','off');
    end
    level = level + n_vertices +1;
end
delete(contour_plot);