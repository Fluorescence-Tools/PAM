function PCFAnalysis
global UserValues PCFData
h.PCF=findobj('Tag','PCF');

if ~isempty(h.PCF) % Gives focus to PCFAnalysis figure if it already exists
    figure(h.PCF); return;
end     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Disables negative values for log plot warning
    warning('off','MATLAB:Axes:NegativeDataInLogAxis');
    %%% Loads user profile    
    LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;    
    %%% Generates the PCF figure
    
    h.PCF = figure(...
        'Units','normalized',...
        'Tag','PCF',...
        'Name','Pair Correlation analysis',...
        'NumberTitle','off',...
        'Menu','none',...
        'defaultUicontrolFontName','Times',...
        'defaultAxesFontName','Times',...
        'defaultTextFontName','Times',...
        'Toolbar','figure',...
        'UserData',[],...
        'OuterPosition',[0.01 0.1 0.98 0.9],...
        'CloseRequestFcn',@Close_PCF,...
        'Visible','on');  
    
    %%% Sets background of axes and other things
    whitebg(Look.Axes);
    %%% Changes Pam background; must be called after whitebg
    h.PCF.Color=Look.Back;
    %%% Initializes cell containing text objects (for changes between mac/pc
    h.Text={};
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    %%% File menu with loading, saving and exporting functions
    h.LoadPCF = uimenu(...
        'Parent',h.PCF,...
        'Tag','LoadPCF',...
        'Label','Load PCF files');
    h.LoadNew = uimenu(...
        'Parent',h.LoadPCF,...
        'Tag','LoadNew',...
        'Label','Load new files',...
        'Callback', {@Load_PCF,1});
    h.LoadAdd = uimenu(...
        'Parent',h.LoadPCF,...
        'Tag','LoadAdd',...
        'Label','Add files',...
        'Callback', {@Load_PCF,0});
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%% Carpet Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Carpet Panel
    h.Carpet_Panel = uibuttongroup(...
        'Parent',h.PCF,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.005 0.005 0.4925 0.99]); 
    %% Top Pannel
    %%% File selection menu
    h.PCF_File = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','popupmenu',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.005 0.965, 0.99 0.03],...
        'Callback',{@Select_Bins,1},...
        'String','Nothing Loaded');   
    %%% Text for distance selection
    h.Text{end+1} = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','Text',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Position',[0.005 0.935, 0.05 0.02],...
        'String','Dist:');        
    %%% Editbox for distance selection
    h.PCF_Dist_Edit = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.055 0.935, 0.04 0.02],...
        'Callback',{@Change_Dist,2},...
        'Enable','off',...
        'String','0');
    %%% Slider for distance selection
    h.PCF_Dist_Slider = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','slider',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Min',0,...
        'Max',1,...
        'SliderStep',[1 1],...
        'Value',0,...
        'Enable','off',...
        'Position',[0.1 0.935, 0.1 0.02],...
        'Callback',{@Change_Dist,1},...
        'String','0');
    
    %%% Text for time selection
    h.Text{end+1} = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','Text',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Position',[0.21 0.935, 0.07 0.02],...
        'String','Points:');        
    %%% Editbox for distance selection
    h.Carpet_Min_Time = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.285 0.935, 0.05 0.02],...
        'Callback',{@Update_Plots,[1,2]},...
        'Enable','off',...
        'String','2');
    %%% Editbox for distance selection
    h.Carpet_Max_Time = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.34 0.935, 0.05 0.02],...
        'Callback',{@Update_Plots,[1,2]},...
        'Enable','off',...
        'String','100');

    %%% Checkbox to switch between Cotrelation and Intensity
    h.Text{end+1} = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','text',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Position',[0.4 0.935, 0.25 0.02],...
        'String','Intensity rebinning factor:');
    %%% Editbox for Intensity rebinning
    h.Carpet_Intensity_Rebin = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.65 0.935, 0.07 0.02],...
        'Callback',{@Update_Plots,[1,2]},...
        'Enable','off',...
        'String','200');    
    %% Context menues
    %%% Contexmenu for Correlation Carpet
    h.Carpet_Menu = uicontextmenu;
    %%% Menu for normalizing carpet
    h.Carpet_Normalize = uimenu(...
        'Parent',h.Carpet_Menu,...
        'Label','Normalize',...
        'Callback', {@Carpet_Callback,1});
    %%% Menu for carpet ploting selection
    h.Carpet_PlotStyle = uimenu(...
        'Parent',h.Carpet_Menu,...
        'Label','Plot...');
    %%% Menu for plotting correlation carpet
    h.Carpet_Cor = uimenu(...
        'Parent',h.Carpet_PlotStyle,...
        'Label','Correlations',...
        'Checked','on',...
        'Callback', {@Carpet_Callback,2});   
    %%% Menu for plotting intensity carpet
    h.Carpet_Int = uimenu(...
        'Parent',h.Carpet_PlotStyle,...
        'Label','Intensities',...
        'Callback', {@Carpet_Callback,3});
    %%% Menu for plotting arrival time carpet
    h.Carpet_MI = uimenu(...
        'Parent',h.Carpet_PlotStyle,...
        'Label','Mean arrival times',...
        'Callback', {@Carpet_Callback,4});
    %%% Selection for exporting carpet
    h.Carpet_Export2Fig = uimenu(...
        'Parent',h.Carpet_Menu,...
        'Label','Export to figure:');
    %%% Menu for exporting full carpet
    h.Carpet_Full2Fig = uimenu(...
        'Parent',h.Carpet_Export2Fig,...
        'Label','Full carpet',...
        'Callback', {@Carpet_Callback,5});
    %%% Menu for exporting selected carpet
    h.Carpet_Sel2Fig = uimenu(...
        'Parent',h.Carpet_Export2Fig,...
        'Label','Selected carpet',...
        'Callback', {@Carpet_Callback,5});
    
    %%% Contexmenu for Mean Intensity/Arrival time histogram
    h.Mean_Menu = uicontextmenu;
    %%% Menu for mean ploting selection
    h.Mean_PlotStyle = uimenu(...
        'Parent',h.Mean_Menu,...
        'Label','Plot...');
    %%% Menu for plotting mean intensity 
    h.Mean_Int = uimenu(...
        'Parent',h.Mean_PlotStyle,...
        'Label','Mean intensity',...
        'Checked','on',...
        'Callback', {@Intensity_Callback,1});
    %%% Menu for plotting mean arrival time
    h.Mean_MI = uimenu(...
        'Parent',h.Mean_PlotStyle,...
        'Label','Mean arrival time',...
        'Callback', {@Intensity_Callback,2});
    %%% Menu for Exporting Intenity carpet
    h.Mean_Export2Fig = uimenu(...
        'Parent',h.Mean_Menu,...
        'Label','Export intensity carpet');
    %%% Menu for Exporting full intensity
    h.Mean_Full2Fig = uimenu(...
        'Parent',h.Mean_Export2Fig,...
        'Label','Full carpet',...
        'Callback', {@Intensity_Callback,3});
    %%% Menu for Exporting selected intensity
    h.Mean_Sel2Fig = uimenu(...
        'Parent',h.Mean_Export2Fig,...
        'Label','Selected carpet',...
        'Callback', {@Intensity_Callback,3});
    %% Axes and plots
    %%% Axes for Carpet
    h.Carpet_Axes = axes(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...      
        'Position',[0.08 0.45 0.91 0.45],...
        'Box','off');
    h.Plot.Carpet = imagesc(zeros(1,1,1),...
            'Parent',h.Carpet_Axes);
    h.Carpet_Axes.XLabel.String='Bin';
    h.Carpet_Axes.XLabel.Color=Look.Fore;
    h.Carpet_Axes.YLabel.Color=Look.Fore;    
    h.Carpet_Axes.Box = 'off';
    h.Carpet_Axes.XTick = [];
    h.Carpet_Axes.XAxisLocation = 'top';
    h.Carpet_Axes.XColor = Look.Fore;
    h.Carpet_Axes.YColor = Look.Fore;
    colormap(jet);      
    %%% Axes for mena intensity
    h.Intensity_Axes = axes(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',....
        'Position',[0.08 0.3 0.91 0.14],...
        'Box','off');
    h.Plot.Intensity = plot(0,0,'k');
    h.Intensity_Axes.YLabel.String='Mean intensity [kHz]';
    h.Intensity_Axes.YLabel.Color=Look.Fore;
    h.Intensity_Axes.Box = 'off';
    h.Intensity_Axes.XTick = [];
    h.Intensity_Axes.XColor = Look.Fore;
    h.Intensity_Axes.YColor = Look.Fore;
    h.Intensity_Axes.YLimMode = 'auto';
    %%% Axes for (un)selecting bins
    h.Selected_Axes = axes(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',....
        'Position',[0.08 0.27 0.91 0.02],...
        'XTick',[],...
        'YTick',[],...
        'Nextplot','add',...
        'ButtonDownFcn',{@Select_Bins,2},...
        'Box','off');
    %%% Links xlim of carpet axes
    h.Plot.Link.Carpet = linkprop([h.Selected_Axes,h.Intensity_Axes,h.Carpet_Axes], 'XLim');   
    %% List and buttons
    %%% Listbox of all ROIs
    h.ROI_List = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Max',5,...
        'FontSize',12,...
        'Position',[0.005 0.005 0.5 0.25],...
        'KeyPressFcn',{@Update_ROIs,0},...
        'Style','listbox');
    
    %%% Text to show current bin
    h.Current_Int = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','G(t): ',...
        'HorizontalAlignment','left',...
        'Position',[0.51 0.225 0.485 0.03],...
        'Style','Text');    
    %%% Text to show current bin
    h.Current_Time = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Time: ',...
        'HorizontalAlignment','left',...
        'Position',[0.51 0.19 0.485 0.03],...
        'Style','Text');
    %%% Text to show current bin
    h.Current_Bin = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Bin: ',...
        'HorizontalAlignment','left',...
        'Position',[0.51 0.155 0.485 0.03],...
        'Style','Text');
    
    
    %%% Button to average inside ROIs
    h.Auto_ROI = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Generate ROIs',...
        'Position',[0.51 0.075 0.235 0.03],...
        'Callback',{@Update_ROIs,13},...
        'Style','pushbutton');
    
    %%% Button to average inside ROIs
    h.Auto_Select = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Unselect non-ROIs',...
        'Position',[0.76 0.075 0.235 0.03],...
        'Callback',{@Select_Bins,6},...
        'Style','pushbutton');
    
    %%% Button to average inside ROIs
    h.Average_Inside = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Average inside',...
        'Position',[0.51 0.04 0.235 0.03],...
        'Callback',{@Update_ROIs,9},...
        'Style','pushbutton');
    %%% Button to plot individual bins inside ROIs
    h.Indivudual_Inside = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Individual inside',...
        'Position',[0.76 0.04 0.235 0.03],...
        'Callback',{@Update_ROIs,10},...
        'Style','pushbutton');
    
    %%% Button to average across ROIs
    h.Average_Across = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Average across',...
        'Position',[0.51 0.005 0.235 0.03],...
        'Callback',{@Update_ROIs,11},...
        'Style','pushbutton');
    %%% Button to plot individual bins across ROIs
    h.Individual_Across = uicontrol(...
        'Parent',h.Carpet_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'FontSize',12,...
        'String','Individual across',...
        'Position',[0.76 0.005 0.235 0.03],...
        'Callback',{@Update_ROIs,12},...
        'Style','pushbutton');
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%% Correlation Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Correlation Panel
    h.Correlation_Panel = uibuttongroup(...
        'Parent',h.PCF,...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.5025 0.005 0.4925 0.99]); 
    
    %%% Text for time selection
    h.Text{end+1} = uicontrol(...
        'Parent',h.Correlation_Panel,...
        'Style','Text',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Position',[0.005 0.975, 0.15 0.02],...
        'String','Time limits [s]:');
    %%% Editbox for distance selection
    h.Cor_Min_Time = uicontrol(...
        'Parent',h.Correlation_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.16 0.975, 0.07 0.02],...
        'Callback',{@Update_Plots,[3]},...
        'Enable','off',...
        'String','1.5e-3');
    %%% Editbox for distance selection
    h.Cor_Max_Time = uicontrol(...
        'Parent',h.Correlation_Panel,...
        'Style','edit',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Position',[0.24 0.975, 0.07 0.02],...
        'Callback',{@Update_Plots,[3]},...
        'Enable','off',...
        'String','1e0');
        
    %%% Axes for Carpet
    h.Cor_Axes = axes(...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'Position',[0.1 0.32 0.885 0.625],...
        'XScale','log',...
        'NextPlot','add',...
        'Box','off');   
    h.Cor_Axes.XLabel.String='Time Lag {\it\tau{}} [s]';
    h.Cor_Axes.XLabel.Color=Look.Fore;
    h.Cor_Axes.YLabel.String='G({\it\tau{}})';
    h.Cor_Axes.YLabel.Color=Look.Fore;
    h.Cor_Axes.XColor = Look.Fore;
    h.Cor_Axes.YColor = Look.Fore;
    
    %%% Listbox of all averaged correlations
    h.Cor_List = uicontrol(...
        'Parent',h.Correlation_Panel,...
        'Units','normalized',...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Max',5,...
        'FontSize',12,...
        'String',{},...
        'Position',[0.005 0.005 0.99 0.25],...
        'KeyPressFcn',{@Update_Cors,0},...
        'Style','listbox');    
          
