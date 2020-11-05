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
%%%% second MIA channels. A checkbox is created to toggle plotting of the
%%%% spectrum histogram 
%%%% 
%%%% mode = 2: This loads the actual data. It uses the bfmatlab functions
%%%% of the bioformats toolbox.
%%%% Currently, the string in the first output of the bfopen function is
%%%% used to determine the number of channels and number of frames
%%%%
%%%% mode = 3: This simply saves the channel settings to UserValues



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
        Out{3}(3) = uicontrol(...
            'Parent',findobj('Tag','Mia_Orientation_Settings_Panel'),...
            'Style','checkbox',...
            'Units','normalized',...
            'FontSize',12,...
            'Value', UserValues.MIA.Custom.Zeiss_CZI{3},...
            'BackgroundColor', UserValues.Look.Back,...
            'ForegroundColor', UserValues.Look.Fore,...
            'String', 'Show spectrum histogram',...
            'Callback', {@Zeiss_CZI,3},...
            'Position',[0.02 0.40, 0.9 0.05] );
        Out{3}(4) = uicontrol(...
            'Parent',findobj('Tag','Mia_Orientation_Settings_Panel'),...
            'Style','edit',...
            'Units','normalized',...
            'FontSize',12,...
            'BackgroundColor', UserValues.Look.Control,...
            'ForegroundColor', UserValues.Look.Fore,...
            'String', '1',...
            'Callback', {@Zeiss_CZI,3},...
            'Position',[0.45 0.3, 0.25 0.05] );
        Out{3}(5) = uicontrol(...
            'Parent',findobj('Tag','Mia_Orientation_Settings_Panel'),...
            'Style','text',...
            'Units','normalized',...
            'FontSize',12,...
            'HorizontalAlignment','left',...
            'BackgroundColor', UserValues.Look.Back,...
            'ForegroundColor', UserValues.Look.Fore,...
            'Position',[0.02 0.3, 0.3 0.05],...
            'String','Z-plane(s):',...
            'Tooltipstring',['Checks the .czi file for z-stacks' 10 ...
            'Write a number or a range e.g. 1:5, to load']);
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
        
        Zplane = str2num(h.Mia_Image.Settings.Custom(4).String);
        
        if isempty(Channel1) %%% No valid bins were set for channel 1
            msgbox('No valid bins selected for channel 1')
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
        MIAData.TICS = [];
        MIAData.TICS.Int = [];
        MIAData.TICS.MS = [];
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
        Spectrum = cell(numel(FileName),1);
        Spectral_Range = cell(numel(FileName),1);
        for i=1:numel(FileName)
            
            h.Mia_Image.Settings.Image_Frame.String = '1';
            h.Mia_Image.Settings.Image_Line.String = '3';
            h.Mia_ICS.Fit_Table.Data(15,:) = {'3'};
            h.Mia_Image.Settings.Image_Pixel.String = '10';
            h.Mia_ICS.Fit_Table.Data(13,:) = {'10'};
            h.Mia_Image.Settings.Pixel_Size.String = '50';
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
                        
            %%%PixelSize
            Start = strfind(Info,'<Scaling>');
            Stop = strfind(Info,'</Scaling>');
            Scaling = Info(Start+10:Stop-1);
            Start = strfind(Scaling,'<Value>');
            Stop = strfind(Scaling,'</Value>');
            
            h.Mia_Image.Settings.Pixel_Size.String = num2str(round(str2double(Scaling(Start(1)+7:Stop(1)-1))*10^9));
            h.Mia_ICS.Fit_Table.Data(11,:) = {num2str(str2double(Scaling(Start(1)+7:Stop(1)-1))*10^9);};
            
            Data = bfopen(fullfile(Path,FileName{i}),h.Mia_Progress_Axes,h.Mia_Progress_Text,i,numel(FileName));
