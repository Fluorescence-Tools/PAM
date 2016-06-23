function [success] = save_hdf5_python()
global TcspcData FileInfo UserValues
%%% function to save our data structure as photon-hdf5
%% input validation
if ~isstruct(TcspcData) || ~isstruct(FileInfo)
    success = 0;
    disp('Input must be PAM data structures!');
    return;
end
%% validate python installation
condaPython = assert_condapython();
if ~condaPython
    disp('Conda Python not set.');
    return;
end
pythonInstalled = check_python_hdf5();
if ~pythonInstalled
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
laser_repetition_rate = FileInfo.TACRange;
%%% PIE channel boundaries
%%% no separate definition for the FRET channel is present in hdf5 file format
alex_excitation_period1 = [UserValues.PIE.From(1) UserValues.PIE.To(1)]; % take only the donor period
alex_excitation_period2 = [UserValues.PIE.From(3) UserValues.PIE.To(3)];
% read out the detectors for every color
spectral_ch1 = UserValues.PIE.Detector(1:2);
spectral_ch2 = UserValues.PIE.Detector(5:6);
% read out the detectors for every polarization
polarization_ch1 = UserValues.PIE.Detector([1,5]);
polarization_ch2 = UserValues.PIE.Detector([2,6]);

detectors_specs = py.dict(pyargs(...
    'spectral_ch1',py.numpy.array(py.list(spectral_ch1)),...
    'spectral_ch2',py.numpy.array(py.list(spectral_ch2)),...
    'polarization_ch1',py.numpy.array(py.list(polarization_ch1)),...
    'polarization_ch2',py.numpy.array(py.list(polarization_ch2))...
    ));
measurement_specs = py.dict(pyargs(...
    'measurement_type',measurement_type,...
    'laser_repetition_rate',laser_repetition_rate,...
    'alex_excitation_period1',py.numpy.array(py.list(alex_excitation_period1)),....
    'alex_excitation_period2',py.numpy.array(py.list(alex_excitation_period2)),...
    'detectors_specs',detectors_specs...
    ));

%% photon data group - convert PAM data
% timestamps are macrotimes in int64, as one array!
% microtime should be given in?
% detectors need to be converted to single array as well!
timestamps = [];
detectors = [];
nanotimes = [];
for i = 1:numel(TcspcData.MT)
    timestamps = [timestamps, TcspcData.MT{i}'];
    detectors = [detectors, (i-1)*ones(1,numel(TcspcData.MT{i}))];
    nanotimes = [nanotimes, TcspcData.MI{i}'];
end

% sort the timestamps and detectors stamps
[timestamps, idx] = sort(timestamps);
detectors = detectors(idx);
nanotimes = nanotimes(idx);
timestamps_unit = FileInfo.ClockPeriod; % ClockPeriod
tcspc_unit = FileInfo.SyncPeriod/FileInfo.MI_Bins;
tcspc_num_bins = FileInfo.MI_Bins;
tcspc_range = FileInfo.SyncPeriod;

% convert photon data to numpy arrays
timestamps = py.numpy.array(py.list(timestamps));
detectors = py.numpy.array(py.list(detectors));
nanotimes = py.numpy.array(py.list(nanotimes));

% make photon_data python dict
photon_data = py.dict(pyargs('timestamps',timestamps,'detectors',detectors,'nanotimes',nanotimes,...
'timestamps_specs',py.dict(pyargs('timestamps_unit', timestamps_unit)),...
'nanotimes_specs',py.dict(pyargs('tcspc_unit',tcspc_unit,'tcspc_num_bins',tcspc_num_bins,'tcspc_range',tcspc_range)),...
'measurement_specs',measurement_specs...
));
clear timestamps detectors nanotimes measurement_specs detectors_specs

%% setup group - information about the setup

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

%%% query the rest of the parameters using input dialog

% excitation wavelengths
excitation_wavelenghts = {480e-9,647e-9};
% excitation type (i.e. cw or not = pulsed)
excitation_cw = {false,false,false};
% detection wavelengths
detection_wavelengths = {500e-9,670e-9};

description = 'Photon data from PAM.';
% query username
if ispc
    author = getenv('USERNAME');
elseif ismac
    author = getenv('USER');
end
author_affiliation = '';


sample_name = FileInfo.FileName{1};
buffer_name = '';
dye_names = 'Donor, Acceptor';   % Comma separates names of fluorophores



% file information
filename = fullfile(FileInfo.Path,FileInfo.FileName{1});
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
    'excitation_wavelengths', py.list(excitation_wavelenghts),...         % List of excitation wavelenghts
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


%% Save the file to .hdf5
%minimal file
data = py.dict(pyargs(...
    'description',description,...
    'photon_data', photon_data,...
    'setup',setup,...
    'identity',identity,...
    'provenance',provenance...
));
clear description photon_data setup identity provenance
% save
[~, name_old, ~] = fileparts(FileInfo.FileName{1});
filename_hdf5 = fullfile(FileInfo.Path, [name_old '.h5']);
py.phconvert.hdf5.save_photon_hdf5(data,pyargs('h5_fname',filename_hdf5));
clear data
