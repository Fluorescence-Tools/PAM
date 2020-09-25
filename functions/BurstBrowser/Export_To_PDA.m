%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export Photons for PDA analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_To_PDA(obj,~)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
if obj == h.Export_PDA_All_Menu
    files = 1:numel(BurstData);
elseif obj == h.Export_PDA_Sel_Menu
    [files,species,subspecies] = get_multiselection(h);
else
    files = BurstMeta.SelectedFile;
end

export_lifetime = h.PDA_ExportLifetime.Value;

k = 0;
sel_file =  BurstMeta.SelectedFile;
for i = 1:numel(files)
    file = files(i);
    BurstMeta.SelectedFile = file;
    if obj == h.Export_PDA_Sel_Menu
        sel_species = BurstData{file}.SelectedSpecies;
        BurstData{file}.SelectedSpecies = [species(i),subspecies(i)];        
    end
    UpdateCuts();
    Progress(k/numel(files),h.Progress_Axes,h.Progress_Text,'Loading Photon Data');
    %%% Load associated .bps file, containing Macrotime, Microtime and Channel
    if isempty(BurstTCSPCData{file})
        Load_Photons();
    end
    Progress(k/numel(files),h.Progress_Axes,h.Progress_Text,'Exporting...');
    
    SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
    SelectedSpeciesName = strrep(strrep(SelectedSpeciesName,'/','-'),':','');
    %% Export FRET Species
    %%% find selected bursts
    MT = BurstTCSPCData{file}.Macrotime(BurstData{file}.Selected);
    CH = BurstTCSPCData{file}.Channel(BurstData{file}.Selected);
    if export_lifetime
        MI = BurstTCSPCData{file}.Microtime(BurstData{file}.Selected);
    end
    % Timebin can be a single number or a range e.g. "0.2,0.5,1", without the " "
    Timebin = str2num(h.TimeBinPDAEdit.String).*1E-3;
    
    for t = 1:numel(Timebin)
        timebin = Timebin(t);
        duration = timebin./BurstData{file}.ClockPeriod;
        
        if timebin ~= 0
            if ~export_lifetime
                PDAdata = Bursts_to_Timebins(MT,CH,duration);
            else
                PDAdata = Bursts_to_Timebins(MT,CH,duration,MI);
            end
        elseif timebin == 0 %burstwise, get duration array
            [PDAdata, dur] = Bursts_to_Timebins(MT,CH,duration);
            dur = double(dur).*BurstData{file}.ClockPeriod;
        end
        Progress(k/numel(files),h.Progress_Axes,h.Progress_Text,'Exporting...');
        
        %%% Save Brightness Reference?
        save_brightness_reference = 1;
        %now save channel wise photon numbers
        total = numel(PDAdata);
        filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
        
        newfilename = GenerateName([filename(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.pda'], 1);
        switch BurstData{file}.BAMethod
            case {1,2}
                PDA.NGP = zeros(total,1);
                PDA.NGS = zeros(total,1);
                PDA.NFP = zeros(total,1);
                PDA.NFS = zeros(total,1);
                PDA.NRP = zeros(total,1);
                PDA.NRS = zeros(total,1);
                
                PDA.NG = zeros(total,1);
                PDA.NF = zeros(total,1);
                PDA.NR = zeros(total,1);
                
                PDA.NGP = cellfun(@(x) sum((x==1)),PDAdata(:,1));
                PDA.NGS = cellfun(@(x) sum((x==2)),PDAdata(:,1));
                PDA.NFP = cellfun(@(x) sum((x==3)),PDAdata(:,1));
                PDA.NFS = cellfun(@(x) sum((x==4)),PDAdata(:,1));
                PDA.NRP = cellfun(@(x) sum((x==5)),PDAdata(:,1));
                PDA.NRS = cellfun(@(x) sum((x==6)),PDAdata(:,1));
                
                PDA.NG = PDA.NGP + PDA.NGS;
                PDA.NF = PDA.NFP + PDA.NFS;
                PDA.NR = PDA.NRP + PDA.NRS;
                
                PDA.Corrections = BurstData{file}.Corrections;
                PDA.Background = BurstData{file}.Background;
                
                if timebin == 0% burstwise, save duration array
                    PDA.Duration = dur;
                end
                if save_brightness_reference
                    posS = (strcmp(BurstData{file}.NameArray,'Stoichiometry'));
                    donly = (BurstData{file}.DataArray(:,posS) > 0.95);
                    if timebin ~= 0
                        DOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                    elseif timebin == 0 %burstwise, get duration array
                        [DOnly_PDA, DOnly_dur] = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                        DOnly_dur = DOnly_dur.*BurstData{file}.ClockPeriod;
                        PDA.BrightnessReference.Duration = DOnly_dur;
                    end
                    NGP = cellfun(@(x) sum((x==1)),DOnly_PDA);
                    NGS = cellfun(@(x) sum((x==2)),DOnly_PDA);
                    PDA.BrightnessReference.N = NGP + NGS;
                end
                
                if h.PDA_ExportLifetime.Value
                    PDA.MI_GP = cellfun(@(x,y) y(x==1),PDAdata(:,1),PDAdata(:,2),'UniformOutput',false);
                    PDA.MI_GS = cellfun(@(x,y) y(x==2),PDAdata(:,1),PDAdata(:,2),'UniformOutput',false);
                    PDA.MI_G = cellfun(@(x,y) [x;y],PDA.MI_GP,PDA.MI_GS,'UniformOutput',false);
                    PDA.IRF_GP = BurstData{file}.IRF{1};
                    PDA.IRF_GS = BurstData{file}.IRF{2};
                    PDA.IRF_G = PDA.IRF_GP + PDA.IRF_GS;
                    PDA.TACbin = BurstData{file}.FileInfo.TACRange*1E9/BurstData{file}.FileInfo.MI_Bins;
                    PDA.PIE = BurstData{file}.PIE;
                end
                %%% add cut information of current species
                CutState = cell2table(vertcat(BurstData{file}.Cut{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}{:}),'VariableNames',{'Paramater','Min','Max','Active','Delete'});
                PDA.CutState = CutState(:,1:end-1);
                
                save(newfilename, 'PDA', 'timebin')
            case 5 %noMFD
                PDA.NG = zeros(total,1);
                PDA.NF = zeros(total,1);
                PDA.NR = zeros(total,1);
                
                PDA.NG = cellfun(@(x) sum((x==1)),PDAdata(:,1));
                PDA.NF = cellfun(@(x) sum((x==2)),PDAdata(:,1));
                PDA.NR = cellfun(@(x) sum((x==3)),PDAdata(:,1));
                
                PDA.Corrections = BurstData{file}.Corrections;
                PDA.Background = BurstData{file}.Background;
                for i = fieldnames(PDA.Background)'
                    PDA.Background.(i{1}) = PDA.Background.(i{1})/2;
                end
                if save_brightness_reference
                    posS = (strcmp(BurstData{file}.NameArray,'Stoichiometry'));
                    donly = (BurstData{file}.DataArray(:,posS) > 0.95);
                    DOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                    NG = cellfun(@(x) sum((x==1)),DOnly_PDA);
                    PDA.BrightnessReference.N = NG;
                end
                if h.PDA_ExportLifetime.Value
                    PDA.MI_G = cellfun(@(x,y) y(x==1),PDAdata(:,1),PDAdata(:,2),'UniformOutput',false);
                    PDA.IRF_G = BurstData{file}.IRF{1};
                    PDA.TACbin = BurstData{file}.FileInfo.TACRange*1E9/BurstData{file}.FileInfo.MI_Bins;
                    PDA.PIE = BurstData{file}.PIE;
                end
                %%% add cut information of current species
                CutState = cell2table(vertcat(BurstData{file}.Cut{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}{:}),'VariableNames',{'Paramater','Min','Max','Active','Delete'});
                PDA.CutState = CutState(:,1:end-1);
                
                save(newfilename, 'PDA', 'timebin')
            case {3,4}
                %%% ask user for either 3CPDA or two color subpopulation
                [choice, ok] = listdlg('PromptString','Select Export Mode:',...
                    'SelectionMode','single',...
                    'ListString',{'3CPDA','GR','BG','BR'});
                if ~ok
                    return;
                end
                switch choice
                    case 1
                        NBBP = cellfun(@(x) sum((x==1)),PDAdata(:,1));
                        NBBS = cellfun(@(x) sum((x==2)),PDAdata(:,1));
                        NBGP = cellfun(@(x) sum((x==3)),PDAdata(:,1));
                        NBGS = cellfun(@(x) sum((x==4)),PDAdata(:,1));
                        NBRP = cellfun(@(x) sum((x==5)),PDAdata(:,1));
                        NBRS = cellfun(@(x) sum((x==6)),PDAdata(:,1));
                        NGGP = cellfun(@(x) sum((x==7)),PDAdata(:,1));
                        NGGS = cellfun(@(x) sum((x==8)),PDAdata(:,1));
                        NGRP = cellfun(@(x) sum((x==9)),PDAdata(:,1));
                        NGRS = cellfun(@(x) sum((x==10)),PDAdata(:,1));
                        NRRP = cellfun(@(x) sum((x==11)),PDAdata(:,1));
                        NRRS = cellfun(@(x) sum((x==12)),PDAdata(:,1));
                        
                        tcPDAstruct.NBB = NBBP + NBBS;
                        tcPDAstruct.NBG = NBGP + NBGS;
                        tcPDAstruct.NBR = NBRP + NBRS;
                        tcPDAstruct.NGG = NGGP + NGGS;
                        tcPDAstruct.NGR = NGRP + NGRS;
                        tcPDAstruct.NRR = NRRP + NRRS;
                        tcPDAstruct.duration = ones(numel(NBBP),1)*timebin*1000;
                        tcPDAstruct.timebin = timebin*1000;
                        tcPDAstruct.background = BurstData{file}.Background;
                        tcPDAstruct.corrections = BurstData{file}.Corrections;
                        
                        if save_brightness_reference
                            posSGR = (strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
                            posSBG = (strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
                            posSBR = (strcmp(BurstData{file}.NameArray,'Stoichiometry BR'));
                            gonly = (BurstData{file}.DataArray(:,posSGR) > 0.95) & (BurstData{file}.DataArray(:,posSBG) < 0.05);
                            GOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(gonly),BurstTCSPCData{file}.Channel(gonly),duration);
                            NGP = cellfun(@(x) sum((x==7)),GOnly_PDA);
                            NGS = cellfun(@(x) sum((x==8)),GOnly_PDA);
                            tcPDAstruct.BrightnessReference.NG = NGP + NGS;
                            bonly = (BurstData{file}.DataArray(:,posSBR) > 0.95) & (BurstData{file}.DataArray(:,posSBG) > 0.95);
                            BOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(bonly),BurstTCSPCData{file}.Channel(bonly),duration);
                            NBP = cellfun(@(x) sum((x==1)),BOnly_PDA);
                            NBS = cellfun(@(x) sum((x==2)),BOnly_PDA);
                            tcPDAstruct.BrightnessReference.NB = NBP + NBS;
                        end
                        filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
                        newfilename = [filename(1:end-4) '_' SelectedSpeciesName '_' num2str(timebin*1000) 'ms.tcpda'];
                        
                        %%% add cut information of current species
                        CutState = cell2table(vertcat(BurstData{file}.Cut{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}{:}),'VariableNames',{'Paramater','Min','Max','Active','Delete'});
                        tcPDAstruct.CutState = CutState(:,1:end-1);
                
                        save(newfilename, 'tcPDAstruct', 'timebin')
                    case {2,3,4}
                        PDA.NGP = zeros(total,1);
                        PDA.NGS = zeros(total,1);
                        PDA.NFP = zeros(total,1);
                        PDA.NFS = zeros(total,1);
                        PDA.NRP = zeros(total,1);
                        PDA.NRS = zeros(total,1);
                        
                        PDA.NG = zeros(total,1);
                        PDA.NF = zeros(total,1);
                        PDA.NR = zeros(total,1);
                        
                        %chan gives the photon counts in format
                        %[Donor_par/perp,FRET_par/perp,Acc_par/perp]
                        switch choice
                            case 2
                                chan = [7,8,9,10,11,12];
                                newfilename = [newfilename(1:end-4) '_GR.pda'];
                            case 3
                                chan = [1, 2, 3, 4, 7, 8];
                                newfilename = [newfilename(1:end-4) '_BG.pda'];
                            case 4
                                chan = [1, 2, 5, 6, 11, 12];
                                newfilename = [newfilename(1:end-4) '_BR.pda'];
                        end
                        
                        PDA.NGP = cellfun(@(x) sum((x==chan(1))),PDAdata(:,1));
                        PDA.NGS = cellfun(@(x) sum((x==chan(2))),PDAdata(:,1));
                        PDA.NFP = cellfun(@(x) sum((x==chan(3))),PDAdata(:,1));
                        PDA.NFS = cellfun(@(x) sum((x==chan(4))),PDAdata(:,1));
                        PDA.NRP = cellfun(@(x) sum((x==chan(5))),PDAdata(:,1));
                        PDA.NRS = cellfun(@(x) sum((x==chan(6))),PDAdata(:,1));
                        
                        %PDA.NGP = cellfun(@(x) sum((x==7)),PDAdata);
                        %PDA.NGS = cellfun(@(x) sum((x==8)),PDAdata);
                        %PDA.NFP = cellfun(@(x) sum((x==9)),PDAdata);
                        %PDA.NFS = cellfun(@(x) sum((x==10)),PDAdata);
                        %PDA.NRP = cellfun(@(x) sum((x==11)),PDAdata);
                        %PDA.NRS = cellfun(@(x) sum((x==12)),PDAdata);
                        
                        PDA.NG = PDA.NGP + PDA.NGS;
                        PDA.NF = PDA.NFP + PDA.NFS;
                        PDA.NR = PDA.NRP + PDA.NRS;
                        
                        PDA.Corrections = BurstData{file}.Corrections;
                        PDA.Background = BurstData{file}.Background;
                        %%% change corrections with values for selected species
                        switch choice
                            case 2
                                %%% keep as is
                            case 3
                                PDA.Corrections.Gamma_GR = PDA.Corrections.Gamma_BG;
                                PDA.Corrections.CrossTalk_GR = PDA.Corrections.CrossTalk_BG;
                                PDA.Corrections.FoersterRadius = PDA.Corrections.FoersterRadiusBG;
                                PDA.Background.Background_GGpar = PDA.Background.Background_BBpar;
                                PDA.Background.Background_GGperp = PDA.Background.Background_BBperp;
                                PDA.Background.Background_GRpar = PDA.Background.Background_BGpar;
                                PDA.Background.Background_GRperp = PDA.Background.Background_BGperp;
                                PDA.Background.Background_RRpar = PDA.Background.Background_GGpar;
                                PDA.Background.Background_RRperp = PDA.Background.Background_GGperp;
                            case 4
                                PDA.Corrections.Gamma_GR = PDA.Corrections.Gamma_BR;
                                PDA.Corrections.CrossTalk_GR = PDA.Corrections.CrossTalk_BR;
                                PDA.Corrections.FoersterRadius = PDA.Corrections.FoersterRadiusBR;
                                PDA.Background.Background_GGpar = PDA.Background.Background_BBpar;
                                PDA.Background.Background_GGperp = PDA.Background.Background_BBperp;
                                PDA.Background.Background_GRpar = PDA.Background.Background_BRpar;
                                PDA.Background.Background_GRperp = PDA.Background.Background_BRperp;
                        end
                        if save_brightness_reference
                            posSGR = (strcmp(BurstData{file}.NameArray,'Stoichiometry GR'));
                            posSBG = (strcmp(BurstData{file}.NameArray,'Stoichiometry BG'));
                            donly = (BurstData{file}.DataArray(:,posSGR) > 0.95) & (BurstData{file}.DataArray(:,posSBG) < 0.05);
                            DOnly_PDA = Bursts_to_Timebins(BurstTCSPCData{file}.Macrotime(donly),BurstTCSPCData{file}.Channel(donly),duration);
                            NGP = cellfun(@(x) sum((x==7)),DOnly_PDA);
                            NGS = cellfun(@(x) sum((x==8)),DOnly_PDA);
                            PDA.BrightnessReference.N = NGP + NGS;
                        end
                        %%% add cut information of current species
                        CutState = cell2table(vertcat(BurstData{file}.Cut{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}{:}),'VariableNames',{'Paramater','Min','Max','Active','Delete'});
                        PDA.CutState = CutState(:,1:end-1);
                
                        save(newfilename, 'PDA', 'timebin')
                end
        end
    end
    k = k+1;
    
    if obj == h.Export_PDA_Sel_Menu
        BurstData{file}.SelectedSpecies = sel_species;
    end
end
BurstMeta.SelectedFile = sel_file;
Progress(1,h.Progress_Axes,h.Progress_Text);
%%% Set tcPDA Path to BurstBrowser Path
UserValues.tcPDA.PathName = UserValues.File.BurstBrowserPath;
UserValues.File.PDAPath = UserValues.File.BurstBrowserPath;
LSUserValues(1);