%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Load Photon Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function success = Load_Photons(mode)
global PhotonStream BurstData UserValues BurstTCSPCData BurstMeta
h = guidata(findobj('Tag','BurstBrowser')); 
if nargin == 0
    mode = 'bps';
end
file = BurstMeta.SelectedFile;
filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
prev_string = h.Progress_Text.String;
h.Progress_Text.String = 'Loading Photon Data';
success = true;
switch mode
    case 'aps'
        if isempty(PhotonStream)
            PhotonStream = cell(numel(BurstData),1);
        end
        %%% Load associated .aps file, containing Macrotime, Microtime and Channel
        if isempty(PhotonStream{file})
            if exist([filename(1:end-3) 'aps'],'file') == 2
                %%% load if it exists
                S = load([filename(1:end-3) 'aps'],'-mat');
            else
                disp('No *.aps file found.'); 
                h.Progress_Text.String = prev_string; 
                success = false;
                return;
                %%% else ask for the file
                %[FileName,PathName] = uigetfile({'*.aps'}, 'Choose the associated *.aps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
                %if FileName == 0
                %    return;
                %end
                %S = load('-mat',fullfile(PathName,FileName));
            end
            % transfer to global array
            PhotonStream{file}.start = S.PhotonStream.start;
            PhotonStream{file}.stop = S.PhotonStream.stop;
            PhotonStream{file}.Macrotime = double(S.PhotonStream.Macrotime);
            PhotonStream{file}.Microtime = S.PhotonStream.Microtime;
            PhotonStream{file}.Channel = S.PhotonStream.Channel;
            clear S;
        end
        %%% Enable CorrelateWindow Button
        %h.CorrelateWindow_Button.Enable = 'on';
        %h.CorrelateWindow_Edit.Enable = 'on';
    case 'bps'
        if exist([filename(1:end-3) 'bps'],'file') == 2
            %%% load if it exists
            BurstTCSPCData{file} = load([filename(1:end-3) 'bps'],'-mat');
        else
            %%% else ask for the file
            [FileName,PathName] = uigetfile({'*.bps'}, 'Choose the associated *.bps file', UserValues.File.BurstBrowserPath, 'MultiSelect', 'off');
            if FileName == 0
                return;
            end
            BurstTCSPCData{file} = load('-mat',fullfile(PathName,FileName));
            %%% Store the correct Path in BurstData
            BurstData{file}.FileName = [FileName(1:end-3) 'bur'];
        end
        %BurstTCSPCData{file}.Macrotime = Macrotime;%cellfun(@double,Macrotime,'UniformOutput',false);
        %BurstTCSPCData{file}.Microtime = Microtime;%cellfun(@double,Microtime,'UniformOutput',false);
        %BurstTCSPCData{file}.Channel = Channel;%cellfun(@double,Channel,'UniformOutput',false);
        %clear Macrotime Microtime Channel
end
h.Progress_Text.String = prev_string;
