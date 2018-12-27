%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Updates Lifetime Plot (+fit) in the left Corrections Tab %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateLifetimeFits(obj,~)
global BurstData UserValues BurstMeta
h = guidata(obj);
file = BurstMeta.SelectedFile;
%%% Use the current cut Data (of the selected species) for plots
datatoplot = BurstData{file}.DataCut;
%%% read out the indices of the parameters to plot
switch BurstData{file}.BAMethod
    case {1,2,5}
        idx_tauGG = strcmp('Lifetime D [ns]',BurstData{file}.NameArray);
        idx_tauRR = strcmp('Lifetime A [ns]',BurstData{file}.NameArray);
        idx_rGG = strcmp('Anisotropy D',BurstData{file}.NameArray);
        idx_rRR = strcmp('Anisotropy A',BurstData{file}.NameArray);
    case {3,4}
        idx_tauGG = strcmp('Lifetime GG [ns]',BurstData{file}.NameArray);
        idx_tauRR = strcmp('Lifetime RR [ns]',BurstData{file}.NameArray);
        idx_rGG = strcmp('Anisotropy GG',BurstData{file}.NameArray);
        idx_rRR = strcmp('Anisotropy RR',BurstData{file}.NameArray);
end
%% Add Fits
if obj == h.PlotStaticFRETButton
    %% Add a static FRET line EvsTau plots
    %%% Calculate static FRET line in presence of linker fluctuations
    [staticFRETline, ~,tau] = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
        BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.Visible = 'on';
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.XData = tau;
    BurstMeta.Plots.Fits.staticFRET_EvsTauGG.YData = staticFRETline;
    %BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG.Visible = 'off';
    if any(BurstData{file}.BAMethod == [3,4])
        %%% Calculate static FRET line in presence of linker fluctuations
        [staticFRETline,~,tau] = conversion_tau_3C(BurstData{file}.Corrections.DonorLifetimeBlue,...
            BurstData{file}.Corrections.FoersterRadiusBG,BurstData{file}.Corrections.FoersterRadiusBR,...
            BurstData{file}.Corrections.LinkerLengthBG,BurstData{file}.Corrections.LinkerLengthBR);
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.Visible = 'on';
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.XData = tau;
        BurstMeta.Plots.Fits.staticFRET_E_BtoGRvsTauBB.YData = staticFRETline;
    end
end
if any(obj == [h.PlotDynamicFRETButton, h.DynamicFRETManual_Menu, h.DynamicFRETRemove_Menu])
    switch obj
        case {h.PlotDynamicFRETButton, h.DynamicFRETManual_Menu}
            if obj == h.PlotDynamicFRETButton
                menu_stored = h.axes_EvsTauGG.UIContextMenu; 
                h.axes_EvsTauGG.UIContextMenu = []; set(h.axes_EvsTauGG.Children,'UIContextMenu',[]);
                h.axes_lifetime_ind_2d.UIContextMenu = []; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',[]);
                %%% Query Lifetimes using ginput
                if verLessThan('MATLAB','9.5')
                    %ha = get(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(1),'parent');
