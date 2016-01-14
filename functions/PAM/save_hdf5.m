function [success] = save_hdf5(TcspcData, FileInfo, UserValues)
%%% function to save our data structure as photon-hdf5

%% input validation
if ~isstruct(TcspcData) || ~isstruct(FileInfo)
    success = 0;
    disp('Input must be PAM data structures!');
    return;
end

%% measurement specs group
%%% check what kind of data is to be saved
switch UserValues.BurstSearch.Method
    case {1,2} % 2color MFD
        measurement_type = 'smFRET-nsALEX';
    case {3,4} % 3color MFD
        disp('3C-MFD (nsALEX) data is currently not supported.');
        return;
    case 5
        disp('No-MFD data is currently not supported.');
        return;
end

%%% read out the PIE channel numbers of burst search selections
donor_par = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}{1,1}));
donor_per = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}{1,2}));
acceptor_par = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}{3,1}));
acceptor_per = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}{3,2}));

%%% we need to map the detector routing combination in PAM to a single
%%% detector number in hdf5!
% read out ordered list of detector/routing pairs
chans = [donor_par, donor_per, acceptor_par, acceptor_per];
det_rout = [UserValues.PIE.Detector(chans)',UserValues.PIE.Router(chans)'];

%%% laser repetition rate is given by syncrate at TCSPC hardware
laser_repetition_rate = 1/FileInfo.SyncPeriod;
%%% PIE channel boundaries
%%% no separate definition for the FRET channel is present in hdf5 file format
alex_excitation_period1 = [UserValues.PIE.From(donor_par) UserValues.PIE.To(donor_par)]; % take only the donor period
alex_excitation_period2 = [UserValues.PIE.From(acceptor_par) UserValues.PIE.To(acceptor_par)];
% spectral channels are hard coded since detector/routing pairing is
% transformed anyway
spectral_ch1 = [1,2];
spectral_ch2 = [3,4];
polarization_ch1 = [1,3];
polarization_ch2 = [2,4];

detectors_specs = py.dict(pyargs('spectral_ch1',py.numpy.array(py.list(num2cell(spectral_ch1))),...
    'spectral_ch2',py.numpy.array(py.list(num2cell(spectral_ch2))),...
    'polarization_ch1',py.numpy.array(py.list(num2cell(polarization_ch1))),...
    'polarization_ch2',py.numpy.array(py.list(num2cell(polarization_ch2)))...
    ));
measurement_specs = py.dict(pyargs(...
    'measurement_type',measurement_type,...
    'laser_repetition_rate',laser_repetition_rate,...
    'alex_excitation_period1',py.numpy.array(py.list(num2cell(alex_excitation_period1))),....
    'alex_excitation_period2',py.numpy.array(py.list(num2cell(alex_excitation_period2))),...
    'detectors_specs',detectors_specs...
    ));

%% photon data group - convert PAM data
% timestamps are macrotimes in int64, as one array!
% microtime should be given in?
% detectors need to be converted to single array as well!

%%% to account for routing also, we need to use the detector/routing
%%% pairing for each "virtual" detector in PAM and convert this to a single
%%% detector number in hdf5

timestamps = [];
detectors = [];
nanotimes = [];

