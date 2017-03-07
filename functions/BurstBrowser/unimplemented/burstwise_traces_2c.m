global BurstTCSPCData
global BurstData

hGG = [];
hGR = [];
hRR = [];
selected = BurstData{1}.Selected;
Mac = BurstTCSPCData{1}.Macrotime(selected);
Chan = BurstTCSPCData{1}.Channel(selected);

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

    %histogram in steps of 1 ms
    maxi(i)=max([max(mGGt{i}) max(mGRt{i}) max(mRRt{i})]);
    hGG{i} = hist(mGGt{i},0:1:maxi(i));
    hGR{i} = hist(mGRt{i},0:1:maxi(i));
    hRR{i} = hist(mRRt{i},0:1:maxi(i));
end

i=10;
figure;plot(hGG{i},'g');hold on;plot(hGR{i},'r');plot(hRR{i},'k')
figure;plot(hGR{i}./(hGG{i}+hGR{i}),'b');hold on;plot((hGG{i}+hGR{i})./(hRR{i}+hGG{i}+hGR{i}),'r');

GG = horzcat(hGG{:});
GR = horzcat(hGR{:});
RR = horzcat(hRR{:});

E = GR./(GG+GR);
S = (GG+GR)./(GG+GR+RR);

%% save for tracy
T = struct;
N = numel(hGG);
maxLength =max(cellfun(@numel,hGG));
T.fret_pairs = ones(N,4); % camera coordinates (later use the absolute macrotime value)
T.b = zeros(N,1); % later use crosstalk value
T.g = ones(N,1); % later use gamma value
T.dir = zeros(N,maxLength); % alexa trace
T.bdir = zeros(N,maxLength); % background of alex trace
T.acc = zeros(N,maxLength); % FRET signal trace
T.bacc = zeros(N,maxLength); % background in FRET signal trace
T.don = zeros(N,maxLength); % donor signal trace
T.bdon = zeros(N,maxLength); % background in donor signal trace
T.fret = zeros(N,maxLength); % FRET trace
T.frames = cellfun(@numel,hGG)'; % number of frames per trace
for i = 1:N
    T.dir(i,1:T.frames(i)) = hRR{i};
    T.acc(i,1:T.frames(i)) = hGR{i};
    T.don(i,1:T.frames(i)) = hRR{i};
    T.fret(i,1:T.frames(i)) = hGR{i}./(hGG{i}+hGR{i});
end
T.pacc = uint16(40*ones(N,maxLength)); % no idea what this is
T.pdon = uint16(40*ones(N,maxLength)); % no idea what this is
T.accc = T.acc; % background corrected
T.donc = T.don; % background corrected
T.dirc = T.dir; % background corrected
T.fretc = T.fret; % background corrected
T.range = zeros(N,5); % bleach step ranges
T.range(:,1) = 1;T.range(:,2) = T.frames; T.range(:,3) = T.frames;
%T.select = ones(N,1); % selection in groups
T.peak_id = (1:N)';
T.gain = ones(N,1);
T.freq = 10*ones(N,1); % no idea what this is
T.acq_time = repmat({'today'},N,1);
T.movie_name = repmat({'dummy'},N,1);
T.movie_mode = 2*ones(N,1); % 2 means alex mode
T.exposure = ones(N,1); % this is the exposure time in milliseconds
%T.tags = {sprintf('without selection (%i)',N)};
%T.pop_hotkeys = {};

save('test_burstbrowser_export.mat','-struct','T');