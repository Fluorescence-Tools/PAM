function [ installed ] = check_phconvert()
%%% we need to ensure phconvert is installed
try
    py.phconvert.hdf5.get_versions();
catch
    fprintf('phconvert is not installed. Run "conda install phforge -c tritemio" in command line.\nSee https://github.com/Photon-HDF5/photon-hdf5-matlab-write for more information.');
    installed = 0;
    return
end

%%% if we got here, phconvert is installed
installed = 1;

