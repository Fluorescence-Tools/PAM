function [samples,prob,acc] =  MWGsample(nsamples,probfun,priorfun,sigma_prop,lb,ub,initial_parameters,fixed,plot_params,param_names)
%%% Performs Metropolis-Within-Gibbs-Sampling of posterior distribution
%%% (also called block-wise Metropolis and similar things)
%%% Input parameters:
%%% nsamples    -   Number of Samples to draw
%%% probfun     -   funtion handle to the posterior density function,
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
%%% model_type  -   The type of the model in a string:
%%%                 'SR'        (Single Ratio)
%%%                 '1Gauss'    (Single Gauss)
%%%                 '2Gauss'    (Two Gaussian)
%%%                 If left empty, no plot will be displayed.
%%% initial_parameters - Vector of start parameters.
%%% fixed       -   logical array specifying which parameters to vary
%%% plot_param  -   logical array of parameter values to plot each
%%%                 iteration
%%%                 (uses plotfun(samples,prob,acceptance,count) )
%%% param_names -   Names of the parameters (Cell array) used for plotting

%%%
%%% Output parameters:
%%% samples     -   An (n x m)array of the drawn samples with dimension
%%%                 where n = nsamples and m = numel(parameters)
%%% prob        -   Vector of the sampled posterior density values
%%% acceptance  -   The total acceptance rate of the proposed steps.

%%% check whether to display plots or not
if nargin < 8
    Display = 0;
else
    Display = 1;
end

%%% define global Stop variable to interrupt the algorithm by button press
global Stop
Stop = 0;
%%% randomize the seed for the random number generator
rng('shuffle')
%%% read out number of parameters
nparam = numel(initial_parameters);

%%% initialize output variables
samples = zeros(nsamples,size(initial_parameters,2));
samples(1,:) = initial_parameters;
prob = zeros(nsamples,1);
param = initial_parameters;

%%% evaluate the prior and the posterior at the initial position
Posterior_old = probfun(initial_parameters);
Prior_old = priorfun(initial_parameters);
prob(1) = Posterior_old;

%%% initialize loop variables and parameters
count = 1; %%% the number of sattempted teps
acc = zeros(nparam,1);   %%% the number of successfull steps

%%% Initalize plots
if Display ~= 0
    UpdatePlot(samples,prob,acc,count,plot_params,param_names);
end

%%% Parameter order will be randomized in every step of the Gibbs sampler
order = [1:nparam];
%%% Start while loop
%%% Loop stops if the number of samples was drawn or STOP was pressed
while count < (nsamples) && (Stop == 0)
    %%% increase count variable
    count = count + 1;
    %%% randomize the order
    order = order(randperm(nparam));
    %%% copy the samples vector to the new chain position
    samples(count,:) = samples(count-1,:);
    for k = 1:nparam %%% loop through parameters, sample them one by one
        %%% draw new value for one parameter
        param = samples(count,:); %%% this contains already all the changes made to the other parameters
        param(order(k)) = normrnd(samples(count,order(k)),sigma_prop(order(k))); %%% here, a new value is drawn
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

            %%% update parameter value if the step was accepted
            %%% (Don't update the total vector of samples yet!)
            if post_accepted == 1
                Prior_old = Prior_new;
                Posterior_old = Posterior_new;
                acc(order(k)) = acc(order(k)) +1;
                %%% update samples vector
                samples(count,order(k)) = param(order(k));
                prob(count) = Posterior_new;
            end
        end
    end
    %%% if no value was accepted, keep the old values
    if prob(count) == 0
        prob(count) = Posterior_old;
        samples(count,:) = samples(count-1,:);
    end
    %%% Now update the Display
    acceptance = mean(acc)/count;
    if Display ~= 0
        UpdatePlot(samples,prob,acceptance,count,plot_params,param_names);
    end
end

%%% erase empty values from samples and prob output vectors if STOP was
%%% pressed
if Stop == 1
    samples( (count+1):end, :) = [];
    prob( (count+1):end) = [];
end

function UpdatePlot(samples,prob,acceptance,count,plot_params,param_names)
%%% initializes or updates plot to show the chain progress
n_param = sum(plot_params);

h = findobj('Tag','MCMC_Plot');
if isempty(h) %%% create new figure, depending on the model
    %%% initialize plots
    handles.Figure=figure('Tag','MCMC_Plot','Units','normalized','Position',[0.2 0.1 0.6 0.8]);
    %%% distribute plots in two columns and ceil((n_param+1)/2) rows (+1
    %%% for p plot)
    n_rows = ceil((n_param+1)/2);
    subplot(n_rows,2,1);
    handles.plot_p = plot(prob(1:count));
    ylabel('log likelihood');
    j = 1;
    for i = 1:numel(plot_params)
        if plot_params(i)
            subplot(n_rows,2,j+1);
            handles.plot_param(j) = plot(samples(1:count,j));
            ylabel(param_names(i));
            j = j+1;
        end
    end
    handles.button = uicontrol('Style','pushbutton','Parent',handles.Figure,'Units','normalized',...
        'Position',[0 0 0.1 0.1],'Callback',@StopCallback,'String','Stop');
    handles.text = uicontrol('Style','text','String','0','Units','normalized','Position',[0.9 0 0.1 0.05]);
    drawnow;
    %%% save handles structure to guidata
    guidata(gcf,handles);
else
    handles = guidata(gcf);
    %%% update plots
    handles.plot_p.YData = prob(1:count);
    j = 1;
    for i = 1:numel(plot_params)
        if plot_params(i)
            handles.plot_param(j).YData = samples(1:count,i);
            j = j+1;
        end
        
    end
    handles.text.String = num2str(acceptance);
    drawnow;
end 

function StopCallback(~,~)
global Stop
Stop = 1;
drawnow;
