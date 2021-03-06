%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Does fFCS Correlation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Do_fFCS(obj,~)
global BurstMeta BurstData UserValues
if isempty(obj)
    h = guidata(findobj('Tag','BurstBrowser'));
else
    h = guidata(obj);
end
file = BurstMeta.SelectedFile;
isMFD = BurstData{file}.BAMethod < 5;
use_species3 = numel(BurstMeta.fFCS.hist_MIpar_Species) > 2;
%%% clear previous result
BurstMeta.fFCS.Result = struct;
BurstMeta.fFCS.Result.FileName = [];
BurstMeta.fFCS.Result.Header = [];
BurstMeta.fFCS.Result.Counts = [];
BurstMeta.fFCS.Result.Valid = [];
BurstMeta.fFCS.Result.Cor_Times = [];
BurstMeta.fFCS.Result.Cor_Average = [];
BurstMeta.fFCS.Result.Cor_SEM = [];
BurstMeta.fFCS.Result.Cor_Array = [];
BurstMeta.fFCS.Result.MetaData = [];
%%% Set Up Progress Bar
Progress(0,h.Progress_Axes,h.Progress_Text,'Correlating...');
%%% define channels
Name = {h.fFCS_Species1_popupmenu.String{h.fFCS_Species1_popupmenu.Value},...
        h.fFCS_Species2_popupmenu.String{h.fFCS_Species2_popupmenu.Value}};
if use_species3
    Name = [Name, {h.fFCS_Species3_popupmenu.String{h.fFCS_Species3_popupmenu.Value}}];
end
CorrMat = true(numel(Name));
NumChans = size(CorrMat,1);
%%% Read out photons and filters from BurstMeta
%MT_par = BurstMeta.fFCS.Photons.MT_total_par;
%MT_perp = BurstMeta.fFCS.Photons.MT_total_perp;
%MI_par = BurstMeta.fFCS.Photons.MI_total_par;
%MI_perp = BurstMeta.fFCS.Photons.MI_total_perp;
filters_par{1} = BurstMeta.fFCS.filters_par(1,:)';
filters_par{2} = BurstMeta.fFCS.filters_par(2,:)';
if use_species3
    filters_par{3} = BurstMeta.fFCS.filters_par(3,:)';
end
if isMFD
    filters_perp{1} = BurstMeta.fFCS.filters_perp(1,:)';
    filters_perp{2} = BurstMeta.fFCS.filters_perp(2,:)';
    if use_species3
        filters_perp{3} = BurstMeta.fFCS.filters_perp(3,:)';
    end
else
    filters_perp = filters_par;
