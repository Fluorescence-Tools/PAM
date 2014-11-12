function Header = FabsurfInfo(FullFileName,ToRead)

% SCANNING AND GENERAL PARAMETERS:   
%   1   Time per Image [ms]            
%   2   Image Size:                     
%   3   Lines per Image
%   4   MT cal, ms
%   5   #Frames use
%   6   Objective Magnification
%       
% SCAN & TRACK PARAMETERS:  
%   7   Measurement Time
%   8   Threshold Right
%   9   Threshold Left
%   10  # of particles
%       
% CIRCULAR SCAN PARAMETERS:  
%   11  Scan Frequency
%   12  Scan Frequency Corrected
%   13  Scan Radius
%   14  Scanning Mode
%       
% POSITION PARAMETERS:   
%   15  OffSetX
%   16  OffSetY
%   17  LStep_X
%   18  LStep_Y
%   19  Cursor 1 X Position
%   20  Cursor 1 Y Position
%   21  Cursor 2 X Position
%   22  Cursor 2 Y Position
%   23  Current Z Plane
%   24  Current Piezo Z-position
%   25  Current Z-Position             
%      
%   26  Additional Information

%%% Parameters to be looked for are defined here
for i=1
Params{1}='Time per Image';
Params{2}='Image Size';
Params{3}='Lines per Image';
Params{4}='MT cal, ms';
Params{5}='#Frames use';
Params{6}='Objective Magnification';
Params{7}='Measurement Time';
Params{8}='Threshold Right';
Params{9}='Threshold Left';
Params{10}='# of particles';
Params{11}='Scan Frequency:';
Params{12}='Scan Frequency Corrected';
Params{13}='Scan Radius';
Params{14}='Scanning Mode';
Params{15}='OffSetX';
Params{16}='OffSetY';
Params{17}='LStep_X';
Params{18}='LStep_Y';
Params{19}='Cursor 1 X Position';
Params{20}='Cursor 1 Y Position';
Params{21}='Cursor 2 X Position';
Params{22}='Cursor 2 Y Position';
Params{23}='Current Z Plane';
Params{24}='Current Piezo Z-position';
Params{25}='Current Z-Position';
Params{26}='Additional Information';
end
%%% Header fieldnames are defined here
for i=1
Outputname{1}='Imagetime';
Outputname{2}='Imagesize';
Outputname{3}='Imagelines';
Outputname{4}='RepRate';
Outputname{5}='FramesUsed';
Outputname{6}='Objective';
Outputname{7}='MTime';
Outputname{8}='THR';
Outputname{9}='THL';
Outputname{10}='NoP';
Outputname{11}='ScanFreq';
Outputname{12}='ScanFreqCorrected';
Outputname{13}='ScanRadius';
Outputname{14}='ScanMode';
Outputname{15}='OffSetX';
Outputname{16}='OffSetY';
Outputname{17}='LStepX';
Outputname{18}='LStepY';
Outputname{19}='C1X';
Outputname{20}='C1Y';
Outputname{21}='C2X';
Outputname{22}='C2Y';
Outputname{23}='ZPlane';
Outputname{24}='PiezoPos';
Outputname{25}='ZPos';
Outputname{26}='Additional';
    
end
%%% Replacement parameters, if file is not found/complete are defined here
for i=1
% Replace{1}=UserValues.InfoParams.Imagetime;
% Replace{2}=UserValues.InfoParams.Imagesize;
% Replace{3}=UserValues.InfoParams.Lines;
% Replace{4}=1000/UserValues.InfoParams.MicroTime;
% Replace{5}=UserValues.InfoParams.FramesUsed;
% Replace{6}=60;
% Replace{7}=UserValues.InfoParams.TrackTime;
% Replace{8}=-1;
% Replace{9}=-1;
% Replace{10}=-1;
% Replace{11}=UserValues.InfoParams.ScanFreq;
% Replace{12}=UserValues.InfoParams.ScanFreqCor;
% Replace{13}=1;
% Replace{14}='Circle';
% Replace{15}=0;
% Replace{16}=0;
% Replace{17}=0;
% Replace{18}=0;
% Replace{19}=0;
% Replace{20}=0;
% Replace{21}=0;
% Replace{22}=0;
% Replace{23}=1;
% Replace{24}=0;
% Replace{25}=0;
% Replace{26}='';    
end
%%% Read all if not defined differntly
if  ~exist('ToRead','var')
    ToRead=1:26;
end

%%% Checks if and which infofile belongs to filename
fid1 = fopen([FullFileName(1:end-9) '_info' FullFileName(end-8:end-6) '.txt']);
fid2 = fopen([FullFileName(1:end-9) '_MeasureCursor_info' FullFileName(end-8:end-6) '.txt']);
fid3 = fopen([FullFileName(1:end-9) '_Scanning_info' FullFileName(end-8:end-6) '.txt']);
fid4 = fopen([FullFileName(1:end-9) '_Track_info' FullFileName(end-8:end-6) '.txt']);
fid5 = fopen([FullFileName(1:end-9) '_MeasureCursorSeries_info' FullFileName(end-8:end-6) '.txt']);
fid6 = fopen([FullFileName(1:end-10) '_info' FullFileName(end-9:end-6) '.txt']);
fid7 = fopen([FullFileName(1:end-10) '_MeasureCursor_info' FullFileName(end-9:end-6) '.txt']);
fid8 = fopen([FullFileName(1:end-10) '_Scanning_info' FullFileName(end-9:end-6) '.txt']);
fid9 = fopen([FullFileName(1:end-10) '_Track_info' FullFileName(end-9:end-6) '.txt']);
fid10 = fopen([FullFileName(1:end-10) '_MeasureCursorSeries_info' FullFileName(end-9:end-6) '.txt']);
fid11 = fopen([FullFileName(1:end-10) '_ZScan_info' FullFileName(end-9:end-6) '.txt']);
fid12 = fopen([FullFileName(1:end-10) '_ZTrack_info' FullFileName(end-9:end-6) '.txt']);
i=1;
fid=-1;
while i<13
    eval(['if fid' num2str(i) '~=-1; fid=fid' num2str(i) '; i=12;end;']);
    i=i+1;
end

%%% Looks for Parameters defined in Params and saves string in Output
Output=cell(26,1);
if fid ~= -1
    T=textscan(fid,'%s', 'delimiter', '\n','whitespace', '');
    T=T{1};
    for i=ToRead;
        if any(ToRead==i)
            j=1;
            while j<numel(T)
                if ~isempty(strfind(T{j},Params{i}))
                    Output{i} = T{j}(strfind(T{j},':')+1:end);
                    j=numel(T);
                end
                j=j+1;
            end
        end
    end  
else 
    disp('ERROR: Could not find info txt file');
end

%%% Writes value of Output into Header fieldnames defined by Outputname
Header=struct;
for i=[1:13 15:25]
    if strfind(Output{i},',')
        Output{i} = strrep(Output{i},',','.');
    end
        
    if ~isempty(Output{i})
        eval(['Header.' Outputname{i} '= str2double(Output{' num2str(i) '});']);
    else
        eval(['Header.' Outputname{i} '= [];']);
        %eval(['Header.' Outputname{i} '= str2double(Replace{' num2str(i) '});']);
    end
        
end
%%% Writes string of Output into Header fieldnames defined by Outputname
for i=[14 26]
    if ~isempty(Output{i})
        eval(['Header.' Outputname{i} '= Output{' num2str(i) '};']);
    else
        eval(['Header.' Outputname{i} '= [];']);
%         eval(['Header.' Outputname{i} '= Replace{' num2str(i) '};']);
    end
end
try
    fclose('all');
end
