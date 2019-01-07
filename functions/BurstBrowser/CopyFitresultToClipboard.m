%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Copies Gauss Fit Data to Clipboard %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CopyFitresultToClipboard(obj,~)
global BurstMeta
if ~isfield(BurstMeta,'Fitting')
    return;
end
res = BurstMeta.Fitting.FitResult;
h = guidata(obj);

switch BurstMeta.Fitting.FitType
    case '1D'
        Header = {'Fraction','Mean(X)','sigma(X)'};
    case '2D'
        Header = {'Fraction','Mean(X)','Mean(Y)','sigma(XX)','sigma(YY)','COV(XY)'};
end

Info = cell(2,numel(Header));
switch h.Fit_GaussianMethod_Popupmenu.Value
    case 1 %MLE
        Info(1:2,1:2) = {'NegativeLogLikelihood','BIC';res(end-1),res(end)};
        res(end-1:end) = [];
    case 2 %LSQ
        Info(1:2,1) = {'Chi2';res(end)};
        res(end) = [];
end
Header = [Info;Header];
data = [];
switch BurstMeta.Fitting.FitType
    case '1D'
        nG = numel(res)/3;
        for i = 1:nG
            data = [data;num2cell(res((1:3)+(i-1)*3))];
        end
    case '2D'
        nG = numel(res)/6;
        for i = 1:nG
            data = [data;num2cell(res((1:6)+(i-1)*6))];
        end
end
Mat2clip([Header;data]);