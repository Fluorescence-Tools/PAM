function  [Profiles,Current] = LSUserValues(Mode)
global UserValues


if Mode==0
    %% Loads user values
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
    if ~isfield (S, 'Detector') || any(~isfield(S.Detector, {'Det';'Rout';'Use';'Color';'Shift'}));
        S.Detector=[];
        S.Detector.Det=1;
        S.Detector.Rout=1;
        S.Detector.Use=1;
        S.Detector.Color=[1 0 0];
        S.Detector.Shift={zeros(400,1)};
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
    
    if ~isfield(S.File,'FCS_Standard')
        S.File.FCS_Standard=[];
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
    %%% (This field contains the PIEChannel Selection (as a number) for every
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
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UserValues=S;
    Mode=1;
    
else
    Current=[];
end

if Mode==1
    %% Saves user values
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



