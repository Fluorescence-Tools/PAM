function [samples,prob,acceptance] =  MHsample(nsamples,probfun,priorfun,sigma_prop,lb,ub,initial_parameters,fixed,plot_params,param_names,parent_figure)
%%% Performs Metropolis-Hastings-Sampling of posterior distribution
%%% Input parameters:
%%% nsamples    -   Number of Samples to draw
%%% probfun     -   function handle to the logarithm of posterior density function,
%%%                 only a funtion of the parameter vector, 
%%%                 defined with the data! 
%%%                 i.e. probfun = @(par) prob(data_x,data_y,model_param,par)
%%% priorfun    -   function handle to the prior density function, also
%%%                 a function of the parameter vector
%%% sigma_prop  -   width of the Gaussian distributions used for proposal
%%%                 distribution. Defined individually for every parameter!
%%%                 (1 x n)
%%% lb          -   Lower Boundaries (1 x n)
%%% ub          -   Upper Boundaries (1 x n)
%%% initial_parameters - Vector of start parameters.
%%% fixed       -   logical array specifying which parameters to vary
%%% plot_param  -   logical array of parameter values to plot each
%%%                 iteration
%%%                 (uses plotfun(samples,prob,acceptance,count) )
%%% param_names -   Names of the parameters (Cell array) used for plotting
%%% parent_figure - handle to the container to plot in
%%%
%%% Output parameters:
%%% samples     -   An (n x m)array of the drawn samples with dimension
%%%                 where n = nsamples and m = numel(parameters)
%%% prob        -   Vector of the sampled posterior density values
%%% acceptance  -   The total acceptance rate of the proposed steps.

%%% check whether to display plots or not
if nargin > 8
    Display = 1;
    if nargin < 11 %%% no parent figure specified
        parent_figure = [];
    end
else
    Display = 0;
end

%%% define global Stop variable to interrupt the algorithm by button press
global Stop Pause 
Stop = 0;
Pause = 0;
%%% randomize the seed for the random number generator
rng('shuffle')

%%% initialize output variables
samples = zeros(nsamples,size(initial_parameters,1));
samples(1,:) = initial_parameters;
prob = zeros(nsamples,1);
acceptance = 0;

%%% evaluate the prior and the posterior at the initial position
Posterior_old = probfun(initial_parameters);
Prior_old = priorfun(initial_parameters);
prob(1) = Posterior_old;

%%% initialize loop variables and parameters
count = 1; %%% the number of attempted steps
acc = 0;   %%% the number of successfull steps

%%% Initalize plots
if Display ~= 0
    parent_figure = UpdatePlot(samples,prob,acc,count,plot_params,param_names,parent_figure);
end
%%% Start while loop
%%% Loop stops if the number of samples was drawn or STOP was pressed
while count < (nsamples) && (Stop == 0)
    if Pause == 1
        handles = guidata(gcf);
        waitfor(handles.bayesian.button_pause,'UserData',0);
    end
    %%% draw new parameters
    param = samples(count,:);
    param(~fixed) = normrnd(samples(count,(~fixed)),sigma_prop(~fixed));
    %%% increase count variable
    count = count + 1;
    %%% Apply boundaries but recycle random numbers (reflecting boundary)
    param(param < lb) = 2*lb(param < lb) - param(param < lb);
    param(param > ub) = 2*ub(param > ub) - param(param > ub);
    
    %%% First evaluate the prior ratio#
    prior_accepted = 0;
    Prior_new = priorfun(param);
    ratio_prior = exp(Prior_new-Prior_old);
    if ratio_prior >= 1
        %%% step accepted by priors
        prior_accepted = 1;
    elseif ratio_prior > 0
        %%% evaluate binomial
        prior_accepted = binornd(1,ratio_prior);
    end
    
    %%% continue if the markov step was accepted according to the priors
    if prior_accepted == 1
        %%% only now evaluate the actual posterior density
        post_accepted = 0;
        Posterior_new = probfun(param);
        ratio_post = exp(Posterior_new-Posterior_old);
        if ratio_post >= 1
            %%% accept the step
            post_accepted = 1;
        elseif ratio_post > 0
            post_accepted = binornd(1,ratio_post);
        end
        
        %%% update values if the step was accepted
        if post_accepted == 1
            Prior_old = Prior_new;
            Posterior_old = Posterior_new;
            acc = acc +1;
            samples(count,:) = param;
            prob(count) = Posterior_new;
            acceptance = acc/count;
            if (Display ~= 0) && (mod(count,100) == 0)
                UpdatePlot(samples,prob,acceptance,count,plot_params,param_names,parent_figure);
            end
        else %%% value not accepted based on posterior, keep old value
            samples(count,:) = samples(count-1,:);
            prob(count) = prob(count-1);
            acceptance = acc/count;
            if (Display ~= 0) && (mod(count,100) == 0)
                UpdatePlot(samples,prob,acceptance,count,plot_params,param_names,parent_figure);
            end
        end
    else %%% value not accepted based on prior, keep old value
        samples(count,:) = samples(count-1,:);
        prob(count) = prob(count-1);
        acceptance = acc/count;
        if (Display ~= 0) && (mod(count,100) == 0)
            UpdatePlot(samples,prob,acceptance,count,plot_params,param_names,parent_figure);
        end
    end
