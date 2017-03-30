function [MT, MI,SyncRate,Resolution] = Read_hdf5(FileName)
% read out the information from the photon-hdf5 file one by one
%
% Args:
%   * FileName: Full path to file
%
% Returns:
%   * MT: Cell array of macrotimes in the file for every detector
%   * MI: Cell array of microtimes in the file for every detector
%   * SyncRate: Repetition rate/TAC range
%   * Resolution: Microtime resolution in picoseconds

%%% confirm the measurement type
measurementType = h5read(FileName,'/photon_data/measurement_specs/measurement_type');
if ~strcmp(measurementType,'smFRET-nsALEX')
    disp(['Measurement Type "' measurementType '" not supported yet.']);
    return;
end
SyncRate = h5read(FileName,'/photon_data/measurement_specs/laser_repetition_rate');
TACRange = h5read(FileName,'/photon_data/nanotimes_specs/tcspc_range');
Resolution = h5read(FileName,'/photon_data/nanotimes_specs/tcspc_unit');
MIBins = h5read(FileName,'/photon_data/nanotimes_specs/tcspc_num_bins');
ClockRate = h5read(FileName,'/photon_data/timestamps_specs/timestamps_unit');

%%% read the macrotimes, microtimes and channel stamps
Macrotime = h5read(FileName,'/photon_data/timestamps');
Microtime = h5read(FileName,'/photon_data/nanotimes');
Channel = h5read(FileName,'/photon_data/detectors');

MT = cell(10,1);
MI = cell(10,1);

%%% sort photon data into matlab cell arrays
chan = unique(Channel);
for i = 1:(max(chan)+1)
    MT{chan(i)+1} = Macrotime(Channel == chan(i));
    MI{chan(i)+1} = Microtime(Channel == chan(i));
end
clear Macrotime Microtime Channel