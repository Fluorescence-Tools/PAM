%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Mouse-click Callback for Species List       %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Left-click: Change plot to selected Species %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Right-click: Open menu                      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SpeciesList_ButtonDownFcn(hTree,eventData)
global BurstData BurstMeta UserValues
if isempty(BurstData)
    return;
end
h = guidata(findobj('Tag','BurstBrowser'));

%%% get the clicked node
%clicked = eventData.getCurrentNode;
clicked = hTree.getSelectedNodes;
if isempty(clicked)
    return;
end

if numel(clicked) > 1
    %%% if more than one element was selected -> Multiselection for multiplot
    %%% remove all top level species
    valid = true(numel(clicked),1);
    for i = 1:numel(clicked)
        if clicked(i).getLevel < 2
            valid(i) = false;
        end
    end
    clicked = clicked(valid);
    %%% update the selection to reflect the filtering
    if numel(clicked) > 1
        hTree.setSelectedNodes(clicked);
    else
        hTree.setSelectedNode(clicked);
    end
end

clicked = clicked(1);
%%% find out what exact node was clicked on with relation to array of
%%% species names
switch clicked.getLevel
    case 0
        % top level was clicked
        %%% reset selected node according to BurstData{file}.SelectedSpecies
        if all(BurstData{BurstMeta.SelectedFile}.SelectedSpecies == [0,0])
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.File(BurstMeta.SelectedFile));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) == 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)).getChildAt(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)-2));
        end
        return;
    case 1
        % file was clicked
        % which one?
        for i = 1:numel(h.SpeciesList.File)
            file(i) = h.SpeciesList.File(i).equals(clicked);
        end
        file = find(file);
        BurstMeta.SelectedFile = file;
        % default to the stored species selection for this file
        if all(BurstData{BurstMeta.SelectedFile}.SelectedSpecies == [0,0])
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.File(BurstMeta.SelectedFile));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) == 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(max([1,BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)])));
        elseif BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2) > 1
            h.SpeciesList.Tree.setSelectedNode(h.SpeciesList.Species{BurstMeta.SelectedFile}(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(1)).getChildAt(BurstData{BurstMeta.SelectedFile}.SelectedSpecies(2)-2));
        end
        
        %%% enable/disable gui elements based on type of file
        if BurstData{file}.APBS == 1
            %%% Enable the donor only lifetime checkbox
            h.DonorLifetimeFromDataCheckbox.Enable = 'on';
        else
            h.DonorLifetimeFromDataCheckbox.Enable = 'off';
        end
       
    case 2
        % species group was clicked
        % which file?
        f = clicked.getParent;
        for i = 1:numel(h.SpeciesList.File)
            file(i) = h.SpeciesList.File(i).equals(f);
        end
        file = find(file);
        % which one?
        for i = 1:numel(h.SpeciesList.Species{file})
            species(i) = h.SpeciesList.Species{file}(i).equals(clicked);
        end
        species = find(species);
        
        BurstMeta.SelectedFile = file;
        BurstData{file}.SelectedSpecies = [species,1];
    case 3
        % subspecies was clicked
        % which parent file?
        f = clicked.getParent.getParent;
        for i = 1:numel(h.SpeciesList.File)
            file(i) = h.SpeciesList.File(i).equals(f);
        end
        file = find(file);
        % which parent species?
        parent = clicked.getParent;
        for i = 1:numel(h.SpeciesList.Species{file})
            group(i) = h.SpeciesList.Species{file}(i).equals(parent);
        end
        group = find(group);
        % which subspecies?
        for i = 1:parent.getChildCount
            subspecies(i) = parent.getChildAt(i-1).equals(clicked);
        end
        subspecies = find(subspecies)+1;
        
        BurstMeta.SelectedFile = file;
        BurstData{file}.SelectedSpecies = [group,subspecies];
end
UserValues.File.BurstBrowserPath = BurstData{file}.PathName;

UpdateCorrections([],[],h);
UpdateCutTable(h);
UpdateCuts();
Update_fFCS_GUI([],[],h);
Update_ParameterList([],[],h);

%%% Update Plots
%%% To speed up, find out which tab is visible and only update the respective tab
switch h.Main_Tab.SelectedTab
    case h.Main_Tab_General
        %%% we switched to the general tab
        UpdatePlot([],[],h);
    case h.Main_Tab_Lifetime
        %%% we switched to the lifetime tab
        %%% figure out what subtab is selected
        UpdateLifetimePlots([],[],h);
        switch h.LifetimeTabgroup.SelectedTab
            case h.LifetimeTabAll
            case h.LifetimeTabInd
                PlotLifetimeInd([],[],h);
        end     
end