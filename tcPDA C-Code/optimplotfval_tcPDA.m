function stop = optimplotfval_tcPDA(x,optimValues,state,varargin)
% OPTIMPLOTFVAL Plot value of the objective function at each iteration.
%
%   STOP = OPTIMPLOTFVAL(X,OPTIMVALUES,STATE) plots OPTIMVALUES.fval.  If
%   the function value is not scalar, a bar plot of the elements at the
%   current iteration is displayed.  If the OPTIMVALUES.fval field does not
%   exist, the OPTIMVALUES.residual field is used.
%
%   Example:
%   Create an options structure that will use OPTIMPLOTFVAL as the plot
%   function
%     options = optimset('PlotFcns',@optimplotfval);
%
%   Pass the options into an optimization problem to view the plot
%     fminbnd(@sin,3,10,options)

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/10 17:23:44 $

stop = false;
switch state
    case 'iter'
        if isfield(optimValues,'fval')
            if isscalar(optimValues.fval)
                plotscalar(optimValues.iteration,optimValues.fval);
            else
                plotvector(optimValues.iteration,optimValues.fval);
            end
        else
            plotvector(optimValues.iteration,optimValues.residual);
        end
    case 'init'
        if isfield(optimValues,'fval')
            if isscalar(optimValues.fval)
                plotscalar(optimValues.iteration,optimValues.fval);
            else
                plotvector(optimValues.iteration,optimValues.fval);
            end
        else
            plotvector(optimValues.iteration,optimValues.residual);
        end
end

function plotscalar(iteration,fval)
% PLOTSCALAR initializes or updates a line plot of the function value
% at each iteration.
global tcPDAstruct
handles = guidata(gcbo);

if iteration == 0
    plotfval = plot(iteration,fval,'kd','MarkerFaceColor',[1 0 1]);
    %axes(handles.axes_chi2);
    plotfval = plot(iteration,fval,'kd','MarkerFaceColor',[1 0 1]);
    title(sprintf('Current Function Value: %g',fval),'interp','none');
    xlabel(sprintf('Iteration'),'interp','none');
    set(plotfval,'Tag','optimplotfval');
    ylabel(sprintf('Function value'),'interp','none')
else
    plotfval = findobj(get(gca,'Children'),'Tag','optimplotfval');
    newX = [get(plotfval,'Xdata') iteration];
    newY = [get(plotfval,'Ydata') fval];
    set(plotfval,'Xdata',newX, 'Ydata',newY);
    set(get(gca,'Title'),'String',sprintf('Current Function Value: %g',fval));
    
    %% code for plotting in the respective axes
    
    plot_after_fit(handles);
end

function plotvector(iteration,fval)
% PLOTVECTOR creates or updates a bar plot of the function values or
% residuals at the current iteration.
if iteration == 0
    xlabelText = sprintf('Number of function values: %g',length(fval));
    % display up to the first 100 values
    if numel(fval) > 100
        xlabelText = {xlabelText,sprintf('Showing only the first 100 values')};
        fval = fval(1:100);
    end
    plotfval = bar(fval);
    title(sprintf('Current Function Values'),'interp','none');
    set(plotfval,'edgecolor','none')
    set(gca,'xlim',[0,1 + length(fval)])
    xlabel(xlabelText,'interp','none')
    set(plotfval,'Tag','optimplotfval');
    ylabel(sprintf('Function value'),'interp','none')
else
    plotfval = findobj(get(gca,'Children'),'Tag','optimplotfval');
    % display up to the first 100 values
    if numel(fval) > 100
        fval = fval(1:100);
    end
    set(plotfval,'Ydata',fval);
end

function plot_after_fit(handles)

