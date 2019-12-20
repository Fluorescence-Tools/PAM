function ExportGraph_CloseFunction(hfig,~,ask_file,FigureName)
global UserValues BurstData BurstMeta
if isempty(UserValues) || isempty(BurstData)
    delete(hfig);
    return;
end
directly_save = UserValues.BurstBrowser.Settings.SaveFileExportFigure;
file = BurstMeta.SelectedFile;
if directly_save
    if ask_file
        %%% Get Path to save File
        FilterSpec = {'*.png','PNG File (*.png)';'*.pdf','PDF File (*.pdf)';'*.eps','EPS File (*.eps)';'*.tif','TIFF File (*.tif)';'*.fig','MATLAB figure (*.fig)'};
        [FileName,PathName,FilterIndex] = uiputfile(FilterSpec,'Choose a filename',fullfile(getPrintPath(),FigureName));       
        if FileName == 0
            delete(hfig);
            return;
        end
        if ~UserValues.BurstBrowser.Settings.UseFilePathForExport
            UserValues.BurstBrowser.PrintPath = PathName;
            h = guidata(findobj('Tag','BurstBrowser'));
            h.Current_PrintPath_Text.Label = PathName;
        end
        LSUserValues(1);
    else
        FilterIndex = 1; %%% Save as png
        FileName = [FigureName '.png'];
        PathName = getPrintPath();
    end
    FileName = strrep(FileName,'/','-');
    %%% print figure
    hfig.PaperPositionMode = 'auto';
    dpi = 300;
    switch FilterIndex
        case 1
            print(hfig,fullfile(PathName,FileName),'-dpng',sprintf('-r%d',dpi),'-painters');
        case {2,3}
            % Make changing paper type possible
            set(hfig,'PaperType','<custom>');
            
            % Set units to all be the same
            set(hfig,'PaperUnits','inches');
            set(hfig,'Units','inches');
            
            % Set the page size and position to match the figure's dimensions
            position = get(hfig,'Position');
            set(hfig,'PaperPosition',[0,0,position(3:4)]);
            set(hfig,'PaperSize',position(3:4));
            set(hfig,'InvertHardCopy', 'off');
            switch FilterIndex
                case 2
                    print(hfig,fullfile(PathName,FileName),'-dpdf',sprintf('-r%d',dpi));
                case 3
                    print('-painters',hfig,fullfile(PathName,FileName),'-depsc2');
            end
        case 4
            print(hfig,fullfile(PathName,FileName),'-dtiff',sprintf('-r%d',dpi));
        case 5
            hfig.CloseRequestFcn = [];
            savefig(hfig,fullfile(PathName,FileName));
    end
    
    hfig.CloseRequestFcn = @(x,y) delete(x);
    pause(0.5)
    delete(hfig);
    LSUserValues(1);
else
    delete(hfig);
    return;
end