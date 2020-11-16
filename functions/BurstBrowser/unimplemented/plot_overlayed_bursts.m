function plot_overlayed_bursts(mode)
global BurstData PhotonStream BurstMeta
%h = guidata(finobj('Tag','BurstBrowser'));
% mode: 1 - normalize to mean
%       2 - normalize to half (start+stop)/2
%       3 - normalize to start
if nargin == 0
    mode = 1;
end
%%% Set Up Progress Bar
%Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
file = BurstMeta.SelectedFile;
UpdateCuts();
%%% Read out the species name
if (BurstData{file}.SelectedSpecies(1) == 0)
    species = 'total';
elseif (BurstData{file}.SelectedSpecies(1) >= 1)
    species = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1};
    if (BurstData{file}.SelectedSpecies(2) > 1)
        species = [species '-' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
    end
end
species = strrep(species,' ','_');

if isempty(PhotonStream{file})
    success = Load_Photons('aps');
    if ~success
        %Progress(1,h.Progress_Axes,h.Progress_Text);
        return;
    end
end

% use selected only
start = PhotonStream{file}.start(BurstData{file}.Selected);
stop = PhotonStream{file}.stop(BurstData{file}.Selected);

time_before = 50E-3/BurstData{file}.SyncPeriod; % ms time before
time_after = 50E-3/BurstData{file}.SyncPeriod; % ms time after
max_dur = max(PhotonStream{file}.Macrotime(stop)-PhotonStream{file}.Macrotime(start))+time_after;
normalized_bursts = cell(numel(start),1);
fprintf('0.00');
photon_window = 1E4; % to speed up, consider only this window around each burst
% mean macrotime in time units
mean_mt = BurstData{file}.DataArray(BurstData{file}.Selected,strcmp(BurstData{file}.NameArray,'Mean Macrotime [s]'))/BurstData{file}.SyncPeriod;

for i = 1:numel(start)
    mt_dummy = PhotonStream{file}.Macrotime(max([start(i)-photon_window,1]):min([stop(i)+photon_window,end]));
    normalized_bursts{i} = mt_dummy(...
        mt_dummy > (PhotonStream{file}.Macrotime(start(i)) - time_before) &...
        mt_dummy < (PhotonStream{file}.Macrotime(start(i)) + max_dur));
    switch mode
        case 1
            normalized_bursts{i} = normalized_bursts{i} -...
                mean_mt(i);
        case 2
            normalized_bursts{i} = normalized_bursts{i} -...
                (PhotonStream{file}.Macrotime(start(i))+PhotonStream{file}.Macrotime(stop(i)))/2;
        case 3
            normalized_bursts{i} = normalized_bursts{i} -...
                PhotonStream{file}.Macrotime(start(i));
    end
        %(PhotonStream{file}.Macrotime(start(i)) + PhotonStream{file}.Macrotime(stop(i)))/2;
        %(PhotonStream{file}.Macrotime(stop(i)) - PhotonStream{file}.Macrotime(start(i)))/2;
%     normalized_bursts{i} = PhotonStream{file}.Macrotime(...
%         PhotonStream{file}.Macrotime > (PhotonStream{file}.Macrotime(start(i)) - time_before) &...
%         PhotonStream{file}.Macrotime < (PhotonStream{file}.Macrotime(start(i)) + max_dur)) - ...
%         PhotonStream{file}.Macrotime(start(i));
    fprintf('\b\b\b\b%.2f',i/numel(start));
end
fprintf('\n');
a = vertcat(normalized_bursts{:});
binning = 0.01; % 10 µs binning
[h,xh] = histcounts(a*BurstData{file}.SyncPeriod*1000,-50:binning:50);
xh = xh(1:end-1) + min(diff(xh))/2;
h = h./numel(start)*(1./binning); % convert to average countrate in kHz

% find the peak
[~,ix_peak] = max(smooth(xh,h,50)); % 500 µs window
xh = xh-xh(ix_peak);

% plot
color = lines(2);
figure('Position',[100,100,1000,400]);
subplot(1,2,1); hold on;
plot(xh(1:ix_peak+1),h(1:ix_peak+1),'LineWidth',2);
plot(xh(ix_peak+1:end),h(ix_peak+1:end),'LineWidth',2);
%plot(xh(1:numel(xh)/2+1),h(1:numel(xh)/2+1),'LineWidth',2);
%plot(xh(numel(xh)/2+1:end),h(numel(xh)/2+1:end),'LineWidth',2);
xlabel('time (ms)');
ylabel('count rate [kHz]');
set(gca,'LineWidth',2,'FontSize',18,'Box','on');
subplot(1,2,2); hold on;
plot(-xh(ix_peak:-1:1),h(ix_peak:-1:1),'LineWidth',2,'Color',[color(1,:),1]);
plot(xh(ix_peak+1:end),h(ix_peak+1:end),'LineWidth',2,'Color',[color(2,:),1]);
xlabel('time difference to mean arrival time (ms)');
ylabel('count rate [kHz]');
set(gca,'XScale','log','LineWidth',2,'FontSize',18,'Box','on');

do_fit = false;
if do_fit
    model = @(a,b,c,x) a*exp(-x./b) + c;
    fit_before = fit(-xh(ix_peak:-1:1)',h(ix_peak:-1:1)',model,'StartPoint',[max(h),1,0],'Lower',[0,0,-Inf]);
    fit_after = fit(xh(ix_peak+1:end)',h(ix_peak+1:end)',model,'StartPoint',[max(h),1,0]);
    plot(-xh(ix_peak:-1:1),fit_before(-xh(ix_peak:-1:1)),'Color',color(1,:),'LineWidth',3);
    plot(xh(ix_peak+1:end),fit_after(xh(ix_peak+1:end)),'Color',color(2,:),'LineWidth',3);
end
%xlim([-5,10]);
%ylim([0,2500]);
axis('tight');
legend({'rise','fall'});