end

%%% erase empty values from samples and prob output vectors if STOP was
%%% pressed
if Stop == 1
    samples( (count+1):end, :) = [];
    prob( (count+1):end) = [];
end

function parent_figure = UpdatePlot(samples,prob,acceptance,count,plot_params,param_names,parent_figure)
global UserValues
%%% initializes or updates plot to show the chain progress
n_param = sum(plot_params);

%h = findobj('Tag','MCMC_Plot');
if count == 1 %isempty(h) %%% create new figure, depending on the model
    %%% initialize plots
    if isempty(parent_figure)
        %%% create a figure
        parent_figure = figure('Tag','MCMC_Plot','Units','normalized','Position',[0.2 0.1 0.6 0.8],'Color',UserValues.Look.Back);
        whitebg(parent_figure, UserValues.Look.Axes);
    else
        handles = guidata(parent_figure);
        delete(parent_figure.Children);
    end
    %%% distribute plots in two columns and ceil((n_param+1)/2) rows (+1
    %%% for p plot)
    n_rows = ceil((n_param+1)/2);
    h = subplot(n_rows,2,1,'Parent',parent_figure,'nextplot','add');
    handles.bayesian.plot_p = plot(h,prob(1:count));
    h.XColor = UserValues.Look.Fore;
    h.YColor = UserValues.Look.Fore;
    h.GridAlpha = 0.5; h.FontSize = 12; h.LineWidth = UserValues.Look.AxWidth; h.XGrid = 'on'; h.YGrid = 'on';h.Box = 'on';
    h.YLabel.String = 'log likelihood'; h.YLabel.Color = UserValues.Look.Fore;
    j = 1;
    for i = 1:numel(plot_params)
        if plot_params(i)
            h = subplot(n_rows,2,j+1,'Parent',parent_figure,'nextplot','add');
            h.XColor = UserValues.Look.Fore;
            h.YColor = UserValues.Look.Fore;
            h.GridAlpha = 0.5; h.FontSize = 12; h.LineWidth = UserValues.Look.AxWidth; h.XGrid = 'on'; h.YGrid = 'on';h.Box = 'on';
            handles.bayesian.plot_param(j) = plot(h,samples(1:count,j));
            h.YLabel.String = param_names(i); h.YLabel.Color = UserValues.Look.Fore;
            j = j+1;
        end
    end
    handles.bayesian.button_stop = uicontrol('Style','pushbutton','Parent',parent_figure,'Units','normalized',...
        'Position',[0.01 0.01 0.1 0.05],'Callback',@StopCallback,'String','Stop','ForegroundColor',UserValues.Look.Fore,'BackgroundColor',UserValues.Look.Control);
    handles.bayesian.button_pause = uicontrol('Style','pushbutton','Parent',parent_figure,'Units','normalized','UserData',0,...
        'Position',[0.12 0.01 0.1 0.05],'Callback',@PauseCallback,'String','Pause','ForegroundColor',UserValues.Look.Fore,'BackgroundColor',UserValues.Look.Control);
    handles.bayesian.text = uicontrol('Style','text','String','acceptance ratio = 0','Units','normalized','Position',[0.8 0 0.2 0.05],'Parent',parent_figure,'ForegroundColor',UserValues.Look.Fore,'BackgroundColor',UserValues.Look.Back,'FontSize',12);
    handles.bayesian.text_time = uicontrol('Style','text','String','est. time remaining: 0 min','Units','normalized','Position',[0.6 0 0.2 0.05],'Parent',parent_figure,'ForegroundColor',UserValues.Look.Fore,'BackgroundColor',UserValues.Look.Back,'FontSize',12);
    drawnow;
    %%% save handles structure to guidata
    guidata(parent_figure,handles);
    %%% start timer to estimate remaining time
    tic;
    handles.bayesian.text_time.UserData = 0;
else
    handles = guidata(parent_figure);
    %%% update plots
    handles.bayesian.plot_p.YData = prob(1:count);
    j = 1;
    for i = 1:numel(plot_params)
        if plot_params(i)
            handles.bayesian.plot_param(j).YData = samples(1:count,i);
            j = j+1;
        end
        
    end
    handles.bayesian.text.String = sprintf('acceptance ratio = %.4f',acceptance);
    
    %%% estimate remaining time
    time = toc;
    handles.bayesian.text_time.UserData = handles.bayesian.text_time.UserData + time; % sum up time
    handles.bayesian.text_time.String = sprintf('est. time remaining: %.1f min',handles.bayesian.text_time.UserData.*(size(samples,1)-count)./count./60);
    tic; %restart timer
    drawnow;
end 

function StopCallback(~,~)
global Stop
Stop = 1;
drawnow;

function PauseCallback(obj,~)
global Pause
if obj.UserData == 0
    obj.UserData = 1;
    Pause = 1;
    obj.String = 'Resume';
else
    obj.UserData = 0;
    Pause = 0;
    obj.String = 'Pause';
end
drawnow;

