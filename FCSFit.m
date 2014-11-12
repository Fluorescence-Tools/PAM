function FCSFit
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
        'CellEditCallback',{@Update_Table,3});
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
        'String','1e-6',...
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
        'String','1',...
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
        'Value',1,...
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
        'Value',1,...
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
    %%% Checkbox to toggle errorbar plotting
    h.Normalize = uicontrol(...
        'Parent',h.Setting_Panel,...
        'Tag','Normalize',...
        'Units','normalized',...
        'FontSize',10,...
        'BackgroundColor', Look.Control,...
        'ForegroundColor', Look.Fore,...
        'Style','popupmenu',...
        'String',{'None';'Fit N 3D';'Fit G(0)';'Fit N 2D'; 'Time'},...
        'Value',1,...
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
        'String','1000',...
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
        'String','1e-6',...
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
        'Position',[0.35 0.88 0.6 0.1]);
    
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
        'CellEditCallback',{@Update_Style,2});
    
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
        'Box','off');
    h.Residuals_Axes.XTickLabel=[];
    h.Residuals_Axes.YLabel.String = 'Weighted residuals';
    h.Residuals_Axes.YLabel.Color = Look.Fore;
    
    linkaxes([h.FCS_Axes h.Residuals_Axes],'x');
    
%% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FCSData=[];
    FCSData.Data=[];
    FCSData.FileName=[];
    FCSMeta=[];
    FCSMeta.Data=[];
    FCSMeta.Params=[];
    FCSMeta.Plots=cell(0);
    FCSMeta.Model=[];
    FCSMeta.Fits=[];
    FCSMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 1 0; 1 0 1; 0 1 1];
    
    
    guidata(h.FCSFit,h); 
    Load_Fit([],[],0);
    Update_Style([],[],0) 
else
    figure(h.FCSFit); % Gives focus to Pam figure  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to close figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_FCSFit(~,~)
clear global -regexp FCSData FCSMeta
Phasor=findobj('Tag','Phasor');
Pam=findobj('Tag','Pam');
if isempty(Phasor) && isempty(Pam)
    clear global -regexp UserValues
end
delete(gcf);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .cor files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Cor(~,~,mode)
global UserValues FCSData FCSMeta
h = guidata(gcf);

%%% Choose files to load
[FileName,PathName,Type] = uigetfile({'*.mcor'; '.cor'}, 'Choose a referenced data file', UserValues.File.FCSPath, 'MultiSelect', 'on');
%%% Tranforms to cell array, if only one file was selected
if ~iscell(FileName)
    FileName = {FileName};
end

