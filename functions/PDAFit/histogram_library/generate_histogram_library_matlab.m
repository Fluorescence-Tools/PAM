function [P, P_donly] = generate_histogram_library_matlab(i,NobinsE,Nobins,maxN,h)
global PDAMeta PDAData UserValues
%%% evaluate the background probabilities
BGgg = poisspdf(0:1:maxN,PDAMeta.BGdonor(i)*PDAData.timebin(i)*1E3);
BGgr = poisspdf(0:1:maxN,PDAMeta.BGacc(i)*PDAData.timebin(i)*1E3);

method = 'cdf';
switch method
    case 'pdf'
        %determine boundaries for background inclusion
        BGgg(BGgg<1E-3) = [];
        BGgr(BGgr<1E-3) = [];
    case 'cdf'
        %%% evaluate the background probabilities
        CDF_BGgg = poisscdf(0:1:maxN,PDAMeta.BGdonor(i)*PDAData.timebin(i)*1E3);
        CDF_BGgr = poisscdf(0:1:maxN,PDAMeta.BGacc(i)*PDAData.timebin(i)*1E3);
        %determine boundaries for background inclusion
        threshold = 0.95;
        BGgg((find(CDF_BGgg>threshold,1,'first')+1):end) = [];
        BGgr((find(CDF_BGgr>threshold,1,'first')+1):end) = [];
end
PBG = BGgg./sum(BGgg);
PBR = BGgr./sum(BGgr);
NBG = numel(BGgg)-1;
NBR = numel(BGgr)-1;

% assign current file to global cell
PDAMeta.PBG{i} = PBG;
PDAMeta.PBR{i} = PBR;
PDAMeta.NBG{i} = NBG;
PDAMeta.NBR{i} = NBR;

%%% prepare epsilon grid

% generate NobinsE+1 values for eps
%E_grid = linspace(0,1,NobinsE+1);
%R_grid = linspace(0,5*PDAMeta.R0(i),100000)';
%epsEgrid = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*((E_grid+PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))./(1-E_grid))).^(-1);
%epsRgrid = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*(((PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))+(1./(1+(R_grid./PDAMeta.R0(i)).^6)))./(1-(1./(1+(R_grid./PDAMeta.R0(i)).^6))))).^(-1);

%%% new: use linear distribution of eps since the
%%% conversion of P(R) to P(eps) returns a probability
%%% density, that would have to be converted to a
%%% probability by multiplying with the bin width.
%%% Instead, usage of a linear grid of eps ensures that the
%%% returned P(eps) is directly a probabilty
eps_min = 1-(1+PDAMeta.crosstalk(i)+PDAMeta.gamma(i)*((0+PDAMeta.directexc(i)/(1-PDAMeta.directexc(i)))./(1-0))).^(-1);
eps_grid = linspace(eps_min,1,NobinsE+1);
[NF, N, eps] = meshgrid(0:maxN,1:maxN,eps_grid);
% generates a grid cube:
% NF all possible number of FRET photons
% N all possible total number of photons
% eps all possible FRET efficiencies
% generate a P(NF) cube given fixed initial values of NF, N and given particular values of eps
PNF = calc_PNF(NF(:),N(:),eps(:),numel(NF));
PNF = reshape(PNF,size(eps,1),size(eps,2),size(eps,3));
%PNF = binopdf(NF, N, eps);
% binopdf(X,N,P) returns the binomial probability density function with parameters N and P at the values in X.
%%% Also calculate distribution for donor only
PNF_donly = binopdf(NF(:,:,1),N(:,:,1),PDAMeta.crosstalk(i)/(1+PDAMeta.crosstalk(i)));

if ~UserValues.PDA.DeconvoluteBackground
    % histogram NF+NG into maxN+1 bins
    PN = histcounts((PDAData.Data{i}.NF(PDAMeta.valid{i})+PDAData.Data{i}.NG(PDAMeta.valid{i})),1:(maxN+1));
else
    PN = deconvolute_PofF(PDAData.Data{i}.NF(PDAMeta.valid{i})+PDAData.Data{i}.NG(PDAMeta.valid{i}),(PDAMeta.BGdonor(i)+PDAMeta.BGacc(i))*PDAData.timebin(i)*1E3);
    PN = PN(1:maxN).*sum(PDAMeta.valid{i} &  ~((PDAData.Data{i}.NG == 0) & (PDAData.Data{i}.NF == 0)));