%% Initializes global variables

PCFData.Data = {};
PCFData.ROI.Name = {};
PCFData.ROI.Bins = {};
PCFData.ROI.Color = {};

PCFData.Cor = struct('Bins',{},'Dist',{},'File',{},'Color',{},'Cor',{});

h.Plot.ROI = {};
h.Plot.Cor = {};
guidata(h.PCF,h);  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions that executes upon closing of pam window %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_PCF(Obj,~)
clear global -regexp PCFData
Phasor=findobj('Tag','Phasor');
Pam=findobj('Tag','Pam');
FCSFit=findobj('Tag','FCSFit');
MIAFit=findobj('Tag','MIAFit');

if isempty(Phasor) && isempty(FCSFit) && isempty(Pam) && isempty(MIAFit)
    clear global -regexp UserValues
end
delete(Obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to load PCF files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_PCF(~,~,mode)
global UserValues PCFData
h = guidata(findobj('Tag','PCF'));

%%% Choose files to load
[FileName,PathName] = uigetfile('*.pcor', 'Choose Pair correlation files', UserValues.File.PCFPath, 'MultiSelect', 'on');
if ~iscell(FileName) %%% Tranforms to cell array, if only one file was selected
    FileName = {FileName};
end
if all(FileName{1}==0) %%% Exits callback, if no file was selected
   return; 
end

%%% Saves pathname to uservalues
UserValues.File.PCFPath=PathName;
LSUserValues(1);

if mode %%% Deletes previously loaded files
    PCFData.Data = cell(0);
    h.PCF_File.String = {};
end

%%% Loads Data and updates file list
for i=1:numel(FileName)
    PCFData.Data{end+1} = load([PathName FileName{i}],'-mat');
    PCFData.Data{end}.SelectedBins = ones(1,PCFData.Data{end}.PairInfo.Bins);
    h.PCF_File.String{end+1} = ['File' num2str(numel(h.PCF_File.String)+1) ': ' FileName{i}];
end
%%% Turns Callbacks on (first loaded data)
h.PCF_Dist_Edit.Enable = 'on';
h.PCF_Dist_Slider.Enable = 'on';
h.Carpet_Min_Time.Enable = 'on';
h.Carpet_Max_Time.Enable = 'on';
h.Carpet_Normalize.Enable = 'on';
h.Carpet_Intensity.Enable = 'on';
h.Carpet_Intensity_Rebin.Enable = 'on';
h.Cor_Min_Time.Enable = 'on';
h.Cor_Max_Time.Enable = 'on';
h.Plot.Carpet.UIContextMenu = h.Carpet_Menu;
h.Intensity_Axes.UIContextMenu = h.Mean_Menu;
h.Plot.Carpet.ButtonDownFcn = {@Select_ROI,1};
h.Intensity_Axes.ButtonDownFcn = {@Select_ROI,2};
h.PCF.WindowScrollWheelFcn = {@PCF_Callbacks,1};
h.PCF.KeyPressFcn = {@Update_ROIs,0};
h.PCF.WindowButtonMotionFcn = {@PCF_Callbacks,2};

%%% Selects last loaded file
h.PCF_File.Value = numel(h.PCF_File.String);

%%% Updates selected bins and plots
Select_Bins([],[],1)

Update_Plots([],[],2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callbacks of events triggered in the figure itself %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Currently only mouse wheel scroll
function PCF_Callbacks (~,e,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));

switch mode
    case 1 %%% Change selected file using the mouse wheel
        if e.VerticalScrollCount<0 &&  h.PCF_File.Value>1
            h.PCF_File.Value = h.PCF_File.Value-1;
        elseif e.VerticalScrollCount>0 &&  h.PCF_File.Value<numel(h.PCF_File.String)
            h.PCF_File.Value = h.PCF_File.Value+1;
        end
        Select_Bins([],[],1);
    case 2 %%% Shows amplitude, time and bin at current cursor position
        h.PCF.WindowButtonMotionFcn = []; 
        if strcmp('PCF',get(gcf,'Tag'));
            
            %%% Information about carpet
            Pos=h.Carpet_Axes.CurrentPoint(1,1:2);
            if Pos(1)>h.Carpet_Axes.XLim(1) && Pos(1)<h.Carpet_Axes.XLim(2) && Pos(2)>h.Carpet_Axes.YLim(1) && Pos(2)<h.Carpet_Axes.YLim(2)
                
                File = h.PCF_File.Value;
                Dist = h.PCF_Dist_Slider.Value;
                Rebin = str2double(h.Carpet_Intensity_Rebin.String)/10;
                Bin = round(Pos(1));
                h.Current_Bin.String = ['Bin: ' num2str(Bin)];
                if strcmp(h.Carpet_Cor.Checked,'on') %%% Correlation plot
                    Time = PCFData.Data{File}.PairInfo.Time(round(Pos(2)));
                    if any(PCFData.Data{File}.PairInfo.Dist == Dist)
                        Int = PCFData.Data{File}.PairCor(round(Pos(2)),Bin,Dist+1,1);
                    else
                        Int = 0;
                    end
                    h.Current_Time.String= ['Lag time: ' num2str(Time, '%.3g') ' s'];
                    h.Current_Int.String = ['G(t): ' num2str(Int, '%.3g')];
                elseif strcmp(h.Carpet_Int.Checked,'on') %%% Intensity plot
                    Time = Pos(2);
                    Point = round(Time*PCFData.Data{File}.PairInfo.ScanFreq/Rebin);
                    Int = h.Plot.Carpet.CData(Point,Bin);
                    h.Current_Time.String= ['Time: ' num2str(Time, '%.3g') ' s'];
                    h.Current_Int.String = ['Count rate: ' num2str(Int, '%.4g') ' kHz'];
                elseif strcmp(h.Carpet_MI.Checked,'on') %%% Mean arival time plot
                    Time = Pos(2);
                    Point = round(Time*PCFData.Data{File}.PairInfo.ScanFreq/Rebin);
                    Int = h.Plot.Carpet.CData(Point,Bin);
                    h.Current_Time.String= ['Time: ' num2str(Time, '%.3g') ' s'];
                    h.Current_Int.String = ['Mean arrival time: ' num2str(Int, '%.4g') ];
                end
            end
            %%% Information about mean intensity/arrival time plot
            Pos=h.Intensity_Axes.CurrentPoint(1,1:2);            
            if Pos(1)>h.Intensity_Axes.XLim(1) && Pos(1)<h.Intensity_Axes.XLim(2) && Pos(2)>h.Intensity_Axes.YLim(1) && Pos(2)<h.Intensity_Axes.YLim(2)                
                Bin = round(Pos(1));
                h.Current_Bin.String = ['Bin: ' num2str(Bin)];
                h.Current_Time.String = '';
                if strcmp(h.Mean_Int.Checked,'on') %%% Mean intensity
                    Int = h.Plot.Intensity.YData(round(Pos(1)));
                    h.Current_Int.String = ['Count rate: ' num2str(Int, '%.4g') ' kHz'];
                elseif strcmp(h.Mean_MI.Checked,'on') %%% Mean arrival time
                    Int = h.Plot.Intensity.YData(round(Pos(2)));
                    h.Current_Int.String = ['Mean arrival time: ' num2str(Int, '%.4g') ];
                end
            end
            %%% Information about correlation plot
            Pos=h.Cor_Axes.CurrentPoint(1,1:2);            
            if Pos(1)>h.Cor_Axes.XLim(1) && Pos(1)<h.Cor_Axes.XLim(2) && Pos(2)>h.Cor_Axes.YLim(1) && Pos(2)<h.Cor_Axes.YLim(2)
                h.Current_Bin.String = '';
                h.Current_Time.String = ['Lag time: ' num2str(Pos(1), '%.3g') ' s'];
                h.Current_Int.String = ['G(t): ' num2str(Pos(2), '%.3g')];
            end
        end
        h.PCF.WindowButtonMotionFcn = {@PCF_Callbacks,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions update PCF plots  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(~,~,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));


%%% Stops execution, if no file was loaded
if isempty(PCFData.Data)
    return;
end
%%% Determines selected file
File = h.PCF_File.Value;
%%% Determines selected distance and adjusts, if distance is to large
h.PCF_Dist_Slider.Max = max(PCFData.Data{File}.PairInfo.Dist);
h.PCF_Dist_Slider.SliderStep = [1 1]/(h.PCF_Dist_Slider.Max-h.PCF_Dist_Slider.Min);
h.PCF_Dist_Slider.Value = round(h.PCF_Dist_Slider.Value);
if h.PCF_Dist_Slider.Value > h.PCF_Dist_Slider.Max
    h.PCF_Dist_Slider.Value = h.PCF_Dist_Slider.Max;
end
Dist = h.PCF_Dist_Slider.Value;
%%% Adjusts Carpet ROI to distance
for i= 1:size(h.Plot.ROI,1)
    if h.Plot.ROI{i,2}.XData(1) <= h.Plot.ROI{i,2}.XData(3)-Dist
        h.Plot.ROI{i,1}.XData(3:4) = h.Plot.ROI{i,2}.XData(3:4)-Dist;
    else
        Min = h.Plot.ROI{i,2}.XData(1);
        h.Plot.ROI{i,1}.XData = [Min, Min, Min+0.8, Min+0.8, Min];
    end
end

if any(mode == 1) %%% Updates correlation/intensity/mean arrival time carpet
    if strcmp(h.Carpet_Cor.Checked,'on') %%% Plots correlation carpet
        Min = str2double(h.Carpet_Min_Time.String);
        Max = min([str2double(h.Carpet_Max_Time.String), size(PCFData.Data{File}.PairInfo.Time,1)]);
        if any(PCFData.Data{File}.PairInfo.Dist == Dist) %%% Plots PCF for selected distance
            CData = PCFData.Data{File}.PairCor(Min:Max,:,Dist+1,1);
            if strcmp(h.Carpet_Normalize.Checked,'on') %%% Normalized data per bin
                CData = (CData-repmat(min(CData),[(Max-Min+1),1]))./repmat((max(CData)-min(CData)),[(Max-Min+1),1]);
                CData(isnan(CData) | isinf(CData)) = 0;
            end
            
        else %%% Plots zeros for nonexistent distances
            CData = 0*PCFData.Data{File}.PairCor(Min:Max,:,1,1);
        end
        %%% Sets all unselected bins to zero
        CData(repmat(PCFData.Data{File}.SelectedBins,[Max-Min+1,1])==0)=0;
        %%% Sets all bins correlated with unselected bins to zero
        CData(circshift(repmat(PCFData.Data{File}.SelectedBins,[Max-Min+1,1]),[0,-Dist])==0)=0;
        h.Plot.Carpet.CData = CData;
        h.Plot.Carpet.YData = 1:size(CData,1);
        %%% Adjusts axis limits
        h.Carpet_Axes.XLim = [0.5 size(CData,2)+0.5];
        h.Carpet_Axes.YLim = [0.5 size(CData,1)+0.5];
        h.Carpet_Axes.YLabel.String='Correlation bins (logscale)';
    elseif strcmp(h.Carpet_Int.Checked,'on') %%% Plots intensity carpet
        Rebin = str2double(h.Carpet_Intensity_Rebin.String)/10;
        CData = PCFData.Data{File}.PairInt{1}*...        
            PCFData.Data{File}.PairInfo.ScanFreq*...
            PCFData.Data{File}.PairInfo.Bins/...
            1000;
        CData = CData(1:end-mod(size(CData,1),Rebin),:);
        CData = squeeze(sum(reshape(CData,[Rebin,size(CData,1)/Rebin,size(CData,2)])))/Rebin;
        if strcmp(h.Carpet_Normalize.Checked,'on') %%% Normalized data per bin
            CData = (CData-repmat(min(CData),[size(CData,1),1]))./repmat((max(CData)-min(CData)),[size(CData,1),1]);
            CData(isnan(CData) | isinf(CData)) = 0;
        end
        h.Plot.Carpet.CData = CData;
        h.Plot.Carpet.YData = (0.5:(size(CData,1)-0.5))/PCFData.Data{File}.PairInfo.ScanFreq*Rebin;
        h.Carpet_Axes.XLim = [0.5 size(CData,2)+0.5];
        h.Carpet_Axes.YLim = h.Plot.Carpet.YData([1 end]);
        h.Carpet_Axes.YLabel.String='Time [s]';
    elseif strcmp(h.Carpet_MI.Checked,'on') %%% Plots mean arrival time carpet
        Rebin = str2double(h.Carpet_Intensity_Rebin.String)/10;
        CData = PCFData.Data{File}.PairMI{1};
        CData = CData(1:end-mod(size(CData,1),Rebin),:);
        CData = reshape(CData,[Rebin,size(CData,1)/Rebin,size(CData,2)]);
        Weights = PCFData.Data{File}.PairInt{1};
        Weights = Weights(1:end-mod(size(Weights,1),Rebin),:);
        Weights = reshape(Weights,[Rebin,size(Weights,1)/Rebin,size(Weights,2)]);        
        CData = squeeze(sum(CData.*Weights)./sum(Weights));
        if strcmp(h.Carpet_Normalize.Checked,'on') %%% Normalized data per bin
            CData = (CData-repmat(min(CData),[size(CData,1),1]))./repmat((max(CData)-min(CData)),[size(CData,1),1]);
            CData(isnan(CData) | isinf(CData)) = 0;
        end
        h.Plot.Carpet.CData = CData;
        h.Plot.Carpet.YData = (0.5:(size(CData,1)-0.5))/PCFData.Data{File}.PairInfo.ScanFreq*Rebin;
        h.Carpet_Axes.XLim = [0.5 size(CData,2)+0.5];
        h.Carpet_Axes.YLim = h.Plot.Carpet.YData([1 end]);
        h.Carpet_Axes.YLabel.String='Time [s]';
    end
end
if any(mode == 2) %%% Updates mean intensity/arival time plot
    if strcmp(h.Mean_Int.Checked,'on') %%% Plots mean intensity in kHz
        h.Plot.Intensity.YData = (mean(PCFData.Data{File}.PairInt{1},1)*...
            PCFData.Data{File}.PairInfo.ScanFreq*...
            PCFData.Data{File}.PairInfo.Bins/1000);
        h.Intensity_Axes.YLabel.String='Mean intensity [kHz]';
    elseif strcmp(h.Mean_MI.Checked,'on') %%% Plots mean arrival time
        h.Plot.Intensity.YData = sum(PCFData.Data{File}.PairInt{1}.*PCFData.Data{File}.PairMI{1},1)./sum(PCFData.Data{File}.PairInt{1});
        h.Intensity_Axes.YLabel.String = 'Mean arrival time [ticks]';
    end
    %%% Adjusts axis limits
    h.Plot.Intensity.XData = 1:numel(h.Plot.Intensity.YData);
    h.Intensity_Axes.XLim = [0 numel(h.Plot.Intensity.XData)]+0.5;
    YLim = [min(h.Plot.Intensity.YData) max(h.Plot.Intensity.YData)+1e-10];
    h.Intensity_Axes.YLim = [YLim(1)-0.1*diff(YLim) YLim(2)+0.1*diff(YLim)];
end
if any(mode == 3) %%% Updates correlations plot
    h.Cor_Axes.XLim = [str2double(h.Cor_Min_Time.String), str2double(h.Cor_Max_Time.String)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to syncronize Distance inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Change_Dist(~,~,mode)
h = guidata(findobj('Tag','PCF'));
switch mode
    case 1 %%% Slider was moved
        Dist = round(h.PCF_Dist_Slider.Value);
    case 2 %%% Editbox was changed
        Dist = round(str2double(h.PCF_Dist_Edit.String));
end
h.PCF_Dist_Edit.String = num2str(Dist);
h.PCF_Dist_Slider.Value = Dist;
Update_Plots([],[],1)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions for disabling/enabling bins %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Select_Bins(~,e,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));
switch mode
    case 1 %%% Creates new set of selection patches when selected file is changed
        %%% Deletes all patches
        delete(h.Selected_Axes.Children);
        File = h.PCF_File.Value;
        %%% Creates new patches
        for i=1:PCFData.Data{File}.PairInfo.Bins
            patch(...
                'Parent', h.Selected_Axes,...
                'XData',[i-0.4, i-0.4, i+0.4, i+0.4],...
                'YData',[0 1 1 0],...
                'HitTest', 'off',...
                'FaceColor',[~PCFData.Data{File}.SelectedBins(i), PCFData.Data{File}.SelectedBins(i), 0]);
        end
        Update_Plots([],[],[1 2]);
    case 2 %%% (Un)select bins by clicking
        File = h.PCF_File.Value;
        Pos = round(e.IntersectionPoint(1));
        switch h.PCF.SelectionType
            case 'normal' %%% (Un)select using left mous button
                State = ~PCFData.Data{File}.SelectedBins(Pos);
                PCFData.Data{File}.SelectedBins(Pos) = State;                
                h.Selected_Axes.Children(end+1-Pos).FaceColor = [~State State 0];             
                h.PCF.WindowButtonMotionFcn = {@Select_Bins,3+State};
                h.PCF.WindowButtonUpFcn = {@Select_Bins,5};               
            case 'alt' %%% (U)nselects all bins using right mouse button
                State = ~PCFData.Data{File}.SelectedBins(Pos);
                PCFData.Data{File}.SelectedBins(:) = State;
                for i=1:PCFData.Data{File}.PairInfo.Bins
                    h.Selected_Axes.Children(i).FaceColor = [~State State 0];
                end
                Update_Plots([],[],1);
        end      
    case 3 %%% Unselect bins by moving
        File = h.PCF_File.Value;
        h.PCF.WindowButtonMotionFcn = [];
        Pos = round(h.Selected_Axes.CurrentPoint(1));
        if Pos>=1 && Pos <=PCFData.Data{File}.PairInfo.Bins;
            PCFData.Data{File}.SelectedBins(Pos) = 0;
            h.Selected_Axes.Children(end+1-Pos).FaceColor = [1 0 0];
        end
        h.PCF.WindowButtonMotionFcn = {@Select_Bins,3};
    case 4 %%% Select bins by moving
        File = h.PCF_File.Value;
        h.PCF.WindowButtonMotionFcn = [];
        Pos = round(h.Selected_Axes.CurrentPoint(1));
        if Pos>=1 && Pos <=PCFData.Data{File}.PairInfo.Bins;
            PCFData.Data{File}.SelectedBins(Pos) = 1;
            h.Selected_Axes.Children(end+1-Pos).FaceColor = [0 1 0];
        end
        h.PCF.WindowButtonMotionFcn = {@Select_Bins,4};
    case 5 %%% Stop (un)selection
        h.PCF.WindowButtonMotionFcn = {@PCF_Callbacks,2};
        h.PCF.WindowButtonUpFcn = [];
        Update_Plots([],[],1);
    case 6 %%% (Un)select bins according to ROIs
        File = h.PCF_File.Value;
        Bins = [];
        for i = 1:numel(PCFData.ROI.Bins)
            Bins = [Bins PCFData.ROI.Bins{i}(1):PCFData.ROI.Bins{i}(2)];            
        end
        Bins = unique(Bins);
        Bins = Bins(Bins <= PCFData.Data{File}.PairInfo.Bins);
        PCFData.Data{File}.SelectedBins(:) = 0;
        PCFData.Data{File}.SelectedBins(Bins) = 1;
        for i=1:PCFData.Data{File}.PairInfo.Bins
            if any(Bins == i)
                h.Selected_Axes.Children(end-i+1).FaceColor = [0 1 0];
            else
                h.Selected_Axes.Children(end-i+1).FaceColor = [1 0 0];
            end
        end
        Update_Plots([],[],1);
        
        
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback for Carpet menus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Carpet_Callback(Obj,~,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));

