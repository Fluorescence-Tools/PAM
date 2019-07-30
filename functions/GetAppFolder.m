function GetAppFolder()
%%% Find the folder where PAM.m or PAM.app/PAM.exe is located
global PathToApp
if isdeployed
    disp(['You can find the profiles and fit models at: ' ctfroot '.']);
    PathToApp = ctfroot;%GetExeLocation();
%     if ismac
%         %%% navigate out of the packaged app to folder of .app
%         for i = 1:4
%             PathToApp = fileparts(PathToApp);
%         end
%     elseif ispc
%         %%% remove filename and extension
%         PathToApp = fileparts(PathToApp);
%     end
else
    %%% if not deployed, the folder to PAM. is one up from /functions
    PathToApp = [fileparts(mfilename('fullpath')) filesep '..'];
end