end
% assign current file to global cell
%PDAMeta.E_grid{i} = E_grid;
%PDAMeta.R_grid{i} = R_grid;
PDAMeta.eps_grid{i} = eps_grid;
%PDAMeta.epsRgrid{i} = epsRgrid;
PDAMeta.PN{i} = PN;
PDAMeta.PNF{i} = PNF;
PDAMeta.PNF_donly{i} = PNF_donly;
PDAMeta.Grid.NF{i} = NF;
PDAMeta.Grid.N{i} = N;
PDAMeta.Grid.eps{i} = eps;
PDAMeta.maxN{i} = maxN;

Progress((i-1+0.2)./numel(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing fit...');
Progress((i-1+0.2)./numel(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing fit...');
%%% Calculate Histogram Library (CalcHistLib)
PDAMeta.HistLib = [];
P = cell(1,numel(eps_grid));
PN_dummy = PN';
%%% Calculate shot noise limited histogram
% case 1, no background in either channel
if NBG == 0 && NBR == 0
    for j = 1:numel(eps_grid)
        %for a particular value of E
        P_temp = PNF(:,:,j);
        switch PDAMeta.xAxisUnit
            case 'Proximity Ratio'
                E_temp = NF(:,:,j)./N(:,:,j);
                minE = 0; maxE = 1;
            case 'log(FD/FA)'
                E_temp = real(log10((N(:,:,j)-NF(:,:,j))./NF(:,:,j)));
                %minE = min(E_temp(:)); maxE = max(E_temp(:));
                minE = h.AllTab.Main_Axes.XLim(1);
                maxE = h.AllTab.Main_Axes.XLim(2);
            case {'FRET efficiency','Distance'}
                % Background correction
                NF_cor = NF(:,:,j);
                ND_cor = N(:,:,j)-NF(:,:,j);
                % crosstalk and direct excitation correction
                % (direct excitation based on Schuler method
                % using the corrected total number of photon
                % and the direct excitation factor as defined
                % for PDA as p_de =
                % eps_A^lambdaD/(eps_A^lambdaD+eps_D^lambdaD),
                % i.e. the probability that the acceptor is
                % excited by the donor laser using the
                % exctinction coefficients at the donor
                % excitation wavelength.
                % see: Nettels, D. et al. Excited-state annihilation reduces power dependence of single-molecule FRET experiments. Physical Chemistry Chemical Physics 17, 32304-32315 (2015).
                NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);
                if strcmp(PDAMeta.xAxisUnit,'Distance')
                    valid_distance = E_temp > 0;
                    % convert to distance
                    E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                    E_temp = E_temp(valid_distance);
                    P_temp = P_temp(valid_distance);
                end
                %minE = min(E_temp); maxE = max(E_temp);
                minE = h.AllTab.Main_Axes.XLim(1);
                maxE = h.AllTab.Main_Axes.XLim(2);
        end
        [~,~,bin] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
        validd = (bin ~= 0);
        P_temp = P_temp(:);
        bin = bin(validd);
        P_temp = P_temp(validd);
        %%% Store bin,valid and P_temp variables for brightness correction
        PDAMeta.HistLib.bin{i}{j} = bin;
        PDAMeta.HistLib.P_array{i}{j} = P_temp;
        PDAMeta.HistLib.valid{i}{j} = validd;
        
        PN_trans = repmat(PN_dummy,1,maxN+1);
        PN_trans = PN_trans(:);
        PN_trans = PN_trans(PDAMeta.HistLib.valid{i}{j});
        P{1,j} = accumarray(PDAMeta.HistLib.bin{i}{j},PDAMeta.HistLib.P_array{i}{j}.*PN_trans);
    end
else
    for j = 1:numel(eps_grid)
        bin = cell((NBG+1)*(NBR+1),1);
        P_array = cell((NBG+1)*(NBR+1),1);
        validd = cell((NBG+1)*(NBG+1),1);
        count = 1;
        for g = 0:NBG
            for r = 0:NBR
                P_temp = PBG(g+1)*PBR(r+1)*PNF(1:end-g-r,:,j); %+1 since also zero is included
                switch PDAMeta.xAxisUnit
                    case 'Proximity Ratio'
                        E_temp = (NF(1:end-g-r,:,j)+r)./(N(1:end-g-r,:,j)+g+r);
                        minE = 0; maxE = 1;
                    case 'log(FD/FA)'
                        E_temp = real(log10((N(1:end-g-r,:,1)-NF(1:end-g-r,:,1)+g)./(NF(1:end-g-r,:,1)+r)));
                        %minE = min(E_temp(:)); maxE = max(E_temp(:));
                        minE = h.AllTab.Main_Axes.XLim(1);
                        maxE = h.AllTab.Main_Axes.XLim(2);
                    case {'FRET efficiency','Distance'}
                        % Background correction
                        NF_cor = NF(1:end-g-r,:,j);
                        ND_cor = N(1:end-g-r,:,j)-NF(1:end-g-r,:,j);
                        % crosstalk and direct excitation correction
                        % (direct excitation based on Schuler method
                        % using the corrected total number of photon
                        % and the direct excitation factor as defined
                        % for PDA as p_de =
                        % eps_A^lambdaD/(eps_A^lambdaD+eps_D^lambdaD),
                        % i.e. the probability that the acceptor is
                        % excited by the donor laser using the
                        % exctinction coefficients at the donor
                        % excitation wavelength.
                        % see: Nettels, D. et al. Excited-state annihilation reduces power dependence of single-molecule FRET experiments. Physical Chemistry Chemical Physics 17, 32304-32315 (2015).
                        NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                        E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);
                        if strcmp(PDAMeta.xAxisUnit,'Distance')
                            valid_distance = E_temp > 0;
                            % convert to distance
                            E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                            E_temp = E_temp(valid_distance);
                            P_temp = P_temp(valid_distance);
                        end
                        %minE = min(E_temp(:)); maxE = max(E_temp(:));
                        minE = h.AllTab.Main_Axes.XLim(1);
                        maxE = h.AllTab.Main_Axes.XLim(2);
                end
                [~,~,bin{count}] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
                validd{count} = (bin{count} ~= 0);
                P_temp = P_temp(:);
                bin{count} = bin{count}(validd{count});
                P_temp = P_temp(validd{count});
                P_array{count} = P_temp;
                count = count+1;
            end
        end
        
        %%% Store bin,valid and P_array variables for brightness
        %%% correction
        PDAMeta.HistLib.bin{i}{j} = bin;
        PDAMeta.HistLib.P_array{i}{j} = P_array;
        PDAMeta.HistLib.valid{i}{j} = validd;
        
        P{1,j} = zeros(Nobins,1);
        count = 1;
        if ~UserValues.PDA.DeconvoluteBackground
            for g = 0:NBG
                for r = 0:NBR
                    %%% Approximation of P(F) ~= P(S), i.e. use
                    %%% P(S) with S = F + BG
                    PN_trans = repmat(PN_dummy(1+g+r:end),1,maxN+1);%the total number of fluorescence photons is reduced
                    PN_trans = PN_trans(:);
                    PN_trans = PN_trans(validd{count});
                    %P{1,j} = P{1,j} + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                    P{1,j} = P{1,j} + [accumarray_c(bin{count},P_array{count}.*PN_trans,max(bin{count}),numel(bin{count}))'; zeros(Nobins-max(bin{count}),1)];
                    count = count+1;
                end
            end
        else
            for g = 0:NBG
                for r = 0:NBR
                    %%% Use the deconvolved P(F)
                    PN_trans = repmat(PN_dummy(1:end-g-r),1,maxN+1);%the total number of fluorescence photons is reduced
                    PN_trans = PN_trans(:);
                    PN_trans = PN_trans(validd{count});
                    %P{1,j} = P{1,j} + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                    P{1,j} = P{1,j} + [accumarray_c(bin{count},P_array{count}.*PN_trans,max(bin{count}),numel(bin{count}))'; zeros(Nobins-max(bin{count}),1)];
                    count = count+1;
                end
            end
        end
    end
end
Progress((i-1+0.8)./numel(PDAMeta.Active),h.AllTab.Progress.Axes,h.AllTab.Progress.Text,'Preparing fit...');
Progress((i-1+0.8)./numel(PDAMeta.Active),h.SingleTab.Progress.Axes,h.SingleTab.Progress.Text,'Preparing fit...');
%% Caclulate shot noise limited histogram for Donly
if NBG == 0 && NBR == 0
    %for a particular value of E
    P_temp = PNF_donly;
    switch PDAMeta.xAxisUnit
        case 'Proximity Ratio'
            E_temp = NF(:,:,1)./N(:,:,1);
            minE = 0; maxE = 1;
        case 'log(FD/FA)'
            E_temp = real(log10((N(:,:,1)-NF(:,:,1))./NF(:,:,1)));
            %minE = min(E_temp(:)); maxE = max(E_temp(:));
            minE = h.AllTab.Main_Axes.XLim(1);
            maxE = h.AllTab.Main_Axes.XLim(2);
        case {'FRET efficiency','Distance'}
            NF_cor = NF(:,:,1);
            ND_cor = N(:,:,1)-NF(:,:,1);
            NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
            E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);
            if strcmp(PDAMeta.xAxisUnit,'Distance')
                valid_distance = E_temp > 0;
                % convert to distance
                E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                E_temp = E_temp(valid_distance);
                P_temp = P_temp(valid_distance);
            end
            %minE = min(E_temp(:)); maxE = max(E_temp(:));
            minE = h.AllTab.Main_Axes.XLim(1);
            maxE = h.AllTab.Main_Axes.XLim(2);
    end
    [~,~,bin] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
    validd = (bin ~= 0);
    P_temp = P_temp(:);
    bin = bin(validd);
    P_temp = P_temp(validd);
    
    PN_trans = repmat(PN_dummy,1,maxN+1);
    PN_trans = PN_trans(:);
    PN_trans = PN_trans(validd);
    P_donly = accumarray(bin,P_temp.*PN_trans);
else
    bin = cell((NBG+1)*(NBR+1),1);
    P_array = cell((NBG+1)*(NBR+1),1);
    validd = cell((NBG+1)*(NBG+1),1);
    count = 1;
    for g = 0:NBG
        for r = 0:NBR
            P_temp = PBG(g+1)*PBR(r+1)*PNF_donly(1:end-g-r,:); %+1 since also zero is included
            E_temp = (NF(1:end-g-r,:,1)+r)./(N(1:end-g-r,:,1)+g+r);
            switch PDAMeta.xAxisUnit
                case 'Proximity Ratio'
                    E_temp = (NF(1:end-g-r,:,1)+r)./(N(1:end-g-r,:,1)+g+r);
                    minE = 0; maxE = 1;
                case 'log(FD/FA)'
                    E_temp = real(log10((N(1:end-g-r,:,1)-NF(1:end-g-r,:,1)+g)./(NF(1:end-g-r,:,1)+r)));
                    %minE = min(E_temp(:)); maxE = max(E_temp(:));
                    minE = h.AllTab.Main_Axes.XLim(1);
                    maxE = h.AllTab.Main_Axes.XLim(2);
                case {'FRET efficiency','Distance'}
                    NF_cor = NF(1:end-g-r,:,1);
                    ND_cor = N(1:end-g-r,:,1)-NF(1:end-g-r,:,1);
                    NF_cor = NF_cor - PDAMeta.crosstalk(i)*ND_cor-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*ND_cor+NF_cor);
                    E_temp = NF_cor./(PDAMeta.gamma(i)*ND_cor+NF_cor);
                    if strcmp(PDAMeta.xAxisUnit,'Distance')
                        valid_distance = E_temp > 0;
                        % convert to distance
                        E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
                        E_temp = E_temp(valid_distance);
                        P_temp = P_temp(valid_distance);
                    end
                    %minE = min(E_temp); maxE = max(E_temp);
                    minE = h.AllTab.Main_Axes.XLim(1);
                    maxE = h.AllTab.Main_Axes.XLim(2);
            end
            [~,~,bin{count}] = histcounts(E_temp(:),linspace(minE,maxE,Nobins+1));
            validd{count} = (bin{count} ~= 0);
            P_temp = P_temp(:);
            bin{count} = bin{count}(validd{count});
            P_temp = P_temp(validd{count});
            P_array{count} = P_temp;
            count = count+1;
        end
    end
    
    P_donly = zeros(Nobins,1);
    count = 1;
    if ~UserValues.PDA.DeconvoluteBackground
        for g = 0:NBG
            for r = 0:NBR
                %%% Approximation of P(F) ~= P(S), i.e. use
                %%% P(S) with S = F + BG
                PN_trans = repmat(PN_dummy(1+g+r:end),1,maxN+1);%the total number of fluorescence photons is reduced
                PN_trans = PN_trans(:);
                PN_trans = PN_trans(validd{count});
                P_donly = P_donly + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                count = count+1;
            end
        end
    else
        for g = 0:NBG
            for r = 0:NBR
                %%% Use the deconvolved P(F)
                PN_trans = repmat(PN_dummy(1:end-g-r),1,maxN+1);%the total number of fluorescence photons is reduced
                PN_trans = PN_trans(:);
                PN_trans = PN_trans(validd{count});
                P_donly = P_donly + [accumarray(bin{count},P_array{count}.*PN_trans); zeros(Nobins-max(bin{count}),1)];
                count = count+1;
            end
        end
    end
end
% different files = different rows
% different Ps = different columns