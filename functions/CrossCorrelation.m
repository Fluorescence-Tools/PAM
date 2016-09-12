function [Cor_Array,Timeaxis] = CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2,mode)
% Calculates crosscorrelation function of two photon streams.
%
% Args:
%   * Data1, Data2: Cell arrays of photon time stamps for each block
%   * Maxtime: Maximum photon arrival time
%   * Weights1, Weights2: Cell arrays of photon weights. Used for FLCS, defaults to 1)
%   * mode: mode=1 performs normal correlation based on blocks of photon data. mode=2 performs burstwise correlation. In this case, Data1/2 are cell arrays of burstwise photon data. Defaults to 1.
%
% Returns:
%   * Cor_Array: Array of computed correlation functions. Number of correlation curves returned is equal to the number of blocks (mode 1), or equal to 50 in case of burstwise correlation (mode 2).
%   * Timeaxis: Timeaxis for correlation function

global UserValues

%%% If no weights are specified, set to 1
if (nargin < 4) || isempty(Weights1)
    Weights1 = cell(numel(Data1),1);
    Weights2 = cell(numel(Data2),1);
    for i = 1:numel(Data1)
        Weights1{i} = ones(numel(Data1{i}),1);
        Weights2{i} = ones(numel(Data2{i}),1);
    end
end

%%% If no mode (BurstCorrelation or not) was specified, default to normal
%%% correlation
if nargin < 6
    mode = 1;
end

%%% Calculates a pseudologarithmic timeaxis:
%%% [1:21 20:2:41 45:4:81 ....]
if mode == 1
    Timeaxis_Exponent=floor(log2(Maxtime/10));
elseif mode == 2
    MaxMaxtime = max(Maxtime);
    Timeaxis_Exponent=floor(log2(MaxMaxtime/10));
end
Timeaxis=ones(10*(Timeaxis_Exponent+1),1);
Timeaxis=Timeaxis.*2.^floor(((1:numel(Timeaxis))-1)/10-1)';
Timeaxis(Timeaxis<1)=1;
Timeaxis=cumsum([1;Timeaxis]);


Cor_Array=repmat({[]},numel(Data1),1);
parfor (i=1:numel(Data1),UserValues.Settings.Pam.ParallelProcessing)
    if ~isempty(Data1{i}) && ~isempty(Data2{i})
        %%% Does the crosscorrelation        
        %Cor_Array{i}=Do_CCF(Data1{i},Data2{i},Weights1{i},Weights2{i},10,Timeaxis_Exponent,numel(Data1{i}),numel(Data2{i}),Timeaxis);
        Cor_Array{i}=Do_CCF_new(Data1{i},Data2{i},Weights1{i},Weights2{i},10,Timeaxis_Exponent,numel(Data1{i}),numel(Data2{i}),Timeaxis);
        %%% Truncates to leangth of Timeaxis
        Cor_Array{i}=Cor_Array{i}(1:numel(Timeaxis))';  
    end
end

