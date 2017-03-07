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

i=2;
figure;plot(hGG{i},'g');hold on;plot(hGR{i},'r');plot(hRR{i},'k')
figure;plot(hGR{i}./(hGG{i}+hGR{i}),'b');hold on;plot((hGG{i}+hGR{i})./(hRR{i}+hGG{i}+hGR{i}),'r');

GG = horzcat(hGG{:});
GR = horzcat(hGR{:});
RR = horzcat(hRR{:});

E = GR./(GG+GR);
S = (GG+GR)./(GG+GR+RR);