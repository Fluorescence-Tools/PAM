function Spectral
global UserValues SpectralData
h.SpectralImage = findobj('Tag','SpectralImage');

addpath(genpath(['.' filesep 'bfmatlab']));

if ~isempty(h.SpectralImage) % Creates new figure, if none exists
    figure(h.SpectralImage);
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
h.SpectralImage = figure(...
    'Units','normalized',...
    'Tag','SpectralImage',...
    'Name','Spectral Imaging',...
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
    'CloseRequestFcn',@Close_Filter,...
    'Visible','on');
%%% Sets background of axes and other things
whitebg(Look.Fore);
%%% Changes Pam background; must be called after whitebg
h.SpectralImage.Color=Look.Back;
%%% Remove unneeded items from toolbar
toolbar = findall(h.SpectralImage,'Type','uitoolbar');
toolbar_items = findall(toolbar);
delete(toolbar_items([2:7 9 13:17]));

%%% Loading menues
h.Load = uimenu(...
    'Parent',h.SpectralImage,...
    'Label','Load...');

h.Load_Data = uimenu(...
    'Parent',h.Load,...
    'Label','data directly',...
    'Callback',{@Load_Data,1});

h.Load_Database = uimenu(...
    'Parent',h.Load,...
    'Label','data to database',...
    'Callback',{@Load_Data,2});

h.Load_Database = uimenu(...
    'Parent',h.Load,...
    'Label','species data',...
    'Callback',{@Load_Data,4});

h.Text = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image Plot and Display %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Plot panel 1
h.Plot_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.005 0.505 0.29 0.49]);

%%% Main Image plot
h.Image_Plot = axes(...
    'Parent',h.Plot_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.01 0.98 0.98]);
h.Spectral_Image = image(zeros(1,1,3));
h.Image_Plot.DataAspectRatio = [1 1 1];
h.Image_Plot.XTick = [];
h.Image_Plot.YTick = [];

%%% Plot panel 2
h.Phasor_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.305 0.505 0.29 0.49]);

%%% Main Image plot
h.Phasor_Plot = axes(...
    'Parent',h.Phasor_Panel,...
    'Units','normalized',...
    'Position',[0.01 0.01 0.98 0.98]);
h.Phasor_Image = image(zeros(1,1,3));
h.Phasor_Plot.DataAspectRatio = [1 1 1];
h.Phasor_Plot.XTick = [];
h.Phasor_Plot.YTick = [];

%%% Image display panel
h.Display_Panel = uibuttongroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0.605 0.505 0.39 0.49]);


h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.92 0.4 0.06],...
    'String','Image Settings:');

%%%% Colormap selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.82 0.2 0.06],...
    'String','Colormap:');

h.Colormap = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.2 0.82 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String',{'Gray','Jet','Hot','RGB'});


%%%% Data to be plotted selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.82 0.2 0.06],...
    'String','Plotted data:');


h.PlottedData = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','popup',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.6 0.82 0.38 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String',{'Full'});


%%%% Frame Selection
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.72 0.2 0.06],...
    'String','Frame:');

h.Frame_Edit = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback',{@Frame},...
    'Position',[0.2 0.72 0.18 0.06],...
    'String','0');

h.Frame_Slider = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','slider',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.72 0.58 0.06]);

h.Frame_Listener=addlistener(h.Frame_Slider,'Value','PostSet',@Frame);

%%%% Scaling settings
h.Text{end+1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','text',...
    'Units','normalized',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.01 0.62 0.2 0.06],...
    'String','Scale Image:');

h.Autoscale = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','checkbox',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.2 0.62 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'Value',1,...
    'String','Autoscale');

h.Scale{1} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.4 0.62 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String','0');

h.Scale{2} = uicontrol(...
    'Parent',h.Display_Panel,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.6 0.62 0.18 0.06],...
    'Callback',{@Plot_Spectral,1},...
    'String','100');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tabs for Species and Filters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Main_Tabs = uitabgroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'Position',[0.005 0.005 0.59 0.49]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Species %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Species_Tab = uitab(...
    'Parent',h.Main_Tabs,...
    'Title','Species',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],...
    'Units','normalized');

