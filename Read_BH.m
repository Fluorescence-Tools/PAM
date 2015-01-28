function [MT, MI, PLF, ClockRate] = Read_BH(FileName,NoE,Scanner,Card, MI_Bins)

%%% Input parameters:
%%% Filename: Full filename
%%% NoE: Maximal number of entries to load
%%% Mark: defines, which marks to use; [Pixel Line Frame];

%%% Output parameters:
%%% ClockRate: the macrotime clock, in 0.1 ns resolution

FileID = fopen(FileName, 'r');
if strcmp(Card, 'SPC-140/150')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Data is arranged per 4 bytes
    %%%% Data is read in at 32 bits
    ByteRecord = fread(FileID, NoE, 'uint32=>uint32');
    %%%% The first photon frame (4 bytes) in the .spc file is added by the software and contains information
    %%%% about the Macro Time clock (resolution 0.1 ns) and the number of routing channels used during the measurement:
    %%%% byte 0,1,2     = macro time clock in 0.1 ns units ( for 50ns value 500 is set )
    %%%%        SPC140/150: MT clock can be 50 ns or the Sync Rate (Only if external clocking is selected in measurement preferences rather than 50ns internal clock!)
    %%%%        SPC630: MT clock is 50 ns
    %%%% byte 3 : bit 7 = 1 ( Invalid photon ),  bits 3-6 = number of routing bits,
    %%%%          bit 2 = 1 file with raw data ( for diagnostic mode only,
    %%%%                       such file contains pure data read from FIFO without special meaning
    %%%%                       of the entries with 'MTOV = 1' and 'INVALID = 1' described below )
    %%%%          bit 1 = 1 file with markers ( new SPC-140, SPC-150, see below)
    %%%%          bit 0 = reserved
    %%%% every photon is stored as follows in 4 bytes
    %%%% Bit/Byte 1      2      3      4      5      6      7      8
    %%%%       1  MT1    MT2    MT3    MT4    MT5    MT6    MT7    MT8
    %%%%       2  MT9    MT10   MT11   MT12   ROUT1  ROUT2  ROUT3  ROUT4
    %%%%       3  MI1    MI2    MI3    MI4    MI5    MI6    MI7    MI8
    %%%%       4  MI9    MI10   MI11   MI12   MARK   GAP    MTOV   INVALID
    MTres = 2^12;
elseif strcmp(Card, 'SPC-630 256chs')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Data is arranged per 4 bytes
    %%%% Data is read in at 32 bits
    ByteRecord = fread(FileID, NoE, 'uint32=>uint32');
    %%%% The first photon frame (4 bytes) in the .spc file is added by the software and contains information
    %%%% about the Macro Time clock (resolution 0.1 ns) and the number of routing channels used during the measurement:
    %%%% byte 0,1,2     = macro time clock in 0.1 ns units ( for 50ns value 500 is set )
    %%%%        SPC140/150: MT clock can be 50 ns or the Sync Rate (Only if external clocking is selected in measurement preferences rather than 50ns internal clock!)
    %%%%        SPC630: MT clock is 50 ns
    %%%% byte 3 : bit 7 = 1 ( Invalid photon ),  bits 3-6 = number of routing bits,
    %%%%          bit 2 = 1 file with raw data ( for diagnostic mode only,
    %%%%                       such file contains pure data read from FIFO without special meaning
    %%%%                       of the entries with 'MTOV = 1' and 'INVALID = 1' described below )
    %%%%          bit 1 = 1 file with markers ( new SPC-140, SPC-150, see below)
    %%%%          bit 0 = reserved
    %%%% every photon is stored as follows in 4 bytes:
    %%%%            Bit 7           <=           Bit 0
    %%%% Byte 0:    ADC7             <=          ADC0
    %%%% Byte 1:    MT7                <=        MT0
    %%%% Byte 2:    MT15                <=       MT8
    %%%% Byte 3:    INVALID MTOV GAP 0 R2 <= R0  MT16
    MTres = 2^17;
