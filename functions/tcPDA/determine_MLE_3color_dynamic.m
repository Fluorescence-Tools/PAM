function [ P_result ] = determine_MLE_3color_dynamic(fitpar)
global tcPDAstruct

%10 fit par:
%1 Amplitude
%3 Distances
%3 sigma
%3 elements of cov mat

if ~tcPDAstruct.use_stochasticlabeling
    %%% No stochastic labeling correction
    N_gauss = numel(fitpar)/10; 

    for i = 1:N_gauss
        A(i) =fitpar((i-1)*10+1);
        Rgr(i) = fitpar((i-1)*10+2);
        sigma_Rgr(i) = fitpar((i-1)*10+3);
        Rbg(i) = fitpar((i-1)*10+4);
        sigma_Rbg(i) = fitpar((i-1)*10+5);
        Rbr(i) = fitpar((i-1)*10+6);
        sigma_Rbr(i) = fitpar((i-1)*10+7);
        simga_Rbg_Rbr(i) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(i) = fitpar((i-1)*10+9);
        simga_Rbr_Rgr(i) = fitpar((i-1)*10+10);
    end
elseif tcPDAstruct.use_stochasticlabeling
    %%% use stochastic labeling correction
    %%% this means: every population gets a second population with equal
    %%% RGR but switched RBG and RBR. The fraction of this population is
    %%% given by as well
    
    %%% stochastic labeling can be a fit parameter
    if ~tcPDAstruct.fix_stochasticlabeling
        fraction_stochasticlabeling = fitpar(end);
        fitpar(end) = [];
    else
        fraction_stochasticlabeling = tcPDAstruct.fraction_stochasticlabeling;
    end
    
    N_gauss = numel(fitpar)/10;
    
    for i = 1:N_gauss
        %%% normal population at position 2*i-1 (1,3,5,7...)
        A(2*i-1) =fitpar((i-1)*10+1)*fraction_stochasticlabeling; %%% multiplied with fraction of "normal" population
        Rgr(2*i-1) = fitpar((i-1)*10+2);
        sigma_Rgr(2*i-1) = fitpar((i-1)*10+3);
        Rbg(2*i-1) = fitpar((i-1)*10+4);
        sigma_Rbg(2*i-1) = fitpar((i-1)*10+5);
        Rbr(2*i-1) = fitpar((i-1)*10+6);
        sigma_Rbr(2*i-1) = fitpar((i-1)*10+7);
        simga_Rbg_Rbr(2*i-1) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(2*i-1) = fitpar((i-1)*10+9);
        simga_Rbr_Rgr(2*i-1) = fitpar((i-1)*10+10);
        %%% second population at position 2*i (2,4,6,8...)
        A(2*i) =fitpar((i-1)*10+1)*(1-fraction_stochasticlabeling);%%% multiplied with fraction of second population
        Rgr(2*i) = fitpar((i-1)*10+2);
        sigma_Rgr(2*i) = fitpar((i-1)*10+3);
        Rbg(2*i) = fitpar((i-1)*10+6); %%% switched with RBR
        sigma_Rbg(2*i) = fitpar((i-1)*10+7);%%% switched with sigma_RBR
        Rbr(2*i) = fitpar((i-1)*10+4);%%% switched with RBG
        sigma_Rbr(2*i) = fitpar((i-1)*10+5);%%% switched with sigma_RBG
        simga_Rbg_Rbr(2*i) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(2*i) = fitpar((i-1)*10+10); %%% switched with sigma_Rbr_Rgr
        simga_Rbr_Rgr(2*i) = fitpar((i-1)*10+9); %%% switched with sigma_Rbg_Rgr
    end
    N_gauss = 2*N_gauss;
end
A = A./sum(A);

%read corrections
corrections = tcPDAstruct.corrections;
corrections.gamma_bg = corrections.gamma_br/corrections.gamma_gr;

corrections.steps = 4;
%valid = Cut_Data([],[]);
dur = tcPDAstruct.duration(tcPDAstruct.valid);
%H_meas = tcPDAstruct.H_meas;
corrections.pe_b = 1-corrections.de_br-corrections.de_bg; %probability of blue excitation

