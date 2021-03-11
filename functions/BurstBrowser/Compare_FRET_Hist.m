%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Compare exported FRET histograms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Compare_FRET_Hist(obj,~)
global UserValues BurstMeta BurstData
h = guidata(obj);
if obj == h.FRET_comp_File_Menu
    %%% Load *.his files (assume they are in one folder)
    try
        [FileNames,PathName] = uigetfile('*.his','Choose *.his files',getPrintPath(),'Multiselect','on');
    catch
        Choose_PrintPath_Menu([],[]);
        [FileNames,PathName] = uigetfile('*.his','Choose *.his files',getPrintPath(),'Multiselect','on');
    end
    if ~iscell(FileNames)
        return;
    end
    dummy = load(fullfile(PathName,FileNames{1}),'-mat');
    switch numel(fieldnames(dummy))% 2is 2color, 3 is 3color
        case 1
            mode = 2;
        case 3
            mode= 3;
    end

    switch mode
        case 2 
            %%% Load FRET arrays
            for i = 1:numel(FileNames)
                data = load(fullfile(PathName,FileNames{i}),'-mat');
                E{i} = data.E;
            end
        case 3
            %%% Load FRET arrays
        for i = 1:numel(FileNames)
            data = load(fullfile(PathName,FileNames{i}),'-mat');
            EGR{i} = data.EGR;
            EBG{i} = data.EBG;
            EBR{i} = data.EBR;
        end
    end
elseif any(obj.Parent == [h.FRET_comp_Loaded_Menu,h.FRET_comp_selected_Menu])
    file = BurstMeta.SelectedFile;
    switch BurstData{file}.BAMethod
        case {1,2,5}
            mode = 2;
        case {3,4}
            mode = 3;
    end
    
    switch obj.Parent
        case h.FRET_comp_Loaded_Menu
            sel_file = BurstMeta.SelectedFile;
            for i = 1:numel(BurstData)
                BurstMeta.SelectedFile = i;
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[],h,0);
                %%% read fret values
                file = i;
                SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
                if BurstData{file}.SelectedSpecies(2) > 1 %%% subspecies selected
                    SelectedSpeciesName = [BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1} '/' SelectedSpeciesName];
                end
                FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
                switch mode
                    case 2
                        E{i} = BurstData{file}.DataCut(:,1);
                    case 3
                        EGR{i} = BurstData{file}.DataCut(:,1);
                        EBG{i} = BurstData{file}.DataCut(:,2);
                        EBR{i} = BurstData{file}.DataCut(:,3);
                end
            end
            BurstMeta.SelectedFile = sel_file;
        case h.FRET_comp_selected_Menu
            sel_file = BurstMeta.SelectedFile;
            [files,species,subspecies] = get_multiselection(h);
            for i = 1:numel(files)
                file = files(i);
                BurstMeta.SelectedFile = file;
                %%% Make sure to apply corrections
                ApplyCorrections(obj,[],h,0);
                %%% read fret values
                try
                    SelectedSpeciesName = BurstData{file}.SpeciesNames{species(i),subspecies(i)};
                    if subspecies(i) > 1 %%% subspecies selected
                        SelectedSpeciesName = [BurstData{file}.SpeciesNames{species(i),1} '/' SelectedSpeciesName];
                    end
                    FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
                catch
                    FileNames{i} = [BurstData{file}.FileName(1:end-4) '.his'];
                end
                [~, Data] = UpdateCuts([species(i),subspecies(i)],file);
                switch mode
                    case 2
                        E{i} = Data(:,1);
                    case 3
                        EGR{i} = Data(:,1);
                        EBG{i} = Data(:,2);
                        EBR{i} = Data(:,3);
                end
            end
            BurstMeta.SelectedFile = sel_file;
    end
elseif  obj.Parent == h.Param_comp_Loaded_Menu
    mode = 0;
    param = h.ParameterListX.String{h.ParameterListX.Value};
    sel_file = BurstMeta.SelectedFile;
    P = cell(numel(BurstData),1);
    for i = 1:numel(BurstData);
        BurstMeta.SelectedFile = i;
        %%% Make sure to apply corrections
        ApplyCorrections(obj,[],h,0);
        %%% read parameter values
        file = i;
        try
            SelectedSpeciesName = BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),BurstData{file}.SelectedSpecies(2)};
            if BurstData{file}.SelectedSpecies(2) > 1 %%% subspecies selected
                SelectedSpeciesName = [BurstData{file}.SpeciesNames{BurstData{file}.SelectedSpecies(1),1} '/' SelectedSpeciesName];
            end
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
        catch
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '.his'];
        end
        p = find(strcmp(BurstData{file}.NameArray,param));
        if ~isempty(p)
            P{i} = BurstData{file}.DataCut(:,p);
        end
    end
    BurstMeta.SelectedFile = sel_file;
