%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Estimates the event rates in the different channels %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thresholds are based on the currently selected settings
% If APBS is selected, the same threshold is applied to all channels
% If DCBS is selected, separate thresholds are used
% By default, the FRET/crosstalk channels (i.e. DA) are used as donor
% signal.
function estimate_event_rates(~,~)

global FileInfo UserValues PamMeta
%%% Initialization
h = guidata(findobj('Tag','Pam'));
%%% get external function from PAM
Perform_BurstSearch = PAM('Perform_BurstSearch');
Get_Photons_from_PIEChannel = PAM('Get_Photons_from_PIEChannel');
Update_Display = PAM('Update_Display');

%%% Set Progress Bar
h.Progress.Text.String = 'Performing Burst Search...';

BAMethod = UserValues.BurstSearch.Method;
SmoothingMethod = UserValues.BurstSearch.SmoothingMethod;
%% Burst Search
%%% The Burst Search Procedure outputs three vectors containing the
%%% Macrotime (AllPhotons), Microtime (AllPhotons_Microtime) and the
%%% Channel as a Number (Channel) of all Photons in the PIE channels used
%%% for the BurstSearch.
%%% The Bursts are defined via the start and stop vectors, containing the
%%% absolute photon number (NOT the macrotime) of the first and last photon
%%% in a burst. Additonally, the BurstSearch puts out the Number of Photons
%%% per Burst directly.

%%% The Channel Information is encoded as follows:

%%% 2color-MFD:
%%% 1   2   GG1 GG2
%%% 3   4   GR1 GR2
%%% 5   6   RR1 RR2

%%% 3color-MFD
%%% 1   2   BB1 BB2
%%% 3   4   BG1 BG2
%%% 5   6   BR1 BR2
%%% 7   8   GG1 GG2
%%% 9   10  GR1 GR2
%%% 11  12  RR1 RR2

%%% 2color-noMFD
%%% 1       GG
%%% 2       GR
%%% 3       RR

Number_of_Chunks = numel(find(PamMeta.Selected_MT_Patches));
ChunkSize = FileInfo.MeasurementTime/numel(PamMeta.Selected_MT_Patches)/60;
offset = [0,0];
for i = find(PamMeta.Selected_MT_Patches)'
    Progress((i-1)/Number_of_Chunks,h.Progress.Axes, h.Progress.Text,'Estimating Event Rates...');
    % get the photons and assign them to the color channels
    if any(BAMethod == [1 2]) %ACBS 2 Color
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime',i,ChunkSize);
        Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort macrotime and use index to sort microtime and channel
        %information
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))...
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))]);
        Channel = chan_temp(index);
        Channel = Channel';
        clear chan_temp
        
        %%% assign to color channels
        PhotonsCh{i,1} = AllPhotons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4);
        PhotonsCh{i,2} = AllPhotons(Channel == 5 | Channel == 6);
    elseif any(BAMethod == [3,4])
        disp('Not implemented for three colors yet.');
        return;
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,2},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{4} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,2},'Macrotime',i,ChunkSize);
        Photons{5} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        Photons{6} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,2},'Macrotime',i,ChunkSize);
        Photons{7} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,1},'Macrotime',i,ChunkSize);
        Photons{8} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{4,2},'Macrotime',i,ChunkSize);
        Photons{9} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,1},'Macrotime',i,ChunkSize);
        Photons{10} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{5,2},'Macrotime',i,ChunkSize);
        Photons{11} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,1},'Macrotime',i,ChunkSize);
        Photons{12} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{6,2},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))...
            4*ones(1,numel(Photons{4})) 5*ones(1,numel(Photons{5})) 6*ones(1,numel(Photons{6}))...
            7*ones(1,numel(Photons{7})) 8*ones(1,numel(Photons{8})) 9*ones(1,numel(Photons{9}))...
            10*ones(1,numel(Photons{10})) 11*ones(1,numel(Photons{11})) 12*ones(1,numel(Photons{12}))]);
        Channel = chan_temp(index);
        Channel = Channel';
        clear chan_temp
        
        %%% assign to color channels
        PhotonsCh{i,1} = AllPhotons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4 | Channel == 5 | Channel == 6);
        PhotonsCh{i,2} = AllPhotons(Channel == 7 | Channel == 8 | Channel == 9 | Channel == 10);
        PhotonsCh{i,3} = AllPhotons(Channel == 11| Channel == 12);
    elseif any(BAMethod == [5,6]) %2 color no MFD
        %prepare photons
        %read out macrotimes for all channels
        Photons{1} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{1,1},'Macrotime',i,ChunkSize);
        Photons{2} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{2,1},'Macrotime',i,ChunkSize);
        Photons{3} = Get_Photons_from_PIEChannel(UserValues.BurstSearch.PIEChannelSelection{BAMethod}{3,1},'Macrotime',i,ChunkSize);
        AllPhotons_unsort = vertcat(Photons{:});
        %sort
        [AllPhotons, index] = sort(AllPhotons_unsort);
        clear AllPhotons_unsort
        %get colors of photons
        chan_temp = uint8([1*ones(1,numel(Photons{1})) 2*ones(1,numel(Photons{2})) 3*ones(1,numel(Photons{3}))]);
        Channel = chan_temp(index);
        Channel = Channel';
        clear chan_temp
        %%% assign to color channels
        PhotonsCh{i,1} = AllPhotons(Channel == 1 | Channel == 2);
        PhotonsCh{i,2} = AllPhotons(Channel == 3);
    end
    % get burst search parameters
    NChan = size(PhotonsCh,2); % number of channels used
    L = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(1);
    T = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2);
    M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3);
    if any(BAMethod == [1,3,5])
        % APBS - all photon, same threshold for all channels
        M = repmat(M,[1,NChan]);
        T = repmat(T,[1,NChan]);
    else
        M = UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(3:4);
        T = [UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(2), UserValues.BurstSearch.SearchParameters{SmoothingMethod,BAMethod}(6)];
    end
    % do the burst search
    for j = 1:NChan
        [start{i,j}, stop{i,j}] = Perform_BurstSearch(PhotonsCh{i,j},[],'APBS',T(j),M(j),L);        
        event_number_mat(i,j) = numel(start{i,j});        
    end    
    if i > 1
        offset = offset + [numel(PhotonsCh{i-1,1}),numel(PhotonsCh{i-1,2})];
        for j = 1:NChan
            start{i,j} = start{i,j} + offset(j);
            stop{i,j} = stop{i,j} + offset(j);
        end
    end
