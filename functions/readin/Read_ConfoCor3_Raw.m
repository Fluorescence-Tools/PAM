function [MT, MI,SyncRate,Resolution,Header] = Read_ConfoCor3_Raw(FileName,NoE,ProgressAxes,ProgressText,FileNumber,NumFiles)
%%% Input parameters:
%%% Filename: Full filename
%%% NoE: Maximal number of entries to load
MT = cell(10);
MI = cell(10);

fid=fopen(FileName,'r');

Progress(0/NumFiles,ProgressAxes,ProgressText,['Processing Header of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ASCII file header processing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% some constants

% Globals for subroutines

%%% Following code reads out all values from header

% read Tag Head
Header.Header = fread(fid, 64, '*char')'; % TagHead.Ident
Header.Identifier = fread(fid, 4, 'uint32');    % TagHead.Idx
Header.Settings = fread(fid, 4, 'uint32');   % TagHead.Typ
Skip = fread(fid, 8, 'uint32'); % Skip 8 4-byte integers
% TagHead.Value will be read in the
% right type function
%fprintf(1,'\n   %-40s', EvalName);
SyncRate = Header.Settings(4);
Resolution = 1;% Resolution in picoseconds!
%%% read out the detection channel from the Header
channel = str2double(Header.Header(end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This reads the T3 mode event records
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Progress(0.1/NumFiles,ProgressAxes,ProgressText,['Reading Byte Record of File ' num2str(FileNumber) ' of ' num2str(NumFiles) '...']);

T3Record = fread(fid, NoE, 'uint32');  % all 32 bits:
fclose(fid);

MT{channel,1} = cumsum(T3Record);
clear T3Record
MI{channel,1} = 100*ones(size(MT{channel,1}));

Progress(1/NumFiles,ProgressAxes,ProgressText, ['File ' num2str(FileNumber) ' of ' num2str(NumFiles) ' loaded']);

end
