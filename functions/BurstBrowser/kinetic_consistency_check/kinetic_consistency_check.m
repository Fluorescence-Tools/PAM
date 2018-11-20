function kinetic_consistency_check(type)
global BurstData BurstTCSPCData UserValues BurstMeta
h = guidata(findobj('Tag','BurstBrowser'));
file = BurstMeta.SelectedFile;

%%% Load associated .bps file, containing Macrotime, Microtime and Channel
if isempty(BurstTCSPCData{file})
    Load_Photons();
end
photons = BurstTCSPCData{file};

%%% recolor channel photons based on kinetic scheme
rate_matrix = 1000*[0, 1; 0.5,0]; %%% rates in Hz
switch type
    case 'BVA'
         case {1} % BVA
            %%% read out macrotimes of donor and FRET channels
            switch BurstData{file}.BAMethod
                case {1,2}
                    % channel : 1,2 Donor Par Perp
                    %           3,4 FRET Par Perp
                    %           5,6 ALEX Par Parp
                    mt = cellfun(@(x,y) x(y < 5),photons.Macrotime,photons.Channel,'UniformOutput',false);                            
                case 5
                    % channel : 1 Donor
                    %           2 FRET
                    %           3 ALEX
                    mt = cellfun(@(x,y) x(y < 3),photons.Macrotime,photons.Channel,'UniformOutput',false);
            end
            %%% generate channel variable based on kinetic scheme
            
end
    
