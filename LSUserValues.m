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
    if ~isfield (S, 'Look') || any(~isfield(S.Look, {'Back';'Fore';'Control';'Axes';'Disabled';'Shadow'}));
        S.Look=[];
        S.Look.Back=[0.2 0.2 0.2];
        S.Look.Fore=[1 1 1];
        S.Look.Control=[0.4 0.4 0.4];
        S.Look.Axes=[0.8 0.8 0.8];
        S.Look.Disabled=[0 0 0];
        S.Look.Shadow=[0.4 0.4 0.4];
        disp('UserValues.Look was incomplete');
    end
    P.Look = [];
    P.Look.Back = S.Look.Back;
    P.Look.Fore = S.Look.Fore;
    P.Look.Control = S.Look.Control;
    P.Look.Axes = S.Look.Axes;
    P.Look.Disabled = S.Look.Disabled;
    P.Look.Shadow = S.Look.Shadow;
    %% File: Last used Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Checks, if fields exist
    if ~isfield (S, 'File');
        S.File=[];
        disp('UserValues.File was incomplete');
    end
    P.File = [];
    if ~isfield(S.File, 'Path')
        S.File.Path=pwd;
    end
    P.File.Path = S.File.Path;
    if ~isfield(S.File, 'ExportPath')
        S.File.ExportPath=pwd;
    end
    P.File.ExportPath = S.File.ExportPath;
    if ~isfield(S.File, 'PhasorPath')
        S.File.PhasorPath=pwd;
    end
    P.File.PhasorPath = S.File.PhasorPath;
    if ~isfield(S.File, 'FCSPath')
        S.File.FCSPath=pwd;
    end
    P.File.FCSPath = S.File.FCSPath;
    if ~isfield(S.File, 'MIAPath')
        S.File.MIAPath=pwd;
    end 
    P.File.MIAPath = S.File.MIAPath;
    if ~isfield(S.File, 'MIAFitPath')
        S.File.MIAFitPath=pwd;
    end
    P.File.MIAFitPath = S.File.MIAFitPath;
    if ~isfield(S.File, 'BurstBrowserPath')
        S.File.BurstBrowserPath=pwd;
    end 
    P.File.BurstBrowserPath = S.File.BurstBrowserPath;
    
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
            '*.ht3','HydraHarp400 TTTR file (*.ht3)'};

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
    %%% Checksm if Pam.Cor_Selection subfield exists
    if ~isfield (S.Settings.Pam, 'Cor_Selection')
        S.Settings.Pam.Cor_Selection=false(numel(S.PIE.Name)+1);
        disp('UserValues.Settings.Pam.Cor_Selection was incomplete');
    end
    P.Settings.Pam.Cor_Selection = S.Settings.Pam.Cor_Selection;
    
    %% FCSFit
    %%% Checks, if FCSFit subfield exists
    if ~isfield (S, 'FCSFit')
        S.FCSFit=[];
        disp('UserValues.FCSFit was incomplete');
    end
    P.FCSFit = [];
    %%% Checks if FCSFit.Fit_Min subfield exists
    if ~isfield (S.FCSFit, 'Fit_Min')
        S.FCSFit.Fit_Min=0;
        disp('UserValues.FCSFit.Fit_Min was incomplete');
    end
    P.FCSFit.Fit_Min = S.FCSFit.Fit_Min;
    %%% Checks if FCSFit.Fit_Min subfield exists
    if ~isfield (S.FCSFit, 'Fit_Max')
        S.FCSFit.Fit_Max=1;
        disp('UserValues.FCSFit.Fit_Max was incomplete');
    end
    P.FCSFit.Fit_Max = S.FCSFit.Fit_Max;
    %%% Checks if FCSFit.Plot_Errorbars subfield exists
    if ~isfield (S.FCSFit, 'Plot_Errorbars')
        S.FCSFit.Plot_Errorbars=1;
        disp('UserValues.FCSFit.Plot_Errorbars was incomplete');
    end
    P.FCSFit.Plot_Errorbars = S.FCSFit.Plot_Errorbars;
    %%% Checks if FCSFit.Fit_Tolerance subfield exists
    if ~isfield (S.FCSFit, 'Fit_Tolerance')
        S.FCSFit.Fit_Tolerance=1e-6;
        disp('UserValues.FCSFit.Fit_Tolerance was incomplete');
    end
    P.FCSFit.Fit_Tolerance = S.FCSFit.Fit_Tolerance;
    %%% Checks if FCSFit.Use_Weights subfield exists
    if ~isfield (S.FCSFit, 'Use_Weights')
        S.FCSFit.Use_Weights=1;
        disp('UserValues.FCSFit.Use_Weights was incomplete');
    end
    P.FCSFit.Use_Weights = S.FCSFit.Use_Weights;
    %%% Checks if FCSFit.Max_Iterations subfield exists
    if ~isfield (S.FCSFit, 'Max_Iterations')
        S.FCSFit.Max_Iterations=1000;
        disp('UserValues.FCSFit.Max_Iterations was incomplete');
    end
    P.FCSFit.Max_Iterations = S.FCSFit.Max_Iterations;
    %%% Checks if FCSFit.NormalizationMethod subfield exists
    if ~isfield (S.FCSFit, 'NormalizationMethod')
        S.FCSFit.NormalizationMethod=1;
        disp('UserValues.FCSFit.NormalizationMethod was incomplete');
    end
    P.FCSFit.NormalizationMethod = S.FCSFit.NormalizationMethod;
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
    %%% Checks, if BurstSearch.IRF exists
    %%% (This field contains the IRF pattern used for burstwise lifetime
    %%% fitting)
    if ~isfield (S.BurstSearch,'IRF')
        S.BurstSearch.IRF=[];
        disp('UserValues.BurstSearch.IRF was incomplete');    
    end
    P.BurstSearch.IRF = S.BurstSearch.IRF;
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
    %%% Checks, if TauFit.IRF exists
    %%% (This fields stores the Microtime Pattern of an IRF measurement)
    if ~isfield (S.TauFit,'IRF')
        S.TauFit.IRF=[];
            disp('UserValues.TauFit.IRF was incomplete');    
    end
    P.TauFit.IRF = S.TauFit.IRF;
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
    %% BurstBrowser
    %%% Checks, if BurstBrowser subfield exists
    if ~isfield (S,'BurstBrowser')
        S.BurstBrowser=[];
        disp('UserValues.BurstBrowser was incomplete');    
    end
    P.BurstBrowser = [];
    %%% Checks, if BurstBrowser.Corrections subfield exists
    %%% Here the correction factors are stored
    if ~isfield (S.BurstBrowser,'Corrections')
        S.BurstBrowser.Corrections=[];
        disp('UserValues.BurstBrowser.Corrections was incomplete');    
    end
    P.BurstBrowser.Corrections = [];
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
    %%% Checks, if BurstBrowser.Display subfield exists
    %%% Here the display options are stored
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
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UserValues=P;
    Mode=1;
    
else
    Current=[];
end

if Mode==1 %%% Saves user values    
    Profiledir = [pwd filesep 'profiles'];    
    if ~isempty(Current) %% Saves loaded profile
        Profile=Current;
        save(fullfile(Profiledir,'Profile.mat'),'Profile');
        save(fullfile(Profiledir,Profile),'-struct','UserValues');
    else
        load([Profiledir filesep 'Profile.mat']); %% Saves current profile
        save(fullfile(Profiledir,Profile),'-struct','UserValues');
    end    
end



