function ParticleDetection(~,~)
global UserValues
h.Particle=findobj('Tag','Particle');

addpath(genpath(['.' filesep 'functions']));

if ~isempty(h.Particle) % Creates new figure, if none exists
    figure(h.Particle);
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Disables uitabgroup warning
warning('off','MATLAB:uitabgroup:OldVersion');
%%% Loads user profile
LSUserValues(0);
%%% To save typing
Look=UserValues.Look;
%%% Generates the Pam figure
h.Particle = figure(...
    'Units','normalized',...
    'Tag','Particle',...
    'Name','Phasor Particle Detection',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName',Look.Font,...
    'defaultAxesFontName',Look.Font,...
    'defaultTextFontName',Look.Font,...
    'defaultAxesYColor',Look.Fore,...
    'Toolbar','figure',...
    'UserData',[],...
    'BusyAction','cancel',...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@Close_Particle,...
    'Visible','on');
%%% Sets background of axes and other things
whitebg(Look.Fore);
%%% Changes Pam background; must be called after whitebg
h.Particle.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.Particle,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 9 13:17]));

h.Load_Particle = uimenu(...
    'Parent',h.Particle,...
    'Label','Load Phasor Data',...
    'Callback',@Load_Particle_Data);

h.Load_MaskData = uimenu(...
    'Parent',h.Particle,...
    'Label','Load External Mask Data',...
    'Callback',@Load_Mask_Data);

h.Text = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image Plot and Controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Plot panel
h.Plot_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.25 0.29 0.74]);

%%% Main Image plot
h.Particle_Plot = axes(...
    'Parent',h.Plot_Panel,...
    'Units','normalized',...
    'Position',[0 0.34 1 0.635]);
h.Particle_Image = image(zeros(1,1,3));
h.Particle_Plot.DataAspectRatio = [1 1 1];
h.Particle_Plot.XTick = [];
h.Particle_Plot.YTick = [];

%%% Pixel Counts plot
h.Particle_Counts = axes(...
    'Parent',h.Plot_Panel,...
    'Nextplot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'Units','normalized',...
    'Position',[0.13 0.07 0.82 0.25]);
h.Particle_CountsHist{1} = plot(h.Particle_Counts,zeros(100,1),'Color',[0.8 0 0]);
h.Particle_CountsHist{2} = plot(h.Particle_Counts,zeros(100,1),'Color',[0 0.6 0]);

h.Particle_Counts.XLabel.String = 'Counts';
h.Particle_Counts.XLabel.Color = Look.Fore;
h.Particle_Counts.YLabel.String = 'Frequency';
h.Particle_Counts.YLabel.Color = Look.Fore;

%%% Plot control panel
h.Plot_Control_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.01 0.29 0.24]);
%%% Frame
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.87, 0.15 0.12],...
    'String','Frame:');
%%% Editbox for frame
h.Particle_Frame = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame,1},...
    'Position',[0.18 0.86, 0.1 0.12],...
    'String','1');
%%% Checkbox for use frame
h.Particle_FrameSlider = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Frame,2},...
    'Position',[0.29 0.86, 0.2 0.12]);

%%% Colormap selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.85, 0.2 0.12],...
    'String','Colormap:');
h.Particle_Colormap = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0},...
    'Position',[0.71 0.86, 0.25 0.12],...
    'String',{'Jet','Gray','Hot','HSV'});

%%% Autoscale
h.Particle_ManualScale = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0:2},...
    'Value',0,...
    'Position',[0.02 0.72, 0.35 0.12],...
    'String','Manual Scale:');

%%% Min Scale
h.Particle_ScaleMin = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0:2},...
    'Position',[0.38 0.72, 0.1 0.12],...
    'String','0');
%%% Max Scale
h.Particle_ScaleMax = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,0:2},...
    'Position',[0.49 0.72, 0.1 0.12],...
    'String','100');

%%% Frames to use
h.Text{end+1} = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.58, 0.3 0.12],...
    'String','Use Frames:');
h.Particle_Frames_Start = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.38 0.58, 0.1 0.12]);
h.Particle_Frames_Stop = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','999',...
    'Position',[0.49 0.58, 0.1 0.12]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Particle detection selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Particle Detection settings panel
h.Detection_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.3 0.01 0.2 0.98]);

%%% Method of particle detection
h.Particle_Method = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Method_Update,0},...
    'Position',[0.01 0.93, 0.98 0.06],...
    'String',{'Simple threshold method',...
              'Simple wavelet method',...
              'External mask'});

h.Particle_Method_Description = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.72, 0.98 0.21],...
    'String','This method uses a full stack threshold to calculate a binary map. Based on this map it used the matlab "regionprops" function to detect particles. Always works with full stack.');

%%% Method settings Table
TableData = {   'Pixel Threshold [Counts]',150;...
    'Use Non-Particle',0};
ColumnNames = {'Parameter Name', 'Value'};
ColumnEditable = [false,true];
ColumnFormat = {'char','numeric'};
RowNames = [];

h.Particle_Method_Settings = uitable(...
    'Parent',h.Detection_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'Position',[0.01 0.16 0.98 0.55],...
    'Data',TableData,...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'ColumnEditable',ColumnEditable,...
    'ColumnFormat',ColumnFormat);


h.Particle_Use_External_Mask = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use external mask',...
    'Callback',{@Misc},...
    'Position',[0.01 0.13, 0.8 0.02]);

h.Particle_Use_NonParticle = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Use non-detected pixels',...
    'Position',[0.01 0.1, 0.8 0.02]);

%%% Starts Calculation
h.Particle_DoCalculation = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Method_Update,1},...
    'Position',[0.01 0.05, 0.4 0.04],...
    'String','Calculate');
h.Particle_Save = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Particle_Save},...
    'Position',[0.45 0.05, 0.4 0.04],...
    'String','Save');
h.Particle_Save_Method = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.01, 0.5 0.03],...
    'Callback',{@Misc},...
    'String',{'Save Average';...
              'Save FLIM Trace';...
              'Save Text'});
