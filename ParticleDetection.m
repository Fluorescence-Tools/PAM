function ParticleDetection
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
    'Callback',@Load_Particle_Data,...
    'Tag','Load_Phasor');

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
    'Position',[0.1 0.07 0.82 0.25]);
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

%%% Starts Calculation
h.Particle_DoCalculation = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Method_Update,1},...
    'Position',[0.15 0.03, 0.3 0.2],...
    'String','Calculate');
h.Particle_Save = uicontrol(...
    'Parent',h.Plot_Control_Panel,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',15,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Method_Update,2},...
    'Position',[0.55 0.03, 0.3 0.2],...
    'String','Save');

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
    'String',{'Simple threshold and regionprops method',...
              'Threshold and Regionprops with shape method'});

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
    'Position',[0.01 0.01 0.98 0.7],...
    'Data',TableData,...
    'ColumnName',ColumnNames,...
    'RowName',RowNames,...
    'ColumnEditable',ColumnEditable,...
    'ColumnFormat',ColumnFormat);

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
    'Position',[0.02 0.26, 0.96 0.05],...
    'String',{  'Mask only',...
                'Mask overlay',...
                'Mask gray/red',...
                'Mask magenta/green',...
                'Particles only',...
                'Particles overlay',...
                'Particles gray/jet'});
            
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
%% Stores Info in guidata
guidata(h.Particle,h); 

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

%%% Adjusts slider and frame range
h.Particle_FrameSlider.Min=0;
h.Particle_FrameSlider.Max=size(ParticleData.Data.Intensity,3);
h.Particle_FrameSlider.SliderStep=[1./size(ParticleData.Data.Intensity,3),10/size(ParticleData.Data.Intensity,3)];
h.Particle_FrameSlider.Value=0;
h.Particle_Frame.String = '0';
guidata(h.Particle,h);

