function MIAFit
global UserValues MIAFitData MIAFitMeta

h.MIAFit=findobj('Tag','MIAFit');

if ~isempty(h.MIAFit) % Creates new figure, if none exists
    figure(h.MIAFit);
    return;
end

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
h.MIAFit = figure(...
    'Units','normalized',...
    'Tag','MIAFit',...
    'Name','MIAFit',...
    'NumberTitle','off',...
    'Menu','none',...
    'defaultUicontrolFontName','Times',...
    'defaultAxesFontName','Times',...
    'defaultTextFontName','Times',...
    'Toolbar','figure',...
    'UserData',[],...
    'OuterPosition',[0.01 0.1 0.98 0.9],...
    'CloseRequestFcn',@Close_MIAFit,...
    'Visible','on');

%%% Sets background of axes and other things
whitebg(Look.Axes);
%%% Changes Pam background; must be called after whitebg
h.MIAFit.Color=Look.Back;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Menubar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% File menu with loading, saving and exporting functions
h.File = uimenu(...
    'Parent',h.MIAFit,...
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
    'Parent',h.MIAFit,...
    'Tag','Fit',...
    'Label','Fit',...
    'Callback',@Do_MIAFit);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Fitting parameters Tab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Microtime tabs container
h.FitParams_Tab = uitabgroup(...
    'Parent',h.MIAFit,...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    'String','Size in X\Y [px]:',...
    'Position',[0.002 0.88 0.09 0.1]);
%%% Minimum and maximum for fitting and plotting
h.Fit_X = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Setting_Panel',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String',num2str(UserValues.MIAFit.Fit_X),...
    'Callback',@Update_Plots,...
    'Position',[0.096 0.88 0.04 0.1]);
h.Fit_Y = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Setting_Panel',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String',num2str(UserValues.MIAFit.Fit_Y),...
    'Callback',@Update_Plots,...
    'Position',[0.141 0.88 0.04 0.1]);
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
    'Value',UserValues.MIAFit.Use_Weights,...
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
    'Value',UserValues.MIAFit.Plot_Errorbars,...
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
    'String',{'None';'Fit N 3D';'Fit G(0)';'Fit N 2D'; 'Point X\Y'},...
    'Value',UserValues.MIAFit.NormalizationMethod,...
    'Callback',@Update_Plots,...
    'Position',[0.082 0.52 0.06 0.1]);
%%% Editbox to set X point used for normalization
h.Norm_X = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Normalize',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','1',...
    'Visible','off',...
    'Callback',@Update_Plots,...
    'Position',[0.145 0.51 0.04 0.1]);
%%% Editbox to set Y point used for normalization
h.Norm_Y = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Normalize',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','edit',...
    'String','0',...
    'Visible','off',...
    'Callback',@Update_Plots,...
    'Position',[0.19 0.51 0.04 0.1]);
%%% Checkbox to omit center point
h.Omit_Center = uicontrol(...
    'Parent',h.Setting_Panel,...
    'Tag','Normalize',...
    'Units','normalized',...
    'FontSize',12,...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'Style','checkbox',...
    'Value',UserValues.MIAFit.Omit,...
    'String','Omit center',...
    'Callback',@Update_Plots,...
    'Position',[0.002 0.37 0.1 0.1]);
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
    'String',num2str(UserValues.MIAFit.Max_Iterations),...
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
    'String',num2str(UserValues.MIAFit.Fit_Tolerance),...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Main plots tab container
h.Main_Tab = uitabgroup(...
    'Parent',h.MIAFit,...
    'Units','normalized',...
    'Position',[0.005 0.26 0.99 0.73]);
    %% On axis plots
%%% On axis plots tab
h.On_Axis_Tab= uitab(...
    'Parent',h.Main_Tab,...
    'Title','On axis');

%%% Panel for on axis plots
h.On_Axis_Panel = uibuttongroup(...
    'Parent',h.On_Axis_Tab,...
    'Tag','Fit_Plots_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% Axes for on Chi axis plot
h.X_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XLim',[10^-6,1],...
    'Position',[0.06 0.28 0.43 0.7],...
    'Box','off');
h.X_Axes.XLabel.String = 'Pixel Lag {\it\xi{}} [pixels]';
h.X_Axes.XLabel.Color = Look.Fore;
h.X_Axes.YLabel.String = 'G({\it\xi{}},0)';
h.X_Axes.YLabel.Color = Look.Fore;

%%% Axes for chi residuals
h.XRes_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XAxisLocation','top',....
    'Position',[0.06 0.02 0.43 0.18],...
    'Box','off',...
    'YGrid','on',...
    'XGrid','on');
h.XRes_Axes.GridColorMode = 'manual';
h.XRes_Axes.GridColor = [0 0 0];
h.XRes_Axes.XTickLabel=[];
h.XRes_Axes.YLabel.String = 'Weighted residuals';
h.XRes_Axes.YLabel.Color = Look.Fore;
linkaxes([h.X_Axes h.XRes_Axes],'x');

%%% Axes for on Psi axis plot
h.Y_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XLim',[10^-6,1],...
    'Position',[0.56 0.28 0.43 0.7],...
    'Box','off');
h.Y_Axes.XLabel.String = 'Pixel Lag {\it\psi{}} [pixels]';
h.Y_Axes.XLabel.Color = Look.Fore;
h.Y_Axes.YLabel.String = 'G({0,\it\psi{}})';
h.Y_Axes.YLabel.Color = Look.Fore;

%%% Axes for chi residuals
h.YRes_Axes = axes(...
    'Parent',h.On_Axis_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'XAxisLocation','top',...
    'Position',[0.56 0.02 0.43 0.18],...
    'Box','off',...
    'YGrid','on',...
    'XGrid','on');
h.YRes_Axes.GridColorMode = 'manual';
h.YRes_Axes.GridColor = [0 0 0];
h.YRes_Axes.XTickLabel=[];
h.YRes_Axes.YLabel.String = 'Weighted residuals';
h.YRes_Axes.YLabel.Color = Look.Fore;
linkaxes([h.Y_Axes h.YRes_Axes],'x');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Individual 2D Plots
%%% 2D plots tab
h.Full_Plot_Tab= uitab(...
    'Parent',h.Main_Tab,...
    'Title','2D Plots');

