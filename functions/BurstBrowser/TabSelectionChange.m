%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Executes on Tab-Change in Main Window and updates Plots %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TabSelectionChange(obj,e)
h = guidata(obj);
if isempty(h)
    return;
end

switch obj %%% distinguish between maintab change and lifetime subtab change
    case h.Main_Tab
        switch e.NewValue
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
    case h.LifetimeTabgroup %%% we clicked the lifetime subtabgroup
        UpdateLifetimePlots([],[],h);
        switch e.NewValue
            case h.LifetimeTabAll
            case h.LifetimeTabInd
                PlotLifetimeInd([],[],h);
        end
end
drawnow;