switch mode
    case 1 %%% Toggle binwise normalization
        if strcmp(h.Carpet_Normalize.Checked,'on')
            h.Carpet_Normalize.Checked ='off';
        else
            h.Carpet_Normalize.Checked = 'on';
        end
        Update_Plots([],[],1);
    case 2 %%% Plot correlations
        h.Carpet_Cor.Checked = 'on';
        h.Carpet_Int.Checked = 'off';
        h.Carpet_MI.Checked = 'off';
        Update_Plots([],[],1);
    case 3 %%% Plot intensities
        h.Carpet_Cor.Checked = 'off';
        h.Carpet_Int.Checked = 'on';
        h.Carpet_MI.Checked = 'off';        
        Update_Plots([],[],1);
    case 4 %%% Plot mean arrival times
        h.Carpet_Cor.Checked = 'off';
        h.Carpet_Int.Checked = 'off';
        h.Carpet_MI.Checked = 'on';
        Update_Plots([],[],1);
    case 5 %%% Exports full carpet to figure
        %% Calculates image
        File = h.PCF_File.Value;
        Dist = h.PCF_Dist_Slider.Value;
        Min = str2double(h.Carpet_Min_Time.String);
        Max = min([str2double(h.Carpet_Max_Time.String), size(PCFData.Data{File}.PairInfo.Time,1)]);
        if any(PCFData.Data{File}.PairInfo.Dist == Dist) %%% Plots PCF for selected distance
            CData = PCFData.Data{File}.PairCor(Min:Max,:,Dist+1,1);
            if strcmp(h.Carpet_Normalize.Checked,'on') %%% Normalized data per bin
                CData = (CData-repmat(min(CData),[(Max-Min+1),1]))./repmat((max(CData)-min(CData)),[(Max-Min+1),1]);
                CData(isnan(CData) | isinf(CData)) = 0;
            end            
        else %%% Plots zeros for nonexistent distances
            CData = 0*PCFData.Data{File}.PairCor(Min:Max,:,1,1);
        end
        CData = CData(:,1:end-Dist);   
        %% Removes unselected bins
        if Obj == h.Carpet_Sel2Fig
            Sel = PCFData.Data{File}.SelectedBins & circshift(PCFData.Data{File}.SelectedBins,[0,-Dist]);
            Sel = Sel(1:end-Dist);
            %%% Removes all unselected bins
            CData = reshape(CData(repmat(Sel,[Max-Min+1,1])~=0),[],sum(Sel));
        end
        %% Creates figure, axes and plot
        Scale = 2;
        Exp.fig = figure(...
        'Units','points',...
        'defaultUicontrolFontName','Arial',...
        'defaultAxesFontName','Arial',...
        'defaultTextFontName','Arial',...
        'Position',[100 200 Scale*size(CData,2)+125 Scale*size(CData,1)+40]);
    
        Exp.axes = axes(...
            'Parent',Exp.fig,...
            'Units','points',...
            'FontSize',12,...
            'Position',[50 5 Scale*size(CData,2) Scale*size(CData,1)],...
            'NextPlot', 'add',...
            'XLim',[0.5 size(CData,2)+0.5],...
            'YLim',[0.5 size(CData,1)+0.5],...
            'YDir','reverse',...
            'XAxisLocation','top',...
            'Layer','top',...
            'XTick',[1 size(CData,2)],...
            'Box', 'off');
        Exp.carpet = imagesc(...
            'Parent', Exp.axes,...
            'CData',CData);
        colormap(jet);        
        %% Calculates and adds Ticks and Labels
        YTickLabels = cell(60,1);
        YTicks = zeros(60,1);
        for i= 1:6
            YTicks((1:9)+((i-1)*9)) = 10^(-5+i)*(1:9);
            YTickLabels{9*(i-1)+1} = num2str(YTicks(9*(i-1)+1));
        end
        Time = PCFData.Data{File}.PairInfo.Time(Min:Max);
        YTicks = interp1(Time,1:numel(Time),YTicks);        
        Exp.axes.YTickLabel = YTickLabels(~isnan(YTicks));
        Exp.axes.YTick = YTicks(~isnan(YTicks));
        Exp.axes.YLabel.String = 'Lag time {\it\tau{}} [s]';
        Exp.axes.YLabel.FontSize = 14;       
        Exp.axes.XLabel.String = 'Bin';
        Exp.axes.XLabel.FontSize = 14;        
        %% Adds colorbar
        Exp.colbar = colorbar(...
            'peer',Exp.axes,...
            'FontSize',12,...
            'Units','points',...
            'Position', [Scale*size(CData,2)+60 5 10 Scale*size(CData,1)],...
            'Location','eastoutside');
        if strcmp(h.Carpet_Normalize.Checked,'on')
            Exp.colbar.Label.String = 'Normalized G({\it\tau{}})';
        else
            Exp.colbar.Label.String = 'G({\it\tau{}})';
        end
        Exp.colbar.Label.FontSize = 14;         
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Callback for Carpet menus %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Intensity_Callback(Obj,~,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));