%%% Panel for on axis plots
h.Full_Plot_Panel = uibuttongroup(...
    'Parent',h.Full_Plot_Tab,...
    'Tag','Fit_Plots_Panel',...
    'Units','normalized',...
    'BackgroundColor', Look.Back,...
    'ForegroundColor', Look.Fore,...
    'HighlightColor', Look.Control,...
    'ShadowColor', Look.Shadow,...
    'Position',[0 0 1 1]);

%%% 2D main plot axis
h.Full_Main_Axes = axes(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'ZColor',Look.Fore,...
    'View',[145,25],...
    'Position',[0.06 0.2 0.43 0.78],...
    'Box','off');
h.Full_Main_Axes.XLabel.String = 'Pixel Lag {\it\xi{}} [pixels]';
h.Full_Main_Axes.XLabel.Color = Look.Fore;
h.Full_Main_Axes.YLabel.String = 'Pixel Lag {\it\psi{}} [pixels]';
h.Full_Main_Axes.YLabel.Color = Look.Fore;
h.Full_Main_Axes.ZLabel.String = 'G({\it\xi{}},{\it\psi{}})';
h.Full_Main_Axes.ZLabel.Color = Look.Fore;
%%% Surface plot for 2D data
h.Plots.Main=surf(zeros(2),zeros(2,2,3),...
    'Parent',h.Full_Main_Axes,...
    'FaceColor','Flat');
%%% 2D fit plot
h.Full_Fit_Axes = axes(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',12,...
    'NextPlot','add',...
    'XColor',Look.Fore,...
    'YColor',Look.Fore,...
    'ZColor',Look.Fore,...
    'View',[0,25],...
    'Position',[0.56 0.2 0.43 0.78],...
    'Box','off');
h.Full_Fit_Axes.XLabel.String = 'Pixel Lag {\it\xi{}} [pixels]';
h.Full_Fit_Axes.XLabel.Color = Look.Fore;
h.Full_Fit_Axes.YLabel.String = 'Pixel Lag {\it\psi{}} [pixels]';
h.Full_Fit_Axes.YLabel.Color = Look.Fore;
h.Full_Fit_Axes.ZLabel.String = 'G({\it\xi{}},{\it\psi{}})';
h.Full_Fit_Axes.ZLabel.Color = Look.Fore;
%%% Surface plot for 2D fit
h.Plots.Fit=surf(zeros(2),zeros(2,2,3),...
    'Parent',h.Full_Fit_Axes,...
    'FaceColor','Flat');
%%% Links plots together
h.Plots.Link=linkprop([h.Full_Main_Axes,h.Full_Fit_Axes],...
    {'View','XLim','YLim','ZLim','DataAspectRatio'});

%%% Determines, which file to plot
h.Plot2D = uicontrol(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','popupmenu',...
    'String',{'Nothing selected'},...
    'Value',1,...
    'Callback',@Update_Plots,...
    'Position',[0.005 0.02 0.15 0.04]);
%%% Determines, how to plot second graph
h.Plot2DStyle = uicontrol(...
    'Parent',h.Full_Plot_Panel,...
    'Units','normalized',...
    'FontSize',10,...
    'BackgroundColor', Look.Control,...
    'ForegroundColor', Look.Fore,...
    'Style','popupmenu',...
    'String',{'Fit','Residuals','Fit\Residuals'},...
    'Value',1,...
    'Callback',@Update_Plots,...
    'Position',[0.005 0.065 0.15 0.04]);
%% Initializes global variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MIAFitData=[];
MIAFitData.Data=cell(0);
MIAFitData.FileName=cell(0);
MIAFitData.Counts=cell(0);
MIAFitMeta=[];
MIAFitMeta.Data=[];
MIAFitMeta.Params=[];
MIAFitMeta.Confidence_Intervals = cell(1,1);
MIAFitMeta.Plots=cell(0);
MIAFitMeta.Model=[];
MIAFitMeta.Fits=[];
MIAFitMeta.Color=[1 1 0; 0 0 1; 1 0 0; 0 0.5 0; 1 0 1; 0 1 1];

guidata(h.MIAFit,h);
Load_Fit([],[],0);
Update_Style([],[],0);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to close figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Close_MIAFit(~,~)
clear global -regexp MIAFitData MIAFitMeta
Phasor=findobj('Tag','Phasor');
Pam=findobj('Tag','Pam');
FCS=findobj('Tag','FCSFit');
if isempty(Phasor) && isempty(Pam) && isempty(FCS)
    clear global -regexp UserValues
end
delete(gcf);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to load .cor files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Cor(~,~,mode)
global UserValues MIAFitData MIAFitMeta
h = guidata(findobj('Tag','MIAFit'));

%%% Choose files to load
[FileName,PathName,Type] = uigetfile({'*.miacor', 'MIA 2D correlation file'; '*.tif', 'TIFFs generated with MIA';'*.tif','General TIFFs'}, 'Choose an image data file', UserValues.File.MIAFitPath, 'MultiSelect', 'on');
%%% Tranforms to cell array, if only one file was selected
if ~iscell(FileName)
    FileName = {FileName};
end

%%% Stops, if no file was selected
if all(FileName{1}==0)  
    return;
end

%%% Saves pathname to uservalues
UserValues.File.MIAFitPath=PathName;
LSUserValues(1);
%%% Deletes loaded data
if mode==1
    MIAFitData=[];
    MIAFitData.Data=cell(0);
    MIAFitData.FileName=cell(0);
    MIAFitData.Counts=cell(0);
    cellfun(@delete,MIAFitMeta.Plots);
    MIAFitMeta.Data=[];
    MIAFitMeta.Params=[];
    MIAFitMeta.Plots=cell(0);
    h.Fit_Table.RowName(1:end-3)=[];
    h.Fit_Table.Data(1:end-3,:)=[];
    h.Style_Table.RowName(1:end-1,:)=[];
    h.Style_Table.Data(1:end-1,:)=[];