elseif strcmp(Card, 'SPC-630 4096chs')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Data is arranged per 6 bytes
    %%%% We first read the data at 16bits
    ByteRecord = fread(FileID, NumberOfEntries, 'uint16=>uint16');
    %%%% First 6 bytes of ByteRecord contains Resolution of macrotime (MT) clock in units of 0.1ns
    %%%% SPC630: MT clock is always 50 ns
    %%%%
    %%%% From b&h header information file:
    %%%% =================================
    %%%% The first photon frame (6 bytes) in the .spc file is added by the software and contains information
    %%%% about the Macro Time clock and the number of routing channels used during the measurement:
    %%%%   byte 0, 4, 5 = 0
    %%%%   byte 2,3     = macro time clock in 0.1 ns units (for 50ns value 500 is set)
    %%%%   byte 1 : bit 4 = 1 Invalid photon
    %%%%            bits 3-0 = number of routing bits
    %%%% Important:
    %%%% To be able to do bitwise operations, we have to put the 6-byte file
    %%%% into one 16bit and one 32bit variable
    maxi = round(numel(ByteRecord)/3);
    ByteRecord1 = zeros(maxi, 1);
    ByteRecord2 = zeros(maxi, 1);
    for i = 1:maxi
        % we create two new ByteRecords, one 16bit and one 32bit
        ByteRecord1(i) = ByteRecord(1+3*(i-1));
        %            Bit 7           <=           Bit 0
        % Byte 0:    ADC7             <=          ADC0
        % Byte 1:    0  GAP MTOV INVALID ACD11 <= ADC8
        
        ByteRecord2(i) = bitor(bitshift(uint32(ByteRecord(2+3*(i-1))),16), uint32(ByteRecord(3+3*(i-1))));
        %            Bit 7  <=   Bit 0
        % Byte 0:    MT7    <=   MT0
        % Byte 1:    MT15   <=   MT8
        % Byte 2:    MT23   <=   MT16
        % Byte 3:    R7     <=   R0
    end
    MTres = 2^24;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
fclose(FileID);
clear FileID;

if numel(ByteRecord) < 2 % Even empty file will contain sync rate
    msgbox(['Empty file: ', FullFileName]);