end
count = 0;
for i=1:NumChans
    for j=1:NumChans
        if CorrMat(i,j)
            MT1 = BurstMeta.fFCS.Photons.MT_total_par;
            if isMFD
                MT2 = BurstMeta.fFCS.Photons.MT_total_perp;
            else
                MT2 = MT1;
            end
            MIpar = BurstMeta.fFCS.Photons.MI_total_par;
            if isMFD
                MIperp = BurstMeta.fFCS.Photons.MI_total_perp;
            else
                MIperp = MIpar;
            end
            if any(UserValues.BurstBrowser.Settings.fFCS_Mode == [1,2])
                inval = cellfun(@isempty,MT1) | cellfun(@isempty,MT2);
                MT1(inval) = []; MT2(inval) = [];
                MIpar(inval) = [];
                MIperp(inval) = [];
                %%% prepare weights
                Weights1 = cell(numel(MT1),1);
                Weights2 = cell(numel(MT1),1);
                for k = 1:numel(MT1)
                    Weights1{k} = filters_par{i}(MIpar{k});
                    Weights2{k} = filters_perp{j}(MIperp{k});
                end
                %%% Calculates the maximum inter-photon time in clock ticks
                Maxtime=cellfun(@(x,y) max([x(end) y(end)]),MT1,MT2);
                
                %%% Do Correlation
                [Cor_Array,Cor_Times]=CrossCorrelation(MT1,MT2,Maxtime,Weights1,Weights2,2);
                
                %%% estimate average count rates
                counts_per_channel = [sum(cellfun(@sum,Weights1)) sum(cellfun(@sum,Weights2))];
                duration = sum((cellfun(@(x,y) max(x(end),y(end)),MT1,MT2) - cellfun(@(x,y) min(x(1),y(1)),MT1,MT2))).*BurstData{file}.ClockPeriod;
                Counts = counts_per_channel./duration/1000; % average countrate in kHz
            elseif any(UserValues.BurstBrowser.Settings.fFCS_Mode == [3,4]) %%% Full correlation
                Weights1_dummy = filters_par{i}(MIpar);
                Weights2_dummy = filters_perp{j}(MIperp);
                Maxtime = max([MT1(end),MT2(end)]);
                %%% Split in 10 timebins
                Times = ceil(linspace(0,Maxtime,11));
                Data1 = cell(10,1);
                Data2 = cell(10,1);
                Weights1 = cell(10,1);
                Weights2 = cell(10,1);
                for k = 1:10
                    Data1{k} = MT1(MT1 >= Times(k) &...
                        MT1 <Times(k+1)) - Times(k);
                    Weights1{k} = Weights1_dummy(MT1 >= Times(k) &...
                        MT1 <Times(k+1));
                    Data2{k} = MT2(MT2 >= Times(k) &...
                        MT2 <Times(k+1)) - Times(k);
                    Weights2{k} = Weights2_dummy(MT2 >= Times(k) &...
                        MT2 <Times(k+1));
                end
                %%% Do Correlation
                [Cor_Array,Cor_Times]=CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2);
                
                %%% estimate average count rates
                counts_per_channel = [sum(cellfun(@sum,Weights1)) sum(cellfun(@sum,Weights2))];
                duration = sum(cellfun(@(x,y) max(x(end),y(end)),Data1,Data2)).*BurstData{file}.ClockPeriod;
                Counts = counts_per_channel./duration/1000; % average countrate in kHz  
            end
            Cor_Times = Cor_Times*BurstData{file}.ClockPeriod;
            
            %%% Calculates average and standard error of mean (without tinv_table yet
            if numel(Cor_Array)>1
                Cor_Average=mean(Cor_Array,2);
                Cor_SEM=std(Cor_Array,0,2);
            else
                Cor_Average=Cor_Array{1};
                Cor_SEM=Cor_Array{1};
            end
            
            %%% Save the correlation file
            %%% Generates filename
            filename = fullfile(BurstData{file}.PathName,BurstData{file}.FileName);
            Current_FileName=[filename(1:end-4) '_' Name{i} '_x_' Name{j}];
            switch UserValues.BurstBrowser.Settings.fFCS_Mode
                case {2} % burstwise with time window
                    Method = 'burstwise with time window';
                    Current_FileName=[Current_FileName '_tw_' sprintf('%d',UserValues.BurstBrowser.Settings.Corr_TimeWindowSize) 'ms' '.mcor'];
                case {1} % burstwise
                    Method = 'burstwise';
                    Current_FileName=[Current_FileName '_bw.mcor'];
                case {3} % total photon stream
                    Method = 'total photon stream';
                    Current_FileName=[Current_FileName '_ps.mcor'];
                case {4} % total photon stream + donor only
                    Method = 'total photon stream + donor only';
                    Current_FileName=[Current_FileName '_ps_donly.mcor'];
            end
            BurstMeta.fFCS.Result.FileName{end+1} = Current_FileName;
            BurstMeta.fFCS.Result.Header{end+1} = ['Correlation file for: ' strrep(filename,'\','\\') ' of Channels ' Name{i} ' cross ' Name{j}];
            BurstMeta.fFCS.Result.Counts{end+1} = Counts;%[0,0];
            BurstMeta.fFCS.Result.Valid{end+1} = 1:size(Cor_Array,2);
            BurstMeta.fFCS.Result.Cor_Times{end+1} = Cor_Times;
            BurstMeta.fFCS.Result.Cor_Average{end+1} = Cor_Average;
            BurstMeta.fFCS.Result.Cor_SEM{end+1} = Cor_SEM;
            BurstMeta.fFCS.Result.Cor_Array{end+1} = Cor_Array;
            %%% store additional meta data describing the species selection
            BurstMeta.fFCS.Result.MetaData{end+1} = BurstMeta.fFCS.MetaData;
            BurstMeta.fFCS.Result.MetaData{end}.Method = Method;
            
            count = count +1;
            Progress(count/(NumChans^2),h.Progress_Axes,h.Progress_Text,'Correlating...');
        end
    end
end
Progress(1,h.Progress_Axes,h.Progress_Text);

%%% show fit result in result axis
switch UserValues.BurstBrowser.Settings.fFCS_Mode
    case {2} % burstwise with time window
        % but only up to timewindowsize/2 to avoid the edge artifacts
        max_time = find(BurstMeta.fFCS.Result.Cor_Times{1} < 1E-3*UserValues.BurstBrowser.Settings.Corr_TimeWindowSize/2, 1, 'last');
    otherwise
        max_time = find(BurstMeta.fFCS.Result.Cor_Times{1} < BurstMeta.fFCS.Result.Cor_Times{1}(end)/2, 1, 'last');
end
if ~use_species3
    BurstMeta.Plots.fFCS.result_1x1.XData = BurstMeta.fFCS.Result.Cor_Times{1}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x1.YData = BurstMeta.fFCS.Result.Cor_Average{1}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x2.XData = BurstMeta.fFCS.Result.Cor_Times{2}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x2.YData = BurstMeta.fFCS.Result.Cor_Average{2}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x1.XData = BurstMeta.fFCS.Result.Cor_Times{3}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x1.YData = BurstMeta.fFCS.Result.Cor_Average{3}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x2.XData = BurstMeta.fFCS.Result.Cor_Times{4}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x2.YData = BurstMeta.fFCS.Result.Cor_Average{4}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x3.Visible = 'off';
    BurstMeta.Plots.fFCS.result_1x3.Visible = 'off';
    BurstMeta.Plots.fFCS.result_3x1.Visible = 'off';
    BurstMeta.Plots.fFCS.result_2x3.Visible = 'off';
    BurstMeta.Plots.fFCS.result_3x2.Visible = 'off';
else % species3, other assignment of correlation functions
    BurstMeta.Plots.fFCS.result_3x3.Visible = 'on';
    BurstMeta.Plots.fFCS.result_1x3.Visible = 'on';
    BurstMeta.Plots.fFCS.result_3x1.Visible = 'on';
    BurstMeta.Plots.fFCS.result_2x3.Visible = 'on';
    BurstMeta.Plots.fFCS.result_3x2.Visible = 'on';
    BurstMeta.Plots.fFCS.result_1x1.XData = BurstMeta.fFCS.Result.Cor_Times{1}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x1.YData = BurstMeta.fFCS.Result.Cor_Average{1}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x2.XData = BurstMeta.fFCS.Result.Cor_Times{2}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x2.YData = BurstMeta.fFCS.Result.Cor_Average{2}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x3.XData = BurstMeta.fFCS.Result.Cor_Times{3}(1:max_time);
    BurstMeta.Plots.fFCS.result_1x3.YData = BurstMeta.fFCS.Result.Cor_Average{3}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x1.XData = BurstMeta.fFCS.Result.Cor_Times{4}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x1.YData = BurstMeta.fFCS.Result.Cor_Average{4}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x2.XData = BurstMeta.fFCS.Result.Cor_Times{5}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x2.YData = BurstMeta.fFCS.Result.Cor_Average{5}(1:max_time);    
    BurstMeta.Plots.fFCS.result_2x3.XData = BurstMeta.fFCS.Result.Cor_Times{6}(1:max_time);
    BurstMeta.Plots.fFCS.result_2x3.YData = BurstMeta.fFCS.Result.Cor_Average{6}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x1.XData = BurstMeta.fFCS.Result.Cor_Times{7}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x1.YData = BurstMeta.fFCS.Result.Cor_Average{7}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x2.XData = BurstMeta.fFCS.Result.Cor_Times{8}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x2.YData = BurstMeta.fFCS.Result.Cor_Average{8}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x3.XData = BurstMeta.fFCS.Result.Cor_Times{9}(1:max_time);
    BurstMeta.Plots.fFCS.result_3x3.YData = BurstMeta.fFCS.Result.Cor_Average{9}(1:max_time);
end
axis(h.axes_fFCS_Result,'tight');
h.fFCS_axes_tab.SelectedTab = h.fFCS_axes_result_tab;