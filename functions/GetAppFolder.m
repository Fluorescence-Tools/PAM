function GetAppFolder()
%%% Find the folder where PAM.m or PAM.app/PAM.exe is located
global PathToApp
if isdeployed
    PathToApp = ctfroot;%GetExeLocation();
    if ~ismac % on UNIX and Windows, the relevant data is placed in a subfolder "PAM" in ctfroot
        PathToApp = [PathToApp filesep 'PAM'];
    end
    disp(['You can find the profiles and fit models at: ' PathToApp '.']);
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