function CloseWindow(obj,~)

LSUserValues(1);

%%% Clears function specific variables
switch obj.Tag
    case 'Pam'
        clear global -regexp FileInfo PamMeta TcspcData
    case 'Phasor'
        clear global -regexp PhasorData
    case 'FCSFit'
        clear global -regexp FCSData FCSMeta
    case 'Mia'
        clear global -regexp MIAData
    case 'MIAFit'
         clear global -regexp MIAFitData MIAFitMeta
    case 'Sim'
         clear global -regexp SimData
    case 'PCF'
         clear global -regexp PCFData
    case 'BurstBrowser'
         clear global -regexp BurstMeta BurstTCSPCData PhotonStream BurstData
    case 'TauFit'
        clear global -regexp TauFitData
    case 'PhasorTIFF'
        clear global -regexp PhasorTIFFData
    case 'GlobalPDAFit'
         clear global -regexp PDAData PDAMeta
    case 'Particle'
        clear global -regexp ParticleData
        
end

%%% Closes window
delete(obj);

%%% Finds all active PAM related figures
h = [];
h = cat(1,h, findobj('Tag','Pam'));
h = cat(1,h, findobj('Tag','Phasor'));
h = cat(1,h, findobj('Tag','FCSFit'));
h = cat(1,h, findobj('Tag','Mia'));
h = cat(1,h, findobj('Tag','MIAFit'));
h = cat(1,h, findobj('Tag','Sim'));
h = cat(1,h, findobj('Tag','PCF'));
h = cat(1,h, findobj('Tag','BurstBrowser'));
h = cat(1,h, findobj('Tag','TauFit'));
h = cat(1,h, findobj('Tag','PhasorTIFF'));
h = cat(1,h, findobj('Tag','GlobalPDAFit'));
h = cat(1,h, findobj('Tag','Partice'));

%%% Clears general PAM related global variables when nothing is open
if isempty(h)
    clear global -regexp UserValues PathToApp 
end
%%% Clears FileInfo if PAM was closed
%%% FileInfo is sometimes called in LSUserValues
if isempty(findobj('Tag','Pam'))
    clear global -regexp FileInfo
end
