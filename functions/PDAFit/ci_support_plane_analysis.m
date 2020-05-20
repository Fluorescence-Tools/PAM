function ci = ci_support_plane_analysis(chi2,param_val,chi2_0,nu,p,alpha)
%%% calculates the confidence intervals for parameters based on the F-test
%%% used in support plane analysis
% chi2 - the chi2 values of the support plane analysis, as columns for every parameter tested
% param_val - the corresponding parameter values
% chi2_0 - the optimal chi2 from a free fit
% nu - the degrees of freedom (bins)
% p - the number of fit parameters
% alpha - the confidence level (0.95 --> 95%, 0.68 --> 68%)

% First, the maximum chi2 value chi2_max that is tolerated for a confidence
% level is calculated based on the F statistic
chi2_max = chi2_0*(1+(p/nu)*finv(0.95,p,nu));

% Then, the chi2 is interpolated on a finer grid using a spline and
% the first and last points above threshold are determined
res = 1000;
param_fine = zeros(res,size(chi2,2));
chi2_fine = zeros(res,size(chi2,2));
valid = false(res,size(chi2,2));
ci = zeros(2,size(chi2,2));
for i = 1:size(chi2,2) %%% loop over all parameters
    param_fine(:,i) = linspace(param_val(1,i),param_val(end,i),res);
    chi2_fine(:,i) = interp1(param_val(:,i),chi2(:,i),param_fine(:,i),'spline');
    valid(:,i) = chi2_fine(:,i) < chi2_max;
    ci(1,i) = param_fine(find(valid(:,i),1,'first'),i);
    ci(2,i) = param_fine(find(valid(:,i),1,'last'),i);
end

%%% visualize the result
figure; hold on;
for i = 1:size(chi2,2)
    scatter(param_val(:,i),chi2(:,i));
    plot(param_fine(valid(:,i),i),chi2_fine(valid(:,i),i),'-');
    plot(param_fine(~valid(:,i),i),chi2_fine(~valid(:,i),i),'--');
end
plot([min(param_fine(:)),max(param_fine(:))],[chi2_max,chi2_max],'k-');