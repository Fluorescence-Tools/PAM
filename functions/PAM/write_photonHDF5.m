function write_photonHDF5(~,~)
global FileInfo UserValues TcspcData

% check if phforge is installed
[status,cmdout] = system('phforge');
if status ~= 0
    disp(cmdout);
    disp('Adding conda path to system path...');
    %%% find users home directory
    if ispc
        home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
    else
        home = getenv('HOME');
    end
    %%% construct anaconda python path
    if ispc
        conda_path = [home '\anaconda\bin'];
    else
        conda_path = [home '/anaconda/bin'];
    end
    
    %%% add conda path to system path
    setenv('PATH', [getenv('PATH') ':' conda_path]);
    %%% try again
    [status,cmdout] = system('phforge');
    if status == 0
        disp('phforge is installed.');
    else
        disp(cmdout);
        disp('Please install phforge! For instructions vist http://photon-hdf5.github.io/phforge/');
        return;
    end
end
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

disp('Saving data to PhotonHDF5 file...');

%% Write YAML file with Mandatory Metadata
if ~isdir('temp')
    mkdir('temp');
end
filename = 'temp/metadata.yaml';

%% Mandatory Fields
description =          'Photon data from PAM';
%% Setup description
num_pixels =           4;
num_spots =            1;
num_polarization_ch =  2;
num_spectral_ch =      2;
num_split_ch =         1;
modulated_excitation = true;
if modulated_excitation
    modulated_excitation = 'True';
else
    modulated_excitation = 'False';
end
lifetime = true;
if lifetime
    lifetime = 'True';
else
    lifetime = 'False';
end

%% Format/Write Mandatory fields to YAML file

formatSpec = ['description: %s \n'...
'\n'...
'setup: \n'...
'    num_pixels: %hd                # number single-pixel detectors \n'...
'    num_spots: %hd                 # number of confocal excitation spots \n'...
'    num_spectral_ch: %hd           # 2 for donor and acceptor detection \n'...
'    num_polarization_ch: %hd       # 1 = no polarization selection \n'...
'    num_split_ch: %hd              # 1 = no beam splitting \n'...
'    modulated_excitation: %s   # us-ALEX alternation requires True here \n'...
'    lifetime: %s               # False = no TCSPC in detection \n'...
'\n'];

fileID = fopen(filename,'w');
fprintf(fileID,formatSpec,description,num_pixels,num_spots,num_spectral_ch,...
        num_polarization_ch,num_split_ch,modulated_excitation,lifetime);


%% Optional fields
%assumes two wavelengths

excitation_wavelengths = str2num(UserValues.MetaData.ExcitationWavelengths);
excitation_cw =          [false,false];

if excitation_cw(1,1)
    excitation_cwa = 'True';
else
    excitation_cwa = 'False';
end
if excitation_cw(1,2)
    excitation_cwb = 'True';
else
    excitation_cwb = 'False';
end
% map PIE channel selection to detector
PIEa = find(strcmp(UserValues.PIE.Name, UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}{1,1}));
PIEb = find(strcmp(UserValues.PIE.Name, UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}{3,1}));
deta = find( (UserValues.Detector.Det == UserValues.PIE.Detector(PIEa(1))) & (UserValues.Detector.Rout == UserValues.PIE.Router(PIEa(1))));
detb = find( (UserValues.Detector.Det == UserValues.PIE.Detector(PIEb(1))) & (UserValues.Detector.Rout == UserValues.PIE.Router(PIEb(1))));
wavelength_a = strsplit(UserValues.Detector.Filter{deta(1)},'/');
wavelength_b = strsplit(UserValues.Detector.Filter{detb(1)},'/');
detection_wavelengths = [str2num(wavelength_a{1}), str2num(wavelength_b{1})];

%% Format/Write Optional fields to YAML file
formatSpec = [...
'    excitation_wavelengths: [%g,%g]  # List of excitation wavelenghts \n'...
'    excitation_cw: [%s,%s]               # List of booleans, True if wavelength is CW \n'...
'    detection_wavelengths: [%g, %g]   # Center wavelength for each for detection ch \n'...
'\n'];

fprintf(fileID,formatSpec,excitation_wavelengths(1),excitation_wavelengths(1),...
        excitation_cwa,excitation_cwb,detection_wavelengths(1),...
        detection_wavelengths(2));

%% Sample Metadata

sample_name = UserValues.MetaData.SampleName;
buffer_name = UserValues.MetaData.SampleName;
dye_names =   UserValues.MetaData.DyeNames;

%% Write Sample Metadata to YAML file

formatSpec = ['sample: \n'...
'  sample_name: %s \n'...
'  buffer_name: %s \n' ...
'  dye_names: ''%s''   # Comma separates names of fluorophores \n'...
'\n'];

fprintf(fileID,formatSpec,sample_name,buffer_name,dye_names);


%% Identity Metadata

author =             UserValues.MetaData.User;
author_affiliation = 'none';

