function CalculateGammaGUI(obj,~)
%%% opens figure with table to put in values and button to calculate gamma
f = findobj('Tag','CalculateGammaFigure');
if isempty(f)
    f = figure('Tag','CalculateGammaFigure','Menubar','none','Toolbar','none','Name','E-S table','NumberTitle','off','Units','pixels');
    m = uimenu('Parent',f,'Label','Calculate','Callback',@CalculateGamma);
    t = uitable('Parent',f,'ColumnName',{'E','S','<html>&sigma;E</html>','<html>&sigma;S</html>'},...
        'ColumnFormat',{'numeric','numeric','numeric','numeric'},...
        'Units','normalized','Position',[0,0,1,1],'Tag','CalculateGammaTable',...
        'Data',cell(10,4),'ColumnEditable',true);
    extent = t.Extent;
    f.Position(3) = f.Position(3)*extent(3);
    f.Position(4) = f.Position(4)*extent(4);
else
    figure(f);
end