switch mode
    case 1 %%% Plot mean intensity
        h.Mean_Int.Checked = 'on';
        h.Mean_MI.Checked = 'off';        
        Update_Plots([],[],2);
    case 2 %%% Plot mean arrival time
        h.Mean_Int.Checked = 'off';
        h.Mean_MI.Checked = 'on';
        Update_Plots([],[],2);
    case 3 %%% Exports mean intensity\lifetime plot
        %% Calculates YData
        File = h.PCF_File.Value;
        if strcmp(h.Mean_Int.Checked,'on') %%% Plots mean intensity in kHz
            YData = (mean(PCFData.Data{File}.PairInt{1},1)*...
                PCFData.Data{File}.PairInfo.ScanFreq*...
                PCFData.Data{File}.PairInfo.Bins/1000);
            
            Rebin = str2double(h.Carpet_Intensity_Rebin.String)/10;
            CData = PCFData.Data{File}.PairInt{1};
            CData = CData(1:end-mod(size(CData,1),Rebin),:);
            CData = squeeze(sum(reshape(CData,[Rebin,size(CData,1)/Rebin,size(CData,2)])))*...
                PCFData.Data{File}.PairInfo.ScanFreq*...
                PCFData.Data{File}.PairInfo.Bins/...
                1000/Rebin;
            
            YLabel_String='Mean intensity [kHz]';
        elseif strcmp(h.Mean_MI.Checked,'on') %%% Plots mean arrival time
            YData = sum(PCFData.Data{File}.PairInt{1}.*PCFData.Data{File}.PairMI{1},1)./sum(PCFData.Data{File}.PairInt{1});
            YLabel_String = 'Mean arrival time [ticks]';
            
            Rebin = str2double(h.Carpet_Intensity_Rebin.String)/10;
            CData = PCFData.Data{File}.PairMI{1};
            CData = CData(1:end-mod(size(CData,1),Rebin),:);
            CData = reshape(CData,[Rebin,size(CData,1)/Rebin,size(CData,2)]);
            Weights = PCFData.Data{File}.PairInt{1};
            Weights = Weights(1:end-mod(size(Weights,1),Rebin),:);
            Weights = reshape(Weights,[Rebin,size(Weights,1)/Rebin,size(Weights,2)]);
            CData = squeeze(sum(CData.*Weights)./sum(Weights));
    
        end        
        %% Removes unselected bins
        if Obj == h.Mean_Sel2Fig
            Sel = PCFData.Data{File}.SelectedBins;
            %%% Removes all unselected bins
            YData = YData(Sel~=0);
            CData = reshape(CData(repmat(Sel,[size(CData,1),1])~=0),[],sum(Sel));
        end       
        %% Creates figure, axes and plot
        ScaleX = 2;
        ScaleY = 1.5;
        Exp.fig = figure(...
        'Units','points',...
        'defaultUicontrolFontName','Arial',...
        'defaultAxesFontName','Arial',...
        'defaultTextFontName','Arial',...
        'Position',[100 100 ScaleX*size(CData,2)+125 ScaleY*size(CData,1)/PCFData.Data{File}.PairInfo.ScanFreq*Rebin+ScaleY*15+85]);
    
        Exp.axes1 = axes(...
            'Parent',Exp.fig,...
            'Units','points',...
            'FontSize',12,...
            'Position',[50 ScaleY*15+40 ScaleX*size(CData,2) ScaleY*size(CData,1)/PCFData.Data{File}.PairInfo.ScanFreq*Rebin],...
            'NextPlot', 'add',...
            'XLim',[0.5 size(CData,2)+0.5],...
            'YLim',[0.5 size(CData,1)+0.5],...
            'YDir','reverse',...
            'XAxisLocation','top',...
            'Layer','top',...
            'XTick',[1 size(CData,2)],...
            'Box', 'off');
        Exp.axes1.XLim = [0.5 size(CData,2)+0.5];
        Exp.axes1.YLim = h.Plot.Carpet.YData([1 end]);
        Exp.axes1.YLabel.String='Time [s]';
        Exp.axes1.YLabel.FontSize = 14;
        Exp.axes1.XLabel.String='Bin';
        Exp.axes1.XLabel.FontSize = 14;
        Exp.carpet = imagesc(...
            'Parent', Exp.axes1,...
            'CData',CData,...
            'YData',(0.5:(size(CData,1)-0.5))/PCFData.Data{File}.PairInfo.ScanFreq*Rebin);
        colormap(jet);      
        
        Exp.axes2 = axes(...
            'Parent',Exp.fig,...
            'Units','points',...
            'FontSize',12,...
            'Position',[50 5 ScaleX*size(CData,2) ScaleY*15+25],...
            'NextPlot', 'add',...
            'XLim',[0.5 numel(YData)+0.5],...
            'YAxisLocation','right',...
            'Layer','top',...
            'XTick',[1 size(CData,2)],...
            'Box', 'off');          
        Exp.plot = line(....
            'Parent',Exp.axes2,...
            'XData', 1:numel(YData),...
            'YData', YData,...
            'Color','k');         
       Exp.axes2.YLim = [min(YData) max(YData)];
       if strcmp(h.Mean_Int.Checked,'on') %%% Plots mean intensity in kHz
           Exp.axes2.YLabel.String = {'Mean Int.', '[kHz]'};
       else
           Exp.axes2.YLabel.String = {'Mean LT.', '[Ticks]'};
       end
       Exp.axes2.YLabel.FontSize = 14;
       Exp.axes2.XLabel.String='Bin';
       Exp.axes2.XLabel.FontSize = 14;               
        %% Adds colorbar
        Exp.colbar = colorbar(...
            'peer',Exp.axes1,...
            'FontSize',12,...
            'Units','points',...
            'Position', [ScaleX*size(CData,2)+60 ScaleY*15+40 10 ScaleY*size(CData,1)/PCFData.Data{File}.PairInfo.ScanFreq*Rebin],...
            'Location','eastoutside');

        Exp.colbar.Label.String = YLabel_String;
        Exp.colbar.Label.FontSize = 14;       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions to select relevant regions in carpet  %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Select_ROI(~,e,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));