end
for i=1:numel(FileName)
    switch Type
        case 1 %% MIA correlation file based on .mat file            
            MIAFitData.FileName{end+1} = FileName{i};
            load([PathName FileName{i}],'-mat','Data');
            MIAFitData.Data{end+1,1} = Data{1}; %#ok<USENS>
            MIAFitData.Data{end,2} = Data{2};
            clear Data;
            load([PathName FileName{i}],'-mat','Info');
            MIAFitData.Counts{end+1} = Info.Counts/Info.Times(1)*1000;
        case 2 %% MIA correlation file based on .tif + info file
            MIAFitData.FileName{end+1} = FileName{i};
            FileInfo=imfinfo(fullfile(PathName,FileName{i}));
            if numel(FileInfo)==2
                Info = str2num(FileInfo(1).ImageDescription); %#ok<ST2NM>
                MIAFitData.Data{end+1,1} = double(imread(fullfile(PathName,FileName{i}),'TIFF','Index',1));
                MIAFitData.Data{end,1} = MIAFitData.Data{end,1}/Info(1)+Info(2);
                MIAFitData.Counts{end+1} = Info(3)/Info(4)*1000;
                Info = str2num(FileInfo(2).ImageDescription); %#ok<ST2NM>
                MIAFitData.Data{end,2} = double(imread(fullfile(PathName,FileName{i}),'TIFF','Index',2));
                MIAFitData.Data{end,2} = MIAFitData.Data{end,2}/Info(1)+Info(2);
            end       
    end
    %% Creates new plots
    Center = ceil((size(MIAFitData.Data{end,1})+1)/2);
    %%% On Axis X plot
    MIAFitMeta.Plots{end+1,1} = errorbar(...
        0,...
        MIAFitData.Data{end,1}(Center(1), Center(2)),...
        MIAFitData.Data{end,2}(Center(1), Center(2)),...
        'Parent',h.X_Axes);
    %%% On Axis X fit
    MIAFitMeta.Plots{end,2} = line(...
        'Parent',h.X_Axes,...
        'XData',0,...
        'YData',zeros(1));
    %%% On Axis X residuals
    MIAFitMeta.Plots{end,3} = line(...
        'Parent',h.XRes_Axes,...
        'XData',0,...
        'YData',zeros(1));
    %%% On Axis X plot
    MIAFitMeta.Plots{end,4} = errorbar(...
        0,...
        MIAFitData.Data{end,1}(Center(1),Center(2)),...
        MIAFitData.Data{end,2}(Center(1),Center(2)),...
        'Parent',h.Y_Axes);
    %%% On Axis Y fit
    MIAFitMeta.Plots{end,5} = line(...
        'Parent',h.Y_Axes,...
        'XData',0,...
        'YData',zeros(1));
    %%% On Axis Y residuals
    MIAFitMeta.Plots{end,6} = line(...
        'Parent',h.YRes_Axes,...
        'XData',0,...
        'YData',zeros(1));
    
    MIAFitMeta.Params(:,end+1)=cellfun(@str2double,h.Fit_Table.Data(end-2,4:3:end-1));
