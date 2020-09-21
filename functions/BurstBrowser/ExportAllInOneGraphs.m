%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Export all-in-one graphs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExportAllInOneGraphs(obj,~,arrangement)
global BurstData BurstMeta UserValues
h = guidata(obj);

%%% some options
overlay = true; %%% overlay the axis labels on 1D plot
opacity = 0.8; %%% gray color for 1D axis if overlay = true
% file and species that are currently selected
[file, species, subspecies] = get_multiselection(h);
multiplot = h.MultiselectOnCheckbox.UserData && numel(file)>1;

%file_old = BurstMeta.SelectedFile;
old_paramX = h.ParameterListX.Value;
old_paramY = h.ParameterListY.Value;
            
Progress(0,h.Progress_Axes,h.Progress_Text,'Generating figure...');

for k = 1:1%numel(file) %loop through all selected species
    %BurstMeta.SelectedFile = file(k);
    % select the same species for all files as for the currently selected file
    %SelectedSpecies_old = BurstData{file(k)}.SelectedSpecies;
    %BurstData{file(k)}.SelectedSpecies = [species(k), subspecies(k)];
    
    %%% Make sure to apply corrections to all files
    ApplyCorrections(h.ApplyCorrectionsButton,[],h,0);
    UpdateCutTable(h);
    UpdateCuts();
    %update all plots, cause that's what we'll be copying
    UpdatePlot([],[],h);
    UpdateLifetimePlots([],[],h);
    PlotLifetimeInd([],[],h);
    Progress(0.2,h.Progress_Axes,h.Progress_Text,'Generating figure...');
    if any(BurstData{file(k)}.BAMethod == [3,4])
        disp('Not implemented for three color.');
        return;
    end
    
    % initialize the figure
    fontsize = 8;
    if ispc
        fontsize = fontsize/1.2;
    end
    size_pixels = 650;
    AspectRatio = 1;
    pos = [100,100, round(1.3*size_pixels),round(1.2*size_pixels*AspectRatio)];
    
    % make a cell containing the strings of the parameters you want to plot
    % in the figure.
    paramname = cell(4,2);
    % 2D Lifetime-E
    paramname{1,1} = 'Lifetime D [ns]';
    paramname{1,2} = 'FRET Efficiency';
    % 2D lifetime GG-Anisotropy GG
    paramname{2,1} = 'Lifetime D [ns]';
    paramname{2,2} = 'Anisotropy D';
    % 2D lifetime RR-Anisotropy RR
    paramname{3,1} = 'Lifetime A [ns]';
    paramname{3,2} = 'Anisotropy A';
    % 2D Stoichiometry-E
    paramname{5,1} = 'Stoichiometry';
    paramname{5,2} = 'FRET Efficiency';
    % 2D FRET efficiency vs Lifetime A
    paramname{4,1} = 'Lifetime A [ns]';
    paramname{4,2} = 'FRET Efficiency';
    
    panel_copy = cell(5,1);
    
    % Make 4 new figures with the appropriate plots
    for f = 1:5
        hfig{f} = figure('Position',pos,'Color',[1 1 1],'Visible','off');
        if f < 5
            %%% Update lifetime ind plot
            switch f
                case 1
                    h.lifetime_ind_popupmenu.Value = 1;
                case 2
                    h.lifetime_ind_popupmenu.Value = 3;
                case 3
                    h.lifetime_ind_popupmenu.Value = 4;
                case 4
                    h.lifetime_ind_popupmenu.Value = 2;
            end
            PlotLifetimeInd([],[],h);
            panel_copy{f} = copyobj([h.axes_lifetime_ind_1d_y,...
                h.axes_lifetime_ind_1d_x,...
                h.axes_lifetime_ind_2d],...
                hfig{f});
        else
            h.ParameterListX.Value = find(strcmp(paramname{f,1},BurstData{file(k)}.NameArray));
            h.ParameterListY.Value = find(strcmp(paramname{f,2},BurstData{file(k)}.NameArray));
            %%% restrict E and S to fixed intervals
            prev_setting = UserValues.BurstBrowser.Display.Restrict_EandS_Range;
            UserValues.BurstBrowser.Display.Restrict_EandS_Range = 1;
            UpdatePlot([],[],h);
            %%% Copy axes to figure
            panel_copy{f} = copyobj([findobj('Parent',h.MainTabGeneralPanel,'Tag','Axes_1D_Y'),...
                findobj('Parent',h.MainTabGeneralPanel,'Tag','Axes_1D_X'),...
                findobj('Parent',h.MainTabGeneralPanel,'Tag','Axes_General')],...
                hfig{f});
            UserValues.BurstBrowser.Display.Restrict_EandS_Range = prev_setting;
            UpdatePlot([],[],h);
        end
        %%% set Background Color to white
        for a = 1:3
            panel_copy{f}(a).Color = [1 1 1];
            panel_copy{f}(a).XColor = [0 0 0];
            panel_copy{f}(a).GridAlpha=0.5;
            panel_copy{f}(a).GridAlphaMode = 'manual';
            panel_copy{f}(a).GridColor = [0 0 0];
            panel_copy{f}(a).GridColorMode = 'auto';
            panel_copy{f}(a).GridLineStyle = '-';
            %panel_copy{f}(a).XTickLabelMode = 'auto';
            %panel_copy{f}(a).YTickLabelMode = 'auto';
            panel_copy{f}(a).XMinorGrid = 'off';
            panel_copy{f}(a).YMinorGrid = 'off';
            %%% change X/YColor Color Color
            panel_copy{f}(a).XColor = [0,0,0];
            panel_copy{f}(a).YColor = [0,0,0];
            panel_copy{f}(a).XLabel.Color = [0,0,0];
            panel_copy{f}(a).YLabel.Color = [0,0,0];
