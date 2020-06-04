function ci = ci_support_plane_analysis(chi2,param_val,chi2_0,nu,p,alpha)
global PDAData
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
chi2_max = chi2_0*(1+(p/nu)*finv(alpha,p,nu));

% Then, the chi2 is interpolated on a finer grid using a spline and
% the first and last points above threshold are determined
res = 1000;
param_fine = zeros(res,size(chi2,2));
chi2_fine = zeros(res,size(chi2,2));
valid = false(res,size(chi2,2));
ci = zeros(2,size(chi2,2));
best_val = zeros(1,size(chi2,2));
for i = 1:size(chi2,2) %%% loop over all parameters
    param_fine(:,i) = linspace(param_val(1,i),param_val(end,i),res);
    chi2_fine(:,i) = interp1(param_val(:,i),chi2(:,i),param_fine(:,i),'spline');
    valid(:,i) = chi2_fine(:,i) < chi2_max;
    ci(1,i) = param_fine(find(valid(:,i),1,'first'),i);
    ci(2,i) = param_fine(find(valid(:,i),1,'last'),i);
    [best_chi2,best_idx] = min(chi2_fine(:,i));
    best_val(i) = param_fine(best_idx,i);
end

%%% visualize the result
colors = lines(size(chi2,2));
legend_str = {};
figure; hold on;
for i = 1:size(chi2,2)    
    chi2_temp = chi2_fine(:,i); chi2_temp(~valid(:,i)) = NaN;
    l(i) = plot(param_fine(:,i),chi2_temp,'-','LineWidth',1.5,'Color',colors(i,:));
    chi2_temp = chi2_fine(:,i); chi2_temp(valid(:,i)) = NaN;
    plot(param_fine(:,i),chi2_temp,'--','LineWidth',1.5,'Color',colors(i,:));
    scatter(param_val(:,i),chi2(:,i),'filled','MarkerFaceColor',colors(i,:),'MarkerEdgeColor',[0,0,0]);
    legend_str{i} = sprintf('R%d = %.2f \\pm %.2f (%.2f, %.2f)',i,best_val(i),0.5*(ci(2,i)-ci(1,i)),ci(1,i),ci(2,i));
end
xlabel('Distance [A]');
ylabel('\chi^2_{red.}');
set(gca,'Box','on','LineWidth',1.5,'Tickdir','out','FontSize',16,'XGrid','on','YGrid','on');
plot(get(gca,'XLim'),[chi2_max,chi2_max],'k--','LineWidth',1.5);
legend(l,legend_str);

%%% save figure as fig and png
% take first filename
[~,fn,~] = fileparts(PDAData.FileName{1});
export_fig([PDAData.PathName{1} filesep fn '.png'],'-r300');
%export_fig([PDAData.PathName{1} filesep fn '.eps']);
savefig([PDAData.PathName{1} filesep fn '.fig']);

%%% save result as txt file
fn_text = [PDAData.PathName{1} filesep fn '.txt'];
fid = fopen(fn_text,'w');
fprintf(fid,['Support Plane Analysis of file: ' fn '\n\n']);
for i = 1:numel(legend_str)
    fprintf(fid,strrep(legend_str{i},'\pm','+-'));
    fprintf(fid,'\n');
end
fprintf(fid,'\n');
fprintf(fid,'Confidence level:\t%.2f\n',alpha);
fprintf(fid,'chi2r threshold:\t%.2f\n',chi2_max);
fprintf(fid,'Best chi2r:\t%.2f\n',chi2_0);
fprintf(fid,'\n');
fprintf(fid,'Parameter Scan Results:\n');
fprintf(fid,'R1\tchi2');
for i = 2:numel(legend_str)
    fprintf(fid,'\tR%d\tchi2',i);
end
fprintf(fid,'\n');
mat = [param_val(:,1),chi2(:,1)];
for i = 2:numel(legend_str)
    mat = [mat,param_val(:,i),chi2(:,i)];
end
fclose(fid);
dlmwrite(fn_text,mat,'-append','Delimiter','\t');
fid = fopen(fn_text,'a');
fprintf(fid,'\n');
fprintf(fid,'Parameter Scan Results (interpolated):\n');
fprintf(fid,'R1\tchi2');
for i = 2:numel(legend_str)
    fprintf(fid,'\tR%d\tchi2',i);
end
fprintf(fid,'\n');
mat = [param_fine(:,1),chi2_fine(:,1)];
for i = 2:numel(legend_str)
    mat = [mat,param_fine(:,i),chi2_fine(:,i)];
end
fclose(fid);
dlmwrite(fn_text,mat,'-append','Delimiter','\t');