end
%%% Updates table and plot data and style to new size
Update_Style([],[],1);
Update_Table([],[],1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes fit function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Load_Fit(~,~,mode)
global MIAFitMeta MIAFitData UserValues

FileName=[];
if mode %% Select a new model to load
    [FileName,PathName]= uigetfile('.miafit', 'Choose a fit model', [pwd filesep 'Models']);
    FileName=fullfile(PathName,FileName);
elseif isempty(UserValues.File.MIAFit_Standard) || ~exist(UserValues.File.MIAFit_Standard,'file') 
    %% Opens the first model in the folder at the start of the program
    Models=dir([pwd filesep 'Models']);
    Models=Models(~cell2mat({Models.isdir}));
    while isempty(FileName) && ~isempty(Models)
       if strcmp(Models(1).name(end-6:end),'.miafit')
           FileName=[pwd filesep 'Models' filesep Models(1).name];
           UserValues.File.MIAFit_Standard=FileName;
       else
           Models(1)=[];
       end
    end
else
    %% Opens last model used before closing program
    FileName=UserValues.File.MIAFit_Standard;
end

if ~isempty(FileName)
    UserValues.File.MIAFit_Standard=FileName;
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
    MIAFitMeta.Model=[];
    MIAFitMeta.Model.Name=FileName;
    MIAFitMeta.Model.Brightness=Text{B_Start+1};
    %%% Concaternates the function string
    MIAFitMeta.Model.Function=[];
    for i=Fun_Start+1:numel(Text)
        MIAFitMeta.Model.Function=[MIAFitMeta.Model.Function Text(i)];
    end
    MIAFitMeta.Model.Function=cell2mat(MIAFitMeta.Model.Function);
    %%% Extracts parameter names, initial values and bounds
    MIAFitMeta.Model.Params=cell(NParams,1);
    MIAFitMeta.Model.Value=zeros(NParams,1);
    MIAFitMeta.Model.LowerBoundaries = zeros(NParams,1);
    MIAFitMeta.Model.UpperBoundaries = zeros(NParams,1);
    %%% Reads parameters and values from file
    for i=1:NParams
        %%% Reads parameter name
        Param_Pos=strfind(Text{i+Param_Start},' ');
        MIAFitMeta.Model.Params{i}=Text{i+Param_Start}((Param_Pos(1)+1):(Param_Pos(2)-1));
        
        Start = strfind(Text{i+Param_Start},'=');
        Stop = strfind(Text{i+Param_Start},';');
        
        %%% Reads starting value    
        MIAFitMeta.Model.Value(i) = str2double(Text{i+Param_Start}(Start(1)+1:Stop(1)-1));
        MIAFitMeta.Model.LowerBoundaries(i) = str2double(Text{i+Param_Start}(Start(2)+1:Stop(2)-1));   
        MIAFitMeta.Model.UpperBoundaries(i) = str2double(Text{i+Param_Start}(Start(3)+1:Stop(3)-1));
    end    
    MIAFitMeta.Params=repmat(MIAFitMeta.Model.Value,[1,size(MIAFitData.Data,1)]);
    
    %%% Updates table to new model
    Update_Table([],[],0);
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Plots(~,~)
h = guidata(findobj('Tag','MIAFit'));
global MIAFitMeta MIAFitData UserValues

x = str2double(h.Fit_X.String);
y = str2double(h.Fit_Y.String);
[x,y] = meshgrid(1:x,1:y);
x = x - ceil(max(max(x))/2);
y = y - ceil(max(max(y))/2);
Plot_Errorbars = h.Fit_Errorbars.Value;
Normalization_Method = h.Normalize.Value;

%%% store in UserValues
UserValues.MIAFit.Fit_X = str2double(h.Fit_X.String);
UserValues.MIAFit.Fit_Y = str2double(h.Fit_Y.String);
UserValues.MIAFit.Plot_Errorbars = Plot_Errorbars;
UserValues.MIAFit.NormalizationMethod = Normalization_Method;
UserValues.MIAFit.Omit = h.Omit_Center.Value;
LSUserValues(1);

Active = cell2mat(h.Fit_Table.Data(1:end-3,1));

if all(~Active) %% Clears 2D plot, if all are inactive    
    h.Plots.Main.ZData = zeros(2);
    h.Plots.Main.CData = zeros(2,2,3);
    h.Plots.Fit.ZData = zeros(2);
    h.Plots.Fit.CData = zeros(2,2,3);  
    h.Plot2D.String = {'Nothing selected'};
else %% Updates 2D plot selection string
   h.Plot2D.String = MIAFitData.FileName(Active);
   if h.Plot2D.Value>numel(h.Plot2D.String)
       h.Plot2D.Value = 1;
   end
end
%%% Does the plotting and the calculations
for i=1:size(MIAFitMeta.Plots,1)
    if Active(i)
        Center = ceil((size(MIAFitData.Data{i,1})+1)/2);
        %% Calculates normalization parameter B
        h.Norm_X.Visible='off';
        h.Norm_Y.Visible='off';
        switch Normalization_Method
            case 1 %% No normalization
                B =1 ;
            case 2 %% Normalizes to number of particles 3D (defined in model)
                P = MIAFitMeta.Params(:,i); %#ok<NASGU>
                eval(MIAFitMeta.Model.Brightness);
                B = B/sqrt(8);
                if isnan(B) || B==0 || isinf(B)
                    B = 1;
                end
            case 3 %% Normalizes to G(0) of the fit
                P = MIAFitMeta.Params(:,i); x = 0; y = 0; %#ok<NASGU>
                eval(MIAFitMeta.Model.Function);
                B = OUT;
                if isnan(B) || B==0 || isinf(B)
                    B = 1;
                end
                x = str2double(h.Fit_X.String);
                %%% Has to reset x and y parameters again;
                y = str2double(h.Fit_Y.String);
                [x,y] = meshgrid(1:x,1:y);
                x = x - ceil(max(max(x))/2);
                y = y - ceil(max(max(y))/2);
            case 4 %% Normalizes to number of particles 2D (defined in model)
                P = MIAFitMeta.Params(:,i); %#ok<NASGU>
                eval(MIAFitMeta.Model.Brightness);
                B = B/sqrt(4);
                if isnan(B) || B==0 || isinf(B)
                    B = 1;
                end
            case 5 %% Normalizes to selected pixel
                h.Norm_X.Visible='on';
                h.Norm_Y.Visible='on';
                B = MIAFitData.Data{i,1}(Center(1)+(str2double(h.Norm_Y.String)), Center(2)+(str2double(h.Norm_X.String)));
        end      
        %% Updates on axis data plot y values 
        MIAFitMeta.Plots{i,1}.XData = x(1,:);    
        MIAFitMeta.Plots{i,1}.YData = MIAFitData.Data{i,1}(Center(1), Center(2)+x(1,:))/B;   
        MIAFitMeta.Plots{i,4}.XData = y(:,1);
        MIAFitMeta.Plots{i,4}.YData = MIAFitData.Data{i,1}(Center(1)+y(:,1), Center(2))/B;
       
        %% Updates data errorbars/ turns them off
        if Plot_Errorbars
            MIAFitMeta.Plots{i,1}.LData = MIAFitData.Data{i,2}(Center(1), Center(2)+x(1,:))/B;   
            MIAFitMeta.Plots{i,1}.UData = MIAFitData.Data{i,2}(Center(1), Center(2)+x(1,:))/B;   
            MIAFitMeta.Plots{i,4}.LData = MIAFitData.Data{i,2}(Center(1)+y(:,1), Center(2))/B; 
            MIAFitMeta.Plots{i,4}.UData = MIAFitData.Data{i,2}(Center(1)+y(:,1), Center(2))/B; 
        else
            MIAFitMeta.Plots{i,1}.LData=0;
            MIAFitMeta.Plots{i,1}.UData=0;
            MIAFitMeta.Plots{i,4}.LData=0;
            MIAFitMeta.Plots{i,4}.UData=0;
        end
        %% Calculates fit y data and updates fit plot
        P=MIAFitMeta.Params(:,i); %#ok<NASGU>
        eval(MIAFitMeta.Model.Function);
        OUT=real(OUT);
        if h.Omit_Center.Value
           OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,1)+1)/2)) =...
               (OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,1)+1)/2)+1) + ...
               OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,1)+1)/2)-1))/2; 
        end
        MIAFitMeta.Plots{i,2}.XData=x(1,:);        
        MIAFitMeta.Plots{i,2}.YData=OUT(1-min(min(y)),:)/B;     
        MIAFitMeta.Plots{i,5}.XData=y(:,1);
        MIAFitMeta.Plots{i,5}.YData=OUT(:,1-min(min(x)))/B;
        %% Calculates weighted residuals and plots them
        if h.Fit_Weights.Value
            ResidualsX = (MIAFitMeta.Plots{i,1}.YData-MIAFitMeta.Plots{i,2}.YData)./MIAFitData.Data{i,2}(Center(1), Center(2)+x(1,:))/B;   
            ResidualsY = (MIAFitMeta.Plots{i,4}.YData-MIAFitMeta.Plots{i,5}.YData)./MIAFitData.Data{i,2}(Center(1)+y(:,1), Center(2))'/B;
            Chisqr = sum(((MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT)...
                ./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))).^2); 
        else
            ResidualsX = (MIAFitMeta.Plots{i,1}.YData-MIAFitMeta.Plots{i,2}.YData)*B;
            ResidualsY = (MIAFitMeta.Plots{i,4}.YData-MIAFitMeta.Plots{i,5}.YData)*B;
            Chisqr = sum((MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))-OUT).^2); 
        end
        ResidualsX(ResidualsX==inf | isnan(ResidualsX)) = 0;
        ResidualsY(ResidualsY==inf | isnan(ResidualsY)) = 0;
        MIAFitMeta.Plots{i,3}.XData=x(1,:); 
        MIAFitMeta.Plots{i,3}.YData=ResidualsX; 
        MIAFitMeta.Plots{i,6}.XData=y(:,1); 
        MIAFitMeta.Plots{i,6}.YData=ResidualsY;      
        %% Calculates Chi^2 and updates table
        h.Fit_Table.CellEditCallback = [];
        Chisqr = Chisqr/(numel(x)-sum(~cell2mat(h.Fit_Table.Data(i,5:3:end-1))));
        h.Fit_Table.Data{i,end}=num2str(Chisqr);
        h.Fit_Table.CellEditCallback={@Update_Table,3};
        %% Makes plot visible, if it is active
        MIAFitMeta.Plots{i,1}.Visible='on';
        MIAFitMeta.Plots{i,2}.Visible='on';
        MIAFitMeta.Plots{i,3}.Visible='on';
        MIAFitMeta.Plots{i,4}.Visible='on';
        MIAFitMeta.Plots{i,5}.Visible='on';
        MIAFitMeta.Plots{i,6}.Visible='on';        
        %% Updates 2D plot
        if i == h.Plot2D.Value
            Color = jet(64);
            %% Plots main 2D plot surface
            h.Plots.Main.XData = x(1,:);
            h.Plots.Main.YData = y(:,1);
            h.Plots.Main.ZData = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))./B;            
            %%% Calculates color for main plot faces            
            Data = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))))./B;
            Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
            Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
            Data = Color(Data(:),:);
            Data = reshape(Data,[size(x,1),size(x,2),3]);
            h.Plots.Main.CData = Data;
            %%% Rescales plot
            Range = [min(min(h.Plots.Main.ZData)), max(max(h.Plots.Main.ZData))];
            h.Full_Main_Axes.XLim = [min(min(x)) max(max(x))];
            h.Full_Main_Axes.YLim = [min(min(y)) max(max(y))];
            h.Full_Main_Axes.ZLim = [Range(1)-0.1*diff(Range), Range(2)+0.1*diff(Range)];
            h.Full_Main_Axes.DataAspectRatio = [1 1 1.5*diff(Range)/max(size(x))];            
            %% Plots fit 2D plot surface
            switch h.Plot2DStyle.Value
                case 1 %%% Plots fit
                    addprop(h.Plots.Link,'DataAspectRatio');
                    addprop(h.Plots.Link,'ZLim');
                    Data = OUT./B;
                    h.Plots.Fit.XData = x(1,:);
                    h.Plots.Fit.YData = y(:,1);
                    h.Plots.Fit.ZData = Data;
                    %%% Calculates color for fit plot faces
                    Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                    Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
                    Data = Color(Data(:),:);
                    Data = reshape(Data,[size(x,1),size(x,2),3]);
                    h.Plots.Fit.CData = Data;
                case 2 %%% Plots residuals
                    removeprop(h.Plots.Link,'DataAspectRatio');
                    removeprop(h.Plots.Link,'ZLim');
                    Data = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                    if h.Fit_Weights.Value
                       Data = (Data./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))))^2;                    
                    else
                       Data = Data^2;
                    end
                    Data(Data==inf | isnan(Data)) = 0;
                    h.Plots.Fit.XData = x(1,:);
                    h.Plots.Fit.YData = y(:,1);
                    h.Plots.Fit.ZData = Data;
                    %%% Calculates color for fit plot faces
                    Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                    Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
                    Data = Color(Data(:),:);
                    Data = reshape(Data,[size(x,1),size(x,2),3]);
                    h.Plots.Fit.CData = Data; 
                    %%% Rescales residuals plot
                    Range = [min(min(h.Plots.Fit.ZData)), max(max(h.Plots.Fit.ZData))];
                    h.Full_Fit_Axes.ZLim = [Range(1)-0.1*diff(Range), Range(2)+0.1*diff(Range)];
                    h.Full_Fit_Axes.DataAspectRatio = [1 1 1.5*diff(Range)/max(size(x))];
                case 3 %%% Plots fit with residuals in blue (neg) and red (pos)
                    addprop(h.Plots.Link,'ZLim');
                    addprop(h.Plots.Link,'DataAspectRatio');
                    Color=zeros(64,3);
                    Color(:,1)=[linspace(0,0.8,32), repmat(0.8,[1,32])];
                    Color(:,2)=[linspace(0,0.8,32), linspace(0.8,0,32)];
                    Color(:,3)=[repmat(0.8,[1,32]), linspace(0.8,0,32)];
                    Data = OUT./B;
                    h.Plots.Fit.XData = x(1,:);
                    h.Plots.Fit.YData = y(:,1);
                    h.Plots.Fit.ZData = Data;
                    %%% Calculates color for fit plot faces
                    Data = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))) - OUT;
                    if h.Fit_Weights.Value
                       Data = (Data./MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x)))))^2;                    
                    else
                       Data = Data^2;
                    end
                    Data = (Data + circshift(Data,[0 -1]) + circshift(Data,[-1 0]) + circshift(Data,[-1 -1]))/4;
                    Data = ceil(63*(Data-min(min(Data)))/(max(max(Data))-min(min(Data)))+1);
                    Data = Color(Data(:),:);
                    Data = reshape(Data,[size(x,1),size(x,2),3]);
                    h.Plots.Fit.CData = Data;
            end                    
        end        
    else
        %% Hides plots
        MIAFitMeta.Plots{i,1}.Visible='off';
        MIAFitMeta.Plots{i,2}.Visible='off';
        MIAFitMeta.Plots{i,3}.Visible='off';
        MIAFitMeta.Plots{i,4}.Visible='off';
        MIAFitMeta.Plots{i,5}.Visible='off';
        MIAFitMeta.Plots{i,6}.Visible='off';
    end
