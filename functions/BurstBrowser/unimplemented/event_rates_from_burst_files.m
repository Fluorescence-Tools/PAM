%% parameters for script
save_plots = true;
pore_size = [24,33;38,47;39,49;48,58;57,68];
pore_size = mean(pore_size,2);
warning off export_fig:exportgraphics
%% get data and generate table
global BurstData
if isempty(BurstData)
    disp('Load some data first.');
    return;
end
fn = cell(numel(BurstData),1);
dur = zeros(numel(BurstData),1);
rates = zeros(numel(BurstData),2);
for i = 1:numel(BurstData)
    % get name
    fn{i} = BurstData{i}.FileNameSPC;
    % get measurement duration
    dur(i) = BurstData{i}.FileInfo.MeasurementTime;
    % get events detected in the different channels
    for j = 1:2
        rates(i,j) = sum(BurstData{i}.DataArray(:,strcmp(BurstData{i}.NameArray,'Detected Channel'))==j)./dur(i);
    end
end
filename = fn;
duration = dur;
rate_channel1 = rates(:,1);
rate_channel2 = rates(:,2);

%% try to infer additional metadata from filenames
concentration = zeros(numel(BurstData),1);
analyte = cell(numel(BurstData),1);
pore_number = zeros(numel(BurstData),1);
for i = 1:numel(BurstData)
    % get analyte (Kap, BSA, or both)
    if contains(filename{i},'bsa','IgnoreCase',true) && contains(filename{i},'kap','IgnoreCase',true)
        analyte{i} = 'Kap+BSA';
    elseif contains(filename{i},'bsa','IgnoreCase',true)
        analyte{i} = 'BSA';
    elseif contains(filename{i},'kap','IgnoreCase',true)
        analyte{i} = 'Kap';
    else
        analyte{i} = '-';
    end
    if contains(filename{i},'wash','IgnoreCase',true)
        analyte{i} = ['wash (after ' analyte{i} ')'];
    end
    % get concentration of analyte
    % check if there is a concentration specified
    if contains(filename{i},'nm','IgnoreCase',true) % nm or nM is specified
        if contains(filename{i},'nm')
            pat = digitsPattern + 'nm';
        elseif contains(filename{i},'nM')
            pat = digitsPattern + 'nM';
        end
        c = extract(extract(filename{i},pat),digitsPattern);
        concentration(i) = str2double(c{1});
    else
        concentration(i) = NaN;
    end
    % get pore number
    if contains(filename{i},'pore','IgnoreCase',true)
        pat = 'pore' + digitsPattern;
        n = extract(extract(filename{i},pat),digitsPattern);
        pore_number(i) = str2double(n{1});
    else
        pore_number(i) = NaN;
    end
end
%% save event rates as a table
data = table(filename,pore_number,analyte,concentration,rate_channel1,rate_channel2,duration);
% sort according to concentration, analyte, pore number
data = sortrows(data,{'pore_number','analyte','concentration'});

%% do some further analysis and plotting (fitting of event rate / nM for each pore)
save_plot = true;
foldername = [fileparts(BurstData{1}.PathName) filesep 'results_' date];
if ~exist(foldername,'dir')
    mkdir(foldername);
end
% save data (use parent folder name as file name)
[~,parent_folder] = fileparts(fileparts(BurstData{1}.PathName));
writetable(data,[foldername filesep parent_folder '.xlsx'],'Sheet','Event Rates');
%% first, plot the result as bar plot
% format labels
labels = {};
for i = 1:numel(data.analyte)
    if ~contains(data.analyte{i},'wash')   
        labels{i} = sprintf('pore %d - %s %d nM',data.pore_number(i),data.analyte{i},data.concentration(i));
    else
        labels{i} = sprintf('pore %d - %s',data.pore_number(i),data.analyte{i});
    end
    if i > 1
        % check for duplicates
        if any(strcmp(labels{i},labels(1:i-1)))
            labels{i} = [labels{i} '\_1'];
        end
        c = 2;
        while any(strcmp(labels{i},labels(1:i-1)))
            labels{i}(end) = num2str(c);
            c = c+1;
        end
    end
end
f = figure('Position',[50,50,1000,600],'Color',[1,1,1]); hold on;
bar([data.rate_channel1,data.rate_channel2],'BarWidth',1,'LineWidth',1);
set(gca,'XTick',1:numel(labels),'XTickLabel',labels);
set(gca,'TickDir','out','Box','off','XTickLabelRotation',-90,'LineWidth',1.5,'FontSize',14,'Color',[1,1,1]);
ylabel('event rate (Hz)');
% add vertical dashed lines to indicate the different pores
for i = unique(pore_number)'
    xline(find(data.pore_number==i,1,'last')+0.5,'LineStyle','--');
end
legend({'Kap','BSA'},'EdgeColor','none');

% save
if save_plots
    export_fig([foldername filesep 'overview.fig']);
    export_fig([foldername filesep 'overview.png'],'-r300','-painters');
    export_fig([foldername filesep 'overview.pdf']);
    delete(f);