P_res = cell(N_gauss,1);
for j=1:N_gauss
    MU = [Rbg(j), Rbr(j), Rgr(j)];
    COV =[sigma_Rbg(j).^2, simga_Rbg_Rbr(j) ,simga_Rbg_Rgr(j);...
          simga_Rbg_Rbr(j),sigma_Rbr(j).^2,simga_Rbr_Rgr(j);...
          simga_Rbg_Rgr(j),simga_Rbr_Rgr(j),sigma_Rgr(j).^2];
    [~,err] = cholcov(COV,0);
    while err ~= 0 %any(eig(COV)< 0)
        %COV = nearestSPD(COV);
       [COV] = fix_covariance_matrix(COV);
       [~,err] = cholcov(COV,0);
    end
    
    param.MU = MU;
    param.COV = COV;
    P_res{j} = posterior_tc(tcPDAstruct.fbb,tcPDAstruct.fbg,tcPDAstruct.fbr,tcPDAstruct.fgg,tcPDAstruct.fgr,dur,corrections,param);
end

if tcPDAstruct.BrightnessCorrection
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        PNGX_scaled = cell(N_gauss,1);
        PNBX_scaled = cell(N_gauss,1);
        for c = 1:N_gauss
            [Qr_g,Qr_b] = calc_relative_brightness(Rgr(c),Rbg(c),Rbr(c));
            %%% Rescale the PN;
            PNGX_scaled{c} = scalePN(tcPDAstruct.BrightnessReference.PNG,Qr_g);
            PNGX_scaled{c} = smooth(PNGX_scaled{c},10);
            PNGX_scaled{c} = PNGX_scaled{c}./sum(PNGX_scaled{c});
            PNBX_scaled{c} = scalePN(tcPDAstruct.BrightnessReference.PNB,Qr_b);
            PNBX_scaled{c} = smooth(PNBX_scaled{c},10);
            PNBX_scaled{c} = PNBX_scaled{c}./sum(PNBX_scaled{c});
        end
        %%% calculate the relative probabilty
        PGX_norm = sum(horzcat(PNGX_scaled{:}),2);
        PBX_norm = sum(horzcat(PNBX_scaled{:}),2);
        for c = 1:N_gauss
            PNGX_scaled{c}(PGX_norm~=0) = PNGX_scaled{c}(PGX_norm~=0)./PGX_norm(PGX_norm~=0);
            PNBX_scaled{c}(PBX_norm~=0) = PNBX_scaled{c}(PBX_norm~=0)./PBX_norm(PBX_norm~=0);
            %%% We don't want zero probabilities here!
            PNGX_scaled{c}(PNGX_scaled{c} == 0) = eps;
            PNBX_scaled{c}(PNBX_scaled{c} == 0) = eps;
            %%% Treat case where measured bursts have higher photon number than
            %%% reference
            %%% -> Set probability to 1/N_gauss then
            if numel(PNGX_scaled{c}) < max(tcPDAstruct.fgg+tcPDAstruct.fgr)
                PNGX_scaled{c}(numel(PNGX_scaled{c})+1 : max(tcPDAstruct.fgg+tcPDAstruct.fgr)) = 1/N_gauss;
            end
            if numel(PNBX_scaled{c}) < max(tcPDAstruct.fbb+tcPDAstruct.fbg+tcPDAstruct.fbr)
                PNBX_scaled{c}(numel(PNBX_scaled{c})+1 :  max(tcPDAstruct.fbb+tcPDAstruct.fbg+tcPDAstruct.fbr)) = 1/N_gauss;
            end
            %%% Treat case of zero photons
            PNGX_scaled{c} = [1/N_gauss;PNGX_scaled{c}];
            PNBX_scaled{c} = [1/N_gauss;PNBX_scaled{c}];
        end
        
        
        
        for c = 1:N_gauss
            P_res{c} = P_res{c} + log(PNGX_scaled{c}(1+tcPDAstruct.fgg+tcPDAstruct.fgr)) + log(PNBX_scaled{c}(1+tcPDAstruct.fbb+tcPDAstruct.fbg+tcPDAstruct.fbr)); % +1 for zero photon case
        end
end

%%% combine the likelihoods of the Gauss
PA = A;
P_res = horzcat(P_res{:});
P_res = P_res + repmat(log(PA),numel(tcPDAstruct.fbb),1);
Lmax = max(P_res,[],2);
P_res = Lmax + log(sum(exp(P_res-repmat(Lmax,1,numel(PA))),2));
%%% P_res has NaN values if Lmax was -Inf (i.e. total of zero probability)!
%%% Reset these values to -Inf
P_res(isnan(P_res)) = -Inf;
P_result = sum(P_res);
%%% since the algorithm minimizes, it is important to minimize the negative
%%% log likelihood, i.e. maximize the likelihood
P_result = (-1)*double(P_result);

