function [out, func, xval] = conversion_tau_3C(tauD,R0BG,R0BR,sBG,sBR)
global BurstData BurstMeta
res = 10;
xval = linspace(0,tauD,1000);
%range of RDA center values, i.e. 100 values in 0.1*R0 to 10*R0
[RBG, RBR] = meshgrid(linspace(0*R0BG,4*R0BG,100),linspace(0*R0BR,4*R0BR,100));
RBG = RBG(:);
RBR = RBR(:);
%RBG = linspace(0*R0BG,4*R0BG,res);
%RBR = linspace(0*R0BR,4*R0BR,res);
n = numel(RBG);
%for every R calculate gaussian distribution
p = zeros(res,res,n);
rBG = zeros(res,res,n);
rBR = zeros(res,res,n);
for j = 1:n
    [xRBG, xRBR] = meshgrid(linspace(RBG(j)-3*sBG,RBG(j)+3*sBG,res),linspace(RBR(j)-3*sBR,RBR(j)+3*sBR,res));
    dummy = exp(-( ((xRBG-RBG(j)).^2)./(2*sBG^2) + ((xRBR-RBR(j)).^2)./(2*sBR^2) ));
    dummy(xRBG < 0) = 0;
    dummy(xRBR < 0) = 0;
    dummy = dummy./sum(sum(dummy));
    p(:,:,j) = dummy;
    rBG(:,:,j) = xRBG;
    rBR(:,:,j) = xRBR;
end

%calculate lifetime distribution
tau = zeros(res,res,n);
for j = 1:n
    %%% first calculate the Efficiencies B->G and B->R
    EBG = 1./((rBG(:,:,j)./R0BG).^6 + 1);
    EBR = 1./((rBR(:,:,j)./R0BR).^6 + 1);
    %%% calculate E1A from EBG and EBR
    E1A = (EBG.*(1-EBR) + EBR.*(1-EBG))./(1-EBG.*EBR);
    E1A(isnan(E1A)) = 1;
    %%% tau = tau0*(1-E1A)
    tau(:,:,j) = tauD.*(1-E1A);
end

%calculate species weighted taux
taux = zeros(1,n);
for j = 1:n
    taux(j) = sum(sum(p(:,:,j).*tau(:,:,j)));
end

%calculate intensity weighted tauf
tauf = zeros(1,n);
for j = 1:n
    tauf(j) = sum(sum(p(:,:,j).*(tau(:,:,j).^2)))./taux(j);
end

% we need the fitting here because of ambiguity between tauf and taux
% similar taux values can have different tauf values, e.g. one can not
% distinguish between donor (B) quenching due to close G and far R, or close R
% and far G, which will have different effect on the relation between tauf
% and taux due to the mixing.
coefficients = polyfit(tauf,taux,3);
out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;
% figure;plot(xval,out);hold on;plot(xval,1-interp1(tauf,taux,xval)./tauD)

%out = 1-interp1(tauf,taux,xval)./tauD;
%out(xval == 0) = 1; %%% set E to 1 at tau = 0 (interp1 returns NaN)
%out(xval == BurstData{BurstMeta.SelectedFile}.Corrections.DonorLifetimeBlue) = 0; % lifetime = tauD is E = 0
if nargout > 1
    func = @(x) 1- ( coefficients(1).*x.^3 + coefficients(2).*x.^2 + coefficients(3).*x + coefficients(4) )./tauD;;
    % interp1 does not work due to the ambiguity of values
    %func = @(x) 1-interp1(tauf,taux,x)./tauD;
end