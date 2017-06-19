function [MT, MI, Header] = Read_BH(FileName,NoE,Card)

%%% Input parameters:
%%% Filename: Full filename
%%% NoE: Maximal number of entries to load
%%% Mark: defines, which marks to use; [Pixel Line Frame];

%%% Output parameters:
%%% ClockRate: the macrotime clock. For SPC-140/150/830/130, the Becker and 
%%% Hickl software can be set to use the SyncRate as the MT clock, for SPC-630
%%% the MT clock is 50 ns

Header = struct;

FileID = fopen(FileName, 'r');
switch Card
    case {'SPC-140/150/130', 'SPC-830'}
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Data is arranged per 4 bytes
        %%%% Data is read in at 32 bits
        %%%% The first photon frame (4 bytes) in the .spc file is added by the software and contains information
        %%%% about the Macro Time clock (resolution 0.1 ns) and the number of routing channels used during the measurement:
        %%%% byte 0,1,2     = macro time clock in 0.1 ns units ( for 50ns value 500 is set )
        %%%%        SPC130/830/140/150: MT clock can be 50 ns or the Sync Rate (Only if external clocking is selected in measurement preferences rather than 50ns internal clock!)
        %%%%        SPC630: MT clock is 50 ns
        %%%% byte 3 : bit 7 = 1 ( Invalid photon ),  bits 3-6 = number of routing bits,
        %%%%          bit 2 = 1 file with raw data ( for diagnostic mode only,
        %%%%                       such file contains pure data read from FIFO without special meaning
        %%%%                       of the entries with 'MTOV = 1' and 'INVALID = 1' described below )
        %%%%          bit 1 = 1 file with markers ( new SPC-140, SPC-150, see below)
        %%%%          bit 0 = reserved
        %%%% Bit/Byte 7     6       5       4       3       2       1       0
        %%%%          inval rout    rout    rout    rout    raw     mark    res             
        
        %%%% every photon is stored as follows in 4 bytes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% File format:
        %%%% Bit/Byte 7     6       5       4       3       2       1       0
        %%%%       1  MT8   MT7     MT6     MT5     MT4     MT3     MT2     MT1
        %%%%       2  ROUT4 ROUT3   ROUT2   ROUT1   MT12    MT11    MT10    MT9  
        %%%%       3  MI8   MI7     MI6     MI5     MI4     MI3     MI2     MI1
        %%%%       4  INVAL MTOV    GAP     MARK    MI12    MI11    MI10    MI9  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        ByteRecord = fread(FileID, NoE, 'uint32=>uint32');
        fclose(FileID);
        clear FileID;
        
        if numel(ByteRecord) < 2 % Even empty file will contain sync rate
            %h = msgbox(['Empty file: ', FileName]);
            %disp(['Empty file: ', FileName])
            %pause(1)
            %close(h)
            MT = {[]};
            MI = {[]};
            Header.ClockRate = 1E10/double(bitand(ByteRecord(1), bin2dec('00000000111111111111111111111111')));
            return;
        else
            %the sync rate is contained in the first 3 bytes of the first 32-bit word
            %record in units of 100 ps
            Header.ClockRate = 1E10/double(bitand(ByteRecord(1), bin2dec('00000000111111111111111111111111')));
            NumberOfRoutingBits = uint8(bitand(bitshift(ByteRecord(1), - 27), 15))+1; %...00001111
            % +1 because there's always at least 1 route
            InvalidFirstPhoton = isequal(double(bitand(ByteRecord(1), 2147483648)), 2147483648); % is the very last bit of the first 32-bit word = 1 ?
            ByteRecord(1)=[]; %%% Delete Header entry
            
            % put Rout in the top 4 bits, since in the lower 4 we need to put the Mark. 
            Rout=uint8(bitand(bitshift(ByteRecord, - 8), 240)); % Loads Routing bits
            % if MARK == 0
            % Routing channel 1 => Rout = 00000000 = 0
            % Routing channel 2 => Rout = 00010000 = 16
            % Routing channel 3 => Rout = 00100000 = 32
            % Routing channel 4 => Rout = 00110000 = 48
            % if MARK == 1, then the pixel, line, frame bits are written into Rout
            Mark = uint8(bitand(bitshift(ByteRecord, -28),  15)); % Loads Mark, Gap, Macrotime Overflow and Invalid bits
            %disp(['Number of invalid entries in ' FileName ': ' num2str(numel(find(Mark==8)))])
            Mark = Mark+Rout; % Combines Rout and Mark to save memory (Matlab has not file format < 8bit)
            clear Rout;
            %%%% Mark structure
            %%%% Bit/Byte 7     6       5       4       3       2       1       0
            %%%%          ROUT4 ROUT3   ROUT2   ROUT1   INVAL   MTOV    GAP     MARK
            %%%% 25 = 00011001
            %%%% 29 = 00011101
            
            MT=uint32(zeros(numel(Mark),1)); % Initializes macrotime overflow variable
            
            % MTOV==1 & INVALID==0 & MARK==0
            % a single overflow occurred between this and the previous entry. 
            % this entry is a photon
            MT(bitand(Mark,12)==4)=1; %4=00000100 12=00001100
            
            % MTOV==1 & INVALID==1 & MARK==1
            % a single overflow occurred between this and the previous entry. 
            % this entry is a marker
            MT(bitand(Mark,13)==13)=1; %13=00001101
            
            % MTOV==1 & INVALID==1 & MARK==0
            % no photon was recorded between this and the previous MT overflow
            % Entry is the number of times the MT overflowed, i.e. the CNT thing in the handbook; written in 28 bits
            MT(bitand(Mark,13)==12)=bitand(ByteRecord(bitand(Mark,13)==12),268435455); %13=00001101  12=00001100 268435455 = first 28 bits
            
            Macrotime=uint16(zeros(numel(Mark),1));
            
            %Load the actual Macrotime from the lower 12 bits for all entries except the (MTOV==1 & INVALID==1 & MARK==0) entries
            %Waldi: this is different from before. It's more correct since the CNT entries do not hold MT counts but number of complete MTOVs
            Macrotime(bitand(Mark,13)~=12)=uint16(bitand(ByteRecord(bitand(Mark,13)~=12), 4095)); 
           
            MI=4095-uint16(bitand(bitshift(ByteRecord, -16), 4095)); % Loads Microtime from lower 12 of upper 16 bits
            clear ByteRecord;
            
            MT=cumsum(double(MT))*4096+double(Macrotime); % Transforms MT into continuous stream (as double)
            clear Macrotime;
        end
        Header.SyncRate = Header.ClockRate; %only true if the laser is the MT clock
        % If SyncRate ~= ClockRate, hardcode it in a custom read-in routine!
        
    case 'SPC-630 256chs'
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
        fclose(FileID);
        clear FileID;
        
        if numel(ByteRecord) < 2 % Even empty file will contain sync rate
            h = msgbox(['Empty file: ', FileName]);
            disp(['Empty file: ', FileName])
            pause(1)
            close(h)
        else
            %the Header.ClockRate is contained in the first 3 bytes of the first
            %record in units of 100 ps
            Header.ClockRate = 1E10/double(bitand(ByteRecord(1), bin2dec('00000000111111111111111111111111')));
            Header.SyncRate = 1; %SPC-630 cards cannot use the laser as sync rate!
            
            ByteRecord(1)=[]; %%% Delete Header entry
            % Non macro/microtime information
            Rout = uint8(bitand(bitshift(ByteRecord, - 21), 112));
            Mark = uint8(bitand(bitshift(ByteRecord, - 28),  15));
            disp(['Number of invalid entries in ' FileName ': ' num2str(numel(find(Mark==8)))])
            disp(['Number of multi MTOVs ' FileName ': ' num2str(numel(find(Mark==12)))])
            Mark = Mark + Rout;
            % Mark combines Rout and Mark to save memory (Matlab has not file format < 8bit)
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
            clear Rout;
            
            MT = uint32(zeros(numel(Mark),1)); % Initializes macrotime overflow variable
            MT(bitand(Mark,12)==4) = 1; % One single overflow occured (MTOV==1 & INVALID==0)
            MT(bitand(Mark,12)==12) = bitand(ByteRecord(bitand(Mark,12)==12), 33554431); % Several overflows occured (MTOV==1 & INVALID==1)
            Macrotime = bitand(bitshift(ByteRecord, -8), 131071); % Loads 17 bit Macrotime in 32 bit
            MI = 255-uint8(bitand(ByteRecord, 255)); % Loads 8 bit Microtime in 8 bit
            clear ByteRecord
            MT = cumsum(double(MT))*2^17 + double(Macrotime); % Transforms MT into continuous stream (as double)
            clear Macrotime;
        end
    case 'SPC-630 4096chs'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Data is arranged per 6 bytes
        %%%% We first read the data at 16bits
        ByteRecord = fread(FileID, NoE, 'uint16=>uint16');
        %%%% First 6 bytes of ByteRecord contains Resolution of macrotime (MT) clock in units of 0.1ns
        %%%% SPC630: MT clock is always 50 ns
        %%%%
        %%%% From b&h header information file:
        %%%% =================================
        %%%% The first photon frame (6 bytes) in the .spc file is added by the software and contains information
        %%%% about the Macro Time clock and the number of routing channels used during the measurement:
        %%%%   byte 0, 4, 5 = 0
        %%%%   byte 1 : bit 4 has to be 1 cause it's an invalid photon
        %%%%            bits 3-0 = number of routing bits
        %%%%   byte 2,3     = macro time clock in 0.1 ns units (for 50ns value 500 is set)

                
        % record in units of 100 ps
        % ByteRecord(1) is bytes 0 and 1;
        % ByteRecord(2) is bytes 2 and 3 and thus contains the Header.ClockRate;
        Header.ClockRate = 1E10/double(ByteRecord(2));  
        Header.SyncRate = 1; %SPC-630 cards cannot use the laser as sync rate!
        InvalidFirstPhoton = isequal(double(bitand(ByteRecord(1), 4096)), 4096); % is byte 1 bit 4 = 1 ?
        % cut ByteRecord(1) at 8bit and put the top 4 bits to 0:
        NumberOfRoutingBits = uint8(bitand(bitshift(ByteRecord(1), -8), 15))+1; %00001111
        % +1 because there's always at least 1 route
        
        %%%% Important:
        %%%% To be able to do bitwise operations, we have to put the 6-byte file
        %%%% into one 16bit and one 32bit variable
        ind = uint32(1:3:round(numel(ByteRecord)));
        ByteRecord1 = ByteRecord(ind); %16bit
        %            Bit 7           <=           Bit 0
        % Byte 0:    ADC7             <=          ADC0
        % Byte 1:    0  GAP MTOV INVALID ACD11 <= ADC8
        ByteRecord2 = bitor(bitshift(uint32(ByteRecord(ind+1)),16), uint32(ByteRecord(ind+2))); %32bit
        %            Bit 7  <=   Bit 0
        % Byte 0:    MT7    <=   MT0
        % Byte 1:    MT15   <=   MT8
        % Byte 2:    MT23   <=   MT16
        % Byte 3:    R7     <=   R0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        fclose(FileID);
        clear FileID ByteRecord;
        
        if numel(ByteRecord1) < 2 % Even empty file will contain sync rate
            h = msgbox(['Empty file: ', FileName]);
            disp(['Empty file: ', FileName])
            pause(1)
            close(h)
        else
            ByteRecord1(1)=[]; %%% Delete Header entry
            ByteRecord2(1)=[]; %%% Delete Header entry
            % Non macro/microtime information
            % put Rout in the top 4 bits, since in the lower 4 we need to put the Mark. 
            % we loose the top 4 routing bits, but they're empty anyway
            Rout = uint8(bitand(bitshift(ByteRecord2, - 20), 240)); %11110000
            % Routing channel 1 => Rout = 00000000 = 0
            % Routing channel 2 => Rout = 00010000 = 16
            % Routing channel 3 => Rout = 00100000 = 32
            % Routing channel 4 => Rout = 00110000 = 48
             
            tmp = uint8(bitand(bitshift(ByteRecord1, - 12),  15));
            Mark = tmp;
            Mark = bitset(Mark,1,bitget(tmp, 4)); %MARK
            Mark = bitset(Mark,2,bitget(tmp, 3)); %GAP
            Mark = bitset(Mark,3,bitget(tmp, 2)); %MTOV
            Mark = bitset(Mark,4,bitget(tmp, 1)); %INVALID
            disp(['Number of invalid entries in ' FileName ': ' num2str(numel(find(Mark==8)))])
            Mark = Mark + Rout;
            clear Rout tmp;
            % Mark combines Rout and Mark to save memory (Matlab has not file format < 8bit)
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
            %   macrotime overflow bit, written in the next real photon
            %   MTOV = 1 and INV = 1 does not mean multiple MTOV overflows!
            % GAP:
            %   a FIFO overflow occurred. Data is likely invalid
            % MARK:
            %   scanning information, with MARK = 0 for 'SPC-630'

            MT = uint32(zeros(numel(Mark),1)); % Initializes macrotime overflow variable
            MT(bitand(Mark,4)==4) = 1; % One single overflow occured (MTOV==1 & INVALID==0) or (MTOV==1 & INVALID==1)
            Macrotime = bitand(ByteRecord2, 16777215); % Loads 24 bit Macrotime in 32 bit
            MI = 4095-uint16(bitand(ByteRecord1, 4095)); % Loads 12 bit Microtime in 16 bit
            clear ByteRecord1 ByteRecord2
            MT = cumsum(double(MT))*2^24 + double(Macrotime); % Transforms MT into continuous stream (as double)
            clear Macrotime;
        end