%%% Frames to use
h.Particle_Frames_Sum_Text = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'Visible','off',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.53 0.01, 0.3 0.02],...
    'String','Sum Frames:');
h.Particle_Frames_Sum = uicontrol(...
    'Parent',h.Detection_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'Visible','off',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','1',...
    'Position',[0.83 0.01, 0.15 0.02]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Particle detection display %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Particle display panel
h.Display_Panel = uibuttongroup(...
    'Parent',h.Particle,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.51 0.25 0.29 0.74]);

%%% Partilce display plot
h.Particle_Display = axes(...
    'Parent',h.Display_Panel,...
    'Units','normalized',...
    'Position',[0 0.34 1 0.635]);
h.Particle_Display_Image = image(zeros(1,1,3));
h.Particle_Display.DataAspectRatio = [1 1 1];
h.Particle_Display.XTick = [];
h.Particle_Display.YTick = [];

%%% Display type selection
h.Particle_Disply_Type = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Plot_Particle,2},...
    'Position',[0.02 0.26, 0.4 0.05],...
    'String',{  'Mask only',...
    'Mask overlay',...
    'Mask gray/red',...
    'Mask magenta/green',...
    'Particles only',...
    'Particles overlay',...
    'Particles gray/jet'});

h.Particle_Display_ExternalMask = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'Value',0,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'String','Show external mask',...
    'Callback',{@Plot_Particle,2},....
    'Position',[0.5 0.27, 0.49 0.04]);

h.Particle_Number = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.02 0.21, 0.96 0.04],...
    'String','Particle detected: 0 ');

h.Particle_SaveMask = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'String','Save Mask',...
    'Callback',@Save_Mask,....
    'Position',[0.5 0.21, 0.44 0.04]);
