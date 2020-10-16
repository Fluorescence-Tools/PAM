function report_generator(obj,~,mode,h)
global BurstData BurstMeta UserValues
if isempty(BurstData)
    return;
end
if nargin < 4
    h = guidata(obj);
end
import mlreportgen.ppt.*

if mode == 1 % initialize report
    [~,fn,~] = fileparts(BurstData{BurstMeta.SelectedFile}.FileName);
    reportname = [fn '.pptx'];
    [FileName,PathName] = uiputfile('*.pptx','Choose a filename',fullfile(getPrintPath(),reportname));       
    if FileName == 0
        return;
    end
    if ~UserValues.BurstBrowser.Settings.UseFilePathForExport
        UserValues.BurstBrowser.PrintPath = PathName;
        h = guidata(findobj('Tag','BurstBrowser'));
        h.Current_PrintPath_Text.Label = PathName;
    end
    LSUserValues(1);
    
    BurstMeta.ReportFile = fullfile(PathName,FileName);
    ppt = Presentation(BurstMeta.ReportFile);
    open(ppt);
    titleSlide = add(ppt,'Title Slide');
    replace(titleSlide,'Title',fn);
    titleSlide.Children(1).FontSize = '30 pt';
    replace(titleSlide,'Subtitle',string(datetime));
    close(ppt);
    h.Export_ReportAdd_Menu.Enable = 'on';
    h.Export_ReportClose_Menu.Enable = 'on';
elseif mode == 2 %%% add picture slide
    if isempty(BurstMeta.ReportFile)
        disp('First open a presentation.');
        return;
    end
    set(h.BurstBrowser, 'pointer', 'watch')
    ppt = Presentation(BurstMeta.ReportFile,BurstMeta.ReportFile);
    open(ppt);
    export_fig(gcf,'temp.png','-dpng','-r150');
    screenshot = Picture('temp.png');
    screenshot.X = '0 px'; screenshot.Y = '0 px';
    AspectRatio_PPT = 33.87/19.05;
    % get aspect ratio of figure
    f = gcf;
    AspectRatio_Figure = f.Position(3)/f.Position(4);
    if AspectRatio_Figure > AspectRatio_PPT
        %%% figure is wider than target
        %%% fit width, adjust height
        screenshot.Width = '33.87 cm';
        screenshot.Height =  sprintf('%.2f cm',33.87/AspectRatio_Figure);
    else
        %%% figure is higher than target
        %%% fit heigt, adjust width
        screenshot.Height = '19.05 cm';
        screenshot.Width =  sprintf('%.2f cm',19.05*AspectRatio_Figure);
    end
    pictureSlide = add(ppt,'Blank');
    add(pictureSlide,screenshot);
    close(ppt);
    %rptview(ppt);
    delete('temp.png');
    set(h.BurstBrowser, 'pointer', 'arrow')
elseif mode == 3 %%% show the report
    if isempty(BurstMeta.ReportFile)
        disp('First open a presentation.');
        return;
    end
    ppt = Presentation(BurstMeta.ReportFile,BurstMeta.ReportFile);
    rptview(ppt);
    close(ppt);
    BurstMeta.ReportFile = [];
    h.Export_ReportAdd_Menu.Enable = 'off';
    h.Export_ReportClose_Menu.Enable = 'off';
end