end

% Checks for detection gaps due to fifo overflows
if any(bitand(Mark,2)==2)
    h = msgbox(['FIFO overflow occured in ', FileName, '. Data is likely invalid!']);
    disp(['FIFO overflow occured in ', FileName, '. Data is likely invalid!'])
    pause(1)
    close(h)
end

% Checks for Mark entries (usually frame, line or pixels entries)
if any(bitand(Mark,1)==1)
        Header.PixelMarker= MT(bitand(Mark, 25)==25); %00011001
        Header.LineMarker= MT(bitand(Mark, 41)==41); %00101001
        Header.FrameMarker= MT(bitand(Mark, 73)==73); %01001001  
else
    Header.PixelMarker = [];
    Header.LineMarker = [];
    Header.FrameMarker = [];
end

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
            MT{i,1}=[]; MI{i,1}=[]; % Creates empty cell entries for unused routing channels
        end
        % Shifts photons into the correct routing channel
        % This way, no photon is assigned to more than one variable to save memory
        MT=circshift(MT,UsedRout-1);
        MI=circshift(MI,UsedRout-1);
    else
        MT={MT}; MI={MI}; % Transform to cell array
        for i=2:max(UsedRout)
            % Shifts photons to the corresponding routing channel
            MT{i,1}=MT{1,1}(Mark==i-1);
            MI{i,1}=MI{1,1}(Mark==i-1);
            MT{1,1}(Mark==i-1)=[];
            MI{1,1}(Mark==i-1)=[];
            Mark(Mark==i-1)=[];            
        end
        
    end
else %%% Gives out empty cells
    MI={[]}; MT={[]};
end
clear Mark
end