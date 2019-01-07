%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Applies Cuts to Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Valid, Data] = UpdateCuts(species,file)
global BurstData BurstMeta
%%% If no species is specified, read out selected species.
if nargin == 0
    file = BurstMeta.SelectedFile;
    species = BurstData{file}.SelectedSpecies;
end
if nargin < 2 % no file specified
    file = BurstMeta.SelectedFile;
end

Valid = true(size(BurstData{file}.DataArray,1),1);

if ~all(species == [0,0])
    CutState = vertcat(BurstData{file}.Cut{species(1),species(2)}{:});
    if ~isempty(CutState) %%% only proceed if there are elements in the CutTable
        for i = 1:size(CutState,1)
            if CutState{i,4} == 1 %%% only if the Cut is set to "active"
                if ~strcmp(CutState{i,1}(1:4),'AR: ') %%% if not arbitrary cut
                    Index = (strcmp(CutState(i,1),BurstData{file}.NameArray));
                    Valid = Valid & (BurstData{file}.DataArray(:,Index) >= CutState{i,2}) & (BurstData{file}.DataArray(:,Index) <= CutState{i,3});
                else %%% arbitrary cut
                    ARCutState = BurstData{file}.ArbitraryCut{species(1),species(2)}{i};
                    [nbinsY, nbinsX] = size(ARCutState.Mask);
                    mask = ARCutState.Mask(:);
                    %%% read out parameters used for arbitrary cut
                    IndexX = (strcmp(ARCutState.ParamX,BurstData{file}.NameArray));
                    IndexY = (strcmp(ARCutState.ParamY,BurstData{file}.NameArray));
                    parX = BurstData{file}.DataArray(:,IndexX);
                    parY = BurstData{file}.DataArray(:,IndexY);
                    %%% filter out-of-bounds data
                    valid_bounds = (parX >= ARCutState.LimX(1)) & (parX <= ARCutState.LimX(2)) &...
                        (parY >= ARCutState.LimY(1)) & (parY <= ARCutState.LimY(2));
                    %%% histogram data to apply mask
                    [~,~,~,~,~, bin] = calc2dhist(parX(valid_bounds),parY(valid_bounds),[nbinsX,nbinsY],ARCutState.LimX,ARCutState.LimY);

                    valid_mask = mask(sub2ind(size(ARCutState.Mask),bin(:,1),bin(:,2)));
                    valid_bounds(valid_bounds) = valid_mask;

                    Valid = Valid & valid_bounds;
                end
            end
        end
    end
    if strcmp(BurstData{file}.SpeciesNames{species(1),1}(1:min([end,5])),'Fit: ')%%% check if fit species was selected
        %%% read out additonal cuts from stored variable
        Valid = Valid & BurstData{file}.FitCut{species(1),species(2)};
    end
end

Data = BurstData{file}.DataArray(Valid,:);

if nargout == 0 %%% Only update global Variable if no output is requested!
    BurstData{file}.Selected = Valid;
    BurstData{file}.DataCut = Data;
end