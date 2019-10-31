function [MT, MI, datastruct] = Read_PhotonHDF5(file)
% reads PhotonHDF5 data into matlab structure for further processing

%%% first check for measurement type
measurement_type = h5read(file,'/photon_data/measurement_specs/measurement_type');
disp(['Measurement type of loaded file is : ' measurement_type]);

%%% read general info from file
datastruct = struct;
%%% general info - /
datastruct.description = h5read(file,'/description');
datastruct.acquisiton_duration = h5read(file,'/acquisition_duration');

%%% /identity group
try;datastruct.identity.author = h5read(file,'/identity/author');end;
try;datastruct.identity.author_affiliation = h5read(file,'/identity/author_affiliation');end;
try;datastruct.identity.creation_time = h5read(file,'/identity/creation_time');end;
try;datastruct.identity.fname_full = h5read(file,'/identity/filename_full');end;
try;datastruct.identity.format_name = h5read(file,'/identity/format_name');end;
try;datastruct.identity.format_url = h5read(file,'/identity/format_url');end;
try;datastruct.identity.format_version = h5read(file,'/identity/format_version');end;
try;datastruct.identity.software = h5read(file,'/identity/software');end;
try;datastruct.identity.software_version = h5read(file,'/identity/software_version');end;

%%% /provenance group
try
    datastruct.provenance.creation_time = h5read(file,'/provenance/creation_time');
catch
    datastruct.provenance.creation_time = string(datetime);
end
try
    datastruct.provenance.filename = h5read(file,'/provenance/filename');
catch
    [~,filen,ext] = fileparts(file);
    datastruct.provenance.filename = [filen, ext];
end
try
    datastruct.provenance.filename_full = h5read(file,'/provenance/filename_full');
catch
    datastruct.provenance.filename_full = file;
end
try
    datastruct.provenance.modification_time = h5read(file,'/provenance/modification_time');
catch
    datastruct.provenance.modification_time = string(datetime);
end
try
    datastruct.provenance.software = h5read(file,'/provenance/software');
catch
    datastruct.provenance.software = 'unknown';
end

%%% /sample group
try
    datastruct.sample.buffer_name = h5read(file,'/sample/buffer_name');
catch
    datastruct.sample.buffer_name = 'Buffer';
end
try
    datastruct.sample.dye_names = h5read(file,'/sample/dye_names');
catch
    datastruct.sample.dye_names = 'Dye names';
end
try
    datastruct.sample.sample_name = h5read(file,'/sample/sample_name');
catch
    datastruct.sample.sample_name = 'Sample name';
end

%%% /setup group
datastruct.setup.excitation_cw = h5read(file,'/setup/excitation_cw');
datastruct.setup.lifetime = h5read(file,'/setup/lifetime');
datastruct.setup.modulated_excitation = h5read(file,'/setup/modulated_excitation');
datastruct.setup.num_pixels = h5read(file,'/setup/num_pixels');
datastruct.setup.num_polarization_ch = h5read(file,'/setup/num_polarization_ch');
datastruct.setup.num_spectral_ch = h5read(file,'/setup/num_spectral_ch');
datastruct.setup.num_split_ch = h5read(file,'/setup/num_split_ch');
datastruct.setup.num_spots = h5read(file,'/setup/num_spots');
try
    datastruct.setup.detection_wavelengths = h5read(file,'/setup/detection_wavelengths');
    datastruct.setup.excitation_wavelengths = h5read(file,'/setup/excitation_wavelengths');
catch
    datastruct.setup.detection_wavelengths = '';
    datastruct.setup.excitation_wavelengths = '';
end
%%% read photon data
switch measurement_type
    case 'smFRET-usALEX'
        %%% /photon_data group
        %%% /photon_data/measurement_specs
        datastruct.photon_data.measurement_specs.alex_excitation_period1 = h5read(file,'/photon_data/measurement_specs/alex_excitation_period1');
        datastruct.photon_data.measurement_specs.alex_excitation_period2 = h5read(file,'/photon_data/measurement_specs/alex_excitation_period2');
        datastruct.photon_data.measurement_specs.alex_period = h5read(file,'/photon_data/measurement_specs/alex_period');
        datastruct.photon_data.measurement_specs.alex_offset = h5read(file,'/photon_data/measurement_specs/alex_offset'); 
        datastruct.photon_data.measurement_specs.measurement_type = measurement_type;
        %%% /photon_data/measurement_specs/detectors_specs
        datastruct.photon_data.measurement_specs.detectors_specs.spectral_ch1 = h5read(file,'/photon_data/measurement_specs/detectors_specs/spectral_ch1');
        datastruct.photon_data.measurement_specs.detectors_specs.spectral_ch2 = h5read(file,'/photon_data/measurement_specs/detectors_specs/spectral_ch2');
        %%% /photon_data/timestamps_specs
        datastruct.photon_data.timestamps_specs.timestamps_unit = h5read(file,'/photon_data/timestamps_specs/timestamps_unit');
        %%% photon data is read and transformed into PAM MT/MI scheme, discarding
        %%% the channel variable
        timestamps = h5read(file,'/photon_data/timestamps');
        detectors =  h5read(file,'/photon_data/detectors');

        %%% read alex parameters
        det = unique(detectors);
        MT = cell(10,1); MI = cell(10,1);
        for i = 1:numel(det)
            MT{det(i)+1} = double(timestamps(detectors == det(i)))';
        end
        clear timestamps nanotimes detectors
        %%% apply alex period and offset to gain the alex information
        alex_period = double(datastruct.photon_data.measurement_specs.alex_period);
        alex_offset= double(datastruct.photon_data.measurement_specs.alex_offset);
        for i = 1:numel(MT)
            MI{i} = mod(MT{i}-alex_offset,alex_period);
        end
        %%% fix orientation of arrays
        if size(MT{1},1) < size(MT{1},2) %%% horizontal array, make vertical
            MT = cellfun(@transpose,MT,'UniformOutput',false);
            MI = cellfun(@transpose,MI,'UniformOutput',false);
        end
