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
    %plotfval = plot(iteration,fval,'kd','MarkerFaceColor',[1 0 1]);
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
    if tcPDAstruct.MLE == 0
        plot_after_fit(handles);
    end
    
    
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
switch (handles.tabgroup.SelectedTab)
        case handles.tab_1d
            set(handles.plots.handle_1d_fit,'YData',tcPDAstruct.plots.H_res_gr);
            if (size(tcPDAstruct.plots.H_res_1d_individual,2) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_1d_individual,2)
                    set(handles.plots.handles_H_res_1d_individual(i),'YData',tcPDAstruct.plots.A_gr(i).*tcPDAstruct.plots.H_res_1d_individual(:,i));
                end
            end
            set(handles.plots.handle_1d_dev,'YData',tcPDAstruct.plots.dev_gr);
        case handles.tab_2d
            if (size(tcPDAstruct.plots.H_res_2d_individual,3) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_2d_individual,3)
                    set(handles.plots.handles_H_res_2d_individual(i),'ZData',tcPDAstruct.plots.A_2d(i).*tcPDAstruct.plots.H_res_2d_individual(:,:,i));
                end
            end
            set(handles.plots.handle_2d_fit,'ZData',tcPDAstruct.plots.H_res_2d);
           
            set(handles.plots.handle_2d_dev,'ZData',tcPDAstruct.plots.dev_2d);
            set(handles.axes_2d_res,'zlim',[min(min(tcPDAstruct.plots.dev_2d)) max(max(tcPDAstruct.plots.dev_2d))]);
        case handles.tab_3d
            if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                    set(handles.plots.handles_H_res_3d_individual_bg_br(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},3)));
                end
            end
            set(handles.plots.handle_3d_fit_bg_br,'ZData',tcPDAstruct.plots.H_res_3d_bg_br);
            
            if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                    set(handles.plots.handles_H_res_3d_individual_bg_gr(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},2)));
                end
            end
            set(handles.plots.handle_3d_fit_bg_gr,'ZData',tcPDAstruct.plots.H_res_3d_bg_gr);
            
            if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                    set(handles.plots.handles_H_res_3d_individual_br_gr(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},1)));
                end
            end
            set(handles.plots.handle_3d_fit_br_gr,'ZData',tcPDAstruct.plots.H_res_3d_br_gr);
         
            set(handles.plots.handle_3d_fit_bg,'YData',tcPDAstruct.plots.H_res_3d_bg); 
            if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                    set(handles.plots.handles_H_res_3d_individual_bg(i),'YData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},2),3)));
                end
            end
            
            set(handles.plots.handle_3d_fit_br,'YData',tcPDAstruct.plots.H_res_3d_br); 
            if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                    set(handles.plots.handles_H_res_3d_individual_br(i),'YData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),3)));
                end
            end
            
            set(handles.plots.handle_3d_fit_gr,'YData',tcPDAstruct.plots.H_res_3d_gr); 
            if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
                for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
                    set(handles.plots.handles_H_res_3d_individual_gr(i),'YData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),2)));
                end
            end      
end
handles.text_chi2.String = sprintf('Chi2 = %.2f',tcPDAstruct.plots.chi2);