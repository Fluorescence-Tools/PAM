%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculate lifetimes from phasor corrdinates on mouseover %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PhasorLiveUpdate(obj,eData)
global BurstData BurstMeta
h = guidata(obj);
if isempty(BurstData)
    return;
end
%%% are we in a phasor window?
if ~isempty(BurstData)
    if ~any(BurstData{BurstMeta.SelectedFile}.BAMethod == [3,4]) % for 3color MFD, there are 6 plots even without phasor
        if (h.lifetime_ind_popupmenu.Value < 5)
            return;
        end
    end
end
if ~isfield(BurstData{BurstMeta.SelectedFile},'Phasor')
    return;
end
%%% get position
Pos=h.axes_lifetime_ind_2d.CurrentPoint(1,1:2);
%%% Calculates current cursor position relative to limits
XLim=h.axes_lifetime_ind_2d.XLim;
YLim=h.axes_lifetime_ind_2d.YLim;
%%% Only ecexutes inside plot bounds
if ~(Pos(1)>XLim(1) && Pos(1)<XLim(2) && Pos(2)>YLim(1) && Pos(2)<XLim(2))
    return;
end

%%% get channel (donor or acceptor)
chan = h.lifetime_ind_popupmenu.Value-4;
%%%Calculates info and updates text fields
Freq = 1./(BurstData{BurstMeta.SelectedFile}.Phasor.PhasorRange(chan)/BurstData{BurstMeta.SelectedFile}.FileInfo.MI_Bins*BurstData{BurstMeta.SelectedFile}.TACRange*1E9);
TauP=(Pos(1,2)/Pos(1,1))/(2*pi*Freq);
TauM=sqrt((1/(Pos(1,2)^2+Pos(1,1)^2))-1)/(2*pi*Freq);
MeanTau = (TauP+TauM)/2;    
h.axes_lifetime_ind_2d_textbox.String = ...
    sprintf('TauP = %.2f ns   TauM = %.2f ns\nTauAvg = %.2f ns',...
                TauP,TauM,MeanTau);
%%% Enables callback
h.BurstBrowser.WindowButtonMotionFcn=@PhasorLiveUpdate;