if tcPDAstruct.use_stochasticlabeling
    %%% reset N_gauss to number of populations
    N_gauss = N_gauss/2;
end
%%% Update Fit Parameter in global struct
for i = 1:N_gauss
    tcPDAstruct.fitdata.param{i}(1:10) = fitpar(((i-1)*10+1):((i-1)*10+10));
end
if tcPDAstruct.use_stochasticlabeling && ~tcPDAstruct.fix_stochasticlabeling
    tcPDAstruct.fraction_stochasticlabeling = fraction_stochasticlabeling;
end
%%% update BIC
fixed = tcPDAstruct.fitdata.fixed(1:N_gauss);
n_param = sum(~vertcat(fixed{:}));
n_data = numel(tcPDAstruct.fbb);
%%% BIC = -2*lnL + #params * ln(# data points)
%%% P_result is already -lnL
tcPDAstruct.BIC = 2*P_result + n_param*log(n_data);
tcPDAstruct.logL = -P_result;

function P_res = posterior_dynamic(fbb,fbg,fbr,fgg,fgr,dur,corrections,param1,param2)
global tcPDAstruct UserValues
%%% evaluates the loglikelihood that param produce data
%%%
%%% input:
%%% data    -   structure containing the data
%%%             data.fbb,data.fbg ... etc
%%% corrections - structure containing the corretions
%%%               R0bg, R0br, R0gr
%%%               gamma_bg, gamma_br, gamma_gr
%%%               ct_bg, ct_br, ct_gr
%%%               de_bg, de_br, de_gr
%%%               bg_bb, bg_bg, bg_br, bg_gg, bg_gr
%%%               steps: Steps to use for R grid
%%% param   -   contains the parameters
%%%             Rbg, Rbr, Rgr x2
%%%             sigma_bg, sigma_br, sigma_gr x2
%%%             k12, k21

%%% read out parameters
Rbg = [param1.MU(1), param2.MU(1)];
Rbr = [param1.MU(2), param2.MU(2)];
Rgr = [param1.MU(3), param2.MU(3)];
% distribution widths currently not used (yet)
sigma_bg = sqrt([param1.COV(1,1) param2.COV(1,1)]);
sigma_br = sqrt([param1.COV(2,2) param2.COV(2,2)]);
sigma_gr = sqrt([param1.COV(3,3) param2.COV(3,3)]);

BG_bb = corrections.background.BGbb;
BG_bg = corrections.background.BGbg;
BG_br = corrections.background.BGbr;
BG_gg = corrections.background.BGgg;
BG_gr = corrections.background.BGgr;
NBGbb = corrections.background.NBGbb;
NBGbg = corrections.background.NBGbg;
NBGbr = corrections.background.NBGbr;
NBGgg = corrections.background.NBGgg;
NBGgr = corrections.background.NBGgr;

%% Dynamics
%%% define the array of state occupancies (dynamic mixing)

%%% calculate expected E values for states
EBG = 1./(1+(Rbg./corrections.R0_bg).^6);
EBR = 1./(1+(Rbr./corrections.R0_br).^6);
EGR = 1./(1+(XRgr./corrections.R0_gr).^6);

PGR = 1-(1+corrections.ct_gr+(((corrections.de_gr/(1-corrections.de_gr)) + EGR) * corrections.gamma_gr)./(1-EGR)).^(-1);

EBG_R = EBG.*(1-EBR)./(1-EBG.*EBR);
EBR_G = EBR.*(1-EBG)./(1-EBG.*EBR);
E1A = EBG_R + EBR_G;

pe_b = 1-corrections.de_bg - corrections.de_br;

Pout_B = pe_b.*(1-E1A);

Pout_G = pe_b.*(1-E1A).*corrections.ct_bg + ...
    pe_b.*EBG_R.*(1-EGR).*corrections.gamma_bg + ...
    corrections.de_bg.*(1-EGR).*corrections.gamma_bg;

