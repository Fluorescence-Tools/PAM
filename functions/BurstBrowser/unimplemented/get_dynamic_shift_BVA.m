%%% determines the dynamic shift from fitting the population in the E-tau plot
%%% Perform a fit of E vs tauD(A) first!
global BurstMeta BurstData UserValues
h = guidata(findobj('Tag','BurstBrowser'));

if ~strcmp(BurstMeta.Fitting.ParamX,'Proximity Ratio') || ~strcmp(BurstMeta.Fitting.ParamY,'BVA standard deviation') 
    disp('Perform a 2D fit of BVA standard deviation vs Proximity Ratio');
    return;
end
% get BVA parameter: Number of photons per E sample 
N = UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA;

% BurstMeta.Fitting.FitResults contains the result in order:
% (amp, mu1, mu2, sigma1, simga2, cov12)*Nspecies LogL BIC
nGauss = numel(BurstMeta.Fitting.FitResult(1:end-2))/6;
res = reshape(BurstMeta.Fitting.FitResult(1:end-2),[6,nGauss]);
% find main population by amplitude and get muTau, muE, sTau, sE
[~,ix] = max(res(1,:));
res = res(:,ix);
A = res(1);
muPR = res(2);
muBVA = res(3);
sPR = res(4);
sBVA = res(5);

% get total number of bursts in population
Nbursts = A*size(BurstData{BurstMeta.SelectedFile}.DataCut,1);
% get SEM towards static FRET line
% approximate the radial angle
theta = atan(muBVA./(0.5-muPR));
sigma = sqrt((cos(theta).*sPR).^2+(sin(theta).*sBVA).^2)./sqrt(2);
SEM = sigma./sqrt(Nbursts);

f = figure('Color',[1,1,1]);
copyobj(h.axes_general,f);
colormap(colormap(h.BurstBrowser));
set(gca,'Color',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Position',[0.15,0.15,0.65,0.7],'FontSize',14);%,'DataAspectRatioMode','manual','DataAspectRatio',[1,1,1]);
xlim([0,1]);
ax = gca; ax.YLim(1) = 0;

point = [muPR,muBVA];
% calculate the shot-noise line
x_line = 0:0.001:1;
y_line = sqrt(x_line.*(1-x_line)./N);

% find radial distance = dynamic shift
% construct the radial line
x = linspace(0.5,point(1),1000);
y = linspace(0,point(2),1000);

[X1,X2] = meshgrid(x_line,x);
[Y1,Y2] = meshgrid(y_line,y);
d = sqrt((X1-X2).^2+(Y1-Y2).^2);
[mind,ix_ds] = min(d(:));
[ix_ds_x,ix_ds_y] = ind2sub([numel(x),numel(x_line)],ix_ds);
point2 = [X1(ix_ds), Y1(ix_ds)];
ds = sqrt(sum((point-point2).^2));

% simpler dynamic shift, not strictly radial
d = sqrt((x_line-point(1)).^2+(y_line-point(2)).^2);
[ds_min,ix_ds] = min(d);
%fprintf('Dynamic shift: %.3f\n',ds);
hold on;
plot(x,y);
scatter(point2(1),point2(2),200,'x','MarkerEdgeColor','k','LineWidth',2);
scatter(x_line(ix_ds),y_line(ix_ds),200,'x','MarkerEdgeColor','k','LineWidth',2);
plot(x_line,y_line,'k-','LineWidth',2);
scatter(point(1),point(2),200,'x','MarkerEdgeColor','k','LineWidth',2);
plot([point(1),point2(1)],[point(2),point2(2)],'k--','LineWidth',2);
plot([point(1),x_line(ix_ds)],[point(2),y_line(ix_ds)],'k--','LineWidth',2);
%%% add population
if nGauss == 1
    ix = 0;
end
x = BurstMeta.Plots.Mixture.Main_Plot(ix+1).XData;
y = BurstMeta.Plots.Mixture.Main_Plot(ix+1).YData;
z = BurstMeta.Plots.Mixture.Main_Plot(ix+1).ZData; z = z./max(z(:));
LevelList = 0.32;
[c,hC] = contour(x,y,z,'LevelList',LevelList,'Fill','off','LineColor',[0,0,0],'LineWidth',2,'ShowText','off');
viscircles([point;point],[SEM,sigma],'LineStyle','-');

title(sprintf('dynamic shift (radial) = %.3f\ndynamic shift (minimum) = %.3f\nSEM of population = %.4f',ds,ds_min,SEM),'FontSize',14);