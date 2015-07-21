function  [Profiles,Current] = LSUserValues(Mode)
global UserValues


if Mode==0 %%% Loads user values    
    %% Identifying current profile
    %%% Current profiles directory
    Profiledir = [pwd filesep 'profiles'];
    %%% Finds all matlab files in profiles directory
    Profiles = what(Profiledir);
    %%% Only uses .mat files
    Profiles=Profiles.mat;
    %%% Removes Profile.mat from list (Profile.mat saves the currently used profile
    for i=1:numel(Profiles)
        if strcmp(Profiles{i},'Profile.mat')
            Profiles(i)=[];
            break;
        end
    end
    
    %%% Checks, if a Profile exists and if Profile.mat has a valid profile saved
    %%% Both do not exist; it creates new ones
    if isempty(Profiles) && ~exist([Profiledir filesep 'Profile.mat'],'file')
        PIE=[];
        Profile='StartingProfile.mat';
        save([Profiledir filesep 'Profile.mat'],'Profile');
        save([Profiledir filesep 'StartingProfile.mat'],'PIE');
        %%% Saves first Profile to Profiles.mat, if none was saved
    elseif ~isempty(Profiles) && ~exist([Profiledir filesep 'Profile.mat'],'file')
        Profile=Profiles{1};
        save([Profiledir filesep 'Profile.mat'],'Profile');
        %%% Generates a Standard profile, if none existed
    elseif isempty(Profiles) && exist([Profiledir filesep 'Profile.mat'],'file')
        PIE=[];
        save([Profiledir filesep 'StartingProfile.mat'],'PIE');
    end
    %%% Determines current Profile
    load([Profiledir filesep 'Profile.mat']);
    
    %%% Compares current profile to existing profiles
    Current=[];
    for i=1:numel(Profiles)
        if strcmp(Profiles{i},Profile)
            Current=Profile;
        end
    end
    %%% Checks, if current profile exists; if not, uses first profile
    if isempty(Current)
        Profile=Profiles{1};
        Current=Profiles{1};
    end
    %%% Loads UserValues of current profile
    S = load(fullfile(Profiledir,Profile));
    
    
    %% PIE: Definition of PIE channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Do not add new fields!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Checks, if all fields exist and redefines them
    if ~isfield (S, 'PIE') || any(~isfield(S.PIE, {'Name';'Detector';'Router';'From';'To';'Color';'Combined';'Duty_Cycle'}));
        S.PIE=[];
        S.PIE.Name={'Channel1'};
        S.PIE.Detector=1;
        S.PIE.Router=1;
        S.PIE.From=0;
        S.PIE.To=4096;
        S.PIE.Color=[1 0 0];
        S.PIE.Combined={[]};
        S.PIE.Duty_Cycle=0;
        S.PIE.IRF = {[]};
        S.PIE.ScatterPattern = {[]};
        disp('UserValues.PIE was incomplete');
    end
    P.PIE = [];
    P.PIE.Name = S.PIE.Name;
    P.PIE.Detector = S.PIE.Detector;
    P.PIE.Router = S.PIE.Router;
    P.PIE.From = S.PIE.From;
    P.PIE.To = S.PIE.To;
    P.PIE.Color = S.PIE.Color;
    P.PIE.Combined = S.PIE.Combined;
    P.PIE.Duty_Cycle = S.PIE.Duty_Cycle;
    if ~isfield(S.PIE,'IRF')
        S.PIE.IRF = cell(1,numel(S.PIE.Name));
        disp('UserValues.PIE.IRF was incomplete');
    end
    P.PIE.IRF = S.PIE.IRF;
    if ~isfield(S.PIE,'ScatterPattern')
        S.PIE.ScatterPattern = cell(1,numel(S.PIE.Name));
        disp('UserValues.PIE.ScatterPattern was incomplete');
    end
    P.PIE.ScatterPattern = S.PIE.ScatterPattern;
    %% Detector: Definition of Tcspc cards/routing channels to use %%%%%%%%%%%%
    %%% Do not add new fields!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Checks, if all fields exist and redefines them
    if ~isfield (S, 'Detector') || any(~isfield(S.Detector, {'Det';'Rout';'Color';'Shift';'Name';'Plots'}));
        S.Detector=[];
        S.Detector.Det=1;
        S.Detector.Rout=1;
        S.Detector.Color=[1 0 0];
        S.Detector.Shift={zeros(400,1)};
        S.Detector.Name={'1'};
        S.Detector.Plots=1;
        disp('UserValues.Detector was incomplete');
    end
    P.Detector = [];
    P.Detector.Det = S.Detector.Det;
    P.Detector.Rout = S.Detector.Rout;
    P.Detector.Color = S.Detector.Color;
    P.Detector.Shift = S.Detector.Shift;
    P.Detector.Name = S.Detector.Name;
    P.Detector.Plots = S.Detector.Plots;
    %% Look: Definition of Pam colors and style %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Do not add new fields!!! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Checks, if fields exist
    if ~isfield (S, 'Look') || any(~isfield(S.Look, {'Back';'Fore';'Control';'Axes';'Disabled';'Shadow';'AxesFore';'List';'ListFore';'Table1';'Table2';'TableFore';'Font'}));
        S.Look=[];
        S.Look.Back=[0.2 0.2 0.2];
        S.Look.Fore=[1 1 1];
        S.Look.Control=[0.4 0.4 0.4];
        S.Look.Disabled=[0 0 0];
        S.Look.Shadow=[0.4 0.4 0.4];
        S.Look.Axes=[0.8 0.8 0.8];
        S.Look.AxesFore=[0 0 0];
        S.Look.List=[0.8 0.8 0.8];
        S.Look.ListFore=[0 0 0];
        S.Look.Table1=[0.9 0.9 0.9];
        S.Look.Table2=[0.8 0.8 0.8];
        S.Look.TableFore=[0 0 0];
        S.Look.Font = 'Times';
        disp('UserValues.Look was incomplete');
    end
    P.Look = [];
    P.Look.Back = S.Look.Back;
    P.Look.Fore = S.Look.Fore;
    P.Look.Control = S.Look.Control;
    P.Look.Disabled = S.Look.Disabled;
    P.Look.Shadow = S.Look.Shadow;
    P.Look.Axes = S.Look.Axes;
    P.Look.AxesFore = S.Look.AxesFore;
    P.Look.List = S.Look.List;
    P.Look.ListFore = S.Look.ListFore;
    P.Look.Table1=S.Look.Table1;
    P.Look.Table2=S.Look.Table2;
    P.Look.TableFore=S.Look.TableFore;
    P.Look.Font = S.Look.Font;
    %% File: Last used Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Checks, if fields exist
    if ~isfield (S, 'File');
        S.File=[];
        disp('UserValues.File was incomplete');
    end
    P.File = [];
    if ~isfield(S.File, 'Path') || ~exist(S.File.Path,'dir')
        S.File.Path=pwd;
    end
    P.File.Path = S.File.Path;
    if ~isfield(S.File, 'ExportPath') || isempty(S.File.ExportPath) || ~ischar(S.File.ExportPath) || ~exist(S.File.ExportPath,'dir')
        S.File.ExportPath=pwd;
    end
    P.File.ExportPath = S.File.ExportPath;
    if ~isfield(S.File, 'PhasorPath') || isempty(S.File.PhasorPath)  || ~ischar(S.File.PhasorPath) || ~exist(S.File.PhasorPath,'dir')
        S.File.PhasorPath=pwd;
    end
    P.File.PhasorPath = S.File.PhasorPath;
    if ~isfield(S.File, 'FCSPath') || isempty(S.File.FCSPath)  || ~ischar(S.File.FCSPath) || ~exist(S.File.FCSPath,'dir')
        S.File.FCSPath=pwd;
    end
    P.File.FCSPath = S.File.FCSPath;
    if ~isfield(S.File, 'MIAPath') || isempty(S.File.MIAPath)  || ~ischar(S.File.MIAPath) || ~exist(S.File.MIAPath,'dir')
        S.File.MIAPath=pwd;
    end 
    P.File.MIAPath = S.File.MIAPath;
    if ~isfield(S.File, 'MIAFitPath') || isempty(S.File.MIAFitPath)  || ~ischar(S.File.MIAFitPath) || ~exist(S.File.MIAFitPath,'dir')
        S.File.MIAFitPath=pwd;
    end
    P.File.MIAFitPath = S.File.MIAFitPath;
    if ~isfield(S.File, 'BurstBrowserPath') || isempty(S.File.BurstBrowserPath)  || ~ischar(S.File.BurstBrowserPath) || ~exist(S.File.BurstBrowserPath,'dir')
        S.File.BurstBrowserPath=pwd;
    end 
    P.File.BurstBrowserPath = S.File.BurstBrowserPath;
    if ~isfield(S.File,'PCFPath') || isempty(S.File.PCFPath)  || ~ischar(S.File.PCFPath) || ~exist(S.File.PCFPath,'dir')
        S.File.PCFPath=pwd;
    end
    P.File.PCFPath = S.File.PCFPath;
    if ~isfield(S.File,'SimPath') || isempty(S.File.SimPath)  || ~ischar(S.File.SimPath) || ~exist(S.File.SimPath,'dir')
        S.File.SimPath=pwd;
    end
    P.File.SimPath = S.File.SimPath;
    if ~isfield(S.File, 'PhasorTIFFPath') || isempty(S.File.PhasorTIFFPath)  || ~ischar(S.File.PhasorTIFFPath) || ~exist(S.File.PhasorTIFFPath,'dir')
        S.File.PhasorTIFFPath=pwd;
    end
    P.File.PhasorTIFFPath = S.File.PhasorTIFFPath;
    
    
    if ~isfield(S.File,'FCS_Standard') 
        S.File.FCS_Standard=[];
    end
    P.File.FCS_Standard = S.File.FCS_Standard;
    if ~isfield(S.File,'MIAFit_Standard')
        S.File.MIAFit_Standard=[];
    end
    P.File.MIAFit_Standard = S.File.MIAFit_Standard;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% File types for uigetfile with SPC files  %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% CurrentFileTypes is the list of the filetypes for the selection
    %%% menu.
    %%% You can edit it here if you want to change/add filetypes.
    %%% The order of filetypes has to correspond to the order in
    %%% LoadTcspc!
    CurrentFileTypes = {'*0.spc','B&H SPC files recorded with FabSurf (*0.spc)';...
            '*_m1.spc','Multi-card B&H SPC files recorded with B&H-Software (*_m1.spc)';...
            '*.spc','Single card B&H SPC files recorded with B&H-Software (*.spc)';...
            '*.ht3','HydraHarp400 TTTR file (*.ht3)';...
            '*.ht3','FabSurf HydraHarp400 TTTR file (*.ht3)';...
            '*.sim','Pam Simulation file';...
            '*.ppf','Pam Photon File (Created by Pam)'};

    if ~isfield(S.File, 'SPC_FileTypes')
        disp('WARNING: UserValues structure incomplete, field "SPC_FileTypes" missing');
        S.File.SPC_FileTypes = CurrentFileTypes;
    end
    %%% Check for changes
    if ~(isempty(setdiff(S.File.SPC_FileTypes,CurrentFileTypes)) && isempty(setdiff(CurrentFileTypes,S.File.SPC_FileTypes)) )
        %%% overwrite loaded UserValues.File.SPC_FileTypes
        S.File.SPC_FileTypes = CurrentFileTypes;
    end
    P.File.SPC_FileTypes = S.File.SPC_FileTypes;
    %%% Saves the current selected FileType with respect to the static
    %%% FileType-List above
    if ~isfield(S.File, 'OpenTCSPC_FilterIndex')
        disp('WARNING: UserValues structure incomplete, field "OpenTCSPC_FilterIndex" missing');
        S.File.OpenTCSPC_FilterIndex = 1;
    end
    P.File.OpenTCSPC_FilterIndex = S.File.OpenTCSPC_FilterIndex;
    %% Settings: All values of popupmenues, checkboxes etc. that need to be persistent
    
    %%% Checks, if Settings field exists
    if ~isfield (S, 'Settings')
        S.Settings=[];
        disp('UserValues.Settings was incomplete');
    end
    P.Settings = [];
    %%% Checks, if Pam subfield exists
    if ~isfield (S.Settings, 'Pam')
        S.Settings.Pam=[];
        disp('UserValues.Settings.Pam was incomplete');
    end
    P.Settings.Pam = [];
    %%% Checks, if Pam.Use_Image subfield exists
    if ~isfield (S.Settings.Pam, 'Use_Image')
        S.Settings.Pam.Use_Image=0;
        disp('UserValues.Settings.Pam.Use_Image was incomplete');
    end
    P.Settings.Pam.Use_Image = S.Settings.Pam.Use_Image;
    %%% Checks, if Pam.Use_Lifetime subfield exists
    if ~isfield (S.Settings.Pam, 'Use_Lifetime')
        S.Settings.Pam.Use_Lifetime=0;
        disp('UserValues.Settings.Pam.Use_Lifetime was incomplete');
    end
    P.Settings.Pam.Use_Lifetime = S.Settings.Pam.Use_Lifetime;
    %%% Checks, if Pam.MT_Binning subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Binning')
        S.Settings.Pam.MT_Binning=10;
        disp('UserValues.Settings.Pam.MT_Binning was incomplete');
    end
    P.Settings.Pam.MT_Binning = S.Settings.Pam.MT_Binning;
    %%% Checks, if Pam.MT_Trace_Sectioning subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Trace_Sectioning')
        S.Settings.Pam.MT_Trace_Sectioning=1;
        disp('UserValues.Settings.Pam.MT_Trace_Sectioning was incomplete');
    end
    P.Settings.Pam.MT_Trace_Sectioning = S.Settings.Pam.MT_Trace_Sectioning;
    %%% Checks, if Pam.MT_Time_Section subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Time_Section')
        S.Settings.Pam.MT_Time_Section=2;
        disp('UserValues.Settings.Pam.MT_Time_Section was incomplete');
    end
    P.Settings.Pam.MT_Time_Section = S.Settings.Pam.MT_Time_Section;
    %%% Checks, if Pam.MT_Number_Section subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Number_Section')
        S.Settings.Pam.MT_Number_Section=10;
        disp('UserValues.Settings.Pam.MT_Number_Section was incomplete');
    end
    P.Settings.Pam.MT_Number_Section = S.Settings.Pam.MT_Number_Section;
    %%% Checks, if Pam.Multi_Cor subfield exists
    if ~isfield (S.Settings.Pam, 'Multi_Core')
        S.Settings.Pam.Multi_Core='on';
        disp('UserValues.Settings.Pam.Multi_Cor was incomplete');
    end
    P.Settings.Pam.Multi_Core = S.Settings.Pam.Multi_Core;
    %%% Checks, if Pam.Cor_Divider subfield exists
    if ~isfield (S.Settings.Pam, 'Cor_Divider')
        S.Settings.Pam.Cor_Divider=1;
        disp('UserValues.Settings.Pam.Cor_Divider was incomplete');
    end   
    P.Settings.Pam.Cor_Divider = S.Settings.Pam.Cor_Divider;
    %%% Checks if Pam.Cor_Selection subfield exists
    if ~isfield (S.Settings.Pam, 'Cor_Selection')
        S.Settings.Pam.Cor_Selection=false(numel(S.PIE.Name)+1);
        disp('UserValues.Settings.Pam.Cor_Selection was incomplete');
    end
    P.Settings.Pam.Cor_Selection = S.Settings.Pam.Cor_Selection;   
    %%% Checks if Pam.PlotIRF subfield exists
    if ~isfield (S.Settings.Pam, 'PlotIRF')
        S.Settings.Pam.PlotIRF='off';
        disp('UserValues.Settings.Pam.PlotIRF was incomplete');
    end
    P.Settings.Pam.PlotIRF = S.Settings.Pam.PlotIRF;   
    %%% Checks if Pam.PlotScat subfield exists
    if ~isfield (S.Settings.Pam, 'PlotScat')
        S.Settings.Pam.PlotScat='off';
        disp('UserValues.Settings.Pam.PlotScat was incomplete');
    end
    P.Settings.Pam.PlotScat = S.Settings.Pam.PlotScat;  
    %%% Checksm if Pam.PlotLog subfield exists
    if ~isfield (S.Settings.Pam, 'PlotLog')
        S.Settings.Pam.PlotLog='off';
        disp('UserValues.Settings.Pam.PlotLog was incomplete');
    end
    P.Settings.Pam.PlotLog = S.Settings.Pam.PlotLog;   
    %% FCSFit
    %%% Checks, if FCSFit subfield exists
    if ~isfield (S, 'FCSFit')
        S.FCSFit=[];
        disp('UserValues.FCSFit was incomplete');
    end
    P.FCSFit = [];
    %%% Checks if FCSFit.Fit_Min subfield exists
    if ~isfield (S.FCSFit, 'Fit_Min') || numel(S.FCSFit.Fit_Min)~=1 || ~isnumeric(S.FCSFit.Fit_Min)
        S.FCSFit.Fit_Min = 0;
        disp('UserValues.FCSFit.Fit_Min was incomplete');
    end
    P.FCSFit.Fit_Min = S.FCSFit.Fit_Min;
    %%% Checks if FCSFit.Fit_Min subfield exists
    if ~isfield (S.FCSFit, 'Fit_Max') || numel(S.FCSFit.Fit_Max)~=1 || ~isnumeric(S.FCSFit.Fit_Max)
        S.FCSFit.Fit_Max=1;
        disp('UserValues.FCSFit.Fit_Max was incomplete');
    end
    P.FCSFit.Fit_Max = S.FCSFit.Fit_Max;
    %%% Checks if FCSFit.Plot_Errorbars subfield exists
    if ~isfield (S.FCSFit, 'Plot_Errorbars') || numel(S.FCSFit.Plot_Errorbars)~=1 || (~isnumeric(S.FCSFit.Plot_Errorbars) && ~islogical(S.FCSFit.Plot_Errorbars))
        S.FCSFit.Plot_Errorbars=1;
        disp('UserValues.FCSFit.Plot_Errorbars was incomplete');
    end
    P.FCSFit.Plot_Errorbars = S.FCSFit.Plot_Errorbars;
    %%% Checks if FCSFit.Fit_Tolerance subfield exists
    if ~isfield (S.FCSFit, 'Fit_Tolerance') || numel(S.FCSFit.Fit_Tolerance)~=1 || ~isnumeric(S.FCSFit.Fit_Tolerance)
        S.FCSFit.Fit_Tolerance=1e-6;
        disp('UserValues.FCSFit.Fit_Tolerance was incomplete');
    end
    P.FCSFit.Fit_Tolerance = S.FCSFit.Fit_Tolerance;
    %%% Checks if FCSFit.Use_Weights subfield exists
    if ~isfield (S.FCSFit, 'Use_Weights') || numel(S.FCSFit.Use_Weights)~=1 || (~isnumeric(S.FCSFit.Use_Weights) && ~islogical(S.FCSFit.Use_Weights))
        S.FCSFit.Use_Weights=1;
        disp('UserValues.FCSFit.Use_Weights was incomplete');
    end
    P.FCSFit.Use_Weights = S.FCSFit.Use_Weights;
    %%% Checks if FCSFit.Max_Iterations subfield exists
    if ~isfield (S.FCSFit, 'Max_Iterations') || numel(S.FCSFit.Max_Iterations)~=1 || ~isnumeric(S.FCSFit.Max_Iterations)
        S.FCSFit.Max_Iterations=1000;
        disp('UserValues.FCSFit.Max_Iterations was incomplete');
    end
    P.FCSFit.Max_Iterations = S.FCSFit.Max_Iterations;
    %%% Checks if FCSFit.NormalizationMethod subfield exists
    if ~isfield (S.FCSFit, 'NormalizationMethod') || numel(S.FCSFit.NormalizationMethod)~=1 || ~isnumeric(S.FCSFit.NormalizationMethod)
        S.FCSFit.NormalizationMethod = 1;
        disp('UserValues.FCSFit.NormalizationMethod was incomplete');
    end
    P.FCSFit.NormalizationMethod = S.FCSFit.NormalizationMethod;
    %%% Checks if FCSFit.Conf_Interval subfield exists
    if ~isfield (S.FCSFit, 'Conf_Interval') || numel(S.FCSFit.Conf_Interval)~=1 || (~isnumeric(S.FCSFit.Conf_Interval) && ~islogical(S.FCSFit.Conf_Interval))
        S.FCSFit.Conf_Interval=1;
        disp('UserValues.FCSFit.Conf_Interval was incomplete');
    end
    P.FCSFit.Conf_Interval = S.FCSFit.Conf_Interval;
    %%% Checks, if FCSFit.PlotStyles subfield exists
    if ~isfield (S.FCSFit,'PlotStyles')
        S.FCSFit.PlotStyles = repmat({'1 1 1','none','1','.','8','-','1','none','8',false},10,1); % Consider 10 plots, which should be enough
        S.FCSFit.PlotStyles(:,1) = {'0 0 1'; '1 0 0'; '0 0.5 0'; '1 0 1'; '0 1 1'; '1 1 0'; '0.5 0.5 0.5';'1 0.5 0',;'0.5 1 0';'0.5 0 0'};
        disp('UserValues.FCSFit.PlotStyles was incomplete');
    end    
    P.FCSFit.PlotStyles = S.FCSFit.PlotStyles;
    if ~isfield (S.FCSFit,'PlotStyleAll')
        S.FCSFit.PlotStyleAll = {'1 1 1','none','1','.','8','-','1','none','8',false}; % Consider 10 plots, which should be enough
        disp('UserValues.FCSFit.PlotStyleAll was incomplete');
    end
    P.FCSFit.PlotStyleAll = S.FCSFit.PlotStyleAll;
    %% MIAFit
    %%% Checks, if MIAFit subfield exists
    if ~isfield (S, 'MIAFit')
        S.MIAFit=[];
        disp('UserValues.MIAFit was incomplete');
    end
    P.MIAFit = [];
    %%% Checks if MIAFit.Fit_X subfield exists
    if ~isfield (S.MIAFit, 'Fit_X')
        S.MIAFit.Fit_X=31;
        disp('UserValues.MIAFit.Fit_Min was incomplete');
    end
    P.MIAFit.Fit_X = S.MIAFit.Fit_X;
    %%% Checks if MIAFit.Fit_Y subfield exists
    if ~isfield (S.MIAFit, 'Fit_Y')
        S.MIAFit.Fit_Y=31;
        disp('UserValues.MIAFit.Fit_Max was incomplete');
    end
    P.MIAFit.Fit_Y = S.MIAFit.Fit_Y;
    %%% Checks if MIAFit.Plot_Errorbars subfield exists
    if ~isfield (S.MIAFit, 'Plot_Errorbars')
        S.MIAFit.Plot_Errorbars=1;
        disp('UserValues.MIAFit.Plot_Errorbars was incomplete');
    end
    P.MIAFit.Plot_Errorbars = S.MIAFit.Plot_Errorbars;
    %%% Checks if MIAFit.Fit_Tolerance subfield exists
    if ~isfield (S.MIAFit, 'Fit_Tolerance')
        S.MIAFit.Fit_Tolerance=1e-6;
        disp('UserValues.MIAFit.Fit_Tolerance was incomplete');
    end
    P.MIAFit.Fit_Tolerance = S.MIAFit.Fit_Tolerance;
    %%% Checks if MIAFit.Use_Weights subfield exists
    if ~isfield (S.MIAFit, 'Use_Weights')
        S.MIAFit.Use_Weights=1;
        disp('UserValues.MIAFit.Use_Weights was incomplete');
    end
    P.MIAFit.Use_Weights = S.MIAFit.Use_Weights;
    %%% Checks if FCSFit.Max_Iterations subfield exists
    if ~isfield (S.MIAFit, 'Max_Iterations')
        S.MIAFit.Max_Iterations=1000;
        disp('UserValues.MIAFit.Max_Iterations was incomplete');
    end
    P.MIAFit.Max_Iterations = S.MIAFit.Max_Iterations;
    %%% Checks if MIAFit.NormalizationMethod subfield exists
    if ~isfield (S.MIAFit, 'NormalizationMethod')
        S.MIAFit.NormalizationMethod=1;
        disp('UserValues.MIAFit.NormalizationMethod was incomplete');
    end
    P.MIAFit.NormalizationMethod = S.MIAFit.NormalizationMethod;
    %%% Checks if MIAFit.Omit subfield exists
    if ~isfield (S.MIAFit, 'Omit')
        S.MIAFit.Omit=1;
        disp('UserValues.MIAFit.Omit was incomplete');
    end
    P.MIAFit.Omit = S.MIAFit.Omit;
    %%% Checks, if MIAFit.PlotStyles subfield exists
    if ~isfield (S.MIAFit,'PlotStyles')
        S.MIAFit.PlotStyles = repmat({'1 1 1','none','1','.','8','-','1','none','8',false},10,1); % Consider 10 plots, which should be enough
        S.MIAFit.PlotStyles(:,1) = {'0 0 1'; '1 0 0'; '0 0.5 0'; '1 0 1'; '0 1 1'; '1 1 0'; '0.5 0.5 0.5';'1 0.5 0',;'0.5 1 0';'0.5 0 0'};
        disp('UserValues.MIAFit.PlotStyles was incomplete');
    end    
    P.MIAFit.PlotStyles = S.MIAFit.PlotStyles;
    if ~isfield (S.MIAFit,'PlotStyleAll')
        S.MIAFit.PlotStyleAll = {'1 1 1','none','1','.','8','-','1','none','8',false}; % Consider 10 plots, which should be enough
        disp('UserValues.MIAFit.PlotStyleAll was incomplete');
    end
    P.MIAFit.PlotStyleAll = S.MIAFit.PlotStyleAll;    
    %% Phasor
    %%% Checks, if Phasor subfield exists
    if ~isfield (S,'Phasor')
        S.Phasor=[];
        disp('UserValues.Phasor was incomplete');
    end
    P.Phasor = [];
    %%% Checks, if Phasor.Reference subfield exists
    if ~isfield (S.Phasor,'Reference')
        S.Phasor.Reference=zeros(numel(S.Detector.Det),4096);
        disp('UserValues.Phasor.Reference was incomplete');
    elseif size(S.Phasor.Reference,1)<numel(P.Detector.Det)
        S.Phasor.Reference(numel(P.Detector.Det),end) = 0;
    end
    P.Phasor.Reference = S.Phasor.Reference;
    %% Burst Search
    %%% Checks, if BurstSearch subfield exists
    if ~isfield (S,'BurstSearch')
        S.BurstSearch=[];
        disp('UserValues.BurstSearch was incomplete');    
    end
    P.BurstSearch = [];
    %%% Checks, if BurstSearch.Method subfield exists
    if ~isfield (S.BurstSearch,'Method')
        S.BurstSearch.Method=1;
        disp('UserValues.BurstSearch.Method was incomplete');    
    end
    P.BurstSearch.Method = S.BurstSearch.Method;
    %%% Checks, if BurstSearch.PIEChannelSelection exists
    %%% (This field contains the PIEChannel Selection (as a String) for every
    %%% Burst Search Method)
    if ~isfield (S.BurstSearch,'PIEChannelSelection')
        dummy = S.PIE.Name{1};
        S.BurstSearch.PIEChannelSelection={{dummy,dummy;dummy,dummy;dummy,dummy},{dummy,dummy;dummy,dummy;dummy,dummy},{dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy},{dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy},{dummy;dummy;dummy}};
        disp('UserValues.BurstSearch.PIEChannelSelection was incomplete');    
    end
    P.BurstSearch.PIEChannelSelection = S.BurstSearch.PIEChannelSelection;
    %%% Checks, if BurstSearch.SearchParameters exists
    %%% (This field contains the Search Parameters for every Burst Search
    %%% Method)
    if ~isfield (S.BurstSearch,'SearchParameters')
        S.BurstSearch.SearchParameters={[100,500,5,5,5],[100,500,5,5,5],[100,500,5,5,5],[100,500,5,5,5],[100,500,5,5,5]};
        disp('UserValues.BurstSearch.SearchParameters was incomplete');    
    end
    P.BurstSearch.SearchParameters = S.BurstSearch.SearchParameters;
    %%% Checks, if BurstSearch.SaveTotalPhotonStream exists
    if ~isfield (S.BurstSearch,'SaveTotalPhotonStream')
        S.BurstSearch.SaveTotalPhotonStream=0;
        disp('UserValues.BurstSearch.SaveTotalPhotonStream was incomplete');    
    end
    P.BurstSearch.SaveTotalPhotonStream = S.BurstSearch.SaveTotalPhotonStream;
    %%% Checks, if BurstSearch.TauFit subfield exists
    if ~isfield (S.BurstSearch,'TauFit')
        S.BurstSearch.TauFit=[];
        disp('UserValues.BurstSearch.TauFit was incomplete');    
    end
    P.BurstSearch.TauFit = S.BurstSearch.TauFit;
    %%% Checks, if BurstSearch.TauFit.Length subfield exists
    if ~isfield (S.BurstSearch.TauFit,'Length')
        S.BurstSearch.TauFit.Length=cell(1,3);
        disp('UserValues.BurstSearch.TauFit.Length was incomplete');    
    end
    P.BurstSearch.TauFit.Length = S.BurstSearch.TauFit.Length;
    %%% Checks, if BurstSearch.TauFit.StartPar subfield exists
    if ~isfield (S.BurstSearch.TauFit,'StartPar')
        S.BurstSearch.TauFit.StartPar={0,0,0};
        disp('UserValues.BurstSearch.TauFit.StartPar was incomplete');    
    end
    P.BurstSearch.TauFit.StartPar = S.BurstSearch.TauFit.StartPar;
    %%% Checks, if BurstSearch.TauFit.ShiftPer subfield exists
    if ~isfield (S.BurstSearch.TauFit,'ShiftPer')
        S.BurstSearch.TauFit.ShiftPer={0,0,0};
        disp('UserValues.BurstSearch.TauFit.ShiftPer was incomplete');    
    end
    P.BurstSearch.TauFit.ShiftPer = S.BurstSearch.TauFit.ShiftPer;
    %%% Checks, if BurstSearch.TauFit.ShiftPer subfield exists
    if ~isfield (S.BurstSearch.TauFit,'ShiftPer')
        S.BurstSearch.TauFit.ShiftPer={0,0,0};
        disp('UserValues.BurstSearch.TauFit.ShiftPer was incomplete');    
    end
    P.BurstSearch.TauFit.ShiftPer = S.BurstSearch.TauFit.ShiftPer;
    %%% Checks, if BurstSearch.TauFit.IRFShift subfield exists
    if ~isfield (S.BurstSearch.TauFit,'IRFShift')
        S.BurstSearch.TauFit.IRFShift={0,0,0};
        disp('UserValues.BurstSearch.TauFit.IRFShift was incomplete');    
    end
    P.BurstSearch.TauFit.IRFShift = S.BurstSearch.TauFit.IRFShift;
    %%% Checks, if BurstSearch.TauFit.IRFLength subfield exists
    if ~isfield (S.BurstSearch.TauFit,'IRFLength')
        S.BurstSearch.TauFit.IRFLength={200,200,200};
        disp('UserValues.BurstSearch.TauFit.IRFLength was incomplete');    
    end
    P.BurstSearch.TauFit.IRFLength = S.BurstSearch.TauFit.IRFLength;
    %% TauFit
    %%% Checks, if TauFit subfield exists
    if ~isfield (S,'TauFit')
        S.TauFit=[];
        disp('UserValues.TauFit was incomplete');    
    end
    P.TauFit = [];
    %%% Checks, if TauFit.PIEChannelSelection exists
    %%% (This field contains the PIE Channel Selection as String/Name for
    %%% Parallel and Perpendicular Channel)
    if ~isfield (S.TauFit,'PIEChannelSelection')
        dummy = S.PIE.Name{1};
        S.TauFit.PIEChannelSelection={dummy,dummy};
            disp('UserValues.TauFit.PIEChannelSelection was incomplete');    
    end
    P.TauFit.PIEChannelSelection = S.TauFit.PIEChannelSelection;
    %%% Checks, if TauFit.blue exists
    %%% (Gfactor for the blue channels)
    if ~isfield (S.TauFit,'Gblue')
        S.TauFit.Gblue=1;
        disp('UserValues.TauFit.Gblue was incomplete');    
    end
    P.TauFit.Gblue = S.TauFit.Gblue;
    %%% Checks, if TauFit.Ggreen exists
    %%% (Gfactor for the green channels)
    if ~isfield (S.TauFit,'Ggreen')
        S.TauFit.Ggreen=1;
            disp('UserValues.TauFit.Ggreen was incomplete');    
    end
    P.TauFit.Ggreen = S.TauFit.Ggreen;
    %%% Checks, if TauFit.Gred exists
    %%% (Gfactor for the red channels)
    if ~isfield (S.TauFit,'Gred')
        S.TauFit.Gred=1;
        disp('UserValues.TauFit.Gred was incomplete');    
    end
    P.TauFit.Gred = S.TauFit.Gred;
    %%% Checks, if TauFit.l1 exists
    %%% (First of the correction factors accounting for the polarization mixing caused by the high N.A. objective lense)
    if ~isfield (S.TauFit,'l1')
        S.TauFit.l1=0;
        disp('UserValues.TauFit.l1 was incomplete');    
    end
    P.TauFit.l1 = S.TauFit.l1;
    %%% Checks, if TauFit.l2 exists
    %%% (Second of the correction factors accounting for the polarization mixing caused by the high N.A. objective lense)
    if ~isfield (S.TauFit,'l2')
        S.TauFit.l2=0;
        disp('UserValues.TauFit.l2 was incomplete');    
    end
    P.TauFit.l2 = S.TauFit.l2;
    %%% Checks, if TauFit.ConvolutionType exists
    %%% (Options: lijnear and circular == periodic convolution)
    if ~isfield (S.TauFit,'ConvolutionType')
        S.TauFit.ConvolutionType='linear';
        disp('UserValues.TauFit.ConvolutionType was incomplete');    
    end
    P.TauFit.ConvolutionType = S.TauFit.ConvolutionType;
    %% BurstBrowser
    %%% Checks, if BurstBrowser subfield exists
    if ~isfield (S,'BurstBrowser')
        S.BurstBrowser=[];
        disp('UserValues.BurstBrowser was incomplete');    
    end
    P.BurstBrowser = S.BurstBrowser;
    %%% Checks, if BurstBrowser.Corrections subfield exists
    %%% Here the correction factors are stored
    if ~isfield (S.BurstBrowser,'Corrections')
        S.BurstBrowser.Corrections=[];
        disp('UserValues.BurstBrowser.Corrections was incomplete');    
    end
    P.BurstBrowser.Corrections = S.BurstBrowser.Corrections;
    %%% Checks, if BurstBrowser.Corrections.CrossTalk_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'CrossTalk_GR')
        S.BurstBrowser.Corrections.CrossTalk_GR=0;
        disp('UserValues.BurstBrowser.Corrections.CrossTalk_GR was incomplete');    
    end
    P.BurstBrowser.Corrections.CrossTalk_GR = S.BurstBrowser.Corrections.CrossTalk_GR;
    %%% Checks, if BurstBrowser.Corrections.CrossTalk_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'CrossTalk_BG')
        S.BurstBrowser.Corrections.CrossTalk_BG=0;
        disp('UserValues.BurstBrowser.Corrections.CrossTalk_BG was incomplete');    
    end
    P.BurstBrowser.Corrections.CrossTalk_BG = S.BurstBrowser.Corrections.CrossTalk_BG;
    %%% Checks, if BurstBrowser.Corrections.CrossTalk_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'CrossTalk_BR')
        S.BurstBrowser.Corrections.CrossTalk_BR=0;
        disp('UserValues.BurstBrowser.Corrections.CrossTalk_BR was incomplete');    
    end
    P.BurstBrowser.Corrections.CrossTalk_BR = S.BurstBrowser.Corrections.CrossTalk_BR;
    %%% Checks, if BurstBrowser.Corrections.DirectExcitation_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'DirectExcitation_GR')
        S.BurstBrowser.Corrections.DirectExcitation_GR=0;
        disp('UserValues.BurstBrowser.Corrections.DirectExcitation_GR was incomplete');    
    end
    P.BurstBrowser.Corrections.DirectExcitation_GR = S.BurstBrowser.Corrections.DirectExcitation_GR;
    %%% Checks, if BurstBrowser.Corrections.DirectExcitation_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'DirectExcitation_BG')
        S.BurstBrowser.Corrections.DirectExcitation_BG=0;
        disp('UserValues.BurstBrowser.Corrections.DirectExcitation_BG was incomplete');    
    end
    P.BurstBrowser.Corrections.DirectExcitation_BG = S.BurstBrowser.Corrections.DirectExcitation_BG;
    %%% Checks, if BurstBrowser.Corrections.DirectExcitation_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'DirectExcitation_BR')
        S.BurstBrowser.Corrections.DirectExcitation_BR=0;
        disp('UserValues.BurstBrowser.Corrections.DirectExcitation_BR was incomplete');    
    end
    P.BurstBrowser.Corrections.DirectExcitation_BR = S.BurstBrowser.Corrections.DirectExcitation_BR;
    %%% Checks, if BurstBrowser.Corrections.Gamma_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Gamma_GR')
        S.BurstBrowser.Corrections.Gamma_GR=1;
        disp('UserValues.BurstBrowser.Corrections.Gamma_GR was incomplete');    
    end
    P.BurstBrowser.Corrections.Gamma_GR = S.BurstBrowser.Corrections.Gamma_GR;
    %%% Checks, if BurstBrowser.Corrections.Gamma_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Gamma_BG')
        S.BurstBrowser.Corrections.Gamma_BG=1;
        disp('UserValues.BurstBrowser.Corrections.Gamma_BG was incomplete');    
    end
    P.BurstBrowser.Corrections.Gamma_BG = S.BurstBrowser.Corrections.Gamma_BG;
    %%% Checks, if BurstBrowser.Corrections.Gamma_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Gamma_BR')
        S.BurstBrowser.Corrections.Gamma_BR=1;
        disp('UserValues.BurstBrowser.Corrections.Gamma_BR was incomplete');    
    end
    P.BurstBrowser.Corrections.Gamma_BR = S.BurstBrowser.Corrections.Gamma_BR;
    %%% Checks, if BurstBrowser.Corrections.UseBeta subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'UseBeta')
        S.BurstBrowser.Corrections.UseBeta=0;
        disp('UserValues.BurstBrowser.Corrections.UseBeta was incomplete');    
    end
    P.BurstBrowser.Corrections.UseBeta = S.BurstBrowser.Corrections.UseBeta;
    %%% Checks, if BurstBrowser.Corrections.Beta_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Beta_GR')
        S.BurstBrowser.Corrections.Beta_GR=1;
        disp('UserValues.BurstBrowser.Corrections.Beta_GR was incomplete');    
    end
    P.BurstBrowser.Corrections.Beta_GR = S.BurstBrowser.Corrections.Beta_GR;
    %%% Checks, if BurstBrowser.Corrections.Beta_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Beta_BG')
        S.BurstBrowser.Corrections.Beta_BG=1;
        disp('UserValues.BurstBrowser.Corrections.Beta_BG was incomplete');    
    end
    P.BurstBrowser.Corrections.Beta_BG = S.BurstBrowser.Corrections.Beta_BG;
    %%% Checks, if BurstBrowser.Corrections.Beta_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Beta_BR')
        S.BurstBrowser.Corrections.Beta_BR=1;
        disp('UserValues.BurstBrowser.Corrections.Beta_BR was incomplete');    
    end
    P.BurstBrowser.Corrections.Beta_BR = S.BurstBrowser.Corrections.Beta_BR;
    %%% Checks, if BurstBrowser.Corrections.Background_BBpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BBpar')
        S.BurstBrowser.Corrections.Background_BBpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BBpar was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_BBpar = S.BurstBrowser.Corrections.Background_BBpar;
    %%% Checks, if BurstBrowser.Corrections.Background_BBperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BBperp')
        S.BurstBrowser.Corrections.Background_BBperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BBperp was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_BBperp = S.BurstBrowser.Corrections.Background_BBperp;
    %%% Checks, if BurstBrowser.Corrections.Background_BGpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BGpar')
        S.BurstBrowser.Corrections.Background_BGpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BGpar was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_BGpar = S.BurstBrowser.Corrections.Background_BGpar;
    %%% Checks, if BurstBrowser.Corrections.Background_BGperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BGperp')
        S.BurstBrowser.Corrections.Background_BGperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BGperp was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_BGperp = S.BurstBrowser.Corrections.Background_BGperp;
    %%% Checks, if BurstBrowser.Corrections.Background_BRpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BRpar')
        S.BurstBrowser.Corrections.Background_BRpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BRpar was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_BRpar = S.BurstBrowser.Corrections.Background_BRpar;
    %%% Checks, if BurstBrowser.Corrections.Background_BRperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BRperp')
        S.BurstBrowser.Corrections.Background_BRperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BRperp was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_BRperp = S.BurstBrowser.Corrections.Background_BRperp;
    %%% Checks, if BurstBrowser.Corrections.Background_GGpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GGpar')
        S.BurstBrowser.Corrections.Background_GGpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GGpar was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_GGpar = S.BurstBrowser.Corrections.Background_GGpar;
    %%% Checks, if BurstBrowser.Corrections.Background_GGperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GGperp')
        S.BurstBrowser.Corrections.Background_GGperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GGperp was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_GGperp = S.BurstBrowser.Corrections.Background_GGperp;
    %%% Checks, if BurstBrowser.Corrections.Background_GRpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GRpar')
        S.BurstBrowser.Corrections.Background_GRpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GRpar was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_GRpar = S.BurstBrowser.Corrections.Background_GRpar;
    %%% Checks, if BurstBrowser.Corrections.Background_GRperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GRperp')
        S.BurstBrowser.Corrections.Background_GRperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GRperp was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_GRperp = S.BurstBrowser.Corrections.Background_GRperp;
    %%% Checks, if BurstBrowser.Corrections.Background_RRpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_RRpar')
        S.BurstBrowser.Corrections.Background_RRpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_RRpar was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_RRpar = S.BurstBrowser.Corrections.Background_RRpar;
    %%% Checks, if BurstBrowser.Corrections.Background_RRperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_RRperp')
        S.BurstBrowser.Corrections.Background_RRperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_RRperp was incomplete');    
    end
    P.BurstBrowser.Corrections.Background_RRperp = S.BurstBrowser.Corrections.Background_RRperp;
    %%% Checks, if BurstBrowser.Corrections.GfactorBlue subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'GfactorBlue')
        S.BurstBrowser.Corrections.GfactorBlue=1;
        disp('UserValues.BurstBrowser.Corrections.GfactorBlue was incomplete');    
    end
    P.BurstBrowser.Corrections.GfactorBlue = S.BurstBrowser.Corrections.GfactorBlue;
    %%% Checks, if BurstBrowser.Corrections.GfactorGreen subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'GfactorGreen')
        S.BurstBrowser.Corrections.GfactorGreen=1;
        disp('UserValues.BurstBrowser.Corrections.GfactorGreen was incomplete');    
    end
    P.BurstBrowser.Corrections.GfactorGreen = S.BurstBrowser.Corrections.GfactorGreen;
    %%% Checks, if BurstBrowser.Corrections.GfactorRed subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'GfactorRed')
        S.BurstBrowser.Corrections.GfactorRed=1;
        disp('UserValues.BurstBrowser.Corrections.GfactorRed was incomplete');    
    end
    P.BurstBrowser.Corrections.GfactorRed = S.BurstBrowser.Corrections.GfactorRed;
    %%% Checks, if BurstBrowser.Corrections.l1 subfield exists
    %%% This is the first corrections factor accounting for polarization
    %%% mixing caused by the high N.A. objective lense
    if ~isfield (S.BurstBrowser.Corrections,'l1')
        S.BurstBrowser.Corrections.l1=0;
        disp('UserValues.BurstBrowser.Corrections.l1 was incomplete');    
    end
    P.BurstBrowser.Corrections.l1 = S.BurstBrowser.Corrections.l1;
    %%% Checks, if BurstBrowser.Corrections.l2 subfield exists
    %%% This is the second corrections factor accounting for polarization
    %%% mixing caused by the high N.A. objective lense
    if ~isfield (S.BurstBrowser.Corrections,'l2')
        S.BurstBrowser.Corrections.l2=0;
        disp('UserValues.BurstBrowser.Corrections.l2 was incomplete');    
    end
    P.BurstBrowser.Corrections.l2 = S.BurstBrowser.Corrections.l2;
    %%% Checks, if BurstBrowser.Corrections.DonorLifetime subfield exists
    %%% This value stores the set Donor Lifetime
    if ~isfield (S.BurstBrowser.Corrections,'DonorLifetime')
        S.BurstBrowser.Corrections.DonorLifetime=3.8;
        disp('UserValues.BurstBrowser.Corrections.DonorLifetime was incomplete');    
    end
    P.BurstBrowser.Corrections.DonorLifetime = S.BurstBrowser.Corrections.DonorLifetime;
    %%% Checks, if BurstBrowser.Corrections.DonorLifetimeBlue subfield exists
    %%% This value stores the set Donor Lifetime
    if ~isfield (S.BurstBrowser.Corrections,'DonorLifetimeBlue')
        S.BurstBrowser.Corrections.DonorLifetimeBlue=3.8;
        disp('UserValues.BurstBrowser.Corrections.DonorLifetimeBlue was incomplete');    
    end
    P.BurstBrowser.Corrections.DonorLifetimeBlue = S.BurstBrowser.Corrections.DonorLifetimeBlue;
    %%% Checks, if BurstBrowser.Corrections.AcceptorLifetime subfield exists
    %%% This value stores the set Acceptor Lifetime
    if ~isfield (S.BurstBrowser.Corrections,'AcceptorLifetime')
        S.BurstBrowser.Corrections.AcceptorLifetime=3.5;
        disp('UserValues.BurstBrowser.Corrections.AcceptorLifetime was incomplete');    
    end
    P.BurstBrowser.Corrections.AcceptorLifetime = S.BurstBrowser.Corrections.AcceptorLifetime;
    %%% Checks, if BurstBrowser.Corrections.FoersterRadius subfield exists
    %%% This value stores the set Foerster Radius
    if ~isfield (S.BurstBrowser.Corrections,'FoersterRadius')
        S.BurstBrowser.Corrections.FoersterRadius=59;
        disp('UserValues.BurstBrowser.Corrections.FoersterRadius was incomplete');    
    end
    P.BurstBrowser.Corrections.FoersterRadius = S.BurstBrowser.Corrections.FoersterRadius;
    %%% Checks, if BurstBrowser.Corrections.LinkerLength subfield exists
    %%% This value stores the set Linker Length 
    if ~isfield (S.BurstBrowser.Corrections,'LinkerLength')
        S.BurstBrowser.Corrections.LinkerLength=5;
        disp('UserValues.BurstBrowser.Corrections.LinkerLength was incomplete');    
    end
    P.BurstBrowser.Corrections.LinkerLength = S.BurstBrowser.Corrections.LinkerLength;
     %%% Checks, if BurstBrowser.Corrections.DonorLifetimeBlue subfield exists
    %%% This value stores the set Donor Lifetime of the Blue dye
    if ~isfield (S.BurstBrowser.Corrections,'DonorLifetimeBlue')
        S.BurstBrowser.Corrections.DonorLifetimeBlue=4.1;
        disp('UserValues.BurstBrowser.Corrections.DonorLifetimeBlue was incomplete');    
    end
    P.BurstBrowser.Corrections.DonorLifetimeBlue = S.BurstBrowser.Corrections.DonorLifetimeBlue;
    %%% Checks, if BurstBrowser.Corrections.FoersterRadiusBG subfield exists
    %%% This value stores the set Foerster Radius BG
    if ~isfield (S.BurstBrowser.Corrections,'FoersterRadiusBG')
        S.BurstBrowser.Corrections.FoersterRadiusBG=59;
        disp('UserValues.BurstBrowser.Corrections.FoersterRadiusBG was incomplete');    
    end
    P.BurstBrowser.Corrections.FoersterRadiusBG = S.BurstBrowser.Corrections.FoersterRadiusBG;
    %%% Checks, if BurstBrowser.Corrections.LinkerLengthBG subfield exists
    %%% This value stores the set Linker Length BG
    if ~isfield (S.BurstBrowser.Corrections,'LinkerLengthBG')
        S.BurstBrowser.Corrections.LinkerLengthBG=5;
        disp('UserValues.BurstBrowser.Corrections.LinkerLengthBG was incomplete');    
    end
    P.BurstBrowser.Corrections.LinkerLengthBG = S.BurstBrowser.Corrections.LinkerLengthBG;
    %%% Checks, if BurstBrowser.Corrections.FoersterRadiusBR subfield exists
    %%% This value stores the set Foerster Radius BR
    if ~isfield (S.BurstBrowser.Corrections,'FoersterRadiusBR')
        S.BurstBrowser.Corrections.FoersterRadiusBR=59;
        disp('UserValues.BurstBrowser.Corrections.FoersterRadiusBR was incomplete');    
    end
    P.BurstBrowser.Corrections.FoersterRadiusBR = S.BurstBrowser.Corrections.FoersterRadiusBR;
    %%% Checks, if BurstBrowser.Corrections.LinkerLength subfield exists
    %%% This value stores the set Linker Length BR
    if ~isfield (S.BurstBrowser.Corrections,'LinkerLengthBR')
        S.BurstBrowser.Corrections.LinkerLengthBR=5;
        disp('UserValues.BurstBrowser.Corrections.LinkerLengthBR was incomplete');    
    end
    P.BurstBrowser.Corrections.LinkerLengthBR = S.BurstBrowser.Corrections.LinkerLengthBR;
    %%% Checks, if BurstBrowser.Display subfield exists
    %%% Here the display options are stored
    if ~isfield (S.BurstBrowser,'Display')
        S.BurstBrowser.Display=[];
        disp('UserValues.BurstBrowser.Display was incomplete');    
    end
        %%% Check, if BurstBrowser.Corrections.r0_green subfield exists
    if ~isfield(S.BurstBrowser.Corrections, 'r0_green')
        S.BurstBrowser.Corrections.r0_green=0.4;
        disp('UserValues.BurstBrowser.Corrections.r0_green was incomplete');    
    end 
    P.BurstBrowser.Corrections.r0_green = S.BurstBrowser.Corrections.r0_green;
    %%% Check, if BurstBrowser.Corrections.r0_red subfield exists
    if ~isfield(S.BurstBrowser.Corrections, 'r0_red')
        S.BurstBrowser.Corrections.r0_red=0.4;
        disp('UserValues.BurstBrowser.Corrections.r0_red was incomplete');    
    end 
    P.BurstBrowser.Corrections.r0_red = S.BurstBrowser.Corrections.r0_red;
    %%% Check, if BurstBrowser.Corrections.r0_green subfield exists
    if ~isfield(S.BurstBrowser.Corrections, 'r0_blue')
        S.BurstBrowser.Corrections.r0_blue=0.4;
        disp('UserValues.BurstBrowser.Corrections.r0_blue was incomplete');    
    end 
    P.BurstBrowser.Corrections.r0_blue = S.BurstBrowser.Corrections.r0_blue;
    %%% Checks, if BurstBrowser.Display subfield exists
    if ~isfield (S.BurstBrowser,'Display')
        S.BurstBrowser.Display=[];
        disp('UserValues.BurstBrowser.Display was incomplete');    
    end
    P.BurstBrowser.Display = [];
    %%% Checks, if BurstBrowser.Display.NumberOfBinsX subfield exists
    if ~isfield (S.BurstBrowser.Display,'NumberOfBinsX')
        S.BurstBrowser.Display.NumberOfBinsX=50;
        disp('UserValues.BurstBrowser.Display.NumberOfBinsX was incomplete');    
    end
    P.BurstBrowser.Display.NumberOfBinsX = S.BurstBrowser.Display.NumberOfBinsX;
    %%% Checks, if BurstBrowser.Display.NumberOfBinsX subfield exists
    if ~isfield (S.BurstBrowser.Display,'NumberOfBinsY')
        S.BurstBrowser.Display.NumberOfBinsY=50;
        disp('UserValues.BurstBrowser.Display.NumberOfBinsY was incomplete');    
    end
    P.BurstBrowser.Display.NumberOfBinsY = S.BurstBrowser.Display.NumberOfBinsY;
    %%% Checks, if BurstBrowser.Display.PlotType subfield exists
    if ~isfield (S.BurstBrowser.Display,'PlotType')
        S.BurstBrowser.Display.PlotType='Image';
        disp('UserValues.BurstBrowser.Display.PlotType was incomplete');    
    end
    P.BurstBrowser.Display.PlotType = S.BurstBrowser.Display.PlotType;
    %%% Checks, if BurstBrowser.Display.ColorMap subfield exists
    if ~isfield (S.BurstBrowser.Display,'ColorMap')
        S.BurstBrowser.Display.ColorMap='hot';
        disp('UserValues.BurstBrowser.Display.ColorMap was incomplete');    
    end
    P.BurstBrowser.Display.ColorMap = S.BurstBrowser.Display.ColorMap;
    %%% Checks, if BurstBrowser.Display.NumberOfContourLevels subfield exists
    if ~isfield (S.BurstBrowser.Display,'NumberOfContourLevels')
        S.BurstBrowser.Display.NumberOfContourLevels=10;
        disp('UserValues.BurstBrowser.Display.NumberOfContourLevels was incomplete');    
    end
    P.BurstBrowser.Display.NumberOfContourLevels = S.BurstBrowser.Display.NumberOfContourLevels;
    %%% Checks, if BurstBrowser.Display.ContourOffset subfield exists
    if ~isfield (S.BurstBrowser.Display,'ContourOffset')
        S.BurstBrowser.Display.ContourOffset=5;
        disp('UserValues.BurstBrowser.Display.ContourOffset was incomplete');    
    end
    P.BurstBrowser.Display.ContourOffset = S.BurstBrowser.Display.ContourOffset;
    %%% Checks, if BurstBrowser.Display.PlotContourLines subfield exists
    if ~isfield (S.BurstBrowser.Display,'PlotContourLines')
        S.BurstBrowser.Display.PlotContourLines=1;
        disp('UserValues.BurstBrowser.Display.PlotContourLines was incomplete');    
    end
    P.BurstBrowser.Display.PlotContourLines = S.BurstBrowser.Display.PlotContourLines;
    %%% Checks, if BurstBrowser.Display.KDE subfield exists
    if ~isfield (S.BurstBrowser.Display,'KDE')
        S.BurstBrowser.Display.KDE=0;
        disp('UserValues.BurstBrowser.Display.KDE was incomplete');    
    end
    P.BurstBrowser.Display.KDE = S.BurstBrowser.Display.KDE;
    %%% Checks, if BurstBrowser.Display.ColorMapInvert subfield exists
    if ~isfield (S.BurstBrowser.Display,'ColorMapInvert')
        S.BurstBrowser.Display.ColorMapInvert=0;
        disp('UserValues.BurstBrowser.Display.ColorMapInvert was incomplete');    
    end
    P.BurstBrowser.Display.ColorMapInvert = S.BurstBrowser.Display.ColorMapInvert;
    %%% Checks, if BurstBrowser.Display.ColorLine1 subfield exists
    if ~isfield (S.BurstBrowser.Display,'ColorLine1')
        S.BurstBrowser.Display.ColorLine1=[0 0 1];
        disp('UserValues.BurstBrowser.Display.ColorLine1 was incomplete');    
    end
    P.BurstBrowser.Display.ColorLine1 = S.BurstBrowser.Display.ColorLine1;
    %%% Checks, if BurstBrowser.Display.ColorLine2 subfield exists
    if ~isfield (S.BurstBrowser.Display,'ColorLine2')
        S.BurstBrowser.Display.ColorLine2=[1 0 0];
        disp('UserValues.BurstBrowser.Display.ColorLine2 was incomplete');    
    end
    P.BurstBrowser.Display.ColorLine2 = S.BurstBrowser.Display.ColorLine2;
    %%% Checks, if BurstBrowser.Display.ColorLine3 subfield exists
    if ~isfield (S.BurstBrowser.Display,'ColorLine3')
        S.BurstBrowser.Display.ColorLine3=[0 1 0];
        disp('UserValues.BurstBrowser.Display.ColorLine3 was incomplete');    
    end
    P.BurstBrowser.Display.ColorLine3 = S.BurstBrowser.Display.ColorLine3;
    
    %%% Checks, if BurstBrowser.Settings subfield exists
    if ~isfield (S.BurstBrowser,'Settings')
        S.BurstBrowser.Settings=[];
        disp('UserValues.BurstBrowser.Settings was incomplete');    
    end
    
    P.BurstBrowser.Settings = [];
    %%% Check, if BurstBrowser.Settings.PrintPath subfield exists
    if ~isfield(S.BurstBrowser.Settings, 'PrintPath')
        S.BurstBrowser.Settings.PrintPath=pwd;
        disp('UserValues.BurstBrowser.Settings.PrintPath was incomplete');    
    end 
    P.BurstBrowser.Settings.PrintPath = S.BurstBrowser.Settings.PrintPath;
    %%% Check, if BurstBrowser.Settings.SaveOnClose subfield exists
    if ~isfield(S.BurstBrowser.Settings, 'SaveOnClose')
        S.BurstBrowser.Settings.SaveOnClose=0;
        disp('UserValues.BurstBrowser.Settings.SaveOnClose was incomplete');    
    end 
    P.BurstBrowser.Settings.SaveOnClose = S.BurstBrowser.Settings.SaveOnClose;
    %%% Check, if BurstBrowser.Settings.fFCS_UseIRF subfield exists
    if ~isfield(S.BurstBrowser.Settings, 'fFCS_UseIRF')
        S.BurstBrowser.Settings.fFCS_UseIRF=1;
        disp('UserValues.BurstBrowser.Settings.fFCS_UseIRF was incomplete');    
    end 
    P.BurstBrowser.Settings.fFCS_UseIRF = S.BurstBrowser.Settings.fFCS_UseIRF;
    %%% Check, if BurstBrowser.Settings.Downsample_fFCS subfield exists
    if ~isfield(S.BurstBrowser.Settings, 'Downsample_fFCS')
        S.BurstBrowser.Settings.Downsample_fFCS=0;
        disp('UserValues.BurstBrowser.Settings.Downsample_fFCS was incomplete');    
    end 
    P.BurstBrowser.Settings.Downsample_fFCS = S.BurstBrowser.Settings.Downsample_fFCS;
    %%% Check, if BurstBrowser.Settings.Downsample_fFCS_Time subfield exists
    %%% Stores the desired MI Bin time in ps
    if ~isfield(S.BurstBrowser.Settings, 'Downsample_fFCS_Time')
        S.BurstBrowser.Settings.Downsample_fFCS_Time=100;
        disp('UserValues.BurstBrowser.Settings.Downsample_fFCS_Time was incomplete');    
    end 
    P.BurstBrowser.Settings.Downsample_fFCS_Time = S.BurstBrowser.Settings.Downsample_fFCS_Time;
    %%% Check, if BurstBrowser.Settings.fFCS_UseTimewindow subfield exists
    if ~isfield(S.BurstBrowser.Settings, 'fFCS_UseTimewindow')
        S.BurstBrowser.Settings.fFCS_UseTimewindow=0;
        disp('UserValues.BurstBrowser.Settings.fFCS_UseTimewindow was incomplete');    
    end 
    P.BurstBrowser.Settings.fFCS_UseTimewindow = S.BurstBrowser.Settings.fFCS_UseTimewindow;
    %%% Check, if BurstBrowser.Settings.Corr_TimeWindowSize subfield exists
    if ~isfield(S.BurstBrowser.Settings, 'Corr_TimeWindowSize')
        S.BurstBrowser.Settings.Corr_TimeWindowSize=5;
        disp('UserValues.BurstBrowser.Settings.Corr_TimeWindowSize was incomplete');    
    end 
    P.BurstBrowser.Settings.Corr_TimeWindowSize = S.BurstBrowser.Settings.Corr_TimeWindowSize;
    %% tcPDA
    if ~isfield(S, 'tcPDA')
        disp('WARNING: UserValues structure incomplete, field "tcPDA" missing');
        S.tcPDA = [];
    end
    P.tcPDA = S.tcPDA;
    
    if ~isfield(S.tcPDA, 'PathName')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.PathName" missing');
        S.tcPDA.PathName = pwd;
    end
    P.tcPDA.PathName = S.tcPDA.PathName;

    if ~isfield(S.tcPDA, 'FileName')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.FileName" missing');
        S.tcPDA.FileName = '';
    end
    P.tcPDA.FileName = S.tcPDA.FileName;
    
    if ~isfield(S.tcPDA, 'corrections')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections" missing');
        S.tcPDA.corrections = [];
    end
    P.tcPDA.corrections = S.tcPDA.corrections;

    if ~isfield(S.tcPDA.corrections, 'ct_gr')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.ct_gr" missing');
        S.tcPDA.corrections.ct_gr = 0;
    end
    P.tcPDA.corrections.ct_gr = S.tcPDA.corrections.ct_gr;

    if ~isfield(S.tcPDA.corrections, 'ct_bg')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.ct_bg" missing');
        S.tcPDA.corrections.ct_bg = 0;
    end
    P.tcPDA.corrections.ct_bg = S.tcPDA.corrections.ct_bg;

    if ~isfield(S.tcPDA.corrections, 'ct_br')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.ct_br" missing');
        S.tcPDA.corrections.ct_br = 0;
    end
    P.tcPDA.corrections.ct_br = S.tcPDA.corrections.ct_br;

    if ~isfield(S.tcPDA.corrections, 'de_gr')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.de_gr" missing');
        S.tcPDA.corrections.de_gr = 0;
    end
    P.tcPDA.corrections.de_gr = S.tcPDA.corrections.de_gr;

    if ~isfield(S.tcPDA.corrections, 'de_bg')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.de_bg" missing');
        S.tcPDA.corrections.de_bg = 0;
    end
    P.tcPDA.corrections.de_bg = S.tcPDA.corrections.de_bg;

    if ~isfield(S.tcPDA.corrections, 'de_br')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.de_br" missing');
        S.tcPDA.corrections.de_br = 0;
    end
    P.tcPDA.corrections.de_br = S.tcPDA.corrections.de_br;

    if ~isfield(S.tcPDA.corrections, 'gamma_gr')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.gamma_gr" missing');
        S.tcPDA.corrections.gamma_gr = 1;
    end
    P.tcPDA.corrections.gamma_gr = S.tcPDA.corrections.gamma_gr;

    if ~isfield(S.tcPDA.corrections, 'gamma_br')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.gamma_br" missing');
        S.tcPDA.corrections.gamma_br = 1;
    end
    P.tcPDA.corrections.gamma_br = S.tcPDA.corrections.gamma_br;


    if ~isfield(S.tcPDA.corrections, 'BG_bb')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.BG_bb" missing');
        S.tcPDA.corrections.BG_bb = 0;
    end
    P.tcPDA.corrections.BG_bb = S.tcPDA.corrections.BG_bb;

    if ~isfield(S.tcPDA.corrections, 'BG_bg')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.BG_bg" missing');
        S.tcPDA.corrections.BG_bg = 0;
    end
    P.tcPDA.corrections.BG_bg = S.tcPDA.corrections.BG_bg;

    if ~isfield(S.tcPDA.corrections, 'BG_br')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.BG_br" missing');
        S.tcPDA.corrections.BG_br = 0;
    end
    P.tcPDA.corrections.BG_br = S.tcPDA.corrections.BG_br;

    if ~isfield(S.tcPDA.corrections, 'BG_gg')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.BG_gg" missing');
        S.tcPDA.corrections.BG_gg = 0;
    end
    P.tcPDA.corrections.BG_gg = S.tcPDA.corrections.BG_gg;

    if ~isfield(S.tcPDA.corrections, 'BG_gr')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.BG_gr" missing');
        S.tcPDA.corrections.BG_gr = 0;
    end
    P.tcPDA.corrections.BG_gr = S.tcPDA.corrections.BG_gr;

    if ~isfield(S.tcPDA.corrections, 'sampling')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.sampling" missing');
        S.tcPDA.corrections.sampling = 1;
    end
    P.tcPDA.corrections.sampling = S.tcPDA.corrections.sampling;

    if ~isfield(S.tcPDA.corrections, 'R0_gr')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.R0_gr" missing');
        S.tcPDA.corrections.R0_gr = 68;
    end
    P.tcPDA.corrections.R0_gr = S.tcPDA.corrections.R0_gr;

    if ~isfield(S.tcPDA.corrections, 'R0_bg')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.R0_bg" missing');
        S.tcPDA.corrections.R0_bg = 63;
    end
    P.tcPDA.corrections.R0_bg = S.tcPDA.corrections.R0_bg;

    if ~isfield(S.tcPDA.corrections, 'R0_br')
        disp('WARNING: UserValues structure incomplete, field "tcPDA.corrections.R0_br" missing');
        S.tcPDA.corrections.R0_br = 51;
    end
    P.tcPDA.corrections.R0_br = S.tcPDA.corrections.R0_br;
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UserValues=P;
    save(fullfile(Profiledir,'Profile.mat'),'Profile');
else
    Current=[];
end

%%% Saves user values    
Profiledir = [pwd filesep 'profiles'];
if ~isempty(Current) %% Saves loaded profile
    Profile=Current;
    save(fullfile(Profiledir,'Profile.mat'),'Profile');
    save(fullfile(Profiledir,Profile),'-struct','UserValues');
else
    load([Profiledir filesep 'Profile.mat']); %% Saves current profile
    save(fullfile(Profiledir,Profile),'-struct','UserValues');
end




