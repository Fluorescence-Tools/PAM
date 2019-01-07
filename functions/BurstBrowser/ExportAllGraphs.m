%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export All Graphs at once %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportAllGraphs(obj,~)
global BurstData BurstMeta UserValues
h = guidata(obj);

%%% enable saving
prev_setting = UserValues.BurstBrowser.Settings.SaveFileExportFigure;
UserValues.BurstBrowser.Settings.SaveFileExportFigure = 1;
file = BurstMeta.SelectedFile;
UpdateCorrections([],[],h);
UpdateCutTable(h);
UpdateCuts();
%Update_fFCS_GUI([],[],h);
%update all plots, cause that's what we'll be copying
UpdatePlot([],[],h);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);

if any(BurstData{file}.BAMethod == [3,4])
    disp('Not implemented for three color.');
    return;
end

% 2D E-S 
h.ParameterListX.Value = find(strcmp('FRET Efficiency',BurstData{file}.NameArray));
h.ParameterListY.Value = find(strcmp('Stoichiometry',BurstData{file}.NameArray));
UpdatePlot([],[],h);
[hfig, FigureName] = ExportGraphs(h.Export2D_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName)
% 1D E
[hfig, FigureName] = ExportGraphs(h.Export1DX_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName) 
% all lifetime & anisotropy plots
[hfig, FigureName] = ExportGraphs(h.ExportLifetime_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName)
% 2D E-tau
h.lifetime_ind_popupmenu.Value = 1;
PlotLifetimeInd([],[]);
[hfig, FigureName] = ExportGraphs(h.Export2DLifetime_Menu,[],0);
ExportGraph_CloseFunction(hfig,[],0,FigureName)
% Corrections
% [hfig, FigureName] = ExportGraphs(h.ExportCorrections_Menu,[],0);
% ExportGraph_CloseFunction(hfig,[],0,FigureName)

UserValues.BurstBrowser.Settings.SaveFileExportFigure = prev_setting;