Pout_R = pe_b.*(1-E1A).*corrections.ct_br + ...
    pe_b.*EBG_R.*(1-EGR).*corrections.gamma_bg.*corrections.ct_gr + ...
    pe_b.*EBG_R.*EGR.*corrections.gamma_br + ...
    pe_b.*EBR_G.*corrections.gamma_br + ...
    corrections.de_bg.*(1-EGR).*corrections.gamma_bg.*corrections.ct_gr + ...
    corrections.de_bg.*EGR.*corrections.gamma_br + ...
    corrections.de_br.*corrections.gamma_br;

P_total = Pout_B+Pout_G+Pout_R;

PBB = Pout_B./P_total;
PBG = Pout_G./P_total;
PBR = Pout_R./P_total;

%%% evaluate dynamic distribution
dT = 1; % time bin in milliseconds
N = 25;
k1 = param.k12;
k2 = param.k21;
PofT = calc_dynamic_distribution(dT,N,k1,k2);
%%% calculate relative brightnesses
for i = 1:2
    [Qr_g(i),Qr_b(i)] = calc_relative_brightness(Rgr(i),Rbg(i),Rbr(i));
end
%%% calculate mixed FRET efficiencies
t = linspace(0,1,N+1); % cumulative time spent in each state
PBB_mix = (t.*Qr_b(1).*PBB(1)+(1-t).*Qr_b(2).*PBB(2))./(t.*Qr_b(1)+(1-t).*Qr_b(2));
PBG_mix = (t.*Qr_b(1).*PBG(1)+(1-t).*Qr_b(2).*PBG(2))./(t.*Qr_b(1)+(1-t).*Qr_b(2));
PBR_mix = (t.*Qr_b(1).*PBR(1)+(1-t).*Qr_b(2).*PBR(2))./(t.*Qr_b(1)+(1-t).*Qr_b(2));
PGR_mix = (t.*Qr_g(1).*PGR(1)+(1-t).*Qr_g(2).*PGR(2))./(t.*Qr_g(1)+(1-t).*Qr_g(2));

% remove first and last bin as they will be treated as pseudo-static later,
% including a correct treatment of the distribution width
PBB_mix = PBB_mix(2:end-1);
PBG_mix = PBG_mix(2:end-1);
PBR_mix = PBR_mix(2:end-1);
PGR_mix = PGR_mix(2:end-1);

%%% evaluate dynamic part
if strcmp(tcPDAstruct.timebin,'burstwise')
    %%% burstwise, indivual backgrounds used
    disp('Burstwise datasets do not support fitting of kinetics yet.');
    P_res = Inf;
    return;
elseif isnumeric(tcPDAstruct.timebin)
    %% CUDA
    if (gpuDeviceCount > 0) && ~tcPDAstruct.GPU_locked
        if UserValues.tcPDA.UseCUDAKernel %%% use CUDAKernel implementation
            %%% transfer data to GPU
            PBB_gpu = gpuArray(single(PBB_mix));
            PBG_gpu = gpuArray(single(PBG_mix));
            PGR_gpu = gpuArray(single(PGR_mix));
            P_dyn = feval(tcPDAstruct.CUDAKernel.k,tcPDAstruct.CUDAKernel.likelihood,...
                tcPDAstruct.CUDAKernel.fbb,tcPDAstruct.CUDAKernel.fbg,tcPDAstruct.CUDAKernel.fbr,tcPDAstruct.CUDAKernel.fgg,tcPDAstruct.CUDAKernel.fgr,...
                tcPDAstruct.CUDAKernel.NBGbb,tcPDAstruct.CUDAKernel.NBGbg,tcPDAstruct.CUDAKernel.NBGbr,tcPDAstruct.CUDAKernel.NBGgg,tcPDAstruct.CUDAKernel.NBGgr,...
                tcPDAstruct.CUDAKernel.BG_bb,tcPDAstruct.CUDAKernel.BG_bg,tcPDAstruct.CUDAKernel.BG_br,tcPDAstruct.CUDAKernel.BG_gg,tcPDAstruct.CUDAKernel.BG_gr,...
                PBB_gpu,PBG_gpu,PGR_gpu,numel(PBB_mix),numel(fbb));
            P_dyn = reshape(gather(PP_dyn),numel(PBB_mix),numel(fbb))';
            %%% clear data from GPU to avoid memory leak
            clear PBB_gpu PBG_gpu PGR_gpu
        else %%% use mex file CUDA implementation
            %%% the mex file has to be recompiled for different
            %%% architectures
            fbb_single = single(fbb);
            fbg_single = single(fbg);
            fbr_single = single(fbr);
            fgg_single = single(fgg);
            fgr_single = single(fgr);

            NBGbb_single = int32(NBGbb);
            NBGbg_single = int32(NBGbg);
            NBGbr_single = int32(NBGbr);
            NBGgg_single = int32(NBGgg);
            NBGgr_single = int32(NBGgr);

            BG_bb_single = single(BG_bb);
            BG_bg_single = single(BG_bg);
            BG_br_single = single(BG_br);
            BG_gg_single = single(BG_gg);
            BG_gr_single = single(BG_gr);

            PBB_single = single(PBB_mix);
            PBG_single = single(PBG_mix);
            PGR_single = single(PGR_mix);

            P_dyn = eval_prob_3c_bg_cuda(fbb_single,fbg_single,fbr_single,fgg_single,fgr_single,...
                    NBGbb_single,NBGbg_single,NBGbr_single,NBGgg_single,NBGgr_single,...
                    BG_bb_single',BG_bg_single',BG_br_single',BG_gg_single',BG_gr_single',...
                    PBB_single,PBG_single,PGR_single);
            P_dyn = double(P_dyn);
        end
    else
        %% CPU
        P_dyn = eval_prob_3c_bg_lib(fbb,fbg,fbr,fgg,fgr,...
                NBGbb,NBGbg,NBGbr,NBGgg,NBGgr,...
                BG_bb',BG_bg',BG_br',BG_gg',BG_gr',...
                PBB_mix,PBG_mix,PGR_mix,tcPDAstruct.lib_b,tcPDAstruct.lib_t);
    end
