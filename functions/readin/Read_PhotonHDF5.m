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
datastruct.identity.author = h5read(file,'/identity/author');
datastruct.identity.author_affiliation = h5read(file,'/identity/author_affiliation');
datastruct.identity.creation_time = h5read(file,'/identity/creation_time');
datastruct.identity.fname = h5read(file,'/identity/filename');
datastruct.identity.fname_full = h5read(file,'/identity/filename_full');
datastruct.identity.format_name = h5read(file,'/identity/format_name');
datastruct.identity.format_url = h5read(file,'/identity/format_url');
datastruct.identity.format_version = h5read(file,'/identity/format_version');
datastruct.identity.software = h5read(file,'/identity/software');
datastruct.identity.software_version = h5read(file,'/identity/software_version');

%%% /provenance group
datastruct.provenance.creation_time = h5read(file,'/provenance/creation_time');
datastruct.provenance.filename = h5read(file,'/provenance/filename');
datastruct.provenance.filename_full = h5read(file,'/provenance/filename_full');
datastruct.provenance.modification_time = h5read(file,'/provenance/modification_time');
datastruct.provenance.software = h5read(file,'/provenance/software');

%%% /sample group
datastruct.sample.buffer_name = h5read(file,'/sample/buffer_name');
datastruct.sample.dye_names = h5read(file,'/sample/dye_names');
datastruct.sample.sample_name = h5read(file,'/sample/sample_name');

%%% /setup group
datastruct.setup.detection_wavelengths = h5read(file,'/setup/detection_wavelengths');
datastruct.setup.excitation_cw = h5read(file,'/setup/excitation_cw');
datastruct.setup.excitation_wavelengths = h5read(file,'/setup/excitation_wavelengths');
datastruct.setup.lifetime = h5read(file,'/setup/lifetime');
datastruct.setup.modulated_excitation = h5read(file,'/setup/modulated_excitation');
datastruct.setup.num_pixels = h5read(file,'/setup/num_pixels');
datastruct.setup.num_polarization_ch = h5read(file,'/setup/num_polarization_ch');
datastruct.setup.num_spectral_ch = h5read(file,'/setup/num_spectral_ch');
datastruct.setup.num_split_ch = h5read(file,'/setup/num_split_ch');
datastruct.setup.num_spots = h5read(file,'/setup/num_spots');

%%% read photon data
if strcmp(measurement_type,'smFRET-usALEX')
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
    
else
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



