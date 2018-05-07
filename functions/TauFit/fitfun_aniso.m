function [z] = fitfun_aniso(param,xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};
p = xdata{4};
y = xdata{5};
c = xdata{6};
ignore = xdata{7};
G = xdata{8};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
IRF = cell(1,2);
%Scatter = cell(1,2); 
for i = 1:2
    irf = [];
    %irf = circshift(IRFPattern{i},[c, 0]);
    irf = shift_by_fraction(IRFPattern{i},c);
    irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
    irf(irf~=0) = irf(irf~=0)-min(irf(irf~=0));
    irf = irf./sum(irf);
    IRF{i} = [irf; zeros(size(y,2)+ignore-1-numel(irf),1)];
    %A shift in the scatter is not needed in the model
    %Scatter{i} = circshift(ScatterPattern{i},[ShiftParams(5), 0]);
    %Scatter{i} = ScatterPattern{i}( (ShiftParams(1)+1):ShiftParams(3) );
end
n = length(IRF{1});
%t = 1:n;
%tp = (1:p)';
tau = param(1);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width
rho = param(2);
r0 = param(3);
r_inf = param(4);
l1 = param(9);
l2 = param(10);
sc_par = param(5);
sc_per = param(6);
bg_par = param(7);
bg_per = param(8);
I0 = param(11);
%%% Calculate the parallel Intensity Decay
x_par = (I0/G)*exp(-(1:n)./tau).*(1+(2-3*l1).*((r0-r_inf).*exp(-(1:n)./rho) + r_inf));
switch conv_type
    case 'linear'
        z_par = conv(IRF{1}, x_par);z_par = z_par(1:n)';
    case 'circular'
        z_par = convol(IRF{1},x_par(1:n));
end
%z_par = z_par./repmat(sum(z_par,1),size(z_par,1),1);
z_par = (1-sc_par).*z_par + sc_par*Scatter{1}*sum(z_par);
%z_par = z_par./sum(z_par);
z_par = z_par(ignore:end);
%z_par = z_par./sum(z_par);
%z_par = z_par.*sum(y(1,:)) + bg_par;
z_par = z_par.*(1-bg_par)+bg_par*sum(z_par)./numel(z_par);%z_par = z_par.*sum(y(1,:));
z_par = z_par';

%%% Calculate the perpendicular Intensity Decay
x_per = I0*exp(-(1:n)./tau).*(1-(1-3*l2).*((r0-r_inf).*exp(-(1:n)./rho) + r_inf));
switch conv_type
    case 'linear'
        z_per = conv(IRF{2}, x_per);z_per = z_per(1:n)';
    case 'circular'
        z_per = convol(IRF{2}, x_per(1:n));
end
%z_per = z_per./repmat(sum(z_per,1),size(z_per,1),1);
z_per = (1-sc_per).*z_per + sc_per*Scatter{2}*sum(z_per);
%z_per = z_per./sum(z_per);
z_per = z_per(ignore:end);
%z_per = z_per./sum(z_per);
%z_per = z_per.*sum(y(2,:)) + bg_per;
z_per = z_per.*(1-bg_per)+bg_per*sum(z_per)./numel(z_per);%z_per = z_per.*sum(y(2,:));
z_per = z_per';

% %%% Calculate the perpendicular t Decay
% x_per = exp(-(1:n)./tau).*(1-(1-3*l2).*((r0-r_inf).*exp(-(1:n)./rho) + r_inf));
% z_per = convol(IRF{2}, x_per);
% z_per = z_per./repmat(sum(z_per,1),size(z_per,1),1);
% z_per = (1-sc_per).*z_per + sc_per*Scatter{2};
% z_per = z_per./sum(z_per);
% z_per = z_per(ignore:end);
% z_per = z_per./sum(z_per);
% z_per = z_per.*sum(y(2,:)) + bg_per;
% z_per = z_per';

%%% Construct Stacked Result
z = [z_par z_per];