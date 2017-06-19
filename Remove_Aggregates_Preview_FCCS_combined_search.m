function Remove_Aggregates_Preview(obj,~)
global UserValues PamMeta FileInfo TcspcData
h = guidata(obj);
Progress(0,h.Progress.Axes, h.Progress.Text,'Calculating Aggregate Removal Preview...');

cla(h.Cor.Remove_Aggregates_Axes);
[Cor_A,Cor_B]=find(h.Cor.Table.Data(1:end-1,1:end-1));
%valid = Cor_A == Cor_B;
%Cor = Cor_A(valid);
% if isempty(Cor)
%     Progress(1,h.Progress.Axes, h.Progress.Text);
%     return;
% end
if numel(Cor_A) > 1
    Cor_A = Cor_A(1);
    Cor_B = Cor_B(1);
end

Times=ceil(PamMeta.MT_Patch_Times/FileInfo.ClockPeriod);

Det1=UserValues.PIE.Detector(Cor_A);
Rout1=UserValues.PIE.Router(Cor_A);
To1=UserValues.PIE.To(Cor_A);
From1=UserValues.PIE.From(Cor_A);
Name1 = UserValues.PIE.Name{Cor_A};

j = round(str2double(h.Cor.Remove_Aggregate_Block_Edit.String));

Data1=[TcspcData.MT{Det1,Rout1}(...
TcspcData.MI{Det1,Rout1}>=From1 &...
TcspcData.MI{Det1,Rout1}<=To1 &...
TcspcData.MT{Det1,Rout1}>=Times(j) &...
TcspcData.MT{Det1,Rout1}<Times(j+1))-Times(j)];

if Cor_B ~= Cor_A
    Det2=UserValues.PIE.Detector(Cor_B);
    Rout2=UserValues.PIE.Router(Cor_B);
    To2=UserValues.PIE.To(Cor_B);
    From2=UserValues.PIE.From(Cor_B);
    Name2 = UserValues.PIE.Name{Cor_B};
    
    Data2=[TcspcData.MT{Det2,Rout2}(...
    TcspcData.MI{Det2,Rout2}>=From2 &...
    TcspcData.MI{Det2,Rout2}<=To2 &...
    TcspcData.MT{Det2,Rout2}>=Times(j) &...
    TcspcData.MT{Det2,Rout2}<Times(j+1))-Times(j)];
end

T = str2double(h.Cor.Remove_Aggregate_Timewindow_Edit.String)*1000;%in mus
timebin_add = str2double(h.Cor.Remove_Aggregate_TimeWindowAdd_Edit.String);
Nsigma = str2double(h.Cor.Remove_Aggregate_Nsigma_Edit.String);

% get the average countrate of the block
cr = numel(Data1)./Data1(end)./FileInfo.ClockPeriod;
M = T*1E-6*cr;% minimum number of photons in time window
M = round(M + Nsigma*sqrt(M)); %%% add N sigma
                                
[start1, stop1] = find_aggregates(Data1,T,M,timebin_add);
start_times1 = Data1(start1);
stop_times1 = Data1(stop1);

% count rate trace in units of the time bin
[Trace,x] = histcounts(Data1*FileInfo.ClockPeriod,0:T*1E-6:(Data1(end)*FileInfo.ClockPeriod));
trace1 = plot(h.Cor.Remove_Aggregates_Axes,x(1:end-1),Trace,'-b');
%h.Cor.Remove_Aggregates_Axes.YLimMode = 'auto';
scale = h.Cor.Remove_Aggregates_Axes.YScale;
minY = min(Trace);
maxY = 10*max(Trace);
if strcmp(scale,'linear')
    minY = 0;
    h.Cor.Remove_Aggregates_Axes.YLim = [0,max(Trace)];
end
if Cor_B == Cor_A
    for i = 1:numel(start_times1)
        patch(h.Cor.Remove_Aggregates_Axes,FileInfo.ClockPeriod*[start_times1(i),stop_times1(i),stop_times1(i),start_times1(i)],...
            [minY,minY,maxY,maxY],'b','FaceAlpha',0.3,'EdgeColor','none');
    end
end
%%% plot second channel
if Cor_B ~= Cor_A
    % get the average countrate of the block
    cr = numel(Data2)./Data2(end)./FileInfo.ClockPeriod;
    M = T*1E-6*cr;% minimum number of photons in time window
    M = round(M + Nsigma*sqrt(M)); %%% add N sigma
    
    [start2, stop2] = find_aggregates(Data2,T,M,timebin_add);
    start_times2 = Data2(start2);
    stop_times2 = Data2(stop2);
    
    [start_times,idx] = sort([start_times1;start_times2]);
    stop_times = [stop_times1;stop_times2]; stop_times = stop_times(idx);
    %%% AND search, combining overlapping time windows
    k = 1;
    while k < numel(start_times)
        if start_times(k+1) <= (stop_times(k)+1)
            stop_times(k) = stop_times(k+1);
            start_times(k+1) = [];
            stop_times(k+1) = [];
        else
            k = k+1;
        end
    end
    % count rate trace in units of the time bin
    [Trace,x] = histcounts(Data2*FileInfo.ClockPeriod,0:T*1E-6:(Data2(end)*FileInfo.ClockPeriod));
    trace2 = plot(h.Cor.Remove_Aggregates_Axes,x(1:end-1),Trace,'-r');
    %h.Cor.Remove_Aggregates_Axes.XLimMode = 'auto';
    scale = h.Cor.Remove_Aggregates_Axes.YScale;
    minY = min([min(Trace) minY]);
    maxY = 10*max(Trace);
    if strcmp(scale,'linear')
        minY = 0;
        h.Cor.Remove_Aggregates_Axes.YLim = [0,max(Trace)];
    end
    for i = 1:numel(start_times)
        patch(h.Cor.Remove_Aggregates_Axes,FileInfo.ClockPeriod*[start_times(i),stop_times(i),stop_times(i),start_times(i)],...
            [minY,minY,maxY,maxY],'b','FaceAlpha',0.3,'EdgeColor','none');
    end
