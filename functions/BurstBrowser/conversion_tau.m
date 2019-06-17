%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Calculates static FRET line with Linker Dynamics %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out, func, xval] = conversion_tau(tauD,R0,s,xval_in)
global BurstData BurstMeta
% s = 6;
res = 1000;

%range of RDA center values, i.e. 1000 values in 0*R0 to 3*R0
R = linspace(0*R0,3*R0,res);

%for every R calculate gaussian distribution
p = zeros(numel(R),res);
r = zeros(numel(R),res);
for j = 1:numel(R)
    x = linspace(R(j)-4*s,R(j)+4*s,res);
    dummy = exp(-((x-R(j)).^2)./(2*s^2));
    dummy(x < 0) = 0;
    dummy = dummy./sum(dummy);
    p(j,:) = dummy;
    r(j,:) = x;
end

%calculate lifetime distribution
tau = zeros(numel(R),res);
for j = 1:numel(R)
    tau(j,:) = tauD./(1+((R0./r(j,:)).^6));
end

%calculate species weighted taux
taux = zeros(1,numel(R));
for j = 1:numel(R)
    taux(j) = sum(p(j,:).*tau(j,:));
end

%calculate intensity weighted tauf
tauf = zeros(1,numel(R));
for j = 1:numel(R)
    tauf(j) = sum(p(j,:).*(tau(j,:).^2))./taux(j);
end

%coefficients = polyfit(tauf,taux,3);
%out = 1- ( coefficients(1).*xval.^3 + coefficients(2).*xval.^2 + coefficients(3).*xval + coefficients(4) )./tauD;

if nargin < 4
    %%% no interpolation, just return data
    out = 1-taux./tauD;
    xval = tauf;
else
    %%% return distance at specified intensity-weighted lifetimes (used for calculation of dynamic FRET lines)
    xval = xval_in;
    if xval > tauf(end)
        out = R(end); return;
    end
    if xval < tauf(1);
        out = tauf(1); return;
    end
    %%% find nearest neighbours
    dif = tauf-xval; neg = find(dif < 0,1,'last'); pos = find(dif > 0,1,'first');
    %%% interpolate to zero crossing
    m = (dif(pos)-dif(neg))./(R(pos)-R(neg));
    out = R(neg)-dif(neg)./m;
end
%%% legacy code:
%%% fix for display
%%% set tau=0 to E=1
% out(xval == 0) = 1; % lifetime zero is E = 1
% out(xval == BurstData{BurstMeta.SelectedFile}.Corrections.DonorLifetime) = 0; % lifetime = tauD is E = 0
% valid = ~isnan(out);
% out = out(valid); %%% remove NaNs for E -> 1
% xval = xval(valid);

if nargout > 1
    func = @(x) 1-interp1(tauf,taux,x)./tauD;
end


function [p] = normal_dist(xR,Rmp,sigma)
p = exp(-((xR-Rmp)).^2)./(2*sigma^2);
p = p./sum(p);

function [p] = chi_dist(xR,Rmp,sigma)
p = (xR./Rmp).*(normal_dist(xR,Rmp,sigma)-normal_dist(xR,-Rmp,sigma));
p = p./sum(p);
