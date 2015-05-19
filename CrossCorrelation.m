function [Cor_Array,Timeaxis] = CrossCorrelation(Data1,Data2,Maxtime,Weights1,Weights2)
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
Timeaxis_Exponent=floor(log2(Maxtime/10));
Timeaxis=ones(10*(Timeaxis_Exponent+1),1);
Timeaxis=Timeaxis.*2.^floor(((1:numel(Timeaxis))-1)/10-1)';
Timeaxis(Timeaxis<1)=1;
Timeaxis=cumsum([1;Timeaxis]);

Cor_Array=repmat({[]},numel(Data1),1);
parfor i=1:numel(Data1)
    if ~isempty(Data1{i}) && ~isempty(Data2{i})
        %%% Does the crosscorrelation        
        Cor_Array{i}=Do_CCF(Data1{i},Data2{i},Weights1{i},Weights2{i},10,Timeaxis_Exponent,numel(Data1{i}),numel(Data2{i}),Timeaxis);
        %%% Truncates to leangth of Timeaxis
        Cor_Array{i}=Cor_Array{i}(1:numel(Timeaxis))';  
    end
end


%%% Calculates divisor to account for the differently spaced bins
Divisor=ones(numel(Timeaxis),1);
Divisor(22:end)=2.^(floor((10:(numel(Divisor)-12))/10));
%%% Does additional normalizing
for i=1:numel(Cor_Array)
    Cor_Array{i}=(Cor_Array{i}./Divisor./(Maxtime-(Timeaxis)))/((sum(Weights1{i})/max(Data1{i}))*(sum(Weights2{i})/max(Data2{i})))-1;
    %Cor_Array{i}=(Cor_Array{i}./Divisor./(Maxtime-Timeaxis))/((numel(Data1{i})/max(Data1{i}))*(numel(Data2{i})/max(Data2{i})))-1;
    Cor_Array{i}=Cor_Array{i}(1:find(Cor_Array{i}~=-1,1,'last'));
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
Timeaxis=Timeaxis(1:max(Array_Length));
%%% Shift timeaxis to center of bins
%Timeaxis = Timeaxis+[diff(Timeaxis); (Timeaxis(end)-Timeaxis(end-1))]/2;
%Timeaxis = Timeaxis + Divisor(1:numel(Timeaxis))/2;