end

%%% Generates figure legend entries
Active=find(Active);
LegendString=cell(numel(Active)*2,1);
LegendUse=h.X_Axes.Children(1:numel(Active)*2);
for i=1:numel(Active)
    LegendString{2*i-1}=['Data: ' MIAFitData.FileName{Active(i)}];
    LegendString{2*i}  =['Fit:  ' MIAFitData.FileName{Active(i)}];
    LegendUse(2*i-1)=MIAFitMeta.Plots{Active(i),1};
    LegendUse(2*i)=MIAFitMeta.Plots{Active(i),2};
end
if ~isempty(LegendString)
    %% Active legend    
    h.MIAFit_Legend(1)=legend(h.X_Axes,LegendUse,LegendString,'Interpreter','none');
    h.MIAFit_Legend(2)=legend(h.Y_Axes,LegendUse,LegendString,'Interpreter','none');
    guidata(h.MIAFit,h);
else
    %% Hides legend for empty plot
    h.MIAFit_Legend(1).Visible='off';
    h.MIAFit_Legend(2).Visible='off';
end
drawnow;

%%% Updates axes limits
h.X_Axes.XLim = [min(min(x)), max(max(x))]; h.X_Axes.YLimMode ='Auto';
h.Y_Axes.XLim = [min(min(y)), max(max(y))]; h.Y_Axes.YLimMode ='Auto';
h.XRes_Axes.XLim = [min(min(x)), max(max(x))]; h.XRes_Axes.YLimMode ='Auto';
h.YRes_Axes.XLim = [min(min(y)), max(max(y))]; h.YRes_Axes.YLimMode ='Auto';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function that updates fit table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Table(~,e,mode)
h = guidata(findobj('Tag','MIAFit'));
global MIAFitData MIAFitMeta

