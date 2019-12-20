%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Change GUI to 2cMFD or 3cMFD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SwitchGUI(BAMethod,force)
global UserValues
h = guidata(findobj('Tag','BurstBrowser'));
if nargin == 1
    force = 0;
end
%%% convert BAMethod to 2 (2colorMFD) or 3 (3cMFD)
if any(BAMethod == [1,2,5])
    if BAMethod ~= 5
        MFD = true;
    else
        MFD = false;
    end
    BAMethod = 2;
elseif any(BAMethod == [3,4])
    BAMethod = 3;
end
%%% determine which GUI format is currently used
%%% This can be done by checking whether the Corrections Tab for 3cMFD is
%%% hidden or not
if (h.Main_Tab_Corrections_ThreeCMFD.Parent == h.Hide_Tab)
    %%% Three-color Corrections Tab is currently hidden
    %%% Two-color MFD was set
    PreviousBAMethod = 2;
elseif (h.Main_Tab_Corrections_ThreeCMFD.Parent == h.Main_Tab)
    %%% Three-color Corrections Tab is currently active
    %%% Three-color MFD was set
    PreviousBAMethod = 3;
end

%%% stop here if no change
if force == 0
    if PreviousBAMethod == BAMethod
        return;
    end
end

%%% unhide panel if change is TO 3cMFD
if BAMethod == 3
    %% Change Tabs
    
    %%% move the three-color Corrections Tab to Main Panel
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Main_Tab;
    %%% Then add again the other tabs in correct order
    h.Main_Tab_Lifetime.Parent = h.Main_Tab;
    h.Main_Tab_fFCS.Parent = h.Main_Tab;
    
    %h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem.Visible = 'on';
    %% Change correction table
    Corrections_Rownames = {'<html><b>&gamma(GR)</b></html>','<html><b>&gamma(BG)</b></html>','<html><b>&gamma(BR)</b></html>','<html><b>&beta(GR)</b></html>','<html><b>&beta(BG</b>)</html>','<html><b>&beta(BR)</b></html>',...
        '<html><b>crosstalk GR</b></html>','<html><b>crosstalk BG</b></html>','<html><b>crosstalk BR</b></html>','<html><b>direct exc. GR</b></html>','<html><b>direct exc. BG</b></html>','<html><b>direct exc. BR</b></html>',...
        '<html><b>G(blue)</b></html>','<html><b>G(green)</b></html>','<html><b>G(red)</b></html>','<html><b>l1</b></html>','<html><b>l2</b></html>',...
        '<html><b>BG BB par</b></html>','<html><b>BG BB perp</b></html>','<html><b>BG BG par</b></html>','<html><b>BG BG perp</b></html>','<html><b>BG BR par</b></html>','<html><b>BG BR perp</b></html>',...
        '<html><b>BG GG par</b></html>','<html><b>BG GG perp</b></html>','<html><b>BG GR par</b></html>','<html><b>BG GR perp</b></html>','<html><b>BG RR par</b></html>','<html><b>BG RR perp</b></html>'}';
    Corrections_Data = {1;1;1;1;1;1;...
        0;0;0;0;0;0;...
        0;0;0;0;0;0;...
        0;0;0;0;0;0;...
        1;1;1;0;0};
    %% Change Corrections GUI
    h.DetermineGammaLifetimeThreeColorButton.Visible = 'on';
    %%% Add DetermineGammaLifetimeThreeColorButton to layout
    % remove last two elements
    h.ApplyCorrectionsButton.Parent = h.SecondaryTabCorrectionsPanel;
    h.UseBetaCheckbox.Parent = h.SecondaryTabCorrectionsPanel;
    % add in correct order
    h.DetermineGammaLifetimeThreeColorButton.Parent = h.CorrectionsButtonsContainer;
    h.ApplyCorrectionsButton.Parent = h.CorrectionsButtonsContainer;
    h.UseBetaCheckbox.Parent = h.CorrectionsButtonsContainer;
    
    h.FoersterRadiusText.String = 'Foerster Radius GR [A]';
    h.LinkerLengthText.String = 'Linker Length GR [A]';
    h.FoersterRadiusBGEdit.Visible = 'on';
    h.FoersterRadiusBGText.Visible = 'on';
    h.FoersterRadiusBREdit.Visible = 'on';
    h.FoersterRadiusBRText.Visible = 'on';
    h.LinkerLengthBGEdit.Visible = 'on';
    h.LinkerLengthBGText.Visible = 'on';
    h.LinkerLengthBREdit.Visible = 'on';
    h.LinkerLengthBRText.Visible = 'on';
    h.DonorLifetimeBlueText.Visible = 'on';
    h.DonorLifetimeBlueEdit.Visible = 'on';
    h.r0Green_text.String = 'r0 Green';
    h.r0Red_text.String = 'r0 Red';
    h.r0Blue_edit.Visible = 'on';
    h.r0Blue_text.Visible = 'on';
    %% Change Lifetime GUI
    %%% Make 3C-Plots visible
    h.axes_E_BtoGRvsTauBB.Parent = h.LifetimePanelAll;
    h.axes_rBBvsTauBB.Parent = h.LifetimePanelAll;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.05 0.57 (0.8/3) 0.4];
    h.axes_EvsTauRR.Position = [(0.1+0.8/3)+0.0125 0.57 (0.8/3) 0.4];
    h.axes_rGGvsTauGG.Position = [0.05 0.07 (0.8/3) 0.4];
    h.axes_rRRvsTauRR.Position = [(0.1+0.8/3)+0.0125 0.07 (0.8/3) 0.4];
    
    %%% Change axes in lifetime tab
    h.axes_EvsTauGG.YLabel.String = 'FRET Efficiency GR';
    h.axes_EvsTauGG.XLabel.String = '\tau_{GG} [ns]';
    h.axes_EvsTauGG.Title.String = 'FRET Efficiency GR vs. Lifetime GG';
    h.axes_EvsTauGG.Title.Color = UserValues.Look.Fore;
    h.axes_EvsTauRR.YLabel.String = 'FRET Efficiency GR';
    h.axes_EvsTauRR.XLabel.String = '\tau_{RR} [ns]';
    h.axes_EvsTauRR.Title.String = 'FRET Efficiency GR vs. Lifetime RR';
    h.axes_EvsTauRR.Title.Color = UserValues.Look.Fore;
    h.axes_rGGvsTauGG.XLabel.String = '\tau_{GG} [ns]';
    h.axes_rGGvsTauGG.YLabel.String = 'r_{GG}';
    h.axes_rGGvsTauGG.YLabel.Position= [-0.12, 0.5, 0];
    h.axes_rGGvsTauGG.Title.String= 'Anisotropy GG vs Lifetime GG';
    h.axes_rRRvsTauRR.XLabel.String = '\tau_{RR} [ns]';
    h.axes_rRRvsTauRR.YLabel.String = 'r_{RR}';
    h.axes_rRRvsTauRR.YLabel.Position= [-0.12, 0.5, 0];
    h.axes_rRRvsTauRR.Title.String= 'Anisotropy RR vs Lifetime RR';
    %%% Unhide TauBB Export Option
    h.ExportEvsTauBB_Menu.Visible = 'on';
    %%% Update Popupmenu in LifetimeInd Tab
    h.lifetime_ind_popupmenu.String = {'<html>E vs &tau;<sub>GG</sub></html>',...
        '<html>E vs &tau;<sub>RR</sub></html>',...
        '<html>E<sub>B->G+R</sub> vs &tau;<sub>BB</sub></html>',...
        '<html>r<sub>GG</sub> vs &tau;<sub>GG</sub></html>',...
        '<html>r<sub>RR</sub> vs &tau;<sub>RR</sub></html>',...
        '<html>r<sub>BB</sub> vs &tau;<sub>BB</sub></html>'};   
    %% Change Correlation Table
    Names = {'BB1','BB2','BG1','BG2','BR1','BR2','GG1','GG2','GR1','GR2','RR1','RR2','BX1','BX2','GX1','GX2','BB','BG','BR','GG','GR','RR','BX','GX'};
    h.Correlation_Table.RowName = Names;
    h.Correlation_Table.ColumnName = Names;
    h.Correlation_Table.Data = logical(zeros(numel(Names)));
    h.Secondary_Tab_Correlation_Standard2CMFD_Menu.Visible = 'off';
    %% Change BVA Tab
    h.FRETpair_text.Visible = 'on';
    h.FRETpair_Popupmenu.Visible = 'on';
    %% Change CutDatabase
    %%% Update string if cuts have been stores
    if (numel(UserValues.BurstBrowser.CutDatabase) > 1) && ~isempty(UserValues.BurstBrowser.CutDatabase{2})
        if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{2}))
            h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{2});
        end
    else
        h.CutDatabase.String = {'-'};
    end