%             panel_copy{f}(a).Children(1).Visible = 'off';
        end
        for a = 3
            panel_copy{f}(a).YColor = [0 0 0];
            panel_copy{f}(a).XGrid = 'on';
            panel_copy{f}(a).YGrid = 'on';
        end
        for a = 1:2
            panel_copy{f}(a).XTickLabelMode = 'auto';
            panel_copy{f}(a).YTickLabelMode = 'auto';
            panel_copy{f}(a).XGrid = 'off';
            panel_copy{f}(a).YGrid = 'off';
            %%% delete the stair plot
            if f == 5
                set(panel_copy{f}(a).Children(end-2),'Color','none');
            else
                if ~multiplot
                    delete(panel_copy{f}(a).Children(1));
                end
            end
        end
        for a = 3
            panel_copy{f}(a).XTickLabel = [];
            panel_copy{f}(a).YTickLabel = [];
            panel_copy{f}(a).XLabel.String = [];
            panel_copy{f}(a).YLabel.String = [];
        end
            
    end
    panel_copy([5,4]) = deal(panel_copy([4,5]));
    hfigallinone = figure('Position',pos.*[1,1,1.5,1],'Color',[1 1 1],'Visible','off');
    norm_to_pix = [pos(3),pos(4),pos(3),pos(4)];
    
    Progress(0.4,h.Progress_Axes,h.Progress_Text,'Generating figure...');
    
    % read out corrections of all files
    corr = struct('CrossTalk_GR',[],'DirectExcitation_GR',[],'Gamma_GR',[],...
        'Beta_GR',[],'GfactorGreen',[],'GfactorRed',[],'FoersterRadius',[],...
        'LinkerLength',[],'DonorLifetime',[],'AcceptorLifetime',[],...
        'r0_green',[],'r0_red',[]);
    for i = 1:numel(file)
        corr.CrossTalk_GR(end+1) = BurstData{file(i)}.Corrections.CrossTalk_GR;
        corr.DirectExcitation_GR(end+1) = BurstData{file(i)}.Corrections.DirectExcitation_GR;
        corr.Gamma_GR(end+1) = BurstData{file(i)}.Corrections.Gamma_GR;
        corr.Beta_GR(end+1) = BurstData{file(i)}.Corrections.Beta_GR;
        corr.GfactorGreen(end+1) = BurstData{file(i)}.Corrections.GfactorGreen;
        corr.GfactorRed(end+1) = BurstData{file(i)}.Corrections.GfactorRed;
        corr.FoersterRadius(end+1) = BurstData{file(i)}.Corrections.FoersterRadius;
        corr.LinkerLength(end+1) = BurstData{file(i)}.Corrections.LinkerLength;
        corr.DonorLifetime(end+1) = BurstData{file(i)}.Corrections.DonorLifetime;
        corr.AcceptorLifetime(end+1) = BurstData{file(i)}.Corrections.AcceptorLifetime;
        corr.r0_green(end+1) = BurstData{file(i)}.Corrections.r0_green;
        corr.r0_red(end+1) = BurstData{file(i)}.Corrections.r0_red;
    end
    % check if all files have the same values, if yes, replace array with
    % single value
    fields = fieldnames(corr);
    for i = 1:numel(fields)
        if all(corr.(fields{i}) == corr.(fields{i})(1))
            corr.(fields{i}) = corr.(fields{i})(1);
        end
    end
    
    Pos = struct;
    %tauD - E plots
    Pos.Y.tauD_E =  [0.06 0.53 0.06 0.35].*norm_to_pix;
    Pos.X.tauD_E =   [0.12 0.88 0.35 0.06].*norm_to_pix;
    Pos.XY.tauD_E =   [0.12 0.53 0.35 0.35].*norm_to_pix;
    %tauD - rD plots
    Pos.Y.tauD_rD = [0.06 0.18 0.06 0.35].*norm_to_pix;
    Pos.X.tauD_rD =  [0.12 0.12 0.35 0.06].*norm_to_pix;
    Pos.XY.tauD_rD =  [0.12 0.18 0.35 0.35].*norm_to_pix;
    if arrangement == 1
        %[1, 2, 3;
        %[4, 5,  ];
        Pos.Y.tauA_E =  [1.5  1.5  0.06 0.35].*norm_to_pix; %move it out of the screen
        Pos.X.tauA_E =  [0.47 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_E = [0.47 0.53 0.35 0.35].*norm_to_pix;
        Pos.Y.tauA_rA = [0.82 0.18 0.06 0.35].*norm_to_pix;
        Pos.X.tauA_rA = [0.47 0.12 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_rA =[0.47 0.18 0.35 0.35].*norm_to_pix;
        Pos.Y.S_E =     [1.17 0.53 0.06 0.35].*norm_to_pix;
        Pos.X.S_E =     [0.82 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.S_E =    [0.82 0.53 0.35 0.35].*norm_to_pix;
        Pos.cbar =      [0.98,0.49,0.19,0.02].*norm_to_pix;
        Pos.table =     [0.6000 0.180 0.2750 0.2750];
    else
        %[1, 3, 2;
        %[4,  , 5];
        Pos.Y.tauA_E =  [1.17  0.53  0.06 0.35].*norm_to_pix;
        Pos.X.tauA_E =  [0.82 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_E = [0.82 0.53 0.35 0.35].*norm_to_pix;
        Pos.Y.tauA_rA = [1.17 0.18 0.06 0.35].*norm_to_pix;
        Pos.X.tauA_rA = [0.82 0.12 0.35 0.06].*norm_to_pix;
        Pos.XY.tauA_rA =[0.82 0.18 0.35 0.35].*norm_to_pix;
        Pos.Y.S_E =     [1.17 1.5 0.06 0.35].*norm_to_pix; %move it out of the screen
        Pos.X.S_E =     [0.47 0.88 0.35 0.06].*norm_to_pix;
        Pos.XY.S_E =    [0.47 0.53 0.35 0.35].*norm_to_pix;
        Pos.cbar =      [0.55,0.47,0.19,0.02].*norm_to_pix;
        Pos.table =     [0.32 0.180 0.22 0.25];
    end
    
    % 2D Lifetime-E
    copyobj([panel_copy{1}],hfigallinone);delete(panel_copy{1});
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauD_E;
    set(hfigallinone.Children(1).YLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(1).XAxisLocation = 'bottom';
    hfigallinone.Children(1).YLabel.Position = [0.48 1.1 0];
    set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(1).XLabel.Position = [-0.55 0.5 0];
    hfigallinone.Children(1).XLabel.String = 'FRET Efficiency';
    set(hfigallinone.Children(1), 'Ydir','reverse')
    hfigallinone.Children(1).YAxisLocation = 'Right';
    hfigallinone.Children(1).YTickLabelRotation = 90;
    hfigallinone.Children(1).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(1).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(1).YTick = [];
    hfigallinone.Children(1).YLabel.String = '';
    hfigallinone.Children(1).XLim = [-0.1 1.1];
    
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauD_E;   
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.43 1.5 0];
    hfigallinone.Children(2).YAxisLocation = 'Right';
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(2).TickLength = [0.0100 0.0250];
    hfigallinone.Children(2).YTickLabel = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).XLabel.String = 'Lifetime D [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauD_E;
    hfigallinone.Children(3).XAxisLocation = 'top';
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YTickLabel = [];
    hfigallinone.Children(3).YLabel.String = '';
    hfigallinone.Children(3).YLim = [-0.1 1.1];
    
    b = 1;
    labels = hfigallinone.Children(b).XTickLabel;
    if hfigallinone.Children(b).XTick(1) == hfigallinone.Children(1).XLim(1)
        labels{1} = '';
    end
    hfigallinone.Children(b).XTickLabel = labels;
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';

    if overlay
        if ~multiplot
            hfigallinone.Children(1).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(1).Visible = 'off';
        hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
        hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
        hfigallinone.Children(3).YLabel.Units = 'norm';
        hfigallinone.Children(3).YLabel.Position(1) = -0.17;
        if ~multiplot
            hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = 1.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
   
    % 2D lifetime GG-Anisotropy GG
    copyobj([panel_copy{2}],hfigallinone);delete(panel_copy{2});
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauD_rD;
    hfigallinone.Children(1).YLabel.Color = 'k';
    set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(1).XAxisLocation = 'bottom';
    hfigallinone.Children(1).XLabel.Position = [-0.55 0.5 0];
    hfigallinone.Children(1).XLabel.String = 'Anisotropy D';
    hfigallinone.Children(1).TickLength = [0.0100 0.0250];
    hfigallinone.Children(1).YAxisLocation = 'Left';
    hfigallinone.Children(1).YTickLabelRotation = 90;
    hfigallinone.Children(1).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(1).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(1).YTick = [500 1000 1500];
    hfigallinone.Children(1).YTick = [];
    hfigallinone.Children(1).YLabel.String = '';
    
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauD_rD;
    hfigallinone.Children(2).XAxisLocation = 'bottom';
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).YTickLabel = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).XLabel.Position = [0.50 -0.5 0];
    hfigallinone.Children(2).XLabel.String = 'Lifetime D [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauD_rD;
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YTickLabel = [];
    hfigallinone.Children(3).YLabel.String = '';
    
    set(hfigallinone.Children(1), 'Ydir','reverse')
    set(hfigallinone.Children(2), 'Ydir','reverse')
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        if ~multiplot
            hfigallinone.Children(1).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(1).Visible = 'off';
        hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
        hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
        hfigallinone.Children(3).YLabel.Units = 'norm';
        hfigallinone.Children(3).YLabel.Position(1) = -0.17;
        if ~multiplot
            hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = -0.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
    
    Progress(0.6,h.Progress_Axes,h.Progress_Text,'Generating figure...');
    
    % 2D lifetime RR-Anisotropy RR
    copyobj([panel_copy{3}],hfigallinone);delete(panel_copy{3});
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauA_rA;
    set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm','rotation', -90);
    hfigallinone.Children(1).XLabel.Position = [2.1 0.5 0];
    hfigallinone.Children(1).XLabel.String = 'Anisotropy A';
    hfigallinone.Children(1).YAxisLocation = 'Right';
    hfigallinone.Children(1).YTickLabelRotation = -90;
    hfigallinone.Children(1).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(1).YAxis.FontSize = fontsize;
    catch
        %hfigallinone.Children(1).FontSize = fontsize;
    end
    hfigallinone.Children(1).YTick = [];
    
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauA_rA;
    hfigallinone.Children(2).XAxisLocation = 'bottom';
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.50 -0.5 0];
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    %hfigallinone.Children(2).XTick = [0 1 2 3 4 5 6];
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).XLabel.String = 'Lifetime A [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauA_rA;
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YTickLabel = [];
    hfigallinone.Children(3).YLabel.String = '';
    
    set(hfigallinone.Children(2), 'Ydir','reverse')
	b = 1;
    labels = hfigallinone.Children(b).XTickLabel;
    if hfigallinone.Children(b).XTick(end) == hfigallinone.Children(b).XLim(2)
        labels{end} = '';
    end
    hfigallinone.Children(b).XTickLabel = labels;
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        if ~multiplot
            hfigallinone.Children(1).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(1).Visible = 'off';
        hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
        hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
        hfigallinone.Children(3).YLabel.Units = 'norm';
        hfigallinone.Children(3).YLabel.Rotation = -90;
        hfigallinone.Children(3).YTickLabelRotation = -90;
        hfigallinone.Children(3).YAxisLocation = 'right';
        hfigallinone.Children(3).YLabel.Position(1) = 1.24;
        if ~multiplot
            hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = -0.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end

    % 2D E-tauA
    copyobj([panel_copy{5}],hfigallinone);delete(panel_copy{5});
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.tauA_E;
    if arrangement == 1
        hfigallinone.Children(1).Visible = 'off';
    else
        set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm','rotation', -90);
        hfigallinone.Children(1).XLabel.Position = [2.1 0.5 0];
        hfigallinone.Children(1).XLabel.String = 'FRET Efficiency';
        hfigallinone.Children(1).YAxisLocation = 'Right';
        hfigallinone.Children(1).YTickLabelRotation = -90;
        try
            hfigallinone.Children(1).YAxis.FontSize = fontsize;
        catch
            %hfigallinone.Children(1).FontSize = fontsize;
        end
        hfigallinone.Children(1).YTick = [];
    end

    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.tauA_E;
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.50 1.5 0];
    hfigallinone.Children(2).YAxisLocation = 'Right';
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(2).TickLength = [0.0100 0.0250];
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).YLabel.String = '';
    hfigallinone.Children(2).XLabel.String = 'Lifetime A [ns]';
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.tauA_E;
    hfigallinone.Children(3).XAxisLocation = 'top';
    hfigallinone.Children(3).XLabel.Position = [0.50 1.0 0];
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    hfigallinone.Children(3).YLim = [-0.1 1.1];
%     b = 2;
%     labels = hfigallinone.Children(b).XTickLabel;
%     if hfigallinone.Children(b).XTick(1) == hfigallinone.Children(b).XLim(1)
%         labels{1} = '';
%     end
%     hfigallinone.Children(b).XTickLabel = labels;
    hfigallinone.Children(b).YTick = [];
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        if arrangement == 2
            set(findobj(hfigallinone.Children(1).Children,'Type','bar'),'FaceColor',[opacity,opacity,opacity]);
            hfigallinone.Children(1).Visible = 'off';
            hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
            hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
            hfigallinone.Children(3).YLabel.Units = 'norm';
            hfigallinone.Children(3).YLabel.Rotation = -90;
            hfigallinone.Children(3).YTickLabelRotation = -90;
            hfigallinone.Children(3).YAxisLocation = 'right';
            hfigallinone.Children(3).YLabel.Position(1) = 1.24;
        end
        if ~multiplot
            hfigallinone.Children(2).Children(1).FaceColor = [opacity,opacity,opacity];
        end
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(1:2) = [0.5, 1.17];
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
    
    Progress(0.8,h.Progress_Axes,h.Progress_Text,'Generating figure...');
    
    % 2D Stoichiometry-E
    copyobj([panel_copy{4}],hfigallinone);delete(panel_copy{4});
    delete(hfigallinone.Children(strcmp(get(hfigallinone.Children,'Type'),'uicontextmenu')));
    hfigallinone.Children(1).Units = 'pixel';
    hfigallinone.Children(1).Position = Pos.Y.S_E;
    if arrangement == 2
        hfigallinone.Children(1).Visible = 'off';
    else
        hfigallinone.Children(1).YTickLabel = [];
        hfigallinone.Children(1).YLabel.String = '';
        hfigallinone.Children(1).YTick = [];
        hfigallinone.Children(1).XLabel.String = 'FRET Efficiency';
        set(hfigallinone.Children(1).XLabel,'Color', 'k', 'Units', 'norm','rotation', -90);
        hfigallinone.Children(1).XLabel.Position = [2.1 0.5 0];
        if ~multiplot
            hfigallinone.Children(1).YLim(2) = max(hfigallinone.Children(1).Children(end-1).YData)*1.05; %%% adapt to YLim of related axes
        end
    end
    hfigallinone.Children(2).Units = 'pixel';
    hfigallinone.Children(2).Position = Pos.X.S_E;
    set(hfigallinone.Children(2).XLabel,'Color', 'k', 'Units', 'norm');
    hfigallinone.Children(2).XLabel.Position = [0.50 1.5 0];
    hfigallinone.Children(2).YAxisLocation = 'Right';
    hfigallinone.Children(2).YLabel.FontSize = fontsize;
    try
        hfigallinone.Children(2).YAxis.FontSize = fontsize;
    end
    hfigallinone.Children(2).TickLength = [0.0100 0.0250];
    hfigallinone.Children(2).YTick = [];
    hfigallinone.Children(2).YLabel.String = '';
    if ~multiplot
        hfigallinone.Children(2).YLim(2) = max(hfigallinone.Children(2).Children(end-1).YData)*1.05; %%% adapt to YLim of related axes
    end
    
    hfigallinone.Children(3).Units = 'pixel';
    hfigallinone.Children(3).Position = Pos.XY.S_E;
    hfigallinone.Children(3).XAxisLocation = 'top';
    hfigallinone.Children(3).XLabel.Position = [0.50 1.0 0];
    hfigallinone.Children(3).XGrid = 'on';
    hfigallinone.Children(3).YGrid = 'on';
    b = 2;
    labels = hfigallinone.Children(b).XTickLabel;
    if hfigallinone.Children(b).XTick(1) == hfigallinone.Children(b).XLim(1)
        labels{1} = '';
    end
    hfigallinone.Children(b).XTickLabel = labels;
    hfigallinone.Children(b).YTick = [];
    
    hfigallinone.Children(1).Layer = 'top';
    hfigallinone.Children(2).Layer = 'top';
    
    if overlay
        if arrangement == 1
            set(findobj(hfigallinone.Children(1).Children,'Type','bar'),'FaceColor',[opacity,opacity,opacity]);
            hfigallinone.Children(1).Visible = 'off';
            hfigallinone.Children(3).YLabel.String = hfigallinone.Children(1).XLabel.String;
            hfigallinone.Children(3).YTickLabel = hfigallinone.Children(1).XTickLabel;
            hfigallinone.Children(3).YLabel.Units = 'norm';
            hfigallinone.Children(3).YLabel.Rotation = -90;
            hfigallinone.Children(3).YTickLabelRotation = -90;
            hfigallinone.Children(3).YAxisLocation = 'right';
            hfigallinone.Children(3).YLabel.Position(1) = 1.24;
        end
        set(findobj(hfigallinone.Children(2).Children,'Type','bar'),'FaceColor',[opacity,opacity,opacity]);
        hfigallinone.Children(2).Visible = 'off';
        hfigallinone.Children(3).XLabel.String = hfigallinone.Children(2).XLabel.String;
        hfigallinone.Children(3).XTickLabel = hfigallinone.Children(2).XTickLabel;
        hfigallinone.Children(3).XLabel.Units = 'norm';
        hfigallinone.Children(3).XLabel.Position(2) = 1.17;
        hfigallinone.Children(3).TickDir = 'out';
        uistack(hfigallinone.Children(1:2),'bottom');
    end
    
    for u = 1:5
        close(hfig{u})
    end
    colormap(colormap(h.BurstBrowser));
    
    %%% fix plots overlaying on axes
    if ~UserValues.BurstBrowser.Display.PlotGridAboveData
        % find 2d axes
        ax2d = {};
        for i = 1:numel(hfigallinone.Children)
            if  strcmp(hfigallinone.Children(i).Type,'axes')
                if any(strcmp(get(hfigallinone.Children(i).Children,'Type'),'image'))
                    ax2d{end+1} = hfigallinone.Children(i);
                end
            end
        end
        for i = 1:numel(ax2d)
            %%% create dummy axis to prevent data overlapping the axis
            ax_dummy = axes('Parent',hfigallinone,'Units',ax2d{i}.Units,'Position',ax2d{i}.Position);
            %linkaxes([ax2d ax_dummy]);
            set(ax_dummy,'Color','none','XTick',ax2d{i}.XTick,'YTick',ax2d{i}.YTick,'XTickLabel',[],'YTickLabel',[],...
                'LineWidth',1,'Box','on','XLim',ax2d{i}.XLim, 'YLim', ax2d{i}.YLim);
        end
    end
    
    %%% add colorbar
    cbar = colorbar('peer', hfigallinone.Children(1),'Location','north','Color',[0 0 0]); 
    cbar.Units = 'pixel';
    cbar.Position = Pos.cbar;
    cbar.Label.String = 'Occurrence';
    cbar.Label.FontSize = 16;
    if ispc
        cbar.Label.FontSize = cbar.Label.FontSize/1.2;
    end
    cbar.Limits(1) = 0;
    cbar.Ticks = [];
    cbar.TickLabels = [];
    
    table_mode = 'html';
    switch table_mode
        case 'latex'
            %%% Add text box with information about applied corrections
            text_box = '$$\begin{tabular}{ll}';
            text_box = [text_box '\bf{Correction factors} & \\ '];
            text_box = [text_box sprintf('crosstalk: & %.2f\\\\ ',corr.CrossTalk_GR)];
            text_box = [text_box sprintf('direct excitation: & %.2f\\\\ ',corr.DirectExcitation_GR)];
            text_box = [text_box sprintf('$\\gamma$-factor: & %.2f\\\\ ',corr.Gamma_GR)];
            text_box = [text_box sprintf('$\\beta$-factor: & %.2f\\\\ ',corr.Beta_GR)];
            text_box = [text_box sprintf('$G_{D}$: & %.2f\\\\ ',corr.GfactorGreen)];
            text_box = [text_box sprintf('$G_{A}$: & %.2f\\\\ ',corr.GfactorRed)];
            text_box = [text_box ' & \\ '];
            text_box = [text_box '\bf{Dye parameters} & \\ '];
            text_box = [text_box sprintf('Foerster distance: & %.1f $\\rm{\\AA}$\\\\ ',corr.FoersterRadius)];
            text_box = [text_box sprintf('Linker length: & %.1f $\\rm{\\AA}$\\\\ ',corr.LinkerLength)];
            text_box = [text_box sprintf('Donor lifetime: & %.2f ns\\\\ ',corr.DonorLifetime)];
            text_box = [text_box sprintf('Acceptor lifetime: & %.2f ns\\\\ ',corr.AcceptorLifetime)];
            text_box = [text_box sprintf('$r_0(D)$: & %.2f\\\\ ',corr.r0_green)];
            text_box = [text_box sprintf('$r_0(A)$: & %.2f\\\\ ',corr.r0_red)];
            text_box = [text_box '\end{tabular}$$'];
            
            t=text(-1,0,text_box,'interpreter','latex','FontSize',fontsize);
            t.Units = 'normalized';
            t.Position = [-3.34 -0.81];
        case 'html'
            % preformat number->string conversion
            CrossTalk_GR = sprintf('%.2f/', corr.CrossTalk_GR); CrossTalk_GR = CrossTalk_GR(1:end-1);
            DirectExcitation_GR = sprintf('%.2f/', corr.DirectExcitation_GR); DirectExcitation_GR = DirectExcitation_GR(1:end-1);
            Gamma_GR = sprintf('%.2f/', corr.Gamma_GR); Gamma_GR = Gamma_GR(1:end-1);
            Beta_GR = sprintf('%.2f/', corr.Beta_GR); Beta_GR = Beta_GR(1:end-1);
            GfactorGreen = sprintf('%.2f/', corr.GfactorGreen); GfactorGreen = GfactorGreen(1:end-1);
            GfactorRed = sprintf('%.2f/', corr.GfactorRed); GfactorRed = GfactorRed(1:end-1);
            FoersterRadius = sprintf('%.1f/', corr.FoersterRadius); FoersterRadius = FoersterRadius(1:end-1);
            LinkerLength = sprintf('%.1f/', corr.LinkerLength); LinkerLength = LinkerLength(1:end-1);
            DonorLifetime = sprintf('%.2f/', corr.DonorLifetime); DonorLifetime = DonorLifetime(1:end-1);
            AcceptorLifetime = sprintf('%.2f/', corr.AcceptorLifetime); AcceptorLifetime = AcceptorLifetime(1:end-1);
            r0_green = sprintf('%.2f/', corr.r0_green); r0_green = r0_green(1:end-1);
            r0_red = sprintf('%.2f/', corr.r0_red); r0_red = r0_red(1:end-1);
            if arrangement == 1
                fontsize = 10; if ispc; fontsize = fontsize./1.2;end
                table = '<html><table>';
                table = [table '<tr><th align="left">Correction factors</th><th></th><th>&nbsp;&nbsp;</th><th align="left">Dye parameters</th><th></th></tr>'];
                table = [table '<tr><td>crosstalk:</td><td>' CrossTalk_GR '</td><td>&nbsp;</td><td>Foerster distance:</td><td>' FoersterRadius ' &#8491;</td></tr>'];
                table = [table '<tr><td>direct excitation:</td><td>' DirectExcitation_GR '</td><td>&nbsp;</td><td>app. Linker length:</td><td>' LinkerLength ' &#8491;</td></tr>'];
                table = [table '<tr><td>&gamma;-factor:</td><td>' Gamma_GR '</td><td>&nbsp;</td><td>Donor lifetime:</td><td>' DonorLifetime ' ns</td></tr>'];
                table = [table '<tr><td>&beta;-factor:</td><td>' Beta_GR '</td><td>&nbsp;</td><td>Acceptor lifetime:</td><td>' AcceptorLifetime ' ns</td></tr>'];
                table = [table '<tr><td>G<sub>D</sub>:</td><td>' GfactorGreen '</td><td>&nbsp;</td><td>r<sub>0</sub>(D):</td><td>' r0_green '</td></tr>'];
                table = [table '<tr><td>G<sub>A</sub>:</td><td>' GfactorRed '</td><td>&nbsp;</td><td>r<sub>0</sub>(A):</td><td>' r0_red '</td></tr>'];
                table = [table '</table></html>'];
            else
                fontsize = 10; if ispc; fontsize = fontsize./1.2;end
                table = '<html><table>';
                table = [table '<tr><th align="left">Correction factors</th><th></th><th>&nbsp;&nbsp;</th><th align="left">Dye parameters</th><th></th></tr>'];
                table = [table '<tr><td>crosstalk:</td><td>' CrossTalk_GR '</td><td>&nbsp;</td><td>Foerster distance:</td><td>' FoersterRadius ' &#8491;</td></tr>'];
                table = [table '<tr><td>direct excitation:</td><td>' DirectExcitation_GR '</td><td>&nbsp;</td><td>app. Linker length:</td><td>' LinkerLength ' &#8491;</td></tr>'];
                table = [table '<tr><td>&gamma;-factor:</td><td>' Gamma_GR '</td><td>&nbsp;</td><td>Donor lifetime:</td><td>' DonorLifetime ' ns</td></tr>'];
                table = [table '<tr><td>&beta;-factor:</td><td>' Beta_GR '</td><td>&nbsp;</td><td>Acceptor lifetime:</td><td>' AcceptorLifetime ' ns</td></tr>'];
                table = [table '<tr><td>G<sub>D</sub>:</td><td>' GfactorGreen '</td><td>&nbsp;</td><td>r<sub>0</sub>(D):</td><td>' r0_green '</td></tr>'];
                table = [table '<tr><td>G<sub>A</sub>:</td><td>' GfactorRed '</td><td>&nbsp;</td><td>r<sub>0</sub>(A):</td><td>' r0_red '</td></tr>'];
                table = [table '</table></html>'];
            end
            hTextbox = uicontrol('style','pushbutton', 'max',1000, 'Units', 'normalized', 'Position', Pos.table,...
                'FontName', UserValues.Look.Font, 'String',table, 'BackgroundColor',[1,1,1], 'FontSize', fontsize);
            hTextbox.Units = 'pixel';
            jPushButton = findjobj(hTextbox);
            jPushButton.setBorderPainted(false);
    end
    %%% Set all units to pixels for easy editing without resizing
    hfigallinone.Units = 'pixels';
    offset_y = 80; %%% shift everything down
    offset_x = 30; %%% shift everything left
    for i = 1:numel(hfigallinone.Children)
        if isprop(hfigallinone.Children(i),'Units');
            hfigallinone.Children(i).Units = 'pixels';
            hfigallinone.Children(i).Position(2) = hfigallinone.Children(i).Position(2) - offset_y;
            hfigallinone.Children(i).Position(1) = hfigallinone.Children(i).Position(1) - offset_x;
        end
    end
    hfigallinone.Position(3) = 1100 - offset_x;
    hfigallinone.Position(4) = hfigallinone.Position(4) - offset_y - 30;
    %%% Combine the Original FileName and the parameter names
    if isfield(BurstData{file(k)},'FileNameSPC')
        if strcmp(BurstData{file(k)}.FileNameSPC,'_m1')
            FileName = BurstData{file(k)}.FileNameSPC(1:end-3);
        else
            FileName = BurstData{file(k)}.FileNameSPC;
        end
    else
        FileName = BurstData{file(k)}.FileName(1:end-4);
    end

    if BurstData{file(k)}.SelectedSpecies(1) ~= 0
        SpeciesName = ['_' BurstData{file(k)}.SpeciesNames{BurstData{file(k)}.SelectedSpecies(1),1}];
        if BurstData{file(k)}.SelectedSpecies(2) > 1 %%% subspecies selected, append
            SpeciesName = [SpeciesName '_' BurstData{file(k)}.SpeciesNames{BurstData{file(k)}.SelectedSpecies(1),BurstData{file(k)}.SelectedSpecies(2)}];
        end
    else
        SpeciesName = '';
    end
    FigureName = 'AllInOne';
    FigureName = [FileName SpeciesName '_' FigureName];
    hfigallinone.Name = FigureName;
    hfigallinone.NumberTitle = 'off';
    %%% remove spaces
    FigureName = strrep(strrep(FigureName,' ','_'),'/','-');
    hfigallinone.CloseRequestFcn = {@ExportGraph_CloseFunction,1,FigureName};
    hfigallinone.Visible= 'on';
    %BurstData{file(k)}.SelectedSpecies = SelectedSpecies_old;
    
    %Progress(k/numel(file),h.Progress_Axes,h.Progress_Text,'Generating figure...');
    Progress(1,h.Progress_Axes,h.Progress_Text,'Generating figure...');
end 
h.ParameterListX.Value = old_paramX;
h.ParameterListY.Value = old_paramY;
%BurstMeta.SelectedFile = file_old;
if ~isempty(BurstMeta.ReportFile)
    %%% a report file exists, add figure to it
    report_generator([],[],2,h);
end
UpdatePlot([],[],h);
Progress(1,h.Progress_Axes,h.Progress_Text,'Done');