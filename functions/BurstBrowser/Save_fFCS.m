%%%%% saves the fFCS result
function Save_fFCS(~,~)
global BurstMeta UserValues
for i = 1:numel(BurstMeta.fFCS.Result.FileName)
    Current_FileName = BurstMeta.fFCS.Result.FileName{i};   
    %%% Checks, if file already exists
    if  exist(Current_FileName,'file')
        k=1;
        %%% Adds 1 to filename
        Current_FileName=[Current_FileName(1:end-5) '_' num2str(k) '.mcor'];
        %%% Increases counter, until no file is found
        while exist(Current_FileName,'file')
            k=k+1;
            Current_FileName=[Current_FileName(1:end-(5+numel(num2str(k-1)))) num2str(k) '.mcor'];
        end
    end
    Header = BurstMeta.fFCS.Result.Header{i};
    Counts = BurstMeta.fFCS.Result.Counts{i};
    Valid = BurstMeta.fFCS.Result.Valid{i};
    Cor_Times = BurstMeta.fFCS.Result.Cor_Times{i};
    Cor_Average = BurstMeta.fFCS.Result.Cor_Average{i};
    Cor_SEM = BurstMeta.fFCS.Result.Cor_SEM{i};
    Cor_Array = BurstMeta.fFCS.Result.Cor_Array{i};
    
    save(Current_FileName,'Header','Counts','Valid','Cor_Times','Cor_Average','Cor_SEM','Cor_Array');
end
%%% Update FCSFit Path
UserValues.File.FCSPath = UserValues.File.BurstBrowserPath;
LSUserValues(1);