case 'smFRET' % this seems to be data from PyBroMo simulation
    %%% photon data is read and transformed into PAM MT/MI scheme, discarding
    %%% the channel variable
    timestamps = h5read(file,'/photon_data/timestamps');    
    detectors =  h5read(file,'/photon_data/detectors');

    det = unique(detectors);
    MT = cell(10,1); MI = cell(10,1);
    for i = 1:numel(det)
        MT{det(i)+1} = double(timestamps(detectors == det(i)))';
        MI{det(i)+1} = ones(size(MT{det(i)+1})); % dummy variable
    end
    clear timestamps detectors

    %%% fix orientation of arrays
    if size(MT{1},1) < size(MT{1},2) %%% horizontal array, make vertical
        MT = cellfun(@transpose,MT,'UniformOutput',false);
        MI = cellfun(@transpose,MI,'UniformOutput',false);
    end
    
    %%% /photon_data group
    %%% /photon_data/measurement_specs
    %datastruct.photon_data.measurement_specs.alex_excitation_period1 = h5read(file,'/photon_data/measurement_specs/alex_excitation_period1');
    %datastruct.photon_data.measurement_specs.alex_excitation_period2 = h5read(file,'/photon_data/measurement_specs/alex_excitation_period2');
    datastruct.photon_data.measurement_specs.laser_repetition_rate = 10/1E9;%h5read(file,'/photon_data/measurement_specs/laser_repetition_rate');
    datastruct.photon_data.measurement_specs.measurement_type = measurement_type;
    %%% /photon_data/measurement_specs/detectors_specs
    datastruct.photon_data.measurement_specs.detectors_specs.spectral_ch1 = h5read(file,'/photon_data/measurement_specs/detectors_specs/spectral_ch1');
    datastruct.photon_data.measurement_specs.detectors_specs.spectral_ch2 = h5read(file,'/photon_data/measurement_specs/detectors_specs/spectral_ch2');

    %%% /photon_data/nanotimes_specs
    datastruct.photon_data.nanotimes_specs.tcspc_num_bins = 100;%h5read(file,'/photon_data/nanotimes_specs/tcspc_num_bins');
    datastruct.photon_data.nanotimes_specs.tcspc_range = 10E-9;%h5read(file,'/photon_data/nanotimes_specs/tcspc_range');
    datastruct.photon_data.nanotimes_specs.tcspc_unit = 0.1E-9;%h5read(file,'/photon_data/nanotimes_specs/tcspc_unit');
    %%% /photon_data/timestamps_specs
    datastruct.photon_data.timestamps_specs.timestamps_unit = h5read(file,'/photon_data/timestamps_specs/timestamps_unit');
otherwise
    %%% photon data is read and transformed into PAM MT/MI scheme, discarding
    %%% the channel variable
    timestamps = h5read(file,'/photon_data/timestamps');
    nanotimes = h5read(file,'/photon_data/nanotimes');
    detectors =  h5read(file,'/photon_data/detectors');

    det = unique(detectors);
    MT = cell(10,1); MI = cell(10,1);
    for i = 1:numel(det)
        MT{det(i)+1} = double(timestamps(detectors == det(i)))';
        MI{det(i)+1} = nanotimes(detectors == det(i))';
    end
    clear timestamps nanotimes detectors

    %%% fix orientation of arrays
    if size(MT{1},1) < size(MT{1},2) %%% horizontal array, make vertical
        MT = cellfun(@transpose,MT,'UniformOutput',false);
        MI = cellfun(@transpose,MI,'UniformOutput',false);
    end
    
    %%% /photon_data group
    %%% /photon_data/measurement_specs
    datastruct.photon_data.measurement_specs.alex_excitation_period1 = h5read(file,'/photon_data/measurement_specs/alex_excitation_period1');
    datastruct.photon_data.measurement_specs.alex_excitation_period2 = h5read(file,'/photon_data/measurement_specs/alex_excitation_period2');
    datastruct.photon_data.measurement_specs.laser_repetition_rate = h5read(file,'/photon_data/measurement_specs/laser_repetition_rate');
    datastruct.photon_data.measurement_specs.measurement_type = measurement_type;
    %%% /photon_data/measurement_specs/detectors_specs
    datastruct.photon_data.measurement_specs.detectors_specs.spectral_ch1 = h5read(file,'/photon_data/measurement_specs/detectors_specs/spectral_ch1');
    datastruct.photon_data.measurement_specs.detectors_specs.spectral_ch2 = h5read(file,'/photon_data/measurement_specs/detectors_specs/spectral_ch2');

    %%% /photon_data/nanotimes_specs
    datastruct.photon_data.nanotimes_specs.tcspc_num_bins = h5read(file,'/photon_data/nanotimes_specs/tcspc_num_bins');
    datastruct.photon_data.nanotimes_specs.tcspc_range = h5read(file,'/photon_data/nanotimes_specs/tcspc_range');
    datastruct.photon_data.nanotimes_specs.tcspc_unit = h5read(file,'/photon_data/nanotimes_specs/tcspc_unit');
    %%% /photon_data/timestamps_specs
    datastruct.photon_data.timestamps_specs.timestamps_unit = h5read(file,'/photon_data/timestamps_specs/timestamps_unit');
end



