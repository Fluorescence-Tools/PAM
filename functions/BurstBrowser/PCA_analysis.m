function PCA_analysis(obj,~)
global BurstData
h = guidata(obj);
%%% Perform Principal Component Analysis to find differences between data
%%% sets and indentify parameters with high variance/differences between
%%% data sets, i.e. "sensitive" parameters.

%%% get selection of species list
[file_n,species_n,subspecies_n,sel] = get_multiselection(h);
%%% read out data
datatoplot = cell(numel(file_n),1);
for i = 1:numel(file_n)
    [~,datatoplot{i}] = UpdateCuts([species_n(i),subspecies_n(i)],file_n(i));
end

%%% PCA analysis on multiple data sets
%%% pooling of all data sets to generate joint principal components
%%% parameters: E,S,tauD,tauA,rD,rA,(ALEX2CDE,FRET2CDE,Duration,NumberOfPhotons)
param = [1,2,5,6,7,8];%,10,12];%,13,15]; (Better: read out parameter indices from name array)
data = vertcat(datatoplot{:});
for i = 1:numel(datatoplot)
    n(i)=size(datatoplot{i},1);
end
id = [];
for i = 1:numel(n)
    id = [id, i*ones(1,n(i))];
end
data_val = data(:,param);
%%% transform to z scores
%%% z = (x-mean)/sigma
data_val = (data_val-repmat(mean(data_val,1),size(data_val,1),1))./repmat(std(data_val,0,1),size(data_val,1),1);
data_val(isnan(data_val)) = 0;
[coeff,score,latent] = pca(data_val);

%%% do thresholding on PC1 and PC2
val = true(size(score,1),1);
alpha = 0.3; %99.7 percentile, i.e. 3 sigma
val = val & (score(:,1) > prctile(score(:,1),alpha/2)) &...
    (score(:,1) < prctile(score(:,1),100-alpha/2)) &...
    (score(:,2) > prctile(score(:,2),alpha/2)) &...
    (score(:,2) < prctile(score(:,2),100-alpha/2));

data_val = data_val(val,:);
id_val = id(val);
[coeff,score,latent] = pca(data_val);

%%% plot in different colors
f = figure('Units','pixel','Position',[100,100,1000,400],'Color',[1,1,1]);
ax(1) = subplot(1,2,1);
hold on;
color = lines(numel(datatoplot));
%%% define scatter colors
scat_col = color(id_val,:);
%%% randomize scatter data clouds
order = randperm(size(score,1));
scatter(score(order,1),score(order,2),10,scat_col(order,:),'Marker','.','MarkerFaceColor',color(i,:));
for i = 1:numel(datatoplot)
    p(i) = plot(mean(score(id_val==i,1)),mean(score(id_val==i,2)),'o','MarkerFaceColor',color(i,:),'MarkerEdgeColor','k','MarkerSize',10);
end
xlabel('PC1');ylabel('PC2');
axis('tight');
%%% add legend
[file_n,species_n,subspecies_n,sel] = get_multiselection(h);
num_species = numel(file_n);
str = cell(num_species,1);
for i = 1:num_species
    %%% extract name
    name = BurstData{file_n(i)}.FileName;
    if (species_n(i) ~= 0)
        if (subspecies_n(i) ~= 1) %%% we have a subspecies selected
            name = [name,'/', char(sel(i).getParent.getName),'/',char(sel(i).getName)];
        else %%% we have a species selected 
            name = [name,'/', char(sel(i).getName)];
        end
    end
    str{i} = strrep(name,'_',' ');  
end
hl = legend(p,str,'Interpreter','none','FontSize',12,'Box','off','Color','none');

ax(2) = subplot(1,2,2);
b = bar(coeff(:,1:2));hl2 = legend('PC1','PC2');set(hl2,'Color','none','Box','off');
b(1).FaceColor = [0.7,0.7,0.7];
b(2).FaceColor = [0.3,0.3,0.3];
set(gca,'XTickLabel',{'E','S','\tau_{D(A)}','\tau_A','r_D','r_A'});
ylabel('weight');
xlim([0.5,6.5]);

c = get(f,'Children');
for i = 1:numel(c)
    c(i).Units = 'pixel';
    c(i).Position(2) = c(i).Position(2) + 10;
end
f.Position(4) = f.Position(4)+50;
FontSize = 14; if ispc; FontSize = FontSize/1.25;end
set(ax,'FontSize',FontSize);
set(ax,'Color',[1,1,1]);
hl.Position(2) = ax(1).Position(2)+ax(1).Position(4)+10;