%% Stores Info in guidata
guidata(h.Particle,h);
%%% Updated method table
Method_Update([],[],0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Closes Particle window and clears variables %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_Particle(Obj,~)
clear global -regexp ParticleData
Pam=findobj('Tag','Pam');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
PhasorTIFF = findobj('Tag','PhasorTIFF');
Phasor = findobj('Tag','Phasor');

clear global -regexp ParticleData
if isempty(Pam) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(TauFit) && isempty(BurstBrowser) && isempty(PhasorTIFF)  && isempty(Phasor)
    clear global -regexp UserValues 
end
delete(Obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads new phasor file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Particle_Data(~,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData UserValues
LSUserValues(0);

%%% Choose files to load
[FileName,PathName] = uigetfile({'*.phf'}, 'Choose a referenced data file', UserValues.File.PhasorPath, 'MultiSelect', 'off');
%%% Only esecutes, if at least one file was selected
if all(FileName==0)
    return
end
%%% Saves Path
UserValues.File.PhasorPath=PathName;
LSUserValues(1);

%%% Loads Data
ParticleData.Data=load(fullfile(PathName, FileName),'-mat');
ParticleData.FileName = FileName;
ParticleData.PathName = PathName;

%%% Removed detected particle data
if isfield(ParticleData,'Regions')
    ParticleData = rmfield(ParticleData,'Regions');
end
if isfield(ParticleData,'Mask')
    ParticleData = rmfield(ParticleData,'Mask');
end
if isfield(ParticleData,'Particle')
    ParticleData = rmfield(ParticleData,'Particle');
end
h.Particle_Number.String = 'Particles detected: 0';


%%% Creates full stack counts histogram
Max=max(ParticleData.Data.Intensity(:))+1;
ParticleData.Hist = histcounts(ParticleData.Data.Intensity(:),0:Max)/numel(ParticleData.Data.Intensity);
Max=max(max(sum(ParticleData.Data.Intensity,3)))+1;
ParticleData.Hist_Sum = histcounts(reshape(sum(ParticleData.Data.Intensity,3),1,[]),0:Max)/numel(ParticleData.Data.Intensity(:,:,1));
ParticleData.Int_Sum = sum(ParticleData.Data.Intensity,3);


%%% Adjusts slider and frame range
h.Particle_FrameSlider.Min=0;
h.Particle_FrameSlider.Max=size(ParticleData.Data.Intensity,3);
h.Particle_FrameSlider.SliderStep=[1./size(ParticleData.Data.Intensity,3),10/size(ParticleData.Data.Intensity,3)];
h.Particle_FrameSlider.Value=0;
h.Particle_Frame.String = '0';
guidata(h.Particle,h);

%%% Plots loaded image
Plot_Particle([],[],0:2,h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loads external mask data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Mask_Data(~,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData UserValues
LSUserValues(0);

%%% Choose files to load
[FileName,PathName] = uigetfile({'*.tif'}, 'Choose a mask image file', UserValues.File.PhasorPath, 'MultiSelect', 'off');
%%% Only esecutes, if at least one file was selected
if all(FileName==0)
    return
end

%%% Loads Data
    Info=imfinfo(fullfile(PathName,FileName));
    Frames = numel(Info);
    ParticleData.MaskData = zeros(Info(1).Height,Info(1).Width,Frames);
    
    TIFF_Handle = Tiff(fullfile(PathName,FileName),'r'); % Open tif reference
    
    for i=1:Frames
        TIFF_Handle.setDirectory(i);
        ParticleData.MaskData(:,:,i) = TIFF_Handle.read();
    end
    TIFF_Handle.close(); % Close tif reference
    ParticleData.MaskData_Sum = sum(ParticleData.MaskData,3);

%%% Plots loaded image
Plot_Particle([],[],0:2,h)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates plots in Particle figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Plot_Particle(~,~,mode,h)

if ~exist('h','var')
    h = guidata(findobj('Tag','Particle'));
end
global ParticleData

if ~isfield(ParticleData, 'Data')
    return;
end

Frame = round(h.Particle_FrameSlider.Value);

%%% Plots simple image
if any(mode==0)
    %%% Selects colormap for plotting
    switch h.Particle_Colormap.Value
        case 1
            Color = jet(128);
        case 2
            Color = gray(128);
        case 3
            Color = hot(128);
        case 4
            Color = hsv(128);
    end
    
    %%% Selects right frame for plotting or summed frame
    if Frame == 0 %% Summed up image
        Int = ParticleData.Int_Sum;
    else %%% Framewise image
        Int = ParticleData.Data.Intensity(:,:,Frame);
    end
    %%% Adjusts to range
    if h.Particle_ManualScale.Value
        Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
        Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
    else
        Min = min(Int(:));
        Max = max(Int(:));
    end
    %%% Transforms intensity image to 128 colors
    Int=round(127*(Int-Min)/(Max-Min))+1;
    %%% Applies colormap
    Image=reshape(Color(Int(:),:),size(Int,1),size(Int,2),3);
    
    h.Particle_Image.CData = Image;
    h.Particle_Plot.XLim = [0.5 size(Image,2)+0.5];
    h.Particle_Plot.YLim = [0.5 size(Image,1)+0.5];
    
end

%%% Plots count histogram
if any(mode==1)
    if Frame == 0 %%% Summed up intensity
        %%% Extracts right data
        Hist = ParticleData.Hist_Sum;
        %%% Adjusts to range
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = max([0,ceil(str2double(h.Particle_ScaleMin.String))]);
            Max = min([numel(ParticleData.Hist_Sum)-1 floor(str2double(h.Particle_ScaleMax.String))]);
            %%% Adjusts full stack histogram
            if Max+1<numel(Hist)
               Hist(Max+1)=sum(Hist(Max+1:end));
               Hist=Hist(1:Max+1);
            end
            if Min>0
                Hist(Min+1) = sum(Hist(1:Min+1));
                Hist(1:Min) = [];
            end
        else
            Min = 0;
            Max = numel(ParticleData.Hist_Sum)-1;
        end
        %%% Updates plot
        h.Particle_CountsHist{1}.YData = Hist;
        h.Particle_CountsHist{1}.XData = Min:Max;
        %%% Turns single frame plot off
        h.Particle_CountsHist{2}.Visible ='off';
    else %%% Framewise intensity
        %%% Extracts right data
        Int=ParticleData.Hist;        

        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = max([0,ceil(str2double(h.Particle_ScaleMin.String))]);
            Max = min([numel(ParticleData.Hist)-1 floor(str2double(h.Particle_ScaleMax.String))]);
            %%% Adjusts full stack histogram
            if Max+1<numel(Int)
               Int(Max+1)=sum(Int(Max+1:end));
               Int=Int(1:Max+1);
            end
            if Min>0
                Int(Min+1) = sum(Int(1:Min+1));
                Int(1:Min) = [];
            end
            Int_Frame = histcounts(reshape(ParticleData.Data.Intensity(:,:,Frame),1,[]),Min:(Max+1))./numel(ParticleData.Data.Intensity(:,:,Frame));
            
        else
            Min = 0;
            Max = numel(ParticleData.Hist)-1;
            Int_Frame = histcounts(reshape(ParticleData.Data.Intensity(:,:,Frame),1,[]),Min:(Max+1))./numel(ParticleData.Data.Intensity(:,:,Frame));
        end
        %%% Updates plot
        h.Particle_CountsHist{1}.YData = Int;
        h.Particle_CountsHist{1}.XData = Min:Max;
        h.Particle_CountsHist{2}.YData = Int_Frame;
        h.Particle_CountsHist{2}.XData = Min:Max;
        %%% Turns single frame plot on
        h.Particle_CountsHist{2}.Visible ='on';
        
    end
end

%%% Plots detected particles
if any(mode==2)
    if isfield(ParticleData,'Regions')
        
        %%% Distinguishes between framewise and total mask
        if size(ParticleData.Mask,3) == 1
            Mask = ParticleData.Mask;            
        elseif Frame == 0 || size(ParticleData.Mask,3)<Frame
            Mask = ParticleData.Mask(:,:,1);
        else
            Mask = ParticleData.Mask(:,:,Frame);
        end
        %%% Distinguishes between framewise and total particle assignement
        if size(ParticleData.Particle,3) == 1
            Particle = ParticleData.Particle;
        elseif Frame == 0 || size(ParticleData.Particle,3)<Frame
            Particle = ParticleData.Particle(:,:,1);
        else
            Particle = ParticleData.Particle(:,:,Frame);
        end
        
        %%% Selects right frame for plotting or summed frame
        if h.Particle_Display_ExternalMask.Value...%%% Uses external mask for displaying  
                && h.Particle_Use_External_Mask.Value...
                && isfield(ParticleData,'MaskData')...
                && size(ParticleData.MaskData,1) == size(Mask,1)...
                && size(ParticleData.MaskData,2) == size(Mask,2)
                         
            if Frame == 0 %% Summed up image
                Int = ParticleData.MaskData_Sum;
            elseif Frame >size(ParticleData.MaskData,3) 
                Int = ParticleData.MaskData(:,:,1);
            else %%% Framewise image
                Int = ParticleData.MaskData(:,:,Frame);
            end
        else %%% Uses data itself for displaying
            
            if Frame == 0 %% Summed up image
                Int = ParticleData.Int_Sum;
            else %%% Framewise image
                Int = ParticleData.Data.Intensity(:,:,Frame);
            end
        end
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
            Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
        else
            Min = min(Int(:));
            Max = max(Int(:));
        end
        
        switch h.Particle_Disply_Type.Value
            case 1 %%% Mask only
                Image = zeros(size(Mask,1),size(Mask,2),3);
                Image(:,:,1)=Mask;
            case 2 %%% Mask overlay           
                %%% Grayscale Image with red homogeneous particles
                Image=(Int-Min)/(Max-Min).*~Mask;
                Image = repmat(Image,[1 1 3]);
                Image(Mask) = 1;
                
            case 3 %%% Mask gray/red               
                %%% Grayscale Image with red scaled particles
                Int=(Int-Min)/(Max-Min);
                Image = Int.*~Mask;
                Image = repmat(Image,[1 1 3]);
                Image(Mask) = Int(Mask);
            case 4 %%% Mask magenta/green
                %%% Scales Intensity image
                Int=(Int-Min)/(Max-Min);
                
                %%% Green scaled Image with red scaled particles              
                Image = repmat(Int.*Mask,[1 1 3]);
                Image(:,:,2) = Int.*~Mask;
                
            case 5 %%% Particles only
                %%% Particles colored with jet
                Color = [0,0,0; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
            case 6 %%% Particles overlay
                %%% Scales Intensity image
                Int=(Int-Min)/(Max-Min);
                %%% Sets particles to homogeneous jet color
                Color = [0,0,0; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
                %%% Sets non-particles to grayscale
                Image = repmat(Int.*~Particle,[1 1 3])+Image;
                
            case 7 %%% Particles gray/jet
                %%% Scales Intensity image
                Int=(Int-Min)/(Max-Min);
                %%% Sets particles to scaled jet and rest to gray scale
                Color = [1 1 1 ; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3).*repmat(Int,[1 1 3]);
        end
        
        h.Particle_Display_Image.CData = Image;
        h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
        h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
        h.Particle_Number.String = ['Particles detected: ' num2str(numel(ParticleData.Regions))];
    elseif h.Particle_Display_ExternalMask.Value...%%% Displays only the external mask
                && h.Particle_Use_External_Mask.Value...
                && isfield(ParticleData,'MaskData')...
                && size(ParticleData.MaskData,1) == size(ParticleData.Data.Intensity,1)...
                && size(ParticleData.MaskData,2) == size(ParticleData.Data.Intensity,2)
            
            if Frame == 0 %% Summed up image
                Int = ParticleData.MaskData_Sum;
            elseif Frame >size(ParticleData.MaskData,3)
                Int = ParticleData.MaskData(:,:,1);
            else %%% Framewise image
                Int = ParticleData.MaskData(:,:,Frame);
            end
            %%% Adjusts to range
            if h.Particle_ManualScale.Value
                Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
                Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
            else
                Min = min(Int(:));
                Max = max(Int(:));
            end
            
            Image=(Int-Min)/(Max-Min);
            Image = repmat(Image,[1 1 3]);
            
            h.Particle_Display_Image.CData = Image;
            h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
            h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
            h.Particle_Number.String = 'Particles detected: 0';
    
    else %%% Displays nothing
        if Frame == 0 %% Summed up image
            Int = ParticleData.Int_Sum;
        else %%% Framewise image
            Int = ParticleData.Data.Intensity(:,:,Frame);
        end
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Min = str2double(h.Particle_ScaleMin.String); Int(Int < Min)= Min;
            Max = str2double(h.Particle_ScaleMax.String); Int(Int > Max)= Max;
        else
            Min = min(Int(:));
            Max = max(Int(:));
        end
        
        Image=(Int-Min)/(Max-Min);
        Image = repmat(Image,[1 1 3]);
        
        h.Particle_Display_Image.CData = Image;
        h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
        h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
        h.Particle_Number.String = 'Particles detected: 0';
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Go through frames %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Frame(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData

if isempty(ParticleData)
    return;
end

%%% Gets new value
switch mode
    case 1 %%% Editbox was changed
        Frame = round(str2double(h.Particle_Frame.String));
    case 2 %%% Slider was changed
        Frame = round(h.Particle_FrameSlider.Value);
end
%%% Sets value to valid range
if isempty(Frame) || Frame < 0
    Frame = 0;
elseif Frame > size(ParticleData.Data.Intensity,3)
    Frame = size(ParticleData.Data.Intensity,3);
end
%%% Updates both Frame settings
h.Particle_Frame.String = num2str(Frame);
h.Particle_FrameSlider.Value = Frame;
%%% Plots loaded image
Plot_Particle([],[],0:2,h)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to update method selection and settings %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Update(~,~,mode)
h = guidata(findobj('Tag','Particle'));
LSUserValues(0);

switch h.Particle_Method.Value
    case 1 %%% Regionprops with some shape detection
        Method_Regionprops_Shape([],[],mode);
    case 2 %%% Wavelets and Regionprops
        Method_Wavelets_Simple([],[],mode);
    case 3 %%% Use external mask
        Method_External([],[],mode);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Here are all the different methods collected in separate functions %%%%
%%% General shape:
%%% mode == 0 to update settings
%%% mode == 1 calculating the detection
%%% Note: The particle detection can be both full stack and frame by frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Regionprops with thresholding and shape
function Method_Regionprops_Shape(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
if mode == 0
    
    
    %%% Updates Table
    TableData = {   'Pixel Threshold [Counts]',150;...
        'Min Size [px]:', 10;...
        'Max Size [px]:', 100;...
        'Gauss. Filter [Px]' ,2;...
        'Eccentricity', 0.7};
    ColumnNames = {'Parameter Name', 'Value'};
    
    h.Particle_Method_Settings.ColumnName = ColumnNames;
    h.Particle_Method_Settings.Data = TableData;
    
    %%% Updates Method information
    h.Particle_Method_Description.String =['This method uses a threshold to calculate a binary map. '...
        'Gaussian filtering is applied before thresholding. '....
        'Based on this map it uses the matlab "regionprops" function to detect particles. '...
        'It uses eccentricity filtering for shape detection. ',...
        'The data defined with the frame range in used. '];
    %%% Removed detected particle data
    if isfield(ParticleData,'Regions')
        ParticleData = rmfield(ParticleData,'Regions');
    end
    if isfield(ParticleData,'Mask')
        ParticleData = rmfield(ParticleData,'Mask');
    end
    if isfield(ParticleData,'Particle')
        ParticleData = rmfield(ParticleData,'Particle');
    end
    Plot_Particle([],[],2,h)
    return;
end

%%% Actual particle detection and averaging
if mode == 1
    %%% Extracts parameters
    TH = h.Particle_Method_Settings.Data{1,2};
    MinSize = h.Particle_Method_Settings.Data{2,2};
    MaxSize = h.Particle_Method_Settings.Data{3,2};
    Gaus = h.Particle_Method_Settings.Data{4,2};
    Eccent = h.Particle_Method_Settings.Data{5,2};
    
    From = str2double(h.Particle_Frames_Start.String);
    To = str2double(h.Particle_Frames_Stop.String);
    
    %%% Adjusts frame range to data
    if To>size(ParticleData.Data.Intensity,3)
        To = size(ParticleData.Data.Intensity,3);
        h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
    end
    if From > To
        From = 1;
        h.Particle_Frames_Start.String = 1;
    end
    
    %%% Averages image   
    if h.Particle_Use_External_Mask.Value
        %%% Used external map if possible
        if ~isfield(ParticleData,'MaskData') ||...
                size(ParticleData.MaskData,1)<size(ParticleData.Data.Intensity,1) ||...
                size(ParticleData.MaskData,2)<size(ParticleData.Data.Intensity,2)
            
            Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
            h.Particle_Use_External_Mask.Value=0;
        elseif  size(ParticleData.MaskData,3)<To
            Int = sum(ParticleData.MaskData,3);
        else
            Int = sum(ParticleData.MaskData(:,:,From:To),3);
        end
    else
        %%% Used image directly
        Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
    end
    
    a=Int;
    %%% Gaussian filter
    if Gaus>1
        h = fspecial('gaussian', round(3.*[Gaus Gaus]), Gaus);
        Int = filter2(h, Int);
    end
    
    %%% Applies threshold
    BitImage = Int > TH;
    
    %%% Calculates regionprops
    Regions = regionprops(BitImage,Int,'eccentricity', 'PixelList','Area','PixelIdxList','MaxIntensity','MeanIntensity','PixelValues');
    
    %%% Aborts calculation when no particles were detected
    if isempty(Regions)
        msgbox('No particles detected! Please change threshold.');
        return;
    end
    
    
    if MinSize<1
        MinSize =1;
    end
    if MaxSize<MinSize || MaxSize>numel(BitImage)
        MaxSize = numel(BitImage);
    end
    %%% Removes small regions
    Regions(cat(1, Regions.Area)<MinSize)=[];
    %%% Removes large regions
    Regions(cat(1, Regions.Area)>MaxSize)=[];
    %%% Removes eccentric regions
    Regions(cat(1, Regions.Eccentricity)>Eccent)=[];
    
    ParticleData.Regions = Regions;
    ParticleData.Mask = false(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    ParticleData.Particle = zeros(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    %%% Reformats particle information for Phasor calculation
    for i=1:numel(Regions)
        ParticleData.Mask(Regions(i).PixelIdxList) = true;
        ParticleData.Particle(Regions(i).PixelIdxList) = i;
        ParticleData.Regions(i).TotalCounts = Regions(i).MeanIntensity.*Regions(i).Area;
    end
    ParticleData.Particle = repmat(ParticleData.Particle,1,1,To-From+1);
    Plot_Particle([],[],2,h)
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Regionprops with thresholding and shape
function Method_Wavelets_Simple(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
if mode == 0
    
    
    %%% Updates Table
    TableData = {   'Threshold Significance [0-1]',0.8;...
        'Min Photons',500;...
        'Max Photons',3000;...
        'Min Size [px]:', 10;...
        'Max Size [px]:', 100;...
        'Wavelet depth' ,3;...
        'Eccentricity', 0.7};
    ColumnNames = {'Parameter Name', 'Value'};
    
    h.Particle_Method_Settings.ColumnName = ColumnNames;
    h.Particle_Method_Settings.Data = TableData;
    
    %%% Updates Method information
    h.Particle_Method_Description.String =['This method uses wavelets to calculate a binary map. '...
        'Gaussian filtering is applied before thresholding. '....
        'Based on this map it uses the matlab "regionprops" function to detect particles. '...
        'It uses eccentricity filtering for shape detection. ',...
        'The data defined with the frame range in used. '];
    %%% Removed detected particle data
    if isfield(ParticleData,'Regions')
        ParticleData = rmfield(ParticleData,'Regions');
    end
    if isfield(ParticleData,'Mask')
        ParticleData = rmfield(ParticleData,'Mask');
    end
    if isfield(ParticleData,'Particle')
        ParticleData = rmfield(ParticleData,'Particle');
    end
    Plot_Particle([],[],2,h)
    return;
end

%%% Actual particle detection and averaging
if mode == 1
    %% Extracts parameters
    TH = h.Particle_Method_Settings.Data{1,2};
    MinP = h.Particle_Method_Settings.Data{2,2};
    MaxP = h.Particle_Method_Settings.Data{3,2};
    MinSize = h.Particle_Method_Settings.Data{4,2};
    MaxSize = h.Particle_Method_Settings.Data{5,2};
    Wavelet = h.Particle_Method_Settings.Data{6,2};
    Eccent = h.Particle_Method_Settings.Data{7,2};
    
    From = str2double(h.Particle_Frames_Start.String);
    To = str2double(h.Particle_Frames_Stop.String);
    
    %%% Adjusts frame range to data
    if To>size(ParticleData.Data.Intensity,3)
        To = size(ParticleData.Data.Intensity,3);
        h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
    end
    if From > To
        From = 1;
        h.Particle_Frames_Start.String = 1;
    end
    
    %% Extracts regions
    %%% Averages image
    if h.Particle_Use_External_Mask.Value
        %%% Used external map if possible
        if ~isfield(ParticleData,'MaskData') ||...
                size(ParticleData.MaskData,1)<size(ParticleData.Data.Intensity,1) ||...
                size(ParticleData.MaskData,2)<size(ParticleData.Data.Intensity,2)
            
            Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
            h.Particle_Use_External_Mask.Value=0;
        elseif  size(ParticleData.MaskData,3)<To
            Int = sum(ParticleData.MaskData,3);
        else
            Int = sum(ParticleData.MaskData(:,:,From:To),3);
        end
    else
        %%% Used image directly
        Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
    end
    
    %%% Wavelet filter ® P. Messer, 2016
    w(:,:,1)=Int;
    for i = 1:Wavelet-1
        kern = [1/16,zeros(1,2^(i-1)-1),1/4,zeros(1,2^(i-1)-1),3/8,zeros(1,2^(i-1)-1),1/4,zeros(1,2^(i-1)-1),1/16]; % Convolution Kernel (a trous)
        kernsize = numel(kern);
        t = conv2(kern,kern,padarray(Int(:,:,i),[kernsize kernsize],'symmetric'),'same'); % Image gets symmetrical padded to prevent edge effects
        Int(:,:,i+1) = t(kernsize+1:end-kernsize,kernsize+1:end-kernsize); % Crop image to original size
        tw = Int(:,:,i)- Int(:,:,i+1); % Get Wavelet
        tw2 = abs(tw - median(tw(:))); % Calculate Median Absolute Deviation (MAD)
        %sig = 2*median(tw2(:)); % Estimate std from MAD with k==3
        tw(tw<0) = 0; % Remove unsignificant wavelet coefficients
        w(:,:,i+1) = tw; % Create Wavelet Array
    end
    Int=w(:,:,Wavelet);
    
    %%% Calculates relative threshold
    TH=round(TH.*numel(Int));
    Sorted=sort(Int(:));
    TH=Sorted(TH)+1;
    
    %%% Applies threshold
    BitImage = Int > TH;
    
    %%% Calculates regionprops
    Regions = regionprops(BitImage,Int,'eccentricity', 'PixelList','Area','PixelIdxList','MaxIntensity','MeanIntensity','PixelValues');
    
    %%% Aborts calculation when no particles were detected
    if isempty(Regions)
        msgbox('No particles detected! Please change threshold.');
        return;
    end
    
    %% Applies region criteria
    %%% Removes small regions
    Regions(cat(1, Regions.Area)<MinSize)=[];
    %%% Removes large regions
    if MaxSize<MinSize || MaxSize>numel(BitImage)
        MaxSize = numel(BitImage);
    end
    Regions(cat(1, Regions.Area)>MaxSize)=[];
    
    %%% Removes dark particles
    Regions(cat(1, Regions.Area).*cat(1,Regions.MeanIntensity)<MinP)=[];
    %%% Removes bright particles
    if MaxP<MinP || MaxP==0
        MaxP = sum(Int(:));
    end
    Regions(cat(1, Regions.Area).*cat(1,Regions.MeanIntensity)>MaxP)=[];
    
    %%% Removes eccentric regions
    Regions(cat(1, Regions.Eccentricity)>Eccent)=[];
    
    %% Applies particle selection
    ParticleData.Regions = Regions;
    ParticleData.Mask = false(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    ParticleData.Particle = zeros(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    %%% Reformats particle information for Phasor calculation
    for i=1:numel(Regions)
        ParticleData.Mask(Regions(i).PixelIdxList) = true;
        ParticleData.Particle(Regions(i).PixelIdxList) = i;
        ParticleData.Regions(i).TotalCounts = Regions(i).MeanIntensity.*Regions(i).Area;
    end
    Plot_Particle([],[],2,h)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Regionprops with thresholding and shape
function Method_External(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
if mode == 0
    
    
    %%% Updates Table
    TableData = {};
    ColumnNames = {'Parameter Name', 'Value'};
    
    h.Particle_Method_Settings.ColumnName = ColumnNames;
    h.Particle_Method_Settings.Data = TableData;
    
    %%% Updates Method information
    h.Particle_Method_Description.String =['This method uses an externally generated mask. '...
        'Load a TIFF based mask to use this method. '....
        'Pixels are assined to particles based on their value. '...
        'Pixel values of 0 are associated to background. '...
        'Currently only a static mask is supported.'];
    %%% Removed detected particle data
    if isfield(ParticleData,'Regions')
        ParticleData = rmfield(ParticleData,'Regions');
    end
    if isfield(ParticleData,'Mask')
        ParticleData = rmfield(ParticleData,'Mask');
    end
    if isfield(ParticleData,'Particle')
        ParticleData = rmfield(ParticleData,'Particle');
    end
    Plot_Particle([],[],2,h)
    return;
end

%%% Actual particle detection and averaging
if mode == 1
    
    %%% Stops invalid execution
    if ~isfield(ParticleData,'MaskData') ||...
       ~isfield(ParticleData,'Data') ||...
       size(ParticleData.MaskData,1)~= size(ParticleData.Data.Intensity,1) ||...
       size(ParticleData.MaskData,2)~= size(ParticleData.Data.Intensity,2)
        msgbox('Invalid data loaded'); 
        return;
    end

    From = str2double(h.Particle_Frames_Start.String);
    To = str2double(h.Particle_Frames_Stop.String);
    
    %%% Adjusts frame range to mask data
    if To>size(ParticleData.MaskData,3)
        To = size(ParticleData.MaskData,3);
        h.Particle_Frames_Stop.String = size(ParticleData.MaskData,3);
    end
    if From > To
        From = 1;
        h.Particle_Frames_Start.String = 1;
    end
    
    %%% Extracts mask
    ParticleData.Particle = max(ParticleData.MaskData(:,:,From:To),[],3);
    ParticleData.Mask = ParticleData.Particle>0;
    
    From = str2double(h.Particle_Frames_Start.String);
    To = str2double(h.Particle_Frames_Stop.String);
    
    %%% Adjusts frame range to data
    if To>size(ParticleData.Data.Intensity,3)
        To = size(ParticleData.Data.Intensity,3);
        h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
    end
    if From > To
        From = 1;
        h.Particle_Frames_Start.String = 1;
    end
    
    %%% Extracts intensity
    %%% Used image directly
        Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
        
    for i=1:max(Int(:))
        TH = ParticleData.Particle==i;
        
        Regions(i).Ecctentricity = NaN;
        Regions(i).PixelIdxList = find(TH);
        [Regions(i).PixelList(:,1), Regions(i).PixelList(:,2)] = find(TH);
        Regions(i).Area = numel(Regions(i).PixelIdxList);
        Regions(i).TotalCounts = sum(Int(Regions(i).PixelIdxList)); 
        Regions(i).MeanIntensity = Regions(i).TotalCounts/Regions(i).Area;
        Regions(i).MaxIntensity = max(Int(Regions(i).PixelIdxList)); 
        
    end
    
    %%% Aborts calculation when no particles were detected
    if isempty(Regions)
        msgbox('No particles detected! Please change threshold.');
        return;
    end
    
    ParticleData.Regions = Regions;
    ParticleData.Particle = repmat(ParticleData.Particle,1,1,To-From+1);
    Plot_Particle([],[],2,h)
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Here are all the different methods for applying ROI and saving the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Particle_Save(~,~)
h = guidata(findobj('Tag','Particle'));
switch h.Particle_Save_Method.Value
    case 1 %%% Save time sum
        Save_Averaged;
    case 2 %%% Save FLIM trace
        Save_FLIM_Trace;
    case 3 %%% Saves text or excel files
        Save_Text;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Averages the selected regions and frames and saves the FLIM image
function Save_Averaged
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName] = uiputfile('*.phr','Save Phasor Data', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end

%%% Uses summed up Image and Phasor
From = str2double(h.Particle_Frames_Start.String);
To = str2double(h.Particle_Frames_Stop.String);
%%% Adjusts frame range to data
if To>size(ParticleData.Data.Intensity,3)
    To = size(ParticleData.Data.Intensity,3);
    h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
end
if From > To
    From = 1;
    h.Particle_Frames_Start.String = 1;
end


Mask = logical(squeeze(sum(ParticleData.Mask,3)));
g = sum(ParticleData.Data.g(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
s = sum(ParticleData.Data.s(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Intensity = sum(ParticleData.Data.Intensity(:,:,From:To),3);

%%% Applies particle averaging
for i=1:numel(ParticleData.Regions)
    %%% Calculates mean particle phasor
    ParticleData.Regions(i).g = sum(g(ParticleData.Regions(i).PixelIdxList).*Intensity(ParticleData.Regions(i).PixelIdxList))...
        ./sum(Intensity(ParticleData.Regions(i).PixelIdxList));
    ParticleData.Regions(i).s = sum(s(ParticleData.Regions(i).PixelIdxList).*Intensity(ParticleData.Regions(i).PixelIdxList))...
        ./sum(Intensity(ParticleData.Regions(i).PixelIdxList));
    %%% Applies particle phasor to pixels
    g(ParticleData.Regions(i).PixelIdxList) = ParticleData.Regions(i).g;
    s(ParticleData.Regions(i).PixelIdxList) = ParticleData.Regions(i).s;
end

%%% Sets non-particle pixels to 0
if ~h.Particle_Use_NonParticle.Value
    g(~Mask) = 0;
    s(~Mask) = 0;
    Mean_LT(~Mask) = 0;
end

%%% Updates secondary parameters
Freq = ParticleData.Data.Freq;
Fi = atan(s./g); Fi(isnan(Fi)) = 0;
M = sqrt(s.^2+g.^2);Fi(isnan(M)) = 0;
TauP = real(tan(Fi)./(2*pi*Freq/10^9)); TauP(isnan(TauP)) = 0; %#ok<*NASGU>
TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*Freq/10^9)); TauM(isnan(TauM)) = 0;
Mean_LT = sum(ParticleData.Data.Mean_LT(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Lines = ParticleData.Data.Lines;
Pixels = ParticleData.Data.Pixels;
Imagetime = ParticleData.Data.Imagetime;
Frames = To-From+1;
FileNames = ParticleData.Data.FileNames;
Type = ParticleData.Data.Type;
Regions =ParticleData.Regions;
Path = ParticleData.Data.Path;

save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','Regions');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save the particle data as a text or excel file
function Save_FLIM_Trace
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName] = uiputfile('*.phr','Save Phasor Data', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end

%%% Uses summed up Image and Phasor
From = str2double(h.Particle_Frames_Start.String);
To = str2double(h.Particle_Frames_Stop.String);
Frames_Sum = str2double(h.Particle_Frames_Sum.String);
%%% Adjusts frame range to data
if To>size(ParticleData.Data.Intensity,3)
    To = size(ParticleData.Data.Intensity,3);
    h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
end
if From > To
    From = 1;
    h.Particle_Frames_Start.String = 1;
end


%%% Applies particle averaging
Int = ParticleData.Data.Intensity(:,:,From:To);
G = ParticleData.Data.g(:,:,From:To).*Int; %%%unnormalized g
S = ParticleData.Data.s(:,:,From:To).*Int; %%%unnormalized s

%%% Creates arrays with size(Particle,Frames)
g=zeros(numel(ParticleData.Regions),To-From+1);
s=zeros(numel(ParticleData.Regions),To-From+1);
Intensity=zeros(numel(ParticleData.Regions),To-From+1);

%%%Calculates frame-wise average for each particle
for i=1:max(ParticleData.Particle(:)) 
    %%% Extends PixelId for every frame
    PixelId = repmat((0:(size(g,2)-1))*numel(Int(:,:,1)),numel(ParticleData.Regions(i).PixelIdxList),1);
    PixelId = PixelId + repmat(ParticleData.Regions(i).PixelIdxList,1,size(g,2));
    %%% 
    Intensity(i,:)=sum(Int(PixelId),1);
    g(i,:)=sum(G(PixelId),1); %%%unnormalized g
    s(i,:)=sum(S(PixelId),1); %%%unnormalized s
    
    %Intensity(i,:)= squeeze(sum(sum(Int(ParticleData.Regions(i).PixelList(:,2),ParticleData.Regions(i).PixelList(:,1),:),1),2));
    %g(i,:)= squeeze(sum(sum(G(ParticleData.Regions(i).PixelList(:,2),ParticleData.Regions(i).PixelList(:,1),:),1),2));
    %s(i,:)= squeeze(sum(sum(S(ParticleData.Regions(i).PixelList(:,2),ParticleData.Regions(i).PixelList(:,1),:),1),2));
end

%%% Cuts size to a multiple of the Frames_Sum
Intensity= Intensity(:,1:(floor(size(Intensity,2)/Frames_Sum))*Frames_Sum);
g= g(:,1:(floor(size(Intensity,2)/Frames_Sum))*Frames_Sum);
s= s(:,1:(floor(size(Intensity,2)/Frames_Sum))*Frames_Sum);
%%% Summs up frame range
Intensity = squeeze(sum(reshape(Intensity,size(Intensity,1),Frames_Sum,[]),2));
g = squeeze(sum(reshape(g,size(g,1),Frames_Sum,[]),2))./Intensity; %%% normalized g
s = squeeze(sum(reshape(s,size(s,1),Frames_Sum,[]),2))./Intensity; %%% normalized s
g(isnan(g))=0;
s(isnan(s))=0;

%%% Updates secondary parameters
Freq = ParticleData.Data.Freq;
Fi = atan(s./g); Fi(isnan(Fi)) = 0;
M = sqrt(s.^2+g.^2);Fi(isnan(M)) = 0;
TauP = real(tan(Fi)./(2*pi*Freq/10^9)); TauP(isnan(TauP)) = 0; %#ok<*NASGU>
TauM = real(sqrt((1./(s.^2+g.^2))-1)/(2*pi*Freq/10^9)); TauM(isnan(TauM)) = 0;
Mean_LT = sum(ParticleData.Data.Mean_LT(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Lines = ParticleData.Data.Lines;
Pixels = ParticleData.Data.Pixels;
Imagetime = ParticleData.Data.Imagetime;
Frames = Frames_Sum;
FileNames = ParticleData.Data.FileNames;
Type = ParticleData.Data.Type;
Regions =ParticleData.Regions;
Path = ParticleData.Data.Path;

save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','Regions');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save the FLIM data as a trace for each (static) region over time
function Save_Text
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName, FilterIndex] = uiputfile({'*.txt';'*.csv';'*.xlsx';},'Save Particle Data', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end

%%% Uses summed up Image and Phasor
From = str2double(h.Particle_Frames_Start.String);
To = str2double(h.Particle_Frames_Stop.String);
%%% Adjusts frame range to data
if To>size(ParticleData.Data.Intensity,3)
    To = size(ParticleData.Data.Intensity,3);
    h.Particle_Frames_Stop.String = size(ParticleData.Data.Intensity,3);
end
if From > To
    From = 1;
    h.Particle_Frames_Start.String = 1;
end


Mask = logical(squeeze(sum(ParticleData.Mask,3)));
g = sum(ParticleData.Data.g(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
s = sum(ParticleData.Data.s(:,:,From:To).*ParticleData.Data.Intensity(:,:,From:To),3)./sum(ParticleData.Data.Intensity(:,:,From:To),3);
Intensity = sum(ParticleData.Data.Intensity(:,:,From:To),3);

%%% Applies particle averaging
G=zeros(numel(ParticleData.Regions),1);
S=zeros(numel(ParticleData.Regions),1);
x=zeros(numel(ParticleData.Regions),1);
y=zeros(numel(ParticleData.Regions),1);
for i=1:numel(ParticleData.Regions)
    %%% Calculates mean particle phasor
    G(i) = sum(g(ParticleData.Regions(i).PixelIdxList).*Intensity(ParticleData.Regions(i).PixelIdxList))...
        ./sum(Intensity(ParticleData.Regions(i).PixelIdxList));
    S(i) = sum(s(ParticleData.Regions(i).PixelIdxList).*Intensity(ParticleData.Regions(i).PixelIdxList))...
        ./sum(Intensity(ParticleData.Regions(i).PixelIdxList));
    %%% Extracts first pixel position of each particle
    x(i) = ParticleData.Regions(i).PixelList(1,1);
    y(i) = ParticleData.Regions(i).PixelList(1,2);
    
end

%%% Calculate lifetimes from phasor
Freq = repmat(ParticleData.Data.Freq,size(G));
Fi = atan(S./G);
M = sqrt(S.^2+G.^2);
TauP = real(tan(Fi)./(2*pi*Freq/10^9));
TauM = real(sqrt((1./(S.^2+G.^2))-1)./(2*pi*Freq/10^9));


VarNames = {'TauP','TauM','TotalPhotons','MeanPhotons','MaxPhotons','Area','x','y','s','g','Frequency'};
%%% Creates table variable for saving
tab = table(TauP,... Phase based lifetime
            TauM,... Modulation based lifetime
            [ParticleData.Regions.TotalCounts]',... Total photons of particle
            [ParticleData.Regions.MeanIntensity]',... Average photons per pixel
            [ParticleData.Regions.MaxIntensity]',... Brightest pixel counts
            [ParticleData.Regions.Area]',... Particle area in photons
            x,... x position of first pixel
            y,... y position of first pixel
            S,... S value of particle
            G,... G value of particle
            Freq,... %%% Measurement frequency, e.g. 1/TAC
            'VariableNames',VarNames);

%%% Saves data as text or table
if FilterIndex == 1 %%% Use tab sepparation for .txt files
    writetable(tab,fullfile(PathName,FileName),'Delimiter','tab');
else
    writetable(tab,fullfile(PathName,FileName));
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Saves the calculated Mask as a TIFF %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Save_Mask(~,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Stops execution if data is not complete
if isempty(ParticleData) || ~isfield(ParticleData,'Regions')
    return;
end
%%% Select file names for saving
[FileName,PathName] = uiputfile('*.tif', 'Save Mask', fullfile(ParticleData.PathName, ParticleData.FileName(1:end-4)));
%%% Checks, if selection was cancled
if all(FileName == 0)
    return;
end
Image = uint16(ParticleData.Particle(:,:,1));
imwrite(Image,fullfile(PathName,FileName));













%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Collection of various small functions
function Misc(Obj,~)
h = guidata(findobj('Tag','Particle'));
global ParticleData
switch Obj
    case h.Particle_Save_Method %%% Toggle frame summing visibility
        if h.Particle_Save_Method.Value == 2
            h.Particle_Frames_Sum.Visible = 'on';
            h.Particle_Frames_Sum_Text.Visible = 'on';
        else
            h.Particle_Frames_Sum.Visible = 'off';
            h.Particle_Frames_Sum_Text.Visible = 'off';
        end
    case h.Particle_Use_External_Mask %%% Turns off External Maks if empty
        if ~isfield(ParticleData,'MaskData')
            h.Particle_Use_External_Mask.Value = 0;
        end
        Plot_Particle([],[],2,h);
end
