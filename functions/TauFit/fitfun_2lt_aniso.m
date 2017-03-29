function [z] = fitfun_2lt_aniso(param,xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};
p = xdata{4};
y = xdata{5};
c = xdata{6};
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
IRF = cell(1,2);
%Scatter = cell(1,2); 
for i = 1:2
    irf = [];
    irf = circshift(IRFPattern{i},[c, 0]);
    irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
    irf = irf-min(irf(irf~=0));
    irf = irf./sum(irf);
    IRF{i} = [irf; zeros(size(y,2)+ignore-1-numel(irf),1)];
    %A shift in the scatter is not needed in the model
    %Scatter{i} = circshift(ScatterPattern{i},[ShiftParams(5), 0]);
    %Scatter{i} = ScatterPattern{i}( (ShiftParams(1)+1):ShiftParams(3) );
end
n = length(IRF{1});
%t = 1:n;
%tp = (1:p)';
tau = param(1:2);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width
A = param(3);
rho = param(4);
r0 = param(5);
r_inf = param(6);
l1 = param(11);
l2 = param(12);
sc_par = param(7);
sc_per = param(8);
bg_par = param(9);
bg_per = param(10);

%%% Calculate the parallel Intensity Decay
rt = 1+(2-3*l1).*((r0-r_inf).*exp(-(1:n)./rho) + r_inf);
x_par1 = exp(-(1:n)./tau(1));
x_par2 = exp(-(1:n)./tau(2));
%%% combine the two components
x_par = rt.*(A*x_par1 + (1-A)*x_par2);
switch conv_type
    case 'linear'
        z_par = conv(IRF{1}, x_par);z_par = z_par(1:n)';
    case 'circular'
        z_par = convol(IRF{1},x_par(1:n));
end
z_par = z_par./sum(z_par);

z_par = (1-sc_par).*z_par + sc_par*Scatter{1};
z_par = z_par./sum(z_par);
z_par = z_par(ignore:end);
z_par = z_par./sum(z_par);
%z_par = z_par.*sum(y(1,:)) + bg_par;
z_par = z_par.*(1-bg_par)+bg_par./numel(z_par);z_par = z_par.*sum(y(1,:));
z_par = z_par';

%%% Calculate the perpendicular Intensity Decay
rt = 1-(1-3*l2).*((r0-r_inf).*exp(-(1:n)./rho) + r_inf);
x_per1 = exp(-(1:n)./tau(1));
x_per2 = exp(-(1:n)./tau(2));
%%% combine the two components
x_per = rt.*(A*x_per1 + (1-A)*x_per2);
switch conv_type
    case 'linear'
        z_per = conv(IRF{2}, x_per);z_per = z_per(1:n)';
    case 'circular'
        z_per = convol(IRF{2}, x_per(1:n));
end
z_per = z_per./sum(z_per);

z_per = (1-sc_per).*z_per + sc_per*Scatter{2};
z_per = z_per./sum(z_per);
z_per = z_per(ignore:end);
z_per = z_per./sum(z_per);
%z_per = z_per.*sum(y(2,:)) + bg_per;
z_per = z_per.*(1-bg_per)+bg_per./numel(z_per);z_per = z_per.*sum(y(2,:));
z_per = z_per';

%%% Construct Stacked Result
z = [z_par z_per];