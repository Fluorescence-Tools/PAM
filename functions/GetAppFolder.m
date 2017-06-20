function GetAppFolder()
%GETAPPFOLDER Find the folder where PAM.m or PAM.app/PAM.exe is located
global PathToApp
if isdeployed
    PathToApp = GetExeLocation();
    if ismac
        %%% navigate out of the packaged app to folder of .app
        for i = 1:5
            PathToApp = fileparts(PathToApp);
        end
    end
else
    %%% if not deployed, the folder to PAM. is one up from /functions
    PathToApp = [fileparts(mfilename('fullpath')) filesep '..'];
end