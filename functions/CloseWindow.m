function CloseWindow(obj,~)
%%% Clears function specific variables
switch obj.Tag
    case 'Pam'
        clear global -regexp FileInfo PamMeta TcspcData
        %%% close TauFit if it is open and interacting with PAM
        h_TauFit = findobj('Tag','TauFit');
        if ~isempty(h_TauFit)
            global TauFitData
            if strcmp(TauFitData.Who,'TauFit') || strcmp(TauFitData.Who,'Burstwise') %%% was called from PAM
                CloseWindow(h_TauFit);
            end
        end
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
         %%% close TauFit if it is open and interacting with BurstBrowser
         h_TauFit = findobj('Tag','TauFit');
         if ~isempty(h_TauFit)
             global TauFitData
             if strcmp(TauFitData.Who,'BurstBrowser') %%% was called from BurstBrowser
                 CloseWindow(h_TauFit);
             end
         end
    case 'TauFit'
        clear global -regexp TauFitData
    case 'PhasorTIFF'
        clear global -regexp PhasorTIFFData
    case 'GlobalPDAFit'
         clear global -regexp PDAData PDAMeta
    case 'Particle'
        clear global -regexp ParticleData
    case 'ParticleViewer'
        clear global -regexp ParticleViewer PhasorViewer
        
end

%%% Closes window
delete(obj);

%%% Save UserValues structure
LSUserValues(1);

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
h = cat(1,h, findobj('Tag','Particle'));
h = cat(1,h, findobj('Tag','ParticleViewer'));

%%% Clears general PAM related global variables when nothing is open
if isempty(h)
    clear global -regexp UserValues PathToApp 
end
%%% Clears FileInfo if PAM was closed
%%% FileInfo is sometimes called in LSUserValues
if isempty(findobj('Tag','Pam'))
    clear global -regexp FileInfo
end
