function [MT, MI,SyncRate,Resolution] = Read_hdf5(FileName)

%%% read out the information from the photon-hdf5 file one by one

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

%%% sort photon data into matlab cell arrays
chan = unique(Channel);
for i = 1:(max(chan)+1)
    MT{chan(i)+1} = Macrotime(Channel == chan(i));
    MI{chan(i)+1} = Microtime(Channel == chan(i));
end
clear Macrotime Microtime Channel