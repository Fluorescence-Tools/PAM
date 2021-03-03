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
        PhotonsCh{1} = AllPhotons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4);
        PhotonsCh{2} = AllPhotons(Channel == 5 | Channel == 6);
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
        PhotonsCh{1} = AllPhotons(Channel == 1 | Channel == 2 | Channel == 3 | Channel == 4 | Channel == 5 | Channel == 6);
        PhotonsCh{2} = AllPhotons(Channel == 7 | Channel == 8 | Channel == 9 | Channel == 10);
        PhotonsCh{3} = AllPhotons(Channel == 11| Channel == 12);
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
        PhotonsCh{1} = AllPhotons(Channel == 1 | Channel == 2);
        PhotonsCh{2} = AllPhotons(Channel == 3);       
    end
    % get burst search parameters
    NChan = numel(PhotonsCh); % number of channels used
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
        [start, stop, Number_of_Photons] = Perform_BurstSearch(PhotonsCh{j},[],'APBS',T(j),M(j),L);
        event_number_mat(i,j) = numel(start);
    end
end
event_rates = sum(event_number_mat,1)./FileInfo.MeasurementTime;
event_rates_error = std(event_number_mat,1)./(ChunkSize*60);
fprintf('Event rates:\n');
for i = 1:NChan
    fprintf('Channel %i: %.2f pm %.2f Hz\n',i,event_rates(i),event_rates_error(i));
end

%%% Update Display
Update_Display([],[],1);