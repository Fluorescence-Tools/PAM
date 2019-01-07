%%% universal circle in presence of linker fluctuations
function [g,s] = universal_circle_linker(R0,s,tauD,TAC)
res = 1000;
omega = 2*pi/TAC;
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

% perform intensity weighting of contributions
for j = 1:numel(R)
    p(j,:) = p(j,:).*tau(j,:)./sum(p(j,:).*tau(j,:));
end

%calculate intensity-averaged g and s values
g = zeros(1,numel(R));
for j = 1:numel(R)
    g(j) = sum(p(j,:).*(1./(1+tau(j,:).^2.*omega^2)));
end

s = zeros(1,numel(R));
for j = 1:numel(R)
    s(j) = sum(p(j,:).*((tau(j,:).*omega)./(1+tau(j,:).^2.*omega^2)));
end