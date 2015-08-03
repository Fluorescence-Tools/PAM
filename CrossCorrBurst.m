function [Cor_Array,Timeaxis] = CrossCorrBurst(Data1,Data2,Maxtime,Weights1,Weights2)
%%% Data1, Data2: Photon macrotimes
%%% Weights1, Weights2: Photon weights
%%% Blocktimes: 2xn vector of star/stop times
%%% ProgressStruct: Structure with information for Progress;
%%% ProgressStruct.Axes: handle of progress axes
%%% ProgressStruct.Test: handles to progress text field
%%% ProgressStruct.Max: total number of correlation bins
%%% ProgressStruct.Current: number of correlation bins previously completed

%%% If no weights are specified, set to 1
if nargin < 4
    Weights1 = cell(numel(Data1),1);
    Weights2 = cell(numel(Data2),1);
    for i = 1:numel(Data1)
        Weights1{i} = ones(numel(Data1{i}),1);
        Weights2{i} = ones(numel(Data2{i}),1);
    end
end
%%% Calculates a pseudologarithmic timeaxis:
%%% [1:21 20:2:41 45:4:81 ....]
MaxMaxtime = max(Maxtime);
Timeaxis_Exponent=floor(log2(MaxMaxtime/10));
Timeaxis=ones(10*(Timeaxis_Exponent+1),1);
Timeaxis=Timeaxis.*2.^floor(((1:numel(Timeaxis))-1)/10-1)';
Timeaxis(Timeaxis<1)=1;
Timeaxis=cumsum([1;Timeaxis]);

Cor_Array=repmat({[]},numel(Data1),1);
parfor i=1:numel(Data1)
    if ~isempty(Data1{i}) && ~isempty(Data2{i})
        %%% Does the crosscorrelation        
        Cor_Array{i}=Do_CCF(Data1{i},Data2{i},Weights1{i},Weights2{i},10,Timeaxis_Exponent,numel(Data1{i}),numel(Data2{i}),Timeaxis);
        %%% Truncates to length of Timeaxis
        Cor_Array{i}=Cor_Array{i}(1:numel(Timeaxis))';  
    end
end

%%% Calculates divisor to account for the differently spaced bins
Divisor=ones(numel(Timeaxis),1);
Divisor(22:end)=2.^(floor((10:(numel(Divisor)-12))/10));
%%% Does additional normalizing
Norm = cell(numel(Cor_Array),1);
Countrate1 = cell(numel(Cor_Array),1); 
Countrate2 = cell(numel(Cor_Array),1);

parfor i=1:numel(Cor_Array)
    Norm{i} = Maxtime(i)-Timeaxis+1;
    Norm{i}(Norm{i}<0) = 0;
    %Norm{i}(Timeaxis>Maxtime(i)) = 0;
    for j = 1:numel(Timeaxis)
        Countrate1{i}(j) = sum(Weights1{i}(Data1{i} <= (Maxtime(i)-Timeaxis(j))));
        Countrate2{i}(j) = sum(Weights2{i}(Data2{i} >= (Timeaxis(j))));
    end
     %Countrate1{i} = sum(Weights1{i});
     %Countrate2{i} = sum(Weights2{i});
end

error_estimate = 1;
if error_estimate
    %%% Perform bootstrapping
    %%% 1) Select Nbursts times out of pool (may select double)
    bootstrap = 50;
    selected = randi(numel(Data1),numel(Data1),bootstrap);
    
    Cor_Res = cell(1,bootstrap);
    for i = 1:bootstrap
        sel = selected(:,i);
        norm_temp = Norm(sel); norm_temp = sum(horzcat(norm_temp{:}),2);
        Countrate1_temp = Countrate1(sel);Countrate1_temp = sum(vertcat(Countrate1_temp{:}),1);%./sum(Maxtime(sel));
        Countrate2_temp = Countrate2(sel);Countrate2_temp = sum(vertcat(Countrate2_temp{:}),1);%./sum(Maxtime(sel));
        Cor_Total_temp = Cor_Array(sel);Cor_Total_temp = sum(horzcat(Cor_Total_temp{:}),2);
        Cor_Res{i} = Cor_Total_temp.*norm_temp./Divisor./Countrate1_temp'./Countrate2_temp'-1;
        %Cor_Res{i} = Cor_Total_temp./norm_temp./Divisor./Countrate1_temp'./Countrate2_temp'-1;
    end
    
    for i = 1:numel(Cor_Res)
        Cor_Res{i}(find(Cor_Res{i}(~isnan(Cor_Res{i}))==-1,1,'first'):end) = 0;
        %Cor_Res{i}=Cor_Res{i}(1:find(Cor_Res{i}(~isnan(Cor_Res{i}))~=-1,1,'last'));
    end
    Cor_Array = cell2mat(Cor_Res);
    Cor_Array = Cor_Array(1:find(sum(Cor_Array,2),1,'last'),:);
    Timeaxis = Timeaxis(1:size(Cor_Array,1));
    Timeaxis(22:end) = Timeaxis(22:end)-1;    
else
    Cor_Total = sum(horzcat(Cor_Array{:}),2);
    
    Norm = sum(horzcat(Norm{:}),2);
    Countrate1 = sum(vertcat(Countrate1{:}),1);
    Countrate2 = sum(vertcat(Countrate2{:}),1);

    Cor_Array = Cor_Total.*Norm./Divisor./Countrate1'./Countrate2';
    % for i=1:numel(Cor_Array)
    %     Cor_Array{i}=(Cor_Array{i}./Divisor./(Maxtime-(Timeaxis)))/((sum(Weights1{i})/max(Data1{i}))*(sum(Weights2{i})/max(Data2{i})))-1;
    %     %Cor_Array{i}=(Cor_Array{i}./Divisor./(Maxtime-Timeaxis))/((numel(Data1{i})/max(Data1{i}))*(numel(Data2{i})/max(Data2{i})))-1;
    %     Cor_Array{i}=Cor_Array{i}(1:find(Cor_Array{i}~=-1,1,'last'));
    % end
    Cor_Array = Cor_Array-1;
    Cor_Array=Cor_Array(1:find(Cor_Array~=-1,1,'last'));
    Timeaxis = Timeaxis(1:numel(Cor_Array));
    Timeaxis(22:end) = Timeaxis(22:end)-1;
end