elseif obj.Parent == h.Param_comp_selected_Menu
    [files,species,subspecies] = get_multiselection(h);
    mode = 0;
    param = h.ParameterListX.String{h.ParameterListX.Value};
    sel_file = BurstMeta.SelectedFile;
    P = cell(numel(files),1);
    for i = 1:numel(files)
        file = files(i);
        BurstMeta.SelectedFile = file;
        %%% Make sure to apply corrections
        ApplyCorrections(obj,[],h,0);
        %%% read parmeter values
        try
            SelectedSpeciesName = BurstData{file}.SpeciesNames{species(i),subspecies(i)};
            if subspecies(i) > 1 %%% subspecies selected
                SelectedSpeciesName = [BurstData{file}.SpeciesNames{species(i),1} '/' SelectedSpeciesName];
            end
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '/' SelectedSpeciesName '.his'];
        catch
            FileNames{i} = [BurstData{file}.FileName(1:end-4) '.his'];
        end
        p = find(strcmp(BurstData{file}.NameArray,param));
        if ~isempty(p)
            [~, Data] = UpdateCuts([species(i),subspecies(i)],file);
            P{i} = Data(:,p);
        end
    end
    BurstMeta.SelectedFile = sel_file;
end

N_bins = UserValues.BurstBrowser.Display.NumberOfBinsX;

if numel(FileNames) == 1
    return;
end
%%% determine display mode
switch obj
    case {h.FRET_comp_selected_together_Menu,h.Param_comp_selected_together_Menu,h.FRET_comp_Loaded_together_Menu,h.Param_comp_Loaded_together_Menu}
        display_mode = 1;
    case {h.FRET_comp_selected_separate_Menu,h.Param_comp_selected_separate_Menu,h.FRET_comp_Loaded_separate_Menu,h.Param_comp_Loaded_separate_Menu}
        display_mode = 2;