%%% Only esecutes, if at least one file was selected
if any(FileName{1}~=0)
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
    
    %%% Saves Path
    UserValues.File.FCSPath=PathName;
    LSUserValues(1);
    switch Type
        case 1
            %% Pam correlation files based on .mat files
            for i=1:numel(FileName)
                %%% Updates global parameters
                FCSData.Data{end+1}=load([PathName FileName{i}],'-mat');
                FCSData.FileName{end+1}=FileName{i}(1:end-5);
                FCSMeta.Data{end+1,1}=FCSData.Data{end}.Cor_Times;
                FCSMeta.Data{end,2}=FCSData.Data{end}.Cor_Average;
                FCSMeta.Data{end,3}=FCSData.Data{end}.Cor_SEM;
                %%% Creates new plots
                FCSMeta.Plots{end+1,1}=errorbar(...
                    FCSMeta.Data{end,1},...
                    FCSMeta.Data{end,2},...
                    FCSMeta.Data{end,3},...
                    'Parent',h.FCS_Axes);
                FCSMeta.Plots{end,2}=line(...
                    'Parent',h.FCS_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',zeros(numel(FCSMeta.Data{end,1}),1));
                FCSMeta.Plots{end,3}=line(...
                    'Parent',h.Residuals_Axes,...
                    'XData',FCSMeta.Data{end,1},...
                    'YData',zeros(numel(FCSMeta.Data{end,1}),1));                
                FCSMeta.Params(:,end+1)=cellfun(@str2double,h.Fit_Table.Data(end-2,4:3:end-1));
            end
        case 2
            %% Pam correlation files based on .txt files
    end
    %%% Updates table and plot data and style to new size
    Update_Style([],[],1);
    Update_Table([],[],1);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes fitt function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%% Extracts parameter names and initial values
    FCSMeta.Model.Params=cell(NParams,1);
    FCSMeta.Model.Value=zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        Param_Pos=strfind(Text{i+Param_Start},' ');
        FCSMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        Value_Pos=strfind(Text{i+Param_Start},'=');
        FCSMeta.Model.Value(i)=str2double(Text{i+Param_Start}((Value_Pos+2):end));
    end    
    FCSMeta.Params=repmat(FCSMeta.Model.Value,[1,size(FCSMeta.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(gcf);
global FCSMeta FCSData
switch mode
    case 0
        %% Updates whole table (Load Fit etc.)
        
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
        Columns{end}='Chi²';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(4:3:end-1)=cellfun('length',FCSMeta.Model.Params).*7;
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
            Data{i,2}=mean(FCSData.Data{i}.Counts);
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(FCSMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(FCSMeta.Model.Value)');
        Data(end-1,4:3:end-1)=deal({-inf});
        Data(end,4:3:end-1)=deal({inf});
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
    case 1
        %% Updates tables when new data is loaded
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
            Data{i,2}=num2str(mean(FCSData.Data{i}.Counts));
        end
        h.Fit_Table.Data=Data;
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2
        %% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,4:3:end-1)=cellfun(@num2str,num2cell(FCSMeta.Params)','UniformOutput',false);
        %%% Updates plots
        Update_Plots        
        %%% Enables cell callback again        
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 3
        %% Individual cells calbacks 
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        if e.Indices(1)==size(h.Fit_Table.Data,1)-2
            %% ALL row wase used => Applies to all files
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({e.NewData});
            if mod(e.Indices(2)-4,3)==0 && e.Indices(2)>=4
                %% Value was changed => Apply value to global variables
                FCSMeta.Params((e.Indices(2)-1)/3,:)=str2double(e.NewData);
            elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=6 && e.NewData==1
                %% Value was fixed => Uncheck global
                h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
            elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && e.NewData==1
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
            h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({e.NewData});
            if e.NewData
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
                h.Fit_Table.Data(1:end-2,e.Indices(2))=deal({e.NewData});
                FCSMeta.Params((e.Indices(2)-1)/3,:)=str2double(e.NewData);
            else
                %% Not global => only changes value
                FCSMeta.Params((e.Indices(2)-1)/3,e.Indices(1))=str2double(e.NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
        end       
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end

%%% Calculates brightness for all files
for i=1:size(FCSMeta.Params,2)
    P=FCSMeta.Params(:,i);
    eval(FCSMeta.Model.Brightness);
    h.Fit_Table.Data{i,3}=num2str(mean(FCSData.Data{i}.Counts)*B);
end

%%% Updates plots to changes models
Update_Plots;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(~,e,mode) 
global FCSMeta FCSData
h = guidata(gcf);

switch mode
    case 0
        %% Called at the figure initialization
        %%% Generates the table column and cell names
        Columns=cell(9,1);
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
        h.Style_Table.ColumnName=Columns;
        h.Style_Table.RowName={'ALL'};
        
        %%% Generates the initial cell inputs
        h.Style_Table.ColumnEditable=true;
        h.Style_Table.ColumnFormat={'char',{'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char',...
                                           {'none','-','-.','--',':'},'char',{'none','.','+','o','*','square','diamond','v','^','<','>'},'char','logical'};
        Data=cell(1,9);
        Data{1}='1 1 1';
        Data{2}='none';
        Data{3}='1';
        Data{4}='.';
        Data{5}='8';
        Data{6}='-';
        Data{7}='1';
        Data{8}='none'; 
        Data{9}='8';
        Data{10}=false;
        h.Style_Table.Data=Data;        
    case 1
        %% Called, when new file is loaded

        %%% Sets row names to file names 
        Rows=cell(numel(FCSData.Data)+1,1);
        Rows(1:numel(FCSData.Data))=deal(FCSData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        Data(end,:)=h.Style_Table.Data(end,:);
        %%% Sets previous styles to first rows
        Data(1:size(h.Style_Table.Data,1)-1,:)=h.Style_Table.Data(1:end-1,:);
        %%% Adds ALL styles to new files
        Data((size(h.Style_Table.Data,1)):(end-1),:)=repmat(h.Style_Table.Data(end,:),[numel(Rows)-(size(h.Style_Table.Data,1)),1]);
        %%% Updates new plots to style
        for i=(size(h.Style_Table.Data,1)):numel(FCSData.FileName)
           Data{i,1}=num2str(FCSMeta.Color(mod(i,6)+1,:));
           FCSMeta.Plots{i,1}.Color=FCSMeta.Color(mod(i,6)+1,:);
           FCSMeta.Plots{i,2}.Color=FCSMeta.Color(mod(i,6)+1,:);
           FCSMeta.Plots{i,3}.Color=FCSMeta.Color(mod(i,6)+1,:);
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
    case 2
        %% Cell callback
        %%% Applies to all files if ALL row was used
        if e.Indices(1)==size(h.Style_Table.Data,1)
            File=1:(size(h.Style_Table.Data,1)-1);
            h.Style_Table.Data(:,e.Indices(2))=deal({e.NewData});
        else
            File=e.Indices(1);
        end
        switch e.Indices(2)
            case 1
                %% Changes file color
                for i=File
                    FCSMeta.Plots{i,1}.Color=str2num(e.NewData);
                    FCSMeta.Plots{i,2}.Color=str2num(e.NewData);
                    FCSMeta.Plots{i,3}.Color=str2num(e.NewData);

                end
            case 2
                %% Changes data line style
                for i=File
                    FCSMeta.Plots{i,1}.LineStyle=e.NewData;
                end
            case 3
                %% Changes data line width
                for i=File
                    FCSMeta.Plots{i,1}.LineWidth=str2double(e.NewData);
                end
            case 4
                %% Changes data marker style
                for i=File
                    FCSMeta.Plots{i,1}.Marker=e.NewData;
                end
            case 5
                %% Changes data marker size
                for i=File
                    FCSMeta.Plots{i,1}.MarkerSize=str2double(e.NewData);
                end
            case 6
                %% Changes fit line style
                for i=File
                    FCSMeta.Plots{i,2}.LineStyle=e.NewData;
                    FCSMeta.Plots{i,3}.LineStyle=e.NewData;
                end
            case 7
                %% Changes fit line width
                for i=File
                    FCSMeta.Plots{i,2}.LineWidth=str2double(e.NewData);
                    FCSMeta.Plots{i,3}.LineWidth=str2double(e.NewData);
                end
            case 8
                %% Changes fit marker style
                for i=File
                    FCSMeta.Plots{i,2}.Marker=e.NewData;
                    FCSMeta.Plots{i,3}.Marker=e.NewData;
                end
            case 9
                %% Changes fit marker size
                for i=File
                    FCSMeta.Plots{i,2}.MarkerSize=str2double(e.NewData);
                    FCSMeta.Plots{i,3}.MarkerSize=str2double(e.NewData);
                end
            case 10
                %% Removes files
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
end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(~,~)
h = guidata(gcf);
global FCSMeta FCSData

Min=str2double(h.Fit_Min.String);
Max=str2double(h.Fit_Max.String);
YMax=0; YMin=0; RMax=0; RMin=0;
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
for i=1:size(FCSMeta.Plots,1)
    if Active(i)
        %% Calculates normalization parameter B
        h.Norm_Time.Visible='off';
        switch h.Normalize.Value
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
                eval(FCSMeta.Model.Function);
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
        if h.Fit_Errorbars.Value
            FCSMeta.Plots{i,1}.LData=FCSMeta.Data{i,3}/B;
            FCSMeta.Plots{i,1}.UData=FCSMeta.Data{i,3}/B;
        else
            FCSMeta.Plots{i,1}.LData=0;
            FCSMeta.Plots{i,1}.UData=0;
        end
        %% Calculates fit y data and updates fit plot
        P=FCSMeta.Params(:,i);
        x=FCSMeta.Data{i,1};
        eval(FCSMeta.Model.Function);
        OUT=real(OUT);
        FCSMeta.Plots{i,2}.YData=OUT/B;        
        %% Calculates weighted residuals and plots them
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
for i=1:numel(Active)
    LegendString{2*i-1}=['Data: ' FCSData.FileName{Active(i)}];
    LegendString{2*i}  =['Fit:  ' FCSData.FileName{Active(i)}];
end
if ~isempty(LegendString)
    %% Active legend
    if ~isfield(h,'FCS_Legend')
        %%% Create new legend
        h.FCS_Legend=legend(h.FCS_Axes,LegendString,'Interpreter','none');
        guidata(h.FCSFit,h);
    else
        %%% Updates legend to new settings
        h.FCS_Legend.Visible='on';
        h.FCS_Legend.String=LegendString;
    end    
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
h = guidata(gcf);
global FCSMeta FCSData

switch mode
    case 1
        %% Change X scale
        if strcmp(Obj.Checked,'off')
            h.FCS_Axes.XScale='log';
            Obj.Checked='on';
        else
            h.FCS_Axes.XScale='lin';
            Obj.Checked='off';
        end
    case 2
        %% Exports plots to new figure
        %%% Creates new figure with axes
        H.Fig=figure;
        whitebg([1 1 1]);        
        H.FCS=axes(...
            'Parent',H.Fig,...
            'Units','normalized',...
            'XScale','log',...
            'Position',[0.05 0.35 0.9 0.6]);
        H.Residuals=axes(...
            'Parent',H.Fig,...
            'Units','normalized',...
            'XScale','log',...
            'Position',[0.05 0.05 0.9 0.25]);
        linkaxes([H.FCS,H.Residuals],'x');
        H.FCS.XLim=h.FCS_Axes.XLim;
        H.FCS.YLim=h.FCS_Axes.YLim;
        H.FCS.XLabel.String = 'Time Lag {\it\tau{}} [s]';
        H.FCS.YLabel.String = 'G({\it\tau{}})'; 
        H.Residuals.YLim=h.Residuals_Axes.YLim;
        H.Residuals.XLabel.String='Time Lag {\it\tau{}} [s]';
        H.Residuals.YLabel.String = 'Weighted residuals';
        %%% Copies objects to new figure
        H.FCS_Plots=copyobj(h.FCS_Axes.Children,H.FCS);
        H.FCS_Legend=legend(H.FCS,h.FCS_Legend.String,'Interpreter','none');
        H.Residuals_Plots=copyobj(h.Residuals_Axes.Children,H.Residuals);       
        %%% Copies figure handles to workspace
        assignin('base','H',H);
    case 3
        %% Exports data to workspace
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
            eval(FCSMeta.Model.Function);
            OUT=real(OUT);
            FCS.Fit{i}=OUT;
            FCS.Residuals{i,1}=(FCS.Data{i}-FCS.Fit{i})./FCS.Error{i};
        end
        %%% Copies data to workspace
        assignin('base','FCS',FCS);
        
end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_FCSFit(~,~)
global FCSMeta
h = guidata(gcf);
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
%%% Optimization settings
opts=optimset('Display','off','TolFun',str2double(h.Tolerance.String),'MaxIter',str2double(h.Iterations.String));
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
            if ~h.Fit_Weights.Value
                EData(:)=1;
            end
            %%% Sets initial values and bounds for non fixed parameters
            Fit_Params=FCSMeta.Params(~Fixed(i,:),i);
            Lb=lb(~Fixed(i,:));
            Ub=ub(~Fixed(i,:));                      
            %%% Performs fit
            [Fitted_Params,~,~,Flag]=lsqcurvefit(@Fit_Single,Fit_Params,{XData,EData,i},YData./EData,Lb,Ub,opts);
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
        if ~h.Fit_Weights.Value
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
    [Fitted_Params,~,~,Flag]=lsqcurvefit(@Fit_Global,Fit_Params,{XData,EData,Points},YData./EData,Lb,Ub,opts);
    %%% Updates parameters
    FCSMeta.Params(Global,:)=Fitted_Params(1:sum(Global));
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
h = guidata(gcf);

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
eval(FCSMeta.Model.Function);
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
h = guidata(gcf);

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
  eval(FCSMeta.Model.Function);
  Out=[Out;OUT]; 
end
Out=Out./Weights;




