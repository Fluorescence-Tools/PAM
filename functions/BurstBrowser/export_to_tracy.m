function export_to_tracy(binning)
global BurstTCSPCData BurstData BurstMeta
file = BurstMeta.SelectedFile;
if nargin < 1
    binning = 1; % 1ms binning
end
selected = BurstData{file}.Selected;

%% construct burstwise traces
Mac = BurstTCSPCData{file}.Macrotime(selected);
Chan = BurstTCSPCData{file}.Channel(selected);

for i = 1:numel(Mac)
    mGG{i} = double(Mac{i}((Chan{i} == 1) | (Chan{i}== 2)));
    mGR{i} = double(Mac{i}((Chan{i} == 3) | (Chan{i}== 4)));
    mRR{i} = double(Mac{i}((Chan{i} == 5) | (Chan{i}== 6)));
    mGGt{i} =  mGG{i}.*BurstData{1}.ClockPeriod.*1000;
    mGRt{i} =  mGR{i}.*BurstData{1}.ClockPeriod.*1000;
    mRRt{i} =  mRR{i}.*BurstData{1}.ClockPeriod.*1000;
    
    start{i} = min([mGGt{i}; mGRt{i}; mRRt{i}]);
    mGGt{i} = mGGt{i}-start{i};
    mGRt{i} = mGRt{i}-start{i};
    mRRt{i} = mRRt{i}-start{i};

    %histogram in steps of binning
    maxi(i)=max([max(mGGt{i}) max(mGRt{i}) max(mRRt{i})]);
    hGG{i} = hist(mGGt{i},0:binning:maxi(i));
    hGR{i} = hist(mGRt{i},0:binning:maxi(i));
    hRR{i} = hist(mRRt{i},0:binning:maxi(i));
end

%% save for tracy
T = struct;
N = numel(hGG);
maxLength =max(cellfun(@numel,hGG));
T.fret_pairs = ones(N,4); % camera coordinates (later use the absolute macrotime value)
T.b = BurstData{file}.Corrections.CrossTalk_GR*ones(N,1); % use crosstalk value
T.g = BurstData{file}.Corrections.Gamma_GR*ones(N,1); % use gamma value
% missing: direct excitation value!
T.dir = zeros(N,maxLength); % alex trace
T.bdir = ones(N,maxLength)*binning*(BurstData{file}.Background.Background_RRpar+BurstData{file}.Background.Background_RRperp); % background of alex trace
T.acc = zeros(N,maxLength); % FRET signal trace
T.bacc = ones(N,maxLength)*binning*(BurstData{file}.Background.Background_GRpar+BurstData{file}.Background.Background_GRperp); % background in FRET signal trace
T.don = zeros(N,maxLength); % donor signal trace
T.bdon = ones(N,maxLength)*binning*(BurstData{file}.Background.Background_GGpar+BurstData{file}.Background.Background_GGperp); % background in donor signal trace
T.fret = zeros(N,maxLength); % FRET trace
T.frames = cellfun(@numel,hGG)'; % number of frames per trace
for i = 1:N
    T.dir(i,1:T.frames(i)) = hRR{i};
    T.acc(i,1:T.frames(i)) = hGR{i};
    T.don(i,1:T.frames(i)) = hGG{i};
    T.fret(i,1:T.frames(i)) = hGR{i}./(hGG{i}+hGR{i});
end
T.pacc = uint16(40*ones(N,maxLength)); % no idea what this is
T.pdon = uint16(40*ones(N,maxLength)); % no idea what this is
T.accc = T.acc-T.bacc; % background corrected
T.donc = T.don-T.bdon; % background corrected
T.dirc = T.dir-T.bdir; % background corrected
T.fretc = T.fret; % background corrected
T.range = zeros(N,5); % bleach step ranges
T.range(:,1) = 1;T.range(:,2) = T.frames; T.range(:,3) = T.frames; % bleachsteps, set to trace length
T.peak_id = (1:N)';
T.gain = ones(N,1);
T.freq = 10*ones(N,1); % no idea what this is
T.acq_time = repmat({'today'},N,1);
T.movie_name = repmat({'dummy'},N,1);
T.movie_mode = 2*ones(N,1); % 2 means alex mode
T.exposure = binning*ones(N,1); % this is the exposure time in milliseconds

[FileName,PathName] = uiputfile('*.mat','Choose location',fullfile(BurstData{file}.PathName,[BurstData{file}.FileName(1:end-4) '_traces.mat']));
save(fullfile(PathName,FileName),'-struct','T');