elseif BAMethod == 2
    %%% move the three-color Corrections Tab to the Hide_Tab
    h.Main_Tab_Corrections_ThreeCMFD.Parent = h.Hide_Tab;
    %%% reset Corrections Table
    Corrections_Rownames = {'<html><b>&gamma</b></html>','<html><b>&beta</b></html>',...
        '<html><b>crosstalk</b></html>','<html><b>direct exc.</b></html>',...
        '<html><b>G(D)</b></html>','<html><b>G(A)</b></html>',...
        '<html><b>l1</b></html>','<html><b>l2</b></html>',...
        '<html><b>BG DD par</b></html>','<html><b>BG DD perp</b></html>','<html><b>BG DA par</b></html>',...
        '<html><b>BG DA perp</b></html>','<html><b>BG AA par</b></html>','<html><b>BG AA perp</b></html>'}';
    Corrections_Data = {1;1;0;0;1;1;0;0;0;0;0;0;0;0};
    %%% Hide 3cMFD corrections
    %h.ExportSpeciesToPDA_2C_for3CMFD_MenuItem.Visible = 'off';
    h.DetermineGammaLifetimeThreeColorButton.Visible = 'off';
    h.DetermineGammaLifetimeThreeColorButton.Parent = h.SecondaryTabCorrectionsPanel;
    h.FoersterRadiusText.String = 'Foerster Radius [A]';
    h.LinkerLengthText.String = 'Linker Length [A]';
    h.FoersterRadiusBGEdit.Visible = 'off';
    h.FoersterRadiusBGText.Visible = 'off';
    h.FoersterRadiusBREdit.Visible = 'off';
    h.FoersterRadiusBRText.Visible = 'off';
    h.LinkerLengthBGEdit.Visible = 'off';
    h.LinkerLengthBGText.Visible = 'off';
    h.LinkerLengthBREdit.Visible = 'off';
    h.LinkerLengthBRText.Visible = 'off';
    h.DonorLifetimeBlueText.Visible = 'off';
    h.DonorLifetimeBlueEdit.Visible = 'off';
    h.r0Green_text.String = 'r0 Donor';
    h.r0Red_text.String = 'r0 Acceptor';
    h.r0Blue_edit.Visible = 'off';
    h.r0Blue_text.Visible = 'off';
    %%% Reset Lifetime Plots
    %%% Make 3C-Plots invisible
    h.axes_E_BtoGRvsTauBB.Parent = h.Hide_Stuff;
    h.axes_rBBvsTauBB.Parent =  h.Hide_Stuff;
    %%% Change Position of 2Color-Plots
    h.axes_EvsTauGG.Position = [0.075 0.57 0.4 0.4];
    h.axes_EvsTauRR.Position = [0.575 0.57 0.4 0.4];
    h.axes_rGGvsTauGG.Position = [0.075 0.07 0.4 0.4];
    h.axes_rRRvsTauRR.Position = [0.575 0.07 0.4 0.4];
    
    %%% Change axes in lifetime tab
    h.axes_EvsTauGG.YLabel.String = 'FRET Efficiency';
    h.axes_EvsTauGG.XLabel.String = '\tau_{D(A)} [ns]';
    h.axes_EvsTauGG.Title.String = 'FRET Efficiency vs. Lifetime D';
    h.axes_EvsTauGG.Title.Color = UserValues.Look.Fore;
    h.axes_EvsTauRR.YLabel.String = 'FRET Efficiency';
    h.axes_EvsTauGG.XLabel.String = '\tau_{D(A)} [ns]';
    h.axes_EvsTauRR.Title.String = 'FRET Efficiency vs. Lifetime A';
    h.axes_EvsTauRR.Title.Color = UserValues.Look.Fore;
    h.axes_rGGvsTauGG.XLabel.String = '\tau_{D(A)} [ns]';
    h.axes_rGGvsTauGG.YLabel.String = 'r_{D}';
    h.axes_rGGvsTauGG.YLabel.Position= [-0.125, 0.5, 0];
    h.axes_rGGvsTauGG.Title.String= 'Anisotropy D vs Lifetime D';
    h.axes_rRRvsTauRR.XLabel.String = '\tau_{A} [ns]';
    h.axes_rRRvsTauRR.YLabel.String = 'r_{A}';
    h.axes_rRRvsTauRR.YLabel.Position= [-0.125, 0.5, 0];
    h.axes_rRRvsTauRR.Title.String= 'Anisotropy A vs Lifetime A';
    %%% Hide TauBB Export Option
    h.ExportEvsTauBB_Menu.Visible = 'off';
    %% Change Correlation Table
    if MFD %%% 2cMFD
            Names = {'DD1','DD2','DA1','DA2','AA1','AA2','DD','DA','DX','DX1','DX2','AA'};
    else %%% no polarization
            Names = {'DD','DA','AA','DX'};
    end
    h.Correlation_Table.RowName = Names;
    h.Correlation_Table.ColumnName = Names;
    h.Correlation_Table.Data = logical(zeros(numel(Names)));
    h.Secondary_Tab_Correlation_Standard2CMFD_Menu.Visible = 'on';
    %% Change BVA Tab
    h.FRETpair_text.Visible = 'off';
    h.FRETpair_Popupmenu.Visible = 'off';
    %% lifetime ind
    h.lifetime_ind_popupmenu.String = {'<html>E vs &tau;<sub>D(A)</sub></html>','<html>E vs &tau;<sub>A</sub></html>','<html>r<sub>D</sub> vs &tau;<sub>D(A)</sub></html>','<html>r<sub>A</sub> vs &tau;<sub>A</sub></html>'};
    %% Change CutDatabase
    %%% Update string if cuts have been stores
    if ~isempty(fieldnames(UserValues.BurstBrowser.CutDatabase{1}))
        h.CutDatabase.String = fieldnames(UserValues.BurstBrowser.CutDatabase{1});
    else
        h.CutDatabase.String = {'-'};
    end
end
%h.CorrectionsTable.RowName = Corrections_Rownames;
h.CorrectionsTable.Data = horzcat(Corrections_Rownames,Corrections_Data);
%%% Update CorrectionsTable with UserValues-stored Data
UpdateCorrections([],[],h)