if mode && strcmp(h.PCF.SelectionType,'normal') %%% Start of ROI selection
    %%% Determines Starting position
    Start = floor(e.IntersectionPoint(1)+0.5);
    
    %%% Creates rectangle in carpet plot
    YLim = h.Carpet_Axes.YLim;
    h.Plot.ROI{end+1,1} = line (...
        'Parent',h.Carpet_Axes,...
        'XData',[Start-0.4, Start-0.4, Start+0.4, Start+0.4 Start-0.4],...
        'YData',[YLim(2)-0.1 YLim(1)+0.1 YLim(1)+0.1 YLim(2)-0.1 YLim(2)-0.1],...
        'LineStyle','--',...
        'Color',[1 1 1],...
        'LineWidth',1);    
    %%% Creates rectangle in intensity plot
    YLim = h.Intensity_Axes.YLim;
    YLim = [YLim(1)+0.01*diff(YLim),YLim(2)-0.01*diff(YLim)];
    h.Plot.ROI{end,2} = line (...
        'Parent',h.Intensity_Axes,...
        'XData',[Start-0.4, Start-0.4, Start+0.4, Start+0.4 Start-0.4],...
        'YData',[YLim(2), YLim(1), YLim(1), YLim(2), YLim(2)],...
        'LineStyle','--',...
        'Color',[1 1 1],...
        'LineWidth',1);
    %%% Save new plots
    guidata(h.PCF,h);
    %%% Sets stop function
    h.PCF.WindowButtonUpFcn = {@Select_ROI,0};
    %%% Activates movement callback
    ROI_Move([],[],Start,mode);
