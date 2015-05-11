function [samples,prob,acceptance] =  MHsample(nsamples,probfun,priorfun,sigma_prop,lb,ub,initial_parameters,Display)
%%% Performs Metropolis-Hastings-Sampling of posterior distribution
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
%%% plotfun     -   optional plot function:
%%%                 plotfun(samples,prob,acceptance,count)
%%%
%%% Output parameters:
%%% samples     -   An (n x m)array of the drawn samples with dimension
%%%                 where n = nsamples and m = numel(parameters)
%%% prob        -   Vector of the sampled posterior density values
%%% acceptance  -   The total acceptance rate of the proposed steps.

%%% check whether to display plots or not
if isempty(Display)
    Display = 0;
end
%%% define global Stop variable to interrupt the algorithm by button press
global Stop
Stop = 0;
%%% randomize the seed for the random number generator
rng('shuffle')

%%% initialize output variables
samples = zeros(nsamples,size(initial_parameters,2));
samples(1,:) = initial_parameters;
prob = zeros(nsamples,1);

%%% evaluate the prior and the posterior at the initial position
Posterior_old = probfun(initial_parameters);
Prior_old = priorfun(initial_parameters);
prob(1) = Posterior_old;

%%% initialize loop variables and parameters
count = 1; %%% the number of sattempted teps
acc = 0;   %%% the number of successfull steps

%%% Initalize plots
if Display ~= 0
    UpdatePlot(samples,prob,0,1,Display);
end
%%% Start while loop
%%% Loop stops if the number of samples was drawn or STOP was pressed
while count < (nsamples) && (Stop == 0)
    %%% draw new parameters
    param = normrnd(samples(count,:),sigma_prop);
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
            if Display ~= 0
                UpdatePlot(samples,prob,acceptance,count,Display);
            end
        else %%% value not accepted based on posterior, keep old value
            samples(count,:) = samples(count-1,:);
            prob(count) = prob(count-1);
            acceptance = acc/count;
            if Display ~= 0
                UpdatePlot(samples,prob,acceptance,count,Display);
            end
        end
    else %%% value not accepted based on prior, keep old value
        samples(count,:) = samples(count-1,:);
        prob(count) = prob(count-1);
        acceptance = acc/count;
        if Display ~= 0
            UpdatePlot(samples,prob,acceptance,count,Display);
        end
    end
end

%%% erase empty values from samples and prob output vectors if STOP was
%%% pressed
if Stop == 1
    samples( (count+1):end, :) = [];
    prob( (count+1):end) = [];
end

function UpdatePlot(samples,prob,acceptance,count,Display)
%%% initializes or updates plot to show the chain progress

%%% check whether to display at all
if Display == 0
    return;
end

switch Display
    case '1Gauss'
        %%% check if a figure exists
        h = findobj('Tag','MHplot_1Gauss');
        if isempty(h) %%% create new figure, depending on the model
            %%% initialize plots
            handles.Figure=figure('Tag',Display); 
            subplot(3,3,[1 2 3]);
            handles.plot_p = plot([prob(1:count)]);
            subplot(3,3,4);
            handles.plot_r = plot([samples(1:count,1)]);
            subplot(3,3,7);
            handles.plot_s = plot([samples(1:count,2)]);
            subplot(3,3,[ 5 6 8 9])
            handles.plot_rs = scatter(samples(1:count,1),samples(1:count,2),'filled');
            handles.button = uicontrol('Style','pushbutton','Parent',handles.Figure,'Units','normalized',...
                'Position',[0 0 0.1 0.1],'Callback',@StopCallback,'String','Stop');
            handles.text = uicontrol('Style','text','String','0','Units','normalized','Position',[0.9 0 0.1 0.05]);
            drawnow;
            %%% save handles structure to guidata
            guidata(gcf,handles);
        else
            handles = guidata(gcf);
             %%% update plots
            handles.plot_p.YData = prob;
            handles.plot_r.YData = samples(1:count,1);
            handles.plot_s.YData = samples(1:count,2);
            handles.plot_rs.XData = samples(1:count,1);
            handles.plot_rs.YData = samples(1:count,2);
            handles.text.String = num2str(acceptance);
            %plot_rs.CData = linspace(1,10,count);
            drawnow;
        end
    case '2Gauss'
        %%% check if a figure exists
        h = findobj('Tag',Display);
        if isempty(h) %%% create new figure, depending on the model
            %%% initialize plots
            handles.Figure=figure('Tag',Display); 
            subplot(3,3,[1 2]);
            handles.plot_p = plot([prob(1:count)]);
            subplot(3,3,3);
            handles.plot_a = plot([samples(1:count,5)]);
            subplot(3,3,4);
            handles.plot_r1 = plot([samples(1:count,1)]);hold on;
            handles.plot_r2 = plot([samples(1:count,3)]);hold off;
            subplot(3,3,7);
            handles.plot_s1 = plot([samples(1:count,2)]);hold on;
            handles.plot_s2 = plot([samples(1:count,4)]);hold off;
            subplot(3,3,[ 5 6 8 9])
            handles.plot_r1s1 = scatter(samples(1:count,1),samples(1:count,2),'b','filled');hold on;
            handles.plot_r2s2 = scatter(samples(1:count,3),samples(1:count,4),'r','filled');hold off;
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
            handles.plot_r1.YData = samples(1:count,1);
            handles.plot_s1.YData = samples(1:count,2);
            handles.plot_r1s1.XData = samples(1:count,1);
            handles.plot_r1s1.YData = samples(1:count,2);
            handles.plot_r2.YData = samples(1:count,3);
            handles.plot_s2.YData = samples(1:count,4);
            handles.plot_r2s2.XData = samples(1:count,3);
            handles.plot_r2s2.YData = samples(1:count,4);
            handles.plot_a.YData = samples(1:count,5);
            %plot_rs.CData = linspace(1,10,count);
            handles.text.String = num2str(acceptance);
            drawnow;
        end 
    case 'tcPDA_mcmc'
        %%% check if a figure exists
        h = findobj('Tag',Display);
        if isempty(h) %%% create new figure, depending on the model
            %%% initialize plots
            handles.Figure=figure('Tag',Display); 
            subplot(2,4,[1 5]);
            handles.plot_p = plot([prob(1:count)]);
            subplot(2,4,2);
            handles.plot_rbg = plot([samples(1:count,1)]);
            subplot(2,4,3);
            handles.plot_rbr = plot([samples(1:count,3)]);
            subplot(2,4,4);
            handles.plot_rgr = plot([samples(1:count,5)]);
            subplot(2,4,6);
            handles.plot_sbg = plot([samples(1:count,2)]);
            subplot(2,4,7);
            handles.plot_sbr = plot([samples(1:count,4)]);
            subplot(2,4,8);
            handles.plot_sgr = plot([samples(1:count,6)]);
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
            handles.plot_rbg.YData = samples(1:count,1);
            handles.plot_sbg.YData = samples(1:count,2);
            handles.plot_rbr.YData = samples(1:count,3);
            handles.plot_sbr.YData = samples(1:count,4);
            handles.plot_rgr.YData = samples(1:count,5);
            handles.plot_sgr.YData = samples(1:count,6);
            handles.text.String = num2str(acceptance);
            drawnow;
        end 
end

function StopCallback(~,~)
global Stop
Stop = 1;
drawnow;
