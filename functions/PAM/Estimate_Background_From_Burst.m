%%% Estimates background count rates from burst experiment using
%%% exponential tail fit to interphoton time distribution
%%% see Ingargiola, A. et al. PLoS ONE (2016) for more details
function Estimate_Background_From_Burst(~,~)
global UserValues TCSPCData FileInfo

% get subfunction from PAM
Get_Photons_from_PIEChannel = PAM('Get_Photons_from_PIEChannel');

fontsize = 14;
if ispc
    fontsize = fontsize*0.7;
end

BAMethod = UserValues.BurstSearch.Method;
%%% get channels to estimate background for
chans = UserValues.BurstSearch.PIEChannelSelection{BAMethod}'; chans = chans(:);
%%% MLE for Poissonian errors
logL = @(x,xdata,ydata) sum(ydata.*log(ydata./(x(1).*exp(-xdata.*x(2)))) - ydata + x(1).*exp(-xdata.*x(2)) );
bg = zeros(1,numel(chans));
fig = figure('Color',[1,1,1],'Position',[100,100,600,250*ceil(numel(chans)/2)]);
for i = 1:numel(chans)
    %%% read out photons
    MT = Get_Photons_from_PIEChannel(chans{i},'Macrotime');
    MT = diff(MT).*FileInfo.ClockPeriod*1000; % convert to interphoton time and milliseconds
    % calculate histogram
    [hMT, dt] = hist(MT,0:.1:max(MT));
    valid = (dt>max(dt)/5) & (hMT >= 1);
    x0 = [hMT(1),3/max(dt)];
    x = fmincon(@(x) logL(x,dt(valid),hMT(valid)),x0,[],[],[],[],[0,0],[Inf,Inf]);
    model = x(1).*exp(-dt.*x(2));
    subplot(ceil(numel(chans)/2),2,i); hold on;
    scatter(dt,hMT,75,'.r'); plot(dt,model,'-k','LineWidth',2);
    xlabel('Interphoton time [ms]'); ylabel('#');
    set(gca,'Color',[1,1,1],'LineWidth',2,'YScale','log','Box','on','FontSize',fontsize);
    bg(i) = x(2);
    fprintf('Fitted channel %d of %d\n',i,numel(chans));
    
    %%% add residuals
    w_res = MLE_w_res(model(valid),hMT(valid)).*sign(hMT(valid)-model(valid));
    %%% add plot above
    ax = gca;
    ax_res = axes('Position',[ax.Position(1),ax.Position(2)+0.75*ax.Position(4),ax.Position(3),ax.Position(4)*0.25]);
    ax.Position(4) = ax.Position(4)*0.75;
    set(ax_res,'Color',[1,1,1],'LineWidth',2,'YScale','lin','Box','on','FontSize',fontsize); hold on;
    scatter(dt(valid),w_res,75,'.r');
    plot(ax.XLim,[0,0],'k-','LineWidth',2);
    ax_res.XTickLabel = [];
    title(sprintf('%s: %f kHz',chans{i},bg(i)));
end
disp('The estimated background count rates are:')
result = [chans,num2cell(bg')]';
fprintf('%s: %f kHz\n',result{:});
disp('Done estimating background count rates from burst experiment.');

%%% add button to figure to confirm overwriting of background count rates
bt = uicontrol('Style','pushbutton','parent',fig,'Units','normalized',...
    'Position',[0.8,0.01,0.19,0.04],'String','Save Result',...
    'BackgroundColor',[0.75,0.75,0.75],'FontSize',16,...
    'Callback',{@overwrite_background,bg});

function overwrite_background(~,~,bg)
global UserValues
%%% sort background into channels and update display
chans = UserValues.BurstSearch.PIEChannelSelection{UserValues.BurstSearch.Method}'; chans = chans(:);
%%% Store Background Counts in PIE subfield of UserValues structure (PIE.Background) in kHz
for i=1:numel(chans)%numel(UserValues.PIE.Name)
    c = find(strcmp(UserValues.PIE.Name,chans{i}));
    if isempty(UserValues.PIE.Combined{c})
        UserValues.PIE.Background(c) = bg(i);
    end
end

Update_Display = PAM('Update_Display');
LSUserValues(1);
Update_Display([],[],[1,8])

function w_res_MLE = MLE_w_res(model,data)
%%% Returns the weighted residuals based on Poissonian counting statistics,
%%% as described in Laurence TA, Chromy BA (2010) Efficient maximum likelihood estimator fitting of histograms. Nat Meth 7(5):338?339.
%%%
%%% The sum of the weighted residuals is then analogous to a chi2 goodness-of-fit estimator.

valid = true(size(data));

% filter zero bins in data to avoid divsion by zero and in model to avoid log(0)
valid = valid & (data ~= 0) & (model ~= 0);

% compute MLE residuals:
%
% chi2_MLE = 2 sum(data-model) -2*sum(data*log(model/data))
%
% For invalid bins, only compute the first summand.

log_summand = zeros(size(data));
log_summand(valid) = data(valid).*log(model(valid)./data(valid));
w_res_MLE = 2*(model - data) - 2*log_summand; %squared residuals
% avoid complex numbers
w_res_MLE(w_res_MLE < 0) = 0;
w_res_MLE = sqrt(w_res_MLE);