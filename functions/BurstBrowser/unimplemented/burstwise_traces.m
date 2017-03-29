global BurstTCSPCData
global BurstData

selected = BurstData.Selected;
Mac = BurstTCSPCData.Macrotime(selected);
Chan = BurstTCSPCData.Channel(selected);

for i = 1:numel(Mac)
    mBB{i} = Mac{i}((Chan{i} == 1) | (Chan{i}== 2));
    mBG{i} = Mac{i}((Chan{i} == 3) | (Chan{i}== 4));
    mBR{i} = Mac{i}((Chan{i} == 5) | (Chan{i}== 6));
    mBBt{i} =  mBB{i}.*BurstData.ClockPeriod.*1000;
    mBGt{i} =  mBG{i}.*BurstData.ClockPeriod.*1000;
    mBRt{i} =  mBR{i}.*BurstData.ClockPeriod.*1000;
    
    start{i} = min([mBBt{i}; mBGt{i}; mBRt{i}]);
    mBBt{i} = mBBt{i}-start{i};
    mBGt{i} = mBGt{i}-start{i};
    mBRt{i} = mBRt{i}-start{i};

    %histogram in steps of 1 ms
    maxi(i)=max([max(mBBt{i}) max(mBGt{i}) max(mBRt{i})]);
    hBB{i} = hist(mBBt{i},0:1:maxi(i));
    hBG{i} = hist(mBGt{i},0:1:maxi(i));
    hBR{i} = hist(mBRt{i},0:1:maxi(i));
end

figure;plot(hBB{i},'b');hold on;plot(hBG{i},'g');plot(hBR{i},'r')
figure;plot(hBR{i}./(hBB{i}+hBG{i}+hBR{i}),'r');hold on;plot(hBG{i}./(hBB{i}+hBG{i}+hBR{i}),'Color',[0 0.2 0.8])