%% Format/Write Identity Metadata to YAML file

formatSpec = ['identity: \n'...
'    author: %s \n'...
'    author_affiliation: %s \n'...
'\n'];

fprintf(fileID,formatSpec, author, author_affiliation);

%% Provenance Metadata

expfilename = fullfile(FileInfo.Path,FileInfo.FileName{1}); %Experimental Filename e.g. 'photon_data.hdf5'
software =    FileInfo.FileType;

%% Format/Write Provenance Metadata to YAML file

formatSpec = ['provenance: \n'...
'    filename: ''%s'' \n'...
'    software: %s \n'...
'\n'];

fprintf(fileID,formatSpec,expfilename,software);

%% Photon Data Metadata

timestamps_unit =         FileInfo.ClockPeriod;
tcsp_unit =               FileInfo.SyncPeriod/FileInfo.MI_Bins;
tcspc_num_bins =          FileInfo.MI_Bins;
tcspc_range =             FileInfo.SyncPeriod;

laser_repetition_rate =   1/FileInfo.TACRange;
alex_excitation_period1 = [UserValues.PIE.From(PIEa) UserValues.PIE.To(PIEa)]; % take only the donor period
alex_excitation_period2 = [UserValues.PIE.From(PIEb) UserValues.PIE.To(PIEb)];

spectral_ch1 =            [0,1];
spectral_ch2 =            [2,3];

%% Format/Write Photon Data Metadata to YAML file

formatSpec = ['photon_data: \n'...
'    timestamps_specs: \n'...
'        timestamps_unit: %g  # 10 ns \n'...
'    nanotimes_specs: \n'...
'        tcspc_unit: %g \n'...
'        tcspc_num_bins: %hd \n'...
'        tcspc_range: %g \n'...
'\n'...
'    measurement_specs: \n'...
'        measurement_type: %s \n'...
'        laser_repetition_rate: %g  # 20 MHz \n'...
'        alex_excitation_period1: [%hd,%hd] \n'...
'        alex_excitation_period2: [%hd,%hd] \n'...
'\n'...
'        detectors_specs: \n'...
'            spectral_ch1: [%hd,%hd]  # list of donors detector IDs \n'...
'            spectral_ch2: [%hd,%hd]  # list of acceptors detector IDs'];

fprintf(fileID,formatSpec,timestamps_unit,tcsp_unit,tcspc_num_bins,tcspc_range,...
        measurement_type,laser_repetition_rate,alex_excitation_period1(1),...
        alex_excitation_period1(2),alex_excitation_period2(1),...
        alex_excitation_period2(2),spectral_ch1(1),spectral_ch1(2),spectral_ch2(1),spectral_ch2(2));

% Close file
fclose(fileID);

%% Convert photon data
% photon data needs to be mapped correctly to detectors in photonHDF5
% GG1,GG2 -> 1,2
% RR1,RR2 -> 3,4
% map burst search selection to PIE channels
chan(1) = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,1)));
chan(2) = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(1,2)));
chan(3) = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(3,1)));
chan(4) = find(strcmp(UserValues.PIE.Name,UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}(3,2)));

timestamps = [];
detectors = [];
nanotimes = [];
for i = 1:numel(chan)
    timestamps = [timestamps, int64(TcspcData.MT{UserValues.PIE.Detector(chan(i)),UserValues.PIE.Router(chan(i))}')];
    detectors = [detectors, uint8((i-1)*ones(1,numel(TcspcData.MT{UserValues.PIE.Detector(chan(i)),UserValues.PIE.Router(chan(i))})))];
    nanotimes = [nanotimes, uint16(TcspcData.MI{UserValues.PIE.Detector(chan(i)),UserValues.PIE.Router(chan(i))}')];
end
% sort the timestamps and detectors stamps
[timestamps, idx] = sort(timestamps);
detectors = detectors(idx);
nanotimes = nanotimes(idx);
clear idx
%% write photon data using temporary saving of h5 files
h5create('temp/photon_data.h5', '/timestamps', size(timestamps), 'Datatype', 'int64')
h5write('temp/photon_data.h5', '/timestamps', timestamps)
h5create('temp/photon_data.h5', '/detectors', size(detectors), 'Datatype', 'uint8')
h5write('temp/photon_data.h5', '/detectors', detectors)
h5create('temp/photon_data.h5', '/nanotimes', size(nanotimes), 'Datatype', 'uint16')
h5write('temp/photon_data.h5', '/nanotimes', nanotimes)

[~, name_old, ~] = fileparts(FileInfo.FileName{1});
filename = fullfile(FileInfo.Path, [name_old '.h5']);

[status,cmdout] = system(['phforge temp/metadata.yaml temp/photon_data.h5 ' filename],'-echo');
if status ~= 0
    disp('Something went wrong while saving the Photon-HDF5 file...');
    disp(cmdout);
end

delete('temp/metadata.yaml','temp/photon_data.h5');
rmdir('temp');