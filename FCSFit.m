function FCSFit(~,~)
global UserValues FCSData FCSMeta
h.FCSFit=findobj('Tag','FCSFit');

if isempty(h.FCSFit) % Creates new figure, if none exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Figure generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    %%% Disables uitabgroup warning
    warning('off','MATLAB:uitabgroup:OldVersion');   
    %%% Loads user profile    
    [~,~]=LSUserValues(0);
    %%% To save typing
    Look=UserValues.Look;    
    %%% Generates the FCSFit figure
    h.FCSFit = figure(...
        'Units','normalized',...
        'Tag','FCSFit',...
        'Name','FCSFit',...
        'NumberTitle','off',...
        'Menu','none',...
        'defaultUicontrolFontName','Times',...
        'defaultAxesFontName','Times',...
        'defaultTextFontName','Times',...
        'Toolbar','figure',...
        'UserData',[],...
        'OuterPosition',[0.01 0.1 0.98 0.9],...
        'CloseRequestFcn',@Close_FCSFit,...
        'Visible','on');
    %h.FCSFit.Visible='off';
    
    %%% Sets background of axes and other things
    whitebg(Look.Axes);
    %%% Changes Pam background; must be called after whitebg
    h.FCSFit.Color=Look.Back;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    %%% File menu with loading, saving and exporting functions
    h.File = uimenu(...
        'Parent',h.FCSFit,...
        'Tag','File',...
        'Label','File');
    %%% Menu to load new Cor file
    h.LoadCor = uimenu(h.File,...
        'Tag','LoadCor',...
        'Label','Load New Cor Files',...
        'Callback',{@Load_Cor,1});
    %%% Menu to add Cor files to existing
    h.AddCor = uimenu(h.File,...
        'Tag','AddCor',...
        'Label','Add Cor Files',...
        'Callback',{@Load_Cor,2});
    %%% Menu to load fit function
    h.LoadFit = uimenu(h.File,...
        'Tag','LoadFit',...
        'Label','Load Fit Function',...
        'Callback',{@Load_Fit,1});
    %%% File menu for fitting
    h.DoFit = uimenu(...
        'Parent',h.FCSFit,...
        'Tag','Fit',...
        'Label','Fit',...
        'Callback',@Do_FCSFit);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fitting parameters Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Microtime tabs container
    h.FitParams_Tab = uitabgroup(...
        'Parent',h.FCSFit,...
        'Tag','FitParams_Tab',...
        'Units','normalized',...
        'Position',[0.005 0.01 0.99 0.24]);
    %% Fit function tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Tab for fit function inputs
    h.Fit_Function_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Fit_Function_Tab',...
        'Title','Fit');    
    %%% Panel for fit function inputs
    h.Fit_Function_Panel = uibuttongroup(...
        'Parent',h.Fit_Function_Tab,...
        'Tag','Fit_Function_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Fitting table
    h.Fit_Table = uitable(...
        'Parent',h.Fit_Function_Panel,...
        'Tag','Fit_Table',...
        'Units','normalized',...
        'BackgroundColor',[Look.Axes;Look.Fore],...
        'ForegroundColor',Look.Disabled,...
        'FontSize',8,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_Table,3},...
        'CellSelectionCallback',{@Update_Table,3});
    %% Settings tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Tab for fit settings
    h.Setting_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Setting_Tab',...
        'Title','Settings');    
    %%% Panel for fit settings
    h.Setting_Panel = uibuttongroup(...
        'Parent',h.Setting_Tab,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Text
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Borders [s]:',...
        'Position',[0.002 0.88 0.06 0.1]);
    %%% Minimum and maximum for fitting and plotting
    h.Fit_Min = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Fit_Min),...
        'Callback',@Update_Plots,...
        'Position',[0.066 0.88 0.04 0.1]);
    h.Fit_Max = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Fit_Max),...
        'Callback',@Update_Plots,...
        'Position',[0.11 0.88 0.04 0.1]);
    %%% Checkbox to toggle using weights
    h.Fit_Weights = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Fit_Weights',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Use weights',...
        'Value',UserValues.FCSFit.Use_Weights,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.76 0.1 0.1]);
    %%% Checkbox to toggle errorbar plotting
    h.Fit_Errorbars = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Fit_Errorbars',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Plot errorbars',...
        'Value',UserValues.FCSFit.Plot_Errorbars,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.64 0.1 0.1]); 
    %%% Text
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Setting_Panel',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Normalization:',...
        'Position',[0.002 0.51 0.08 0.1]);
    %%% Popupmenu to choose normalization method
    h.Normalize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Normalize',...
        'Units','normalized',...
        'FontSize',10,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','popupmenu',...
        'String',{'None';'Fit N 3D';'Fit G(0)';'Fit N 2D'; 'Time'},...
        'Value',UserValues.FCSFit.NormalizationMethod,...
        'Callback',@Update_Plots,...
        'Position',[0.082 0.52 0.06 0.1]); 
    %%% Editbox to set time used for normalization
    h.Norm_Time = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Normalize',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String','1e-6',...
        'Visible','off',...
        'Callback',@Update_Plots,...
        'Position',[0.145 0.51 0.04 0.1]);  
    %%% Checkbox to toggle confidence interval calculation
    h.Conf_Interval = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Style','checkbox',...
        'String','Calculate confidence intervals',...
        'Value',UserValues.FCSFit.Conf_Interval,...
        'Callback',@Update_Plots,...
        'Position',[0.002 0.38 0.2 0.1]); 
    %%% Optimization settings
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Max interations:',...
        'Position',[0.2 0.88 0.08 0.1]);  
    h.Iterations = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Iterations',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Max_Iterations),...
        'Position',[0.285 0.88 0.04 0.1]);
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Tolerance:',...
        'Position',[0.2 0.76 0.08 0.1]);  
    h.Tolerance = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Tolerance',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String',num2str(UserValues.FCSFit.Fit_Tolerance),...
        'Position',[0.285 0.76 0.04 0.1]);
    %%% Textbox containing optimization termination output
    h.Termination = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Termination',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','',...
        'Position',[0.35 0.01 0.13 0.98]);    
    
    %%% Text for export size
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Export size (X; Cor Y; Residuals Y) [pixels]:',...
        'Position',[0.6 0.88 0.23 0.1]);
    %%% Editbox for export size in X
    h.Export_XSize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String','300',...
        'Position',[0.83 0.88 0.04 0.1]);
    %%% Editbox for export size in Y for correlation
    h.Export_YSize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String','150',...
        'Position',[0.875 0.88 0.04 0.1]); 
    %%% Editbox for export size in Y for residuals
    h.Export_YSizeRes = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','edit',...
        'String','50',...
        'Position',[0.92 0.88 0.04 0.1]); 
    %%% Text for font name
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Font name:',...
        'Position',[0.6 0.75 0.06 0.1]);
    %%% Editbox for font name
    h.Export_FontName = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...        
        'Style','edit',...
        'String','Arial',...
        'Position',[0.66 0.75 0.13 0.1]);
    %%% Text for font size
    uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HorizontalAlignment','left',...
        'Style','text',...
        'String','Font size:',...
        'Position',[0.82 0.75 0.05 0.1]);
    %%% Editbox for font size
    h.Export_FontSize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...   
        'Style','edit',...
        'String','10',...
        'Position',[0.875 0.75 0.04 0.1]);    
    %%% Checkbox for grid lines
    h.Export_Grid = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...   
        'Value',1,...
        'Style','checkbox',...
        'String','Grid',...
        'Position',[0.6 0.62 0.04 0.1]);  
    %%% Checkbox for minor grid lines
    h.Export_MinorGrid = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',1,...
        'Style','checkbox',...
        'String','Minor Grid',...
        'Position',[0.65 0.62 0.09 0.1]);
    %%% Checkbox for box
    h.Export_Box = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',1,...
        'Style','checkbox',...
        'String','Box',...
        'Position',[0.735 0.62 0.04 0.1]);
    %%% Checkbox for fit legend entry
    h.Export_FitsLegend = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'Value',0,...
        'Style','checkbox',...
        'String','Fits in legend',...
        'Position',[0.78 0.62 0.15 0.1]);
    %% Plotting style tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Tab for fit function inputs
    h.Style_Tab= uitab(...
        'Parent',h.FitParams_Tab,...
        'Tag','Style_Tab',...
        'Title','Plotting style');    
    %%% Panel for fit function inputs
    h.Style_Panel = uibuttongroup(...
        'Parent',h.Style_Tab,...
        'Tag','Style_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0 0 1 1]);
    %%% Fitting table
    h.Style_Table = uitable(...
        'Parent',h.Style_Panel,...
        'Tag','Fit_Table',...
        'Units','normalized',...
        'BackgroundColor',[Look.Axes;Look.Fore],...
        'ForegroundColor',Look.Disabled,...
        'FontSize',8,...
        'Position',[0 0 1 1],...
        'CellEditCallback',{@Update_Style,2},...
        'CellSelectionCallback',{@Update_Style,2});
    %%% Button for exporting excel sheet of results
    h.Export_Clipboard = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...   
        'Value',1,...
        'Style','pushbutton',...
        'String','Copy Results to Clipboard',...
        'Callback',{@Plot_Menu_Callback,4},...
        'Position',[0.6 0.42 0.1 0.1]);  
