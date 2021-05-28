function export_burst_preview(obj,~)
h = guidata(obj);
%%% Plot the data
lw = 1.5;
fs = 18;
hfig = figure('Position',[100,100,800,600],'Color',[1,1,1]);

ax1 = copyobj(h.Burst.Axes_Intensity,hfig);
ax2 = copyobj(h.Burst.Axes_Interphot,hfig);

set(ax1,'Position',[0.1,0.5,0.85,0.4],'Color',[1,1,1],'Box','on','Linewidth',lw,'FontSize',fs,'XColor',[0,0,0],'YColor',[0,0,0]);
set(ax2,'Position',[0.1,0.1,0.85,0.4],'Color',[1,1,1],'Box','on','Linewidth',lw,'FontSize',fs,'XColor',[0,0,0],'YColor',[0,0,0]);

linkaxes([ax1,ax2],'x');