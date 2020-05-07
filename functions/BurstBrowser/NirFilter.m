function [ALEX_2CDE, FRET_2CDE, E_D, E_A] = NirFilter(Macrotime,Channel,tau_2CDE,ClockPeriod,BAMethod)
global UserValues
tau = tau_2CDE*1E-6/ClockPeriod;

if any(BAMethod == [1,2,5,6]) %2 Color Data
    FRET_2CDE = zeros(numel(Macrotime),1); %#ok<USENS>
    ALEX_2CDE = zeros(numel(Macrotime),1);
    
    %%% Split into 10 parts to display progress
    parts = (floor(linspace(1,numel(Macrotime),11)));
    for j = 1:10
        %Progress((j-1)/10,h.Progress.Axes, h.Progress.Text,tex);
        parfor (i = parts(j):parts(j+1),UserValues.Settings.Pam.ParallelProcessing)
            if ~(numel(Macrotime{i}) > 1E5)
                [FRET_2CDE(i), ALEX_2CDE(i), E_D(i), E_A(i)] = KDE(Macrotime{i}',Channel{i}',tau, BAMethod); %#ok<USENS,PFIIN>
            else
                ALEX_2CDE(i) = NaN;
                FRET_2CDE(i) = NaN;
                E_D(i) = NaN;
                E_A(i) = NaN;
            end
        end
    end
elseif any(BAMethod == [3,4]) %3 Color Data
    FRET_2CDE = zeros(numel(Macrotime),3);
    ALEX_2CDE = zeros(numel(Macrotime),3);
    %%% Split into 10 parts to display progress
    parts = (floor(linspace(1,numel(Macrotime),11)));
    for j = 1:10
        %Progress((j-1)/10,h.Progress.Axes, h.Progress.Text,tex);
        parfor (i = parts(j):parts(j+1),UserValues.Settings.Pam.ParallelProcessing)
            if ~(numel(Macrotime{i}) > 1E5)
                [FRET_2CDE(i,:), ALEX_2CDE(i,:)] = KDE_3C(Macrotime{i}',Channel{i}',tau); %#ok<PFIIN>
            else
                FRET_2CDE(i,:) = NaN(1,3);
                ALEX_2CDE(i,:) = NaN(1,3);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function related to 2CDE filter calcula tion (Nir-Filter) %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [KDE]= kernel_density_estimate(A,B,tau) %KDE of B around A
%%% error checkup to catch empty arrays
if nargin == 2
    if isempty(A)
        KDE = [];
        return;
    end
elseif nargin == 3
    if isempty(A)
        KDE = [];
        return;
    elseif isempty(B)
        KDE = zeros(numel(A),1);
        return;
    end
end
mex = true;
if mex
    if nargin == 3
        KDE = KDE_mex(double(A),double(B),tau,numel(A),numel(B));
    elseif nargin == 2 %%% B is tau
        KDE = KDE_mex(double(A),double(A),B,numel(A),numel(A));
    end
    KDE = KDE';