%% Main Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Panel for fit plots
    h.Fit_Plots_Panel = uibuttongroup(...
        'Parent',h.FCSFit,...
        'Tag','Fit_Plots_Panel',...
        'Units','normalized',...
        'BackgroundColor', Look.Back,...
        'ForegroundColor', Look.Fore,...
        'HighlightColor', Look.Control,...
        'ShadowColor', Look.Shadow,...
        'Position',[0.005 0.26 0.99 0.73]);
    
    %%% Context menu for FCS plots 
    h.FCS_Plot_Menu = uicontextmenu;
    h.FCS_Plot_XLog = uimenu(...
        'Parent',h.FCS_Plot_Menu,...
        'Label','X Log',...
        'Tag','FCS_Plot_XLog',...
        'Checked','on',...
        'Callback',{@Plot_Menu_Callback,1});
    h.FCS_Plot_Export2Fig = uimenu(...
        'Parent',h.FCS_Plot_Menu,...
        'Label','Export to figure',...
        'Checked','off',...
        'Tag','FCS_Plot_Export2Fig',...
        'Callback',{@Plot_Menu_Callback,2});
    h.FCS_Plot_Export2Base = uimenu(...
        'Parent',h.FCS_Plot_Menu,...
        'Label','Export to workspace',...
        'Checked','off',...
        'Tag','FCS_Plot_Export2Base',...
        'Callback',{@Plot_Menu_Callback,3});
   
    %%% Main axes for fcs plots
    h.FCS_Axes = axes(...
        'Parent',h.Fit_Plots_Panel,...
        'Tag','Fit_Axes',...
        'Units','normalized',...
        'FontSize',12,...
        'NextPlot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XScale','log',...
        'XLim',[10^-6,1],...
        'YColor',Look.Fore,...
        'UIContextMenu',h.FCS_Plot_Menu,...
        'Position',[0.06 0.28 0.93 0.7],...
        'Box','off');
    h.FCS_Axes.XLabel.String = 'Time Lag {\it\tau{}} [s]';
    h.FCS_Axes.XLabel.Color = Look.Fore;
    h.FCS_Axes.YLabel.String = 'G({\it\tau{}})';
    h.FCS_Axes.YLabel.Color = Look.Fore;  

    %%% Axes for fcs residuals
    h.Residuals_Axes = axes(...
        'Parent',h.Fit_Plots_Panel,...
        'Tag','Residuals_Axes',...
        'Units','normalized',...
        'FontSize',12,...
        'NextPlot','add',...
        'XColor',Look.Fore,...
        'YColor',Look.Fore,...
        'XScale','log',...
        'XAxisLocation','top',...
        'YColor',Look.Fore,...
        'Position',[0.06 0.02 0.93 0.18],...
        'Box','off',...
        'YGrid','on',...
        'XGrid','on');
    h.Residuals_Axes.GridColorMode = 'manual';
    h.Residuals_Axes.GridColor = [0 0 0];
    h.Residuals_Axes.XTickLabel=[];
    h.Residuals_Axes.YLabel.String = 'Weighted residuals';
    h.Residuals_Axes.YLabel.Color = Look.Fore;
    
    linkaxes([h.FCS_Axes h.Residuals_Axes],'x');
%% Mac upscaling of Font Sizes
if ismac
    scale_factor = 1.2;
    fields = fieldnames(h); %%% loop through h structure
    for i = 1:numel(fields)
        if isprop(h.(fields{i}),'FontSize')
            h.(fields{i}).FontSize = (h.(fields{i}).FontSize)*scale_factor;
        end
        if isprop(h.(fields{i}),'Style')
            if strcmp(h.(fields{i}).Style,'popupmenu')
                h.(fields{i}).BackgroundColor = Look.Fore;
                h.(fields{i}).ForegroundColor = Look.Back;
            end
        end
    end   
end
    
%% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FCSData=[];
    FCSData.Data=[];
    FCSData.FileName=[];
    FCSMeta=[];
    FCSMeta.Data=[];
    FCSMeta.Params=[];
    FCSMeta.Confidence_Intervals = cell(1,1);
    FCSMeta.Plots=cell(0);
    FCSMeta.Model=[];
    FCSMeta.Fits=[];
    FCSMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 0.5 0; 1 0 1; 0 1 1];
    
    
    guidata(h.FCSFit,h); 
    Load_Fit([],[],0);
    Update_Style([],[],0) 
else
    figure(h.FCSFit); % Gives focus to Pam figure  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to close figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_FCSFit(Obj,~)
clear global -regexp FCSData FCSMeta
Phasor=findobj('Tag','Phasor');
Pam=findobj('Tag','Pam');
MIAFit=findobj('Tag','MIAFit');
Mia=findobj('Tag','Mia');
Sim=findobj('Tag','Sim');
PCF=findobj('Tag','PCF');
BurstBrowser=findobj('Tag','BurstBrowser');
TauFit=findobj('Tag','TauFit');
if isempty(Phasor) && isempty(Pam) && isempty(MIAFit) && isempty(PCF) && isempty(Mia) && isempty(Sim) && isempty(TauFit) && isempty(BurstBrowser)
    clear global -regexp UserValues
end
delete(Obj);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .cor files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Cor(~,~,mode)
global UserValues FCSData FCSMeta
h = guidata(findobj('Tag','FCSFit'));

%%% Choose files to load
[FileName,PathName,Type] = uigetfile({'*.mcor','Averaged correlation based on matlab filetype';...
                                      '*.cor','Averaged correlation based on .txt. filetype';...
                                      '*.mcor','Individual correlation curves based on matlab filetype';...
                                      '*.cor','Individual correlation curves based on .txt. filetype';},...
                                      'Choose a referenced data file',...
                                      UserValues.File.FCSPath,... 
                                      'MultiSelect', 'on');
%%% Tranforms to cell array, if only one file was selected
if ~iscell(FileName)
    FileName = {FileName};
end

%%% Only esecutes, if at least one file was selected
if all(FileName{1}==0)
    return
end

%%% Saves pathname to uservalues
UserValues.File.FCSPath=PathName;
LSUserValues(1);
%%% Deletes loaded data
if mode==1
    FCSData=[];
    FCSData.Data=[];
    FCSData.FileName=[];
    cellfun(@delete,FCSMeta.Plots);
    FCSMeta.Data=[];
    FCSMeta.Params=[];
    FCSMeta.Plots=cell(0);
    h.Fit_Table.RowName(1:end-3)=[];
    h.Fit_Table.Data(1:end-3,:)=[];
    h.Style_Table.RowName(1:end-1,:)=[];
    h.Style_Table.Data(1:end-1,:)=[];
end

