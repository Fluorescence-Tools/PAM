function [ installed ] = check_python_hdf5()
%%% Python checkups
%%% we need to change the python version to anaconda here (since there phconvert is installed)
[~, pypath,isloaded] = pyversion;
if isempty(strfind(pypath,'anaconda')) %%% requires anaconda installation for phconvert
    %%% find users home directory
    if ispc
        home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
    else
        home = getenv('HOME');
    end
    %%% construct anaconda python path
    if ispc
        conda_path = [home '\anaconda\bin\python.exe'];
    else
        conda_path = [home '/anaconda/bin/python'];
    end
    if isloaded %%% python is loaded and can not be changed
        installed = 0;
        fprintf('Python is loaded.\nRestart Matlab and run script again!\n')
    else
        try
            pyversion(conda_path)
            installed = 1;
            fprintf('Default python version in Matlab has been changed to anaconda\n')           
        catch
            installed = 0;
            fprintf('Anaconda is not installed. Install suitable anaconda distribution for your system from https://www.continuum.io/downloads.\n');
        end
    end
    return
end

phconvert_installed = check_phconvert();
if ~phconvert_installed
    installed = 0;
else
    %%% if we got here, everything is fine
    fprintf('Everything is installed!\n')
    installed = 1;
end