for i = 1:size(det_rout,1) % loop over detectors
    timestamps = [timestamps, TcspcData.MT{det_rout(i,1), det_rout(i,2)}'];
    nanotimes = [nanotimes, TcspcData.MI{det_rout(i,1), det_rout(i,2)}'];
    detectors = [detectors, (i-1)*ones(1,numel(TcspcData.MT{det_rout(i,1), det_rout(i,2)}))];
end
% sort the timestamps and detectors stamps
[timestamps, idx] = sort(timestamps);
detectors = detectors(idx);
nanotimes = nanotimes(idx);
timestamps = uint64(timestamps);
timestamps_unit = FileInfo.ClockPeriod; % ClockPeriod can differ from SyncPeriod
tcspc_unit = FileInfo.TACRange/FileInfo.MI_Bins; %%% TCSPC unit is determined by TACRange
tcspc_num_bins = FileInfo.MI_Bins;
tcspc_range = FileInfo.TACRange;

% convert photon data to numpy arrays
timestamps = py.numpy.array(py.list(num2cell(timestamps)));
detectors = py.numpy.array(py.list(num2cell(detectors)));
nanotimes = py.numpy.array(py.list(num2cell(nanotimes)));

% make photon_data python dict
photon_data = py.dict(pyargs('timestamps',timestamps,'detectors',detectors,'nanotimes',nanotimes,...
'timestamps_specs',py.dict(pyargs('timestamps_unit', timestamps_unit)),...
'nanotimes_specs',py.dict(pyargs('tcspc_unit',tcspc_unit,'tcspc_num_bins',tcspc_num_bins,'tcspc_range',tcspc_range)),...
'measurement_specs',measurement_specs...
));

%% setup group - information about the setup

%%% following values are hard coded for PIE-spFRET experiment
% number of dyes
num_dyes = 2;
% number of detectors
num_pixels = 4;
% number of excitation spots
num_spots = 1;
% number of polarizations used
num_polarization_ch = 2;
% number of spectral channels
num_spectral_ch = 2;
% number of channels split by 50:50 beamsplitters
num_split_ch = 1;
% modulated excitation, i.e. PIE or ALEX
modulated_excitation = true;
% lifetime information, i.e. PIE
lifetime = true;

%%% query the rest of the parameters from meta data

% excitation wavelengths
excitation_wavelengths= sscanf(UserValues.MetaData.ExcitationWavelengths,'%f,',[1,Inf]);
if numel(excitation_wavelengths) ~= 2
    disp('Error, please specify exactly two excitation wavelengths using comma separation!');
    return;
end
excitation_wavelengths = num2cell(1e-9*excitation_wavelengths);
% excitation type (i.e. cw or not = pulsed)
excitation_cw = {false,false};
% detection wavelengths
detection_wavelengths = [sscanf(UserValues.Detector.Filter{spectral_ch1(1)},'%f'), sscanf(UserValues.Detector.Filter{spectral_ch2(1)},'%f')];
detection_wavelengths = num2cell(1e-9*detection_wavelengths);

description = 'Photon data from PAM.';
author = UserValues.MetaData.User;
author_affiliation = '';


sample_name = UserValues.MetaData.SampleName;
buffer_name = UserValues.MetaData.BufferName;
dye_names = UserValues.MetaData.DyeNames;   % Comma separates names of fluorophores



% file information
filename = fullfile(FileInfo.Path, FileInfo.FileName{1});
software = FileInfo.FileType;

%% make a matlab structure equivalent to the hdf5 specifications
% data = struct;
% 
% data.photon_data.timestamps = timestamps;
% data.photon_data.detectors = detectors;
% data.photon_data.nanotimes = nanotimes;
% data.photon_data.measurement_specs.measurement_type = measurement_type;
% data.photon_data.measurement_specs.laser_repetition_rate = laser_repetition_rate;
% data.photon_data.measurement_specs.alex_excitation_period1 = alex_excitation_period1;
% data.photon_data.measurement_specs.alex_excitation_period2 = alex_excitation_period2;
% 
% data.photon_data.measurement_specs.detectors_specs.spectral_ch1 = spectral_ch1;
% data.photon_data.measurement_specs.detectors_specs.spectral_ch2 = spectral_ch2;
% data.photon_data.measurement_specs.detectors_specs.polarization_ch1 = polarization_ch1;
% data.photon_data.measurement_specs.detectors_specs.polarization_ch2 = polarization_ch2;

%% create Photon-HDF5 data structure using python dicts

% setup group
setup = py.dict(pyargs(...        % Mandatory fields
    'num_pixels', num_pixels,...               % using 2 detectors
    'num_spots', num_spots, ...               % a single confocal excitation
    'num_spectral_ch', num_spectral_ch,...          % donor and acceptor detection 
    'num_polarization_ch', num_polarization_ch, ...     % no polarization selection 
    'num_split_ch', num_split_ch, ...            % no beam splitter
    'modulated_excitation', modulated_excitation,... % CW excitation, no modulation 
    'lifetime', lifetime, ...            % no TCSPC in detection - ## Optional fields
    'excitation_wavelengths', py.list(excitation_wavelengths),...         % List of excitation wavelenghts
    'excitation_cw', py.list(excitation_cw),  ...                  % List of booleans, True if wavelength is CW
    'detection_wavelengths', py.list(detection_wavelengths)...  % Nominal center wavelength   % each for detection ch                                            
));

% provencance group
provenance = py.dict(pyargs(...
    'filename',filename, ...
    'software',software));

%identity group
identity = py.dict(pyargs(...
    'author',author,...
    'author_affiliation',author_affiliation));

%sample group
sample = py.dict(pyargs(...
    'num_dyes',num_dyes,...
    'dye_names',dye_names,...
    'buffer_name',buffer_name,...
    'sample_name',sample_name...
    ));
%% Save the file to .hdf5
%minimal file
data = py.dict(pyargs(...
    'description',description,...
    'photon_data', photon_data,...
    'setup',setup,...
    'identity',identity,...
    'provenance',provenance,...
    'sample',sample...
));

% save
[~, name_old, ~] = fileparts(FileInfo.FileName{1});
filename_hdf5 = [FileInfo.Path filesep name_old '.h5'];
py.phconvert.hdf5.save_photon_hdf5(data,pyargs('h5_fname',filename_hdf5));