%%% List containing the species
h.Species_List = uicontrol(...
    'Parent',h.Species_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'FontSize',12,...
    'String',{'Data'},...
    'Value',1,...
    'Max',5,...
    'KeyPressFcn',{@Species_Callback},...
    'Callback',{@Plot_Spectral,2},...
    'Position',[0.01 0.01 0.28 0.98],...
    'Style','listbox');

%%% Axis for plotting species spectra
h.Species_Plot = axes(...
    'Parent',h.Species_Tab,...
    'Units','normalized',...
    'Box','off',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'FontSize',12,...
    'LineWidth', Look.AxWidth,...
    'YGrid','on',...
    'XGrid','on',...
    'Position',[0.36 0.14 0.61 0.78]);

h.Species_Plot.YLabel.String = 'Frequency';
h.Species_Plot.YLabel.Color = Look.Fore;

h.Species_Plot.XLabel.String = 'Spectral channel';
h.Species_Plot.XLabel.Color = Look.Fore;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Filters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Filter_Tab = uitab(...
    'Parent',h.Main_Tabs,...
    'Title','Filters',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],...
    'Units','normalized');

%%% List containing the species
h.Filter_List = uicontrol(...
    'Parent',h.Filter_Tab,...
    'Units','normalized',...
    'BackgroundColor', Look.List,...
    'ForegroundColor', Look.ListFore,...
    'FontSize',12,...
    'String',{'Full'},...
    'Value',1,...
    'Max',5,...
    'Callback',{@Plot_Spectral,[1,3]},...
    'KeyPressFcn',{@Filter_Callback},...
    'Position',[0.01 0.01 0.28 0.78],...
    'Style','listbox');

%%% Axis for plotting species spectra
h.Filter_Plot = axes(...
    'Parent',h.Filter_Tab,...
    'Units','normalized',...
    'Box','off',...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'FontSize',12,...
    'LineWidth', Look.AxWidth,...
    'YGrid','on',...
    'XGrid','on',...
    'Position',[0.36 0.14 0.61 0.78]);

h.Filter_Plot.YLabel.String = 'Weight';
h.Filter_Plot.YLabel.Color = Look.Fore;

h.Filter_Plot.XLabel.String = 'Spectral channel';
h.Filter_Plot.XLabel.Color = Look.Fore;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tabs for controls and processes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Control_Tabs = uitabgroup(...
    'Parent',h.SpectralImage,...
    'Units','normalized',...
    'Position',[0.605 0.005 0.39 0.49]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Species and Filter Generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.SF_Tab = uitab(...
    'Parent',h.Control_Tabs,...
    'Title','Species and Filters',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],...
    'Units','normalized');

%%% Controls to create simple rectangular filters
h.Simple_Button = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Calc_Filter,1},...
    'Position',[0.02 0.92 0.4 0.06],...
    'String','Create simple filter');

h.Simple_Range = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.43 0.92 0.15 0.06],...
    'String','1:10');

%%% Button to save selected filters
h.Calc_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Calc_Filter,2},...
    'Position',[0.02 0.82 0.4 0.06],...
    'String','Create filters');

%%% Button to save selected filters
h.Save_Homo_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Save_Filtered,1},...
    'Position',[0.02 0.22 0.46 0.12],...
    'String','Save filtered data');

%%% Button to save selected filters
h.Save_Hetero_Filter = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','pushbutton',...
    'Units','normalized',...
    'FontSize',14,...
    'HorizontalAlignment','center',...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Callback', {@Save_Filtered,2},...
    'Position',[0.02 0.02 0.46 0.12],...
    'String','Save spatially resolved');


h.Spatial_Average_Type = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','popupmenu',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.5 0.02 0.34 0.07],...
    'String',{'No averaging', 'Moving average','Gaussian','Disk'});

