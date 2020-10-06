function [ stop ] = UpdateFitProgress(x,optimvalues,state,varin,plot_after_fit,UpdateFitTable)
%%% updates fit progress for fmincon or fminsearch
% Best objective function value in the previous iteration
persistent last_best gof_type
global tcPDAstruct
handles = guidata(gcbo);
if isempty(state) && isempty(varin)
    %%% pattern search, reorder input
    state = optimvalues;
    optimvalues = x;
end
best = min(optimvalues.fval);

stop = false;
if(strcmp(state,'init')) 
        fig = findobj('Name','Optimization PlotFcns');
        if isempty(fig)
            fig = findobj('Name','Pattern Search');
        end
        fig.Visible = 'off';
        %%% figure out how we got here
        switch handles.tabgroup.SelectedTab
            case {handles.tab_1d, handles.tab_2d}
                %%% Chi2 fitting of 1 or 2d histogram
                handles.fit_progress_text.String = sprintf('red. \\chi^2 = %.2f',best);
                gof_type = 1;
            case {handles.tab_3d}
                switch handles.MLE_checkbox.Value
                    case 0
                        %%% Chi2 fitting of 3d histogram
                        handles.fit_progress_text.String = sprintf('red. \\chi^2 = %.2f',best);
                        gof_type = 1;
                    case 1
                        %%% MLE fitting of 3d histogram
                        handles.fit_progress_text.String = sprintf('-logL = %.2f',best);
                        gof_type = 2;
                end
        end
        %%% reset plot
        handles.plots.fit_progress.XData = optimvalues.iteration;
        handles.plots.fit_progress.YData = best;
        %%% find the plot figure, hijack the buttons, delete it
        handles.fit_pause_button.Callback = fig.Children(1).Callback;
        handles.fit_cancel_button.Callback = fig.Children(2).Callback;
        handles.fit_pause_button.Enable = 'on';
        handles.fit_cancel_button.Enable = 'on';
end
% Best objective function value in the current iteration
  
% Set last_best to best
if optimvalues.iteration == 0
    last_best = best;      
else
    %Change in objective function value
    change = last_best - best; 
    handles.plots.fit_progress.XData(end+1) = optimvalues.iteration;
    handles.plots.fit_progress.YData(end+1) = best;
    if numel(handles.plots.fit_progress.XData) > 1000
        handles.plots.fit_progress.XData(1) = [];
        handles.plots.fit_progress.YData(1) = [];
    end
    switch gof_type
        case 1
            handles.fit_progress_text.String = sprintf('red. \\chi^2 = %.2f',tcPDAstruct.plots.chi2);
        case 2
            handles.fit_progress_text.String = sprintf('-logL = %.2f',best);
    end
end

if tcPDAstruct.live_plot_update
    plot_after_fit(handles);
    %update table
    UpdateFitTable(handles);
end
