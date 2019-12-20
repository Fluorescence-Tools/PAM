%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Defines new cuts from fitted Gaussians  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeciesFromGaussianFit(obj,~)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;
h = guidata(obj);
if h.MultiselectOnCheckbox.UserData
    disp('Disable multiplot mode and fit a single file!');
    return;
end
if ~isfield(BurstMeta,'Fitting')
    disp('Perform a Gaussian fit first');
    return;
end
if ~isfield(BurstMeta.Fitting,'Species') %%% occurs when only one species was used for fitting
    disp('Multi-species fit required.');
    return;
end
%%% assign bursts to species according to bin and probability
%%% uses stored information in BurstMeta.Fitting

%%% convert species probability density functions to probability for bin
nSpecies = numel(BurstMeta.Fitting.Species);
pTotal = BurstMeta.Fitting.Species{1}(:);
for i = 2:nSpecies
    pTotal = pTotal + BurstMeta.Fitting.Species{i}(:);
end
pSpecies = BurstMeta.Fitting.Species{1}(:)./pTotal;
for i = 2:nSpecies
    pSpecies = [pSpecies, BurstMeta.Fitting.Species{i}(:)./pTotal];
end

%%% number of bursts in each bin
burstCount = BurstMeta.Fitting.BurstCount(:);
%%% bins of valid bursts
burstIdx = sub2ind(size(BurstMeta.Fitting.BurstCount),BurstMeta.Fitting.BurstBins(:,1),BurstMeta.Fitting.BurstBins(:,2));

speciesAssignment = NaN(numel(burstIdx),1);
%%% loop over all bins
for i = 1:numel(burstCount)
    if burstCount(i) == 0
        continue;
    end
    %%% assign the bursts randomly to a species based on pSpecies
    nPerSpecies = round(burstCount(i).*pSpecies(i,:));
    while sum(nPerSpecies) < burstCount(i)
        ix = randi(nSpecies);
        nPerSpecies(ix) = nPerSpecies(ix) + 1;
    end
    spec = [];
    for s = 1:nSpecies
        spec = [spec, s*ones(1,nPerSpecies(s))];
    end
    spec = spec(randperm(numel(spec)));
    spec = spec(1:burstCount(i));
    speciesAssignment(burstIdx == i) = spec;
end

%%% add a new species to the species list with specific name
%%% subspecies correspond to the identified species
SpeciesNames = BurstData{file}.SpeciesNames;
SpeciesNames(end+1,1) = {['Fit: ' BurstMeta.Fitting.ParamX ' - ' BurstMeta.Fitting.ParamY]};
BurstData{file}.Cut{end+1,1} = {{BurstMeta.Fitting.ParamX,h.axes_general.XLim(1),h.axes_general.XLim(2),true,false},{BurstMeta.Fitting.ParamY,h.axes_general.YLim(1),h.axes_general.YLim(2),true,false}};
for i = 1:nSpecies
    SpeciesNames(end,i+1) = {['Species ' num2str(i) ': ('  sprintf('%.2f',BurstMeta.Fitting.MeanX(i)) '/' sprintf('%.2f',BurstMeta.Fitting.MeanY(i)) ')']};
    BurstData{file}.Cut{end,i+1} = {{BurstMeta.Fitting.ParamX,h.axes_general.XLim(1),h.axes_general.XLim(2),true,false};{BurstMeta.Fitting.ParamY,h.axes_general.YLim(1),h.axes_general.YLim(2),true,false}};
end
BurstData{file}.SpeciesNames = SpeciesNames;

%%% Add valid arrays to BurstData{file}.FitCut cell array
BurstData{file}.FitCut(size(SpeciesNames,1),1) = {~isnan(burstIdx)};
for i = 1:nSpecies
    BurstData{file}.FitCut(size(SpeciesNames,1),i+1) = {speciesAssignment == i};
end
UpdateSpeciesList(h);