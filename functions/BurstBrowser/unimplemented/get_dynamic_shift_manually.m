%%% calculates the dynamic shift from the data marker placed on the peak of
%%% the population in the E-tau plot
global BurstMeta BurstData
h = guidata(findobj('Tag','BurstBrowser'));

% get tauD0
tauD0 = BurstData{BurstMeta.SelectedFile}.Corrections.DonorLifetime;

f = figure;
copyobj(h.axes_lifetime_ind_2d,f);
set(gca,'Color',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Position',[0.15,0.15,0.65,0.8]);
ax = gca;
% change XData to normalized lifetime
c = ax.Children;
for i = 1:numel(c)
    c(i).XData = c(i).XData./tauD0;
end
xlabel('\tau_{D(A)}/\tau_{D(0)}');
ax.XLim(2) = ax.XLim(2)./tauD0;

dcm = datacursormode;
disp('Click line to display a data tip, then press "Return"')
pause 
point = dcm.getCursorInfo.Position(1:2);

% get the static FRETline
x_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData./tauD0;
y_line = BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData;

% find closest distance = dynamic shift
d = sqrt((x_line-point(1)).^2+(y_line-point(2)).^2);
[ds,ix_ds] = min(d);

fprintf('Dynamic shift: %.3f\n',ds);
hold on;
plot([point(1),x_line(ix_ds)],[point(2),y_line(ix_ds)],'k--','LineWidth',2);