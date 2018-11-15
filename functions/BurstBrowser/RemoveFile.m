%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Remove File belonging to Selected Species (Right-click menu item) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RemoveFile(obj,eventData)
global BurstData BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));

file = BurstMeta.SelectedFile;
species = BurstData{file}.SelectedSpecies;

%%% remove file
BurstData{file} = [];
for i = file:(numel(BurstData)-1);
    BurstData{i} = BurstData{i+1};
end
BurstData(end) = [];
BurstMeta.SelectedFile = 1;
UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);

UpdateSpeciesList(h);
h = guidata(gcf);drawnow;
Update_fFCS_GUI([],[]);