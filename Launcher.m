function Launcher(~,~)
hfig=findobj('Tag','Launcher');
global UserValues PathToApp

addpath(genpath(['.' filesep 'functions']));

if isempty(PathToApp)
    GetAppFolder();
end
LSUserValues(0);
Look=UserValues.Look;

ImageFolderPath = [PathToApp filesep 'images' filesep 'Launcher' filesep];
if isempty(hfig)
    %%% find screen size
    r = groot;
    screensize = r.ScreenSize;
    height = 400;
    width = round(1.6*height);
    %%% place in middle
    pos = [floor(screensize(3)/2-width/2),floor(screensize(4)/2-height/2),width,height];
    h.Launcher = figure(...
        'Units','pixels',...
        'OuterPosition',pos,...
        'Name','Launcher',...
        'NumberTitle','off',...
        'MenuBar','none',...
        'defaultUicontrolFontName',Look.Font,...
        'defaultAxesFontName',Look.Font,...
        'defaultTextFontName',Look.Font,...
        'UserData',[],...
        'Visible','off',...
        'Tag','Launcher',...
        'Toolbar','none',...
        'Resize','off',...
        'Color',Look.Back);
    
    %%% container for buttons
    warning('off','MATLAB:uigridcontainer:MigratingFunction');
    h.button_container = uigridcontainer(...
        'Parent',h.Launcher,...
        'Units','norm',...
        'Position',[0,0,1,1],...
        'GridSize',[3,3],...
        'BackgroundColor',Look.Back);
    %%% buttons for launching programs
    h.PAM_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@LaunchPam);
    iconbutton(h.PAM_button,[ImageFolderPath 'Pam.jpg']);
    
    h.BurstBrowser_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@LaunchBurstBrowser);
    iconbutton(h.BurstBrowser_button,[ImageFolderPath 'BurstBrowser.jpg']);
    
    h.FCSFit_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@FCSFit);
    iconbutton(h.FCSFit_button,[ImageFolderPath 'FCSFit.jpg']);
    
    h.MIA_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@Mia);
    iconbutton(h.MIA_button,[ImageFolderPath 'MIA.jpg']);
    
    h.MIAFit_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@MIAFit);
    iconbutton(h.MIAFit_button,[ImageFolderPath 'MIAFit.jpg']);
    
    h.Phasor_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@Phasor);
    iconbutton(h.Phasor_button,[ImageFolderPath 'Phasor.jpg']);
    
%     h.PCF_button = uicontrol(...
%         'Parent',h.button_container,...
%         'BackgroundColor','white',...
%         'Units','normalized',...
%         'Position',[0.05,0.05,0.9,0.9],...
%         'Callback',@PCFAnalysis);
%     iconbutton(h.PCF_button,'images/Launcher/PCF.jpg');

    h.TauFit_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@LaunchTauFit,...
        'Tag','TauFit_Launcher');
    iconbutton(h.TauFit_button,[ImageFolderPath 'TauFit.jpg']);
    
    h.Sim_button = uicontrol(...
        'Parent',h.button_container,...
        'BackgroundColor','white',...
        'Units','normalized',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@Sim);
    iconbutton(h.Sim_button,[ImageFolderPath 'Sim.jpg']);
    
    h.Doc_button = uicontrol(...
        'Parent',h.button_container,...
        'Units','normalized',...
        'BackgroundColor','white',...
        'Position',[0.05,0.05,0.9,0.9],...
        'Callback',@Open_Doc);
    iconbutton(h.Doc_button,[ImageFolderPath 'Doc.jpg']);
    
    h.Launcher.Visible = 'on';
else
    figure(hfig);
end

function LaunchPam(~,~)
PAM();

function LaunchBurstBrowser(~,~)
BurstBrowser();

function LaunchTauFit(~,~)
TauFit();

function Open_Doc(~,~)
global PathToApp
if isunix
    path = fullfile(PathToApp,'doc/sphinx_docs/build/html/index.html');
elseif ispc
    path = fullfile(PathToApp,'doc\sphinx_docs\build\html\index.html');
end
if ~isdeployed
    web(path);
else
    %%% use system call to browser
    if isunix
        % fix spaces in path
        path = strrep(path,' ','\ ');
    end
    web(path,'-browser');
end
