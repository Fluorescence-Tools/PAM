function [dt1,dt2] = lifetime_correction_truncation(tau,file)
% returns the first and second moment of the microtime distribution
global PDAMeta
% correct for trunctation of exponential distribution
approximate = true; % approximate IRF as delta function
if approximate
    % see this paper for details:
    % Al-Athari FM (2008) Estimation of the Mean of Truncated Exponential Distribution. J of Mathematics and Statistics 4(4):284–288.
    % http://docsdrive.com/pdfs/sciencepublications/jmssp/2008/284-288.pdf
    % Here, the convolution with the IRF is considered only as a
    % delta function, could be improved if needed.
    TACrange = numel(PDAMeta.IRF{file});
    tau = tau - (TACrange-PDAMeta.IRF_moments{file}(1))*(exp((TACrange-PDAMeta.IRF_moments{file}(1))/tau)-1)^(-1);
    % calculate the moments, accounting for IRF
    dt1 = tau + PDAMeta.IRF_moments{file}(1);
    % second moment is E[(X+Y)^2] = E[X^2]+E[Y^2]+2*E[X]*E[Y];
    % calculate parameters of the gamma distribution
    % E[X^2] of exponential is 2*tau
    dt2 = 2*tau.^2+PDAMeta.IRF_moments{file}(2)+2*tau*PDAMeta.IRF_moments{file}(1);
else
    % explicitly calculate the convolution and the moments
    d = exp(-(1:numel(PDAMeta.IRF{file}))/tau);
    d_conv = conv(d,PDAMeta.IRF{file});
    d_conv = d_conv(1:numel(PDAMeta.IRF{file}));
    d_conv = d_conv./sum(d_conv);
    dt1 = sum((1:numel(d_conv)).*d_conv);
    dt2 = sum((1:numel(d_conv)).^2.*d_conv);
end