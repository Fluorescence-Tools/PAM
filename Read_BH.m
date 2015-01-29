function [MT, MI, PLF, SyncRate] = Read_BH(FileName,NoE,Scanner)

%%% Input parameters: 
%%% Filename: Full filename
%%% NoE: Maximal number of entries to load
%%% Mark: defines, which marks to use; [Pixel Line Frame];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% File format:
%%%% Bit/Byte 1      2      3      4      5      6      7      8
%%%%       1  MT1    MT2    MT3    MT4    MT5    MT6    MT7    MT8
%%%%       2  MT9    MT10   MT11   MT12   ROUT1  ROUT2  ROUT3  ROUT4
%%%%       3  MI1    MI2    MI3    MI4    MI5    MI6    MI7    MI8
%%%%       4  MI9    MI10   MI11   MI12   MARK   GAP    MTOV   INVALID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


FileID = fopen(FileName, 'r');
ByteRecord = fread(FileID, NoE, 'uint32=>uint32');
fclose(FileID);
clear FileID;

if numel(ByteRecord) < 2 % Even empty file will contain sync rate
    msgbox(['Empty file: ', FullFileName]);
else
    %the sync rate is contained in the first 3 bytes of the first byte
    %record in units of 100 ps
    SyncRate = 1E10/double(bitand(ByteRecord(1), bin2dec('00000000111111111111111111111111')));
    ByteRecord(1)=[]; %%% Delete Header entry
    
    Rout=uint8(bitand(bitshift(ByteRecord, - 8), 240)); % Loads Routing bits
    Mark=uint8(bitand(bitshift(ByteRecord, -28),  15)); % Loads Mark, Gap, Macrotime Overflow and Invalid bits
    Mark=Mark+Rout; % Combines Rout and Mark to save memory (Matlab has not file format < 8bit)
    clear Rout;
    
    MT=uint32(zeros(numel(Mark),1)); % Initializes macrotime overflow variable
    MT(bitand(Mark,12)==4)=1; % One single overflow occured (MTOV==1 & INVALID==0)
    MT(bitand(Mark,12)==12)=bitand(ByteRecord(bitand(Mark,12)==12),268435455);% Several overflows occured (MTOV==1 & INVALID==1)
        
    Macrotime=uint16(bitand(ByteRecord, 4095)); % Loads Macrotime
    MI=4095-uint16(bitand(bitshift(ByteRecord, -16), 4095)); % Loads Microtime    
    clear ByteRecord;
    
    MT=cumsum(double(MT))*4096+double(Macrotime); % Transforms MT into continuous stream (as double) 
    clear Macrotime;
    
    % Removes all remaining invalid entries (mostly overflow entries)
    MI(bitand(Mark,8)==8)=[];
    MT(bitand(Mark,8)==8)=[];
    Mark(bitand(Mark,8)==8)=[];
    % Remove last overflow photon; seems that sometimes the last entry is
    % somehow wrong
    if ~isempty(Mark) && bitand(Mark(end),12)==4
        MI(end)=[];
        MT(end)=[];
        Mark(end)=[];
    end
    
    % Checks for detection gaps due to fifo overflows
    if any(bitand(Mark,2)==2)
        msgbox(['FIFO overflow occured in file ', FullFileName]);
    end
    % Checks for Mark entries (usually frame, line or pixels entries)
    if sum(Scanner>0) && any(bitend(Mark,1)==1)
        Scanner_Mark=find(bitend(Mark,1)==1);
        Scanner_Rout=bitand(Mark(Scanner_Mark),112);
        Scanner_MT=MT(Scanner_Mark);
        clear Scanner_Mark
        PLF=cell(3,1);
        if Scanner(1) % Reads Pixel times
            PLF{1}= Scanner_MT(Scanner_Rout==16);
        end
        if Scanner(2) % Reads Line times
            PLF{2}= Scanner_MT(Scanner_Rout==32);
        end
        if Scanner(3) % Reads Frame times
            PLF{3}= Scanner_MT(Scanner_Rout==64);
        end
        clear Scanner_MT Scanner_Rout
    else
        PLF={[],[],[]};
    end
    
    % Removes all mark entries (usually frame, line or pixels entries)
    MI(bitand(Mark,1)==1)=[];
    MT(bitand(Mark,1)==1)=[];
    Mark(bitand(Mark,1)==1)=[];
    
    Mark=bitshift(Mark, -4); % Only keeps routing bits
    UsedRout=unique(Mark)+1; % Finds all used routing channels
    
    % Photons are distributed according to routing bits
    if numel(MI~=0)
        if numel(UsedRout)==1 && UsedRout==1 %No routing/only first routing channel was used
            MT={MT}; MI={MI}; % Transform to cell array to keep file format consistent
        elseif numel(UsedRout)==1 %Only one routing channel was used
            MT={MT}; MI={MI}; % Transform to cell array to keep file format consistent
            for i=2:UsedRout
                MT{i,1}=[]; MI{i}=[]; % Creates empty cell entries for unsued routing channels
            end
            % Shifts photons into the correct routing channel
            % This way, no photon is assigned to more than one variable to save memory
            MT=circshift(MT,UsedRout-1);
            MI=circshift(MI,UsedRout-1);
        else
            MT={MT}; MI={MI}; % Transform to cell array
            for i=2:max(UsedRout)
                % Shifts photons to the corresponding routing channel
                MT{i,1}=MT{1,1}(Mark==i);
                MT{1,1}(Mark==i)=[];
                MI{i,1}=MI{1,1}(Mark==i);
                MI{1,1}(Mark==i)=[];
            end
        end
    else %%% Gives out empty cells
        MI={[]}; MT={[]};
    end
    clear Mark        
end