%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Reads out the Donor only lifetime from Donor only bursts %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DonorOnlyLifetimeCallback(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
file = BurstMeta.SelectedFile;

LSUserValues(0);

if ~h.MultiselectOnCheckbox.UserData
    data = BurstData{file}.DataArray;
else
    files = get_multiselection(h);
    files = unique(files);
    data = cell(numel(files),1);
    for i = 1:numel(files)
        data{i} = BurstData{files(i)}.DataArray;
    end
    %%% check if an files have additional parameters added to the DataArray
    len = cellfun(@(x) size(x,2),data);
    if ~(all(len == min(len))) %%% not all same length
        data = cellfun(@(x) x(:,1:min(len)), data, 'UniformOutput',false);
    end
    data = vertcat(data{:});
    %%% for future reference: we are assuming that all files have the same
    %%% NameArray!
end
%%% Determine Donor Only lifetime from data with S > 0.95
switch BurstData{file}.BAMethod
    case {1,2,5}
        idx_tauGG = strcmp(BurstData{file}.NameArray,'Lifetime D [ns]');
    case {3,4}
        idx_tauGG = strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]');
end
%%% catch case where no lifetime was determined

if all(data(:,idx_tauGG) == 0)
    return;
end
if any(BurstData{file}.BAMethod == [1,2,5])
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry');
    valid = (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Donly_Max);
elseif any(BurstData{file}.BAMethod == [3,4])
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry GR');
    %idxSBG = strcmp(BurstData{file}.NameArray,'Stoichiometry BG');
    valid = (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Donly_Max);% &...
        %(BurstData{file}.DataArray(:,idxSBG) > 0) & (BurstData{file}.DataArray(:,idxSBG) < 0.1);
end
x_axis = 0:0.05:10;
htauGG = histc(data(valid,idx_tauGG),x_axis);

