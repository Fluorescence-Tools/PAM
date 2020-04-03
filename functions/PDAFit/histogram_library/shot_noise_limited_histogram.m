function H = shot_noise_limited_histogram(eps,NobinsE,maxN,PN,BG,BR,limits,i)
global PDAMeta
%%% Evaluate probability of combination of photon counts Sg and Sr
P_SgSr = PDA_histogram(maxN,PN,eps,BR,BG); % for some reason, BG and BR have to be assigned opposite as expected from the C code (?)
P_SgSr = reshape(P_SgSr,[maxN+1,maxN+1]);

[Sr, Sg] = meshgrid(0:1:maxN,0:1:maxN);

switch PDAMeta.xAxisUnit
    case 'Proximity Ratio'
        E_temp = Sr./(Sg+Sr);
        limits = [0,1];
    case 'log(FD/FA)'
        E_temp = real(log10(Sg./Sr));
    case {'FRET efficiency','Distance'}
        % Background correction (F = fluorescence photons)
        Fr = Sr - BR;
        Fg = Sg - BG;
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
        Fr = Fr - PDAMeta.crosstalk(i)*Fg-PDAMeta.directexc(i)*(PDAMeta.gamma(i)*Fg+Fr);
        E_temp = Fr./(PDAMeta.gamma(i)*Fg+Fr);
        if strcmp(PDAMeta.xAxisUnit,'Distance')
            valid_distance = E_temp > 0;
            % convert to distance
            E_temp = real(PDAMeta.R0(i)*(1./E_temp-1).^(1/6));
            E_temp = E_temp(valid_distance);
            P_temp = P_temp(valid_distance);
        end
end
[~,~,bin] = histcounts(E_temp(:),linspace(limits(1),limits(2),NobinsE));
P_SgSr = P_SgSr(:);
H = accumarray(bin(bin~=0),P_SgSr(bin~=0));