switch Type
    case {1,2} %%% Averaged correlation files
        for i=1:numel(FileName)
            %%% Reads files (1 == .mcor; 2 == .cor)
            if Type == 1
                FCSData.Data{end+1} = load([PathName FileName{i}],'-mat');
            else                
                FID = fopen(fullfile(PathName,FileName{i}));
                Text = textscan(FID,'%s', 'delimiter', '\n','whitespace', '');
                Text = Text{1};
                Data.Header = Text{1};
                Data.Valid = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Valid bins:')),1)}(12:end)); %#ok<ST2NM>
                Data.Counts(1) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 1 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Data.Counts(2) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 2 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Start = find(~cellfun(@isempty,strfind(Text,'Data starts here:')),1);
                
                Values = zeros(numel(Text)-Start,numel(Data.Valid)+3);
                k=1;
                for j = Start+1:numel(Text)
                    Values(k,:) = str2num(Text{j});  %#ok<ST2NM>
                    k = k+1;
                end
                Data.Cor_Times = Values(:,1);
                Data.Cor_Average = Values(:,2);
                Data.Cor_SEM = Values(:,3);
                Data.Cor_Array = Values(:,4:end);
                FCSData.Data{end+1} = Data;
            end
            %%% Updates global parameters
            FCSData.FileName{end+1} = FileName{i}(1:end-5);
            FCSMeta.Data{end+1,1} = FCSData.Data{end}.Cor_Times;
            FCSMeta.Data{end,2} = FCSData.Data{end}.Cor_Average;
            FCSMeta.Data{end,3} = FCSData.Data{end}.Cor_SEM;
            %%% Creates new plots
            FCSMeta.Plots{end+1,1} = errorbar(...
                FCSMeta.Data{end,1},...
                FCSMeta.Data{end,2},...
                FCSMeta.Data{end,3},...
                'Parent',h.FCS_Axes);
            FCSMeta.Plots{end,2} = line(...
                'Parent',h.FCS_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',zeros(numel(FCSMeta.Data{end,1}),1));
            FCSMeta.Plots{end,3} = line(...
                'Parent',h.Residuals_Axes,...
                'XData',FCSMeta.Data{end,1},...
                'YData',zeros(numel(FCSMeta.Data{end,1}),1));
            FCSMeta.Params(:,end+1) = cellfun(@str2double,h.Fit_Table.Data(end-2,4:3:end-1));
        end
    case {3,4} %% Individual curves from correlation files
        for i=1:numel(FileName)
            %%% Reads files (3 == .mcor; 4 == .cor)
            if Type == 3
                Data = load([PathName FileName{i}],'-mat');
            else
                FID = fopen(fullfile(PathName,FileName{i}));
                Text = textscan(FID,'%s', 'delimiter', '\n','whitespace', '');
                Text = Text{1};
                Data.Header = Text{1};
                Data.Valid = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Valid bins:')),1)}(12:end)); %#ok<ST2NM>
                Data.Counts(1) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 1 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Data.Counts(2) = str2num(Text{find(~cellfun(@isempty,strfind(Text,'Countrate channel 2 [kHz]:')),1)}(27:end)); %#ok<ST2NM>
                Start = find(~cellfun(@isempty,strfind(Text,'Data starts here:')),1);
                
                Values = zeros(numel(Text)-Start,numel(Data.Valid)+3);
                k=1;
                for j = Start+1:numel(Text)
                    Values(k,:) = str2num(Text{j});  %#ok<ST2NM>
                    k = k+1;
                end
                Data.Cor_Times = Values(:,1);
                Data.Cor_Average = Values(:,2);
                Data.Cor_SEM = Values(:,3);
                Data.Cor_Array = Values(:,4:end);
            end           
            %%% Creates entry for each individual curve
            for j=1:size(Data.Cor_Array,2)
                FCSData.Data{end+1} = Data;
                FCSData.FileName{end+1} = [FileName{i}(1:end-5) ' Curve ' num2str(Data.Valid(j))];
                FCSMeta.Data{end+1,1} = FCSData.Data{end}.Cor_Times;
                FCSMeta.Data{end,2} = FCSData.Data{end}.Cor_Array(:,j);
                FCSMeta.Data{end,3} = FCSData.Data{end}.Cor_SEM;
                %%% Creates new plots
                FCSMeta.Plots{end+1,1} = errorbar(...
                    FCSMeta.Data{end,1},...
                    FCSMeta.Data{end,2},...
                    FCSMeta.Data{end,3},...
                    'Parent',h.FCS_Axes);
                FCSMeta.Plots{end,2} = line(...
                    'Parent',h.FCS_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',zeros(numel(FCSMeta.Data{end,1}),1));
                FCSMeta.Plots{end,3} = line(...
                    'Parent',h.Residuals_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',zeros(numel(FCSMeta.Data{end,1}),1));
                FCSMeta.Params(:,end+1) = cellfun(@str2double,h.Fit_Table.Data(end-2,4:3:end-1));
            end
        end
end

%%% Updates table and plot data and style to new size
Update_Style([],[],1);
Update_Table([],[],1);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Fit(~,~,mode)
global FCSMeta UserValues

FileName=[];
if mode
    %% Select a new model to load
    [FileName,PathName]= uigetfile('.txt', 'Choose a fit model', [pwd filesep 'Models']);
    FileName=fullfile(PathName,FileName);
elseif isempty(UserValues.File.FCS_Standard) || ~exist(UserValues.File.FCS_Standard,'file') 
    %% Opens the first model in the folder at the start of the program
    Models=dir([pwd filesep 'Models']);
    Models=Models(~cell2mat({Models.isdir}));
    while isempty(FileName) && ~isempty(Models)
       if strcmp(Models(1).name(end-3:end),'.txt') 
           FileName=[pwd filesep 'Models' filesep Models(1).name];
           UserValues.File.FCS_Standard=FileName;
       else
           Models(1)=[];
       end
    end
else
    %% Opens last model used before closing program
    FileName=UserValues.File.FCS_Standard;
end

if ~isempty(FileName)
    UserValues.File.FCS_Standard=FileName;
    LSUserValues(1);
    
    %%% change encoding on mac
    if ismac
        feature('DefaultCharacterSet', 'windows-1252');
    end
    %%% Reads in the selected fit function file
    fid = fopen(FileName);
    Text=textscan(fid,'%s', 'delimiter', '\n','whitespace', '');
    Text=Text{1};
    
    %%% Finds line, at which parameter definition starts
    Param_Start=find(~cellfun(@isempty,strfind(Text,'-PARAMETER DEFINITION-')),1);
    %%% Finds line, at which function definition starts
    Fun_Start=find(~cellfun(@isempty,strfind(Text,'-FIT FUNCTION-')),1);
    B_Start=find(~cellfun(@isempty,strfind(Text,'-BRIGHTNESS DEFINITION-')),1);
    %%% Defines the number of parameters
    NParams=B_Start-Param_Start-1;
    FCSMeta.Model=[];
    FCSMeta.Model.Name=FileName;
    FCSMeta.Model.Brightness=Text{B_Start+1};
    %%% Concaternates the function string
    FCSMeta.Model.Function=[];
    for i=Fun_Start+1:numel(Text)
        FCSMeta.Model.Function=[FCSMeta.Model.Function Text(i)];
    end
    FCSMeta.Model.Function=cell2mat(FCSMeta.Model.Function);
    %%% Convert to function handle
    eval(['FCSMeta.Model.Function = @(P,x) ' FCSMeta.Model.Function(5:end)]);
    %%% Extracts parameter names and initial values
    FCSMeta.Model.Params=cell(NParams,1);
    FCSMeta.Model.Value=zeros(NParams,1);
    FCSMeta.Model.LowerBoundaries = zeros(NParams,1);
    FCSMeta.Model.UpperBoundaries = zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        Param_Pos=strfind(Text{i+Param_Start},' ');
        FCSMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        Start = strfind(Text{i+Param_Start},'=');
        Stop = strfind(Text{i+Param_Start},';');

        FCSMeta.Model.Value(i) = str2double(Text{i+Param_Start}(Start(1)+1:Stop(1)-1));
        FCSMeta.Model.LowerBoundaries(i) = str2double(Text{i+Param_Start}(Start(2)+1:Stop(2)-1));   
        FCSMeta.Model.UpperBoundaries(i) = str2double(Text{i+Param_Start}(Start(3)+1:Stop(3)-1));
    end    
    FCSMeta.Params=repmat(FCSMeta.Model.Value,[1,size(FCSMeta.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(findobj('Tag','FCSFit'));
global FCSMeta FCSData
switch mode
    case 0 %%% Updates whole table (Load Fit etc.)
        
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];        
        %%% Generates column names and resized them
        Columns=cell(3*numel(FCSMeta.Model.Params)+4,1);
        Columns{1}='Active';
        Columns{2}='<HTML><b> Counts [khz] </b>';
        Columns{3}='<HTML><b> Brightness [khz]</b>';
        for i=1:numel(FCSMeta.Model.Params)
            Columns{3*i+1}=['<HTML><b>' FCSMeta.Model.Params{i} '</b>'];
            Columns{3*i+2}='F';
            Columns{3*i+3}='G';
        end
        Columns{end}='Chi2';
        ColumnWidth=zeros(numel(Columns),1);
        %ColumnWidth(4:3:end-1)=cellfun('length',FCSMeta.Model.Params).*7;
        ColumnWidth(4:3:end-1) = 80;
        ColumnWidth(ColumnWidth>0 & ColumnWidth<30)=45;
        ColumnWidth(5:3:end-1)=20;
        ColumnWidth(6:3:end-1)=20;
        ColumnWidth(1)=40;
        ColumnWidth(2)=80;
        ColumnWidth(3)=100;
        ColumnWidth(end)=40;
        h.Fit_Table.ColumnName=Columns;
        h.Fit_Table.ColumnWidth=num2cell(ColumnWidth');        
        %%% Sets row names to file names 
        Rows=cell(numel(FCSData.Data)+3,1);
        Rows(1:numel(FCSData.Data))=deal(FCSData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.Fit_Table.RowName=Rows;         
        %%% Creates table data:
        %%% 1: Checkbox to activate/deactivate files
        %%% 2: Countrate of file
        %%% 3: Brightness if file
        %%% 4:3:end: Parameter value
        %%% 5:3:end: Checkbox to fix parameter
        %%% 6:3:end: Checkbox to fit parameter globaly
        Data=num2cell(zeros(numel(Rows),numel(Columns)));
        for i=1:(numel(Rows)-3)
            %%% Distinguish between Autocorrelation (only take Counts of
            %%% Channel) and Crosscorrelation (take sum of Channels)
            if FCSData.Data{i}.Counts(1) == FCSData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(FCSData.Data{i}.Counts(1));
            elseif FCSData.Data{i}.Counts(1) ~= FCSData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(FCSData.Data{i}.Counts));
            end
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(FCSMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(FCSMeta.Model.Value)');
        %Data(end-1,4:3:end-1)=deal({-inf});
        %Data(end,4:3:end-1)=deal({inf});
        Data(end-1,4:3:end-1)=deal(num2cell(FCSMeta.Model.LowerBoundaries)');
        Data(end,4:3:end-1)=deal(num2cell(FCSMeta.Model.UpperBoundaries)');
        Data=cellfun(@num2str,Data,'UniformOutput',false);
        Data(:,1)=deal({true});
        Data(:,5:3:end-1)=deal({false});
        Data(:,6:3:end-1)=deal({false});
        Data(:,1)=deal({true});
        Data(:,end)=deal({'0'});
        h.Fit_Table.Data=Data;
        h.Fit_Table.ColumnEditable=[true,false,false,true(1,numel(Columns)-4),false];        
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 1 %%% Updates tables when new data is loaded
        h.Fit_Table.CellEditCallback=[];
        %%% Sets row names to file names 
        Rows=cell(numel(FCSData.Data)+3,1);
        Rows(1:numel(FCSData.Data))=deal(FCSData.FileName);
        Rows{end-2}='ALL';
        Rows{end-1}='Lower bound';
        Rows{end}='Upper bound';
        h.Fit_Table.RowName=Rows;
        
        Data=cell(numel(Rows),size(h.Fit_Table.Data,2));
        %%% Set last 3 row to ALL, lb and ub
        Data(1:(size(h.Fit_Table.Data,1)-3),:)=h.Fit_Table.Data(1:end-3,:);
        %%% Sets previous files
        Data(end-2:end,:)=h.Fit_Table.Data(end-2:end,:);
        %%% Adds new files
        Data((size(h.Fit_Table.Data,1)-2):(end-3),:)=repmat(h.Fit_Table.Data(end-2,:),[numel(Rows)-(size(h.Fit_Table.Data,1)),1]);
        %%% Calculates countrate
        for i=1:numel(FCSData.Data)
            %%% Distinguish between Autocorrelation (only take Counts of
            %%% Channel) and Crosscorrelation (take sum of Channels)
            if FCSData.Data{i}.Counts(1) == FCSData.Data{i}.Counts(2)
                %%% Autocorrelation
                Data{i,2}=num2str(FCSData.Data{i}.Counts(1));
            elseif FCSData.Data{i}.Counts(1) ~= FCSData.Data{i}.Counts(2)
                %%% Crosscorrelation
                Data{i,2}=num2str(sum(FCSData.Data{i}.Counts));
            end
        end
        h.Fit_Table.Data=Data;
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2 %%% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates Brightness in Table
        for i=1:(size(h.Fit_Table.Data,1)-3)
            P=FCSMeta.Params(:,i);
            eval(FCSMeta.Model.Brightness);
            h.Fit_Table.Data{i,3}= num2str(str2double(h.Fit_Table.Data{i,2}).*B);
        end
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,4:3:end-1)=cellfun(@num2str,num2cell(FCSMeta.Params)','UniformOutput',false);
        %%% Updates plots
        Update_Plots        
        %%% Enables cell callback again        
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 3 %%% Individual cells calbacks 
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(1)~=(size(h.Fit_Table.Data,1)-2) && e.Indices(2)~=1)
                h.Fit_Table.CellEditCallback={@Update_Table,3};
                return;
            end
            NewData = h.Fit_Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end
        if e.Indices(1)==size(h.Fit_Table.Data,1)-2
            %% ALL row wase used => Applies to all files
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4
                %% Value was changed => Apply value to global variables
                FCSMeta.Params((e.Indices(2)-1)/3,:)=str2double(NewData);
            elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=6 && NewData==1
                %% Value was fixed => Uncheck global
                h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
            elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && NewData==1
                %% Global was change
                %%% Apply value to all files
                h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Apply value to global variables
                FCSMeta.Params((e.Indices(2)-3)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
                %%% Unfixes all files to prohibit fixed and global
                h.Fit_Table.Data(:,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Global was changed => Applies to all files
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
            if NewData
                %%% Apply value to all files
                h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Apply value to global variables
                FCSMeta.Params((e.Indices(2)-3)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
                %%% Unfixes all file to prohibit fixed and global
                h.Fit_Table.Data(1:end-2,e.Indices(2)-1)=deal({false});
            end
        elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=5 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Value was fixed
            %%% Updates ALL row
            if all(cell2mat(h.Fit_Table.Data(1:end-3,e.Indices(2))))
                h.Fit_Table.Data{end-2,e.Indices(2)}=true;
            else
                h.Fit_Table.Data{end-2,e.Indices(2)}=false;
            end
            %%% Unchecks global to prohibit fixed and global
            h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false;});
        elseif mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4 && e.Indices(1)<size(h.Fit_Table.Data,1)-1
            %% Value was changed
            if h.Fit_Table.Data{e.Indices(1),e.Indices(2)+2}
                %% Global => changes value of all files
                h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({NewData});
                FCSMeta.Params((e.Indices(2)-1)/3,:)=str2double(NewData);
            else
                %% Not global => only changes value
                FCSMeta.Params((e.Indices(2)-1)/3,e.Indices(1))=str2double(NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
        end       
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end

%%% Updates plots to changes models
Update_Plots;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(~,e,mode) 
global FCSMeta FCSData UserValues
h = guidata(findobj('Tag','FCSFit'));
LSUserValues(0);
switch mode
    case 0 %%% Called at the figure initialization
        %%% Generates the table column and cell names
        Columns=cell(11,1);
        Columns{1}='Color';
        Columns{2}='Data LineStyle';
        Columns{3}='Data LineWidth';
        Columns{4}='Data Marker';
        Columns{5}='Data MarkerSize';
        Columns{6}='Fit LineStyle';
        Columns{7}='Fit LineWidth';
        Columns{8}='Fit Marker';
        Columns{9}='Fit MarkerSize';   
        Columns{10}='Remove';
        Columns{11}='Rename';
        h.Style_Table.ColumnName=Columns;
        h.Style_Table.RowName={'ALL'};
        
        %%% Generates the initial cell inputs
        h.Style_Table.ColumnEditable=true;
        h.Style_Table.ColumnFormat={'char',{'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char',...
                                           {'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char','logical','logical'};
        h.Style_Table.Data=UserValues.FCSFit.PlotStyleAll(1:8);        
    case 1 %%% Called, when new file is loaded
        %%% Sets row names to file names 
        Rows=cell(numel(FCSData.Data)+1,1);
        Rows(1:numel(FCSData.Data))=deal(FCSData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        Data(end,1:8)=UserValues.FCSFit.PlotStyleAll(1:8);
        %%% Sets previous styles to first rows
        for i=1:numel(FCSData.Data)
            if i<=size(UserValues.FCSFit.PlotStyles,1)
                Data(i,1:8) = UserValues.FCSFit.PlotStyles(i,1:8);
            else
                Data(i,:) = UserValues.FCSFit.PlotStyles(end,1:8);
            end
        end
        %%% Updates new plots to style
        for i=1:numel(FCSData.FileName)
%            Data{i,1}=num2str(FCSMeta.Color(mod(i,6)+1,:));
%            FCSMeta.Plots{i,1}.Color=FCSMeta.Color(mod(i,6)+1,:);
%            FCSMeta.Plots{i,2}.Color=FCSMeta.Color(mod(i,6)+1,:);
%            FCSMeta.Plots{i,3}.Color=FCSMeta.Color(mod(i,6)+1,:);
           FCSMeta.Plots{i,1}.Color=num2str(Data{i,1});
           FCSMeta.Plots{i,2}.Color=num2str(Data{i,1});
           FCSMeta.Plots{i,3}.Color=num2str(Data{i,1});
           FCSMeta.Plots{i,1}.LineStyle=Data{i,2};
           FCSMeta.Plots{i,1}.LineWidth=str2double(Data{i,3});
           FCSMeta.Plots{i,1}.Marker=Data{i,4};
           FCSMeta.Plots{i,1}.MarkerSize=str2double(Data{i,5});
           FCSMeta.Plots{i,2}.LineStyle=Data{i,6};
           FCSMeta.Plots{i,3}.LineStyle=Data{i,6};
           FCSMeta.Plots{i,2}.LineWidth=str2double(Data{i,7});
           FCSMeta.Plots{i,3}.LineWidth=str2double(Data{i,7});
           FCSMeta.Plots{i,2}.Marker=Data{i,8};
           FCSMeta.Plots{i,3}.Marker=Data{i,8};
           FCSMeta.Plots{i,2}.MarkerSize=str2double(Data{i,7});
           FCSMeta.Plots{i,3}.MarkerSize=str2double(Data{i,7});
        end
        h.Style_Table.Data=Data;
    case 2 %%% Cell callback
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices) || (e.Indices(1)~=(size(h.Fit_Table.Data,1)) && e.Indices(2)~=1)
                return;
            end
            NewData = h.Style_Table.Data{e.Indices(1),e.Indices(2)};
        end
        if isprop(e,'NewData')
            NewData = e.NewData;
        end
        %%% Applies to all files if ALL row was used
        if e.Indices(1)==size(h.Style_Table.Data,1)
            File=1:(size(h.Style_Table.Data,1)-1);
            if e.Indices(2)~=1
                h.Style_Table.Data(:,e.Indices(2))=deal({NewData});
            end
        else
            File=e.Indices(1);
        end
        switch e.Indices(2)
            case 1 %%% Changes file color
                NewColor = uisetcolor;              
                for i=File
                    h.Style_Table.Data{i,1} = num2str(NewColor);
                    FCSMeta.Plots{i,1}.Color=NewColor;
                    FCSMeta.Plots{i,2}.Color=NewColor;
                    FCSMeta.Plots{i,3}.Color=NewColor;
                end
            case 2 %%% Changes data line style
                for i=File
                    FCSMeta.Plots{i,1}.LineStyle=NewData;
                end
            case 3 %%% Changes data line width
                for i=File
                    FCSMeta.Plots{i,1}.LineWidth=str2double(NewData);
                end
            case 4 %%% Changes data marker style
                for i=File
                    FCSMeta.Plots{i,1}.Marker=NewData;
                end
            case 5 %%% Changes data marker size
                for i=File
                    FCSMeta.Plots{i,1}.MarkerSize=str2double(NewData);
                end
            case 6 %%% Changes fit line style
                for i=File
                    FCSMeta.Plots{i,2}.LineStyle=NewData;
                    FCSMeta.Plots{i,3}.LineStyle=NewData;
                end
            case 7 %%% Changes fit line width
                for i=File
                    FCSMeta.Plots{i,2}.LineWidth=str2double(NewData);
                    FCSMeta.Plots{i,3}.LineWidth=str2double(NewData);
                end
            case 8 %%% Changes fit marker style
                for i=File
                    FCSMeta.Plots{i,2}.Marker=NewData;
                    FCSMeta.Plots{i,3}.Marker=NewData;
                end
            case 9 %%% Changes fit marker size
                for i=File
                    FCSMeta.Plots{i,2}.MarkerSize=str2double(NewData);
                    FCSMeta.Plots{i,3}.MarkerSize=str2double(NewData);
                end
            case 10 %%% Removes files
                File=flip(File,2);
                for i=File
                    FCSData.Data(i)=[];
                    FCSData.FileName(i)=[];
                    cellfun(@delete,FCSMeta.Plots(i,:));
                    FCSMeta.Data(i,:)=[];
                    FCSMeta.Params(:,i)=[];
                    FCSMeta.Plots(i,:)=[];
                    h.Fit_Table.RowName(i)=[];
                    h.Fit_Table.Data(i,:)=[];
                    h.Style_Table.RowName(i)=[];
                    h.Style_Table.Data(i,:)=[];
                end
            case 11 %%% Renames Files
                if numel(File)>1
                    return;
                end
                NewName = inputdlg('Enter new filename');
                if ~isempty(NewName)
                    h.Style_Table.RowName{File} = NewName{1};
                    h.Fit_Table.RowName{File} = NewName{1};
                    FCSData.FileName{File} = NewName{1};
                    Update_Plots;
                end                  
        end
end
%%% Save Updated UiTableData to UserValues.FCSFit.PlotStyles
UserValues.FCSFit.PlotStyles(1:(size(h.Style_Table.Data,1)-1),1:8) = h.Style_Table.Data(1:(end-1),(1:8));
UserValues.FCSFit.PlotStyleAll = h.Style_Table.Data(end,1:8);
LSUserValues(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(~,~)
h = guidata(findobj('Tag','FCSFit'));
global FCSMeta FCSData UserValues

Min=str2double(h.Fit_Min.String);
Max=str2double(h.Fit_Max.String);
Plot_Errorbars = h.Fit_Errorbars.Value;
Normalization_Method = h.Normalize.Value;
Conv_Interval = h.Conf_Interval.Value;
%%% store in UserValues
UserValues.FCSFit.Fit_Min = Min;
UserValues.FCSFit.Fit_Max = Max;
UserValues.FCSFit.Plot_Errorbars = Plot_Errorbars;
UserValues.FCSFit.NormalizationMethod = Normalization_Method;
UserValues.FCSFit.Conf_Interval = Conv_Interval;
LSUserValues(1);

YMax=0; YMin=0; RMax=0; RMin=0;
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
for i=1:size(FCSMeta.Plots,1)
    if Active(i)
        %% Calculates normalization parameter B
        h.Norm_Time.Visible='off';
        switch Normalization_Method
            case 1
                %% No normalization
                B=1;
            case 2
                %% Normalizes to number of particles 3D (defined in model)
                P=FCSMeta.Params(:,i);
                eval(FCSMeta.Model.Brightness);
                B=B/sqrt(8);
                if isnan(B) || B==0 || isinf(B)
                    B=1;
                end
            case 3
                %% Normalizes to G(0) of the fit
                P=FCSMeta.Params(:,i);x=0;
                %eval(FCSMeta.Model.Function);
                OUT = feval(FCSMeta.Model.Function,P,x);
                B=OUT;
                if isnan(B) || B==0 || isinf(B)
                    B=1;
                end               
            case 4
                %% Normalizes to number of particles 2D (defined in model)
                P=FCSMeta.Params(:,i);
                eval(FCSMeta.Model.Brightness);
                B=B/sqrt(4);
                if isnan(B) || B==0 || isinf(B)
                    B=1;
                end
            case 5
                %% Normalizes to timepoint cosest to set value
                h.Norm_Time.Visible='on';
                T=find(FCSMeta.Data{i,1}>=str2double(h.Norm_Time.String),1,'first');
                B=FCSMeta.Data{i,2}(T);
        end      
        %% Updates data plot y values
        FCSMeta.Plots{i,1}.YData=FCSMeta.Data{i,2}/B;       
        %% Updates data errorbars/ turns them off
        if Plot_Errorbars
            FCSMeta.Plots{i,1}.LData=FCSMeta.Data{i,3}/B;
            FCSMeta.Plots{i,1}.UData=FCSMeta.Data{i,3}/B;
        else
            FCSMeta.Plots{i,1}.LData=0;
            FCSMeta.Plots{i,1}.UData=0;
        end
        %% Calculates fit y data and updates fit plot
        P=FCSMeta.Params(:,i);
        x = logspace(log10(FCSMeta.Data{i,1}(1)),log10(FCSMeta.Data{i,1}(end)),10000); %plot fit function in higher binning than data!
        %eval(FCSMeta.Model.Function);
        OUT = feval(FCSMeta.Model.Function,P,x);
        OUT=real(OUT);
        FCSMeta.Plots{i,2}.XData=x;
        FCSMeta.Plots{i,2}.YData=OUT/B;      
        %% Calculates weighted residuals and plots them
        %%% recalculate fitfun at data
        x=FCSMeta.Data{i,1};
        %eval(FCSMeta.Model.Function);
        OUT = feval(FCSMeta.Model.Function,P,x);
        OUT=real(OUT);
        if h.Fit_Weights.Value
            Residuals=(FCSMeta.Data{i,2}-OUT)./FCSMeta.Data{i,3};
        else
            Residuals=(FCSMeta.Data{i,2}-OUT);
        end
        Residuals(Residuals==inf | isnan(Residuals))=0;
        FCSMeta.Plots{i,3}.YData=Residuals;                       
        %% Calculates limits to autoscale plot 
        XMin=find(FCSMeta.Data{i,1}>=str2double(h.Fit_Min.String),1,'first');
        XMax=find(FCSMeta.Data{i,1}<=str2double(h.Fit_Max.String),1,'last');
        YMax=max([YMax, max((FCSMeta.Data{i,2}(XMin:XMax)+FCSMeta.Data{i,3}(XMin:XMax)))/B]);
        YMin=min([YMin, min((FCSMeta.Data{i,2}(XMin:XMax)-FCSMeta.Data{i,3}(XMin:XMax)))/B]);
        RMax=max([RMax, max(Residuals(XMin:XMax))]);
        RMin=min([RMin, min(Residuals(XMin:XMax))]);        
        %% Calculates Chi^2 and updates table
        h.Fit_Table.CellEditCallback=[];
        Chisqr=sum(Residuals(XMin:XMax).^2)/(numel(Residuals(XMin:XMax))-sum(~cell2mat(h.Fit_Table.Data(i,5:3:end-1))));
        h.Fit_Table.Data{i,end}=num2str(Chisqr);
        h.Fit_Table.CellEditCallback={@Update_Table,3};
        %% Makes plot visible, if it is active
        FCSMeta.Plots{i,1}.Visible='on';
        FCSMeta.Plots{i,2}.Visible='on';
        FCSMeta.Plots{i,3}.Visible='on';
    else
        %% Hides plots
        FCSMeta.Plots{i,1}.Visible='off';
        FCSMeta.Plots{i,2}.Visible='off';
        FCSMeta.Plots{i,3}.Visible='off';
    end
end

%%% Generates figure legend entries
Active=find(Active);
LegendString=cell(numel(Active)*2,1);
LegendUse=h.FCS_Axes.Children(1:numel(Active)*2);
for i=1:numel(Active)
    LegendString{2*i-1}=['Data: ' FCSData.FileName{Active(i)}];
    LegendString{2*i}  =['Fit:  ' FCSData.FileName{Active(i)}];
    LegendUse(2*i-1)=FCSMeta.Plots{Active(i),1};
    LegendUse(2*i)=FCSMeta.Plots{Active(i),2};
end
if ~isempty(LegendString)
    %% Active legend    
    h.FCS_Legend=legend(h.FCS_Axes,LegendUse,LegendString,'Interpreter','none');
    guidata(h.FCSFit,h);
else
    %% Hides legend for empty plot
    h.FCS_Legend.Visible='off';
end
%%% Updates axes limits
h.FCS_Axes.XLim=[Min Max];
h.FCS_Axes.YLim=[YMin-0.1*abs(YMin) YMax+0.05*YMax+0.0001];
h.Residuals_Axes.YLim=[RMin-0.1*abs(RMin) RMax+0.05*RMax+0.0001];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Context menu callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 1: Change X scaling
%%% 2: Export to figure
%%% 3: Export to Workspace
function Plot_Menu_Callback(Obj,~,mode)
h = guidata(findobj('Tag','FCSFit'));
global FCSMeta FCSData

switch mode
    case 1 %%% Change X scale
        if strcmp(Obj.Checked,'off')
            h.FCS_Axes.XScale='log';
            Obj.Checked='on';
        else
            h.FCS_Axes.XScale='lin';
            Obj.Checked='off';
        end
    case 2 %%% Exports plots to new figure
        %% Sets parameters
        Size = [str2double(h.Export_XSize.String) str2double(h.Export_YSize.String) str2double(h.Export_YSizeRes.String)];
        FontSize = str2double(h.Export_FontSize.String);
        
        
        Scale = [floor(log10(h.FCS_Axes.XLim(1))), ceil(h.FCS_Axes.XLim(2))];
        XTicks = zeros(diff(Scale),1);
        XTickLabels = cell(diff(Scale),1);
        j=1;        
        for i=Scale(1):Scale(2)
            XTicks(j) = 10^i;
            XTickLabels{j} = ['10^{',num2str(i),'}'];
            j = j+1;
        end        
        %% Creates new figure
        H.Fig=figure(...
            'Units','points',...
            'defaultUicontrolFontName',h.Export_FontName.String,...
            'defaultAxesFontName',h.Export_FontName.String,...
            'defaultTextFontName',h.Export_FontName.String,...
            'Position',[50 150 Size(1)+5*FontSize+15 Size(2)+Size(3)+6.5*FontSize]);
        whitebg([1 1 1]);   
        %% Creates axes for correlation and residuals
        H.FCS=axes(...
            'Parent',H.Fig,...
            'XScale','log',...
            'FontSize', FontSize,...
            'XTick',XTicks,...
            'XTickLabel',XTickLabels,...
            'Layer','bottom',...
            'Units','points',...
            'Position',[15+4.2*FontSize 3.5*FontSize Size(1) Size(2)]);                
        H.Residuals=axes(...
            'Parent',H.Fig,...
            'XScale','log',...
            'FontSize', FontSize,...
            'XTick',XTicks,...
            'XTickLabel',[],...
            'Layer','bottom',...
            'Units','points',...
            'Position',[15+4.2*FontSize 5*FontSize+Size(2) Size(1) Size(3)]);
        %% Sets axes parameters
        linkaxes([H.FCS,H.Residuals],'x');
        H.FCS.XLim=h.FCS_Axes.XLim;
        H.FCS.YLim=h.FCS_Axes.YLim;
        H.FCS.XLabel.String = 'Time Lag {\it\tau{}} [s]';
        H.FCS.YLabel.String = 'G({\it\tau{}})'; 
        H.Residuals.YLim=h.Residuals_Axes.YLim;
        H.Residuals.YLabel.String = {'Weighted'; 'residuals'};
        %% Copies objects to new figure
        Active = find(cell2mat(h.Fit_Table.Data(1:end-3,1)));
        UseCurves = sort(numel(h.FCS_Axes.Children)+1-[Active*2-1; Active*2]);
        
        H.FCS_Plots=copyobj(h.FCS_Axes.Children(UseCurves),H.FCS);
        if h.Export_FitsLegend.Value
            H.FCS_Legend=legend(H.FCS,h.FCS_Legend.String,'Interpreter','none');
        else
            
            LegendString = h.FCS_Legend.String(1:2:end-1);
            for i=1:numel(LegendString)
                LegendString{i} = LegendString{i}(7:end);
            end
            H.FCS_Legend=legend(H.FCS,H.FCS_Plots(end:-2:2),LegendString,'Interpreter','none');
        end
        H.Residuals_Plots=copyobj(h.Residuals_Axes.Children(numel(h.Residuals_Axes.Children)+1-Active),H.Residuals);          
        %% Toggles box and grid
        if h.Export_Grid.Value
            grid(H.FCS,'on');
            grid(H.Residuals,'on');
        end
        if h.Export_MinorGrid.Value
            grid(H.FCS,'minor');
            grid(H.Residuals,'minor');
        else
            grid(H.FCS,'minor');
            grid(H.Residuals,'minor');
            grid(H.FCS,'minor');
            grid(H.Residuals,'minor');
        end
        if h.Export_Box.Value
            H.FCS.Box = 'on';
            H.Residuals.Box = 'on';
        else
            H.FCS.Box = 'off';
            H.Residuals.Box = 'off';            
        end
      
        H.Fig.Color = [1 1 1];
        %%% Copies figure handles to workspace
        assignin('base','H',H);
    case 3 %%% Exports data to workspace
        Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
        FCS=[];
        FCS.Model=FCSMeta.Model.Function;
        FCS.FileName=FCSData.FileName(Active)';
        FCS.Params=FCSMeta.Params(:,Active)';        
        FCS.Time=FCSMeta.Data(Active,1);
        FCS.Data=FCSMeta.Data(Active,2);
        FCS.Error=FCSMeta.Data(Active,3);
        FCS.Fit=cell(numel(FCS.Time),1); 
        %%% Calculates y data for fit
        for i=1:numel(FCS.Time)
            P=FCS.Params(i,:);
            x=FCS.Time{i};
            %eval(FCSMeta.Model.Function);
            OUT = feval(FCSMeta.Model.Function,P,x);
            OUT=real(OUT);
            FCS.Fit{i}=OUT;
            FCS.Residuals{i,1}=(FCS.Data{i}-FCS.Fit{i})./FCS.Error{i};
        end
        %%% Copies data to workspace
        assignin('base','FCS',FCS);
    case 4 %%% Exports Fit Result to Excel Sheet
        FitResult = cell(numel(FCSData.FileName),1);
        for i = 1:numel(FCSData.FileName)
            FitResult{i} = cell(size(FCSMeta.Params,1)+2,1);
            FitResult{i}{1} = FCSData.FileName{i};
            FitResult{i}{2} = str2double(h.Fit_Table.Data{i,end});
            for j = 3:(size(FCSMeta.Params,1)+2)
                FitResult{i}{j} = FCSMeta.Params(j-2,i);
            end
        end
        [~,ModelName,~] = fileparts(FCSMeta.Model.Name);
        Params = vertcat({ModelName;'Chi2'},FCSMeta.Model.Params);
        if h.Conf_Interval.Value
            for i = 1:numel(FCSData.FileName)
                FitResult{i} = horzcat(FitResult{i},vertcat({'lower','upper';'',''},num2cell(FCSMeta.Confidence_Intervals{i})));
            end
        end
        FitResult = horzcat(Params,horzcat(FitResult{:}));
        mat2clip(FitResult);
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_FCSFit(~,~)
global FCSMeta UserValues
h = guidata(findobj('Tag','FCSFit'));
%%% Indicates fit in progress
h.FCSFit.Name='FCS Fit  FITTING';
h.Fit_Table.Enable='off';
drawnow;
%%% Reads parameters from table
Fixed = cell2mat(h.Fit_Table.Data(1:end-1,5:3:end-1));
Global = cell2mat(h.Fit_Table.Data(end-2,6:3:end-1));
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
lb = h.Fit_Table.Data(end-1,4:3:end-1);
lb = cellfun(@str2double,lb);
ub = h.Fit_Table.Data(end  ,4:3:end-1);
ub = cellfun(@str2double,ub);
%%% Read fit settings and store in UserValues
MaxIter = str2double(h.Iterations.String);
TolFun = str2double(h.Tolerance.String);
UserValues.FCSFit.Max_Iterations = MaxIter;
UserValues.FCSFit.Fit_Tolerance = TolFun;
Use_Weights = h.Fit_Weights.Value;
UserValues.FCSFit.Use_Weights = Use_Weights;
LSUserValues(1);
%%% Optimization settings
opts=optimset('Display','off','TolFun',TolFun,'MaxIter',MaxIter);
%%% Performs fit
if sum(Global)==0
    %% Individual fits, not global
    for i=find(Active)';
        %%% Reads in parameters
        XData=FCSMeta.Data{i,1};
        YData=FCSMeta.Data{i,2};
        EData=FCSMeta.Data{i,3};
        Min=find(XData>=str2double(h.Fit_Min.String),1,'first');
        Max=find(XData<=str2double(h.Fit_Max.String),1,'last');
        if ~isempty(Min) && ~isempty(Max)
            %%% Adjusts data to selected time region
            XData=XData(Min:Max);
            YData=YData(Min:Max);
            EData=EData(Min:Max);
            %%% Disables weights
            if ~Use_Weights
                EData(:)=1;
            end
            %%% Sets initial values and bounds for non fixed parameters
            Fit_Params=FCSMeta.Params(~Fixed(i,:),i);
            Lb=lb(~Fixed(i,:));
            Ub=ub(~Fixed(i,:));                      
            %%% Performs fit
            [Fitted_Params,~,weighted_residuals,Flag,~,~,jacobian]=lsqcurvefit(@Fit_Single,Fit_Params,{XData,EData,i},YData./EData,Lb,Ub,opts);
            %%% calculate confidence intervals
            if h.Conf_Interval.Value
                FCSMeta.Confidence_Intervals{i} = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian);
            end
            %%% Updates parameters
            FCSMeta.Params(~Fixed(i,:),i)=Fitted_Params;
        end
    end  
else
    %% Global fits
    XData=[];
    YData=[];
    EData=[];
    Points=[];
    %%% Sets initial value and bounds for global parameters
    Fit_Params=FCSMeta.Params(Global,1);
    Lb=lb(Global);
    Ub=ub(Global);
    for  i=find(Active)'
        %%% Reads in parameters of current file
        xdata=FCSMeta.Data{i,1};
        ydata=FCSMeta.Data{i,2};
        edata=FCSMeta.Data{i,3};
        %%% Disables weights
        if ~Use_Weights
            edata(:)=1;
        end
        
        %%% Adjusts data to selected time region
        Min=find(xdata>=str2double(h.Fit_Min.String),1,'first');
        Max=find(xdata<=str2double(h.Fit_Max.String),1,'last');
        if ~isempty(Min) && ~isempty(Max)
            XData=[XData;xdata(Min:Max)];
            YData=[YData;ydata(Min:Max)];
            EData=[EData;edata(Min:Max)];
            Points(end+1)=numel(xdata(Min:Max));
        end
        %%% Concaternates initial values and bounds for non fixed parameters
        Fit_Params=[Fit_Params; FCSMeta.Params(~Fixed(i,:)& ~Global,i)];
        Lb=[Lb lb(~Fixed(i,:) & ~Global)];
        Ub=[Ub ub(~Fixed(i,:) & ~Global)];
    end
    %%% Performs fit
    [Fitted_Params,~,weighted_residuals,Flag,~,~,jacobian]=lsqcurvefit(@Fit_Global,Fit_Params,{XData,EData,Points},YData./EData,Lb,Ub,opts);
    %%% calculate confidence intervals
    if h.Conf_Interval.Value
        FCSMeta.Confidence_Intervals = nlparci(Fitted_Params,weighted_residuals,'jacobian',jacobian);
    end
    %%% Updates parameters
    FCSMeta.Params(Global,:)=repmat(Fitted_Params(1:sum(Global)),[1 size(FCSMeta.Params,2)]) ;
    Fitted_Params(1:sum(Global))=[];
    for i=find(Active)'
        FCSMeta.Params(~Fixed(i,:) & ~Global,i)=Fitted_Params(1:sum(~Fixed(i,:) & ~Global)); 
        Fitted_Params(1:sum(~Fixed(i,:)& ~Global))=[]; 
    end    
end
%%% Displays last exitflag
switch Flag
    case 1
        h.Termination.String='Function converged to a solution x.';
    case 2
        h.Termination.String='Change in x was less than the specified tolerance.';
    case 3
        h.Termination.String='Change in the residual was less than the specified tolerance.';
    case 4
        h.Termination.String='Magnitude of search direction smaller than the specified tolerance.';
    case 0
        h.Termination.String='Number of iterations exceeded options. MaxIter or number of function evaluations exceeded options.';
    case -1
        h.Termination.String='Algorithm was terminated by the output function.';
    case -2
        h.Termination.String='Problem is infeasible: the bounds lb and ub are inconsistent.';
    case -4
        h.Termination.String='Optimization could not make further progress.';
    otherwise
        h.Termination.String= ['Unknown exitflag: ' num2str(Flag)];
end
%%% Indicates end of fitting procedure
h.Fit_Table.Enable='on';
h.FCSFit.Name='FCS Fit';
%%% Updates table values and plots
Update_Table([],[],2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for individual fits %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Single(Fit_Params,Data)
%%% Fit_Params: Non fixed parameters of current file
%%% Data{1}:    X values of current file
%%% Data{2}:    Weights of current file
%%% Data{3}:    Indentifier of current file

global FCSMeta
h = guidata(findobj('Tag','FCSFit'));

x=Data{1};
Weights=Data{2};
file=Data{3};

%%% Determines, which parameters are fixed
Fixed = cell2mat(h.Fit_Table.Data(file,5:3:end-1));
P=zeros(numel(Fixed),1);
%%% Assigns fitting parameters to unfixed parameters of fit
P(~Fixed)=Fit_Params;
%%% Assigns parameters from table to fixed parameters
P(Fixed)=FCSMeta.Params(Fixed,file);
%%% Applies function on parameters
%eval(FCSMeta.Model.Function);
OUT = feval(FCSMeta.Model.Function,P,x);
%%% Applies weights
Out=OUT./Weights;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for global fits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Global(Fit_Params,Data)
%%% Fit_Params: [Global parameters, Non fixed parameters of all files]
%%% Data{1}:    X values of all files
%%% Data{2}:    Weights of all files
%%% Data{3}:    Length indentifier for X and Weights data of each file

global FCSMeta
h = guidata(findobj('Tag','FCSFit'));

X=Data{1};
Weights=Data{2};
Points=Data{3};

%%% Determines, which parameters are fixed, global and which files to use
Fixed = cell2mat(h.Fit_Table.Data(1:end-3,5:3:end));
Global = cell2mat(h.Fit_Table.Data(end-2,6:3:end));
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
P=zeros(numel(Global),1);

%%% Asignes global parameters
P(Global)=Fit_Params(1:sum(Global));
Fit_Params(1:sum(Global))=[];

Out=[];k=1;
for i=find(Active)'
  %%% Sets non-fixed parameters
  P(~Fixed(i,:) & ~Global)=Fit_Params(1:sum(~Fixed(i,:) & ~Global)); 
  Fit_Params(1:sum(~Fixed(i,:)& ~Global))=[];  
  %%% Sets fixed parameters
  P(Fixed(i,:) & ~Global)= FCSMeta.Params((Fixed(i,:)& ~Global),i);
  %%% Defines XData for the file
  x=X(1:Points(k));
  X(1:Points(k))=[]; 
  k=k+1;
  %%% Calculates function for current file
  %eval(FCSMeta.Model.Function);
  OUT = feval(FCSMeta.Model.Function,P,x);
  Out=[Out;OUT]; 
end
Out=Out./Weights;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Mat2Clip copies contents of numeric or cell array to clipboard %%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = mat2clip(a, delim)

%MAT2CLIP  Copies matrix to system clipboard.
%
% MAT2CLIP(A) copies the contents of 2-D matrix A to the system clipboard.
% A can be a numeric array (floats, integers, logicals), character array,
% or a cell array. The cell array can have mixture of data types.
%
% Each element of the matrix will be separated by tabs, and each row will
% be separated by a NEWLINE character. For numeric elements, it tries to
% preserve the current FORMAT. The copied matrix can be pasted into
% spreadsheets.
%
% OUT = MAT2CLIP(A) returns the actual string that was copied to the
% clipboard.
%
% MAT2CLIP(A, DELIM) uses DELIM as the delimiter between columns. The
% default is tab (\t).
%
% Example:
%   format long g
%   a = {'hello', 123;pi, 'bye'}
%   mat2clip(a);
%   % paste into a spreadsheet
%
%   format short
%   data = {
%     'YPL-320', 'Male',   38, true,  uint8(176);
%     'GLI-532', 'Male',   43, false, uint8(163);
%     'PNI-258', 'Female', 38, true,  uint8(131);
%     'MIJ-579', 'Female', 40, false, uint8(133) }
%   mat2clip(data);
%   % paste into a spreadsheet
%
%   mat2clip(data, '|');   % using | as delimiter
%
% See also CLIPBOARD.

% VERSIONS:
%   v1.0 - First version
%   v1.1 - Now works with all numeric data types. Added option to specify
%          delimiter character.
%
% Copyright 2009 The MathWorks, Inc.
%
% Inspired by NUM2CLIP by Grigor Browning (File ID: 8472) Matlab FEX.

error(nargchk(1, 2, nargin, 'struct'));

if ndims(a) ~= 2
 error('mat2clip:Only2D', 'Only 2-D matrices are allowed.');
end

% each element is separated by tabs and each row is separated by a NEWLINE
% character.
sep = {'\t', '\n', ''};

if nargin == 2
 if ischar(delim)
   sep{1} = delim;
 else
   error('mat2clip:CharacterDelimiter', ...
     'Only character array for delimiters');
 end
end

% try to determine the format of the numeric elements.
switch get(0, 'Format')
 case 'short'
   fmt = {'%s', '%0.5f' , '%d'};
 case 'shortE'
   fmt = {'%s', '%0.5e' , '%d'};
 case 'shortG'
   fmt = {'%s', '%0.5g' , '%d'};
 case 'long'
   fmt = {'%s', '%0.15f', '%d'};
 case 'longE'
   fmt = {'%s', '%0.15e', '%d'};
 case 'longG'
   fmt = {'%s', '%0.15g', '%d'};
 otherwise
   fmt = {'%s', '%0.5f' , '%d'};
end

if iscell(a)  % cell array
   a = a';

   floattypes = cellfun(@isfloat, a);
   inttypes = cellfun(@isinteger, a);
   logicaltypes = cellfun(@islogical, a);
   strtypes = cellfun(@ischar, a);

   classType = zeros(size(a));
   classType(strtypes) = 1;
   classType(floattypes) = 2;
   classType(inttypes) = 3;
   classType(logicaltypes) = 3;
   if any(~classType(:))
     error('mat2clip:InvalidDataTypeInCell', ...
       ['Invalid data type in the cell array. ', ...
       'Only strings and numeric data types are allowed.']);
   end
   sepType = ones(size(a));
   sepType(end, :) = 2; sepType(end) = 3;
   tmp = [fmt(classType(:));sep(sepType(:))];

   b=sprintf(sprintf('%s%s', tmp{:}), a{:});

elseif isfloat(a)  % floating point number
   a = a';

   classType = repmat(2, size(a));
   sepType = ones(size(a));
   sepType(end, :) = 2; sepType(end) = 3;
   tmp = [fmt(classType(:));sep(sepType(:))];

   b=sprintf(sprintf('%s%s', tmp{:}), a(:));

elseif isinteger(a) || islogical(a)  % integer types and logical
   a = a';

   classType = repmat(3, size(a));
   sepType = ones(size(a));
   sepType(end, :) = 2; sepType(end) = 3;
   tmp = [fmt(classType(:));sep(sepType(:))];

   b=sprintf(sprintf('%s%s', tmp{:}), a(:));

elseif ischar(a)  % character array
   % if multiple rows, convert to a single line with line breaks
   if size(a, 1) > 1
     b = cellstr(a);
     b = [sprintf('%s\n', b{1:end-1}), b{end}];
   else
     b = a;
   end

else
   error('mat2clip:InvalidDataType', ...
     ['Invalid data type. ', ...
     'Only cells, strings, and numeric data types are allowed.']);

end

clipboard('copy', b);

if nargout
 out = b;
end