switch mode
    case 0 %% Updates whole table (Load Fit etc.)
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Generates column names and resized them
        Columns=cell(3*numel(MIAFitMeta.Model.Params)+4,1);
        Columns{1}='Active';
        Columns{2}='<HTML><b> Counts [khz] </b>';
        Columns{3}='<HTML><b> Brightness [khz]</b>';
        for i=1:numel(MIAFitMeta.Model.Params)
            Columns{3*i+1}=['<HTML><b>' MIAFitMeta.Model.Params{i} '</b>'];
            Columns{3*i+2}='F';
            Columns{3*i+3}='G';
        end
        Columns{end}='Chi?';
        ColumnWidth=zeros(numel(Columns),1);
        ColumnWidth(4:3:end-1) = 80;
        ColumnWidth(5:3:end-1)=20;
        ColumnWidth(6:3:end-1)=20;
        ColumnWidth(1)=40;
        ColumnWidth(2)=80;
        ColumnWidth(3)=100;
        ColumnWidth(end)=40;
        h.Fit_Table.ColumnName=Columns;
        h.Fit_Table.ColumnWidth=num2cell(ColumnWidth');
        %%% Sets row names to file names
        Rows=cell(size(MIAFitData.Data,1)+3,1);
        Rows(1:size(MIAFitData.Data,1))=deal(MIAFitData.FileName);
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
            Data{i,2}=mean(MIAFitData.Counts{i});
        end
        Data(1:end-3,4:3:end-1)=deal(num2cell(MIAFitMeta.Params)');
        Data(end-2,4:3:end-1)=deal(num2cell(MIAFitMeta.Model.Value)');
        Data(end-1,4:3:end-1)=deal(num2cell(MIAFitMeta.Model.LowerBoundaries)');
        Data(end,4:3:end-1)=deal(num2cell(MIAFitMeta.Model.UpperBoundaries)');
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
    case 1 %% Updates tables when new data is loaded
        h.Fit_Table.CellEditCallback=[];
        %%% Sets row names to file names
        Rows=cell(size(MIAFitData.Data,1)+3,1);
        Rows(1:size(MIAFitData.Data,1))=deal(MIAFitData.FileName);
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
        for i=1:numel(MIAFitData.Counts)
            Data{i,2}=num2str(mean(MIAFitData.Counts{i}));
        end
        h.Fit_Table.Data=Data;
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 2 %% Updates table after fit
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        %%% Updates parameter values in table
        h.Fit_Table.Data(1:end-3,4:3:end-1)=cellfun(@num2str,num2cell(MIAFitMeta.Params)','UniformOutput',false);
        %%% Updates plots
        Update_Plots
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
    case 3 %% Individual cells calbacks
        %%% Disables cell callbacks, to prohibit double callback
        h.Fit_Table.CellEditCallback=[];
        if strcmp(e.EventName,'CellSelection') %%% No change in Value, only selected
            if isempty(e.Indices)
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
                MIAFitMeta.Params((e.Indices(2)-1)/3,:)=str2double(NewData);
            elseif mod(e.Indices(2)-5,3)==0 && e.Indices(2)>=6 && NewData==1
                %% Value was fixed => Uncheck global
                h.Fit_Table.Data(1:end-2,e.Indices(2)+1)=deal({false});
            elseif mod(e.Indices(2)-6,3)==0 && e.Indices(2)>=6 && NewData==1
                %% Global was change
                %%% Apply value to all files
                h.Fit_Table.Data(1:end-2,e.Indices(2)-2)=h.Fit_Table.Data(e.Indices(1),e.Indices(2)-2);
                %%% Apply value to global variables
                MIAFitMeta.Params((e.Indices(2)-3)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
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
                MIAFitMeta.Params((e.Indices(2)-3)/3,:)=str2double(h.Fit_Table.Data{e.Indices(1),e.Indices(2)-2});
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
                MIAFitMeta.Params((e.Indices(2)-1)/3,:)=str2double(NewData);
            else
                %% Not global => only changes value
                MIAFitMeta.Params((e.Indices(2)-1)/3,e.Indices(1))=str2double(NewData);
                
            end
        elseif e.Indices(2)==1
            %% Active was changed
        end
        %%% Enables cell callback again
        h.Fit_Table.CellEditCallback={@Update_Table,3};
end

%%% Calculates brightness for all files
for i=1:size(MIAFitMeta.Params,2)
    P=MIAFitMeta.Params(:,i); %#ok<NASGU>
    eval(MIAFitMeta.Model.Brightness);
    h.Fit_Table.Data{i,3}=num2str(mean(MIAFitData.Counts{i})*B);
end

Update_Plots;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Changes plotting style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update_Style(~,e,mode) 
global MIAFitMeta MIAFitData UserValues
h = guidata(findobj('Tag','MIAFit'));
switch mode
    case 0 %% Called at the figure initialization
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
        h.Style_Table.Data=UserValues.MIAFit.PlotStyleAll;        
    case 1 %% Called, when new file is loaded
        %%% Sets row names to file names 
        Rows=cell(size(MIAFitData.Data,1)+1,1);
        Rows(1:size(MIAFitData.Data,1))=deal(MIAFitData.FileName);
        Rows{end}='ALL';
        h.Style_Table.RowName=Rows;
        Data=cell(numel(Rows),size(h.Style_Table.Data,2));
        %%% Sets ALL style to last row
        Data(end,:)=UserValues.MIAFit.PlotStyleAll;
        %%% Sets previous styles to first rows
        if size(MIAFitData.Data,1) <= size(UserValues.MIAFit.PlotStyles,1)
            Data(1:size(MIAFitData.Data,1),:) = UserValues.MIAFit.PlotStyles(1:size(MIAFitData.Data,1),:);
        else
            Data(1:size(UserValues.MIAFit.PlotStyles,1),:) = UserValues.MIAFit.PlotStyles;
            for i=size(UserValues.MIAFit.PlotStyles,1)+1:size(MIAFitData.Data,1)
               Data(i,:) = UserValues.MIAFit.PlotStyleAll; 
            end
        end
        %%% Updates new plots to style
        for i=1:numel(MIAFitData.FileName)
           MIAFitMeta.Plots{i,1}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,2}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,3}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,4}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,5}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,6}.Color=num2str(Data{i,1});
           MIAFitMeta.Plots{i,1}.LineStyle=Data{i,2};
           MIAFitMeta.Plots{i,4}.LineStyle=Data{i,2};
           MIAFitMeta.Plots{i,1}.LineWidth=str2double(Data{i,3});
           MIAFitMeta.Plots{i,4}.LineWidth=str2double(Data{i,3});
           MIAFitMeta.Plots{i,1}.Marker=Data{i,4};
           MIAFitMeta.Plots{i,4}.Marker=Data{i,4};
           MIAFitMeta.Plots{i,1}.MarkerSize=str2double(Data{i,5});
           MIAFitMeta.Plots{i,4}.MarkerSize=str2double(Data{i,5});
           MIAFitMeta.Plots{i,2}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,5}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,3}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,6}.LineStyle=Data{i,6};
           MIAFitMeta.Plots{i,2}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,5}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,3}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,6}.LineWidth=str2double(Data{i,7});
           MIAFitMeta.Plots{i,2}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,5}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,3}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,6}.Marker=Data{i,8};
           MIAFitMeta.Plots{i,2}.MarkerSize=str2double(Data{i,7});
           MIAFitMeta.Plots{i,5}.MarkerSize=str2double(Data{i,7});
           MIAFitMeta.Plots{i,3}.MarkerSize=str2double(Data{i,7});
           MIAFitMeta.Plots{i,6}.MarkerSize=str2double(Data{i,7});
        end
        h.Style_Table.Data=Data;
    case 2 %% Cell callback
        %%% Applies to all files if ALL row was used
        if e.Indices(1)==size(h.Style_Table.Data,1)
            File=1:(size(h.Style_Table.Data,1)-1);
            h.Style_Table.Data(:,e.Indices(2))=deal({e.NewData});
        else
            File=e.Indices(1);
        end
        switch e.Indices(2)
            case 1 %% Changes file color
                for i = File
                    NewColor = str2num(e.NewData); %#ok<ST2NM>
                    MIAFitMeta.Plots{i,1}.Color=NewColor;
                    MIAFitMeta.Plots{i,2}.Color=NewColor;
                    MIAFitMeta.Plots{i,3}.Color=NewColor;
                    MIAFitMeta.Plots{i,4}.Color=NewColor;
                    MIAFitMeta.Plots{i,5}.Color=NewColor;
                    MIAFitMeta.Plots{i,6}.Color=NewColor;
                end
            case 2 %% Changes data line style
                for i = File
                    MIAFitMeta.Plots{i,1}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,4}.LineStyle=e.NewData;
                end
            case 3 %% Changes data line width
                for i=File
                    MIAFitMeta.Plots{i,1}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,4}.LineWidth=str2double(e.NewData);
                end
            case 4 %% Changes data marker style
                for i=File
                    MIAFitMeta.Plots{i,1}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,4}.Marker=e.NewData;
                end
            case 5 %% Changes data marker size
                for i=File
                    MIAFitMeta.Plots{i,1}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,4}.MarkerSize=str2double(e.NewData);
                end
            case 6 %% Changes fit line style
                for i=File
                    MIAFitMeta.Plots{i,2}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,3}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,5}.LineStyle=e.NewData;
                    MIAFitMeta.Plots{i,6}.LineStyle=e.NewData;
                end
            case 7 %% Changes fit line width
                for i=File
                    MIAFitMeta.Plots{i,2}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,3}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,5}.LineWidth=str2double(e.NewData);
                    MIAFitMeta.Plots{i,6}.LineWidth=str2double(e.NewData);
                end
            case 8 %% Changes fit marker style
                for i=File
                    MIAFitMeta.Plots{i,2}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,3}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,5}.Marker=e.NewData;
                    MIAFitMeta.Plots{i,6}.Marker=e.NewData;
                end
            case 9 %% Changes fit marker size
                for i=File
                    MIAFitMeta.Plots{i,2}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,3}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,5}.MarkerSize=str2double(e.NewData);
                    MIAFitMeta.Plots{i,6}.MarkerSize=str2double(e.NewData);
                end
            case 10 %% Removes files
                File=flip(File,2);
                for i=File
                    MIAFitData.Data(i,:)=[];
                    MIAFitData.FileName(i)=[];
                    MIAFitData.Counts(i)=[];
                    cellfun(@delete,MIAFitMeta.Plots(i,:));
                    MIAFitMeta.Params(:,i)=[];
                    MIAFitMeta.Plots(i,:)=[];
                    h.Fit_Table.RowName(i)=[];
                    h.Fit_Table.Data(i,:)=[];
                    h.Style_Table.RowName(i)=[];
                    h.Style_Table.Data(i,:)=[];
                end
        end