%                     ind_axes = flipud(h.axes_lifetime_ind_2d.Children);
%                     if strcmp(ind_axes(1).Visible,'off')
                    %ha = h.axes_lifetime_ind_2d;
                    switch h.LifetimeTabgroup.SelectedTab.Title
                        case 'All'
                            [x,y,button] = ginputax(h.axes_EvsTauGG,2);
                        case 'Individual'
                            [x,y,button] = ginputax(h.axes_lifetime_ind_2d,2);
                    end
                    %[x,y,button] = ginput(2);
                else % 2018b onwards
                    [x,y,button] = my_ginput(2);
                end
                if gca == h.axes_lifetime_ind_2d
                    switch BurstData{file}.BAMethod
                        case {1,2,5}
                            switch h.lifetime_ind_popupmenu.Value
                                case 1 % E vs tauGG is selected
                                    axes(h.axes_EvsTauGG)
                                case {5,6} % Phasor of donor or acceptor is selected
                                    %%% do nothing, axes_lifetime_ind_2d
                            end
                        case {3,4}
                            switch h.lifetime_ind_popupmenu.Value
                                case 1 % E vs tauGG is selected
                                    axes(h.axes_EvsTauGG)
                            end
                    end
                end
                if (gca ~= h.axes_EvsTauGG) && h.lifetime_ind_popupmenu.Value == 1
                    m=msgbox('Click on a E vs. tauGG axis!');
                    pause(1);
                    delete(m);
                    return;
                end
                switch h.lifetime_ind_popupmenu.Value
                    case 1 % E vs tau relation
                        %y = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
                        %    BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength,...
                        %    x);
                        if button(1) == 1 %%% left mouseclick, update first line, reset all others off
                            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(2).Visible = 'off';
                            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(3).Visible = 'off';
                            line = 1;
                        elseif button(1) == 3
                            %%% Check for visibility of plots
                            for i = 1:3
                                vis(i) = strcmp(BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(i).Visible,'on');
                            end
                            if sum(vis) == 3 %% all visible
                                line = 3; %%% update last plot
                            elseif sum(vis) == 0 %% all hidden
                                line = 1;
                            else %%% find the first hidden plot
                                line = find(vis == 0, 1,'first');
                            end
                        end
                        h.axes_EvsTauGG.UIContextMenu = menu_stored; set(h.axes_EvsTauGG.Children,'UIContextMenu',menu_stored);
                        h.axes_lifetime_ind_2d.UIContextMenu = h.axes_lifetime_ind_1d_x.UIContextMenu; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',h.axes_lifetime_ind_1d_x.UIContextMenu);
                    case {5,6} % Phasor plots
                        % draw a line through the universal circles
                        m = (y(2)-y(1))/(x(2)-x(1)); b = (y(1)*x(2)-y(2)*x(1))/(x(2)-x(1));
                        % use p-q formula
                        p = (2*m*b-1)/(m^2+1); q = b^2/(m^2+1);
                        xp1 = -p/2 - sqrt(p^2/4-q); xp2 =  -p/2 + sqrt(p^2/4-q);
                        xp = xp1:0.01:xp2; yp = m*xp+b;
                        plot(xp,yp,'--','LineWidth',3,'Color',UserValues.BurstBrowser.Display.ColorLine2,'Parent',h.axes_lifetime_ind_2d);
                        h.axes_lifetime_ind_2d.UIContextMenu = h.axes_lifetime_ind_1d_x.UIContextMenu; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',h.axes_lifetime_ind_1d_x.UIContextMenu);
                        return;
                end
            elseif obj == h.DynamicFRETManual_Menu
                %%% Query using edit box
                %y = inputdlg({'FRET Efficiency 1','FRET Efficiency 2'},'Enter State Efficiencies',1,{'0.25','0.75'});
                data = inputdlg({'Line #','tau1 [ns]','tau2 [ns]'},'Enter State Lifetimes',1,{'1','1','3'});
                data = cellfun(@str2double,data);
                if any(isnan(data)) || isempty(data)
                    return;
                end
                x = data(2:end);
                line = data(1);
                if line < 1 || line > 3
                    return;
                end
                %y = conversion_tau(BurstData{file}.Corrections.DonorLifetime,...
                %    BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength,...
                %    x);
            end
            [dynFRETline, ~,tau] = dynamicFRETline(BurstData{file}.Corrections.DonorLifetime,...
                x(1),x(2),BurstData{file}.Corrections.FoersterRadius,BurstData{file}.Corrections.LinkerLength);
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).Visible = 'on';
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).XData = tau;
            BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(line).YData = dynFRETline;
        case h.DynamicFRETRemove_Menu
            data = inputdlg({'Line #'},'Remove dynamic line...',1,{'1'});
            data = cellfun(@str2double,data);
            if any(isnan(data))
                return;
            end
            for i=1:numel(data)
                BurstMeta.Plots.Fits.dynamicFRET_EvsTauGG(data(i)).Visible = 'off';
            end
    end