end

%% add pseudo-static populations
P_static1 = posterior_tc(fbb,fbg,fbr,fgg,fgr,dur,corrections,param1);
P_static2 = posterior_tc(fbb,fbg,fbr,fgg,fgr,dur,corrections,param2);

%%% recombined static and dynamic arrays
P = [P_static1 P_dyn P_static2];
P = log(P) + repmat(log(PofT'),numel(fbb),1);
Lmax = max(P,[],2);
P = Lmax + log(sum(exp(P-repmat(Lmax,1,numel(PofT))),2));
%%% Treat case when all burst produced zero probability
P_res = P;
P_res(isnan(P_res)) = -Inf;

function PofT = calc_dynamic_distribution(dT,N,k1,k2)
%%% Calculates probability distribution of dynamic mixing of states for
%%% two-state kinetic scheme
%%% Inputs:
%%% dT  -   Bin time
%%% N   -   Number of time steps to compute
%%% k1  -   Rate from state 1 to state 2
%%% k2  -   Rate from state 2 to state 1

% Split in N+1 time bins
PofT = zeros(1,N+1);
dt = dT/N;

%%% catch special case where k1 = k2 = 0
if (k1 == 0) && (k2 == 0)
    %%% No dynamics, i.e. equal weights
    PofT(1) = 0.5;
    PofT(end) = 0.5;
    return;
end
%%% first and last bin are special cases
PofT(1) = k1/(k1+k2)*exp(-k2*dT) + calcPofT(k1,k2,dt/2,dT-dt/2,dt/2);
PofT(end) = k2/(k1+k2)*exp(-k1*dT) + calcPofT(k1,k2,dT-dt/2,dt/2,dt/2);

%%% rest is determined by formula (2d) in paper giving P(i*dt-dt/2 < T < i*dt+dt/2)
for i = 1:N-1
    T1 = i*dt;
    T2 = dT-T1;
    PofT(i+1) = calcPofT(k1,k2,T1,T2,dt); 
end
PofT = PofT./sum(PofT);


function PofT = calcPofT(k1,k2,T1,T2,dt)
%%% calculates probability for cumulative time spent in state 1(T1) to lie
%%% in range T1-dt, T1+dt based on formula from Seidel paper
%%% besseli is the MODIFIED bessel function of first kind
PofT = (...
       (2*k1*k2/(k1+k2))*besseli(0,2*sqrt(k1*k2*T1*T2)) + ...
       ((k2*T1+k1*T2)/(k1+k2))*(sqrt(k1*k2)/sqrt(T1*T2))*...
       besseli(1,2*sqrt(k1*k2*T1*T2)) ...
       ) * exp(-k1*T1-k2*T2)*dt;