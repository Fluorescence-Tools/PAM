function copy_figure_to_clipboard()
%%% copies the currently selected figure/axes to clipboard as png
h = guidata(findobj('Tag','BurstBrowser'));
% get current axis
ax = gca;
% call the correct right-click menu in place
if ax.Parent == h.LifetimePanelAll
    ax = h.LifetimePanelAll;
end
switch ax
    case h.axes_1d_x
        obj = h.Export1DX_Menu;
    case h.axes_1d_y
        obj = h.Export1DY_Menu;
    case h.axes_general
        obj = h.Export2D_Menu;
    case h.LifetimePanelAll
        obj = h.ExportLifetime_Menu;
    case {h.axes_lifetime_ind_1d_y,h.axes_lifetime_ind_1d_x,h.axes_lifetime_ind_2d}
        obj = h.Export2DLifetime_Menu;
    otherwise
        return;
end
% call ExportGraphs for this axis
fig = ExportGraphs(obj,[],0);

if verLessThan('matlab','9.8') %%% earlier than 2020a, copy as bitmap
    print(fig,'-clipboard','-dbitmap');
else
    %%% from 2020a, there is a new function available
    copygraphics(fig,'ContentType','image','Resolution',150)
end
delete(fig);