elseif mode == 0 %%% Stop of ROI selection
    %%% Disables stop function
    h.PCF.WindowButtonUpFcn = [];
    %%% Disables movement callback
    h.PCF.WindowButtonMotionFcn = {@PCF_Callbacks,2};
    %%% Saves ROI information
    PCFData.ROI.Bins{end+1} = round([h.Plot.ROI{end,2}.XData(1)+0.4, h.Plot.ROI{end,2}.XData(3)-0.4]);
    PCFData.ROI.Name{end+1} = ['Bins ' num2str(PCFData.ROI.Bins{end}(1)) ' to ' num2str(PCFData.ROI.Bins{end}(2))];
    PCFData.ROI.Color{end+1} = [1 1 1];
    %%% Updates ROI List
    Update_ROIs([],[],1)
end
function ROI_Move(~,~,Start,mode)
h = guidata(findobj('Tag','PCF'));

%%% Turns off callback, to prohibit double evaluations
h.PCF.WindowButtonMotionFcn = []; 
%%% Extracts current position
Pos = floor(h.Carpet_Axes.CurrentPoint(1)+0.5);
%%% Determins lower and upper 
Min = min(Pos,Start)-0.4;
Max = max(Pos,Start)+0.4;
%%% Updates ROI position
if mode ==1 %%% Carpet callback
    h.Plot.ROI{end,1}.XData = [Min, Min, Max, Max, Min];
    h.Plot.ROI{end,2}.XData = [Min, Min, Max+h.PCF_Dist_Slider.Value, Max+h.PCF_Dist_Slider.Value, Min,];
else %%% Intensity callback
    h.Plot.ROI{end,2}.XData = [Min, Min, Max, Max, Min,];
    if Min <=Max-h.PCF_Dist_Slider.Value
        h.Plot.ROI{end,1}.XData = [Min, Min, Max-h.PCF_Dist_Slider.Value, Max-h.PCF_Dist_Slider.Value, Min,];
    else
        h.Plot.ROI{end,1}.XData =  [Min, Min, Min+0.8, Min+0.8, Min,];
    end
    
end
%%% Restarts movement callback
h.PCF.WindowButtonMotionFcn = {@ROI_Move,Start,mode}; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning ROIs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_ROIs(~,e,mode)
global PCFData
h = guidata(findobj('Tag','PCF'));
%%% Evaluates, which key was pressed
if mode == 0
   switch e.Key
       case 'delete' %%% Delete entry
           mode = 2;
       case 'rightarrow' %%% Move entry right
           mode = 3;           
       case 'leftarrow' %%% Move entry left
           mode = 4;
       case 'add' %%% Expand entry by one
           mode = 5;
       case 'subtract' %%% Shrink entry by one
           mode = 6;
       case 'c' %%% Change color of entry
           mode = 7;  
       case 'backspace' %%% (De)activate entry
           mode = 8;
       case 'return' %%% Average correlations inside ROI
           mode = 9;
       case 'multiply' %%% Individual correlations inside ROI
           mode = 10;
       case 'insert' %%% Average correlations between ROIs
           mode = 11;
       case 'divide' %%% Individual correlations between ROIs
           mode = 12;
   end    
end

