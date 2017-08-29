function Out = Zeiss_CZI(arg1,~,arg3)
global UserValues MIAData

%%% This is needed because the callbacks allways have two unused inputs
if nargin == 1
    mode = arg1;
else
    mode = arg3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%
%%%% mode = 1: This sets up the czi custom filetype. Tow editboxes are
%%%% created that are used to define the channels used for the first and
%%%% second MIA channels.
%%%% 
%%%% mode = 2: This loads the actual data. It uses the bfmatlab functions
%%%% of the bioformats toolbox.
%%%% Currently, the string in the first output of the bfopen function is
%%%% used to determine the number of channels and number of frames
%%%%
%%% mode = 3: This simply saves the channel settings to UserValues



switch mode
    case 1 %%% Create settings UIs and extract file type info
        Out{1} = '*.czi';
        Out{2} = 'Load multicolor czi files';
        
        %%% Popupmenu for rotation direction
        Out{3}(1) = uicontrol(...
            'Parent',findobj('Tag','Mia_Orientation_Settings_Panel'),...
            'Style','edit',...
            'Units','normalized',...
            'FontSize',12,...
            'BackgroundColor', UserValues.Look.Control,...
            'ForegroundColor', UserValues.Look.Fore,...
            'String', UserValues.MIA.Custom.Zeiss_CZI{1},...
            'Callback', {@Zeiss_CZI,3},...
            'Position',[0.45 0.48, 0.25 0.05] );
        Out{3}(2) = uicontrol(...
            'Parent',findobj('Tag','Mia_Orientation_Settings_Panel'),...
            'Style','edit',...
            'Units','normalized',...
            'FontSize',12,...
            'BackgroundColor', UserValues.Look.Control,...
            'ForegroundColor', UserValues.Look.Fore,...
            'String', UserValues.MIA.Custom.Zeiss_CZI{2},...
            'Callback', {@Zeiss_CZI,3},...
            'Position',[0.72 0.48, 0.25 0.05] );
         
    case 2 %%% Load Data
        h = guidata(findobj('Tag','Mia'));
        
        %%% Extracts information for data loading
        Extension = h.Mia_Image.Settings.FileType.UserData{1};
        Info = h.Mia_Image.Settings.FileType.UserData{2};
        
        %%% Bins to be used for channel 1
        Channel1 = str2num(h.Mia_Image.Settings.Custom(1).String);
        Channel1 = Channel1(~isnan(Channel1) & Channel1~=0); %% Removes zeros and nans
        %%% Bins to be used for channel 2
        Channel2 = str2num(h.Mia_Image.Settings.Custom(2).String);
        Channel2 = Channel2(~isnan(Channel2) & Channel2~=0); %% Removes zeros and nans
        
        if isempty(Channel1) %%% No valid bins were set for channel 1
            magbox('No valid bins selected for channel 1')
            return;
        end
        
        
        %% File selection
        [FileName,Path] = uigetfile({Extension}, Info, UserValues.File.MIAPath, 'MultiSelect', 'on');
        
        if all(Path==0)
            return
        end
        UserValues.File.MIAPath = Path;
        
        LSUserValues(1);
        %%% Transforms FileName into cell array
        if ~iscell(FileName)
            FileName={FileName};
        end        
        %% Clear MIAData
        MIAData.Data = [];
        MIAData.Type = mode;
        MIAData.FileName = [];
        MIAData.PCH = [];
        %% Clears correlation data and plots
        MIAData.Cor=cell(3,2);
        MIAData.TICS_MS = [];
        MIAData.TICS = [];
        MIAData.TICS_Int = [];
        MIAData.STICS = [];
        MIAData.STICS_SEM = [];
        MIAData.RLICS = [];
        for i=1:3
            h.Plots.Cor(i,1).CData=zeros(1,1,3);
            h.Plots.Cor(i,2).ZData=zeros(1);
            h.Plots.Cor(i,2).CData=zeros(1,1,3);
            h.Mia_ICS.Axes(i,1).Visible='off';
            h.Mia_ICS.Axes(i,2).Visible='off';
            h.Mia_ICS.Axes(i,3).Visible='off';
            h.Mia_ICS.Axes(i,4).Visible='off';
            h.Plots.Cor(i,1).Visible='off';
            h.Plots.Cor(i,2).Visible='off';
            h.Plots.Cor(i,3).Visible='off';
            h.Plots.Cor(i,4).Visible='off';
            h.Plots.Cor(i,5).Visible='off';
            h.Plots.Cor(i,6).Visible='off';
            h.Plots.Cor(i,7).Visible='off';
            h.Plots.TICS(i,1).Visible = 'off';
            h.Plots.TICS(i,2).Visible = 'off';
            h.Plots.STICS(i,1).Visible = 'off';
            h.Plots.STICS(i,2).Visible = 'off';
            h.Plots.TICSImage(i).Visible = 'off';
            h.Plots.STICSImage(i,1).Visible = 'off';
            h.Mia_TICS.Image(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,1).Visible = 'off';
            h.Mia_STICS.Image(i,2).Visible = 'off';
        end
        h.Mia_ICS.Frame_Slider.Min=0;
        h.Mia_ICS.Frame_Slider.Max=0;
        h.Mia_ICS.Frame_Slider.SliderStep=[1 1];
        h.Mia_ICS.Frame_Slider.Value=0;
        h.Mia_STICS.Lag_Slider.Min=0;
        h.Mia_STICS.Lag_Slider.Max=1;
        h.Mia_STICS.Lag_Slider.SliderStep=[1 1];
        h.Mia_STICS.Lag_Slider.Value=0;
        %% Clears N&B data and plots
        MIAData.NB=[];
        h.Plots.NB(1).CData=zeros(1,1);
        h.Plots.NB(2).CData=zeros(1,1);
        h.Plots.NB(3).CData=zeros(1,1);
        h.Plots.NB(4).YData=0;
        h.Plots.NB(4).XData=0;
        h.Plots.NB(5).CData=zeros(1,1);
        
        %% Loads all frames for channels
        for i=1:numel(FileName)
            
            h.Mia_Image.Settings.Image_Frame.String = '1';
            h.Mia_Image.Settings.Image_Line.String = '3';
            h.Mia_ICS.Fit_Table.Data(15,:) = {'3'};
            h.Mia_Image.Settings.Image_Pixel.String = '10';
            h.Mia_ICS.Fit_Table.Data(13,:) = {'10'};
            h.Mia_Image.Settings.Image_Size.String = '50';
            h.Mia_ICS.Fit_Table.Data(11,:) = {'50'};
            
            MIAData.FileName{1}{i}=FileName{i};
            MIAData.FileName{2}{i}=FileName{i};
            
            %javaaddpath(fullfile(pwd,'functions','bfmatlab','bioformats_package.jar'));
            
            %%% Reads MetaData
            FileInfo  = czifinfo(fullfile(Path,FileName{i}));
            Info = FileInfo.metadataXML;
            
            %%%FrameTime
            Start = strfind(Info,'<FrameTime>');
            Stop = strfind(Info,'</FrameTime>');            
            h.Mia_Image.Settings.Image_Frame.String = Info(Start+11:Stop-1);
            %%%LineTime => seems to be off, so I don't read it in