global tcPDAstruct
switch (tcPDAstruct.selected_tab)
        case handles.tab_1d
            
            if ~ishandle(tcPDAstruct.plots.handle_1d_data) %data plot was deleted -> replot
                axes(handles.axes_1d);
                tcPDAstruct.plots.handle_1d_data = bar(tcPDAstruct.x_axis,tcPDAstruct.H_meas_gr,'BarWidth',1,'EdgeColor','k','LineWidth',1,'FaceColor',[0.5 0.5 0.5]);
                xlim([0 1]);
                ylim([0 max(tcPDAstruct.H_meas_gr)])
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_1d_fit') %no fit yet --> plot
                axes(handles.axes_1d);
                hold on;
                tcPDAstruct.plots.handle_1d_fit = bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_gr,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
                if (size(tcPDAstruct.plots.H_res_1d_individual,2) > 1)
                    color_str = {'ob','og','oy','oc','om'};
                    for i = 1:size(tcPDAstruct.plots.H_res_1d_individual,2)
                        tcPDAstruct.plots.handles_H_res_1d_individual(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_gr(i).*tcPDAstruct.plots.H_res_1d_individual(:,i),color_str{i});
                    end
                end
                hold off;
            elseif isfield(tcPDAstruct.plots,'handle_1d_fit') %--> plot exists, simply update ydata
                set(tcPDAstruct.plots.handle_1d_fit,'YData',tcPDAstruct.plots.H_res_gr);
                if (size(tcPDAstruct.plots.H_res_1d_individual,2) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_1d_individual')%plot
                        axes(handles.axes_1d);
                        color_str = {'ob','og','oy','oc','om'};
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_1d_individual,2)
                            tcPDAstruct.plots.handles_H_res_1d_individual(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_gr(i).*tcPDAstruct.plots.H_res_1d_individual(:,i),color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_1d_individual,2)
                            set(tcPDAstruct.plots.handles_H_res_1d_individual(i),'YData',tcPDAstruct.plots.A_gr(i).*tcPDAstruct.plots.H_res_1d_individual(:,i));
                        end
                    end
                end
            end
            
            
            
            if ~isfield(tcPDAstruct.plots,'handle_1d_dev') %no fit yet --> plot
                axes(handles.axes_1d_res);
                plot([0,1],[0,0],'-k');
                hold on;
                tcPDAstruct.plots.handle_1d_dev = bar(tcPDAstruct.x_axis,tcPDAstruct.plots.dev_gr,'EdgeColor','k','LineWidth',1,'FaceColor',[0.5 0.5 0.5]);
                hold off;
            elseif isfield(tcPDAstruct.plots,'handle_1d_dev')%simply update the Ydata
                set(tcPDAstruct.plots.handle_1d_dev,'YData',tcPDAstruct.plots.dev_gr);
            end
            
        case handles.tab_2d
            color_str = {'g','r','y','c','m'};
            if ~ishandle(tcPDAstruct.plots.handle_2d_data) %data plot was deleted -> replot
                axes(handles.axes_2d);
                surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.H_meas_2d);
                xlim([0 1]);
                ylim([0 1]);
                zlim([0 max(max(tcPDAstruct.H_meas_2d))]);
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_2d_fit')
                axes(handles.axes_2d);
                hold on;
                 if (size(tcPDAstruct.plots.H_res_2d_individual,3) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_2d_individual,3)
                        tcPDAstruct.plots.handles_H_res_2d_individual(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_2d(i).*tcPDAstruct.plots.H_res_2d_individual(:,:,i),'FaceColor','none','EdgeColor',color_str{i});
                    end
                end
                tcPDAstruct.plots.handle_2d_fit = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_2d,'FaceColor','none','EdgeColor',[1 1 1]);
                hold off;
                set(gca,'Color',[0.5 0.5 0.5]);
                %color the data plot by the deviation!
                set(tcPDAstruct.plots.handle_2d_data,'CData',abs(tcPDAstruct.plots.dev_2d));
                caxis([0 10])
            elseif isfield(tcPDAstruct.plots,'handle_2d_fit') %--> plot exists, simply update zdata
                
                if (size(tcPDAstruct.plots.H_res_2d_individual,3) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_2d_individual')%plot
                        axes(handles.axes_1d);
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_2d_individual,3)
                            tcPDAstruct.plots.handles_H_res_2d_individual(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_2d(i).*tcPDAstruct.plots.H_res_2d_individual(:,:,i),'FaceColor','none','EdgeColor',color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_2d_individual,3)
                            set(tcPDAstruct.plots.handles_H_res_2d_individual(i),'ZData',tcPDAstruct.plots.A_2d(i).*tcPDAstruct.plots.H_res_2d_individual(:,:,i));
                        end
                    end
                end
                set(tcPDAstruct.plots.handle_2d_fit,'ZData',tcPDAstruct.plots.H_res_2d);
                %color the data plot by the deviation!
                set(tcPDAstruct.plots.handle_2d_data,'CData',abs(tcPDAstruct.plots.dev_2d));
                caxis([0 10])
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_2d_dev') %no fit yet --> plot
                axes(handles.axes_2d_res);
                tcPDAstruct.plots.handle_2d_dev = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.dev_2d);
                xlim([0 1]);
                ylim([0 1]);
                zlim([0 max(max(tcPDAstruct.plots.dev_2d))]);
            elseif isfield(tcPDAstruct.plots,'handle_2d_dev')
                set(tcPDAstruct.plots.handle_2d_dev,'ZData',tcPDAstruct.plots.dev_2d);
                set(handles.axes_2d_res,'zlim',[min(min(tcPDAstruct.plots.dev_2d)) max(max(tcPDAstruct.plots.dev_2d))]);
            end
        case handles.tab_3d
            color_str = {'g','r','y','c','m'};
            if ~ishandle(tcPDAstruct.plots.handle_3d_data_bg_br) %data plot was deleted -> replot
                plot4d(tcPDAstruct.H_meas,handles);
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_3d_fit_bg_br')
                axes(handles.axes_3d(1));
                hold on;
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                        tcPDAstruct.plots.handles_H_res_3d_individual_bg_br(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},3)),'FaceColor','none','EdgeColor',color_str{i});
                    end
                end
                tcPDAstruct.plots.handle_3d_fit_bg_br = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_bg_br,'FaceColor','none','EdgeColor',[1 1 1]);
                hold off;
                set(gca,'Color',[0.5 0.5 0.5]);
            elseif isfield(tcPDAstruct.plots,'handle_3d_fit_bg_br')
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_3d_individual_bg_br')%plot
                        axes(handles.axes_3d(1));
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            tcPDAstruct.plots.handles_H_res_3d_individual_bg_br(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},3)),'FaceColor','none','EdgeColor',color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            set(tcPDAstruct.plots.handles_H_res_3d_individual_bg_br(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},3)));
                        end
                    end
                end
                set(tcPDAstruct.plots.handle_3d_fit_bg_br,'ZData',tcPDAstruct.plots.H_res_3d_bg_br);
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_3d_fit_bg_gr')
                axes(handles.axes_3d(2));
                hold on;
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                        tcPDAstruct.plots.handles_H_res_3d_individual_bg_gr(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},2)),'FaceColor','none','EdgeColor',color_str{i});
                    end
                end
                tcPDAstruct.plots.handle_3d_fit_bg_gr = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_bg_gr,'FaceColor','none','EdgeColor',[1 1 1]);
                hold off;
                set(gca,'Color',[0.5 0.5 0.5]);
            elseif isfield(tcPDAstruct.plots,'handle_3d_fit_bg_gr')
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_3d_individual_bg_gr')%plot
                        axes(handles.axes_3d(2));
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            tcPDAstruct.plots.handles_H_res_3d_individual_bg_gr(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},2)),'FaceColor','none','EdgeColor',color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            set(tcPDAstruct.plots.handles_H_res_3d_individual_bg_gr(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},2)));
                        end
                    end
                end
                set(tcPDAstruct.plots.handle_3d_fit_bg_gr,'ZData',tcPDAstruct.plots.H_res_3d_bg_gr);
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_3d_fit_br_gr')
                axes(handles.axes_3d(3));
                hold on;
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                        tcPDAstruct.plots.handles_H_res_3d_individual_br_gr(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},1)),'FaceColor','none','EdgeColor',color_str{i});
                    end
                end
                tcPDAstruct.plots.handle_3d_fit_br_gr = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_br_gr,'FaceColor','none','EdgeColor',[1 1 1]);
                hold off;
                set(gca,'Color',[0.5 0.5 0.5]);
            elseif isfield(tcPDAstruct.plots,'handle_3d_fit_br_gr')
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_3d_individual_br_gr')%plot
                        axes(handles.axes_3d(3));
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            tcPDAstruct.plots.handles_H_res_3d_individual_br_gr(i) = surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},1)),'FaceColor','none','EdgeColor',color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            set(tcPDAstruct.plots.handles_H_res_3d_individual_br_gr(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},1)));
                        end
                    end
                end
                set(tcPDAstruct.plots.handle_3d_fit_br_gr,'ZData',tcPDAstruct.plots.H_res_3d_br_gr);
            end
            
            color_str = {'og','or','oy','oc','om'};
            if ~isfield(tcPDAstruct.plots,'handle_3d_fit_bg') %no fit yet --> plot
                axes(handles.axes_3d(4));
                hold on;
                tcPDAstruct.plots.handle_3d_fit_bg = bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_bg,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                        tcPDAstruct.plots.handles_H_res_3d_individual_bg(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},2),3)),color_str{i});
                    end
                end
                hold off;
            elseif isfield(tcPDAstruct.plots,'handle_3d_fit_bg') %--> plot exists, simply update ydata
                set(tcPDAstruct.plots.handle_3d_fit_bg,'YData',tcPDAstruct.plots.H_res_3d_bg); 
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_3d_individual_bg')%plot
                        axes(handles.axes_3d(4));
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            tcPDAstruct.plots.handles_H_res_3d_individual_bg(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},2),3)),color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            set(tcPDAstruct.plots.handles_H_res_3d_individual_bg(i),'YData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},2),3)));
                        end
                    end
                end
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_3d_fit_br') %no fit yet --> plot
                axes(handles.axes_3d(5));
                hold on;
                tcPDAstruct.plots.handle_3d_fit_br = bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_br,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                        tcPDAstruct.plots.handles_H_res_3d_individual_br(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),3)),color_str{i});
                    end
                end
                hold off;
            elseif isfield(tcPDAstruct.plots,'handle_3d_fit_br') %--> plot exists, simply update ydata
                set(tcPDAstruct.plots.handle_3d_fit_br,'YData',tcPDAstruct.plots.H_res_3d_br); 
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_3d_individual_br')%plot
                        axes(handles.axes_3d(5));
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            tcPDAstruct.plots.handles_H_res_3d_individual_br(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),3)),color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            set(tcPDAstruct.plots.handles_H_res_3d_individual_br(i),'YData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),3)));
                        end
                    end
                end
            end
            
            if ~isfield(tcPDAstruct.plots,'handle_3d_fit_gr') %no fit yet --> plot
                axes(handles.axes_3d(6));
                hold on;
                tcPDAstruct.plots.handle_3d_fit_gr = bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_gr,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                        tcPDAstruct.plots.handles_H_res_3d_individual_gr(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),2)),color_str{i});
                    end
                end
                hold off;
            elseif isfield(tcPDAstruct.plots,'handle_3d_fit_gr') %--> plot exists, simply update ydata
                set(tcPDAstruct.plots.handle_3d_fit_gr,'YData',tcPDAstruct.plots.H_res_3d_gr); 
                if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                    if ~isfield(tcPDAstruct.plots,'handles_H_res_3d_individual_gr')%plot
                        axes(handles.axes_3d(6));
                        hold on;
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            tcPDAstruct.plots.handles_H_res_3d_individual_gr(i) = plot(tcPDAstruct.x_axis,tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),2)),color_str{i});
                        end
                        hold off;
                    else%simply update
                        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                            set(tcPDAstruct.plots.handles_H_res_3d_individual_gr(i),'YData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),2)));
                        end
                    end
                end
            end
            
end