%             for j = 1:size(Data{1,1},1) %flip x and y axes
%                 Data{1,1}{j,1} = Data{1,1}{j,1}';
%             end
            %%% Finds positions of plane/channel/time seperators
            Sep = strfind(Data{1,1}{1,2},';');
            
            if numel(Sep) == 4 %%% Z stack with channels and > 1 frame
                %%% Determines number of frames
                F_Sep = strfind(Data{1,1}{1,2}(Sep(4):end),'/');
                N_F = str2double(Data{1,1}{1,2}(Sep(4)+F_Sep:end));
                
                %%% Determines number of channels
                C_Sep = strfind(Data{1,1}{1,2}(Sep(3):(Sep(4)-1)),'/');
                N_C = str2double(Data{1,1}{1,2}(Sep(3)+C_Sep:(Sep(4)-1)));
                
                %%% Determines number of Z planes
                Z_Sep = strfind(Data{1,1}{1,2}(Sep(2):(Sep(3)-1)),'/');
                N_Z = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:(Sep(3)-1)));
            
            elseif numel(Sep) == 3 %%% Normal mode
                %%% Determines number of frames
                F_Sep = strfind(Data{1,1}{1,2}(Sep(3):end),'/');
                N_F = str2double(Data{1,1}{1,2}(Sep(3)+F_Sep:end));
                
                %%% Determines number of channels
                C_Sep = strfind(Data{1,1}{1,2}(Sep(2):(Sep(3)-1)),'/');
                N_C = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:(Sep(3)-1)));
                
                N_Z = 1;
            elseif numel(Sep) == 2 %%% Single Frame or Single Channel
                
                if isempty(strfind(Data{1,1}{1,2}(Sep(2):end),'C')) %%% Single Color
                    %%% Determines number of channels
                    F_Sep = strfind(Data{1,1}{1,2}(Sep(2):end),'/');
                    N_F = str2double(Data{1,1}{1,2}(Sep(2)+F_Sep:end));
                    N_C  = 1;
                    N_Z = 1;
                else %%% Single Frame
                    N_F = 1;
                    %%% Determines number of channels
                    C_Sep = strfind(Data{1,1}{1,2}(Sep(2):end),'/');
                    N_C = str2double(Data{1,1}{1,2}(Sep(2)+C_Sep:end));
                    N_Z = 1;
                end
            elseif isempty(Sep)  %%% This is a transmisson-only image
                    N_F = 1;
                    %%% Determines number of channels
                    C_Sep = 1;
                    N_C = 1;
                    N_Z = 1;
            else
                msgbox('Invalid data type')
                return;
            end
            
            %%%Spectral range
            Start = strfind(Info,'<DetectorWavelengthRange>');
            Stop = strfind(Info,'</DetectorWavelengthRange>');
            if ~isempty(Start) && ~isempty(Stop)
                RangeInfo = Info(Start+25:Stop-1);
                Range(1) = str2double(RangeInfo(strfind(RangeInfo,'<WavelengthStart>')+17:strfind(RangeInfo,'</WavelengthStart>')-1))*10^9;
                Range(2) = str2double(RangeInfo(strfind(RangeInfo,'<WavelengthEnd>')+15:strfind(RangeInfo,'</WavelengthEnd>')-1))*10^9;
                Bin_Width = (Range(2)-Range(1))/N_C;
                Spectral_Range{i} = linspace(Range(1)+0.5*Bin_Width,Range(2)-0.5*Bin_Width,N_C);
            else
                Spectral_Range{i}=1:N_C;
            end
            
            if i == 1 %first file or only 1 file
                %%% Adds data to global variable
                totalF = 0;
                MIAData.Data{1,1} = zeros( size(Data{1,1}{1,1},1),size(Data{1,1}{1,1},2),N_F*numel(Zplane),'uint16');
                if ~isempty(Channel2) && min(Channel2)<=N_C
                    MIAData.Data{2,1} = zeros( size(Data{1,1}{1,1},1),size(Data{1,1}{1,1},2),N_F*numel(Zplane),'uint16');
                end
            else
                totalF = size(MIAData.Data{1,1}, 3);
                MIAData.Data{1,1}(:,:,end+1:end+N_F*numel(Zplanes)) = 0;
                if ~isempty(Channel2) && min(Channel2)<=N_C
                    MIAData.Data{2,1}(:,:,end+1:end+N_F*numel(Zplanes)) = 0;
                end               
            end
            Spectrum{i} = zeros(N_C,1);
            zz=1;
            if numel(Zplane)>1
                %make sure the correlation blocksize is compatible with the
                %moving average correction frame range
                h.Mia_Image.Calculations.Cor_ICS_Window.String = num2str(N_F-str2double(h.Mia_Image.Settings.Correction_Subtract_Frames.String)+1);
                h.Mia_Image.Calculations.Cor_ICS_Offset.String = num2str(N_F);
            else
                h.Mia_Image.Calculations.Cor_ICS_Window.String = num2str(N_F);
                h.Mia_Image.Calculations.Cor_ICS_Offset.String = num2str(N_F);
            end
            for z=Zplane %loop through all z-planes user wants to load
                Z = 0;
                for j=1:size(Data{1,1},1)
                    %%% the order of the data (frame-channel-z) is
                    %%% 111 121 ... 1c1 112 ... 1c2 ... ... 1nz 211 ... ... fnz
                    %%% the code currently only loads 1 particular z plane
                    %%% because Mia has no option for displaying different Z
                    %%% planes. Also the data format on Mia is not compatible
                    %%% with it yet.
                    
                    %%% Current channel
                    C = mod(j-1,N_C)+1;
                    %%% Current frame
                    F = floor((j-1)/(N_C*N_Z))+1;
                    % for every next file, frames have to be added to the end :
                    F = F + totalF;
                    %%% current Z position
                    if C == 1
                        Z = Z+1;
                        if Z > N_Z
                            Z = 1;
                        end
                    end
                    
                    %%% Adds data to channel 1
                    if ~isempty(intersect(Channel1,C))
                        if ~isempty(intersect(z,Z))
                            MIAData.Data{1,1}(:,:,F+(zz-1)*N_F) = MIAData.Data{1,1}(:,:,F+(zz-1)*N_F)+uint16(Data{1,1}{j,1});
                        end
                    end
                    %%% Adds data to channel 2
                    if ~isempty(intersect(Channel2,C))
                        if ~isempty(intersect(z,Z))
                            MIAData.Data{2,1}(:,:,F+(zz-1)*N_F) = MIAData.Data{2,1}(:,:,F+(zz-1)*N_F)+uint16(Data{1,1}{j,1});
                        end
                    end
                    
                    %%% Calculates averaged spectrum for displaying
                    Spectrum{i}(C)=Spectrum{i}(C)+sum(double(Data{1,1}{j,1}(:)));
                    
                end
                zz = zz+1;
            end
            
            Spectrum{i}=Spectrum{i}/sum(Spectrum{i});
        end
        
        if h.Mia_Image.Settings.Custom(3).Value
            Fig = figure;
            set(Fig, 'color', 'w')
            Axis = axes(Fig);
            Axis.NextPlot = 'add';
            Axis.Color = 'w';
            Axis.XLabel.String = 'Wavelength [nm]';
            Axis.YLabel.String = 'Normalized intensity';
            
            XLim = [10^9 0];
            Bins = 1;
            for i=1:numel(Spectrum)
                Spec{i} = plot(Spectral_Range{i},Spectrum{i});
                if min(Spectral_Range{i})<XLim(1)
                    XLim(1)= min(Spectral_Range{i});
                end
                if max(Spectral_Range{i})>XLim(2)
                    XLim(2)= max(Spectral_Range{i});
                end
                if numel(Spectral_Range{1})>Bins
                    Bins = numel(Spectral_Range{1});
                end
            end
            Axis.XLim = XLim;
            Axis2 = axes('Parent',Fig,...
                        'Position',Axis.Position,...
                        'XAxisLocation','top',...
                        'YLim', Axis.YLim,...
                        'XLim',[1 Bins],...
                        'Color','none');
            Axis2.XLabel.String = 'Spectral Bins';
            Axis2.YLabel.String = 'Normalized intensity';
            grid minor       
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
        UserValues.MIA.Custom.Zeiss_CZI{3} = h.Mia_Image.Settings.Custom(3).Value;
        LSUserValues(1);
end
    