Sel = sort(h.ROI_List.Value, 'descend');
%%% Executes ROI list callbacks
switch mode
    case 1 %%% ROI selection update
        Data = cell(numel(PCFData.ROI.Name),1);
        for i=1:numel(PCFData.ROI.Name)
            if strcmp(h.Plot.ROI{i,1}.Visible,'on');                
                Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
                Data{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
            else
                Data{i} = ['<HTML><FONT color=000000>' PCFData.ROI.Name{i} '</Font></html>'];
            end
        end
        h.ROI_List.String = Data;
        h.ROI_List.Value = numel(h.ROI_List.String);
        uicontrol(h.ROI_List);
    case 2 %%% Delete ROI
        for i = Sel
            delete(h.Plot.ROI{i,1});
            delete(h.Plot.ROI{i,2});
            h.Plot.ROI(i,:) = [];
            PCFData.ROI.Name(i) = [];
            PCFData.ROI.Bins(i) = [];
            PCFData.ROI.Color(i) = [];
            h.ROI_List.String(i) = [];            
        end
        h.ROI_List.Value = Sel(end)-1;
        if h.ROI_List.Value<1
            h.ROI_List.Value = [];
        end
        guidata(h.PCF,h);
    case 3 %%% Move right
        for i = Sel
            PCFData.ROI.Bins{i} = PCFData.ROI.Bins{i}+1;
            h.Plot.ROI{i,1}.XData = h.Plot.ROI{i,1}.XData+1;
            h.Plot.ROI{i,2}.XData = h.Plot.ROI{i,2}.XData+1;
            h.Plot.ROI{i,1}.Visible = 'on';
            h.Plot.ROI{i,2}.Visible = 'on';
            PCFData.ROI.Name{i} = ['Bins ' num2str(PCFData.ROI.Bins{i}(1)) ' to ' num2str(PCFData.ROI.Bins{i}(2))];
            Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
            h.ROI_List.String{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
        end
    case 4 %%% Move left
        for i = Sel
            if PCFData.ROI.Bins{i}(1)>1
                PCFData.ROI.Bins{i} = PCFData.ROI.Bins{i}-1;
                h.Plot.ROI{i,1}.XData = h.Plot.ROI{i,1}.XData-1;
                h.Plot.ROI{i,2}.XData = h.Plot.ROI{i,2}.XData-1;
                h.Plot.ROI{i,1}.Visible = 'on';
                h.Plot.ROI{i,2}.Visible = 'on';
                PCFData.ROI.Name{i} = ['Bins ' num2str(PCFData.ROI.Bins{i}(1)) ' to ' num2str(PCFData.ROI.Bins{i}(2))];
                Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
                h.ROI_List.String{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
            end
        end
    case 5 %%% Expand rigth
        for i = Sel
            PCFData.ROI.Bins{i}(2) = PCFData.ROI.Bins{i}(2)+1;
            h.Plot.ROI{i,2}.XData(3:4) = h.Plot.ROI{i,2}.XData(3:4)+1;
            if h.Plot.ROI{i,2}.XData(1)<= h.Plot.ROI{i,2}.XData(3)-h.PCF_Dist_Slider.Value
                h.Plot.ROI{i,1}.XData(3:4) = h.Plot.ROI{i,2}.XData(3:4)-h.PCF_Dist_Slider.Value;
            else
                h.Plot.ROI{i,1}.XData(3:4) = h.Plot.ROI{i,2}.XData(1)+0.8;
            end
            h.Plot.ROI{i,1}.Visible = 'on';
            h.Plot.ROI{i,2}.Visible = 'on';
            PCFData.ROI.Name{i} = ['Bins ' num2str(PCFData.ROI.Bins{i}(1)) ' to ' num2str(PCFData.ROI.Bins{i}(2))];
            Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
            h.ROI_List.String{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
        end
    case 6 %%% Shrink right
        for i = Sel
            if PCFData.ROI.Bins{i}(2)>PCFData.ROI.Bins{i}(1)
                PCFData.ROI.Bins{i}(2) = PCFData.ROI.Bins{i}(2)-1;
                h.Plot.ROI{i,2}.XData(3:4) = h.Plot.ROI{i,2}.XData(3:4)-1;
                if h.Plot.ROI{i,2}.XData(1)<= h.Plot.ROI{i,2}.XData(3)-h.PCF_Dist_Slider.Value
                    h.Plot.ROI{i,1}.XData(3:4) = h.Plot.ROI{i,2}.XData(3:4)-h.PCF_Dist_Slider.Value;
                else
                    h.Plot.ROI{i,1}.XData(3:4) = h.Plot.ROI{i,2}.XData(1)+0.8;
                end
                h.Plot.ROI{i,1}.Visible = 'on';
                h.Plot.ROI{i,2}.Visible = 'on';
                PCFData.ROI.Name{i} = ['Bins ' num2str(PCFData.ROI.Bins{i}(1)) ' to ' num2str(PCFData.ROI.Bins{i}(2))];
                Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
                h.ROI_List.String{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
            end
        end
    case 7 %%% Change color
        Color=uisetcolor;
        %%% Checks, if color was selected
        if numel(Color)==3
            for i=Sel
                PCFData.ROI.Color{i} = Color;
                h.Plot.ROI{i,1}.Color = Color;
                h.Plot.ROI{i,2}.Color = Color;
                PCFData.ROI.Name{i} = ['Bins ' num2str(PCFData.ROI.Bins{i}(1)) ' to ' num2str(PCFData.ROI.Bins{i}(2))];
                Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
                h.ROI_List.String{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
                h.Plot.ROI{i,1}.Visible = 'on';
                h.Plot.ROI{i,2}.Visible = 'on';
            end
        end
    case 8 %%% Hide ROI
        for i = Sel
            if strcmp(h.Plot.ROI{i,1}.Visible,'on');
                h.Plot.ROI{i,1}.Visible = 'off';
                h.Plot.ROI{i,2}.Visible = 'off';
                h.ROI_List.String{i} = ['<HTML><FONT color=000000>' PCFData.ROI.Name{i} '</Font></html>'];
            else
                h.Plot.ROI{i,1}.Visible = 'on';
                h.Plot.ROI{i,2}.Visible = 'on';
                Hex_color = dec2hex(round(PCFData.ROI.Color{i}*255))';
                h.ROI_List.String{i} = ['<HTML><FONT color=#' Hex_color(:)' '>' PCFData.ROI.Name{i} '</Font></html>'];
            end
        end
    case {9,10} %%% Plot bins inside ROI
        File = h.PCF_File.Value;
        Dist = h.PCF_Dist_Slider.Value;
        if any(PCFData.Data{File}.PairInfo.Dist==Dist) %%% Only execute, if distance exists in file
            Bins = [];
            Color = [0 0 0];
            for i=Sel %%% Determins valid bins for averaging
                Bins = [Bins, PCFData.ROI.Bins{i}(1):(PCFData.ROI.Bins{i}(2)-Dist)];
                Color = Color + PCFData.ROI.Color{i};
            end
            %%% Removes repeated bins
            Bins = unique(Bins);
            if ~isempty(Bins)
                if mode == 9
                %%% Create entry for new averaged correlation
                PCFData.Cor(end+1).Bins = Bins;
                PCFData.Cor(end).File = File;
                PCFData.Cor(end).Dist = Dist;
                PCFData.Cor(end).Color = Color/numel(Sel);
                PCFData.Cor(end).Cor(:,1) = mean(PCFData.Data{File}.PairCor(:,Bins,Dist+1,1),2);
                PCFData.Cor(end).Cor(:,2) = PCFData.Data{File}.PairInfo.Time;
                PCFData.Cor(end).Cor(:,3) = std(PCFData.Data{File}.PairCor(:,Bins,Dist+1,1),0,2)/sqrt(numel(Bins));
                %%% Updates correlation list and plot
                Update_Cors([],[],1);
                else
                    for i = Bins
                        %%% Create entry for new averaged correlation
                        PCFData.Cor(end+1).Bins = i;
                        PCFData.Cor(end).File = File;
                        PCFData.Cor(end).Dist = Dist;
                        PCFData.Cor(end).Color = rand(1,3);
                        PCFData.Cor(end).Cor(:,1) = PCFData.Data{File}.PairCor(:,i,Dist+1,1);
                        PCFData.Cor(end).Cor(:,2) = PCFData.Data{File}.PairInfo.Time;
                        PCFData.Cor(end).Cor(:,3) = 0*PCFData.Cor(end).Cor(:,1);
                        %%% Updates correlation list and plot
                        Update_Cors([],[],1);
                    end
                end
            end
        end        
    case {11,12} %%% Plot bins across ROIs
        File = h.PCF_File.Value;
        Dist = h.PCF_Dist_Slider.Value;
        Sel = flip(Sel,2);
        if any(PCFData.Data{File}.PairInfo.Dist==Dist) && numel(Sel)>1
            Bins = [];
            for i = 1:(numel(Sel)-1)
                for j = (i+1):numel(Sel)
                    %%% Intersection of i with j)
                    bins = intersect((PCFData.ROI.Bins{Sel(i)}(1):PCFData.ROI.Bins{Sel(i)}(2)),...
                        (PCFData.ROI.Bins{Sel(j)}(1):PCFData.ROI.Bins{Sel(j)}(2))-Dist);
                    Bins = [Bins bins];
                    %%% Intersection of j with i)
                    bins = intersect((PCFData.ROI.Bins{Sel(i)}(1):PCFData.ROI.Bins{Sel(i)}(2))-Dist,...
                        (PCFData.ROI.Bins{Sel(j)}(1):PCFData.ROI.Bins{Sel(j)}(2)));
                    Bins = [Bins bins];
                end
            end
            Color = [0 0 0];
            for i = 1:numel(Sel)
                Color = Color + PCFData.ROI.Color{i};
            end
            
            %%% Removes repeated bins
            Bins = unique(Bins);
            if ~isempty(Bins)
                if mode == 11
                    %%% Create entry for new averaged correlation
                    PCFData.Cor(end+1).Bins = Bins;
                    PCFData.Cor(end).File = File;
                    PCFData.Cor(end).Dist = Dist;
                    PCFData.Cor(end).Color = 1-Color/numel(Sel);
                    PCFData.Cor(end).Cor(:,1) = mean(PCFData.Data{File}.PairCor(:,Bins,Dist+1,1),2);
                    PCFData.Cor(end).Cor(:,2) = PCFData.Data{File}.PairInfo.Time;
                    PCFData.Cor(end).Cor(:,3) = std(PCFData.Data{File}.PairCor(:,Bins,Dist+1,1),0,2)/sqrt(numel(Bins));
                    %%% Updates correlation list and plot
                    Update_Cors([],[],1);
                else
                    for i = Bins
                        %%% Create entry for new averaged correlation
                        PCFData.Cor(end+1).Bins = i;
                        PCFData.Cor(end).File = File;
                        PCFData.Cor(end).Dist = Dist;
                        PCFData.Cor(end).Color = rand(1,3);
                        PCFData.Cor(end).Cor(:,1) = PCFData.Data{File}.PairCor(:,i,Dist+1,1);
                        PCFData.Cor(end).Cor(:,2) = PCFData.Data{File}.PairInfo.Time;
                        PCFData.Cor(end).Cor(:,3) = 0*PCFData.Cor(end).Cor(:,1);
                        %%% Updates correlation list and plot
                        Update_Cors([],[],1);
                    end
                end
            end
        end
    case 13 %%% Generates ROIs from selected pattern
        File = h.PCF_File.Value;
        Dist = h.PCF_Dist_Slider.Value;
        Selected = find(PCFData.Data{File}.SelectedBins);
        if ~isempty(Selected)
            Change = find(diff(Selected)-1);
            Bins = Selected(1);
            for i=1:numel(Change)
                Bins = [Bins Selected(Change(i)-1)+1 Selected(Change(i)+1)];
            end
            Bins(end+1) = Selected(end);
            Bins = reshape(Bins,2,[]);
            for i=1:size(Bins,2)
                
                %%% Saves ROI information
                PCFData.ROI.Bins{end+1}(1,1:2) = Bins(:,i);
                PCFData.ROI.Name{end+1} = ['Bins ' num2str(PCFData.ROI.Bins{end}(1)) ' to ' num2str(PCFData.ROI.Bins{end}(2))];
                PCFData.ROI.Color{end+1} = [0 1 0];
                
                %%% Creates rectangle in intensity plot
                YLim = h.Intensity_Axes.YLim;
                YLim = [YLim(1)+0.01*diff(YLim),YLim(2)-0.01*diff(YLim)];
                h.Plot.ROI{end+1,2} = line (...
                    'Parent',h.Intensity_Axes,...
                    'XData',[Bins(1,i)-0.4, Bins(1,i)-0.4, Bins(2,i)+0.4, Bins(2,i)+0.4 Bins(1,i)-0.4],...
                    'YData',[YLim(2), YLim(1), YLim(1), YLim(2), YLim(2)],...
                    'LineStyle','--',...
                    'Color',[0 1 0],...
                    'LineWidth',1);
                
                %%% Creates rectangle in carpet plot
                YLim = h.Carpet_Axes.YLim;
                if Bins(1,i)+Dist<=Bins(2,i)
                    XData = h.Plot.ROI{end,2}.XData;
                    XData(3:4) = XData(3:4)-Dist;
                else
                    XData = [Bins(1)-0.4, Bins(1)-0.4, Bins(1)+0.4, Bins(2)+0.4 Bins(1)-0.4];
                end
                h.Plot.ROI{end,1} = line (...
                    'Parent',h.Carpet_Axes,...
                    'XData',XData,...
                    'YData',[YLim(2)-0.1 YLim(1)+0.1 YLim(1)+0.1 YLim(2)-0.1 YLim(2)-0.1],...
                    'LineStyle','--',...
                    'Color',[0 1 0],...
                    'LineWidth',1);
            end
            %%% Save new plots
            guidata(h.PCF,h);
            %%% Updates ROI List
            Update_ROIs([],[],1)
        end
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions concerning correlations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Cors(~,e,mode)
global PCFData UserValues
h = guidata(findobj('Tag','PCF'));

%%% Evaluates, which key was pressed
if mode == 0
   switch e.Key
       case 'delete'
           mode = 2;
       case 'rightarrow'
           mode = 3;           
       case 'leftarrow'
           mode = 4;
       case 'add'
           mode = 5;
       case 'c'
           mode = 6;
       case 'return'
           mode = 7;
   end    
end

Sel = sort(h.Cor_List.Value, 'descend');
%%% Executes Correlation list callbacks
switch mode
    case 1 %%% Adds new averaged cor entry
        %%% Adds new correlation plot
        h.Plot.Cor{end+1} = line(...
            'Parent', h.Cor_Axes,...
            'XData', PCFData.Cor(end).Cor(:,2),...
            'YData', PCFData.Cor(end).Cor(:,1),...
            'Color', PCFData.Cor(end).Color);       
        %%% Adds new correlation list entry
        Hex_color = dec2hex(round(PCFData.Cor(end).Color*255))';
        h.Cor_List.String{end+1} = ['<HTML><FONT color=#' Hex_color(:)' '>'...
            'File' num2str(PCFData.Cor(end).File)...
            ': Distance ' num2str(PCFData.Cor(end).Dist)...
            ' of Bins ' num2str(PCFData.Cor(end).Bins)...
            '</Font></html>']; 
        %%% Save new plots
        guidata(h.PCF,h);
    case 2 %%% Delete averaged correlation
        for i = Sel
            delete(h.Plot.Cor{i});
            h.Plot.Cor(i) = [];
            PCFData.Cor(i) = [];
            h.Cor_List.String(i) =[];
        end
        h.Cor_List.Value = Sel(end)-1;
        if h.Cor_List.Value<1
            h.Cor_List.Value = [];
        end
        guidata(h.PCF,h);
    case 3 %%% Activate correlation plot
        for i = Sel
           h.Plot.Cor{i}.Visible = 'on';
           uistack(h.Plot.Cor{i},'top');
           Hex_color = dec2hex(round(PCFData.Cor(i).Color*255))';
           h.Cor_List.String{i}(20:25) = Hex_color(:)'; 
        end        
    case 4 %%% Deactivate correlation plot
        for i = Sel
           h.Plot.Cor{i}.Visible = 'off';
           h.Cor_List.String{i}(20:25) = '000000'; 
        end
    case 5 %%% Average averaged correlations
        PCFData.Cor(end+1).Cor(:,2) = PCFData.Cor(Sel(1)).Cor(:,2);
        PCFData.Cor(end).Cor(:,3) = 0*PCFData.Cor(Sel(1)).Cor(:,2);
        PCFData.Cor(end).Color = [0 0 0];
        Bins = 0;
        for i = Sel
            PCFData.Cor(end).Color = PCFData.Cor(end).Color + PCFData.Cor(i).Color;
            %%% Weighted average of subsets;
            PCFData.Cor(end).Cor(:,1) = (Bins*PCFData.Cor(end).Cor(:,1) + numel(PCFData.Cor(i).Bins)*PCFData.Cor(i).Cor(:,1))/(Bins+numel(PCFData.Cor(i).Bins));            
            %%% Needed for SEM calculation
            N1 = Bins^2-Bins;
            N2 = numel(PCFData.Cor(i).Bins)^2-numel(PCFData.Cor(i).Bins);
            N =  (Bins+numel(PCFData.Cor(i).Bins))^2-(Bins+numel(PCFData.Cor(i).Bins));
            %%% Standard error of mean for two subsets of data with errors
            PCFData.Cor(end).Cor(:,3) = sqrt(N1/N*PCFData.Cor(end).Cor(:,3).^2+...
                                             N2/N*PCFData.Cor(i).Cor(:,3).^2+...
                                             Bins*numel(PCFData.Cor(i).Bins)/(Bins+numel(PCFData.Cor(i).Bins))/N*...
                                             (PCFData.Cor(end).Cor(:,1)+PCFData.Cor(i).Cor(:,1)).^2);
            Bins = Bins + numel(PCFData.Cor(i).Bins);   
        end
        PCFData.Cor(end).Cor(:,1) = PCFData.Cor(end).Cor(:,1);
        PCFData.Cor(end).Color = PCFData.Cor(end).Color/numel(Sel);
        PCFData.Cor(end).File = 0;
        PCFData.Cor(end).Bins = Bins;
        PCFData.Cor(end).Dist = PCFData.Cor(Sel(1)).Dist;
        
        %%% Adds new correlation plot
        h.Plot.Cor{end+1} = line(...
            'Parent', h.Cor_Axes,...
            'XData', PCFData.Cor(end).Cor(:,2),...
            'YData', PCFData.Cor(end).Cor(:,1),...
            'Color', PCFData.Cor(end).Color);
        %%% Adds new correlation list entry
        Hex_color = dec2hex(round(PCFData.Cor(end).Color*255))';
        h.Cor_List.String{end+1} = ['<HTML><FONT color=#' Hex_color(:)' '>'...
            'Averaged correlation of distance ' num2str(PCFData.Cor(end).Dist)...
            ' with ' num2str(PCFData.Cor(end).Bins) ' Bins</Font></html>'];
        %%% Save new plots
        guidata(h.PCF,h);
    case 6 %%% Change color
        Color=uisetcolor;
        %%% Checks, if color was selected
        if numel(Color)==3
            for i=Sel
                PCFData.Cor(i).Color = Color;
                h.Plot.Cor{i}.Color = Color;
                Hex_color = dec2hex(round(Color*255))';
                h.Cor_List.String{i}(20:25) = Hex_color(:)';
                h.Plot.Cor{i}.Visible = 'on';
            end
        end
    case 7 %%% Save correlation
        for i = Sel
            [FileName,PathName] = uiputfile('*.mcor','Save Pair Correlation',UserValues.File.FCSPath);
            if any(FileName~=0)
                UserValues.File.FCSPath = PathName;
                LSUserValues(1);
                Cor_Array = PCFData.Cor(i).Cor(:,1)'; %#ok<NASGU>
                Cor_Average = PCFData.Cor(i).Cor(:,1)'; %#ok<NASGU>
                Cor_Times = PCFData.Cor(i).Cor(:,2)'; %#ok<NASGU>
                Cor_SEM = PCFData.Cor(i).Cor(:,3)'; %#ok<NASGU>
                Counts = [0,0]; %#ok<NASGU>
                Valid = 1; %#ok<NASGU>
                Header = ['Pair correlation file of distance'  num2str(PCFData.Cor(i).Dist)]; %#ok<NASGU>
                save(fullfile(PathName,FileName),'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
            end
        end
end
Update_Plots([],[],3)