end
%%% Save Updated UiTableData to UserValues.MIAFit.PlotStyles
UserValues.MIAFit.PlotStyles(1:(size(h.Style_Table.Data,1)-1),:) = h.Style_Table.Data(1:(end-1),:);
UserValues.MIAFit.PlotStyleAll = h.Style_Table.Data(end,:);
LSUserValues(1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Executes fitting routine %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_MIAFit(~,~)
global MIAFitMeta MIAFitData UserValues
h = guidata(findobj('Tag','MIAFit'));
%%% Indicates fit in progress
h.MIAFit.Name = 'MIA Fit  FITTING';
h.Fit_Table.Enable = 'off';
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
UserValues.MIAFit.Max_Iterations = MaxIter;
UserValues.MIAFit.Fit_Tolerance = TolFun;
Use_Weights = h.Fit_Weights.Value;
UserValues.MIAFit.Use_Weights = Use_Weights;
LSUserValues(1);
%%% Optimization settings
opts=optimset('Display','off','TolFun',TolFun,'MaxIter',MaxIter);

%%% Determines x and y data
x = str2double(h.Fit_X.String);
y = str2double(h.Fit_Y.String);
[x,y] = meshgrid(1:x,1:y);
x = x - ceil(max(max(x))/2);
y = y - ceil(max(max(y))/2);

%%% Performs fit
if sum(Global)==0
    %% Individual fits, not global
    for i = find(Active)';
        %%% Reads in parameters
        Center = ceil((size(MIAFitData.Data{i,1})+1)/2);        
        ZData = MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        EData = MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        Omit = MIAFitData.Data{i,1}(Center(1), Center(2));
        %%% Disables weights
        if ~Use_Weights
            EData(:)=1;
        end
        %%% Sets initial values and bounds for non fixed parameters
        Fit_Params=MIAFitMeta.Params(~Fixed(i,:),i);
        Lb=lb(~Fixed(i,:));
        Ub=ub(~Fixed(i,:));
        %%% Performs fit
        tic;
        [Fitted_Params,~,~,Flag,~,~,~]=lsqcurvefit(@Fit_Single,Fit_Params,{x,y,EData,Omit,i},ZData./EData,Lb,Ub,opts);
        toc;
        %%% Updates parameters
        MIAFitMeta.Params(~Fixed(i,:),i)=Fitted_Params;
    end  
else
    %% Global fits
    ZData = []; EData = [];
    X = []; Y = [];
    Points = []; Omit = [];
    %%% Sets initial value and bounds for global parameters
    Fit_Params=MIAFitMeta.Params(Global,1);
    Lb=lb(Global);
    Ub=ub(Global);
    for  i=find(Active)' 
        %%% Reads in parameters of current file   
        Center = ceil((size(MIAFitData.Data{i,1})+1)/2);  
        zdata=MIAFitData.Data{i,1}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        edata=MIAFitData.Data{i,2}(Center(1)+(min(min(y)):max(max(y))), Center(2)+(min(min(x)):max(max(x))));
        %%% Disables weights
        if ~Use_Weights
            edata(:)=1;
        end
        ZData = [ZData;zdata(:)];
        EData = [EData;edata(:)];
        X = [X; x(:)];
        Y = [Y; y(:)];
        Omit = [Omit; MIAFitData.Data{i,1}(Center(1), Center(2))];
        Points(end+1) = numel(x);
        %%% Concaternates initial values and bounds for non fixed parameters
        Fit_Params=[Fit_Params; MIAFitMeta.Params(~Fixed(i,:)& ~Global,i)];
        Lb=[Lb lb(~Fixed(i,:) & ~Global)];
        Ub=[Ub ub(~Fixed(i,:) & ~Global)];
    end
    %%% Performs fit
    [Fitted_Params,~,~,Flag,~,~,~]=lsqcurvefit(@Fit_Global,Fit_Params,{X,Y,EData,Omit,Points},ZData./EData,Lb,Ub,opts);
    %%% Updates parameters
    MIAFitMeta.Params(Global,:)=repmat(Fitted_Params(1:sum(Global)),[1 size(MIAFitMeta.Params,2)]) ;
    Fitted_Params(1:sum(Global))=[];
    for i=find(Active)'
        MIAFitMeta.Params(~Fixed(i,:) & ~Global,i)=Fitted_Params(1:sum(~Fixed(i,:) & ~Global)); 
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
h.MIAFit.Name='MIA Fit';
%%% Updates table values and plots
Update_Table([],[],2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for individual fits %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Single(Fit_Params,Data)
%%% Fit_Params: Non fixed parameters of current file
%%% Data{1}:    x values of current file
%%% Data{2}:    y values of current file
%%% Data{3}:    Weights of current file
%%% Data{4}:    Indentifier of current file

global MIAFitMeta
h = guidata(findobj('Tag','MIAFit'));

x = Data{1}; %#ok<NASGU>
y = Data{2}; %#ok<NASGU>
Weights = Data{3};
Omit = Data{4};
file = Data{5};

%%% Determines, which parameters are fixed
Fixed = cell2mat(h.Fit_Table.Data(file,5:3:end-1));
P = zeros(numel(Fixed),1);
%%% Assigns fitting parameters to unfixed parameters of fit
P(~Fixed) = Fit_Params;
%%% Assigns parameters from table to fixed parameters
P(Fixed) = MIAFitMeta.Params(Fixed,file); %#ok<NASGU>
%%% Applies function on parameters
eval(MIAFitMeta.Model.Function);
if h.Omit_Center.Value
    OUT(floor((size(OUT,1)+1)/2),floor((size(OUT,1)+1)/2)) = Omit;  %#ok<NODEF>
end
%%% Applies weights
Out=OUT./Weights;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Actual fitting function for global fits %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Out] = Fit_Global(Fit_Params,Data)
%%% Fit_Params: [Global parameters, Non fixed parameters of all files]
%%% Data{1}:    x values of current file
%%% Data{2}:    y values of current file
%%% Data{3}:    Weights of current file
%%% Data{4}:    Length indentifier for X and Weights data of each file

global MIAFitMeta
h = guidata(findobj('Tag','MIAFit'));


X=Data{1};
Y=Data{2};
Weights=Data{3};
Omit = Data{4};
Points=Data{5};


%%% Determines, which parameters are fixed, global and which files to use
Fixed = cell2mat(h.Fit_Table.Data(1:end-3,5:3:end));
Global = cell2mat(h.Fit_Table.Data(end-2,6:3:end));
Active = cell2mat(h.Fit_Table.Data(1:end-3,1));
P = zeros(numel(Global),1);

%%% Asignes global parameters
P(Global) = Fit_Params(1:sum(Global));
Fit_Params(1:sum(Global)) = [];

Out=[];k=1;
for i=find(Active)'
  %%% Sets non-fixed parameters
  P(~Fixed(i,:) & ~Global) = Fit_Params(1:sum(~Fixed(i,:) & ~Global)); 
  Fit_Params(1:sum(~Fixed(i,:)& ~Global)) = [];  
  %%% Sets fixed parameters
  P(Fixed(i,:) & ~Global) = MIAFitMeta.Params((Fixed(i,:)& ~Global),i);
  %%% Defines XData and YData for the file
  x = X(1:Points(k)); y = Y(1:Points(k));
  X(1:Points(k))=[]; Y(1:Points(k)) = []; 
  %%% Calculates function for current file
  eval(MIAFitMeta.Model.Function);
  if h.Omit_Center.Value
      OUT(x==0 & y==0) = Omit(k); %#ok<AGROW>
  end
  Out=[Out;OUT]; 
  k=k+1;
end
Out=Out./Weights;





















