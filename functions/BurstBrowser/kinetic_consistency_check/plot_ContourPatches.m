function plot_ContourPatches(axes,H,x,y,MarkerColor)
global UserValues       
[C,contour_plot] = contour(x(1:end-1),y(1:end-1),H',UserValues.BurstBrowser.Display.NumberOfContourLevels,'LineColor','none'); 
alpha = 2/(UserValues.BurstBrowser.Display.NumberOfContourLevels);
level = 1;
while level < size(C,2)
    n_vertices = C(2,level);
    if UserValues.BurstBrowser.Display.PlotContourLines
        %BurstMeta.Plots.Multi.ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),MarkerColor,'FaceAlpha',alpha,'EdgeColor',MarkerColor,'HandleVisibility','off');
        patch(axes,C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),MarkerColor,'FaceAlpha',alpha,'EdgeColor',MarkerColor,'HandleVisibility','off');
    else
        %BurstMeta.Plots.Multi.ContourPatches(end+1) = patch(C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),MarkerColor,'FaceAlpha',alpha,'EdgeColor','none','HandleVisibility','off');
        patch(axes,C(1,level+1:level+n_vertices),C(2,level+1:level+n_vertices),MarkerColor,'FaceAlpha',alpha,'EdgeColor','none','HandleVisibility','off');
    end
    level = level + n_vertices +1;
end
delete(contour_plot);