end
if (Cor_B == Cor_A)
    legend(trace1,Name1);
else
    legend([trace1,trace2],{Name1,Name2});
end

if (Cor_B == Cor_A)
    Data2 = Data1;
end

if h.Cor.Preview_Correlation_Checkbox.Value
    Progress(0.5,h.Progress.Axes, h.Progress.Text,'Calculating Aggregate Removal Preview...');
    h.Cor.Remove_Aggregates_FCS_Axes.Visible = 'on';
    h.Cor.Remove_Aggregates_Axes.Position(3) = 0.5;
    cla(h.Cor.Remove_Aggregates_FCS_Axes);
    
    if Cor_B ~= Cor_A
        %%% convert global start/stop times back to photon indices of
        %%% channels 1 and 2
        start1 = zeros(size(start_times));
        stop1 = zeros(size(start_times));
        start2 = zeros(size(start_times));
        stop2 = zeros(size(start_times));
        for i = 1:numel(start_times)
            start1(i) = find(Data1 >= start_times(i),1,'first');
            stop1(i) = find(Data1 <= stop_times(i),1,'last');
            start2(i) = find(Data2 >= start_times(i),1,'first');
            stop2(i) = find(Data2 <= stop_times(i),1,'last');
        end
    end
    
    %%% do correlation before correction
    MaxTime = max([Data1(end),Data2(end)]);
    [Cor_Before,Cor_Times]=CrossCorrelation({Data1},{Data2},MaxTime);                                        
    
    %%% correct for aggregates
    inval = [];
    for l = 1:numel(start1)
        inval = [inval,start1(l):stop1(l)];
    end
    Data1(inval) = [];
    
    valid_times = (start_times < Data1(end)) & (start_times > Data1(1));
    start_times1 = start_times(valid_times);
    stop_times1 = stop_times(valid_times);
    stop_times1(stop_times1 > Data1(end)) = Data1(end);
    % determine the count rate over the filtered signal
    cr = numel(Data1)./(Data1(end)-sum(start_times1-stop_times1));
    % fill with poisson noise
    for l = 1:numel(start_times1)
        %%% generate noise
        t = start_times1(l);
        while t(end) < stop_times1(l);
            t(end+1) = t(end) + exprnd(1/cr);
        end
        idx = find(Data1 < start_times1(l),1,'last');
        Data1 = [Data1(1:idx); t';Data1((idx+1):end)];
    end
    
    if Cor_B == Cor_A
        Data2 = Data1;
    else %%% do correction for second channel as well
        inval = [];
        for l = 1:numel(start2)
            inval = [inval,start2(l):stop2(l)];
        end
        Data2(inval) = [];
        
        valid_times = (start_times < Data2(end)) & (start_times > Data2(1));
        start_times2 = start_times(valid_times);
        stop_times2 = stop_times(valid_times);
        stop_times2(stop_times2 > Data2(end)) = Data2(end);
        % determine the count rate over the filtered signal
        cr = numel(Data2)./(Data2(end)-sum(start_times2-stop_times2));
        % fill with poisson noise
        for l = 1:numel(start_times2)
            %%% generate noise
            t = start_times2(l);
            while t(end) < stop_times2(l);
                t(end+1) = t(end) + exprnd(1/cr);
            end
            idx = find(Data2 < start_times2(l),1,'last');
            Data2 = [Data2(1:idx); t';Data2((idx+1):end)];
        end
    end
    %%% do correlation after correction
    MaxTime = max([Data1(end),Data2(end)]);
    [Cor_After,Cor_Times]=CrossCorrelation({Data1},{Data2},MaxTime);                 
    Cor_Times = Cor_Times*FileInfo.ClockPeriod;
    average_window = find(Cor_Times > 1e-6,1,'first'); 
    average_window = max([1,(average_window-5)]):min([(average_window+10),numel(Cor_Times)]);
    semilogx(h.Cor.Remove_Aggregates_FCS_Axes,Cor_Times,Cor_Before./mean(Cor_Before(average_window)),'r');
    semilogx(h.Cor.Remove_Aggregates_FCS_Axes,Cor_Times,Cor_After./mean(Cor_After(average_window)),'b');
    legend(h.Cor.Remove_Aggregates_FCS_Axes,'before','after');
    axis(h.Cor.Remove_Aggregates_FCS_Axes,'tight');
    h.Cor.Remove_Aggregates_FCS_Axes.XLim = [1E-6,MaxTime*FileInfo.ClockPeriod/10];
else
    cla(h.Cor.Remove_Aggregates_FCS_Axes);
    h.Cor.Remove_Aggregates_FCS_Axes.Visible = 'off';
    h.Cor.Remove_Aggregates_Axes.Position(3) = 0.9;
    legend(h.Cor.Remove_Aggregates_FCS_Axes,'off');
end
Progress(1);
Update_Display([],[],1);