end
if obj == h.FitAnisotropyButton
    %% Add Perrin Fits to Anisotropy Plot
    %% GG
    fPerrin = @(rho,x) BurstData{file}.Corrections.r0_green./(1+x./rho); %%% x = tau
    if ~h.MultiselectOnCheckbox.UserData
        tauGG = datatoplot(:,idx_tauGG);
        rGG = datatoplot(:,idx_rGG);
    else
        switch BurstData{file}.BAMethod
            case {1,2,5}
                tauGG = get_multiselection_data(h,'Lifetime D [ns]');
                rGG = get_multiselection_data(h,'Anisotropy D');
            case {3,4}
                tauGG = get_multiselection_data(h,'Lifetime GG [ns]');
                rGG = get_multiselection_data(h,'Anisotropy GG');
        end
    end
    PerrinFitGG = fit(tauGG(~isnan(tauGG)),rGG(~isnan(tauGG)),fPerrin,'StartPoint',1);
    tau = linspace(0,h.axes_rGGvsTauGG.XLim(2),100);
    BurstMeta.Plots.Fits.PerrinGG(1).Visible = 'on';
    BurstMeta.Plots.Fits.PerrinGG(1).XData = tau;
    BurstMeta.Plots.Fits.PerrinGG(1).YData = PerrinFitGG(tau);
    BurstMeta.Plots.Fits.PerrinGG(2).Visible = 'off';
    BurstMeta.Plots.Fits.PerrinGG(3).Visible = 'off';
    
    BurstData{file}.Parameters.rhoGG = coeffvalues(PerrinFitGG);
    if any(BurstData{file}.BAMethod == [3,4])
        title(h.axes_rGGvsTauGG,['\rho_{GG} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoGG) ' ns'],'Color',UserValues.Look.Fore);
    else
        title(h.axes_rGGvsTauGG,['\rho_{D} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoGG) ' ns'],'Color',UserValues.Look.Fore);
    end
    %% RR
    fPerrin = @(rho,x) BurstData{file}.Corrections.r0_red./(1+x./rho); %%% x = tau
    if ~h.MultiselectOnCheckbox.UserData
        tauRR = datatoplot(:,idx_tauRR);
        rRR = datatoplot(:,idx_rRR);
    else
        switch BurstData{file}.BAMethod
            case {1,2,5}
                tauRR = get_multiselection_data(h,'Lifetime A [ns]');
                rRR = get_multiselection_data(h,'Anisotropy A');
            case {3,4}
                tauRR = get_multiselection_data(h,'Lifetime RR [ns]');
                rRR = get_multiselection_data(h,'Anisotropy RR');
        end
    end
    PerrinFitRR = fit(tauRR(~isnan(tauRR)),rRR(~isnan(tauRR)),fPerrin,'StartPoint',1);
    tau = linspace(0,h.axes_rRRvsTauRR.XLim(2),100);
    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
    BurstMeta.Plots.Fits.PerrinRR(1).YData = PerrinFitRR(tau);
    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
    BurstData{file}.Parameters.rhoRR = coeffvalues(PerrinFitRR);
    if any(BurstData{file}.BAMethod == [3,4])
        title(h.axes_rRRvsTauRR,['\rho_{RR} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoRR) ' ns'],'Color',UserValues.Look.Fore);
    else
        title(h.axes_rRRvsTauRR,['\rho_{A} = ' sprintf('%2.2f',BurstData{file}.Parameters.rhoRR) ' ns'],'Color',UserValues.Look.Fore);
    end
    if any(BurstData{file}.BAMethod == [3,4])
        %% BB
        idx_tauBB = strcmp('Lifetime BB [ns]',BurstData{file}.NameArray);
        idx_rBB = strcmp('Anisotropy BB',BurstData{file}.NameArray);
        if ~h.MultiselectOnCheckbox.UserData
            tauBB = datatoplot(:,idx_tauBB);
            rBB = datatoplot(:,idx_rBB);
        else
            tauBB = get_multiselection_data(h,'Lifetime BB [ns]');
            rBB = get_multiselection_data(h,'Anisotropy BB');
        end
        fPerrin = @(rho,x) BurstData{file}.Corrections.r0_blue./(1+x./rho); %%% x = tau
        valid = (tauBB > 0.01) & (tauBB < 5) &...
            (rBB > -1) & (rBB < 2) &...
            (~isnan(tauBB));
        PerrinFitBB = fit(tauBB(valid),rBB(valid),fPerrin,'StartPoint',1);
        tau = linspace(0,h.axes_rBBvsTauBB.XLim(2),100);
        BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
        BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
        BurstMeta.Plots.Fits.PerrinBB(1).YData = PerrinFitBB(tau);
        BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
        BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
        BurstData{file}.Parameters.rhoBB = coeffvalues(PerrinFitBB);
        title(h.axes_rBBvsTauBB,['\rho_{BB} = ' num2str(BurstData{file}.Parameters.rhoBB) ' ns'],'Color',UserValues.Look.Fore);
    end
end
%% Manual Perrin plots
if obj == h.ManualAnisotropyButton
    %%% disable right-click callbacks
    BurstMeta.Plots.rGGvsTauGG(1).UIContextMenu =[];BurstMeta.Plots.rGGvsTauGG(2).UIContextMenu = [];
    BurstMeta.Plots.rRRvsTauRR(1).UIContextMenu =[];BurstMeta.Plots.rRRvsTauRR(2).UIContextMenu = [];
    BurstMeta.Plots.rBBvsTauBB(1).UIContextMenu =[];BurstMeta.Plots.rBBvsTauBB(2).UIContextMenu = [];
    h.axes_lifetime_ind_2d.UIContextMenu = []; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',[]);
    if verLessThan('MATLAB','9.5')
        [x,y,button] = ginput(1);
    else % 2018b onwards
        [x,y,button] = my_ginput(1);
    end
    %%% Lifetime Ind plot: If it was selected, check what plot is active
    %%% and set gca accordingly
    if gca == h.axes_lifetime_ind_2d
        switch BurstData{file}.BAMethod
            case {1,2}
                switch h.lifetime_ind_popupmenu.Value
                    case 3 %%% rGG  vs tauGG
                        axes(h.axes_rGGvsTauGG);
                    case 4
                        axes(h.axes_rRRvsTauRR);
                    otherwise
                        m = msgbox('Click on a anistropy axis!');
                        pause(1)
                        delete(m)
                        return;
                end
            case {3,4}
                switch h.lifetime_ind_popupmenu.Value
                    case 4 %%% rGG  vs tauGG
                        axes(h.axes_rGGvsTauGG);
                    case 5
                        axes(h.axes_rRRvsTauRR);
                    case 6
                        axes(h.axes_rBBvsTauBB);
                    otherwise
                        m = msgbox('Click on a anistropy axis!');
                        pause(1)
                        delete(m)
                        return;
                end
        end
    end
    if button == 1 %%% left mouse click, reset plot and plot one perrin line
        if (gca == h.axes_rGGvsTauGG) || (gca == h.axes_rRRvsTauRR) || (gca == h.axes_rBBvsTauBB)
            haxes = gca;
            %%% Determine rho
            switch gca
                case h.axes_rGGvsTauGG
                    r0 = BurstData{file}.Corrections.r0_green;
                case h.axes_rRRvsTauRR
                    r0 = BurstData{file}.Corrections.r0_red;
                case h.axes_rBBvsTauBB
                    r0 = BurstData{file}.Corrections.r0_blue;
            end
            rho = x/(r0/y - 1);
            fitPerrin = @(x) r0./(1+x./rho);
            %%% plot
            tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
            switch haxes
                case h.axes_rGGvsTauGG
                    BurstMeta.Plots.Fits.PerrinGG(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinGG(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinGG(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinGG(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinGG(3).Visible = 'off';
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(['\rho_{GG} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    else
                        title(['\rho_{D} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    end
                    BurstData{file}.Parameters.rhoGG = rho;
                case h.axes_rRRvsTauRR
                    BurstMeta.Plots.Fits.PerrinRR(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinRR(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinRR(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinRR(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinRR(3).Visible = 'off';
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(['\rho_{RR} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    else
                        title(['\rho_{A} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    end
                    BurstData{file}.Parameters.rhoRR = rho;
                case h.axes_rBBvsTauBB
                    BurstMeta.Plots.Fits.PerrinBB(1).Visible = 'on';
                    BurstMeta.Plots.Fits.PerrinBB(1).XData = tau;
                    BurstMeta.Plots.Fits.PerrinBB(1).YData = fitPerrin(tau);
                    BurstMeta.Plots.Fits.PerrinBB(2).Visible = 'off';
                    BurstMeta.Plots.Fits.PerrinBB(3).Visible = 'off';
                    title(['\rho_{BB} = ' sprintf('%2.2f',rho) ' ns'],'Color',UserValues.Look.Fore);
                    BurstData{file}.Parameters.rhoBB = rho;
            end
        end
    elseif button == 3 %%% right mouse click, add plot if a Perrin plot already exists
        haxes = gca;
        if haxes == h.axes_rGGvsTauGG
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinGG(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData{file}.Corrections.r0_green;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinGG(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinGG(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinGG(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(haxes,['\rho_{GG} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    else
                        title(haxes,['\rho_{D} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    end
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' sprintf('%2.2f',rho) ' ns'];
                    title(new_title);
                end
                BurstData{file}.Parameters.rhoGG(vis+1) = rho;
            end
        elseif haxes == h.axes_rRRvsTauRR
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinRR(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData{file}.Corrections.r0_red;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinRR(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinRR(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinRR(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    if any(BurstData{file}.BAMethod == [3,4])
                        title(haxes,['\rho_{RR} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    else
                        title(haxes,['\rho_{A} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                    end
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' sprintf('%2.2f',rho) ' ns'];
                    title(new_title);
                end
                BurstData{file}.Parameters.rhoRR(vis+1) = rho;
            end
        elseif haxes == h.axes_rBBvsTauBB
            %%% Check for visibility of plots
            vis = 0;
            for i = 1:3
                vis = vis + strcmp(BurstMeta.Plots.Fits.PerrinBB(i).Visible,'on');
            end
            if vis < 3
                %%% Determine rho
                r0 = BurstData{file}.Corrections.r0_blue;
                rho = x/(r0/y - 1);
                fitPerrin = @(x) r0./(1+x./rho);
                tau = linspace(haxes.XLim(1),haxes.XLim(2),100);
                BurstMeta.Plots.Fits.PerrinBB(vis+1).Visible = 'on';
                BurstMeta.Plots.Fits.PerrinBB(vis+1).XData = tau;
                BurstMeta.Plots.Fits.PerrinBB(vis+1).YData = fitPerrin(tau);
                if vis == 0
                    title(haxes,['\rho_{BB} = ' sprintf('%2.2f',rho)],'Color',UserValues.Look.Fore);
                else
                    %%% add rho2 to title
                    new_title = [haxes.Title.String ' and ' sprintf('%2.2f',rho) ' ns'];
                    title(new_title);
                end
                BurstData{file}.Parameters.rhoBB(vis+1) = rho;
            end
        end
    end
    %%% reenable right-click callbacks
    BurstMeta.Plots.rGGvsTauGG(1).UIContextMenu = h.LifeTime_Menu;BurstMeta.Plots.rGGvsTauGG(2).UIContextMenu = h.LifeTime_Menu;
    BurstMeta.Plots.rRRvsTauRR(1).UIContextMenu =h.LifeTime_Menu;BurstMeta.Plots.rRRvsTauRR(2).UIContextMenu = h.LifeTime_Menu;
    BurstMeta.Plots.rBBvsTauBB(1).UIContextMenu =h.LifeTime_Menu;BurstMeta.Plots.rBBvsTauBB(2).UIContextMenu = h.LifeTime_Menu;
    h.axes_lifetime_ind_2d.UIContextMenu = h.axes_lifetime_ind_1d_x.UIContextMenu; set(h.axes_lifetime_ind_2d.Children,'UIContextMenu',h.axes_lifetime_ind_1d_x.UIContextMenu);
end
PlotLifetimeInd([],[],h);