%%% Plots loaded image
Plot_Particle([],[],0:2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates plots in Particle figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Plot_Particle(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData

if isempty(ParticleData)
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
        Int = sum(ParticleData.Data.Intensity,3);
    else %%% Framewise image
        Int = ParticleData.Data.Intensity(:,:,Frame);
    end
    %%% Adjusts to range
    if h.Particle_ManualScale.Value
        Int(Int < str2double(h.Particle_ScaleMin.String))=str2double(h.Particle_ScaleMin.String);
        Int(Int > str2double(h.Particle_ScaleMax.String))=str2double(h.Particle_ScaleMax.String);
    end
    %%% Transforms intensity image to 128 colors
    Int=round(127*(Int-min(min(Int)))/(max(max(Int))-min(min(Int))))+1;
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
        Int = sum(ParticleData.Data.Intensity,3);        
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Int(Int < str2double(h.Particle_ScaleMin.String))=NaN;
            Int(Int > str2double(h.Particle_ScaleMax.String))=NaN;
        end
        Int = Int(:);
        %%% Updates plot
        h.Particle_CountsHist{1}.YData = histc(Int,min(floor(Int)):max(ceil(Int)))/sum(~isnan(Int));
        h.Particle_CountsHist{1}.XData = min(floor(Int)):max(ceil(Int));
        %%% Turns single frame plot off
        h.Particle_CountsHist{2}.Visible ='off';
    else %%% Framewise intensity
        %%% Extracts right data
        Int = ParticleData.Data.Intensity;
        Int_Frame = ParticleData.Data.Intensity(:,:,Frame);
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Int(Int < str2double(h.Particle_ScaleMin.String))=NaN;
            Int(Int > str2double(h.Particle_ScaleMax.String))=NaN;
            
            Int_Frame(Int_Frame < str2double(h.Particle_ScaleMin.String))=NaN;
            Int_Frame(Int_Frame > str2double(h.Particle_ScaleMax.String))=NaN;
        end
        Int=Int(:);
        Int_Frame=Int_Frame(:);
        %%% Updates plot
        h.Particle_CountsHist{1}.YData = histc(Int,min(floor(Int)):max(ceil(Int)))/sum(~isnan(Int));
        h.Particle_CountsHist{1}.XData = min(floor(Int)):max(ceil(Int));
        h.Particle_CountsHist{2}.YData = histc(Int_Frame,min(floor(Int_Frame)):max(ceil(Int_Frame)))/sum(~isnan(Int_Frame));
        h.Particle_CountsHist{2}.XData = min(floor(Int_Frame)):max(ceil(Int_Frame));
        %%% Turns single frame plot on
        h.Particle_CountsHist{2}.Visible ='on';
        
    end
end

%%% Plots detected particles
if any(mode==2)
    if isfield(ParticleData,'Regions')
        
        if Frame == 0 || size(ParticleData.Mask,3)==1
           Mask = logical(sum(ParticleData.Mask,3));
        else
           Mask = ParticleData.Mask(:,:,Frame);
        end
        if Frame == 0 || size(ParticleData.Particle,3)==1
            Particle = ceil(mean(ParticleData.Particle,3));
        else
            Particle = ParticleData.Particle(:,:,Frame);
        end
        %%% Selects right frame for plotting or summed frame
        if Frame == 0 %% Summed up image
            Int = sum(ParticleData.Data.Intensity,3);
        else %%% Framewise image
            Int = ParticleData.Data.Intensity(:,:,Frame);
        end
        %%% Adjusts to range
        if h.Particle_ManualScale.Value
            Int(Int < str2double(h.Particle_ScaleMin.String))=str2double(h.Particle_ScaleMin.String);
            Int(Int > str2double(h.Particle_ScaleMax.String))=str2double(h.Particle_ScaleMax.String);
        end
        
        switch h.Particle_Disply_Type.Value
            case 1 %%% Mask only
                Image = zeros(size(Mask,1),size(Mask,2),3);
                Image(:,:,1)=Mask;
            case 2 %%% Mask overlay
                %%% Scales Intensity image
                Int=(Int-min(min(Int)))/(max(max(Int))-min(min(Int)));
                
                %%% Grayscale Image with red homogeneous particles
                Image = repmat(Int,[1 1 3]);           
                Image(Mask) = 1;
                Image(:,:,2) = Image(:,:,2).*~Mask;
                Image(:,:,3) = Image(:,:,3).*~Mask;
                
            case 3 %%% Mask gray/red
                %%% Scales Intensity image
                Int=(Int-min(min(Int)))/(max(max(Int))-min(min(Int)));
                
                %%% Grayscale Image with red scaled particles
                Image = repmat(Int,[1 1 3]);
                Image(:,:,2) = Image(:,:,2).*~Mask;
                Image(:,:,3) = Image(:,:,3).*~Mask;
            case 4 %%% Mask magenta/green
                %%% Scales Intensity image
                Int=(Int-min(min(Int)))/(max(max(Int))-min(min(Int)));
                
                %%% Green scaled Image with red scaled particles
                Image = repmat(Int,[1 1 3]);
                Image(:,:,1) = Image(:,:,3).*Mask;
                Image(:,:,2) = Image(:,:,2).*~Mask;
                Image(:,:,3) = Image(:,:,3).*Mask;
                
            case 5 %%% Particles only
                %%% Particles colored with jet
                Color = [0,0,0; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
            case 6 %%% Particles overlay
                %%% Scales Intensity image
                Int=(Int-min(min(Int)))/(max(max(Int))-min(min(Int)));
                %%% Sets particles to homogeneous jet color
                Color = [0,0,0; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3);
                %%% Sets non-particles to grayscale
                Int = repmat(Int,[1 1 3]);
                Image(~repmat(Particle,[1 1 3]))=Int(~repmat(Particle,[1 1 3]));
            case 7 %%% Particles gray/jet
                %%% Scales Intensity image
                Int=(Int-min(min(Int)))/(max(max(Int))-min(min(Int)));
                %%% Sets particles to scaled jet and rest to gray scale
                Color = [1 1 1 ; jet(max(Particle(:)))];
                Image=reshape(Color(Particle+1,:),size(Int,1),size(Int,2),3).* repmat(Int,[1 1 3]);
        end

        h.Particle_Display_Image.CData = Image;
        h.Particle_Display.XLim = [0.5 size(Image,2)+0.5];
        h.Particle_Display.YLim = [0.5 size(Image,1)+0.5];
        h.Particle_Number.String = ['Particles detected: ' num2str(numel(ParticleData.Regions))];
    else
        h.Particle_Display_Image.CData(:) = 0;
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
Plot_Particle([],[],0:2)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to update method selection and settings %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Method_Update(~,~,mode)
h = guidata(findobj('Tag','Particle'));
LSUserValues(0);

switch h.Particle_Method.Value
    case 1 %%% Simple regionprops
        Method_Regionprops([],[],mode);
    case 2 %%% Regionprops with some shape detection
        Method_Regionprops_Shape([],[],mode);
end






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Here are all the different methods collected in separate functions %%%%
%%% General shape: 
%%% mode == 0 to update settings 
%%% mode == 1 calculating the detection
%%% mode == 2 for saving. Can also be included in mode == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Simple regionprops with thresholding
function Method_Regionprops(~,~,mode)
h = guidata(findobj('Tag','Particle'));
global ParticleData
LSUserValues(0);

%%% Is only called for updating the table/info
if mode == 0
    
    %%% Updates Table
    TableData = {   'Pixel Threshold [Counts]',150;...
                    'Use Non-Particle',0};
    ColumnNames = {'Parameter Name', 'Value'};
    
    h.Particle_Method_Settings.ColumnName = ColumnNames;
    h.Particle_Method_Settings.Data = TableData;
    
    %%% Updates Method information
    h.Particle_Method_Description.String =['This method uses a full stack threshold to calculate a binary map'....
        'Based on this map it uses the matlab "regionprops" function to detect particles. Always works with full stack.'];
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
    Plot_Particle([],[],2)
    return;
end

%%% Actual particle detection and averaging
if mode == 1
    Int = sum(ParticleData.Data.Intensity,3);
    TH = h.Particle_Method_Settings.Data{1,2};
    BitImage = Int > TH;
    Regions = regionprops(BitImage,Int,'Area','PixelIdxList','MaxIntensity','MeanIntensity','PixelValues');
    
    %%% Aborts calculation when no particles were detected
    if isempty(Regions)
        msgbox('No particles detected! Please change threshold.');
        return;
    end
    ParticleData.Regions = Regions;
    ParticleData.Mask = false(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    ParticleData.Particle = zeros(size(ParticleData.Data.Intensity,1),size(ParticleData.Data.Intensity,2));
    %%% Reformats particle information for Phasor calculation
    for i=1:numel(Regions)
        ParticleData.Mask(Regions(i).PixelIdxList) = true;
        ParticleData.Particle(Regions(i).PixelIdxList) = i;
        ParticleData.Regions(i).TotalCounts = Regions(i).MeanIntensity.*Regions(i).Area;
    end
    Plot_Particle([],[],2)
 return;
end

%%% Applies particle averaging and saves it
if mode == 2
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
    g = sum(ParticleData.Data.g.*ParticleData.Data.Intensity,3)./sum(ParticleData.Data.Intensity,3);
    s = sum(ParticleData.Data.s.*ParticleData.Data.Intensity,3)./sum(ParticleData.Data.Intensity,3);
    Intensity = sum(ParticleData.Data.Intensity,3);
    
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
    if ~h.Particle_Method_Settings.Data{2,2}
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
    Mean_LT = sum(ParticleData.Data.Mean_LT.*ParticleData.Data.Intensity,3)./sum(ParticleData.Data.Intensity,3);
    Lines = ParticleData.Data.Lines;
    Pixels = ParticleData.Data.Pixels;
    Imagetime = ParticleData.Data.Imagetime;
    Frames = ParticleData.Data.Frames;
    FileNames = ParticleData.Data.FileNames;
    Type = ParticleData.Data.Type;
    Regions =ParticleData.Regions;
    Path = ParticleData.Data.Path;
    
    save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','Regions');

    
end


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
                    'Frame from:',1;...
                    'Frame to:', 100;...
                    'Min Size [px]:', 10;...
                    'Max Size [px]:', 100;...
                    'Gauss. Filter [Px]' ,2;...
                    'Eccentricity', 0.7;...
                    'Use Non-Particle',0};
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
    Plot_Particle([],[],2)
    return;
end

%%% Actual particle detection and averaging
if mode == 1
    %%% Extracts parameters
    TH = h.Particle_Method_Settings.Data{1,2};
    From = h.Particle_Method_Settings.Data{2,2};
    To = h.Particle_Method_Settings.Data{3,2};
    MinSize = h.Particle_Method_Settings.Data{4,2};
    MaxSize = h.Particle_Method_Settings.Data{5,2};
    Gaus = h.Particle_Method_Settings.Data{6,2};
    Eccent = h.Particle_Method_Settings.Data{7,2};
    
    %%% Adjusts frame range to data
    if To>size(ParticleData.Data.Intensity,3)
        To = size(ParticleData.Data.Intensity,3);
        h.Particle_Method_Settings.Data{3,2} = size(ParticleData.Data.Intensity,3);
    end
    if From > To
        From = 1;
        h.Particle_Method_Settings.Data{3,2} = 1;
    end
    
    %%% Averages image
    Int = sum(ParticleData.Data.Intensity(:,:,From:To),3);
    
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
    Plot_Particle([],[],2)
 return;
end

%%% Applies particle averaging and saves it
if mode == 2
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
    
    From = h.Particle_Method_Settings.Data{2,2};
    To = h.Particle_Method_Settings.Data{3,2};
    %%% Adjusts frame range to data
    if To > size(ParticleData.Data.Intensity,3) || To == 0
        To = size(ParticleData.Data.Intensity,3);
        h.Particle_Method_Settings.Data{3,2} = size(ParticleData.Data.Intensity,3);
    end
    if From > To || From == 0
        From = 1;
        h.Particle_Method_Settings.Data{3,2} = 1;
    end
    
    %%% Uses summed up Image and Phasor
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
    if ~h.Particle_Method_Settings.Data{8,2}
        g(~ParticleData.Mask) = 0;
        s(~ParticleData.Mask) = 0;
        Mean_LT(~ParticleData.Mask) = 0;
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
    Frames = ParticleData.Data.Frames;
    FileNames = ParticleData.Data.FileNames;
    Type = ParticleData.Data.Type;
    Regions =ParticleData.Regions;
    Path = ParticleData.Data.Path;
    
    save(fullfile(PathName,FileName), 'g','s','Mean_LT','Fi','M','TauP','TauM','Intensity','Lines','Pixels','Freq','Imagetime','Frames','FileNames','Path','Type','Regions');

    
end