h.Spatial_Average_Size = uicontrol(...
    'Parent',h.SF_Tab,...
    'Style','edit',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Position',[0.86 0.02 0.12 0.06],...
    'String','3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tab for Database %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h.Database_Tab = uitab(...
    'Parent',h.Control_Tabs,...
    'Title','Database',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', [0 0 0],....
    'Units','normalized');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Saves guidata and initializes global variable %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SpectralData.Data = [];
SpectralData.Species = struct('Name',{'Data'},'Data',{ones(1,1,30,1)});
SpectralData.Filter = struct('Name',{'Full'},'Data',{ones(1,1,30,1)},'Species',1);

h.SpeciesPlots = [];
h.FilterPlots = [];

guidata(h.SpectralImage,h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for closing and deleting global variables
%%% Will be removed later
function Close_Filter(Obj,~)
clear global -regexp SpectralData
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
Particle = findobj('Tag','Particle');

if isempty(Pam) && isempty(FCSFit) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(TauFit) && isempty(BurstBrowser) && isempty(PhasorTIFF)  && isempty(Phasor) && isempty(Particle)
    clear global -regexp UserValues PathToApp
end
delete(Obj);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for loading data and species
%%% mode 1: load data
%%% mode 2: load data into database
%%% mode 3: not used yet; might be used for automatic loading from database
%%% mode 4: load species data
function Load_Data(~,~,mode)
global SpectralData
h = guidata(findobj('Tag','SpectralImage'));

switch mode
    case 1 %%% Normal data loading
        %%%% This is a test version and will be adjusted for the final
        %%%% version
        
        %% Get filenames
        [FileName,Path] = uigetfile({'*.tif'}, 'Load TIFF data', 'MultiSelect', 'on');
        
        if all(Path==0)
            return
        end
        
        %%% Transforms FileName into cell array
        if ~iscell(FileName)
            FileName={FileName};
        end
        
        SpectralData.Data = [];
        
        %% Loads all frames
        SpectralData.Data=uint16.empty(0,0,0);
        for i=1:numel(FileName)
            Info=imfinfo(fullfile(Path,FileName{i}));
            
            %%% Automatically updates image properties
            TIFF_Handle = Tiff(fullfile(Path,FileName{i}),'r'); % Open tif reference
            Frames = 1:numel(Info);
            
            for j=Frames
                TIFF_Handle.setDirectory(j);
                SpectralData.Data(:,:,end+1) = TIFF_Handle.read();
            end
            TIFF_Handle.close(); % Close tif reference
        end
        
        SpectralData.Path = Path;
        SpectralData.FileName = FileName{1};
        
        SpectralData.Data = reshape(SpectralData.Data,size(SpectralData.Data,1),size(SpectralData.Data,2),40,[]);
        
        SpectralData.Species(1).Data = sum(sum(double(sum(SpectralData.Data,4)),2),4);
        SpectralData.Species(1).Data = SpectralData.Species(1).Data/max(SpectralData.Species(1).Data(:));
        SpectralData.Filter(1).Data = ones(1,1,size(SpectralData.Data,3),1);
        
        %%% Adjusts slider and frame range
        h.Frame_Slider.Min=0;
        h.Frame_Slider.Max = size(SpectralData.Data,4);
        h.Frame_Slider.SliderStep=[1./size(SpectralData.Data,4), 10/size(SpectralData.Data,4);];
        h.Frame_Slider.Value=0;
        h.Frame_Edit.String = '0';
        
        %%% Recalculates filters for current data
        for i=1:numel(SpectralData.Filter)
            h.Filter_List.Value = i;
            if any(SpectralData.Filter(i).Species ~= 1)
                Calc_Filter([],[],2,SpectralData.Filter(i).Species)
            end
        end
        
        Plot_Spectral([],[],0);
        
    case 2 %%% Loads files into database
        
        
    case 4 %%% Loads species
        %%%% This is a test version and will be adjusted for the final
        %%%% version
        
        [FileName,Path] = uigetfile({'*.tif'}, 'Load TIFF data', 'MultiSelect', 'on');
        
        if all(Path==0)
            return
        end
        
        %%% Transforms FileName into cell array
        if ~iscell(FileName)
            FileName={FileName};
        end
        
        
        %% Loads all frames
        
        for i=1:numel(FileName)
            Info=imfinfo(fullfile(Path,FileName{i}));
            
            %%% Automatically updates image properties
            TIFF_Handle = Tiff(fullfile(Path,FileName{i}),'r'); % Open tif reference
            Frames = 1:numel(Info);
            Data=uint16.empty(0,0,0);
            for j=Frames
                TIFF_Handle.setDirectory(j);
                Data(:,:,end+1) = TIFF_Handle.read();
            end
            TIFF_Handle.close(); % Close tif reference
            Data = reshape(Data,size(Data,1),size(Data,2),40,[]);
            
            SpectralData.Species(end+1).Data = reshape((sum(sum(sum(Data,4),2),1)),1,1,[],1);
            SpectralData.Species(end).Data = SpectralData.Species(end).Data./max(SpectralData.Species(end).Data(:));
            SpectralData.Species(end).Name = FileName{i}(1:end-4);
            h.Species_List.String{end+1} = SpectralData.Species(end).Name;
            
        end
        
        
        Plot_Spectral([],[],2);
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for displaying data
function Plot_Spectral(~,~,mode)
global SpectralData
h = guidata(findobj('Tag','SpectralImage'));

%%% Updates everything
if isempty(mode) || any(mode==0)
    mode = 1:3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates Image plot
if any(mode == 1) && ~isempty(SpectralData.Data)
    FilterMode = h.PlottedData.Value;
    ColormapMode = h.Colormap.Value;
    
    if ColormapMode <4 %%% Plots one selected filter with colormap
        
        Filter = single(SpectralData.Filter(FilterMode).Data);
        
        %%% Adjusts sizes of filter
        if size(Filter,3) < size(SpectralData.Data,3) %%% Extends filter with zeros to fit data
            Filter(1,1,size(SpectralData.Data,3),1) = 0;
        elseif size(Filter,3) > size(SpectralData.Data,3) %%% Shortens filter at the end to fit data
            Filter(1,1,size(SpectralData.Data,3)+1:end,1) = [];
        end
        
        %%% Calculates filter weightes intensity
        Frame = str2double(h.Frame_Edit.String);
        if Frame == 0 %%% Sum over time
            
            %%% Applies filter weighting
            Image = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
            %%% Summs over spectral information
            Image = squeeze(sum(sum(Image,3),4));
            
        else %%% Single Frame
            Image = single(SpectralData.Data(:,:,:,Frame)) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, 1);
            %%% Summs over spectral information
            Image = squeeze(sum(Image,3));
        end
        
        %%% Plots Image
        h.Spectral_Image.CData = Image;
        h.Spectral_Image.CDataMapping = 'scaled';
        
        h.Image_Plot.XLim = [0.5 size(h.Spectral_Image.CData,2)+0.5];
        h.Image_Plot.YLim = [0.5 size(h.Spectral_Image.CData,1)+0.5];
        %%% Scale image
        if h.Autoscale.Value %%% Autoscaling
            h.Image_Plot.CLimMode = 'auto';
        else %%% Manual scaling
            Min = str2double(h.Scale{1}.String);
            Max = str2double(h.Scale{2}.String);
            if isempty(Min)
                Min = 0;
                h.Scale{1}.String = '0';
            end
            if isempty(Max) || Max <= Min
                Max = Min+1;
                h.Scale{2}.String = num2str(Max);
            end
            h.Image_Plot.CLim = [Min Max];
        end
        
        %%% Set image colormap
        switch ColormapMode
            case 1
                Map = 'gray';
            case 2
                Map = 'jet';
            case 3
                Map = 'hot';
        end
        colormap(h.Image_Plot,Map);
        
    elseif ColormapMode == 4 %%% Plots up to three filters in RGB
        %%% Plots Image
        %h.Spectral_Image.CData = repmat(Image/max(Image(:)),1,1,3);
        %h.Spectral_Image.CDataMapping = 'direct';
    end
    
    
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates Species plot
if any(mode == 2)
    Sel = h.Species_List.Value;
    for i=1:numel(SpectralData.Species)
        
        %%% Updates plot data
        if numel(h.SpeciesPlots) < i
            h.SpeciesPlots{i} = plot(h.Species_Plot, squeeze(SpectralData.Species(i).Data));
        else
            h.SpeciesPlots{i}.YData = SpectralData.Species(i).Data;
        end
        
        %%% Shows only selected species
        if any(i==Sel)
            h.SpeciesPlots{i}.Visible = 'on';
        else
            h.SpeciesPlots{i}.Visible = 'off';
        end
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Updates Filter plot
if any(mode == 3)
    Sel = h.Filter_List.Value;
    Min = -0.05;
    Max = 1.05;
    for i=1:numel(SpectralData.Filter)
        
        %%% Updates plot data
        if numel(h.FilterPlots) < i
            h.FilterPlots{i} = plot(h.Filter_Plot, squeeze(SpectralData.Filter(i).Data), 'LineStyle','--', 'LineWidth',2);
        else
            h.FilterPlots{i}.YData = SpectralData.Filter(i).Data;
        end
        
        %%% Shows only selected species
        if any(i==Sel)
            h.FilterPlots{i}.Visible = 'on';
            
            Min = min([h.FilterPlots{i}.YData-0.05 Min]);
            Max = max([h.FilterPlots{i}.YData+0.05 Max]);
        else
            h.FilterPlots{i}.Visible = 'off';
        end
    end
    
    h.Filter_Plot.YLim = [Min Max];
    
    
