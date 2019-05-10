%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Saves FRET Hist to a file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Export_FRET_Hist(obj,~,mode)
global BurstData UserValues BurstMeta
if ~isempty(obj)
    if ~isobject(obj)
        h = guidata(findobj('Tag','BurstBrowser'));
        obj = 'None';
    else
        h = guidata(obj);
    end
    switch obj
        case h.FRET_Export_All_Menu;
            %%% loop over all files
            sel_file = BurstMeta.SelectedFile;
            for i = 1:numel(BurstData);
                BurstMeta.SelectedFile = i;
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[]);
                Export_FRET_Hist([],[],'Export FRET Efficiency Histogram');
            end
            BurstMeta.SelectedFile = sel_file;
        case h.FRET_Export_Sel_Menu;
            %%% loop over all selected species
            sel_file = BurstMeta.SelectedFile;
            [files,species,subspecies] = get_multiselection(h);
            for i = 1:numel(files)
                file = files(i);
                BurstMeta.SelectedFile = file;
                sel_species = BurstData{file}.SelectedSpecies;
                BurstData{file}.SelectedSpecies = [species(i),subspecies(i)];
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[],h,0);
                Export_FRET_Hist([],[],'Export FRET Efficiency Histogram');
                BurstData{file}.SelectedSpecies = sel_species;
            end
            BurstMeta.SelectedFile = sel_file;
        otherwise %% java menu item
            o = gcbo;
            if strcmp(o.getText,'Export FRET Efficiency Histogram (Time Series)')
                %%% Make sure to apply corrections
                ApplyCorrections(h.BurstBrowser,[]);
                Export_FRET_Hist([],[]);
            else
                %%% loop over all files
                sel_file = BurstMeta.SelectedFile;
                for i = 1:numel(BurstData);
                    BurstMeta.SelectedFile = i;
                    %%% Make sure to apply corrections
                    ApplyCorrections(h.BurstBrowser,[]);
                    Export_FRET_Hist([],[]);
                end
                BurstMeta.SelectedFile = sel_file;
            end
    end
    %%% set FCSFit path to the current print path
    UserValues.File.FCSPath = getPrintPath();
    LSUserValues(1);
else
    file = BurstMeta.SelectedFile;
    if BurstData{file}.SelectedSpecies(2) == 0 %%% total measurement is selected
        SelectedSpeciesName = 'total';
    else
        %%% top level species is selected
        SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1};
        if BurstData{file}.SelectedSpecies(2) > 1 %%% subpspecies is selected
            SelectedSpeciesName = [SelectedSpeciesName '_' BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)}];
        end
    end
    SelectedSpeciesName = strrep(SelectedSpeciesName,' ','_');
    filename = [BurstData{file}.FileName(1:end-4) '_' SelectedSpeciesName '.his'];
    filename = strrep(strrep(filename,'/','-'),':','');
    if nargin < 3
        obj = gcbo;
    else
        obj.Label = mode;
    end
    switch obj.Label
        case 'Export FRET Efficiency Histogram'
            switch BurstData{file}.BAMethod
                case {1,2}
                    E = BurstData{file}.DataCut(:,1);
                    %%% Save E array in *.his file
                    save(fullfile(getPrintPath(),filename),'E');
                case {3,4}
                    EGR = BurstData{file}.DataCut(:,1);
                    EBG = BurstData{file}.DataCut(:,2);
                    EBR = BurstData{file}.DataCut(:,3);
                    %%% Save E array in *.his file
                    save(fullfile(getPrintPath(),filename),'EGR','EBG','EBR');
            end
        case 'Export FRET Efficiency Histogram (Time Series)'
            %%% export a time series in specific binnig
            %%% query binning
            timebin = inputdlg('Enter time bin in minutes:','Specifiy time bin',1,{'10'});
            timebin = round(str2double(timebin{1}))*60;
            macrotime = BurstData{file}.DataCut(:,strcmp('Mean Macrotime [s]',BurstData{file}.NameArray));
            times = 0:timebin:ceil(macrotime(end)/timebin)*timebin;
            for i = 1:numel(times)-1
                % get valid bursts
                valid = (macrotime >= times(i)) & (macrotime <= times(i+1));
                E = BurstData{file}.DataCut(valid,1);
                % generate name
                name = [filename(1:end-4) '_' num2str(round(times(i)/60)) 'to' num2str(round(times(i+1)/60)) 'min.his'];
                %%% Save E array in *.his file
                save(fullfile(getPrintPath(),name),'E');
            end
            m = msgbox('Done exporting time series.');
            pause(1);
            delete(m);
    end
end