x_axis = x_axis(1:end-1);
htauGG(end-1) = htauGG(end-1)+htauGG(end);
htauGG(end) = [];
BurstMeta.Plots.histE_donly.XData = x_axis;
BurstMeta.Plots.histE_donly.YData = htauGG;
h.Corrections.TwoCMFD.axes_crosstalk.XLabel.String = 'Lifetime D [ns]';
h.Corrections.TwoCMFD.axes_crosstalk.Title.String = 'Lifetime of Donor only';
axis(h.Corrections.TwoCMFD.axes_crosstalk,'tight');
%%% fit
[DonorOnlyLifetime, GaussFit] = GaussianFit(x_axis',htauGG);
BurstMeta.Plots.Fits.histE_donly(1).XData = x_axis;
BurstMeta.Plots.Fits.histE_donly(1).YData = GaussFit;
h.Corrections.TwoCMFD.axes_crosstalk.XLim = [0, DonorOnlyLifetime+3*sqrt(sum((x_axis'-DonorOnlyLifetime).^2.*GaussFit)./sum(GaussFit))];
%%% Update GUI
h.DonorLifetimeEdit.String = num2str(DonorOnlyLifetime);
UserValues.BurstBrowser.Corrections.DonorLifetime = DonorOnlyLifetime;
%%% Determine Acceptor Only Lifetime from data with S < 0.1
if any(BurstData{file}.BAMethod == [1,2,5])
    idx_tauRR = strcmp(BurstData{file}.NameArray,'Lifetime A [ns]');
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry');
    valid = (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Aonly_Min);
elseif any(BurstData{file}.BAMethod == [3,4])
    idx_tauRR = strcmp(BurstData{file}.NameArray,'Lifetime RR [ns]');
    idxS = strcmp(BurstData{file}.NameArray,'Stoichiometry GR');
    %idxSBR = strcmp(BurstData{file}.NameArray,'Stoichiometry BR');
    valid = (data(:,idxS) < UserValues.BurstBrowser.Settings.S_Aonly_Max) & (data(:,idxS) > UserValues.BurstBrowser.Settings.S_Aonly_Min);% &...
        %(BurstData{file}.DataArray(:,idxSBR) < 0.1) & (BurstData{file}.DataArray(:,idxSBR) > -0.1);
end
x_axis = 0:0.05:10;
htauRR = histc(data(valid,idx_tauRR),x_axis);
if size(htauRR,2) > size(htauRR,1)
    htauRR = htauRR';
end
x_axis = x_axis(1:end-1);
htauRR(end-1) = htauRR(end-1)+htauRR(end);
htauRR(end) = [];
BurstMeta.Plots.histS_aonly.XData = x_axis;
BurstMeta.Plots.histS_aonly.YData = htauRR;
h.Corrections.TwoCMFD.axes_direct_excitation.XLabel.String = 'Lifetime A [ns]';
h.Corrections.TwoCMFD.axes_direct_excitation.Title.String = 'Lifetime of Acceptor only';
axis(h.Corrections.TwoCMFD.axes_direct_excitation,'tight');
[AcceptorOnlyLifetime, GaussFit] = GaussianFit(x_axis',htauRR);
BurstMeta.Plots.Fits.histS_aonly(1).XData = x_axis;
BurstMeta.Plots.Fits.histS_aonly(1).YData = GaussFit;
h.Corrections.TwoCMFD.axes_direct_excitation.XLim = [0, AcceptorOnlyLifetime+3*sqrt(sum((x_axis'-AcceptorOnlyLifetime).^2.*GaussFit)./sum(GaussFit))];
%%% Update GUI
h.AcceptorLifetimeEdit.String = num2str(AcceptorOnlyLifetime);
UserValues.BurstBrowser.Corrections.AcceptorLifetime = AcceptorOnlyLifetime;

if ~h.MultiselectOnCheckbox.UserData
    BurstData{file}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
    BurstData{file}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
else
    for i = 1:numel(files)
        BurstData{files(i)}.Corrections.AcceptorLifetime = UserValues.BurstBrowser.Corrections.AcceptorLifetime;
        BurstData{files(i)}.Corrections.DonorLifetime = UserValues.BurstBrowser.Corrections.DonorLifetime;
    end
end

if any(BurstData{file}.BAMethod == [3,4])
    %%% Determine Donor Blue Lifetime from Blue dye only species
    idx_tauBB = strcmp(BurstData{file}.NameArray,'Lifetime BB [ns]');
    idxSBG = strcmp(BurstData{file}.NameArray,'Stoichiometry BG');
    idxSBR = strcmp(BurstData{file}.NameArray,'Stoichiometry BR');

    valid = (data(:,idxSBG) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxSBG) < UserValues.BurstBrowser.Settings.S_Donly_Max) &...
        (data(:,idxSBR) > UserValues.BurstBrowser.Settings.S_Donly_Min) & (data(:,idxSBR) < UserValues.BurstBrowser.Settings.S_Donly_Max);
    x_axis = 0:0.05:10;
    htauBB = histc(data(valid,idx_tauBB),x_axis);
    [DonorBlueLifetime, ~] = GaussianFit(x_axis',htauBB);
    %DonorBlueLifetime = mean(BurstData{file}.DataArray(valid,idx_tauBB));
    h.DonorLifetimeBlueEdit.String = num2str(DonorBlueLifetime);

    UserValues.BurstBrowser.Corrections.DonorLifetimeBlue = DonorBlueLifetime;
    if ~h.MultiselectOnCheckbox.UserData
        BurstData{file}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
    else
        for i = 1:numel(files)
            BurstData{files(i)}.Corrections.DonorLifetimeBlue = UserValues.BurstBrowser.Corrections.DonorLifetimeBlue;
        end
    end
    h.Corrections.TwoCMFD.axes_crosstalk.XLabel.String = 'Lifetime GG [ns]';
    h.Corrections.TwoCMFD.axes_direct_excitation.XLabel.String = 'Lifetime RR [ns]';
end
LSUserValues(1);
UpdateLifetimePlots([],[],h);
PlotLifetimeInd([],[],h);
ApplyCorrections([],[],h);