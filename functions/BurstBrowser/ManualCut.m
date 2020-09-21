%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Manual Cut by selecting an area in the current selection  %%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ManualCut(obj,~)

h = guidata(obj);
global BurstData BurstMeta
%%% switch to main tab
h.Main_Tab.SelectedTab = h.Main_Tab_General;

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;
param_x = get(h.ParameterListX,'Value');
param_y = get(h.ParameterListY,'Value');

switch obj
    case h.CutButton
        set(gcf,'Pointer','cross');
        k = waitforbuttonpress;
        point1 = get(gca,'CurrentPoint');    % button down detected
        %%% check if correct axis was clicked
        if gca ~= h.axes_general
            return;
        end
        finalRect = rbbox;           % return figure units
        point2 = get(gca,'CurrentPoint');    % button up detected
        set(gcf,'Pointer','Arrow');
        point1 = point1(1,1:2);
        point2 = point2(1,1:2);
        
        if (all(point1(1:2) == point2(1:2)))
            disp('error');
            return;
        end
        
        %%% Check whether the CutParameter already exists or not
        ExistingCuts = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
        if ~isempty(ExistingCuts)
            if any(strcmp(BurstData{file}.NameArray{param_x},ExistingCuts(:,1)))
                BurstData{file}.Cut{species(1),species(2)}{strcmp(BurstData{file}.NameArray{param_x},ExistingCuts(:,1))} = {BurstData{file}.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
            else
                BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
            end
            
            if any(strcmp(BurstData{file}.NameArray{param_y},ExistingCuts(:,1)))
                BurstData{file}.Cut{species(1),species(2)}{strcmp(BurstData{file}.NameArray{param_y},ExistingCuts(:,1))} = {BurstData{file}.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
            else
                BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
            end
        else
            BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
            BurstData{file}.Cut{species(1),species(2)}{end+1} = {BurstData{file}.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};
        end
        
        %%% If a change was made to the GlobalCuts Species, update all other
        %%% existent species with the changes
        if species(2) == 1
            if numel(BurstData{file}.Cut) > 1 %%% Check if there are other species defined
                ChangedParamX = BurstData{file}.NameArray{get(h.ParameterListX,'Value')};
                ChangedParamY = BurstData{file}.NameArray{get(h.ParameterListY,'Value')};
                GlobalParams = vertcat(BurstData{file}.Cut{species(1),1}{:});
                GlobalParams = GlobalParams(1:numel(BurstData{file}.Cut{species(1),1}),1);
                %%% cycle through the number of other species
                num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
                for j = 2:num_species
                    %%% Check if the parameter already exists in the species j
                    ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
                    if ~isempty(ParamList)
                        ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                        CheckParam = strcmp(ParamList,ChangedParamX);
                        if any(CheckParam)
                            %%% Parameter added or changed
                            %%% Override the parameter with GlobalCut
                            BurstData{file}.Cut{species(1),j}(CheckParam) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamX));
                        else %%% Parameter is new to GlobalCut
                            BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamX));
                        end
                    else %%% Parameter is new to GlobalCut
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamX));
                    end
                end
                for j = 2:num_species
                    %%% Check if the parameter already exists in the species j
                    ParamList = vertcat(BurstData{file}.Cut{species(1),j}{:});
                    if ~isempty(ParamList)
                        ParamList = ParamList(1:numel(BurstData{file}.Cut{species(1),j}),1);
                        CheckParam = strcmp(ParamList,ChangedParamY);
                        if any(CheckParam)
                            %%% Parameter added or changed
                            %%% Override the parameter with GlobalCut
                            BurstData{file}.Cut{species(1),j}(CheckParam) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamY));
                        else %%% Parameter is new to GlobalCut
                            BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamY));
                        end
                    else %%% Parameter is new to GlobalCut
                        BurstData{file}.Cut{species(1),j}(end+1) = BurstData{file}.Cut{species(1),1}(strcmp(GlobalParams,ChangedParamY));
                    end
                end
            end
        end
    case h.ArbitraryCutButton
        %%% enable imfreehand
        roi = imfreehand(h.axes_general);
        %%% wait till double click
        wait(roi);
        if ~roi.isvalid
            return;
        end
        %%% make mask
        mask = createMask(roi,BurstMeta.Plots.Main_Plot(1));
        if strcmp(h.ArbitraryCutInvertCheckbox.Checked,'on')
            mask = 1-mask;
        end
        %%% delete roi
        delete(roi);
        
        if new
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Simply store the indices of the selected bursts %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% read out limits
            LimX = h.axes_general.XLim;
            LimY = h.axes_general.YLim;
            %%% read out parameters used for arbitrary cut
            parX = BurstData{file}.DataArray(:,param_x);
            parY = BurstData{file}.DataArray(:,param_y);
            %%% filter out-of-bounds data
            valid_bounds = (parX >= LimX(1)) & (parX <= LimX(2)) &...
                (parY >= LimY(1)) & (parY <= LimY(2));
            %%% histogram data to apply mask
            [~,~,~,~,~, bin] = calc2dhist(parX(valid_bounds),parY(valid_bounds),[nbinsX,nbinsY],LimX,LimY);
            
            valid_mask = mask(sub2ind(size(mask),bin(:,1),bin(:,2)));
            valid_bounds(valid_bounds) = valid_mask;
            sel = find(valid_bounds);
            %%% we need to store the current plot state to recall the arbitrary cut later
            % add it in any way to the selected species
            % additional field contains a structure with parameter names, plot boundaries and mask
            name = ['AR: ' BurstData{file}.NameArray{get(h.ParameterListX,'Value')} '/' BurstData{file}.NameArray{get(h.ParameterListY,'Value')}];
            BurstData{file}.Cut{species(1),species(2)}{end+1} = {name, NaN, NaN, true,false};
            BurstData{file}.ArbitraryCut{species(1),species(2)}{numel(BurstData{file}.Cut{species(1),species(2)})} = struct('ParamX',BurstData{file}.NameArray{get(h.ParameterListX,'Value')},'ParamY',BurstData{file}.NameArray{get(h.ParameterListY,'Value')},...
                'Mask',mask);
        else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% The OLD way of doing it, storing the mask   %%%
            %%% Disadvantage: Changes of correction factors %%%
            %%% affected the selection.                     %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% we need to store the current plot state to recall the arbitrary cut later
            % add it in any way to the selected species
            % additional field contains a structure with parameter names, plot boundaries and mask
            name = ['AR: ' BurstData{file}.NameArray{get(h.ParameterListX,'Value')} '/' BurstData{file}.NameArray{get(h.ParameterListY,'Value')}];
            BurstData{file}.Cut{species(1),species(2)}{end+1} = {name, NaN, NaN, true,false};
            BurstData{file}.ArbitraryCut{species(1),species(2)}{numel(BurstData{file}.Cut{species(1),species(2)})} = struct('ParamX',BurstData{file}.NameArray{get(h.ParameterListX,'Value')},'ParamY',BurstData{file}.NameArray{get(h.ParameterListY,'Value')},...
                'Mask',mask,'LimX',h.axes_general.XLim,'LimY',h.axes_general.YLim);
        end
        %%% If a change was made to the GlobalCuts Species, add arbitrary cut to all other
        %%% existent species with the changes
        if species(2) == 1
            CutData = BurstData{file}.Cut{species(1),species(2)}(end);
            ARCutData = BurstData{file}.ArbitraryCut{species(1),species(2)}(end);
            if numel(BurstData{file}.Cut) > 1 %%% Check if there are other species defined
                %%% cycle through the number of other species
                num_species = sum(~cellfun(@isempty,BurstData{file}.SpeciesNames(species(1),:)));
                for j = 2:num_species
                    %%% add arbitrary cut
                    BurstData{file}.Cut{species(1),j}(end+1) = CutData;
                    BurstData{file}.ArbitraryCut{species(1),j}(numel(BurstData{file}.Cut{species(1),j})) = ARCutData;
                end
            end
        end
end
UpdateCutTable(h);
UpdateCuts();

UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);