[~,NGR] = get_multiselection_data(h,'Number of Photons (DA)');
[~,NGG] = get_multiselection_data(h,'Number of Photons (DD)');
[~,NRR] = get_multiselection_data(h,'Number of Photons (AA)');

[~,dur] = get_multiselection_data(h,'Duration [ms]');
E_raw = cell(size(NGR));
S_raw = cell(size(NGR));
for i = 1:numel(NGR)
    NGR{i} = NGR{i} - Background_GR.*dur{i};
    NGG{i} = NGG{i} - Background_GG.*dur{i};
    NRR{i} = NRR{i} - Background_RR.*dur{i};
    NGR{i} = NGR{i} - BurstData{file}.Corrections.DirectExcitation_GR.*NRR{i} - BurstData{file}.Corrections.CrossTalk_GR.*NGG{i};
    E_raw{i} = NGR{i}./(NGR{i}+NGG{i});
    S_raw{i} = (NGG{i}+NGR{i})./(NGG{i}+NGR{i}+NRR{i});
end

g = 0.01:0.01:10;k = [];
for i = 1:numel(g);
    k(i) = KBL(g(i),1,[NGG{1},NGR{1},NRR{1}],[NGG{2},NGR{2},NRR{2}]);
end

%%% fit
fitGamma = fminsearch(@(x) KBL(x,S_raw{1},S_raw{2}),[1,1]);

