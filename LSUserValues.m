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
    
    %% File: Last used Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% Checks, if fields exist
    if ~isfield (S, 'File');
        S.File=[];
        disp('UserValues.File was incomplete');
    end
    if ~isfield(S.File, 'Path')
        S.File.Path=pwd;
    end
    if ~isfield(S.File, 'ExportPath')
        S.File.ExportPath=pwd;
    end
    if ~isfield(S.File, 'PhasorPath')
        S.File.PhasorPath=pwd;
    end
    if ~isfield(S.File, 'FCSPath')
        S.File.FCSPath=pwd;
    end
    if ~isfield(S.File, 'MIAPath')
        S.File.MIAPath=pwd;
    end 
    if ~isfield(S.File, 'BurstBrowserPath')
        S.File.BurstBrowserPath=pwd;
    end 
    
    if ~isfield(S.File,'FCS_Standard')
        S.File.FCS_Standard=[];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%% File types for uigetfile with SPC files  %%%%%%%%%%%%% %%%%%%%%%%%%%%%%% %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % never change from here
    if ~isfield(S.File, 'SPC_FileTypes')
        disp('WARNING: UserValues structure incomplete, field "SPC_FileTypes" missing');
        S.File.SPC_FileTypes = {'*0.spc','B&H-SPC files recorded with FabSurf (*0.spc)';...
        '*_m1.spc','B&H-SPC files recorded with B&H-Software (*_m1.spc)'};
    end
    % to here

    % to add filetypes, add 1 to the "currentnumber" and add the new filetype to the array below:
    currentnumber = 3;
    if numel(S.File.SPC_FileTypes) < 2*currentnumber
        disp('WARNING: More file types were added to "UserValues.SPC_FileTypes"');
        S.File.SPC_FileTypes = {'*0.spc','B&H-SPC files recorded with FabSurf (*0.spc)';...
        '*_m1.spc','B&H-SPC files recorded with B&H-Software (*_m1.spc)';...
        '*.ht3','HydraHarp400 TTTR file'};
    end
    
    if ~isfield(S.File, 'OpenTCSPC_FilterIndex')
        disp('WARNING: UserValues structure incomplete, field "OpenTCSPC_FilterIndex" missing');
        S.File.OpenTCSPC_FilterIndex = 1;
    end
    %% Settings: All values of popupmenues, checkboxes etc. that need to be persistent
    
    %%% Checks, if Settings field exists
    if ~isfield (S, 'Settings')
        S.Settings=[];
        disp('UserValues.Settings was incomplete');
    end
    %%% Checks, if Pam subfield exists
    if ~isfield (S.Settings, 'Pam')
        S.Settings.Pam=[];
        disp('UserValues.Settings.Pam was incomplete');
    end
    %%% Checks, if Pam.Use_Image subfield exists
    if ~isfield (S.Settings.Pam, 'Use_Image')
        S.Settings.Pam.Use_Image=0;
        disp('UserValues.Settings.Pam.Use_Image was incomplete');
    end
    %%% Checks, if Pam.Use_Lifetime subfield exists
    if ~isfield (S.Settings.Pam, 'Use_Lifetime')
        S.Settings.Pam.Use_Lifetime=0;
        disp('UserValues.Settings.Pam.Use_Lifetime was incomplete');
    end
    %%% Checks, if Pam.MT_Binning subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Binning')
        S.Settings.Pam.MT_Binning=10;
        disp('UserValues.Settings.Pam.MT_Binning was incomplete');
    end
    %%% Checks, if Pam.MT_Trace_Sectioning subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Trace_Sectioning')
        S.Settings.Pam.MT_Trace_Sectioning=1;
        disp('UserValues.Settings.Pam.MT_Trace_Sectioning was incomplete');
    end
    %%% Checks, if Pam.MT_Time_Section subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Time_Section')
        S.Settings.Pam.MT_Time_Section=2;
        disp('UserValues.Settings.Pam.MT_Time_Section was incomplete');
    end
    %%% Checks, if Pam.MT_Number_Section subfield exists
    if ~isfield (S.Settings.Pam, 'MT_Number_Section')
        S.Settings.Pam.MT_Number_Section=10;
        disp('UserValues.Settings.Pam.MT_Number_Section was incomplete');
    end
    %%% Checks, if Pam.Multi_Cor subfield exists
    if ~isfield (S.Settings.Pam, 'Multi_Core')
        S.Settings.Pam.Multi_Core='on';
        disp('UserValues.Settings.Pam.Multi_Cor was incomplete');
    end
    %%% Checks, if Pam.Cor_Divider subfield exists
    if ~isfield (S.Settings.Pam, 'Cor_Divider')
        S.Settings.Pam.Cor_Divider='1';
        disp('UserValues.Settings.Pam.Cor_Divider was incomplete');
    end
    
    
    
    %% Peripheral fields, that do not concern the main gui (like burst, phasor mia)
    %% Phasor
    %%% Checks, if Phasor subfield exists
    if ~isfield (S,'Phasor')
        S.Phasor=[];
        disp('UserValues.Phasor was incomplete');
    end
    %%% Checks, if Phasor.Reference subfield exists
    if ~isfield (S.Phasor,'Reference')
        S.Phasor.Reference=zeros(numel(S.Detector.Det),4096);
        disp('UserValues.Phasor.Reference was incomplete');
    end
    
    %% Burst Search
    %%% Checks, if BurstSearch subfield exists
    if ~isfield (S,'BurstSearch')
        S.BurstSearch=[];
        disp('UserValues.BurstSearch was incomplete');    
    end
    %%% Checks, if BurstSearch.Method subfield exists
    if ~isfield (S.BurstSearch,'Method')
        S.BurstSearch.Method=1;
        disp('UserValues.BurstSearch.Method was incomplete');    
    end
    %%% Checks, if BurstSearch.PIEChannelSelection exists
    %%% (This field contains the PIEChannel Selection (as a String) for every
    %%% Burst Search Method)
    if ~isfield (S.BurstSearch,'PIEChannelSelection')
        dummy = S.PIE.Name{1};
        S.BurstSearch.PIEChannelSelection={{dummy,dummy;dummy,dummy;dummy,dummy},{dummy,dummy;dummy,dummy;dummy,dummy},{dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy},{dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy;dummy,dummy},{dummy;dummy;dummy}};
        disp('UserValues.BurstSearch.PIEChannelSelection was incomplete');    
    end
    %%% Checks, if BurstSearch.SearchParameters exists
    %%% (This field contains the Search Parameters for every Burst Search
    %%% Method)
    if ~isfield (S.BurstSearch,'SearchParameters')
        S.BurstSearch.SearchParameters={[100,500,5,5,5],[100,500,5,5,5],[100,500,5,5,5],[100,500,5,5,5],[100,500,5,5,5]};
        disp('UserValues.BurstSearch.SearchParameters was incomplete');    
    end
    
    %%% Checks, if BurstSearch.IRF exists
    %%% (This field contains the IRF pattern used for burstwise lifetime
    %%% fitting)
    if ~isfield (S.BurstSearch,'IRF')
        S.BurstSearch.IRF=[];
        disp('UserValues.BurstSearch.IRF was incomplete');    
    end

    %% TauFit
    %%% Checks, if TauFit subfield exists
    if ~isfield (S,'TauFit')
        S.TauFit=[];
        disp('UserValues.TauFit was incomplete');    
    end
    %%% Checks, if TauFit.PIEChannelSelection exists
    %%% (This field contains the PIE Channel Selection as String/Name for
    %%% Parallel and Perpendicular Channel)
    if ~isfield (S.TauFit,'PIEChannelSelection')
        dummy = S.PIE.Name{1};
        S.TauFit.PIEChannelSelection={dummy,dummy};
            disp('UserValues.TauFit.PIEChannelSelection was incomplete');    
    end
    %%% Checks, if TauFit.IRF exists
    %%% (This fields stores the Microtime Pattern of an IRF measurement)
    if ~isfield (S.TauFit,'IRF')
        S.TauFit.IRF=[];
            disp('UserValues.TauFit.IRF was incomplete');    
    end
    
    %%% Checks, if TauFit.Ggreen exists
    %%% (Gfactor for the green channels)
    if ~isfield (S.TauFit,'Ggreen')
        S.TauFit.Ggreen=1;
            disp('UserValues.TauFit.Ggreen was incomplete');    
    end
    
    %%% Checks, if TauFit.Gred exists
    %%% (Gfactor for the red channels)
    if ~isfield (S.TauFit,'Gred')
        S.TauFit.Gred=1;
            disp('UserValues.TauFit.Gred was incomplete');    
    end
    
    %%% Checks, if TauFit.l1 exists
    %%% (First of the correction factors accounting for the polarization mixing caused by the high N.A. objective lense)
    if ~isfield (S.TauFit,'l1')
        S.TauFit.l1=0;
            disp('UserValues.TauFit.l1 was incomplete');    
    end
    
    %%% Checks, if TauFit.l2 exists
    %%% (Second of the correction factors accounting for the polarization mixing caused by the high N.A. objective lense)
    if ~isfield (S.TauFit,'l2')
        S.TauFit.l2=0;
            disp('UserValues.TauFit.l2 was incomplete');    
    end
    
    %% BurstBrowser
    %%% Checks, if BurstBrowser subfield exists
    if ~isfield (S,'BurstBrowser')
        S.BurstBrowser=[];
        disp('UserValues.BurstBrowser was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections subfield exists
    %%% Here the correction factors are stored
    if ~isfield (S.BurstBrowser,'Corrections')
        S.BurstBrowser.Corrections=[];
        disp('UserValues.BurstBrowser.Corrections was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.CrossTalk_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'CrossTalk_GR')
        S.BurstBrowser.Corrections.CrossTalk_GR=0;
        disp('UserValues.BurstBrowser.Corrections.CrossTalk_GR was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.CrossTalk_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'CrossTalk_BG')
        S.BurstBrowser.Corrections.CrossTalk_BG=0;
        disp('UserValues.BurstBrowser.Corrections.CrossTalk_BG was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.CrossTalk_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'CrossTalk_BR')
        S.BurstBrowser.Corrections.CrossTalk_BR=0;
        disp('UserValues.BurstBrowser.Corrections.CrossTalk_BR was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.DirectExcitation_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'DirectExcitation_GR')
        S.BurstBrowser.Corrections.DirectExcitation_GR=0;
        disp('UserValues.BurstBrowser.Corrections.DirectExcitation_GR was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.DirectExcitation_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'DirectExcitation_BG')
        S.BurstBrowser.Corrections.DirectExcitation_BG=0;
        disp('UserValues.BurstBrowser.Corrections.DirectExcitation_BG was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.DirectExcitation_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'DirectExcitation_BR')
        S.BurstBrowser.Corrections.DirectExcitation_BR=0;
        disp('UserValues.BurstBrowser.Corrections.DirectExcitation_BR was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Gamma_GR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Gamma_GR')
        S.BurstBrowser.Corrections.Gamma_GR=1;
        disp('UserValues.BurstBrowser.Corrections.Gamma_GR was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Gamma_BG subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Gamma_BG')
        S.BurstBrowser.Corrections.Gamma_BG=1;
        disp('UserValues.BurstBrowser.Corrections.Gamma_BG was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Gamma_BR subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Gamma_BR')
        S.BurstBrowser.Corrections.Gamma_BR=1;
        disp('UserValues.BurstBrowser.Corrections.Gamma_BR was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_GGpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GGpar')
        S.BurstBrowser.Corrections.Background_GGpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GGpar was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_GGperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GGperp')
        S.BurstBrowser.Corrections.Background_GGperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GGperp was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_GRpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GRpar')
        S.BurstBrowser.Corrections.Background_GRpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GRpar was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_GRperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_GRperp')
        S.BurstBrowser.Corrections.Background_GRperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_GRperp was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_RRpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_RRpar')
        S.BurstBrowser.Corrections.Background_RRpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_RRpar was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_RRperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_RRperp')
        S.BurstBrowser.Corrections.Background_RRperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_RRperp was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_BBpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BBpar')
        S.BurstBrowser.Corrections.Background_BBpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BBpar was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_BBperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BBperp')
        S.BurstBrowser.Corrections.Background_BBperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BBperp was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_BGpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BGpar')
        S.BurstBrowser.Corrections.Background_BGpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BGpar was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_BGperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BGperp')
        S.BurstBrowser.Corrections.Background_BGperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BGperp was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_BRpar subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BRpar')
        S.BurstBrowser.Corrections.Background_BRpar=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BRpar was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.Background_BRperp subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'Background_BRperp')
        S.BurstBrowser.Corrections.Background_BRperp=0;
        disp('UserValues.BurstBrowser.Corrections.Background_BRperp was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.GfactorGreen subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'GfactorGreen')
        S.BurstBrowser.Corrections.GfactorGreen=1;
        disp('UserValues.BurstBrowser.Corrections.GfactorGreen was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.GfactorRed subfield exists
    if ~isfield (S.BurstBrowser.Corrections,'GfactorRed')
        S.BurstBrowser.Corrections.GfactorRed=1;
        disp('UserValues.BurstBrowser.Corrections.GfactorRed was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.l1 subfield exists
    %%% This is the first corrections factor accounting for polarization
    %%% mixing caused by the high N.A. objective lense
    if ~isfield (S.BurstBrowser.Corrections,'l1')
        S.BurstBrowser.Corrections.l1=0;
        disp('UserValues.BurstBrowser.Corrections.l1 was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.l2 subfield exists
    %%% This is the second corrections factor accounting for polarization
    %%% mixing caused by the high N.A. objective lense
    if ~isfield (S.BurstBrowser.Corrections,'l2')
        S.BurstBrowser.Corrections.l2=0;
        disp('UserValues.BurstBrowser.Corrections.l2 was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.DonorLifetime subfield exists
    %%% This value stores the set Donor Lifetime
    if ~isfield (S.BurstBrowser.Corrections,'DonorLifetime')
        S.BurstBrowser.Corrections.DonorLifetime=3.8;
        disp('UserValues.BurstBrowser.Corrections.DonorLifetime was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.AcceptorLifetime subfield exists
    %%% This value stores the set Acceptor Lifetime
    if ~isfield (S.BurstBrowser.Corrections,'AcceptorLifetime')
        S.BurstBrowser.Corrections.AcceptorLifetime=3.5;
        disp('UserValues.BurstBrowser.Corrections.AcceptorLifetime was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.FoersterRadius subfield exists
    %%% This value stores the set Foerster Radius
    if ~isfield (S.BurstBrowser.Corrections,'FoersterRadius')
        S.BurstBrowser.Corrections.FoersterRadius=59;
        disp('UserValues.BurstBrowser.Corrections.FoersterRadius was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Corrections.LinkerLength subfield exists
    %%% This value stores the set Linker Length 
    if ~isfield (S.BurstBrowser.Corrections,'LinkerLength')
        S.BurstBrowser.Corrections.LinkerLength=5;
        disp('UserValues.BurstBrowser.Corrections.LinkerLength was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Display subfield exists
    %%% Here the display options are stored
    if ~isfield (S.BurstBrowser,'Display')
        S.BurstBrowser.Display=[];
        disp('UserValues.BurstBrowser.Display was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Display.NumberOfBins subfield exists
    if ~isfield (S.BurstBrowser.Display,'NumberOfBins')
        S.BurstBrowser.Display.NumberOfBins=50;
        disp('UserValues.BurstBrowser.Display.NumberOfBins was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Display.PlotType subfield exists
    if ~isfield (S.BurstBrowser.Display,'PlotType')
        S.BurstBrowser.Display.PlotType='Image';
        disp('UserValues.BurstBrowser.Display.PlotType was incomplete');    
    end
    
    %%% Checks, if BurstBrowser.Display.ColorMap subfield exists
    if ~isfield (S.BurstBrowser.Display,'ColorMap')
        S.BurstBrowser.Display.ColorMap='hot';
        disp('UserValues.BurstBrowser.Display.ColorMap was incomplete');    
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UserValues=S;
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