end
guidata(h.SpectralImage,h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for updating frame
function Frame(obj,e)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

if obj == h.Frame_Edit %%% Editbox was changed
    Frame=str2double(h.Frame_Edit.String);
    
    %%% Set Frame to 0 if it was an invalid input
    if isempty(Frame) || Frame <0
        Frame = 0;
        h.Frame_Edit.String = str2double(Frame);
    end
    %%% rounds Frame to nearest integer
    if mod(Frame,1)~=0
        Frame = round(Frame);
        h.Frame_Edit.String = str2double(Frame);
    end
    %%% Sets Frame into bounds
    if Frame > size(SpectralData.Data,4)
        Frame = size(SpectralData.Data,4);
        h.Frame_Edit.String = str2double(Frame);
    end
    h.Frame_Slider.Value = Frame;
    
    
elseif strcmp(e.EventName, 'PostSet') && e.AffectedObject == h.Frame_Slider %%% Slider was changed
    
    Frame=h.Frame_Slider.Value;
    
    %%% rounds Frame to nearest integer
    if mod(Frame,1)~=0
        Frame = round(Frame);
        h.Frame_Slider.Value = Frame;
    end
    %%% Sets Frame into bounds
    if Frame > size(SpectralData.Data,4)
        Frame = size(SpectralData.Data,4);
        h.Frame_Slider.Value = Frame;
    end
    h.Frame_Edit.String = num2str(Frame);
end
Plot_Spectral([],[],1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for the interaction with the filter list
function Filter_Callback(obj, e)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

event = 'nothing';
%%% Determines action
switch e.EventName
    case 'KeyPress' %%% Event was executed via key press
        switch e.Key
            case {'delete','backspace'} %%% delete filter
                event = 'delete';
            case 'r' %%% rename filter
                event = 'rename';
        end
        
end

%%% Executes action
switch event
    case 'nothing'
        return;
    case 'delete' %%% delete filter
        %%% Selected entries
        if isfield(e, 'Selected') %%% Species was deleted
            Sel = e.Selected;
        else %%% Filter was deleted
            Sel = obj.Value;
        end
        
        %%% ignores the first entry
        Sel(Sel==1)=[];
        
        %%% Stops if ony first was selected
        if isempty(Sel)
            return;
        end
        
        %%% Deletes filter
        SpectralData.Filter(Sel) = [];
        %%% Removes filter from list
        obj.String(Sel) = [];
        %%% Removes plot selections
        h.PlottedData.String(Sel)=[];
        %%% Deletes filter plots
        for i = Sel
            if numel(h.FilterPlots) >= i && isvalid(h.FilterPlots{i})
                delete(h.FilterPlots{i});
            end
        end
        %%% Removes deleted plots
        for i= numel(h.FilterPlots):-1:1
            if ~isvalid(h.FilterPlots{i})
                h.FilterPlots(i)=[];
            end
        end
        guidata(h.SpectralImage,h);
        
        %%% Sets list selection to first
        obj.Value = 1;
        %%% Re-sets selected filter
        if any(h.PlottedData.Value == Sel)
            h.PlottedData.Value = 1;
        elseif any(h.PlottedData.Value > Sel)
            h.PlottedData.Value = h.PlottedData.Value - sum(h.PlottedData.Value > Sel);
        end
        Plot_Spectral([],[],[1,3]);
        
    case 'rename'
        Sel = obj.Value;
        %%% ignores the first entry
        Sel(Sel==1)=[];
        %%% only applies to first selected entry
        if numel(Sel) == 0
            return;
        elseif numel(Sel) > 1
            Sel = Sel(1);
        end
        
        Name = inputdlg('Pleas enter new filter name','Rename filter',1,{SpectralData.Filter(Sel).Name});
        if ~isempty(Name)
            SpectralData.Filter(Sel).Name = Name{1};
            h.Filter_List.String{Sel} = Name{1};
            h.PlottedData.String{Sel} = Name{1};
        end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for the interaction with the filter list
function Species_Callback(obj, e)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

event = 'nothing';
%%% Determine action
switch e.EventName
    case 'KeyPress' %%% key was pressed
        switch e.Key
            case {'delete' 'backspace'} %%% delete species
                event = 'delete';
            case 'r'
                event = 'rename'; %%% rename species
            case 'f'
                event = 'filters'; %%% calculates filters
        end
end

%%% Execute action
switch event
    case 'nothing'
        return;
    case 'delete' %%% Deletes species
        %%% Selected entries
        Sel = obj.Value;
        
        %%% ignores the first entry
        Sel(Sel==1)=[];
        
        %%% Stops if ony first was selected
        if isempty(Sel)
            return;
        end
        
        %%% Deletes all assisiated filters
        Filter = [];
        for i = 1:numel(SpectralData.Filter)
            if ~isempty(intersect(SpectralData.Filter(i).Species,Sel))
                Filter = [Filter i];
            end
        end
        if ~isempty(Filter)
            evt.EventName = 'KeyPress' ;
            evt.Selected = Filter;
            evt.Key = 'delete';
            Filter_Callback(h.Filter_List, evt)
        end
        
        
        %%% Deletes filter
        SpectralData.Species(Sel) = [];
        %%% Removes species from list
        obj.String(Sel) = [];
        %%% Deletes species plots
        for i = Sel
            if numel(h.SpeciesPlots) >= i && isvalid(h.SpeciesPlots{i})
                delete(h.SpeciesPlots{i});
            end
        end
        %%% Removes deleted plots
        for i= numel(h.SpeciesPlots):-1:1
            if ~isvalid(h.SpeciesPlots{i})
                h.SpeciesPlots(i)=[];
            end
        end
        guidata(h.SpectralImage,h);
        
        %%% Sets list selection to first
        obj.Value = 1;
        Plot_Spectral([],[],2);
    case 'rename' %%% Renames species
        Sel = obj.Value;
        %%% ignores the first entry
        Sel(Sel==1)=[];
        %%% only applies to first selected entry
        Sel = Sel(1);
        
        Name = inputdlg('Pleas enter new species name','Rename species',1,{SpectralData.Species(Sel).Name});
        if ~isempty(Name)
            SpectralData.Species(Sel).Name = Name{1};
            h.Species_List.String{Sel} = Name{1};
        end
    case 'filters' %%% Calculates new filters
        Calc_Filter([],[],2)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function for creating new filters
function Filter = Calc_Filter(~,~,mode,Sel,Spectrum)

global SpectralData
switch mode
    case 1 %%% Create a simple rectangular filter based on the imput
        h = guidata(findobj('Tag','SpectralImage'));
        %%% Bins to be used
        Bins = round(str2num(h.Simple_Range.String));
        %%% Removes invalid bins
        Bins(Bins<0 | Bins > numel(SpectralData.Filter(1).Data)) = [];
        
        %%% Creates new empty filter
        SpectralData.Filter(end+1).Data = zeros(1,1,numel(SpectralData.Filter(1).Data),1);
        %%% Set bins to 1
        SpectralData.Filter(end).Data(Bins) = 1;
        %%% Creates name for filter
        SpectralData.Filter(end).Name = ['Simple_' num2str(min(Bins)) 'to' num2str(max(Bins))];
        SpectralData.Filter(end).Species = 1;
        
        h.Filter_List.String{end+1} = SpectralData.Filter(end).Name;
        h.PlottedData.String{end+1} = SpectralData.Filter(end).Name;
        
        Plot_Spectral([],[],[1 3]);
    case 2 %%% calculate filter for current data
        h = guidata(findobj('Tag','SpectralImage'));
        %%% Take input species or selected
        if ~exist('Sel','var') || isempty(Sel)
            New = 1;
            Sel = h.Species_List.Value;
        else
            New = 0;
        end
        %%% Stop, if only one species is selected
        if numel(Sel)<2
            return;
        end
        
        %%% Calculates summed up spectrum of current data      
        Spectrum = squeeze(sum(sum(double(sum(SpectralData.Data,4)),2),1));
        
        diag_Spectrum = zeros(numel(Spectrum));
        for i = 1:numel(Spectrum)
            diag_Spectrum(i,i) = 1./Spectrum(i);
        end
        %%% Sets no-photon bins to 0
        diag_Spectrum(isinf(diag_Spectrum)) = 0;
        
        Species = [];
        for i = Sel
            Species = [Species, squeeze(SpectralData.Species(i).Data./sum(SpectralData.Species(i).Data))]; % re-normalize here just in case
        end
        Filter = ((Species'*diag_Spectrum*Species)^(-1)*Species'*diag_Spectrum)';
        Filter(isinf(Filter)) = 0;
        
        if New %%% Updates data of old filters or creates new filters
            for i=1:numel(Sel)
                SpectralData.Filter(end+1).Data(1,1,:,1) = Filter(:,i);
                SpectralData.Filter(end).Name = SpectralData.Species(Sel(i)).Name;
                SpectralData.Filter(end).Species = [Sel(i) Sel(Sel~=Sel(i))];
                h.Filter_List.String{end+1} = SpectralData.Filter(end).Name;
                h.PlottedData.String{end+1} = SpectralData.Filter(end).Name;
            end
        else
            SpectralData.Filter(h.Filter_List.Value).Data(1,1,:,1) = Filter(:,1);
        end
    case 3 %%% Spatially resolved filter calculation
        
        %%% Calculates summed up spectrum of current data
        diag_Spectrum = zeros(numel(Spectrum));
        for i = 1:numel(Spectrum)
            diag_Spectrum(i,i) = 1./Spectrum(i);
        end
        %%% Sets no-photon bins to 0
        diag_Spectrum(isinf(diag_Spectrum)) = 0;
        
        Species = [];
        for i = Sel
            Species = [Species, squeeze(SpectralData.Species(i).Data./sum(SpectralData.Species(i).Data))]; % re-normalize here just in case
        end
        Filter = ((Species'*diag_Spectrum*Species)^(-1)*Species'*diag_Spectrum)';
        Filter(isinf(Filter)) = 0;
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that applies filters and saves the data
function Save_Filtered (~,~,mode)
h = guidata(findobj('Tag','SpectralImage'));
global SpectralData

Sel = h.Filter_List.Value;
Path = uigetdir(SpectralData.Path, 'Select folder to save filtered TIFFs');
if all(Path==0)
    return;
end
for i=1:numel(Sel)
    
    Full = uint16(squeeze(sum(SpectralData.Data,3)));
    
    switch mode
        case 1 %%% Apply uniform filters           
            %%% Applies filter
            Filter = single(SpectralData.Filter(Sel(i)).Data);
            Stack = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
            Stack = squeeze(sum(Stack,3));
            
        case 2 %%% Apply pixel-by pixel filters            
            %%% Initializes data cells
            Stack = zeros(size(SpectralData.Data,1),size(SpectralData.Data,2),size(SpectralData.Data,4));
            
            %%% Checks, if simple filter was used
            if numel(SpectralData.Filter(Sel(i)).Species)>1
                %%% Summs up all frames
                Data = double(sum(SpectralData.Data,4));
                
                %%% Applies spatial averaging to the data
                if h.Spatial_Average_Type.Value >1 && str2double(h.Spatial_Average_Size)>1
                    switch h.Spatial_Average_Type.Value
                        case 2 %%% Moving average
                            F = fspecial('average',round(str2double(h.Spatial_Average_Size)));
                        case 3 %%% Gaussian
                            F = fspecial('gaussian',round(str2double(h.Spatial_Average_Size)));
                        case 4 %%% Disk
                            F = fspecial('disk',round(str2double(h.Spatial_Average_Size)));
                    end
                    Data = imfilter(Data,F,'replicate');
                end
                
                %%% Recalculates filter for each line
                %%% This calculates the filters for each filter, although
                %%% each one is used at least twice.
                %%% I will try to remove this redundancy at some point
                for j=1:size(SpectralData.Data,1)
                    for k=1:size(SpectralData.Data,2)
                        Filter = Calc_Filter([],[],3,SpectralData.Filter(Sel(i)).Species,squeeze(Data(j,k,:)));
                        Filter = reshape(Filter(:,1),1,1,[],1);
                        Stack(j,k,:) = squeeze(sum(double(SpectralData.Data(j,k,:,:)) .* repmat(Filter,[1,1,1,size(Stack,4)]),3));
                    end
                end
                
            else %%% Applies homogeneous filter, if a simple filter was used
                Filter = SpectralData.Filter(Sel(i)).Data;
                Stack = single(SpectralData.Data) .* repmat(Filter, size(SpectralData.Data,1),size(SpectralData.Data,2), 1, size(SpectralData.Data,4));
                Stack = squeeze(sum(Stack,3));
            end
            
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Saves the data
    
    %%% Rescales and reshapes weighed stack
    Min = min(Stack(:));
    Max = max(Stack(:));
    Stack=uint16((Stack-Min)./(Max-Min)*2^16);
    
    %%% Adjusts filename
    switch mode
        case 1
            File=fullfile(Path,[SpectralData.FileName(1:end-4) '_' SpectralData.Filter(Sel(i)).Name '.tif']);
        case 2
            File=fullfile(Path,[SpectralData.FileName(1:end-4) '_' SpectralData.Filter(Sel(i)).Name '_SR.tif']);
    end
    
    %%% Creates info data
    Tagstruct.ImageLength = size(Stack,2);
    Tagstruct.ImageWidth = size(Stack,1);
    Tagstruct.Compression = 5; %1==None; 5==LZW
    Tagstruct.SampleFormat = 1; %UInt
    Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
    Tagstruct.SamplesPerPixel = 1;
    Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    Tagstruct.ImageDescription = ['Type: ' '10' '\n',...
        'FrameTime [s]: 0.1 \n',...
        'LineTime [ms]: 1 \n',...
        'PixelTime [us]: 10 \n',...
        'PixelSize [nm]: 50 \n',...
        'RLICS_Scale: ' num2str(Max-Min) '\n',...
        'RLICS_Offset: ' num2str(Min) '\n'];
    TIFF_handle = Tiff(File, 'w');
    TIFF_handle.setTag(Tagstruct);
    
    %%% Writes unfilterd data to the first frames
    for j=1:size(Full,3)
        TIFF_handle.write(Full(:,:,j));
        TIFF_handle.writeDirectory();
        TIFF_handle.setTag(Tagstruct);
    end
    
    %%% Writes filtered data to the last frames
    for j=1:size(Stack,3)
        TIFF_handle.write(Stack(:,:,j));
        if j<size(Stack,3)
            TIFF_handle.writeDirectory();
            TIFF_handle.setTag(Tagstruct);
        end
    end
    TIFF_handle.close()
    
end