else
    %the clockrate is contained in the first 3 bytes of the first
    %record in units of 100 ps
    if strcmp(Card, 'SPC-140/150') || strcmp(Card, 'SPC-630 256chs')
        ClockRate = 1E10/double(bitand(ByteRecord(1), bin2dec('00000000111111111111111111111111')));
        ByteRecord(1)=[]; %%% Delete Header entry
    elseif strcmp(Card, 'SPC-630 4096chs')
        ClockRate = 1E10/double(ByteRecord(2));
        clear ByteRecord
        ByteRecord1(1)=[]; %%% Delete Header entry
        ByteRecord2(1)=[]; %%% Delete Header entry
    end
    
    % Non macro/microtime information
    if strcmp(Card, 'SPC-140/150')
        Rout = uint8(bitand(bitshift(ByteRecord, - 8), 240));
        Rest = uint8(bitand(bitshift(ByteRecord, - 28),  15));
    elseif strcmp(Card, 'SPC-630 256chs')
        Rout = uint8(bitand(bitshift(ByteRecord, - 21), 112));
        Rest = uint8(bitand(bitshift(ByteRecord, - 28),  15));
    else % 'SPC-630 4096chs'
        Rout = uint8(bitand(bitshift(ByteRecord2, - 20), 240));
        Rest = uint8(bitand(bitshift(ByteRecord1, - 12),  15));
        Rest = bin2dec(fliplr(dec2bin(Rest,4)));
    end
    Bits = Rest + Rout;
    % Bits combines Rout and Rest to save memory (Matlab has not file format < 8bit)
    %
    % bit8         <=           bit1
    % R3 <= R0 INVALID MTOV GAP MARK
    %
    % R0-R3:
    %   routing bits, with R3 = 0 for 'SPC-630 256chs'
    % INVALID:
    %   - router detects 2 photons digitally, TCSPC card detects one photon
    %   - TAC + dither > ADC range
    %   - photon during MTOV entry
    % MTOV:
    %   macrotime overflow bit
    % GAP:
    %   a FIFO overflow occurred. Data is likely invalid
    % MARK:
    %   scanning information, with MARK = 0 for 'SPC-630'
    clear Rout Rest;
    
    MT = uint32(zeros(numel(Bits),1)); % Initializes macrotime overflow variable
    MT(bitand(Bits,12)==4) = 1; % One single overflow occured (MTOV==1 & INVALID==0)
    if strcmp(Card, 'SPC-140/150')
        MT(bitand(Bits,12)==12) = bitand(ByteRecord(bitand(Bits,12)==12), 268435455); % Several overflows occured (MTOV==1 & INVALID==1)
        Macrotime = uint16(bitand(ByteRecord, 4095)); % Loads Macrotime
        MI = MI_Bins-1-uint16(bitand(bitshift(ByteRecord, -16), 4095)); % Loads Microtime
        clear ByteRecord
    elseif strcmp(Card, 'SPC-630 256chs')
        MT(bitand(Bits,12)==12) = bitand(ByteRecord(bitand(Bits,12)==12), 33554431); % Several overflows occured (MTOV==1 & INVALID==1)
        Macrotime = bitand(bitshift(ByteRecord, -8), 131071); % Loads 17 bit Macrotime in 32 bit
        MI = MI_Bins-1-uint8(bitand(ByteRecord, 255)); % Loads 8 bit Microtime in 8 bit
        clear ByteRecord
    else
        MT(bitand(Bits,12)==12) = bitand(ByteRecord2(bitand(Bits,12)==12), 16777215); % Several overflows occured (MTOV==1 & INVALID==1)
        Macrotime = bitand(ByteRecord2, 4294967295); % Loads 24 bit Macrotime in 32 bit
        MI = MI_Bins-1-uint16(bitand(ByteRecord1, 4095)); % Loads 12 bit Microtime in 16 bit
        clear ByteRecord1 ByteRecord2
    end
    MT = cumsum(double(MT))*MTres + double(Macrotime); % Transforms MT into continuous stream (as double)
    clear Macrotime;
    
    % Removes all remaining invalid entries (mostly overflow entries)
    MI(bitand(Bits,8)==8)=[];
    MT(bitand(Bits,8)==8)=[];
    Bits(bitand(Bits,8)==8)=[];
    % Remove last overflow photon; seems that sometimes the last entry is
    % somehow wrong
    if ~isempty(Bits) && bitand(Bits(end),12)==4
        MI(end)=[];
        MT(end)=[];
        Bits(end)=[];
    end
    
    % Checks for detection gaps due to fifo overflows
    if any(bitand(Bits,2)==2)
        msgbox(['FIFO overflow occured in file ', FullFileName]);
    end
    
    % Checks for MARK entries (usually frame, line or pixels entries)
    if sum(Scanner>0) && any(bitand(Bits,1)==1)
        Scanner_Mark=find(bitand(Bits,1)==1);
        Scanner_Rout=bitand(Bits(Scanner_Mark),112);
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
    MI(bitand(Bits,1)==1)=[];
    MT(bitand(Bits,1)==1)=[];
    Bits(bitand(Bits,1)==1)=[];
    
    Bits=bitshift(Bits, -4); % Only keeps routing bits
    UsedRout=unique(Bits)+1; % Finds all used routing channels
    
    % Photons are distributed according to routing bits
    if numel(MI~=0)
        if numel(UsedRout)==1 && UsedRout==1 %No routing/only first routing channel was used
            MT={MT}; MI={MI}; % Transform to cell array to keep file format consistent
        elseif numel(UsedRout)==1 % Only one routing channel was used
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
                % Bits = 0 is Routing channel 1
                MT{i,1} = MT{1,1}(Bits==i-1);
                MI{i,1} = MI{1,1}(Bits==i-1);
            end
            MT{1,1}(Bits~=0)=[];
            MI{1,1}(Bits~=0)=[];
        end
    else %%% Gives out empty cells
        MI={[]}; MT={[]};
    end
    clear Bits
end

end