end
switch mode
    case 2 % 2ColorMFD
        xE = linspace(-0.1,1.1,N_bins+1);
        switch display_mode
            case 1 %%% all in one plot
                for i = 1:numel(E)
                    H{i} = histcounts(E{i},xE);
                    switch UserValues.BurstBrowser.Settings.Normalize_Method
                        case 'area'
                           H{i} = H{i}./sum(H{i});
                        case 'max'
                           H{i} = H{i}./max(H{i});
                    end
                end

                color = lines(numel(H));
                f = figure('Color',[1 1 1],'Position',[100 100 600 400]);
                stairs(xE(1:end),[H{1} H{1}(end)],'Color',color(1,:),'LineWidth',2);
                hold on
                for i = 2:numel(H)
                    stairs(xE(1:end),[H{i} H{i}(end)],'Color',color(i,:),'LineWidth',2);
                end
                ax = gca;
                ax.Color = [1 1 1];
                ax.FontSize = 20;
                ax.LineWidth = 2;
                ax.Layer = 'top';
                ax.XLim = [-0.1,1.1];
                ax.Units = 'pixels';
                xlabel('FRET efficiency');
                ylabel('occurrence (norm.)');
                legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
                hl = legend(legend_entries,'fontsize',12,'Box','off');
                set([f,ax,hl],'Units','pixel');
                f.Position(4) = f.Position(4)+hl.Position(4);
                hl.Position(1) = 40;
                hl.Position(2) = 390;
            case 2 % all plots beneath another
                for i = 1:numel(E)
                    H{i} = histcounts(E{i},xE);
                end
                color = lines(numel(H));
                f_width = 600; f_height = min(numel(H)*200,800);
                f = figure('Color',[1 1 1],'Position',[100 100 f_width f_height]);
                f.Units = 'pixel';
                offset_x1 = 85;
                offset_x2 = 10;
                offset_y1 = 75;
                offset_y2 = 10;
                ax_width = f_width - offset_x1 - offset_x2;
                ax_height = (f_height-offset_y1 - offset_y2)/numel(H);
                legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
                for i = 1:numel(H)
                    ax(i) = axes(f,'Units','pixel','Position',[offset_x1, offset_y1+(i-1)*ax_height, ax_width, ax_height],'TickDir','in',...
                        'Box','on','Color',[1,1,1]);
                    hold on;
                    bar(xE(1:end)+min(diff(xE))/2,[H{i} H{i}(end)],'FaceColor',color(i,:),'EdgeColor','none','BarWidth',1);
                    stairs(xE(1:end),[H{i} H{i}(end)],'Color',[0,0,0],'LineWidth',2);
                    if i > 1
                        ax(i).XTickLabel = [];
                        ax(i).YTickLabel{1} = '';
                    else
                        xlabel('FRET efficiency');
                    end
                    if ispc
                        ax(i).FontSize = 20/1.4;
                    else
                        ax(i).FontSize = 20;
                    end
                    if i == 1 && numel(H) > 1
                        ylabel('Occurrence');
                        yl = ax(i).YLabel;
                        yl.Units = 'pixel';
                        yl.Position(2) = yl.Position(2)+ax_height*(numel(H)-1)/2;
                        yl.Units = 'norm';
                    end
                    ax(i).LineWidth = 2;
                    ax(i).YLim(2) = max(H{i})*1.1;
                    ax(i).XLim = [-0.1,1.1];
                    ax(i).Layer = 'top';
                    hl(i) = legend(legend_entries(i),'fontsize',12,'Box','off','Location','northwest');
                end
                linkaxes(ax,'x');
                set(ax,'Units','norm');
        end
        if UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall
                %%% waterfall or image/contour plot
                %%% constuct time series histogram
                for i = 1:numel(H);
                    H{i} = [H{i} H{i}(end)];
                    H{i} = smooth(H{i},3); H{i} = H{i}';
                end
                H = vertcat(H{:}); H = H';
                f = figure('Color',[1 1 1],'Position',[700 100 600 400]);
                contourf(1:1:size(H,2),xE(1:end),H);
                colormap(jet);
                ax = gca;
                ax.Color = [1 1 1];
                ax.FontSize = 20;
                ax.LineWidth = 2;
                ax.Layer = 'top';
                ax.YLim = [0,1];
                ax.Units = 'normalized';
                ax.Position(3) = 0.6;
                ax.Units = 'pixels';
                ylabel('FRET efficiency');
                xlabel('File Number');
                text(1.02,ax.YLim(2),legend_entries);
            end
        FigureName = 'Comp_FRETefficiency';
    case 3 
        xE = linspace(-0.1,1,ceil(N_bins*1.1)+1);
        xEBR = linspace(-0.2,1,ceil(N_bins*1.2)+1);
        for i = 1:numel(EGR)
            HGR{i} = histcounts(EGR{i},xE);
            HBG{i} = histcounts(EBG{i},xE);
            HBR{i} = histcounts(EBR{i},xEBR);
            switch UserValues.BurstBrowser.Settings.Normalize_Method
                case 'area'
                    HGR{i} = HGR{i}./sum(HGR{i});
                    HBG{i} = HBG{i}./sum(HBG{i});
                    HBR{i} = HBR{i}./sum(HBR{i});
                case 'max'
                    HGR{i} = HGR{i}./max(HGR{i});
                    HBG{i} = HBG{i}./max(HBG{i});
                    HBR{i} = HBR{i}./max(HBR{i});
            end
        end
        
        color = lines(numel(HGR));
        H_all = {HGR,HBG,HBR};
        xlb = {'FRET efficiency GR','FRET efficiency BG','FRET efficiency BR'};
        for j = 1:3
            if j == 3
                xE = xEBR;
            end
            H = H_all{j};
            f = figure('Color',[1 1 1],'Position',[100+600*(j-1) 100 600 400],'name',xlb{j});
            stairs(xE(1:end),[H{1} H{1}(end)],'Color',color(1,:),'LineWidth',2);
            hold on
            for i = 2:numel(H)
                stairs(xE(1:end),[H{i} H{i}(end)],'Color',color(i,:),'LineWidth',2);
            end
            ax = gca;
            ax.Color = [1 1 1];
            ax.FontSize = 20;
            ax.LineWidth = 2;
            ax.Layer = 'top';
            ax.XLim = [-0.1 1];
            if j == 3
                ax.XLim = [-0.2 1];
            end
            ax.Units = 'pixels';
            xlabel(xlb{j});
            ylabel('occurrence (norm.)');
            legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
            hl = legend(legend_entries,'fontsize',12,'Box','off');
            set([f,ax,hl],'Units','pixel');
            f.Position(4) = f.Position(4)+hl.Position(4);
            hl.Position(1) = 40;
            hl.Position(2) = 390;
        end
        
        if UserValues.BurstBrowser.Settings.CompareFRETHist_Waterfall
            %%% waterfall or image/contour plot
            %%% constuct time series histogram
            for i = 1:numel(EGR);
                HGR{i} = smooth(HGR{i},3); HGR{i} = HGR{i}';
                HBG{i} = smooth(HBG{i},3); HBG{i} = HBG{i}';
                HBR{i} = smooth(HBR{i},3); HBR{i} = HBR{i}';
            end
            HGR = vertcat(HGR{:});
            HBG = vertcat(HBG{:});
            HBR = vertcat(HBR{:});
            H_all = {HGR,HBG,HBR};
            xE = linspace(-0.1,1,56);
            for j = 1:3
                if j == 3
                    xE = xEBR(1:end-1);
                end
                H = H_all{j}; H = H';
                figure('Color',[1 1 1],'Position',[100+600*(j-1) 500 600 400]);
                contourf(1:1:size(H,2),xE(1:end),H);
                colormap(jet);
                ax = gca;
                ax.Color = [1 1 1];
                ax.FontSize = 20;
                ax.LineWidth = 2;
                ax.Layer = 'top';
                ax.YLim = [0,1];
                ax.Units = 'normalized';
                ax.Position(3) = 0.6;
                ax.Units = 'pixels';
                ylabel(xlb{j});
                xlabel('File Number');
                text(1.02,ax.YLim(2),legend_entries);
            end
        end
    case 0 % no FRET, other parameter
        valid = ~(cellfun(@isempty,P));
        %%% take X hist limits
        xlim = h.axes_1d_x.XLim;
        xP = linspace(xlim(1),xlim(2),N_bins+1);
        switch display_mode
            case 1 % all in one plot
                for i = 1:numel(P)
                    if valid(i)
                        H{i} = histcounts(P{i},xP);
                        switch UserValues.BurstBrowser.Settings.Normalize_Method
                            case 'area'
                                H{i} = H{i}./sum(H{i});
                            case 'max'
                                H{i} = H{i}./max(H{i});
                        end
                    end
                end

                color = lines(numel(H));
                f = figure('Color',[1 1 1],'Position',[100 100 600 400]);
                hold on
                for i = 1:numel(H)
                    if valid(i)
                        stairs(xP(1:end),[H{i} H{i}(end)],'Color',color(i,:),'LineWidth',2);
                    end
                end
                ax = gca;
                ax.Color = [1 1 1];
                ax.FontSize = 20;
                ax.LineWidth = 2;
                ax.Layer = 'top';
                ax.XLim = xlim;
                ax.Units = 'pixels';
                xlabel(param);
                ylabel('occurrence (norm.)');
                legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
                legend_entries = legend_entries(valid);
                hl = legend(legend_entries,'fontsize',12,'Box','off');
                set([f,ax,hl],'Units','pixel');
                f.Position(4) = f.Position(4)+hl.Position(4);
                hl.Position(1) = 40;
                hl.Position(2) = 390;
            case 2 % all beneath another                
                for i = 1:numel(P)
                    if valid(i)
                        H{i} = histcounts(P{i},xP);
                    else
                        H{i} = zeros(1,numel(xP)-1);
                    end
                end
                color = lines(numel(H));
                f_width = 600; f_height = min(numel(H)*200,800);
                f = figure('Color',[1 1 1],'Position',[100 100 f_width f_height]);
                f.Units = 'pixel';
                offset_x1 = 85;
                offset_x2 = 10;
                offset_y1 = 75;
                offset_y2 = 10;
                ax_width = f_width - offset_x1 - offset_x2;
                ax_height = (f_height-offset_y1 - offset_y2)/numel(H);
                legend_entries = cellfun(@(x) strrep(x(1:end-4),'_',' '),FileNames,'UniformOutput',false);
                %legend_entries = legend_entries(valid);
                for i = 1:numel(H)
                    ax(i) = axes(f,'Units','pixel','Position',[offset_x1, offset_y1+(i-1)*ax_height, ax_width, ax_height],'TickDir','in',...
                        'Box','on');
                    hold on;
                    bar(xP(1:end)+min(diff(xP))/2,[H{i} H{i}(end)],'FaceColor',color(i,:),'EdgeColor','none','BarWidth',1);
                    stairs(xP(1:end),[H{i} H{i}(end)],'Color',[0,0,0],'LineWidth',2);
                    if i > 1
                        ax(i).XTickLabel = [];
                        ax(i).YTickLabel{1} = '';
                    else
                        xlabel(param);
                    end
                    if ispc
                        ax(i).FontSize = 20/1.4;
                    else
                        ax(i).FontSize = 20;
                    end
                    if i == 1 && numel(H) > 1
                        ylabel('Occurrence');
                        yl = ax(i).YLabel;
                        yl.Units = 'pixel';
                        yl.Position(2) = yl.Position(2)+ax_height*(numel(H)-1)/2;
                        yl.Units = 'norm';
                    end
                    ax(i).LineWidth = 2;
                    ax(i).YLim(2) = max(H{i})*1.1;
                    ax(i).XLim = xlim;
                    ax(i).Layer = 'top';
                    ax(i).Color = [1,1,1];
                    hl(i) = legend(legend_entries(i),'fontsize',12,'Box','off','Location','northwest');
                end
                linkaxes(ax,'x');
                set(ax,'Units','norm');
        end
        FigureName = ['Comp_' h.ParameterListX.String{h.ParameterListX.Value}];
        FigureName = strrep(FigureName,' ','_');
end
%%% add close request function
if any(mode == [0,2])
    ask_file = 1;
    f.CloseRequestFcn = {@ExportGraph_CloseFunction,ask_file,FigureName};
end