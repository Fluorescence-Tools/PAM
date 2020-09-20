%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Initializes/Resets Plots %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Initialize_Plots(mode)
global BurstMeta UserValues BurstData
h = guidata(findobj('Tag','BurstBrowser'));
%%% supress warning associated with constant Z data and contour plots
warning('off','MATLAB:contour:ConstantData');
warning('off','MATLAB:gui:array:InvalidArrayShape');
switch mode
    case 1
        %%% Initialize Plots in Global Variable
        %%% Enables easy Updating later on
        BurstMeta.Plots = [];
        %%% Main Tab
        BurstMeta.Plots.Main_histX(1) = bar(h.axes_1d_x,[0 1],[nan nan],'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1,'UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Main_histX(2) = stairs(h.axes_1d_x,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.Main_histY(1) = bar(h.axes_1d_y,[0 1],[nan nan],'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1,'UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Main_histY(2) = stairs(h.axes_1d_y,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.ZScale_hist(1)= bar(h.axes_ZScale,0.5,1,'FaceColor',[0.6 0.6 0.6],'BarWidth',1,'LineStyle','none','UIContextMenu',h.ExportGraph_Menu,'Visible','off');
        BurstMeta.Plots.ZScale_hist(2) = stairs(h.axes_ZScale,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1,'Visible','off');
        %%% Initialize both image AND contour plots in array
        BurstMeta.Plots.Main_Plot(1) = imagesc(linspace(0,1,10),linspace(0,1,10),zeros(10),'Parent',h.axes_general,'UIContextMenu',h.ExportGraph_Menu);axis(h.axes_general,'tight');
        [~,BurstMeta.Plots.Main_Plot(2)] = contourf(linspace(0,1,10),linspace(0,1,10),zeros(10),10,'Parent',h.axes_general,'Visible','off');BurstMeta.Plots.Main_Plot(2).UIContextMenu = h.ExportGraph_Menu;
        BurstMeta.HexPlot.MainPlot_hex = [];
        BurstMeta.Plots.Main_Plot(3) = scatter([0,1],[0,1],'.','Parent',h.axes_general,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Main Tab multiple species (consider up to three)
        BurstMeta.Plots.Multi.Main_Plot_multiple = imagesc(zeros(2),'Parent',h.axes_general,'Visible','off','UIContextMenu',h.ExportGraph_Menu);
        BurstMeta.Plots.Multi.Multi_histX(1) = stairs(h.axes_1d_x,0.5,1,'Color','b','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(2) = stairs(h.axes_1d_x,0.5,1,'Color','r','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(3) = stairs(h.axes_1d_x,0.5,1,'Color','g','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(4) = stairs(h.axes_1d_x,0.5,1,'Color','y','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(5) = stairs(h.axes_1d_x,0.5,1,'Color','k','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histX(6) = stairs(h.axes_1d_x,0.5,1,'Color','c','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(1) = stairs(h.axes_1d_y,0.5,1,'Color','b','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(2) = stairs(h.axes_1d_y,0.5,1,'Color','r','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(3) = stairs(h.axes_1d_y,0.5,1,'Color','g','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(4) = stairs(h.axes_1d_y,0.5,1,'Color','y','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(5) = stairs(h.axes_1d_y,0.5,1,'Color','k','LineWidth',2,'Visible','off');
        BurstMeta.Plots.Multi.Multi_histY(6) = stairs(h.axes_1d_y,0.5,1,'Color','c','LineWidth',2,'Visible','off');
        BurstMeta.Plots.MultiScatter.h1dx = [];
        BurstMeta.Plots.MultiScatter.h1dy = [];
        BurstMeta.Plots.Multi.ContourPatches = [];
        %%% Plots for Gaussian mixture fitting
        [~,BurstMeta.Plots.Mixture.Main_Plot(2)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(2).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(3)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(3).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(4)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine4,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(4).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(5)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine5,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(5).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(6)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine6,'LineStyle','--');BurstMeta.Plots.Mixture.Main_Plot(6).UIContextMenu = h.ExportGraph_Menu;
        [~,BurstMeta.Plots.Mixture.Main_Plot(1)] = contour(zeros(2),10,'Parent',h.axes_general,'Visible','off','LineWidth',2,'LineColor',UserValues.BurstBrowser.Display.ColorLine1);BurstMeta.Plots.Mixture.Main_Plot(1).UIContextMenu = h.ExportGraph_Menu;
        BurstMeta.Plots.Mixture.plotX(2) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(3) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(4) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine4,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(5) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine5,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(6) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine6,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotX(1) = plot(h.axes_1d_x,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Visible','off');
        BurstMeta.Plots.Mixture.plotY(2) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(3) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(4) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine4,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(5) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine5,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(6) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine6,'LineWidth',2,'Visible','off','LineStyle','--');
        BurstMeta.Plots.Mixture.plotY(1) = plot(h.axes_1d_y,0.5,1,'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineWidth',2,'Visible','off');
        %%%Corrections Tab
        BurstMeta.Plots.histE_donly = bar(h.Corrections.TwoCMFD.axes_crosstalk,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histE_donly(1) = plot(h.Corrections.TwoCMFD.axes_crosstalk,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histE_donly(2) = plot(h.Corrections.TwoCMFD.axes_crosstalk,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histE_donly(3) = plot(h.Corrections.TwoCMFD.axes_crosstalk,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histS_aonly = bar(h.Corrections.TwoCMFD.axes_direct_excitation,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histS_aonly(1) = plot(h.Corrections.TwoCMFD.axes_direct_excitation,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histS_aonly(2) = plot(h.Corrections.TwoCMFD.axes_direct_excitation,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histS_aonly(3) = plot(h.Corrections.TwoCMFD.axes_direct_excitation,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.gamma_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma);axis(h.Corrections.TwoCMFD.axes_gamma,'tight');
        [~,BurstMeta.Plots.gamma_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.TwoCMFD.axes_gamma,'Visible','off');
        BurstMeta.Plots.Fits.gamma = plot(h.Corrections.TwoCMFD.axes_gamma,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_manual = scatter(h.Corrections.TwoCMFD.axes_gamma,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
        BurstMeta.Plots.gamma_lifetime(1) = imagesc(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma_lifetime);axis(h.Corrections.TwoCMFD.axes_gamma_lifetime,'tight');
        [~,BurstMeta.Plots.gamma_lifetime(2)] = contourf(zeros(2),'Parent',h.Corrections.TwoCMFD.axes_gamma_lifetime,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_gamma_lifetime = plot(h.Corrections.TwoCMFD.axes_gamma_lifetime,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Lifetime Tab
        BurstMeta.Plots.EvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauGG);axis(h.axes_EvsTauGG,'tight');
        [~,BurstMeta.Plots.EvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauGG,'Visible','off');
        BurstMeta.Plots.EvsTauGG(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.EvsTauGG(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.EvsTauGG = [];
        BurstMeta.Plots.EvsTauGG(3) = scatter([0,1],[0,1],'.','Parent',h.axes_EvsTauGG,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        BurstMeta.Plots.Fits.staticFRET_EvsTauGG = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1) = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(2) = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(3) = plot(h.axes_EvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine4,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.EvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_EvsTauRR);axis(h.axes_EvsTauRR,'tight');
        [~,BurstMeta.Plots.EvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_EvsTauRR,'Visible','off');
        BurstMeta.Plots.EvsTauRR(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.EvsTauRR(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.EvsTauRR = [];
        BurstMeta.Plots.EvsTauRR(3) = scatter([0,1],[0,1],'.','Parent',h.axes_EvsTauRR,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        BurstMeta.Plots.Fits.AcceptorLifetime_EvsTauRR = plot(h.axes_EvsTauGG,[0],[1],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rGGvsTauGG(1) = imagesc(zeros(2),'Parent',h.axes_rGGvsTauGG);axis(h.axes_rGGvsTauGG,'tight');
        [~,BurstMeta.Plots.rGGvsTauGG(2)] = contourf(zeros(2),10,'Parent',h.axes_rGGvsTauGG,'Visible','off');
        BurstMeta.Plots.rGGvsTauGG(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rGGvsTauGG(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.rGGvsTauGG = [];
        BurstMeta.Plots.rGGvsTauGG(3) = scatter([0,1],[0,1],'.','Parent',h.axes_rGGvsTauGG,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinGG(1) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(2) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinGG(3) = plot(h.axes_rGGvsTauGG,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rRRvsTauRR(1) = imagesc(zeros(2),'Parent',h.axes_rRRvsTauRR);axis(h.axes_rRRvsTauRR,'tight');
        [~,BurstMeta.Plots.rRRvsTauRR(2)] = contourf(zeros(2),10,'Parent',h.axes_rRRvsTauRR,'Visible','off');axis(h.axes_rRRvsTauRR,'tight');
        BurstMeta.Plots.rRRvsTauRR(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rRRvsTauRR(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.rRRvsTauRR = [];
        BurstMeta.Plots.rRRvsTauRR(3) = scatter([0,1],[0,1],'.','Parent',h.axes_rRRvsTauRR,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinRR(1) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(2) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinRR(3) = plot(h.axes_rRRvsTauRR,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Lifetime Tab 3C
        BurstMeta.Plots.E_BtoGRvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_E_BtoGRvsTauBB);axis(h.axes_E_BtoGRvsTauBB,'tight');
        [~,BurstMeta.Plots.E_BtoGRvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_E_BtoGRvsTauBB,'Visible','off');
        BurstMeta.Plots.E_BtoGRvsTauBB(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.E_BtoGRvsTauBB(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.E_BtoGRvsTauBB = [];
        BurstMeta.Plots.E_BtoGRvsTauBB(3) = scatter([0,1],[0,1],'.','Parent',h.axes_E_BtoGRvsTauBB,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.rBBvsTauBB(1) = imagesc(zeros(2),'Parent',h.axes_rBBvsTauBB);axis(h.axes_rBBvsTauBB,'tight');
        [~,BurstMeta.Plots.rBBvsTauBB(2)] = contourf(zeros(2),10,'Parent',h.axes_rBBvsTauBB,'Visible','off');
        BurstMeta.Plots.rBBvsTauBB(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rBBvsTauBB(2).UIContextMenu = h.LifeTime_Menu;
        BurstMeta.HexPlot.rBBvsTauBB = [];
        BurstMeta.Plots.rBBvsTauBB(3) = scatter([0,1],[0,1],'.','Parent',h.axes_rBBvsTauBB,'CData',UserValues.BurstBrowser.Display.MarkerColor,'SizeData',UserValues.BurstBrowser.Display.MarkerSize);
        %%% Consider up to three Perrin lines
        BurstMeta.Plots.Fits.PerrinBB(1) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(2) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.PerrinBB(3) = plot(h.axes_rBBvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','-','LineWidth',3,'Visible','off');
        %%% Individual Lifetime Tab
        BurstMeta.Plots.LifetimeInd_histX(1) = bar(h.axes_lifetime_ind_1d_x,0.5,1,'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1);BurstMeta.Plots.LifetimeInd_histX.UIContextMenu = h.ExportGraphLifetime_Menu;
        BurstMeta.Plots.LifetimeInd_histX(2) = stairs(h.axes_lifetime_ind_1d_x,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.LifetimeInd_histY(1) = bar(h.axes_lifetime_ind_1d_y,0.5,1,'FaceColor',[0.6 0.6 0.6],'EdgeColor','none','BarWidth',1);BurstMeta.Plots.LifetimeInd_histY.UIContextMenu = h.ExportGraphLifetime_Menu;
        BurstMeta.Plots.LifetimeInd_histY(2) = stairs(h.axes_lifetime_ind_1d_y,[0 1],[nan nan],'Color',[0,0,0],'LineWidth',1);
        BurstMeta.Plots.MultiScatter.h1dx_lifetime = [];
        BurstMeta.Plots.MultiScatter.h1dy_lifetime = [];
        %%% fFCS Tab
        BurstMeta.Plots.fFCS.IRF_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species1_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0,0,1],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species2_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0.4667 0.6745 0.1882],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species3_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0.6353 0.0784 0.1843],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_DOnly_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Microtime_Total_par = plot(h.axes_fFCS_DecayPar,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.IRF_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species1_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0,0,1],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species2_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0.4667 0.6745 0.1882],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Microtime_Species3_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0.6353 0.0784 0.1843],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Microtime_DOnly_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Microtime_Total_perp = plot(h.axes_fFCS_DecayPerp,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.FilterPar_Species1 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0,0,1],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_Species2 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0.4667 0.6745 0.1882],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_Species3 = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0.6353 0.0784 0.1843],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.FilterPar_IRF = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPar_DOnly = plot(h.axes_fFCS_FilterPar,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Reconstruction_Par = plot(h.axes_fFCS_ReconstructionPar,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Decay_Par = plot(h.axes_fFCS_ReconstructionPar,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Weighted_Residuals_Par = plot(h.axes_fFCS_ReconstructionParResiduals,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        
        BurstMeta.Plots.fFCS.FilterPerp_Species1 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0,0,1],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_Species2 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0.4667 0.6745 0.1882],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_Species3 = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0.6353 0.0784 0.1843],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.FilterPerp_IRF = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.FilterPerp_DOnly = plot(h.axes_fFCS_FilterPerp,[0 1],[0 0],'Color',[0.75 0 0.75],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.Reconstruction_Perp = plot(h.axes_fFCS_ReconstructionPerp,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Reconstruction_Decay_Perp = plot(h.axes_fFCS_ReconstructionPerp,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.Weighted_Residuals_Perp = plot(h.axes_fFCS_ReconstructionPerpResiduals,[0 1],[0 0],'Color','k','LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_1x1 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0,0,1],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_2x2 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0.4667 0.6745 0.1882],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_3x3 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0.6353 0.0784 0.1843],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_1x2 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0,1,1],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_2x1 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0 0.5 0.5],'LineStyle','-','LineWidth',1);
        BurstMeta.Plots.fFCS.result_1x3 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[1,0,1],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.result_3x1 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0.5,0,0.5],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.result_2x3 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[1,1,0],'LineStyle','-','LineWidth',1,'Visible','off');
        BurstMeta.Plots.fFCS.result_3x2 = plot(h.axes_fFCS_Result,[0 1],[0 0],'Color',[0.5,0.5,0],'LineStyle','-','LineWidth',1,'Visible','off');
        
        %%%Corrections Tab for 3CMFD
        BurstMeta.Plots.histEBG_blueonly = bar(h.Corrections.ThreeCMFD.axes_crosstalk_BG,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histEBG_blueonly(1) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BG,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histEBG_blueonly(2) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histEBG_blueonly(3) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histEBR_blueonly = bar(h.Corrections.ThreeCMFD.axes_crosstalk_BR,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histEBR_blueonly(1) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BR,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histEBR_blueonly(2) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histEBR_blueonly(3) = plot(h.Corrections.ThreeCMFD.axes_crosstalk_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histSBG_greenonly = bar(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histSBG_greenonly(1) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histSBG_greenonly(2) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histSBG_greenonly(3) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BG,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.histSBR_redonly = bar(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,0.5,1,'FaceColor',[0 0 0],'BarWidth',1);
        %%%Consider fits also (three lines for 2 gauss fit)
        BurstMeta.Plots.Fits.histSBR_redonly(1) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,[0 1],[0 0],'Color','r','LineStyle','-','LineWidth',3);
        BurstMeta.Plots.Fits.histSBR_redonly(2) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.histSBR_redonly(3) = plot(h.Corrections.ThreeCMFD.axes_direct_excitation_BR,[0 1],[0 0],'Color','r','LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.gamma_BG_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gammaBG_threecolor);axis(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'tight');
        [~,BurstMeta.Plots.gamma_BG_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,'Visible','off');
        BurstMeta.Plots.Fits.gamma_BG = plot(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_BG_manual = scatter(h.Corrections.ThreeCMFD.axes_gammaBG_threecolor,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
        BurstMeta.Plots.gamma_BR_fit(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gammaBR_threecolor);axis(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'tight');
        [~,BurstMeta.Plots.gamma_BR_fit(2)] = contourf(zeros(2),10,'Parent',h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,'Visible','off');
        BurstMeta.Plots.Fits.gamma_BR = plot(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3);  %Fit
        BurstMeta.Plots.Fits.gamma_BR_manual = scatter(h.Corrections.ThreeCMFD.axes_gammaBR_threecolor,[0 1],[0 1],1000,'+','LineWidth',4,'MarkerFaceColor','b','MarkerEdgeColor','b','Visible','off');  %Manual
        BurstMeta.Plots.gamma_threecolor_lifetime(1) = imagesc(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime);axis(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'tight');
        [~,BurstMeta.Plots.gamma_threecolor_lifetime(2)] = contourf(zeros(2),'Parent',h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,'Visible','off');
        BurstMeta.Plots.Fits.staticFRET_gamma_threecolor_lifetime = plot(h.Corrections.ThreeCMFD.axes_gamma_threecolor_lifetime,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','-','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_E_BtoGRvsTauBB(1) = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine1,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_E_BtoGRvsTauBB(2) = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine2,'LineStyle','--','LineWidth',3,'Visible','off');
        BurstMeta.Plots.Fits.dynamicFRET_E_BtoGRvsTauBB(3) = plot(h.axes_E_BtoGRvsTauBB,[0 1],[0 0],'Color',UserValues.BurstBrowser.Display.ColorLine3,'LineStyle','--','LineWidth',3,'Visible','off');
        
        ChangePlotType(h.PlotContourLines,[]);
        ChangePlotType(h.PlotTypePopumenu,[]);

        %%% Force switchgui to 2color to update axis label positions and
        %%% axis locations
        if isempty(BurstData)
            SwitchGUI(2,1);
        else
            SwitchGUI(BurstData{1}.BAMethod,1);
        end
    case 2
        %%% reset plots
        obj = [findall(h.BurstBrowser,'Type','stair');...
            findall(h.BurstBrowser,'Type','line');...
            findall(h.BurstBrowser,'Type','bar')];
        set(obj,'XData',0.5,'YData',1);
        obj = findall(h.BurstBrowser,'Type','image');
        set(obj,'XData',[0 1],'YData',[0 1],'CData',zeros(2));
        obj = findall(h.BurstBrowser,'Type','contour');
        set(obj,'XData',[0 1],'YData',[0 1],'ZData',zeros(2));
end