%             Start = strfind(Info,'<LineTime>');
%             Stop = strfind(Info,'</LineTime>');            
%             h.Mia_Image.Settings.Image_Line.String = Info(Start+10:Stop-1);
%             h.Mia_ICS.Fit_Table.Data(15,:) = {Info(Start+10:Stop-1);};
            %%%PixelTime
            Start = strfind(Info,'<PixelTime>');
            Stop = strfind(Info,'</PixelTime>');  
            PixelTime = str2double(Info(Start+11:Stop-1))*10^6;
            h.Mia_Image.Settings.Image_Pixel.String = num2str(PixelTime);
            h.Mia_ICS.Fit_Table.Data(13,:) = {num2str(PixelTime)};
                        
            
            Data = bfopen(fullfile(Path,FileName{i}));
            
            %%% Finds positions of plane/channel/time seperators
            Sep = strfind(Data{1,1}{1,2},';');
            
            
            if numel(Sep) == 3 %%% Normal mode
                %%% Determines number of frames
                F_Sep = strfind(Data{1,1}{1,2}(Sep(3):end),'/');
                N_F = str2double(Data{1,1}{1,2}(Sep(3)+F_Sep:end));
                
                %%% Determines number of channels
                C_Sep = strfind(Data{1,1}{1,2}(Sep(2):(Sep(3)-1)),'/');
                N_C = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:(Sep(3)-1)));
            elseif numel(Sep) == 2 %%% Single Frame or SIngle Channel
                
                if isempty(strfind(Data{1,1}{1,2}(Sep(2):end),'C')) %%% Single Color
                    %%% Determines number of channels
                    F_Sep = strfind(Data{1,1}{1,2}(Sep(2):end),'/');
                    N_F = str2double(Data{1,1}{1,2}(Sep(2)+F_Sep:end));
                    N_C  = 1;
                else %%% Single Frame
                    N_F = 1;
                    %%% Determines number of channels
                    C_Sep = strfind(Data{1,1}{1,2}(Sep(2):end),'/');
                    N_C = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:end));
                end
            else
                msgbox('Inavalid data type')
                return;
            end
            
            %%% Adds data to global variable
            MIAData.Data{1,1} = zeros( size(Data{1,1}{1,1},1),size(Data{1,1}{1,1},2),N_F,'uint16');
            if ~isempty(Channel2) && min(Channel2)<=N_C
                MIAData.Data{2,1} = zeros( size(Data{1,1}{1,1},1),size(Data{1,1}{1,1},2),N_F,'uint16');
            end
            for j=1:size(Data{1,1},1)
                %%% Current channel
                C = mod(j-1,N_C)+1;
                %%% Current frame
                F = floor((j-1)/N_C)+1;
                
                %%% Adds data to channel 1
                if ~isempty(intersect(Channel1,C))
                    MIAData.Data{1,1}(:,:,F) = MIAData.Data{1,1}(:,:,F)+uint16(Data{1,1}{j,1});
                end
                %%% Adds data to channel 2
                if ~isempty(intersect(Channel2,C))
                    MIAData.Data{2,1}(:,:,F) = MIAData.Data{2,1}(:,:,F)+uint16(Data{1,1}{j,1});
                end
            end
        end
        
        %% Updates frame settings for channels
        %%% Unlinks framses
        h.Mia_Image.Settings.Channel_Link.Value = 0;
        h.Mia_Image.Settings.Channel_Link.Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'off';
        h.Mia_Image.Axes(2,1).Visible = 'off';
        h.Mia_Image.Axes(2,2).Visible = 'off';
        h.Plots.Image(2,1).Visible = 'off';
        h.Plots.Image(2,2).Visible = 'off';
        h.Plots.ROI(2).Visible = 'off';
        h.Mia_Image.Settings.Channel_Frame_Slider(1).SliderStep=[1./size(MIAData.Data{1,1},3),10/size(MIAData.Data{1,1},3)];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Max=size(MIAData.Data{1,1},3);
        h.Mia_Image.Settings.ROI_Frames.String=['1:' num2str(size(MIAData.Data{1,1},3))];
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Value=0;
        h.Mia_Image.Settings.Channel_Frame_Slider(1).Min=0;
        MIAData.Use=ones(2,size(MIAData.Data{1,1},3));
        
        if size(MIAData.Data,1) == 2
            %%% Updates frame settings for channel 2
            h.Mia_Image.Settings.Channel_Frame_Slider(2).SliderStep=[1./size(MIAData.Data{2,1},3),10/size(MIAData.Data{2,1},3)];
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Max=size(MIAData.Data{2,1},3);
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Value=0;
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Min=0;
            h.Plots.ROI(2).Position=[10 10 200 200];
            h.Plots.ROI(4).Position=[10 10 200 200];
            %%% Links frames
            h.Mia_Image.Settings.Channel_Link.Value = 1;
            h.Mia_Image.Settings.Channel_Link.Visible = 'on';
            h.Mia_Image.Settings.Channel_Frame(2).Visible = 'on';
            h.Mia_Image.Settings.Channel_FrameUse(2).Visible = 'on';
            h.Mia_Image.Settings.Channel_Frame_Slider(2).Visible = 'on';
            h.Mia_Image.Axes(2,1).Visible = 'on';
            h.Mia_Image.Axes(2,2).Visible = 'on';
            h.Plots.Image(2,1).Visible = 'on';
            h.Plots.Image(2,2).Visible = 'on';
            h.Plots.ROI(2).Visible = 'on';
        end
        
    case 3 %%% Save to UserValues
        h = guidata(findobj('Tag','Mia'));
        UserValues.MIA.Custom.Zeiss_CZI{1} = h.Mia_Image.Settings.Custom(1).String;
        UserValues.MIA.Custom.Zeiss_CZI{2} = h.Mia_Image.Settings.Custom(2).String;
        LSUserValues(1);
end
    

