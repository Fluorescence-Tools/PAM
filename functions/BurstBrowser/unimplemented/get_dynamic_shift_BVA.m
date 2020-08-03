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
set(gca,'Color',[1,1,1],'XColor',[0,0,0],'YColor',[0,0,0],'Position',[0.15,0.15,0.65,0.63],'FontSize',14);%,'DataAspectRatioMode','manual','DataAspectRatio',[1,1,1]);
if ispc
    set(gca,'FontSize',get(gca,'FontSize')/1.4);
end
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
scatter(x_line(ix_ds),y_line(ix_ds),200,'diamond','MarkerEdgeColor','k','LineWidth',2);
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

[BVA_bin,confint] = get_BVA_binwise(muPR,sPR);
BVA_stat = sqrt(muPR.*(1-muPR)./N);
ds_bin = BVA_bin-BVA_stat;
ds_confint = confint-BVA_stat;
scatter(muPR,BVA_bin,200,'o','MarkerEdgeColor','k','LineWidth',2);
scatter(muPR,confint,200,'square','MarkerEdgeColor','k','LineWidth',2);
plot([muPR,muPR],[BVA_stat,BVA_bin],'k--','LineWidth',2);

title(sprintf('dynamic shift (radial) = %.3f\ndynamic shift (minimum) = %.3f\nSEM of population = %.4f\ndynamic shift (bin) = %.3f\nds(static) upper bound = %.4f',ds,ds_min,SEM,ds_bin,ds_confint),'FontSize',14);

Mat2clip([ds,ds_min,SEM,ds_bin,ds_confint]);

function [BVA_est,confint] = get_BVA_binwise(mE,dE)
global UserValues BurstData BurstTCSPCData BurstMeta
% return the BVA STDEV estimate in a specified bin width center mE and
% width dE
% Code adapted from Dynamic_Analysis.m

file = BurstMeta.SelectedFile;
%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
photons = BurstTCSPCData{file};
E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Proximity Ratio'));
% Remove ALEX photons &  calculate STD per Burst
n = UserValues.BurstBrowser.Settings.PhotonsPerWindow_BVA;
switch BurstData{file}.BAMethod
    case {1,2}
        % channel : 1,2 Donor Par Perp
        %           3,4 FRET Par Perp
        %           5,6 ALEX Par Parp
        channel = cellfun(@(x) x(x < 5),photons.Channel,'UniformOutput',false);
        sPerBurst=zeros(size(channel));
        for i = 1:numel(channel)
            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % create photon windows
            sPerBurst(i,1) = std(sum(M==3|M==4)/n); % observed standard deviation of E for each burst
        end
        
    case 5
        % channel : 1 Donor
        %           2 FRET
        %           3 ALEX
        channel = cellfun(@(x) x(x < 3),photons.Channel,'UniformOutput',false);
        sPerBurst=zeros(size(channel));
        for i = 1:numel(channel)
            M = reshape(channel{i,1}(1:fix(numel(channel{i,1})/n)*n),n,[]); % Create photon windows
            sPerBurst(i,1) = std(sum(M==2)/n); % observed standard deviation of E for each burst
        end
end
sSelected = sPerBurst.*BurstData{file}.Selected;
sSelected(sSelected == 0) = NaN;
E = E.*BurstData{file}.Selected;
E(E == 0) = NaN;
% STD per Bin
BinEdges = mE + [-dE,dE]./2;%linspace(0,1,UserValues.BurstBrowser.Settings.NumberOfBins_BVA+1);
[N,~,bin] = histcounts(E,BinEdges);
BinCenters = BinEdges(1:end-1)+min(diff(BinEdges))/2;
sPerBin = zeros(numel(BinEdges)-1,1);
sampling = UserValues.BurstBrowser.Settings.ConfidenceSampling_BVA;
PsdPerBin = zeros(numel(BinEdges)-1,sampling);
for j = 1:numel(N) % 1 : number of bins
    burst_id = find(bin==j); % find indices of bursts in bin j
    if ~isempty(burst_id)
        BurstsPerBin = cell(size(burst_id'));
        for k = 1:numel(burst_id)
            BurstsPerBin(k) = channel(burst_id(k)); % find all bursts in bin j
        end
        M = cellfun(@(x) reshape(x(1:fix(numel(x)/n)*n),n,[]),BurstsPerBin,'UniformOutput',false);
        MPerBin = cat(2,M{:});
        switch BurstData{file}.BAMethod
            case {1,2}
                EPerBin = sum(MPerBin==3|MPerBin==4)/n;
            case 3
                switch UserValues.BurstBrowser.Settings.FRETpair_BVA
                    case 1
                        EPerBin = sum(MPerBin==3|MPerBin==4)/n;
                    case 2
                        EPerBin = sum(MPerBin==5|MPerBin==6)/n;
                    case 3
                        EPerBin = sum(MPerBin==3|MPerBin==4|MPerBin==5|MPerBin==6)/n;
                    case 4
                        EPerBin = sum(MPerBin==9|MPerBin==10)/n;
                end
            case 5
                EPerBin = sum(MPerBin==2)/n;
        end
        if numel(BurstsPerBin)>UserValues.BurstBrowser.Settings.BurstsPerBinThreshold_BVA
            sPerBin(j,1) = std(EPerBin);
        end
        if sampling ~=0
            % simulate P(sigma)
            idx = [0 cumsum(cellfun('size',M,2))];
            window_id = zeros(size(EPerBin));
            for l = 1:numel(M)
                window_id(idx(l)+1:idx(l+1)) = ones(1,size(M{l},2))*burst_id(l);
            end
            for m = 1:sampling
                EperBin_simu = binornd(n,E(window_id))/n;
                PsdPerBin(j,m) = std(EperBin_simu);
                %Progress(((j-1)*sampling+m)/(numel(N)*sampling),h.Progress_Axes,h.Progress_Text,'Calculating Confidence Interval...');
            end
        end
    end
end
alpha = 0.1/numel(BinCenters)/100; % 99.9% with bonferroni correction
confint = mean(PsdPerBin,2) + std(PsdPerBin,0,2)*norminv(1-alpha);
BVA_est = sPerBin;
end