end
start = {vertcat(start{:,1}),vertcat(start{:,2})};
stop = {vertcat(stop{:,1}),vertcat(stop{:,2})};
PhotonsCh = {vertcat(PhotonsCh{:,1}),vertcat(PhotonsCh{:,2})};
event_rates = sum(event_number_mat,1)./FileInfo.MeasurementTime;
event_rates_error = std(event_number_mat,1)./(ChunkSize*60);
fprintf('Event rates:\n');
for i = 1:NChan
    fprintf('Channel %i: %.2f pm %.2f Hz\n',i,event_rates(i),event_rates_error(i));
end

%%% Update Display
Update_Display([],[],1);

%% plot the result
bin_time_ms = 1;
Bin_Time = bin_time_ms*1E-3/FileInfo.ClockPeriod;
%%% prepare trace for display
xout = 0:Bin_Time:FileInfo.MeasurementTime/FileInfo.ClockPeriod;
switch BAMethod %make histograms for lower display with binning T_classic
    case {1,2}    % 2 color, MFD
        ch{1} = hist(PhotonsCh{1}, xout);
        ch{2} = hist(PhotonsCh{2}, xout);
    case {3,4}    % 3 color, MFD
        ch{1} = hist(PhotonsCh{1}, xout);
        ch{2} = hist(PhotonsCh{2}, xout);
        ch{3} = hist(PhotonsCh{3}, xout);
    case {5,6}
        ch{1} = hist(PhotonsCh{1}, xout);
        ch{2} = hist(PhotonsCh{2}, xout);
end
%xout = xout+Bin_Time/2;
% convert start/stop to photon arrival times (i.e. burst range)
x = {[],[]};
y = {[],[]};
for j = 1:2
    for i = 1:numel(start{j})
        x{j} = [x{j},PhotonsCh{j}(start{j}(i)),PhotonsCh{j}(start{j}(i)),...
            PhotonsCh{j}(stop{j}(i)),PhotonsCh{j}(stop{j}(i))];
        y{j} = [y{j},0,1,1,0];
    end
end

%%% Plot the data
lw = 1.5;
fs = 18;
colors = {[0, 0.4471,0.7412],[0.8510, 0.3255, 0.0980]};
hfig = figure('Position',[100,100,800,600],'Color',[1,1,1]);
ax1 = axes('Parent',hfig,'Position',[0.15,0.55,0.8,0.4],'Color',[1,1,1],'Box','on','Linewidth',lw,'FontSize',fs);
ax2 = axes('Parent',hfig,'Position',[0.15,0.15,0.8,0.4],'Color',[1,1,1],'Box','on','Linewidth',lw,'FontSize',fs);
%slider = uicontrol('Parent',hfig,'Style','slider','Units','normalized','Position',[0.1,0.01,0.8,0.05]);

linkaxes([ax1,ax2],'x');

axes(ax1); hold on;
plot(ax1,xout*FileInfo.ClockPeriod,ch{1},'Color',colors{1});
plot(ax1,xout*FileInfo.ClockPeriod,ch{2},'Color',colors{2});
xlim([0 1]);%FileInfo.MeasurementTime]);
set(ax1,'YLimMode','auto');

% plot the selected burst regions
for j = 1:2
    area(ax1,x{j}*FileInfo.ClockPeriod,y{j}*ax1.YLim(2),'EdgeColor','none','FaceAlpha',0.25,'FaceColor',colors{j});
end

%%% Plot Interphoton time trace
axes(ax2); hold on;
for j = 1:2
    dT =[PhotonsCh{j}(1);diff(PhotonsCh{j})];
    plot(ax2,PhotonsCh{j}.*FileInfo.ClockPeriod,dT.*FileInfo.ClockPeriod*1E6,'-','Color', colors{j});
end
set(ax2,'YScale','log');
% plot the selected burst regions
yl = ax2.YLim;
for j = 1:2
    y{j}(y{j}==0) = eps;
    area(ax2,x{j}*FileInfo.ClockPeriod,y{j}*yl(2),'EdgeColor','none','FaceAlpha',0.25,'FaceColor',colors{j});
end
ylim(ax2,yl);

function update_plot(~,~)