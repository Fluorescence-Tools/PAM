global BurstTCSPCData BurstData BurstMeta
file = BurstMeta.SelectedFile;
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
selected = BurstData{file}.Selected;
Mac = BurstTCSPCData{file}.Macrotime(selected);
Chan = BurstTCSPCData{file}.Channel(selected);

switch BurstData{file}.BAMethod
    case {1,2,5}
        switch BurstData{file}.BAMethod
            case {1,2} % MFD
                for i = 1:numel(Mac)
                    mGG{i} = Mac{i}((Chan{i} == 1) | (Chan{i}== 2));
                    mGR{i} = Mac{i}((Chan{i} == 3) | (Chan{i}== 4));
                    mRR{i} = Mac{i}((Chan{i} == 5) | (Chan{i}== 6));                    
                end
            case 5 % noMFD
                for i = 1:numel(Mac)
                    mGG{i} = Mac{i}((Chan{i} == 1));
                    mGR{i} = Mac{i}((Chan{i} == 2));
                    mRR{i} = Mac{i}((Chan{i} == 3));
                end                   
        end
        mGG = cellfun(@double,mGG,'UniformOutput',false);
        mGR = cellfun(@double,mGR,'UniformOutput',false);
        mRR = cellfun(@double,mRR,'UniformOutput',false);
        for i = 1:numel(Mac) 
            mGGt{i} =  mGG{i}.*BurstData{file}.ClockPeriod.*1000;
            mGRt{i} =  mGR{i}.*BurstData{file}.ClockPeriod.*1000;
            mRRt{i} =  mRR{i}.*BurstData{file}.ClockPeriod.*1000;
            
            start{i} = min([mGGt{i}; mGRt{i}; mRRt{i}]);
            mGGt{i} = mGGt{i}-start{i};
            mGRt{i} = mGRt{i}-start{i};
            mRRt{i} = mRRt{i}-start{i};
            
            %histogram in steps of 1 ms
            timebin = 0.1;
            maxi(i) = max([max(mGGt{i}) max(mGRt{i}) max(mRRt{i})]);
            hGG{i} = hist(mGGt{i},0:timebin:maxi(i));
            hGR{i} = hist(mGRt{i},0:timebin:maxi(i));
            hRR{i} = hist(mRRt{i},0:timebin:maxi(i));
        end
        i = 1;
        figure;plot(hGG{i},'b');hold on;plot(hGR{i},'g');%plot(hRR{i},'r');
        figure;plot(hGR{i}./(hGG{i}+hGR{i}),'r');
    case {3,4}
        for i = 1:numel(Mac)
            mBB{i} = Mac{i}((Chan{i} == 1) | (Chan{i}== 2));
            mBG{i} = Mac{i}((Chan{i} == 3) | (Chan{i}== 4));
            mBR{i} = Mac{i}((Chan{i} == 5) | (Chan{i}== 6));
            mBBt{i} =  mBB{i}.*BurstData{file}.ClockPeriod.*1000;
            mBGt{i} =  mBG{i}.*BurstData{file}.ClockPeriod.*1000;
            mBRt{i} =  mBR{i}.*BurstData{file}.ClockPeriod.*1000;

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
        i = 1;
        figure;plot(hBB{i},'b');hold on;plot(hBG{i},'g');plot(hBR{i},'r');
        figure;plot(hBR{i}./(hBB{i}+hBG{i}+hBR{i}),'r');hold on;plot(hBG{i}./(hBB{i}+hBG{i}+hBR{i}),'Color',[0 0.2 0.8]);
end