end
%%
for i = unique(pore_number)'
    % estimate the slopes
    bsa_idx = strcmp(analyte,'BSA') & pore_number == i;
    rates_BSA = rate_channel2(bsa_idx); c_BSA = concentration(bsa_idx);
    %fit(c,BSA_rates,@(a,x) a*x,'StartPoint',1);
    slope_BSA(i) = sum(c_BSA.*rates_BSA)/sum(c_BSA.^2);
 
    kap_idx = strcmp(analyte,'Kap') & pore_number == i;
    rates_Kap = rate_channel1(kap_idx); c_Kap = concentration(kap_idx);
    slope_Kap(i) = sum(c_Kap.*rates_Kap)/sum(c_Kap.^2);
    
    kap_bsa_idx = strcmp(analyte,'Kap+BSA') & pore_number == i;
    rates_Kap_BSA = rate_channel1(kap_bsa_idx);
    rates_BSA_Kap = rate_channel2(kap_bsa_idx);
    c_Kap_BSA = concentration(kap_bsa_idx);
    slope_Kap_BSA(i) = sum(c_Kap_BSA.*rates_Kap_BSA)/sum(c_Kap_BSA.^2);
    slope_BSA_Kap(i) = sum(c_Kap_BSA.*rates_BSA_Kap)/sum(c_Kap_BSA.^2);
    

    colors = lines(2);
    c = 0:1:max(concentration)*1.1;
    %%% prepare plots of each rate-concentation dependence with fit
    % BSA
    f = figure('Position',[50,50,500,400],'Color',[1,1,1]); hold on;
    % first fits
    p = [];
    plot(c,c*slope_BSA(i),'-','Color',colors(2,:),'LineWidth',1.5);
    plot(c,c*slope_Kap(i),'-','Color',colors(1,:),'LineWidth',1.5);
    plot(c,c*slope_BSA_Kap(i),'--','Color',colors(2,:),'LineWidth',1.5);
    plot(c,c*slope_Kap_BSA(i),'--','Color',colors(1,:),'LineWidth',1.5);        
    % then data
    p(end+1) = scatter(c_BSA,rates_BSA,100,'o','filled','MarkerFaceColor',colors(2,:),'MarkerEdgeColor',[0,0,0],'LineWidth',1);
    p(end+1) = scatter(c_Kap,rates_Kap,100,'o','filled','MarkerFaceColor',colors(1,:),'MarkerEdgeColor',[0,0,0],'LineWidth',1);
    p(end+1) = scatter(c_Kap_BSA,rates_BSA_Kap,100,'o','MarkerFaceColor','none','MarkerEdgeColor',colors(2,:),'LineWidth',1);
    p(end+1) = scatter(c_Kap_BSA,rates_Kap_BSA,100,'o','MarkerFaceColor','none','MarkerEdgeColor',colors(1,:),'LineWidth',1);

    set(gca,'Box','on','LineWidth',1.5,'FontSize',18,'Color',[1,1,1]);
    title(sprintf('pore #%d',i));
    ylabel('event rate (Hz)');
    xlabel('protein concentration (nM)');
    axis('tight');
    legend(p,{'BSA','Kap','BSA (Kap)','Kap (BSA)'},'Location','northwest','EdgeColor','none');
    if save_plots    
        % save plots
        export_fig([foldername filesep sprintf('event_rates_pore%d.fig',i)]);
        export_fig([foldername filesep sprintf('event_rates_pore%d.png',i)],'-r300','-painters');
        export_fig([foldername filesep sprintf('event_rates_pore%d.pdf',i)]);
        delete(f);
    end
end
slope_BSA(isnan(slope_BSA)) = 0;
slope_Kap(isnan(slope_Kap)) = 0;
slope_BSA_Kap(isnan(slope_BSA_Kap)) = 0;
slope_Kap_BSA(isnan(slope_Kap_BSA)) = 0;
%% prepare plot of rates vs pores
if isempty(pore_size)
    pore_size = unique(pore_number);
end
f = figure('Position',[50,50,500,400],'Color',[1,1,1]); hold on;
plot(pore_size,slope_BSA,'Color',colors(2,:),'LineWidth',1.5);
plot(pore_size,slope_Kap,'Color',colors(1,:),'LineWidth',1.5);
plot(pore_size,slope_BSA_Kap,'--','Color',colors(2,:),'LineWidth',1.5);
plot(pore_size,slope_Kap_BSA,'--','Color',colors(1,:),'LineWidth',1.5);
p = [];
p(end+1) = scatter(pore_size,slope_BSA,100,'o','filled','MarkerFaceColor',colors(2,:),'MarkerEdgeColor',[0,0,0],'LineWidth',1);
p(end+1) = scatter(pore_size,slope_Kap,100,'o','filled','MarkerFaceColor',colors(1,:),'MarkerEdgeColor',[0,0,0],'LineWidth',1);
p(end+1) = scatter(pore_size,slope_BSA_Kap,100,'o','MarkerFaceColor','none','MarkerEdgeColor',colors(2,:),'LineWidth',1);
p(end+1) = scatter(pore_size,slope_Kap_BSA,100,'o','MarkerFaceColor','none','MarkerEdgeColor',colors(1,:),'LineWidth',1);

set(gca,'Box','on','LineWidth',1.5,'FontSize',18,'Color',[1,1,1]);
ylabel('event rate per nM (s^{-1}nM^{-1})');
xlabel('pore diameter (nm)');
legend(p,{'BSA','Kap','BSA (Kap)','Kap (BSA)'},'Location','northwest','EdgeColor','none');

if save_plots    
    % save plots
    export_fig([foldername filesep 'event_rates_vs_pore_size.fig']);
    export_fig([foldername filesep 'event_rates_vs_pore_size.png'],'-r300','-painters');
    export_fig([foldername filesep 'event_rates_vs_pore_size.pdf']);
    delete(f);
end