else
    if nargin == 3
        M = abs(ones(numel(B),1)*A - B'*ones(1,numel(A)));
        M(M>5*tau) = 0;
        E = exp(-M./tau);
        E(M==0) = 0;
        KDE = sum(E,1)';
        %    KDE = KDE_mex(B,A,tau,numel(B),numel(A));
    elseif nargin == 2
        tau = B;
        M = abs(ones(numel(A),1)*A - A'*ones(1,numel(A)));
        M(M>5*tau) = 0;
        E = exp(-M./tau);
        E(M==0) = 0;
        KDE = sum(E,1)'+1;
    end
end

function [KDE]= nb_kernel_density_estimate(B,tau) %non biased KDE of B around B
%%% error checkup to catch empty arrays
if isempty(B)
    KDE = 0;
    return;
end
mex = true;
if mex
    KDE = KDE_mex(double(B),double(B),tau,numel(B),numel(B));
    KDE = KDE'-1; %%% need to subtract one because zero lag is counter here
else
    M = abs(ones(numel(B),1)*B - B'*ones(1,numel(B)));
    M(M>5*tau) = 0;
    E = exp(-M./tau);
    E(M==0) = 0;
    KDE = sum(E,1)';
end
KDE = (1+2/numel(B)).*KDE;

function [FRET_2CDE, ALEX_2CDE,E_D,E_A] = KDE(Trace,Chan_Trace,tau,BAMethod)
%%% Additional output:
%%% (E)_D = E_D - FRET efficiency estimated around donor photons
%%% (1-E)_A = E_A - 1-FRET efficiency estimated around
%%% acceptor photons
%%%
%%% These quantities are used to calculate FRET_2CDE by:
%%% FRET_2CDE = 110 - 100 x ( (E)_D + (1-E)_A )
%%%
%%% They are needed in BurstBrowser to perform correct averaging of the 
%%% FRET-2CDE filter over a set of bursts.
switch BAMethod
    case {1,2} %MFD
        T_GG = Trace(Chan_Trace == 1 | Chan_Trace == 2);
        T_GR = Trace(Chan_Trace == 3 | Chan_Trace == 4);
        T_RR = Trace(Chan_Trace == 5 | Chan_Trace == 6);
        T_GX = Trace(Chan_Trace == 1 | Chan_Trace == 2 | Chan_Trace == 3 | Chan_Trace == 4);
    case {5,6} %noMFD
        T_GG = Trace(Chan_Trace == 1);
        T_GR = Trace(Chan_Trace == 2);
        T_RR = Trace(Chan_Trace == 3);
        T_GX = Trace(Chan_Trace == 1 | Chan_Trace == 2);
end
%tau = 100E-6; standard value
%KDE calculation

%KDE of A(GR) around D (GG)
KDE_GR_GG = kernel_density_estimate(T_GG,T_GR,tau);
%KDE of D(GG) around D (GG)
KDE_GG_GG = nb_kernel_density_estimate(T_GG,tau);
%KDE of A(GR) around A (GR)
KDE_GR_GR = nb_kernel_density_estimate(T_GR,tau);
%KDE of D(GG) around A(GR)
KDE_GG_GR = kernel_density_estimate(T_GR,T_GG,tau);
%KDE of D(GX) around D (GX)
KDE_GX_GX = kernel_density_estimate(T_GX,tau);
%KDE of A(RR) around A(RR)
KDE_RR_RR = kernel_density_estimate(T_RR,tau);
%KDE of A(RR) around D (GX)
KDE_RR_GX = kernel_density_estimate(T_GX,T_RR,tau);
%KDE of D(GX) around A (RR)
KDE_GX_RR = kernel_density_estimate(T_RR,T_GX,tau);
%calculate FRET-2CDE
%(E)_D
%check for case of denominator == 0!
valid = (KDE_GR_GG+KDE_GG_GG) ~= 0;
E_D = (1/(numel(T_GG)-sum(~valid))).*sum(KDE_GR_GG(valid)./(KDE_GR_GG(valid)+KDE_GG_GG(valid)));
%(1-E)_A
%check for case of denominator == 0!
valid = (KDE_GG_GR+KDE_GR_GR) ~= 0;
E_A = (1/(numel(T_GR)-sum(~valid))).*sum(KDE_GG_GR(valid)./(KDE_GG_GR(valid)+KDE_GR_GR(valid)));
FRET_2CDE = 110 - 100*(E_D+E_A);

%calculate ALEX / PIE 2CDE
%Brightness ratio Dex
BR_D = (1/numel(T_RR)).*sum(KDE_RR_GX./KDE_GX_GX);
%Brightness ration Aex
BR_A =(1/numel(T_GX)).*sum(KDE_GX_RR./KDE_RR_RR);
ALEX_2CDE = 100-50*(BR_D+BR_A);

function [FRET_2CDE, ALEX_2CDE] = KDE_3C(Trace,Chan_Trace,tau)
%Trace(i) and Chan_Trace(i) are referring to the burstsearc
%internal sorting and not related to the channel mapping in the
%pam and Burstsearch GUI, they originate from the row th data is
%imported at hte begining of this function

T_BB = Trace(Chan_Trace == 1 | Chan_Trace == 2);
T_BG = Trace(Chan_Trace == 3 | Chan_Trace == 4);
T_BR = Trace(Chan_Trace == 5 | Chan_Trace == 6);
T_GG = Trace(Chan_Trace == 7 | Chan_Trace == 8);
T_GR = Trace(Chan_Trace == 9 | Chan_Trace == 10);
T_RR = Trace(Chan_Trace == 11 | Chan_Trace == 12);
T_BX = Trace(Chan_Trace == 1 | Chan_Trace == 2 | Chan_Trace == 3 | Chan_Trace == 4 | Chan_Trace == 5 | Chan_Trace == 6);
T_GX = Trace(Chan_Trace == 7 | Chan_Trace == 8 | Chan_Trace == 9 | Chan_Trace == 10);

%tau = 100E-6; fallback value

%KDE calculation for FRET_2CDE

%KDE of BB around BB
KDE_BB_BB = nb_kernel_density_estimate(T_BB,tau);
%KDE of BG around BG
KDE_BG_BG = nb_kernel_density_estimate(T_BG,tau);
%KDE of BR around BR
KDE_BR_BR = nb_kernel_density_estimate(T_BR,tau);
%KDE of BG around BB
KDE_BG_BB = kernel_density_estimate(T_BB,T_BG,tau);
%KDE of BR around BB
KDE_BR_BB = kernel_density_estimate(T_BB,T_BR,tau);
%KDE of BB around BG
KDE_BB_BG = kernel_density_estimate(T_BG,T_BB,tau);
%KDE of BB around BR
KDE_BB_BR = kernel_density_estimate(T_BR,T_BB,tau);
%KDE of A(GR) around D (GG)
KDE_GR_GG = kernel_density_estimate(T_GG,T_GR,tau);
%KDE of D(GG) around D (GG)
KDE_GG_GG = nb_kernel_density_estimate(T_GG,tau);
%KDE of A(GR) around A (GR)
KDE_GR_GR = nb_kernel_density_estimate(T_GR,tau);
%KDE of D(GG) around A(GR)
KDE_GG_GR = kernel_density_estimate(T_GR,T_GG,tau);

%KDE for ALEX_2CDE

%KDE of BX around BX
KDE_BX_BX = kernel_density_estimate(T_BX,tau);
%KDE of GX around BX
KDE_GX_BX = kernel_density_estimate(T_BX,T_GX,tau);
%KDE of BX around GX
KDE_BX_GX = kernel_density_estimate(T_GX,T_BX,tau);
%KDE of A(RR) around D (BX)
KDE_RR_BX = kernel_density_estimate(T_BX,T_RR,tau);
%KDE of BX around RR
KDE_BX_RR = kernel_density_estimate(T_RR,T_BX,tau);
%KDE of D(GX) around D (GX)
KDE_GX_GX = kernel_density_estimate(T_GX,tau);
%KDE of A(RR) around A(RR)
KDE_RR_RR = kernel_density_estimate(T_RR,tau);
%KDE of A(RR) around D (GX)
KDE_RR_GX = kernel_density_estimate(T_GX,T_RR,tau);
%KDE of D(GX) around A (RR)
KDE_GX_RR = kernel_density_estimate(T_RR,T_GX,tau);

%calculate FRET-2CDE based on proximity ratio for BG,BR

%BG
%(E)_D
%check for case of denominator == 0!
valid = (KDE_BG_BB+KDE_BB_BB) ~= 0;
E_D = (1/(numel(T_BB)-sum(~valid))).*sum(KDE_BG_BB(valid)./(KDE_BG_BB(valid)+KDE_BB_BB(valid)));
%(1-E)_A
valid = (KDE_BB_BG+KDE_BG_BG) ~= 0;
E_A = (1/(numel(T_BG)-sum(~valid))).*sum(KDE_BB_BG(valid)./(KDE_BB_BG(valid)+KDE_BG_BG(valid)));
FRET_2CDE(1,1) = 110 - 100*(E_D+E_A);
%BR
valid = (KDE_BR_BB+KDE_BB_BB) ~= 0;
E_D = (1/(numel(T_BB)-sum(~valid))).*sum(KDE_BR_BB(valid)./(KDE_BR_BB(valid)+KDE_BB_BB(valid)));
%(1-E)_A
valid = (KDE_BB_BR+KDE_BR_BR) ~= 0;
E_A = (1/(numel(T_BR)-sum(~valid))).*sum(KDE_BB_BR(valid)./(KDE_BB_BR(valid)+KDE_BR_BR(valid)));
FRET_2CDE(1,2) = 110 - 100*(E_D+E_A);
%GR
%(E)_D
valid = (KDE_GR_GG+KDE_GG_GG) ~= 0;
E_D = (1/(numel(T_GG)-sum(~valid))).*sum(KDE_GR_GG(valid)./(KDE_GR_GG(valid)+KDE_GG_GG(valid)));
%(1-E)_A
valid = (KDE_GG_GR+KDE_GR_GR) ~= 0;
E_A = (1/(numel(T_GR)-sum(~valid))).*sum(KDE_GG_GR(valid)./(KDE_GG_GR(valid)+KDE_GR_GR(valid)));
FRET_2CDE(1,3) = 110 - 100*(E_D+E_A);

%calculate ALEX / PIE 2CDE

%BG
%Brightness ratio Dex
BR_D = (1/numel(T_GX)).*sum(KDE_GX_BX./KDE_BX_BX);
%Brightness ration Aex
BR_A =(1/numel(T_BX)).*sum(KDE_BX_GX./KDE_GX_GX);
ALEX_2CDE(1,1) = 100-50*(BR_D+BR_A);

%BR
%Brightness ratio Dex
BR_D = (1/numel(T_RR)).*sum(KDE_RR_BX./KDE_BX_BX);
%Brightness ration Aex
BR_A =(1/numel(T_BX)).*sum(KDE_BX_RR./KDE_RR_RR);
ALEX_2CDE(1,2) = 100-50*(BR_D+BR_A);

%GR
%Brightness ratio Dex
BR_D = (1/numel(T_RR)).*sum(KDE_RR_GX./KDE_GX_GX);
%Brightness ration Aex
BR_A =(1/numel(T_GX)).*sum(KDE_GX_RR./KDE_RR_RR);
ALEX_2CDE(1,3) = 100-50*(BR_D+BR_A);
