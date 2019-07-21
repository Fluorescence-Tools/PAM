function UpdateSpeciesList(h)
global BurstData BurstMeta
h.SpeciesList.Root = uitreenode('v0',h.SpeciesList.Tree,'Data Tree',[] ,false);
h.SpeciesList.Root.setIcon(im2java(h.icons.iconBurst));
for f = 1:numel(BurstData)
    % populate uitree
    h.SpeciesList.File(f) = uitreenode('v0', h.SpeciesList.Tree, BurstData{f}.FileName, [], false);
    h.SpeciesList.File(f).setIcon(im2java(h.icons.iconFile));
    for i = 1:size(BurstData{f}.SpeciesNames,1)
        %%% make uitreenode for every subgroup
        h.SpeciesList.Species{f}(i) = uitreenode('v0', h.SpeciesList.Tree, BurstData{f}.SpeciesNames{i,1}, [], false);
        h.SpeciesList.Species{f}(i).setIcon(im2java(h.icons.iconSpecies));
        %%% add subnodes for every subspecies
        for j = 2:size(BurstData{f}.SpeciesNames,2)
            if ~isempty(BurstData{f}.SpeciesNames{i,j})
                h.SpeciesList.Nodes{f}{i}(j) = uitreenode('v0', h.SpeciesList.Tree, BurstData{f}.SpeciesNames{i,j}, [], true);
                h.SpeciesList.Species{f}(i).add(h.SpeciesList.Nodes{f}{i}(j));
                h.SpeciesList.Nodes{f}{i}(j).setIcon(im2java(h.icons.iconSubspecies));
            end
        end
        h.SpeciesList.File(f).add(h.SpeciesList.Species{f}(i));
    end
    h.SpeciesList.Root.add(h.SpeciesList.File(f));
end
h.SpeciesList.Tree.setRoot(h.SpeciesList.Root);

%%% expand all
h.SpeciesList.Tree.expand(h.SpeciesList.Root);
for f = 1:numel(BurstData)
    h.SpeciesList.Tree.expand(h.SpeciesList.File(f));
    %for i = 1:numel(h.SpeciesList.Species{f})
    %    h.SpeciesList.Tree.expand(h.SpeciesList.Species{f}(i));
    %end
end

guidata(h.BurstBrowser,h);

set(h.SpeciesList.Tree,'NodeSelectedCallback',@SpeciesList_ButtonDownFcn);
%%% set selected node according to Stored Selection
if all(BurstData{BurstMeta.SelectedFile}.SelectedSpecies == [0,0])
    h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.File(BurstMeta.SelectedFile));
elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) == 1
    h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1
    try
        h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)).getChildAt(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)-2));
    catch % by going to parent species
        h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
    end
end