%%% Calculates divisor to account for the differently spaced bins
Divisor=ones(numel(Timeaxis),1);
Divisor(22:end)=2.^(floor((10:(numel(Divisor)-12))/10));
%%% Does additional normalizing
if mode == 1
    Norm = Maxtime-Timeaxis+1;
    if Norm < 0
        Norm = 0;
    end

    for i=1:numel(Cor_Array)
        Weights1_Sum = cumsum(Weights1{i});
        Weights2_Sum = [0; cumsum(Weights2{i})];
        Countrate1 = zeros(1,numel(Timeaxis));
        Countrate2 = zeros(1,numel(Timeaxis));
        for j = 1:numel(Timeaxis)
            Stop = find(Data1{i} <= (Maxtime-Timeaxis(j)),1,'last');
            Start = find(Data2{i} >= (Timeaxis(j)),1,'first');
            if ~isempty(Stop)
                Countrate1(j) = Weights1_Sum(Stop)/(Maxtime-Timeaxis(j));
            else
                Countrate1(j) = 0;
            end
            if ~isempty(Start)
                Countrate2(j) = (Weights2_Sum(end)-Weights2_Sum(Start))/(Maxtime-Timeaxis(j));
            else
                Countrate2(j) = 0;
            end       
    %         Countrate1(j) = sum(Weights1{i}(Data1{i} <= (Maxtime-Timeaxis(j))))./(Maxtime-Timeaxis(j));
    %         Countrate2(j) = sum(Weights2{i}(Data2{i} >= (Timeaxis(j))))./(Maxtime-Timeaxis(j));
        end 
        Cor_Array{i} = Cor_Array{i}./Norm./Divisor./Countrate1'./Countrate2'-1;
        Cor_Array{i} = Cor_Array{i}(1:find(Cor_Array{i}~=-1,1,'last'));   
    end
    %%% Makes sure all bins have the same size
    Array_Length=cellfun(@numel,Cor_Array);
    if min(Array_Length)~=max(Array_Length)
       for i=1:numel(Cor_Array)
          if Array_Length(i)<max(Array_Length)
              Cor_Array{i}(max(Array_Length))=0;
          end
       end
    end
    Cor_Array=cell2mat(Cor_Array');
    % for i=1:numel(Cor_Array)
    %     Cor_Array{i}=(Cor_Array{i}./Divisor./(Maxtime-(Timeaxis)))/((sum(Weights1{i})/max(Data1{i}))*(sum(Weights2{i})/max(Data2{i})))-1;
    %     %Cor_Array{i}=(Cor_Array{i}./Divisor./(Maxtime-Timeaxis))/((numel(Data1{i})/max(Data1{i}))*(numel(Data2{i})/max(Data2{i})))-1;
    %     Cor_Array{i}=Cor_Array{i}(1:find(Cor_Array{i}~=-1,1,'last'));
    % end
    Timeaxis=Timeaxis(1:max(Array_Length));
elseif mode == 2
    %%% Does additional normalizing
%     Norm = cell(numel(Cor_Array),1);
%     Countrate1 = cell(numel(Cor_Array),1); 
%     Countrate2 = cell(numel(Cor_Array),1);
%     parfor i=1:numel(Cor_Array)
%         Norm{i} = Maxtime(i)-Timeaxis+1;
%         Norm{i}(Norm{i}<0) = 0;
%         %Norm{i}(Timeaxis>Maxtime(i)) = 0;
%         for j = 1:numel(Timeaxis)
%             Countrate1{i}(j) = sum(Weights1{i}(Data1{i} <= (Maxtime(i)-Timeaxis(j))));
%             Countrate2{i}(j) = sum(Weights2{i}(Data2{i} >= (Timeaxis(j))));
%         end
%          %Countrate1{i} = sum(Weights1{i});
%          %Countrate2{i} = sum(Weights2{i});
%     end
    Norm = cell(numel(Cor_Array),1);
    Countrate1 = cell(numel(Cor_Array),1); 
    Countrate2 = cell(numel(Cor_Array),1);
    parfor (i=1:numel(Cor_Array),UserValues.Settings.Pam.ParallelProcessing)
        Norm{i} = Maxtime(i)-Timeaxis+1;
        Norm{i}(Norm{i}<0) = 0;
        Weights1_Sum = cumsum(Weights1{i});
        Weights2_Sum = [0; cumsum(Weights2{i})]; %%% Important here!
        Countrate1{i} = zeros(1,numel(Timeaxis));
        Countrate2{i} = zeros(1,numel(Timeaxis));
        for j = 1:numel(Timeaxis)
            Stop = find(Data1{i} <= (Maxtime(i)-Timeaxis(j)),1,'last');
            Start = find(Data2{i} >= (Timeaxis(j)),1,'first');
            if ~isempty(Stop)
                Countrate1{i}(j) = Weights1_Sum(Stop);
            else
                Countrate1{i}(j) = 0;
            end
            if ~isempty(Start)
                Countrate2{i}(j) = (Weights2_Sum(end)-Weights2_Sum(Start));
            else
                Countrate2{i}(j) = 0;
            end       
    %         Countrate1(j) = sum(Weights1{i}(Data1{i} <= (Maxtime-Timeaxis(j))))./(Maxtime-Timeaxis(j));
    %         Countrate2(j) = sum(Weights2{i}(Data2{i} >= (Timeaxis(j))))./(Maxtime-Timeaxis(j));
        end 
    end
    %%% Bootstrapping
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
        Cor_Res{i}(~isfinite(Cor_Res{i})) = -1;
        %Cor_Res{i}(find(Cor_Res{i}(~isnan(Cor_Res{i}))==-1,1,'first'):end) = 0;
        %Cor_Res{i}=Cor_Res{i}(1:find(Cor_Res{i}(~isnan(Cor_Res{i}))~=-1,1,'last'));
        Cor_Res{i}((find(Cor_Res{i}~=-1,1,'last')+1):end) = 0;
    end
    Cor_Array = cell2mat(Cor_Res);
    Cor_Array = Cor_Array(1:find(sum(Cor_Array,2),1,'last'),:);
    Timeaxis = Timeaxis(1:size(Cor_Array,1));
end
Timeaxis(22:end) = Timeaxis(22:end)-1;
% %% Shift timeaxis to center of bins
% Timeaxis = Timeaxis+[diff(Timeaxis); (Timeaxis(end)-Timeaxis(end-1))]/2;
% Timeaxis = Timeaxis + Divisor(1:numel(Timeaxis))/2;
