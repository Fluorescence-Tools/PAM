function tcPDA(~,~)
global tcPDAstruct UserValues
h = findobj('Name','tcPDA');

addpath(genpath(['.' filesep 'functions']));

LSUserValues(0);

value_dummy = [1,50,2,50,2,50,2,0,0,0]';
fixed_dummy = [false,false,false,false,false,false,false,true,true,true]';
LB_dummy = [0,0,0,0,0,0,0,-Inf,-Inf,-Inf]';
UB_dummy = [Inf,150,10,150,10,150,10,Inf,Inf,Inf]';


for i = 1:10
    tcPDAstruct.fitdata.param{i} = value_dummy;
    tcPDAstruct.fitdata.fixed{i} = fixed_dummy;
    tcPDAstruct.fitdata.LB{i} = LB_dummy;
    tcPDAstruct.fitdata.UB{i} = UB_dummy;
    tcPDAstruct.fitdata.use_prior{i} = false(10,1);
    tcPDAstruct.fitdata.prior_center{i} = value_dummy;
    tcPDAstruct.fitdata.prior_sigma{i} = 0.1*value_dummy;
end

if isempty(h)
    %GUI definition
    handles.colormap = [1,0,0;0.986666679382324,0.0533333346247673,0.0533333346247673;0.973333358764648,0.106666669249535,0.106666669249535;0.959999978542328,0.159999996423721,0.159999996423721;0.946666657924652,0.213333338499069,0.213333338499069;0.933333337306976,0.266666680574417,0.266666680574417;0.920000016689301,0.319999992847443,0.319999992847443;0.906666696071625,0.373333334922791,0.373333334922791;0.893333315849304,0.426666676998138,0.426666676998138;0.879999995231628,0.480000019073486,0.480000019073486;0.866666674613953,0.533333361148834,0.533333361148834;0.853333353996277,0.586666703224182,0.586666703224182;0.840000033378601,0.639999985694885,0.639999985694885;0.826666653156281,0.693333327770233,0.693333327770233;0.813333332538605,0.746666669845581,0.746666669845581;0.800000011920929,0.800000011920929,0.800000011920929;0.812500000000000,0.812500000000000,0.812500000000000;0.824999988079071,0.824999988079071,0.824999988079071;0.837500035762787,0.837500035762787,0.837500035762787;0.850000023841858,0.850000023841858,0.850000023841858;0.862500011920929,0.862500011920929,0.862500011920929;0.875000000000000,0.875000000000000,0.875000000000000;0.887499988079071,0.887499988079071,0.887499988079071;0.899999976158142,0.899999976158142,0.899999976158142;0.912500023841858,0.912500023841858,0.912500023841858;0.925000011920929,0.925000011920929,0.925000011920929;0.937500000000000,0.937500000000000,0.937500000000000;0.949999988079071,0.949999988079071,0.949999988079071;0.962499976158142,0.962499976158142,0.962499976158142;0.975000023841858,0.975000023841858,0.975000023841858;0.987500011920929,0.987500011920929,0.987500011920929;1,1,1;0.987500011920929,0.987500011920929,0.987500011920929;0.975000023841858,0.975000023841858,0.975000023841858;0.962499976158142,0.962499976158142,0.962499976158142;0.949999988079071,0.949999988079071,0.949999988079071;0.937500000000000,0.937500000000000,0.937500000000000;0.925000011920929,0.925000011920929,0.925000011920929;0.912500023841858,0.912500023841858,0.912500023841858;0.899999976158142,0.899999976158142,0.899999976158142;0.887499988079071,0.887499988079071,0.887499988079071;0.875000000000000,0.875000000000000,0.875000000000000;0.862500011920929,0.862500011920929,0.862500011920929;0.850000023841858,0.850000023841858,0.850000023841858;0.837500035762787,0.837500035762787,0.837500035762787;0.824999988079071,0.824999988079071,0.824999988079071;0.812500000000000,0.812500000000000,0.812500000000000;0.800000011920929,0.800000011920929,0.800000011920929;0.750000000000000,0.750000000000000,0.812500000000000;0.699999988079071,0.699999988079071,0.824999988079071;0.650000035762787,0.650000035762787,0.837500035762787;0.600000023841858,0.600000023841858,0.850000023841858;0.550000011920929,0.550000011920929,0.862500011920929;0.500000000000000,0.500000000000000,0.875000000000000;0.450000017881393,0.450000017881393,0.887499988079071;0.400000005960465,0.400000005960465,0.899999976158142;0.349999994039536,0.349999994039536,0.912500023841858;0.300000011920929,0.300000011920929,0.925000011920929;0.250000000000000,0.250000000000000,0.937500000000000;0.200000002980232,0.200000002980232,0.949999988079071;0.150000005960464,0.150000005960464,0.962499976158142;0.100000001490116,0.100000001490116,0.975000023841858;0.0500000007450581,0.0500000007450581,0.987500011920929;0,0,1];
    handles.color_str = lines(10);
    handles.color_str = mat2cell(handles.color_str,ones(size(handles.color_str,1),1),size(handles.color_str,2));
    %define main window
    handles.Figure = figure(...
    'Units','normalized',...
    'Name','tcPDA',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'OuterPosition',[0.05 0.05 0.9 0.9],...
    'UserData',[],...
    'Visible','on',...
    'Tag','tcPDA',...
    'Toolbar','figure',...
    'defaultUicontrolFontName',UserValues.Look.Font,...
    'defaultAxesFontName',UserValues.Look.Font,...
    'defaultTextFontName',UserValues.Look.Font,...
    'CloseRequestFcn',@close_tcPDA);

    whitebg(handles.Figure, UserValues.Look.Axes);
    set(handles.Figure,'Color',UserValues.Look.Back);
    
    %set toolbar
    set(handles.Figure,'Toolbar','figure');
    handles.toolbar = findall(handles.Figure,'Type','uitoolbar');
    toolbar_items = findall(handles.toolbar);
    delete(toolbar_items([2:7 13:17]))
    
    cdata(:,:,1) = [251 250 251 250 250 251 250 251 250 250 251 250 251 250 250 251;253 255 255 255 255 250 249 249 249 249 249 249 249 249 249 250;229 118 87 88 143 247 255 253 253 253 253 253 253 253 249 250;74 0 0 0 0 126 225 217 217 217 217 217 216 223 250 251;6 0 13 23 21 23 34 34 34 34 34 34 33 35 123 249;0 79 227 241 240 238 237 237 237 237 237 237 237 236 226 250;17 210 168 142 144 144 144 144 144 144 144 144 144 144 146 195;62 98 0 0 0 0 0 0 0 0 0 0 0 0 0 22;58 20 0 2 2 2 2 2 2 2 2 2 2 2 0 46;47 5 2 2 2 2 2 2 2 2 2 2 2 2 0 84;29 1 2 2 2 2 2 2 2 2 2 2 2 2 0 126;11 1 2 2 2 2 2 2 2 2 2 2 2 2 0 168;50 0 0 0 0 0 0 0 0 0 0 0 0 0 23 223;207 97 79 80 80 80 80 80 80 80 80 80 79 87 188 255;254 255 255 255 255 255 255 255 255 255 255 255 255 255 253 250;251 250 251 251 251 250 251 250 251 251 250 251 250 250 250 251];
    cdata(:,:,2) = [251 250 251 250 250 251 250 251 250 250 251 250 251 250 250 251;253 255 255 255 255 250 249 249 249 249 249 249 249 249 249 250;229 118 87 88 143 247 255 253 253 253 253 253 253 253 249 250;74 0 0 0 0 126 225 217 217 217 217 217 216 223 250 251;6 0 13 23 21 23 34 34 34 34 34 34 33 35 123 249;0 79 227 241 240 238 237 237 237 237 237 237 237 236 226 250;17 210 168 142 144 144 144 144 144 144 144 144 144 144 146 195;62 98 0 0 0 0 0 0 0 0 0 0 0 0 0 22;58 20 0 2 2 2 2 2 2 2 2 2 2 2 0 46;47 5 2 2 2 2 2 2 2 2 2 2 2 2 0 84;29 1 2 2 2 2 2 2 2 2 2 2 2 2 0 126;11 1 2 2 2 2 2 2 2 2 2 2 2 2 0 168;50 0 0 0 0 0 0 0 0 0 0 0 0 0 23 223;207 97 79 80 80 80 80 80 80 80 80 80 79 87 188 255;254 255 255 255 255 255 255 255 255 255 255 255 255 255 253 250;251 250 251 251 251 250 251 250 251 251 250 251 250 250 250 251];
    cdata(:,:,3) = [251 250 251 251 250 250 250 250 250 250 250 250 250 250 250 251;253 255 255 255 255 250 249 249 249 249 249 249 249 249 249 250;229 118 87 88 143 247 255 253 253 253 253 253 253 253 249 250;74 0 0 0 0 126 225 217 217 217 217 217 216 223 250 251;6 0 13 23 21 23 34 34 34 34 34 34 33 35 123 249;0 79 227 241 240 238 237 237 237 237 237 237 237 236 226 250;17 210 168 142 144 144 144 144 144 144 144 144 144 144 146 195;62 98 0 0 0 0 0 0 0 0 0 0 0 0 0 22;58 20 0 2 2 2 2 2 2 2 2 2 2 2 0 46;47 5 2 2 2 2 2 2 2 2 2 2 2 2 0 84;29 1 2 2 2 2 2 2 2 2 2 2 2 2 0 126;11 1 2 2 2 2 2 2 2 2 2 2 2 2 0 168;50 0 0 0 0 0 0 0 0 0 0 0 0 0 23 223;207 97 79 80 80 80 80 80 80 80 80 80 79 87 188 255;254 255 255 255 255 255 255 255 255 255 255 255 255 255 253 250;251 250 251 251 251 250 251 250 251 251 250 251 250 250 250 251]; 
    cdata = cdata./max(max(max(cdata)));
    handles.load_button = uipushtool(handles.toolbar,...
        'CData',cdata,...
        'ClickedCallback',@load_data,...
        'Separator','on',...
        'Tag','Load_Button');
    
    
    
    %define tabs
    handles.tabgroup = uitabgroup(...
    'Parent',handles.Figure,...
    'Tag','Main_Tab',...
    'Units','normalized',...
    'Position',[0 0 0.7 1]);

    handles.tab_1d = uitab(handles.tabgroup,...
    'title','1D GR',...
    'BackgroundColor', UserValues.Look.Back,...
    'Tag','tab_1d'); 

    handles.tab_2d= uitab(handles.tabgroup,...
    'title','2D BG BR',...
    'BackgroundColor', UserValues.Look.Back,...
    'Tag','tab_2d'); 

    handles.tab_3d= uitab(handles.tabgroup,...
    'title','3D',...
    'BackgroundColor', UserValues.Look.Back,...
    'Tag','tab_3d');
    
    handles.tab_bayesian = uitab(handles.tabgroup,...
        'title','Bayesian',...
        'BackgroundColor', UserValues.Look.Back,...
        'Tag','tab_bayesian');
    
    handles.tabgroup_side = uitabgroup(...
    'Parent',handles.Figure,...
    'Tag','Side_Tab',...
    'Units','normalized',...
    'Position',[0.7 0.1 0.3 0.9]);

    handles.tab_fit_table = uitab(handles.tabgroup_side,...
    'title','Fit Table',...
    'BackgroundColor', UserValues.Look.Back,...
    'Tag','tab_fit_table'); 

    handles.tab_corrections= uitab(handles.tabgroup_side,...
    'title','Corrections',...
    'BackgroundColor', UserValues.Look.Back,...
    'Tag','tab_corrections'); 
    
    handles.tab_PDAData = uitab(handles.tabgroup_side,...
    'title','1D PDA data',...
    'BackgroundColor', UserValues.Look.Back,...
    'Tag','tab_2cPDAData'); 
    
    %%% fit progress axes
    handles.fit_progress_panel = uibuttongroup(...
        'Parent',handles.Figure,...
        'Units','normalized',...
        'Position',[0.7,0,0.3,0.1],...
        'BackgroundColor',UserValues.Look.Back,...
        'Tag','fit_progress_panel');
    
    handles.fit_progress_axes = axes(...
        'Parent',handles.fit_progress_panel,...
        'Units','normalized',...
        'Position',[0,0,1,1],...
        'Color',UserValues.Look.Axes,...
        'XColor',UserValues.Look.Fore,...
        'YColor',UserValues.Look.Fore,...
        'GridAlpha',0.5,...
        'FontSize',10,...
        'LineWidth', UserValues.Look.AxWidth,...
        'XGrid','on',...
        'nextplot','add',...
        'YGrid','on',...
        'Box','on',...
        'Tag','fit_progress_axes');
    handles.fit_progress_text = text(0,1,'red. \chi^2 = 0',...
        'Parent',handles.fit_progress_axes,...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'Color',[0,0,0]);
    handles.fit_progress_text.Units = 'normalized';
    handles.fit_progress_text.Position = [0.5,0.2];
    handles.plots.fit_progress = plot(handles.fit_progress_axes,...
        [0,1],[1,1],...
        'LineStyle','-',...
        'Color',[0 0.45 0.75],...%[0.85,0.33,0.1],...
        'LineWidth',2,...
        'Marker','none',...
        'MarkerSize',5,...
        'MarkerEdgeColor',[0 0.45 0.75],...
        'MarkerFaceColor',[0 0.45 0.75]);
    
    handles.fit_pause_button =  uicontrol('Parent',handles.fit_progress_panel,...
        'Style','pushbutton',...
        'Tag','fit_pause_button',...
        'Units','normalized',...
        'Position',[0.68 0.74 0.15 0.25],...
        'String','Pause',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Enable','off',...
        'Callback',[]);
    handles.fit_cancel_button =  uicontrol('Parent',handles.fit_progress_panel,...
        'Style','pushbutton',...
        'Tag','fit_cancel_button',...
        'Units','normalized',...
        'Position',[0.84 0.74 0.15 0.25],...
        'String','Stop',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Enable','off',...
        'Callback',[]);
    %define tables
    
    %define table for corrections
    data = {UserValues.tcPDA.corrections.ct_gr, UserValues.tcPDA.corrections.ct_bg, UserValues.tcPDA.corrections.ct_br,...
        UserValues.tcPDA.corrections.de_gr, UserValues.tcPDA.corrections.de_bg, UserValues.tcPDA.corrections.de_br,...
        UserValues.tcPDA.corrections.gamma_gr, UserValues.tcPDA.corrections.gamma_br,...
        UserValues.tcPDA.corrections.BG_bb, UserValues.tcPDA.corrections.BG_bg, UserValues.tcPDA.corrections.BG_br,...
        UserValues.tcPDA.corrections.BG_gg, UserValues.tcPDA.corrections.BG_gr,...
        UserValues.tcPDA.corrections.R0_gr, UserValues.tcPDA.corrections.R0_bg, UserValues.tcPDA.corrections.R0_br}';
    %data = {0,0,0,0,0,0,1,1,0,0,0,0,0,50,50,50}';
    str_dummy = {'ct GR','ct BG','ct BR',...
    'de GR', 'de BG', 'de BR',...
    'gamma GR', 'gamma BR',...
    'BG BB', 'BG BG', 'BG BR', 'BG GG', 'BG GR',...
    'R0 GR','R0 BG','R0 BR'};
    handles.corrections_table = uitable('Parent',handles.tab_corrections,...
        'Data',data,...
        'RowName',str_dummy,...
        'ColumnName',{''},...
        'Units','normalized',...
        'FontSize',12,...
        'Position',[0 0 1 0.8],...
        'ColumnWidth',{100},...
        'ColumnEditable',[true],...
        'ForegroundColor',UserValues.Look.TableFore,...
        'BackgroundColor',[UserValues.Look.Table1;UserValues.Look.Table2],...
        'CellEditCallback',@update_corrections);
    
    %make three tabs: 1D GR, 2D PB-PR and 3D all together
    %enable only one tab during fitting (depending on what fit method is
    %selected) but re-enable other tabs after fitting is complete
    %define axes
    handles.sampling_text = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.05,0.95,0.45,0.03],...
        'String','Monte-Carlo Oversampling:',...
        'Tag','sampling_text',...
        'FontSize',12,...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Parent',handles.tab_corrections);
    
    handles.sampling_edit = uicontrol('Style','edit',...
        'Units','normalized',...
        'Position',[0.5,0.95,0.25,0.03],...
        'String',num2str(UserValues.tcPDA.sampling),...
        'FontSize',12,...
        'Tag','sampling_edit',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Parent',handles.tab_corrections,...
        'Callback',@update_corrections);
    
    handles.nbins_text = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.05,0.9,0.45,0.03],...
        'String','# Bins for histograms:',...
        'Tag','nbins_text',...
        'FontSize',12,...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Parent',handles.tab_corrections);
    
    handles.nbins_edit = uicontrol('Style','edit',...
        'Units','normalized',...
        'Position',[0.5,0.9,0.25,0.03],...
        'String',num2str(UserValues.tcPDA.nbins),...
        'FontSize',12,...
        'Tag','nbins_edit',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Parent',handles.tab_corrections,...
        'Callback',@update_corrections);
    

    
    %define fit table
    str_dummy = {'<html><b>Amplitude','<html><b>R<sub>GR</sub>','<html><b>&sigma;<sub>GR</sub>','<html><b>R<sub>BG</sub>', '<html><b>&sigma;<sub>BG</sub>','<html><b>R<sub>BR</sub>','<html><b>&sigma;<sub>BR</sub>',''};
    Data = zeros(numel(str_dummy)-1,4);
    Data([3,5,7],4) = 10;
    handles.fit_table = uitable('Parent',handles.tab_fit_table,...
        'Data',Data,...
        'RowName','',...
        'ColumnName',{'<html><b>Parameter','<html><b>Value','<html><b>F','<html><b>LB','<html><b>UB','<html><b>P','<html><b>Prior &mu;','<html><b>Prior &sigma;'},...
        'Units','normalized',...
        'Position',[0 0 1 0.75],...
        'FontSize',12,...
        'ColumnWidth',{75,75,25,50,50,25,75,75},...
        'ColumnEditable',[false,true,true,true,true,true,true,true],...
        'ColumnFormat',{'char','numeric','logical','numeric','numeric','logical','numeric','numeric'},...
        'ForegroundColor',UserValues.Look.TableFore,...
        'BackgroundColor',[UserValues.Look.Table1;UserValues.Look.Table2],...
        'CellEditCallback',@update_fit_params);
    
    nbins = UserValues.tcPDA.nbins+1;
    %define axes
    handles.axes_1d = axes('Parent',handles.tab_1d,...
        'Units','normalized',...
        'Position',[0.075 0.1 0.9, 0.8],...
        'Color',UserValues.Look.Axes,...
        'XColor',UserValues.Look.Fore,...
        'YColor',UserValues.Look.Fore,...
        'GridAlpha',0.5,...
        'FontSize',12,...
        'LineWidth', UserValues.Look.AxWidth,...
        'XGrid','on',...
        'nextplot','add',...
        'YGrid','on',...
        'Box','off',...
        'XLim',[0,1],...
        'Tag','axes_1d');
  
    handles.axes_1d.XLabel.String = 'FRET efficiency GR';
    handles.axes_1d.XLabel.Color = UserValues.Look.Fore;
    handles.axes_1d.YLabel.String = '#';
    handles.axes_1d.YLabel.Color = UserValues.Look.Fore;
    handles.axes_1d.XColor = UserValues.Look.Fore;
    handles.axes_1d.YColor = UserValues.Look.Fore;
    
    x_axis = linspace(0,1,nbins)+1/(nbins-1)/2;
    x_axis_stairs = [x_axis - (x_axis(2)-x_axis(1))/2 1];
    fit = sum(peaks(nbins),1).^2/nbins;
    data = max(fit+sqrt(fit).*randn(1,nbins),0);
    handles.plots.handle_1d_data = bar(handles.axes_1d,x_axis,data,'BarWidth',1,'EdgeColor','none','LineWidth',1,'FaceColor',[0.5 0.5 0.5]);
    for i = 1:10
        handles.plots.handles_H_res_1d_individual(i) = stairs(handles.axes_1d,x_axis_stairs,[fit fit(end)],'Color',handles.color_str{i},'Visible','off','LineWidth',2);
    end
    handles.plots.handle_1d_fit = stairs(handles.axes_1d,x_axis_stairs,[fit fit(end)],'Color','k','LineWidth',2);     
    
    handles.axes_1d_res = axes('Parent',handles.tab_1d,...
        'Units','normalized',...
        'Position',[0.075 0.875 0.9, 0.1],...
        'XColor',UserValues.Look.Fore,...
        'YColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'LineWidth', UserValues.Look.AxWidth,...
        'Box','off',...
        'XGrid','on',...
        'YGrid','on',...
        'GridAlpha',0.5,...
        'XTickLabel',[],...
        'nextplot','add',...
        'XLim',[0,1],...
        'Tag','axes_1d_res');
    handles.axes_1d_res.XLabel.String = '';
    handles.axes_1d_res.YLabel.String = 'w_{res}';
    handles.axes_1d_res.YLabel.Color = UserValues.Look.Fore;
    
    dev = (data-fit)./sqrt(data); dev(dev == 0) = 0; dev(~isfinite(dev)) = 0; dev(end+1) = dev(end);
    handles.plots.handle_1d_dev = stairs(handles.axes_1d_res,x_axis_stairs,dev,'Color','k','LineWidth',2);

    linkaxes([handles.axes_1d,handles.axes_1d_res],'x');
    
    handles.axes_2d = axes('Parent',handles.tab_2d,...
        'Units','normalized',...
        'Position',[0.075 0.1 0.9, 0.65],...
        'XColor',UserValues.Look.Fore,...
        'YColor',UserValues.Look.Fore,...
        'ZColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'LineWidth', UserValues.Look.AxWidth,...
        'Box','off',...
        'nextplot','add',...
        'XLim',[0,1],...
        'YLim',[0,1],...
        'View',[45,45],...
        'Tag','axes_2d');
    handles.axes_2d.XLabel.String = 'P_{BG}';
    handles.axes_2d.XLabel.Color = UserValues.Look.Fore;
    handles.axes_2d.YLabel.String = 'P_{BR}';
    handles.axes_2d.YLabel.Color = UserValues.Look.Fore;
    handles.axes_2d.ZLabel.String = '#';
    handles.axes_2d.ZLabel.Color = UserValues.Look.Fore;
    
    fit2d = peaks(nbins).^2;
    data2d = real(max(fit2d+sqrt(fit2d).*randn(nbins),0));
    handles.plots.handle_2d_data = surf(handles.axes_2d,linspace(0,1,nbins),linspace(0,1,nbins),data2d,'FaceAlpha',0.6,'EdgeColor','none');
    handles.plots.handle_2d_fit = surf(handles.axes_2d,linspace(0,1,nbins),linspace(0,1,nbins),fit2d,'FaceColor','none','EdgeColor',[0 0 0]);
    for i = 1:10
        handles.plots.handles_H_res_2d_individual(i) = surf(handles.axes_2d,linspace(0,1,nbins),linspace(0,1,nbins),fit2d,'FaceColor','none','EdgeColor',handles.color_str{i},'Visible','off');
    end
                
    handles.axes_2d_res = axes('Parent',handles.tab_2d,...
        'Units','normalized',...
        'Position',[0.075 0.775 0.9 0.2],...
        'FontSize',12,...
        'LineWidth', UserValues.Look.AxWidth,...
        'XColor',UserValues.Look.Fore,...
        'YColor',UserValues.Look.Fore,...
        'ZColor',UserValues.Look.Fore,...
        'Box','off',...
        'nextplot','add',...
        'XLim',[0,1],...
        'YLim',[0,1],...
        'View',[45,25],...
        'Tag','axes_2d_res');
    handles.axes_2d_res.ZLabel.String = 'w_{res}';
    handles.axes_2d_res.ZLabel.Color = UserValues.Look.Fore;
    
    dev2d = (data2d-fit2d)./sqrt(data2d);dev2d(dev2d==0) = 0;
    handles.plots.handle_2d_dev = surf(handles.axes_2d_res,linspace(0,1,nbins),linspace(0,1,nbins),dev2d,'FaceAlpha',1,'EdgeColor','k');
    %link angle
    handles.axes_link_2d = linkprop([handles.axes_2d, handles.axes_2d_res],'CameraPosition');
    
    %%% 3d plot tab
    [X,Y,Z] = meshgrid(linspace(0,1,nbins),linspace(0,1,nbins),linspace(0,1,nbins));
    fit3d = mvnpdf([X(:),Y(:),Z(:)],[0.25,0.75,0.5],0.05^2*eye(3)) +...
             0.5*mvnpdf([X(:),Y(:),Z(:)],[0.5,0.3,0.6],0.04^2*eye(3)) +...
             0.75*mvnpdf([X(:),Y(:),Z(:)],[0.75,0.5,0.25],0.045^2*eye(3));
    fit3d = 1E5*reshape(fit3d,[nbins,nbins,nbins])./sum(fit3d);
    data3d = fit3d + sqrt(fit3d).*randn(nbins,nbins,nbins); %fit3d(fit3d < 0) = 0;
    handles.axes_3d = tight_subplot_tab(2,3,[0.1 0.05],[0.08,0.05],[0.05,0.05],handles.tab_3d);
    for i = 1:numel(handles.axes_3d)
        ax = handle(handles.axes_3d(i));
        set(ax,'XColor',UserValues.Look.Fore);
        set(ax,'YColor',UserValues.Look.Fore);
        set(ax,'LineWidth',UserValues.Look.AxWidth);
        set(ax,'Box','off');
        ax.XLim = [0,1];
        ax.FontSize = 12;
        ax.XLabel.FontSize = 16;
        ax.YLabel.FontSize = 16;
        ax.XLabel.Color = UserValues.Look.Fore;
        ax.YLabel.Color = UserValues.Look.Fore;
        switch i
            case {1,2,3} %%% specific for 2d plots
                set(ax,'ZColor',UserValues.Look.Fore);
                ax.ZLabel.FontSize = 16;
                ax.View = [45,25];
                ax.ZLabel.Color = UserValues.Look.Fore;
        end
        %%% create axis labels and plots
        switch i
            case 1
                ax.XLabel.String = 'P_{BR}';
                ax.YLabel.String = 'P_{BG}';
                handles.plots.handle_3d_data_bg_br =  surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(data3d,3)),'EdgeColor','none','FaceAlpha',0.6);
                for j = 1:10
                    handles.plots.handles_H_res_3d_individual_bg_br(j) = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(fit3d,3)),'FaceColor','none','EdgeColor',handles.color_str{j},'Visible','off');
                end
                handles.plots.handle_3d_fit_bg_br = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(fit3d,3)),'FaceColor','none','EdgeColor',[1 1 1]);
                ax.ZLim(1) = 0;
            case 2
                ax.XLabel.String = 'P_{GR}';
                ax.YLabel.String = 'P_{BG}';
                handles.plots.handle_3d_data_bg_gr = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(data3d,2)),'EdgeColor','none','FaceAlpha',0.6);
                for j = 1:10
                    handles.plots.handles_H_res_3d_individual_bg_gr(j) = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(fit3d,2)),'FaceColor','none','EdgeColor',handles.color_str{j},'Visible','off');
                end
                handles.plots.handle_3d_fit_bg_gr = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(fit3d,2)),'FaceColor','none','EdgeColor',[1 1 1]);
                ax.ZLim(1) = 0;
            case 3
                ax.XLabel.String = 'P_{GR}';
                ax.YLabel.String = 'P_{BR}';
                handles.plots.handle_3d_data_br_gr = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(data3d,1)),'EdgeColor','none','FaceAlpha',0.6);
                for j = 1:10
                    handles.plots.handles_H_res_3d_individual_br_gr(j) = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(fit3d,1)),'FaceColor','none','EdgeColor',handles.color_str{j},'Visible','off');
                end
                handles.plots.handle_3d_fit_br_gr = surf(ax,linspace(0,1,nbins),linspace(0,1,nbins),squeeze(sum(fit3d,1)),'FaceColor','none','EdgeColor',[1 1 1]);
                ax.ZLim(1) = 0;
            case 4
                ax.XLabel.String = 'P_{BG}';
                handles.plots.handle_3d_data_bg = bar(ax,x_axis,squeeze(sum(sum(data3d,2),3)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
                fit = squeeze(sum(sum(fit3d,2),3));
                for j = 1:10
                    handles.plots.handles_H_res_3d_individual_bg(j) = stairs(ax,x_axis_stairs,[fit; fit(end)],'Color',handles.color_str{j},'LineWidth',2,'Visible','off');
                end
                handles.plots.handle_3d_fit_bg = stairs(ax,x_axis_stairs,[fit; fit(end)],'Color','k','LineWidth',2);
                ax.YLim(1) = 0;
            case 5
                ax.XLabel.String = 'P_{BR}';
                handles.plots.handle_3d_data_br = bar(ax,x_axis,squeeze(sum(sum(data3d,1),3)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
                fit = squeeze(sum(sum(fit3d,1),3));
                for j = 1:10
                    handles.plots.handles_H_res_3d_individual_br(j) = stairs(ax,x_axis_stairs,[fit fit(end)],'Color',handles.color_str{j},'LineWidth',2,'Visible','off');
                end
                handles.plots.handle_3d_fit_br = stairs(ax,x_axis_stairs,[fit fit(end)],'Color','k','LineWidth',2);
                ax.YLim(1) = 0;
            case 6
                ax.XLabel.String = 'P_{GR}';
                handles.plots.handle_3d_data_gr = bar(ax,x_axis,squeeze(sum(sum(data3d,1),2)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
                fit = squeeze(sum(sum(fit3d,1),2));
                for j = 1:10
                    handles.plots.handles_H_res_3d_individual_gr(j) = stairs(ax,x_axis_stairs,[fit; fit(end)],'Color',handles.color_str{j},'LineWidth',2,'Visible','off');
                end
                handles.plots.handle_3d_fit_gr = stairs(ax,x_axis_stairs,[fit; fit(end)],'Color','k','LineWidth',2);
                ax.YLim(1) = 0;
        end
    end
    %chi2 text
    handles.text_chi2 = uicontrol('Parent',handles.tab_fit_table,...
         'Units','normalized',...
         'Position',[0.65 0.76 0.35 0.03],...
         'Style','text',...
         'HorizontalAlignment','center',...
         'String','chi2 = ...',...
         'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'FontSize',12,...
         'Tag','text_chi2');
     %BIC text
     handles.BIC_text = uicontrol('Parent',handles.tab_fit_table,...
         'Units','normalized',...
         'Position',[0 0.76 0.65 0.03],...
         'Style','text',...
         'HorizontalAlignment','center',...
         'String','',...
         'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'FontSize',12,...
         'Tag','BIC_text');
     
    %define buttons
    handles.button_fit = uicontrol('Parent',handles.tab_fit_table,...
        'Style','pushbutton',...
        'Tag','button_fit',...
        'Units','normalized',...
        'Position',[0.05 0.8 0.4 0.03],...
        'String','Fit',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Callback',@pushbutton_fit);
    
    handles.button_view_curve = uicontrol('Parent',handles.tab_fit_table,...
        'Style','pushbutton',...
        'Tag','button_view_curve',...
        'Units','normalized',...
        'Position',[0.55 0.8 0.4 0.03],...
        'String','View Curve',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Callback',@pushbutton_view_curve);
    
    handles.button_save_fitstate = uicontrol('Parent',handles.tab_fit_table,...
        'Style','pushbutton',...
        'Tag','button_save_fitstate',...
        'Units','normalized',...
        'Position',[0.55 0.88 0.4 0.03],...
        'FontSize',12,...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'String','Save Fit State',...
        'Callback',@pushbutton_save_fitstate);
    handles.button_save_menu = uicontextmenu;
    handles.button_save_fitstate_external = uimenu('Parent',handles.button_save_menu,...
        'Tag','button_load_fitstate',...
        'Label','Save Fit State in separate file',...
        'Callback',@pushbutton_save_fitstate);
    handles.button_load_fitstate = uimenu('Parent',handles.button_save_menu,...
        'Tag','button_load_fitstate',...
        'Label','Load Fit State from separate file',...
        'Callback',@pushbutton_load_fitstate);
    handles.button_save_fitstate.UIContextMenu = handles.button_save_menu;
    
    handles.button_export_figure = uicontrol('Parent',handles.tab_fit_table,...
        'Style','pushbutton',...
        'Tag','button_load_fitstate',...
        'Units','normalized',...
        'FontSize',12,...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Position',[0.55 0.84 0.4 0.03],...
        'String','Save Figure',...
        'Callback',@pushbutton_export_figure);
    
    handles.checkbox_stochasticlabeling = uicontrol('Parent',handles.tab_fit_table,...
        'Style','checkbox',...
        'Tag','checkbox_stochasticlabeling',...
        'Units','normalized',...
        'Position',[0.025 0.88 0.325 0.03],...
        'String','Stochastic labeling?',...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Value',UserValues.tcPDA.use_stochastic_labeling,...
        'Callback',@update_corrections);
    handles.edit_stochasticlabeling = uicontrol('Parent',handles.tab_fit_table,...
        'Style','edit',...
        'Tag','edit_stochasticlabeling',...
        'Units','normalized',...
        'Position',[0.35 0.88 0.15 0.03],...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'String',num2str(UserValues.tcPDA.stochastic_labeling_fraction),...
        'Callback',@update_corrections);
    handles.MLE_checkbox = uicontrol('Style','checkbox',...
        'Units','normalized',...
        'Position',[0.025,0.84,0.475,0.03],...
        'String','Use MLE',...
        'Tag','MLE_checkbox',...
        'FontSize',12,...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Parent',handles.tab_fit_table,...
        'Value',UserValues.tcPDA.use_MLE,...
        'Callback',@update_corrections);
    
    handles.FitMethod_popupmenu = uicontrol('Style','popupmenu',...
        'Units','normalized',...
        'Position',[0.25,0.96,0.3,0.03],...
        'String',{'Simplex','Pattern Search','Gradient-based','Gradient-based (global)'},...
        'Tag','FitMethod_popupmenu',...
        'Parent',handles.tab_fit_table,...
        'FontSize',12,...
        'Callback',[]);
    handles.FitMethodText = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.025,0.96,0.225,0.03],...
        'String','Fit Method:',...
        'Tag','FitMethod_text',...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'Parent',handles.tab_fit_table);
    
    handles.min_n_edit = uicontrol('Style','edit',...
        'Parent',handles.tab_fit_table,...
        'Units','normalized',...
        'Position',[0.8 0.96 0.15 0.03],...
        'String','0',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','min_n_edit',...
        'Callback',@Cut_Data);
    handles.min_n_text = uicontrol('Style','text',...
        'Parent',handles.tab_fit_table,...
        'Units','normalized',...
        'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'FontSize',12,...
        'Position',[0.65 0.96 0.15 0.03],...
        'HorizontalAlignment','left',...
        'String','Min N:',...
        'Tag','min_n_text');
    handles.max_n_edit = uicontrol('Style','edit',...
        'Parent',handles.tab_fit_table,...
        'Units','normalized',...
        'Position',[0.8 0.92 0.15 0.03],...
        'String','Inf',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','max_n_edit',...
        'Callback',@Cut_Data);
    handles.max_n_text = uicontrol('Style','text',...
        'Parent',handles.tab_fit_table,...
        'Units','normalized',...
        'Position',[0.65 0.92 0.15 0.03],...
        'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'FontSize',12,...
         'HorizontalAlignment','left',...
        'String','Max N:',...
        'Tag','max_n_text');
    handles.popupmenu_ngauss = uicontrol('Parent',handles.tab_fit_table,...
        'Style','popupmenu',...
        'Tag','popupmenu_ngauss',...
        'Units','normalized',...
        'FontSize',12,...
        'Position',[0.25 0.92 0.3 0.03],...
        'String',{'1','2','3','4','5'},...
        'Callback',@popupmenu_ngauss_callback);
    handles.ngauss_text = uicontrol('Style','text',...
        'Units','normalized',...
        'Position',[0.025,0.92,0.225,0.03],...
        'String','# Species:',...
        'Tag','ngauss_text',...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'HorizontalAlignment','left',...
        'Parent',handles.tab_fit_table);
    %%% Bayesian Tab
    handles.bayesian_settings_panel = uibuttongroup(...
        'BackgroundColor',UserValues.Look.Back,...
        'Parent',handles.tab_bayesian,...
        'Units','normalized',...
        'Position',[0 0.85 1 0.15],...
        'Tag','bayesian_settings_panel');
    handles.bayesian_plot_panel = uibuttongroup(...
        'BackgroundColor',UserValues.Look.Back,...
        'Parent',handles.tab_bayesian,...
        'Units','normalized',...
        'Position',[0 0 1 0.85],...
        'Tag','bayesian_plot_panel');

    handles.draw_samples_button = uicontrol('Style','pushbutton',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.02 0.70 0.2 0.2],...
        'String','Draw Samples',...
        'Tag','draw_samples_button',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Callback',@mcmc_draw_samples);
    handles.save_mcmc_button = uicontrol('Style','pushbutton',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.4 0.70 0.2 0.2],...
        'String','Save samples',...
        'Tag','save_mcmc_button',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Callback',@MCMC_summary);
    
    handles.mcmc_append = uicontrol('Style','checkbox',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.23 0.70 0.15 0.2],...
        'String','Append samples',...
        'Tag','mcmc_append',...
        'Value',0,...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore);
    
    handles.n_samples_edit = uicontrol('Style','edit',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.22 0.45 0.125 0.2],...
        'String',num2str(UserValues.tcPDA.mcmc_samples),...
        'Callback',@update_corrections,...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','n_samples_button');
    
     handles.n_samples_text = uicontrol('Style','text',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.02 0.45 0.2 0.2],...
        'String','Number of samples:',...
        'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'FontSize',12,...
        'Tag','n_samples_text');
    
    handles.mcmc_spacing_edit = uicontrol('Style','edit',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.22 0.25 0.125 0.2],...
        'String',num2str(UserValues.tcPDA.mcmc_spacing),...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Callback',@update_corrections,...
        'Tag','mcmc_spacing_edit');
    
     handles.mcmc_spacing_text = uicontrol('Style','text',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.02 0.25 0.2 0.2],...
        'String','Spacing between samples:',...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','mcmc_spacing_text');
    
    handles.mcmc_method_text = uicontrol('Style','text',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.02 0.05 0.2 0.2],...
        'String','Sampling method:',...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','n_samples_text');
    
    handles.mcmc_method = uicontrol('Style','popupmenu',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.22 0.05 0.125 0.2],...
        'String',{'MH','MHWG'},...
        'Value',1,...
        'FontSize',12,...
        'Tag','mcmc_method');
    
    handles.sigma_A_edit = uicontrol('Style','edit',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.85 0.70 0.125 0.2],...
        'String',num2str(UserValues.tcPDA.mcmc_wA),...
        'Callback',@update_corrections,...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','sigma_A_edit');
    
     handles.sigma_A_text = uicontrol('Style','text',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.65 0.7 0.2 0.2],...
        'String','Sampling width for Amplitudes:',...
        'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'FontSize',12,...
         'HorizontalAlignment','left',...
        'Tag','sigma_A_text');
    
    handles.sigma_R_edit = uicontrol('Style','edit',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Position',[0.85 0.45 0.125 0.2],...
        'String',num2str(UserValues.tcPDA.mcmc_wR),...
        'Callback',@update_corrections,...
        'Tag','sigma_R_edit');
    
     handles.sigma_R_text = uicontrol('Style','text',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Position',[0.65 0.45 0.2 0.2],...
        'String','Sampling width for Distances:',...
        'HorizontalAlignment','left',...
        'Tag','sigma_R_text');
    
    handles.sigma_s_edit = uicontrol('Style','edit',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'Position',[0.85 0.2 0.125 0.2],...
        'String',num2str(UserValues.tcPDA.mcmc_wS),...
        'Callback',@update_corrections,...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'FontSize',12,...
        'Tag','sigma_s_edit');
    
     handles.sigma_s_text = uicontrol('Style','text',...
        'Parent',handles.bayesian_settings_panel,...
        'Units','normalized',...
        'BackgroundColor',UserValues.Look.Back,...
         'ForegroundColor',UserValues.Look.Fore,...
         'HorizontalAlignment','left',...
         'FontSize',12,...
        'Position',[0.65 0.2 0.2 0.2],...
        'String','Sampling width for Widths:',...
        'Tag','sigma_s_text');
    
    handles.Brightness_Correction_Toggle = uicontrol('Style','checkbox',...
        'Units','normalized',...
        'Position',[0.1,0.85,0.5,0.04],...
        'String','Use Brightness Correction',...
        'Tag','Brightness_Correction_Toggle',...
        'Parent',handles.tab_corrections,...
        'FontSize',12,...
        'BackgroundColor',UserValues.Look.Back,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Enable','off',...
        'Visible','off',...
        'Callback',[]);
    
   %%% 1d pda data tab
   handles.panel_2cPDAData = uibuttongroup(...
        'BackgroundColor',UserValues.Look.Back,...
        'Parent',handles.tab_PDAData,...
        'Units','normalized',...
        'Position',[0 0 1 1],...
        'Tag','panel_2cPDAData');
    
   handles.add_2cPDAData = uicontrol('Style','pushbutton',...
        'Parent',handles.panel_2cPDAData,...
        'Units','normalized',...
        'Position',[0.05 0.9 0.25 0.05],...
        'String','Load 2C PDA data',...
        'Tag','add_2cPDAData',...
        'BackgroundColor',UserValues.Look.Control,...
        'ForegroundColor',UserValues.Look.Fore,...
        'Callback',@add_2cPDAData);
    
    cnames = {'Use','File','Dist','<html>&gamma;</html>','ct','de','BG don','BG acc','timebin','Del'};
    cformat = {'logical','char',{'GR','BG','BR'},'numeric','numeric','numeric','numeric','numeric','numeric','logical'};
    cedit = [true,false,true,true,true,true,true,true,false,true];
    data = {true,'test','GR',1,0,0,0,0,1,false};
    cwidth = {40,'auto',60,40,40,40,50,50,50,40};
    handles.table_2cPDAData = uitable(...
        'Parent',handles.panel_2cPDAData,...
        'Units','normalized',...
        'Position',[0 0 1 0.8],...
        'RowName',[],...
        'ColumnName',cnames,...
        'ColumnEditable',cedit,...
        'ColumnFormat',cformat,...
        'CellEditCallback',@table_2cPDAData_callback,...
        'ColumnWidth',cwidth,...
        'Data',data);
        
    %%% store guidata
    guidata(handles.Figure,handles);
    
    %set table values
    popupmenu_ngauss_callback(handles.popupmenu_ngauss,0);

    %% Mac upscaling of Font Sizes
    if ismac
        scale_factor = 1.2;
        fields = fieldnames(handles); %%% loop through h structure
        for i = 1:numel(fields)
            if ~isa(handles.(fields{i}),'numeric')
                if isprop(handles.(fields{i}),'FontSize')
                    handles.(fields{i}).FontSize = (handles.(fields{i}).FontSize)*scale_factor;
                end
                if isprop(handles.(fields{i}),'Style')
                    if strcmp(handles.(fields{i}).Style,'popupmenu')
                        handles.(fields{i}).BackgroundColor = [1 1 1];
                        handles.(fields{i}).ForegroundColor = [0 0 0];
                    end
                end
            end
        end   
    end
else
    figure(h);
end

function close_tcPDA(obj,~)
global tcPDAstruct
clearvars -global tcPDAstruct
delete(obj);

function SetCorrectionTable(handles)

corrections = {0;0;0;0;0;0;1;1;0;0;0;0;0;50;50;50};
set(handles.corrections_table,'Data',corrections);

function update_corrections(hObject,eventdata)
global UserValues tcPDAstruct
handles = guidata(hObject);
switch hObject
    case handles.corrections_table
        corrections = get(handles.corrections_table,'data');
        %update values in User Values structure
        [tcPDAstruct.corrections.ct_gr, tcPDAstruct.corrections.ct_bg, tcPDAstruct.corrections.ct_br,...
            tcPDAstruct.corrections.de_gr, tcPDAstruct.corrections.de_bg, tcPDAstruct.corrections.de_br,...
            tcPDAstruct.corrections.gamma_gr, tcPDAstruct.corrections.gamma_br,...
            tcPDAstruct.corrections.BG_bb, tcPDAstruct.corrections.BG_bg, tcPDAstruct.corrections.BG_br,...
            tcPDAstruct.corrections.BG_gg, tcPDAstruct.corrections.BG_gr,...
            tcPDAstruct.corrections.R0_gr, tcPDAstruct.corrections.R0_bg, tcPDAstruct.corrections.R0_br] = deal(corrections{:});

        UserValues.tcPDA.corrections = tcPDAstruct.corrections;
    case handles.sampling_edit
        UserValues.tcPDA.sampling = str2double(get(handles.sampling_edit,'String'));
    case handles.nbins_edit
        UserValues.tcPDA.nbins = str2double(get(handles.nbins_edit,'String'));
        calculate_histograms();
        PlotData(handles);
        view_curve(handles);
    case handles.checkbox_stochasticlabeling
        reset_plot([],[],handles);
    case handles.edit_stochasticlabeling
        if isnan(str2double(handles.edit_stochasticlabeling.String))
            handles.edit_stochasticlabeling.String = num2str(UserValues.tcPDA.stochastic_labeling_fraction);
        else
            UserValues.tcPDA.stochastic_labeling_fraction = str2double(handles.edit_stochasticlabeling.String);
        end     
    case handles.checkbox_stochasticlabeling
        reset_plot([],[],handles);
        UserValues.tcPDA.use_stochastic_labeling = handles.checkbox_stochasticlabeling.Value;
    case handles.MLE_checkbox
        UserValues.tcPDA.use_MLE = handles.MLE_checkbox.Value;
    case handles.sigma_A_edit
        if isnan(str2double(handles.sigma_A_edit.String))
            handles.sigma_A_edit.String = num2str(UserValues.tcPDA.mcmc_wA);
        else
            UserValues.tcPDA.mcmc_wA = str2double(handles.sigma_A_edit.String);
        end   
    case handles.sigma_R_edit
        if isnan(str2double(handles.sigma_R_edit.String))
            handles.sigma_R_edit.String = num2str(UserValues.tcPDA.mcmc_wR);
        else
            UserValues.tcPDA.mcmc_wR = str2double(handles.sigma_R_edit.String);
        end   
    case handles.sigma_s_edit
        if isnan(str2double(handles.sigma_s_edit.String))
            handles.sigma_s_edit.String = num2str(UserValues.tcPDA.mcmc_wS);
        else
            UserValues.tcPDA.mcmc_wS = str2double(handles.sigma_s_edit.String);
        end
    case handles.n_samples_edit
        if isnan(str2double(handles.n_samples_edit.String))
            handles.n_samples_edit.String = num2str(UserValues.tcPDA.mcmc_samples);
        else
            UserValues.tcPDA.mcmc_samples = str2double(handles.n_samples_edit.String);
        end
    case handles.mcmc_spacing_edit
        if isnan(str2double(handles.mcmc_spacing_edit.String))
            handles.mcmc_spacing_edit.String = num2str(UserValues.tcPDA.mcmc_spacing);
        else
            UserValues.tcPDA.mcmc_spacing = str2double(handles.mcmc_spacing_edit.String);
        end
        MCMC_summary(handles.mcmc_spacing_edit,[]);
end
LSUserValues(1);

function pushbutton_fit(hObject,eventdata)
handles = guidata(hObject);
fit_tcPDA(handles)

function calculate_histograms()
global tcPDAstruct UserValues
nbins = UserValues.tcPDA.nbins;

tcPDAstruct.H_meas = histcn([tcPDAstruct.EBG,tcPDAstruct.EBR,tcPDAstruct.EGR],linspace(0,1,nbins+1),linspace(0,1,nbins+1),linspace(0,1,nbins+1));
tcPDAstruct.H_meas(:,:,end-1) = tcPDAstruct.H_meas(:,:,end-1) + tcPDAstruct.H_meas(:,:,end);
tcPDAstruct.H_meas(:,end-1,:) = tcPDAstruct.H_meas(:,end-1,:) + tcPDAstruct.H_meas(:,end,:);
tcPDAstruct.H_meas(end-1,:,:) = tcPDAstruct.H_meas(end-1,:,:) + tcPDAstruct.H_meas(end,:,:);
tcPDAstruct.H_meas = tcPDAstruct.H_meas(1:nbins,1:nbins,1:nbins);

tcPDAstruct.H_meas_gr = squeeze(sum(sum(tcPDAstruct.H_meas,1),2));
tcPDAstruct.H_meas_2d = sum(tcPDAstruct.H_meas,3);
tcPDAstruct.x_axis = linspace(0,1,nbins+1) + 1/2/nbins;%%% xaxis for 2d plots (centered on bins)
tcPDAstruct.x_axis(end) = []; %%% remove last elements since it is outside plot
tcPDAstruct.x_axis_bar = tcPDAstruct.x_axis; %%% xaxis for bar plot
tcPDAstruct.x_axis_stair = linspace(0,1,nbins+1); %%% xaxis for stair plot

function load_data(hObject,~)
global tcPDAstruct UserValues
LSUserValues(0);
handles = guidata(hObject);
[FileName, PathName, FilterIndex] = uigetfile({'*.tcpda','MATLAB based tcPDA file from PAM';'*.txt','Text-based tcPDA file'}, 'Select *.tcpda file for analysis', UserValues.tcPDA.PathName, 'MultiSelect', 'off');

if ~isequal(FileName,0)
    UserValues.tcPDA.PathName = PathName;
    UserValues.tcPDA.FileName = FileName;
else
    return;
end
LSUserValues(1);
tcPDAstruct = [];%clearvars -global tcPDAstruct

switch FilterIndex
    case 1
        load('-mat',fullfile(PathName,FileName)); %%% overwrites existing tcPDAstruct
    case 2
        load_from_txt(fullfile(PathName,FileName));
end

tcPDAstruct.FullFileName = fullfile(PathName,FileName);
handles.Figure.Name = ['tcPDA - ' FileName];

%initialize values
if ~isfield(tcPDAstruct,'sampling')
    tcPDAstruct.sampling = UserValues.tcPDA.sampling;
end
if ~isfield(tcPDAstruct,'use_stochasticlabeling')
    tcPDAstruct.use_stochasticlabeling = handles.checkbox_stochasticlabeling.Value;
end
if ~isfield(tcPDAstruct,'fraction_stochasticlabeling')
    tcPDAstruct.fraction_stochasticlabeling = str2double(handles.edit_stochasticlabeling.String);
end
%if ~isfield(tcPDAstruct,'MLE')
%    tcPDAstruct.MLE = 0;
%end
if ~isfield(tcPDAstruct,'N_min')
    tcPDAstruct.N_min = 0;
end
if ~isfield(tcPDAstruct,'N_max')
    tcPDAstruct.N_max = Inf;
end
if ~isfield(tcPDAstruct,'n_gauss')
    tcPDAstruct.n_gauss = 1;
end
if ~isfield(tcPDAstruct,'nbins')
    tcPDAstruct.nbins = 50;
end
%%% set gui values
handles.sampling_edit.String = num2str(tcPDAstruct.sampling);
handles.checkbox_stochasticlabeling.Value = tcPDAstruct.use_stochasticlabeling;
handles.edit_stochasticlabeling.String = num2str(tcPDAstruct.fraction_stochasticlabeling);
%handles.MLE_checkbox.Value = tcPDAstruct.MLE;
handles.min_n_edit.String = num2str(tcPDAstruct.N_min);
handles.max_n_edit.String = num2str(tcPDAstruct.N_max);
handles.popupmenu_ngauss.Value = tcPDAstruct.n_gauss;
handles.nbins_edit.String = num2str(tcPDAstruct.nbins);

if ~isfield(tcPDAstruct,'fitdata')
    value_dummy = [1,50,2,50,2,50,2,0,0,0]';
    fixed_dummy = [false,false,false,false,false,false,false,true,true,true]';
    LB_dummy = [0,0,0,0,0,0,0,-Inf,-Inf,-Inf]';
    UB_dummy = [Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf]';
    for i = 1:5
        tcPDAstruct.fitdata.param{i} = value_dummy;
        tcPDAstruct.fitdata.fixed{i} = fixed_dummy;
        if i == 1
            tcPDAstruct.fitdata.fixed{i}(1) = true;
        end
        tcPDAstruct.fitdata.LB{i} = LB_dummy;
        tcPDAstruct.fitdata.UB{i} = UB_dummy;
        tcPDAstruct.fitdata.use_prior{i} = false(10,1);
        tcPDAstruct.fitdata.prior_center{i} = tcPDAstruct.fitdata.param{i};
        tcPDAstruct.fitdata.prior_sigma{i} = 0.1*tcPDAstruct.fitdata.param{i};
    end
else
    if ~isfield(tcPDAstruct.fitdata,'use_prior')
        for i = 1:5
            tcPDAstruct.fitdata.use_prior{i} = false(10,1);
            tcPDAstruct.fitdata.prior_center{i} = tcPDAstruct.fitdata.param{i};
            tcPDAstruct.fitdata.prior_sigma{i} = 0.1*tcPDAstruct.fitdata.param{i};
        end
    end
end
if isfield(tcPDAstruct,'corrections') %%% Update Corrections in GUI
    if isfield(tcPDAstruct.corrections,'BG_bb') %%% has been opened before in tcPDA since background was added up
        data = {tcPDAstruct.corrections.ct_gr, tcPDAstruct.corrections.ct_bg, tcPDAstruct.corrections.ct_br,...
            tcPDAstruct.corrections.de_gr, tcPDAstruct.corrections.de_bg, tcPDAstruct.corrections.de_br,...
            tcPDAstruct.corrections.gamma_gr, tcPDAstruct.corrections.gamma_br,...
            tcPDAstruct.corrections.BG_bb, tcPDAstruct.corrections.BG_bg, tcPDAstruct.corrections.BG_br,...
            tcPDAstruct.corrections.BG_gg, tcPDAstruct.corrections.BG_gr,...
            tcPDAstruct.corrections.R0_gr, tcPDAstruct.corrections.R0_bg, tcPDAstruct.corrections.R0_br}';
    else
        if isfield(tcPDAstruct,'background')
            tcPDAstruct.background.BG_bb = tcPDAstruct.background.Background_BBpar + tcPDAstruct.background.Background_BBperp;
            tcPDAstruct.background.BG_bg = tcPDAstruct.background.Background_BGpar + tcPDAstruct.background.Background_BGperp;
            tcPDAstruct.background.BG_br = tcPDAstruct.background.Background_BRpar + tcPDAstruct.background.Background_BRperp;
            tcPDAstruct.background.BG_gg = tcPDAstruct.background.Background_GGpar + tcPDAstruct.background.Background_GGperp;
            tcPDAstruct.background.BG_gr = tcPDAstruct.background.Background_GRpar + tcPDAstruct.background.Background_GRperp;
            data = {tcPDAstruct.corrections.CrossTalk_GR, tcPDAstruct.corrections.CrossTalk_BG, tcPDAstruct.corrections.CrossTalk_BR,...
                UserValues.tcPDA.corrections.de_gr, UserValues.tcPDA.corrections.de_bg, UserValues.tcPDA.corrections.de_br,...
                tcPDAstruct.corrections.Gamma_GR, tcPDAstruct.corrections.Gamma_BR,...
                tcPDAstruct.background.BG_bb, tcPDAstruct.background.BG_bg, tcPDAstruct.background.BG_br,...
                tcPDAstruct.background.BG_gg, tcPDAstruct.background.BG_gr,...
                tcPDAstruct.corrections.FoersterRadius, tcPDAstruct.corrections.FoersterRadiusBG, tcPDAstruct.corrections.FoersterRadiusBR}';
        else
            data = {tcPDAstruct.corrections.CrossTalk_GR, tcPDAstruct.corrections.CrossTalk_BG, tcPDAstruct.corrections.CrossTalk_BR,...
                UserValues.tcPDA.corrections.de_gr, UserValues.tcPDA.corrections.de_bg, UserValues.tcPDA.corrections.de_br,...
                tcPDAstruct.corrections.Gamma_GR, tcPDAstruct.corrections.Gamma_BR,...
                UserValues.tcPDA.corrections.BG_bb, UserValues.tcPDA.corrections.BG_bg, UserValues.tcPDA.corrections.BG_br,...
                UserValues.tcPDA.corrections.BG_gg, UserValues.tcPDA.corrections.BG_gr,...
                tcPDAstruct.corrections.FoersterRadius, tcPDAstruct.corrections.FoersterRadiusBG, tcPDAstruct.corrections.FoersterRadiusBR}';
        end
    end
    handles.corrections_table.Data = data;
    %%% Store in tcPDA variable names
    [tcPDAstruct.corrections.ct_gr, tcPDAstruct.corrections.ct_bg, tcPDAstruct.corrections.ct_br,...
        tcPDAstruct.corrections.de_gr, tcPDAstruct.corrections.de_bg, tcPDAstruct.corrections.de_br,...
        tcPDAstruct.corrections.gamma_gr, tcPDAstruct.corrections.gamma_br,...
        tcPDAstruct.corrections.BG_bb, tcPDAstruct.corrections.BG_bg, tcPDAstruct.corrections.BG_br,...
        tcPDAstruct.corrections.BG_gg, tcPDAstruct.corrections.BG_gr,...
        tcPDAstruct.corrections.R0_gr, tcPDAstruct.corrections.R0_bg, tcPDAstruct.corrections.R0_br] = deal(data{:});
    %%% remove unneeded variable fields
    fields = fieldnames(tcPDAstruct.corrections);
    fields_to_keep = {'ct_gr','ct_bg','ct_br','de_gr','de_bg','de_br','gamma_gr','gamma_br','BG_bb','BG_bg','BG_br','BG_gg','BG_gr','R0_gr','R0_bg','R0_br'}';
    fields_to_remove = fields(~cell2mat(cellfun(@(x) any(strcmp(x,fields_to_keep)),fields,'UniformOutput',false)));
    tcPDAstruct.corrections = rmfield(tcPDAstruct.corrections,fields_to_remove);
end

Cut_Data([],[]);
calculate_histograms();
popupmenu_ngauss_callback(handles.popupmenu_ngauss,[])
PlotData(handles);
reset_plot([],[],handles);
view_curve(handles);

function load_from_txt(filename)
global tcPDAstruct
fid = fopen(filename);
tline = fgetl(fid);
i=1;
timebin = [];
data_start = [];
while ischar(tline)
    tline = fgetl(fid);
    i = i + 1;
    if strcmp(tline(1:3),'NBB')
        data_start = i;
        break;
    else
        % try to find the timebin
        if strfind(tline,'timebin')
            timebin = sscanf(tline,'timebin = %d');
        end
    end
end
fclose(fid);
if isempty(timebin)
    disp('No timebin found in file. Specify in header in units of milliseconds as "timebin = 1".');
end
if isempty(data_start)
    disp('No data found. Data must be preceded by a line with content "NBB, NBG, NBR, NGG, NGR".');
end

% read the data
data_matrix = dlmread(filename,',',data_start,0);

% construct tcPDAstruct variable
tcPDAstruct = struct;
tcPDAstruct.NBB = data_matrix(:,1);
tcPDAstruct.NBG = data_matrix(:,2);
tcPDAstruct.NBR = data_matrix(:,3);
tcPDAstruct.NGG = data_matrix(:,4);
tcPDAstruct.NGR = data_matrix(:,5);
tcPDAstruct.timebin = timebin;
tcPDAstruct.duration = ones(size(data_matrix,1),1).*timebin;

function [valid] = Cut_Data(Obj,~)
global tcPDAstruct
if ~isfield(tcPDAstruct,'NBB')
    return;
end
handles = guidata(findobj('Tag','tcPDA'));
N_total = tcPDAstruct.NBB+tcPDAstruct.NBG+tcPDAstruct.NBR+tcPDAstruct.NGG+tcPDAstruct.NGR;
N_min = str2double(handles.min_n_edit.String);
N_max = str2double(handles.max_n_edit.String);
valid = (N_total >= N_min) & (N_total <= N_max);

if N_max > max(N_total)
    handles.max_n_edit.String = num2str(max(N_total));
end
if N_min < 0
    handles.min_n_edit.String = num2str(0);
end
tcPDAstruct.N_min = N_min;
tcPDAstruct.N_max = N_max;

tcPDAstruct.BSD_GX = tcPDAstruct.NGG(valid)+tcPDAstruct.NGR(valid);
tcPDAstruct.BSD_BX = tcPDAstruct.NBB(valid)+tcPDAstruct.NBG(valid)+tcPDAstruct.NBR(valid);
tcPDAstruct.EGR = tcPDAstruct.NGR(valid)./tcPDAstruct.BSD_GX;
tcPDAstruct.EBG = tcPDAstruct.NBG(valid)./tcPDAstruct.BSD_BX;
tcPDAstruct.EBR = tcPDAstruct.NBR(valid)./tcPDAstruct.BSD_BX;

%disp(sprintf('N = %d',sum(valid)));
if ~isempty(Obj) % Called from gui
    calculate_histograms();
    
    %%% Update Data
    PlotData(handles);
    
    view_curve(handles);
end

function UpdateAxesLimits(handles)

handles.axes_1d.YLim(2) = 1.05*max([max(handles.plots.handle_1d_data.YData),max(handles.plots.handle_1d_fit.YData)]);
handles.axes_2d.ZLim(2) = 1.05*max([max(handles.plots.handle_2d_data.ZData(:)),max(handles.plots.handle_2d_fit.ZData(:))]);
ax = handle(handles.axes_3d(1));
ax.ZLim(2) = 1.05*max([max(handles.plots.handle_3d_data_bg_br.ZData(:)),max(handles.plots.handle_3d_fit_bg_br.ZData(:))]);
ax = handle(handles.axes_3d(2));
ax.ZLim(2) = 1.05*max([max(handles.plots.handle_3d_data_bg_gr.ZData(:)),max(handles.plots.handle_3d_fit_bg_gr.ZData(:))]);
ax = handle(handles.axes_3d(3));
ax.ZLim(2) = 1.05*max([max(handles.plots.handle_3d_data_br_gr.ZData(:)),max(handles.plots.handle_3d_fit_br_gr.ZData(:))]);
ax = handle(handles.axes_3d(4));
ax.YLim(2) = 1.05*max([max(handles.plots.handle_3d_data_bg.YData),max(handles.plots.handle_3d_fit_bg.YData)]);
ax = handle(handles.axes_3d(5));
ax.YLim(2) = 1.05*max([max(handles.plots.handle_3d_data_br.YData),max(handles.plots.handle_3d_fit_br.YData)]);
ax = handle(handles.axes_3d(6));
ax.YLim(2) = 1.05*max([max(handles.plots.handle_3d_data_gr.YData),max(handles.plots.handle_3d_fit_gr.YData)]);

function PlotData(handles)
global tcPDAstruct

%Update 1D GR
handles.plots.handle_1d_data.XData =tcPDAstruct.x_axis_bar;
handles.plots.handle_1d_data.YData =tcPDAstruct.H_meas_gr;
handles.plots.handle_1d_dev.XData = tcPDAstruct.x_axis_stair;
handles.plots.handle_1d_dev.YData =zeros(size(tcPDAstruct.x_axis));
%%% hide fit results
handles.plot.handle_1d_fit.Visible = 'off';
set(handles.plots.handles_H_res_1d_individual,'Visible','off');
%Update 2D plot
handles.plots.handle_2d_data.XData = tcPDAstruct.x_axis;
handles.plots.handle_2d_data.YData = tcPDAstruct.x_axis;
handles.plots.handle_2d_data.ZData = tcPDAstruct.H_meas_2d;
handles.plots.handle_2d_dev.XData = tcPDAstruct.x_axis;
handles.plots.handle_2d_dev.YData = tcPDAstruct.x_axis;
handles.plots.handle_2d_dev.ZData = zeros(numel(tcPDAstruct.x_axis));

%Update 3D plot
plot4d(handles);
UpdateAxesLimits(handles);

function plot4d(handles)
%plots three 2D and three 1D projections of 3 dimensional data array
global tcPDAstruct
input = tcPDAstruct.H_meas;
x_axis = tcPDAstruct.x_axis;
x_axis_bar = tcPDAstruct.x_axis_bar;

handles.plots.handle_3d_data_bg_br.XData =  x_axis;
handles.plots.handle_3d_data_bg_br.YData =  x_axis;
handles.plots.handle_3d_data_bg_br.ZData =  squeeze(sum(input,3));

handles.plots.handle_3d_data_bg_gr.XData = x_axis;
handles.plots.handle_3d_data_bg_gr.YData = x_axis;
handles.plots.handle_3d_data_bg_gr.ZData = squeeze(sum(input,2));

handles.plots.handle_3d_data_br_gr.XData = x_axis;
handles.plots.handle_3d_data_br_gr.YData = x_axis;
handles.plots.handle_3d_data_br_gr.ZData = squeeze(sum(input,1));

handles.plots.handle_3d_data_bg.XData = x_axis_bar;
handles.plots.handle_3d_data_bg.YData = squeeze(sum(sum(input,2),3));

handles.plots.handle_3d_data_br.XData = x_axis_bar;
handles.plots.handle_3d_data_br.YData = squeeze(sum(sum(input,1),3));

handles.plots.handle_3d_data_gr.XData = x_axis_bar;
handles.plots.handle_3d_data_gr.YData = squeeze(sum(sum(input,1),2));

% x_axis = tcPDAstruct.x_axis;
% fontsize_label = 20;
% fontsize_ticks = 15;
% Alpha = 0.6;
% 
% axes(ha(1));
% tcPDAstruct.plots.handle_3d_data_bg_br =  surf(x_axis,x_axis,squeeze(sum(input,3)),'EdgeColor','none','FaceAlpha',Alpha);
% xlim([0 1]);
% ylim([0 1]);
% zlim([0 max([max(max(squeeze(sum(input,3))))])]);
% xlabel('P_{BR}','FontSize',fontsize_label);
% ylabel('P_{BG}','FontSize',fontsize_label);
% set(gca,'Color',[0.5 0.5 0.5]);
% set(gca,'FontSize',fontsize_ticks);
% 
% 
% axes(ha(2));
% tcPDAstruct.plots.handle_3d_data_bg_gr = surf(x_axis,x_axis,squeeze(sum(input,2)),'EdgeColor','none','FaceAlpha',Alpha);
% xlim([0 1]);
% ylim([0 1]);
% zlim([0 max([max(max(squeeze(sum(input,2))))])]);
% xlabel('P_{GR}','FontSize',fontsize_label);
% ylabel('P_{BG}','FontSize',fontsize_label);
% set(gca,'Color',[0.5 0.5 0.5]);
% set(gca,'FontSize',fontsize_ticks);
% 
% axes(ha(3));
% tcPDAstruct.plots.handle_3d_data_br_gr = surf(x_axis,x_axis,squeeze(sum(input,1)),'EdgeColor','none','FaceAlpha',Alpha);
% xlim([0 1]);
% ylim([0 1]);
% zlim([0 max([max(max(squeeze(sum(input,1))))])]);
% xlabel('P_{GR}','FontSize',fontsize_label);
% ylabel('P_{BR}','FontSize',fontsize_label);
% set(gca,'Color',[0.5 0.5 0.5]);
% set(gca,'FontSize',fontsize_ticks);
%    
% axes(ha(4));
% tcPDAstruct.plots.handle_3d_data_bg = bar(x_axis,squeeze(sum(sum(input,2),3)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5]);
% xlim([0 1]);
% xlabel('P_{BG}','FontSize',fontsize_label);
% set(gca,'FontSize',fontsize_ticks);
% 
% axes(ha(5));
% tcPDAstruct.plots.handle_3d_data_br = bar(x_axis,squeeze(sum(sum(input,1),3)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5]);
% xlim([0 1]);
% xlabel('P_{BR}','FontSize',fontsize_label);
% set(gca,'FontSize',fontsize_ticks);
%  
% axes(ha(6));
% tcPDAstruct.plots.handle_3d_data_gr = bar(x_axis,squeeze(sum(sum(input,1),2)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5]);
% xlim([0 1]);
% xlabel('P_{GR}','FontSize',fontsize_label);
% set(gca,'FontSize',fontsize_ticks);    
    
function fit_tcPDA(handles)
global tcPDAstruct
if ~isfield(tcPDAstruct,'NBB')
    return;
end
handles.BIC_text.String = '';
%%% Open Parallel Pool
StartParPool();

tcPDAstruct.sampling = str2double(get(handles.sampling_edit,'String'));
tcPDAstruct.BrightnessCorrection = handles.Brightness_Correction_Toggle.Value;
tcPDAstruct.use_stochasticlabeling = handles.checkbox_stochasticlabeling.Value;
tcPDAstruct.fraction_stochasticlabeling = str2double(handles.edit_stochasticlabeling.String);
if tcPDAstruct.BrightnessCorrection
    %%% Prepare PofN for Brightness Reference
    if ~isfield(tcPDAstruct,'BrightnessReference')
        m = messagebox('No Brightness Reference found...');
        pause(1);
        delete(m);
        return;
    end
    tcPDAstruct.BrightnessReference.PNB = histcounts(tcPDAstruct.BrightnessReference.NB,1:(max(tcPDAstruct.BrightnessReference.NB)+1));
    tcPDAstruct.BrightnessReference.PNG = histcounts(tcPDAstruct.BrightnessReference.NG,1:(max(tcPDAstruct.BrightnessReference.NG)+1));
end
%read correction table
corrections = get(handles.corrections_table,'data');
[tcPDAstruct.corrections.ct_gr, tcPDAstruct.corrections.ct_bg, tcPDAstruct.corrections.ct_br,...
    tcPDAstruct.corrections.de_gr, tcPDAstruct.corrections.de_bg, tcPDAstruct.corrections.de_br,...
    tcPDAstruct.corrections.gamma_gr, tcPDAstruct.corrections.gamma_br,...
    tcPDAstruct.corrections.BG_bb, tcPDAstruct.corrections.BG_bg, tcPDAstruct.corrections.BG_br,...
    tcPDAstruct.corrections.BG_gg, tcPDAstruct.corrections.BG_gr,...
    tcPDAstruct.corrections.R0_gr, tcPDAstruct.corrections.R0_bg, tcPDAstruct.corrections.R0_br] = deal(corrections{:});

%read initial fit values
fit_data = get(handles.fit_table,'data');
n_gauss = get(handles.popupmenu_ngauss,'value');
for i = 1:n_gauss%number of species
   tcPDAstruct.fitdata.param{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,2));
   tcPDAstruct.fitdata.fixed{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,3));
   tcPDAstruct.fitdata.LB{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,4));
   tcPDAstruct.fitdata.UB{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,5));
   tcPDAstruct.fitdata.use_prior{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,6));
   tcPDAstruct.fitdata.prior_center{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,7));
   tcPDAstruct.fitdata.prior_sigma{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,8));
end
%get the selected tab
selected_tab = handles.tabgroup.SelectedTab;
tcPDAstruct.selected_tab = selected_tab;
tcPDAstruct.MLE = get(handles.MLE_checkbox,'Value');
[tcPDAstruct.valid] = Cut_Data([],[]);

switch (selected_tab)
    case handles.tab_1d %only a 1D fit
        %create input data
        fitpar = [];
        LB = [];
        UB = [];
        fixed = [];
        for i = 1:n_gauss
            fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(1:3)];
            LB = [LB; tcPDAstruct.fitdata.LB{i}(1:3)];
            UB = [UB; tcPDAstruct.fitdata.UB{i}(1:3)];
            fixed = [fixed; tcPDAstruct.fitdata.fixed{i}(1:3)];
        end
        %fix by simply setting the same upper and lower border
        LB(fixed == 1) = fitpar(fixed == 1);
        UB(fixed == 1) = fitpar(fixed == 1);
        
        %patternsearch
%         if sum(fixed) == 0 %nothing is fixed
%             A = [];
%             b = [];
%         elseif sum(fixed) > 0
%             A = zeros(numel(fixed)); %NxN matrix with zeros
%             b = zeros(numel(fixed),1);
%             for i = 1:numel(fixed)
%                 if fixed(i) == 1 %set diagonal to 1 and b to value --> 1*x = b
%                     A(i,i) = 1;
%                     b(i) = fitpar(i);
%                 end
%             end
%         end
%         
%         opts = psoptimset('Cache','on','Display','iter','PlotFcns',@psplotchange);%,'UseParallel','always');
%         fitpar = patternsearch(@(x) determine_chi2_1C_mc_cor(x), fitpar, [],[],A,b,LB,UB,[],opts);
        plotfun = @(optimvalues,flag,state,varargin) UpdateFitProgress(optimvalues,flag,state,varargin,@plot_after_fit,@UpdateFitTable);
        fitopts = optimset('MaxFunEvals', 500,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',plotfun);%@optimplotfval_tcPDA);
        fitpar = fminsearchbnd(@(x) determine_chi2_1C_mc_cor(x), fitpar, LB, UB, fitopts);
        
        handles.text_chi2.String = sprintf('Chi2 = %.2f',tcPDAstruct.plots.chi2);
        %Update fitpar in tcPDAstruct
        for i = 1:n_gauss
            tcPDAstruct.fitdata.param{i}(1:3) = fitpar(((i-1)*3+1):(3*i));
        end
        %update table
        UpdateFitTable(handles);
        %plot_E_dist(handles)
    case handles.tab_2d %2d fit
        %create input data
        fitpar = [];
        LB = [];
        UB = [];
        fixed = [];
        for i = 1:n_gauss
            fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(1:7)];
            LB = [LB; tcPDAstruct.fitdata.LB{i}(1:7)];
            UB = [UB; tcPDAstruct.fitdata.UB{i}(1:7)];
            fixed = [fixed; tcPDAstruct.fitdata.fixed{i}(1:7)];
        end
        %fix by simply setting the same upper and lower border
        LB(fixed == 1) = fitpar(fixed == 1);
        UB(fixed == 1) = fitpar(fixed == 1);
        
        %patternsearch
        if sum(fixed) == 0 %nothing is fixed
            A = [];
            b = [];
        elseif sum(fixed) > 0
            A = zeros(numel(fixed)); %NxN matrix with zeros
            b = zeros(numel(fixed),1);
            for i = 1:numel(fixed)
                if fixed(i) == 1 %set diagonal to 1 and b to value --> 1*x = b
                    A(i,i) = 1;
                    b(i) = fitpar(i);
                end
            end
        end
        
        %opts = psoptimset('Cache','on','Display','iter','PlotFcns',@psplotchange);%,'UseParallel','always');
        %fitpar = patternsearch(@(x) determine_chi2_2C_mc_dist_cor(x), fitpar, [],[],A,b,LB,UB,[],opts);
        plotfun = @(optimvalues,flag,state,varargin) UpdateFitProgress(optimvalues,flag,state,varargin,@plot_after_fit,@UpdateFitTable);
        fitopts = optimset('MaxFunEvals', 500,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',plotfun);%@optimplotfval_tcPDA);
        fitpar = fminsearchbnd(@(x) determine_chi2_2C_mc_dist_cor(x), fitpar, LB, UB, fitopts);
        
        %Update fitpar in tcPDAstruct
        for i = 1:n_gauss
            tcPDAstruct.fitdata.param{i}(1:7) = fitpar(((i-1)*7+1):(7*i));
        end
        %update table
        UpdateFitTable(handles); 
    case handles.tab_3d %full 3d fit
        %create input data
        fitpar = [];
        LB = [];
        UB = [];
        fixed = [];
        
        %covariance matrix read in as well!
        for i = 1:n_gauss
            fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(:)];
            LB = [LB; tcPDAstruct.fitdata.LB{i}(:)];
            UB = [UB; tcPDAstruct.fitdata.UB{i}(:)];
            fixed = [fixed; tcPDAstruct.fitdata.fixed{i}(:)];
        end
        
        %fix covariance matrix before fitting
        fitpar = fix_covariance_matrix_fitpar(fitpar);
        %fix by simply setting the same upper and lower border
        LB(fixed == 1) = fitpar(fixed == 1);
        UB(fixed == 1) = fitpar(fixed == 1);
        
        %fitopts = optimset('MaxFunEvals', 1E6,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',@optimplotfval_tcPDA);
        %fitpar = fminsearchbnd(@(x) determine_chi2_mc_dist_3d_cor(x), fitpar, LB, UB, fitopts);
        if sum(fixed) == 0 %nothing is fixed
            A = [];
            b = [];
        elseif sum(fixed) > 0
            A = zeros(numel(fixed)); %NxN matrix with zeros
            b = zeros(numel(fixed),1);
            for i = 1:numel(fixed)
                if fixed(i) == 1 %set diagonal to 1 and b to value --> 1*x = b
                    A(i,i) = 1;
                    b(i) = fitpar(i);
                end
            end
        end
        
        %%% Apply cuts
        [valid] = Cut_Data([],[]);
        tcPDAstruct.fbb = tcPDAstruct.NBB(valid);
        tcPDAstruct.fbg = tcPDAstruct.NBG(valid);
        tcPDAstruct.fbr = tcPDAstruct.NBR(valid);
        tcPDAstruct.fgg = tcPDAstruct.NGG(valid);
        tcPDAstruct.fgr = tcPDAstruct.NGR(valid);
        tcPDAstruct.valid = valid;
        
        plotfun = @(x,optimvalues,state,varargin) UpdateFitProgress(x,optimvalues,state,varargin,@plot_after_fit,@UpdateFitTable);
        if get(handles.MLE_checkbox,'Value') == 0
            switch handles.FitMethod_popupmenu.String{handles.FitMethod_popupmenu.Value}
                case 'Pattern Search'
                    plotfun = @(optimvalues,flag) UpdateFitProgress(optimvalues,flag,[],[],@plot_after_fit,@UpdateFitTable);
                    opts = psoptimset('Cache','on','Display','iter','PlotFcns',plotfun);%@psplotchange);%,'UseParallel','always');
                    fitpar = patternsearch(@(x) determine_chi2_mc_dist_3d_cor(x), fitpar, [],[],A,b,LB,UB,[],opts);
                case 'Simplex'
                    fitopts = optimset('MaxFunEvals', 1E6,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',plotfun);%@optimplotfval_tcPDA);
                    fitpar = fminsearchbnd(@(x) determine_chi2_mc_dist_3d_cor(x), fitpar,LB,UB,fitopts);
                case 'Gradient-based'
                    fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter','PlotFcns',plotfun);%@optimplotfval_tcPDA);
                    fitpar = fmincon(@(x) determine_chi2_mc_dist_3d_cor(x), fitpar,[],[],A,b,LB,UB,[],fitopts);
            end
         else
            tcPDAstruct.grid = 0;
            calculate_background(); 
            %%% check if gpu is available (sometimes it locks up...)
            tcPDAstruct.GPU_locked = false;
            try 
                gpuDevice;
            catch
                disp('GPU locked up - Using CPU instead...');
                disp('Restart Matlab to fix.');
                tcPDAstruct.GPU_locked = true;
            end
            if (gpuDeviceCount==0) || tcPDAstruct.GPU_locked % Use CPU
                % Initialize Array of binomial and trinomial coefficients
                [tcPDAstruct.lib_b,tcPDAstruct.lib_t] = binomial_coefficient_library_mex(tcPDAstruct.fbb,tcPDAstruct.fbg,tcPDAstruct.fbr,tcPDAstruct.fgg,tcPDAstruct.fgr,...
                    tcPDAstruct.corrections.background.NBGbb,tcPDAstruct.corrections.background.NBGbg,tcPDAstruct.corrections.background.NBGbr,tcPDAstruct.corrections.background.NBGgg,tcPDAstruct.corrections.background.NBGgr);
            end
             
            %opts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter','PlotFcns',@optimplotfval,'FinDiffRelStep',0.1);
            %fitpar = fmincon(@(x) determine_MLE_mc_dist_3d_cor(x), fitpar, [],[],A,b,LB,UB,[],opts);
            switch handles.FitMethod_popupmenu.String{handles.FitMethod_popupmenu.Value}
                case 'Simplex'
                    fitopts = optimset('MaxFunEvals', 1E6,'Display','iter','TolFun',1E-6,'TolX',1E-3,'PlotFcns',plotfun);%@optimplotfval_tcPDA);
                    fitpar = fminsearchbnd(@(x) determine_MLE_mc_dist_3d_cor(x), fitpar,LB,UB,fitopts);
                case 'Pattern Search'
                    plotfun = @(optimvalues,flag) UpdateFitProgress(optimvalues,flag,[],[],@plot_after_fit,@UpdateFitTable);
                    opts = psoptimset('Cache','on','Display','iter','PlotFcns',plotfun);%,'UseParallel','always');
                    fitpar = patternsearch(@(x) determine_MLE_mc_dist_3d_cor(x), fitpar, [],[],A,b,LB,UB,[],opts);
                case 'Gradient-based'
                    fitopts = optimoptions('fmincon','MaxFunEvals',1E4,'Display','iter','FinDiffRelStep',0.1,'PlotFcns',plotfun);%@optimplotfval_tcPDA);
                    fitpar = fmincon(@(x) determine_MLE_mc_dist_3d_cor(x), fitpar,[],[],A,b,LB,UB,[],fitopts);
                case 'Gradient-based (global)'
                    opts = optimoptions(@fmincon,'Algorithm','interior-point','Display','iter','PlotFcns',plotfun);%@optimplotfvalPDA);
                    problem = createOptimProblem('fmincon','objective',@(x) determine_MLE_mc_dist_3d_cor(x),'x0',fitpar,'lb',LB,'ub',UB,'Aeq',A,'beq',b,'options',opts);
                    gs = GlobalSearch;
                    fitpar = run(gs,problem);
            end
            handles.BIC_text.String = sprintf('logL = %.4E  BIC = %.4E',tcPDAstruct.logL,tcPDAstruct.BIC);
        end
        %fix covariance matrix again
        fitpar = fix_covariance_matrix_fitpar(fitpar);
        
        %Update fitpar in tcPDAstruct
        for i = 1:n_gauss
            tcPDAstruct.fitdata.param{i} = fitpar(((i-1)*10+1):(10*i));
        end
        %update table
        UpdateFitTable(handles);
        %%% update BIC display
        
end

fitFig = findobj('Name','Optimization PlotFcns');
if isempty(fitFig)
    fitFig = findobj('Name','Pattern Search');
end
if ~isempty(fitFig)
    delete(fitFig);
end
handles.fit_pause_button.Enable = 'off';
handles.fit_cancel_button.Enable = 'off';

view_curve(handles);

function calculate_background()
global tcPDAstruct
if ~strcmp('burstwise',tcPDAstruct.timebin)
    %%% equal timebins, i.e. background correction possible
    %%% evaluate the background probabilities
    BGbb = poisspdf(0:1:max(tcPDAstruct.NBB),tcPDAstruct.corrections.BG_bb*tcPDAstruct.timebin);
    BGbg = poisspdf(0:1:max(tcPDAstruct.NBG),tcPDAstruct.corrections.BG_bg*tcPDAstruct.timebin);
    BGbr = poisspdf(0:1:max(tcPDAstruct.NBR),tcPDAstruct.corrections.BG_br*tcPDAstruct.timebin);
    BGgg = poisspdf(0:1:max(tcPDAstruct.NGG),tcPDAstruct.corrections.BG_gg*tcPDAstruct.timebin);
    BGgr = poisspdf(0:1:max(tcPDAstruct.NGR),tcPDAstruct.corrections.BG_gr*tcPDAstruct.timebin);
    method = 'cdf';
    switch method
        case 'pdf'
            %determine boundaries for background inclusion
            threshold = 1E-2;
            NBGbb = find(BGbb > threshold,1,'last');
            NBGbg = find(BGbg > threshold,1,'last');
            NBGbr = find(BGbr > threshold,1,'last');
            NBGgg = find(BGgg > threshold,1,'last');
            NBGgr = find(BGgr > threshold,1,'last');
            BGbb = BGbb(1:NBGbb);
            BGbg = BGbg(1:NBGbg);
            BGbr = BGbr(1:NBGbr);
            BGgg = BGgg(1:NBGgg);
            BGgr = BGgr(1:NBGgr);
            %BGbb(BGbb<1E-2) = [];
            %BGbg(BGbg<1E-2) = [];
            %BGbr(BGbr<1E-2) = [];
            %BGgg(BGgg<1E-2) = [];
            %BGgr(BGgr<1E-2) = [];
        case 'cdf'
            %%% evaluate the background probabilities
            CDF_BGbb = poisscdf(0:1:max(tcPDAstruct.NBB),tcPDAstruct.corrections.BG_bb*tcPDAstruct.timebin);
            CDF_BGbg = poisscdf(0:1:max(tcPDAstruct.NBG),tcPDAstruct.corrections.BG_bg*tcPDAstruct.timebin);
            CDF_BGbr = poisscdf(0:1:max(tcPDAstruct.NBR),tcPDAstruct.corrections.BG_br*tcPDAstruct.timebin);
            CDF_BGgg = poisscdf(0:1:max(tcPDAstruct.NGG),tcPDAstruct.corrections.BG_gg*tcPDAstruct.timebin);
            CDF_BGgr = poisscdf(0:1:max(tcPDAstruct.NGR),tcPDAstruct.corrections.BG_gr*tcPDAstruct.timebin);
            %determine boundaries for background inclusion
            threshold = 0.95;
            BGbb((find(CDF_BGbb>threshold,1,'first')+1):end) = [];
            BGbg((find(CDF_BGbg>threshold,1,'first')+1):end) = [];
            BGbr((find(CDF_BGbr>threshold,1,'first')+1):end) = [];
            BGgg((find(CDF_BGgg>threshold,1,'first')+1):end) = [];
            BGgr((find(CDF_BGgr>threshold,1,'first')+1):end) = [];
    end
    BGbb = BGbb./sum(BGbb);
    BGbg = BGbg./sum(BGbg);
    BGbr = BGbr./sum(BGbr);
    BGgg = BGgg./sum(BGgg);
    BGgr = BGgr./sum(BGgr);
    NBGbb = numel(BGbb)-1;
    NBGbg = numel(BGbg)-1;
    NBGbr = numel(BGbr)-1;
    NBGgg = numel(BGgg)-1;
    NBGgr = numel(BGgr)-1;
    %%% store in corrections structure
    tcPDAstruct.corrections.background.BGbb = BGbb;
    tcPDAstruct.corrections.background.BGbg = BGbg;
    tcPDAstruct.corrections.background.BGbr = BGbr;
    tcPDAstruct.corrections.background.BGgg = BGgg;
    tcPDAstruct.corrections.background.BGgr = BGgr;
    tcPDAstruct.corrections.background.NBGbb = NBGbb;
    tcPDAstruct.corrections.background.NBGbg = NBGbg;
    tcPDAstruct.corrections.background.NBGbr = NBGbr;
    tcPDAstruct.corrections.background.NBGgg = NBGgg;
    tcPDAstruct.corrections.background.NBGgr = NBGgr;
elseif strcmp('burstwise',tcPDAstruct.timebin)
    %%% Background inclusion only possible if seperate
    %%% Poissonian Distributions are evaluated for every burst
    %%% duration
    
    %%% evaluate up to the maximum to consider (i.e. the
    %%% global maximum number of counts in a channel)
    nBursts = numel(tcPDAstruct.NBB);
    method = 'pdf';
    switch method
        case 'pdf'
            BGbb = poisspdf(repmat(0:1:max(tcPDAstruct.NBB),nBursts,1),repmat(tcPDAstruct.corrections.BG_bb.*tcPDAstruct.duration,1,max(tcPDAstruct.NBB)+1));
            BGbg = poisspdf(repmat(0:1:max(tcPDAstruct.NBG),nBursts,1),repmat(tcPDAstruct.corrections.BG_bg.*tcPDAstruct.duration,1,max(tcPDAstruct.NBG)+1));
            BGbr = poisspdf(repmat(0:1:max(tcPDAstruct.NBR),nBursts,1),repmat(tcPDAstruct.corrections.BG_br.*tcPDAstruct.duration,1,max(tcPDAstruct.NBR)+1));
            BGgg = poisspdf(repmat(0:1:max(tcPDAstruct.NGG),nBursts,1),repmat(tcPDAstruct.corrections.BG_gg.*tcPDAstruct.duration,1,max(tcPDAstruct.NGG)+1));
            BGgr = poisspdf(repmat(0:1:max(tcPDAstruct.NGR),nBursts,1),repmat(tcPDAstruct.corrections.BG_gr.*tcPDAstruct.duration,1,max(tcPDAstruct.NGR)+1));
            %determine boundaries for background inclusion
            BGbb(BGbb<1E-2) = 0;
            BGbg(BGbg<1E-2) = 0;
            BGbr(BGbr<1E-2) = 0;
            BGgg(BGgg<1E-2) = 0;
            BGgr(BGgr<1E-2) = 0;
            %%% find the first column that is completely zero
            BGbb = BGbb(:,1:find( (sum(BGbb,1)==0),1,'first'));
            BGbg = BGbg(:,1:find( (sum(BGbg,1)==0),1,'first'));
            BGbr = BGbr(:,1:find( (sum(BGbr,1)==0),1,'first'));
            BGgg = BGgg(:,1:find( (sum(BGgg,1)==0),1,'first'));
            BGgr = BGgr(:,1:find( (sum(BGgr,1)==0),1,'first'));
        case 'cdf'
            BGbb = poisscdf(repmat(0:1:max(tcPDAstruct.NBB),nBursts,1),repmat(tcPDAstruct.corrections.BG_bb.*tcPDAstruct.duration,1,max(tcPDAstruct.NBB)+1));
            BGbg = poisscdf(repmat(0:1:max(tcPDAstruct.NBG),nBursts,1),repmat(tcPDAstruct.corrections.BG_bg.*tcPDAstruct.duration,1,max(tcPDAstruct.NBG)+1));
            BGbr = poisscdf(repmat(0:1:max(tcPDAstruct.NBR),nBursts,1),repmat(tcPDAstruct.corrections.BG_br.*tcPDAstruct.duration,1,max(tcPDAstruct.NBR)+1));
            BGgg = poisscdf(repmat(0:1:max(tcPDAstruct.NGG),nBursts,1),repmat(tcPDAstruct.corrections.BG_gg.*tcPDAstruct.duration,1,max(tcPDAstruct.NGG)+1));
            BGgr = poisscdf(repmat(0:1:max(tcPDAstruct.NGR),nBursts,1),repmat(tcPDAstruct.corrections.BG_gr.*tcPDAstruct.duration,1,max(tcPDAstruct.NGR)+1));
            %determine boundaries for background inclusion
            % Cover 90% of probability density
            BGbb(BGbb>0.9) = 1;
            BGbg(BGbg>0.9) = 1;
            BGbr(BGbr>0.9) = 1;
            BGgg(BGgg>0.9) = 1;
            BGgr(BGgr>0.9) = 1;
            %%% find the first column that is equal to nBursts
            BGbb = BGbb(:,1:find( (sum(BGbb,1)==nBursts),1,'first'));
            BGbg = BGbg(:,1:find( (sum(BGbg,1)==nBursts),1,'first'));
            BGbr = BGbr(:,1:find( (sum(BGbr,1)==nBursts),1,'first'));
            BGgg = BGgg(:,1:find( (sum(BGgg,1)==nBursts),1,'first'));
            BGgr = BGgr(:,1:find( (sum(BGgr,1)==nBursts),1,'first'));
    end
    %%% renormalize
    BGbb = BGbb./(repmat(sum(BGbb,2),1,size(BGbb,2)));
    BGbg = BGbg./(repmat(sum(BGbg,2),1,size(BGbg,2)));
    BGbr = BGbr./(repmat(sum(BGbr,2),1,size(BGbr,2)));
    BGgg = BGgg./(repmat(sum(BGgg,2),1,size(BGgg,2)));
    BGgr = BGgr./(repmat(sum(BGgr,2),1,size(BGgr,2)));
    %%% find boundaries of how many background counts to
    %%% consider in each burst
    NBGbb = zeros(nBursts,1);
    NBGbg = zeros(nBursts,1);
    NBGbr = zeros(nBursts,1);
    NBGgg = zeros(nBursts,1);
    NBGgr = zeros(nBursts,1);
    for u = 1:nBursts
        NBGbb(u) = find(BGbb(u,:) ~= 0,1,'last')-1;
        NBGbg(u) = find(BGbg(u,:) ~= 0,1,'last')-1;
        NBGbr(u) = find(BGbr(u,:) ~= 0,1,'last')-1;
        NBGgg(u) = find(BGgg(u,:) ~= 0,1,'last')-1;
        NBGgr(u) = find(BGgr(u,:) ~= 0,1,'last')-1;
    end
    %%% store in corrections structure
    tcPDAstruct.corrections.background.BGbb = BGbb;
    tcPDAstruct.corrections.background.BGbg = BGbg;
    tcPDAstruct.corrections.background.BGbr = BGbr;
    tcPDAstruct.corrections.background.BGgg = BGgg;
    tcPDAstruct.corrections.background.BGgr = BGgr;
    tcPDAstruct.corrections.background.NBGbb = NBGbb;
    tcPDAstruct.corrections.background.NBGbg = NBGbg;
    tcPDAstruct.corrections.background.NBGbr = NBGbr;
    tcPDAstruct.corrections.background.NBGgg = NBGgg;
    tcPDAstruct.corrections.background.NBGgr = NBGgr;
end
            
function update_fit_params(hObject,eventdata)
global tcPDAstruct
handles = guidata(gcbo);
%read initial fit values
fit_data = get(handles.fit_table,'data');
n_gauss = get(handles.popupmenu_ngauss,'value');
for i = 1:n_gauss%number of species
   tcPDAstruct.fitdata.param{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,2));
   tcPDAstruct.fitdata.fixed{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,3));
   tcPDAstruct.fitdata.LB{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,4));
   tcPDAstruct.fitdata.UB{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,5));
   tcPDAstruct.fitdata.use_prior{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,6));
   tcPDAstruct.fitdata.prior_center{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,7));
   tcPDAstruct.fitdata.prior_sigma{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,8));
end

function UpdateFitTable(handles)
global tcPDAstruct
%Read the old data from table
data = get(handles.fit_table,'Data');
%Update fitparameter values only
for i = 1:tcPDAstruct.n_gauss
    data(((i-1)*11+1):(11*i-1),2) = mat2cell(tcPDAstruct.fitdata.param{i},ones(10,1),1);
end

set(handles.fit_table,'Data',data);


function popupmenu_ngauss_callback(hObject,eventdata)
global tcPDAstruct
%get data from table

handles = guidata(hObject);
n_gauss = get(hObject,'Value');
tcPDAstruct.n_gauss = n_gauss;
str_dummy = {'<html><b>Amplitude','<html><b>R<sub>GR</sub>','<html><b>&sigma;<sub>GR</sub>','<html><b>R<sub>BG</sub>',...
    '<html><b>&sigma;<sub>BG</sub>','<html><b>R<sub>BR</sub>','<html><b>&sigma;<sub>BR</sub>',...
     '<html><b>cov<sub>BG/BR</sub>','<html><b>cov<sub>BG/GR</sub>','<html><b>cov<sub>BR/GR</sub>'};

nparams = numel(str_dummy);
NameCell = {};
for i = 1:n_gauss
    %NameCell = {NameCell{:} str_dummy{:} ''};
    for j = 1:numel(str_dummy)
        Data{(i-1)*(nparams+1)+j,1} = str_dummy{j};
        Data{(i-1)*(nparams+1)+j,2} = tcPDAstruct.fitdata.param{i}(j);
        Data{(i-1)*(nparams+1)+j,3} = tcPDAstruct.fitdata.fixed{i}(j);
        Data{(i-1)*(nparams+1)+j,4} = tcPDAstruct.fitdata.LB{i}(j);
        Data{(i-1)*(nparams+1)+j,5} = tcPDAstruct.fitdata.UB{i}(j);
        Data{(i-1)*(nparams+1)+j,6} = tcPDAstruct.fitdata.use_prior{i}(j);
        Data{(i-1)*(nparams+1)+j,7} = tcPDAstruct.fitdata.prior_center{i}(j);
        Data{(i-1)*(nparams+1)+j,8} = tcPDAstruct.fitdata.prior_sigma{i}(j);
    end
end
set(handles.fit_table,'RowName',NameCell,'Data',Data);
if gcbo == handles.popupmenu_ngauss
    view_curve(handles);
end
reset_plot([],[],handles);


function reset_plot(obj,~,handles)
if nargin < 3
    handles = guidata(obj);
end

%%% hides/unhides individual plots
n_gauss = handles.popupmenu_ngauss.Value;
if handles.checkbox_stochasticlabeling.Value
    n_gauss = n_gauss*2;
end
%%% hide all plots
for i = 1:10
    handles.plots.handles_H_res_1d_individual(i).Visible = 'off';
    handles.plots.handles_H_res_2d_individual(i).Visible = 'off';
    handles.plots.handles_H_res_3d_individual_bg_br(i).Visible = 'off';
    handles.plots.handles_H_res_3d_individual_bg_gr(i).Visible = 'off';
    handles.plots.handles_H_res_3d_individual_br_gr(i).Visible = 'off';
    handles.plots.handles_H_res_3d_individual_bg(i).Visible= 'off';
    handles.plots.handles_H_res_3d_individual_br(i).Visible= 'off';
    handles.plots.handles_H_res_3d_individual_gr(i).Visible= 'off';
end
%%% unhide used plots
if n_gauss > 1
    if ~handles.checkbox_stochasticlabeling.Value
        for i = 1:n_gauss
            handles.plots.handles_H_res_1d_individual(i).Visible = 'on';
        end
    else
        for i = 1:n_gauss/2
            handles.plots.handles_H_res_1d_individual(i).Visible = 'on';
        end
    end 
    for i = 1:n_gauss
        handles.plots.handles_H_res_2d_individual(i).Visible = 'on';
        handles.plots.handles_H_res_3d_individual_bg_br(i).Visible = 'on';
        handles.plots.handles_H_res_3d_individual_bg_gr(i).Visible = 'on';
        handles.plots.handles_H_res_3d_individual_br_gr(i).Visible = 'on';
        handles.plots.handles_H_res_3d_individual_bg(i).Visible= 'on';
        handles.plots.handles_H_res_3d_individual_br(i).Visible= 'on';
        handles.plots.handles_H_res_3d_individual_gr(i).Visible= 'on';
    end
end

function [ chi2 ] = determine_chi2_1C_mc_cor(fitpar)
global tcPDAstruct UserValues
nbins = UserValues.tcPDA.nbins;
%this ensures that the same random numbers are generated in each fitting
%step to reduce stochastic noise
rng('shuffle');

N_gauss = numel(fitpar)/3;
%one color fit
for i = 1:N_gauss
    A(i) =fitpar((i-1)*3+1);
    RDA(i) = fitpar((i-1)*3+2);
    sigma_RDA(i) = fitpar((i-1)*3+3);
end

A = A./sum(A);

%read corrections
mBG_gg = tcPDAstruct.corrections.BG_gg;
mBG_gr = tcPDAstruct.corrections.BG_gr;
cr = tcPDAstruct.corrections.ct_gr;
de = tcPDAstruct.corrections.de_gr;
gamma = tcPDAstruct.corrections.gamma_gr;
R0 = tcPDAstruct.corrections.R0_gr;
sampling = tcPDAstruct.sampling;
BSD_GX = tcPDAstruct.BSD_GX;
%valid = Cut_Data([],[]);
dur = tcPDAstruct.duration(tcPDAstruct.valid);
H_meas = tcPDAstruct.H_meas_gr;
%pool = gcp;
%sampling = pool.NumWorkers;
PRH = cell(sampling,N_gauss);
for j = 1:N_gauss
    parfor (i = 1:sampling,UserValues.Settings.Pam.ParallelProcessing)
        r = normrnd(RDA(j),sigma_RDA(j),numel(BSD_GX),1);
        E = 1./(1+(r./R0).^6);
        eps = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);
        BG_gg = poissrnd(mBG_gg.*dur);
        BG_gr = poissrnd(mBG_gr.*dur);
        BSD_GX_bg = BSD_GX-BG_gg-BG_gr;
        PRH{i,j} = (binornd(BSD_GX_bg,eps)+BG_gr)./BSD_GX;
    end
end

for i = 1:N_gauss
    H_res_dummy(:,i) = histc(vertcat(PRH{:,i}),linspace(0,1,nbins+1))/sampling;
    H_res_dummy(end-1,i) = H_res_dummy(end-1,i) + H_res_dummy(end,i);
end

H_res_dummy = H_res_dummy(1:nbins,:);
H_res = zeros(nbins,1);
for i = 1:N_gauss
    H_res = H_res + A(i).*H_res_dummy(:,i);
end
H_res = sum(H_meas)*H_res./sum(H_res);
%H_res= H_res(1:50)/sampling;

%calculate chi2
error = sqrt(H_meas); error(error == 0) = 1;
dev = (H_res-H_meas)./error;
chi2 = sum(dev.^2)./sum(H_meas~=0);
tcPDAstruct.plots.chi2 = chi2;
tcPDAstruct.plots.dev_gr = dev;

%%% chi2 estimate based on Poissonian statistics
%chi2 = chi2poiss(H_res,H_meas);

tcPDAstruct.plots.H_res_gr = H_res;
%tcPDAstruct.plots.dev_gr = sign(H_res-H_meas).*sqrt(dev_mle);
tcPDAstruct.plots.H_res_1d_individual = H_res_dummy;
tcPDAstruct.plots.A_gr = A;
%[tcPDAstruct.plots.chi2, tcPDAstruct.plots.dev_gr] = chi2poiss(H_res,H_meas);

%%% Update Fit Parameter in global struct
for i = 1:N_gauss
    tcPDAstruct.fitdata.param{i}(1:3) = fitpar(((i-1)*3+1):((i-1)*3+3));
end

function [ chi2 ] = determine_chi2_2C_mc_dist_cor(fitpar)
global tcPDAstruct UserValues
nbins = UserValues.tcPDA.nbins;
%this ensures that the same random numbers are generated in each fitting
%step to reduce stochastic noise
rng('shuffle');

if ~tcPDAstruct.use_stochasticlabeling
    %%% No stochastic labeling correction
    N_gauss = numel(fitpar)/7; 

    for i = 1:N_gauss
        A(i) =fitpar((i-1)*7+1);
        Rgr(i) = fitpar((i-1)*7+2);
        sigma_Rgr(i) = fitpar((i-1)*7+3);
        Rbg(i) = fitpar((i-1)*7+4);
        sigma_Rbg(i) = fitpar((i-1)*7+5);
        Rbr(i) = fitpar((i-1)*7+6);
        sigma_Rbr(i) = fitpar((i-1)*7+7);
    end
elseif tcPDAstruct.use_stochasticlabeling
    %%% use stochastic labeling correction
    %%% this means: every population gets a second population with equal
    %%% RGR but switched RBG and RBR. The fraction of this population is
    %%% given by as well
    N_gauss = numel(fitpar)/7;
    
    for i = 1:N_gauss
        %%% normal population at position 2*i-1 (1,3,5,7...)
        A(2*i-1) =fitpar((i-1)*7+1)*tcPDAstruct.fraction_stochasticlabeling; %%% multiplied with fraction of "normal" population
        Rgr(2*i-1) = fitpar((i-1)*7+2);
        sigma_Rgr(2*i-1) = fitpar((i-1)*7+3);
        Rbg(2*i-1) = fitpar((i-1)*7+4);
        sigma_Rbg(2*i-1) = fitpar((i-1)*7+5);
        Rbr(2*i-1) = fitpar((i-1)*7+6);
        sigma_Rbr(2*i-1) = fitpar((i-1)*7+7);
        %%% second population at position 2*i (2,4,6,8...)
        A(2*i) =fitpar((i-1)*7+1)*(1-tcPDAstruct.fraction_stochasticlabeling);%%% multiplied with fraction of second population
        Rgr(2*i) = fitpar((i-1)*7+2);
        sigma_Rgr(2*i) = fitpar((i-1)*7+3);
        Rbg(2*i) = fitpar((i-1)*7+6); %%% switched with RBR
        sigma_Rbg(2*i) = fitpar((i-1)*7+7);%%% switched with sigma_RBR
        Rbr(2*i) = fitpar((i-1)*7+4);%%% switched with RBG
        sigma_Rbr(2*i) = fitpar((i-1)*7+5);%%% switched with sigma_RBG
    end
    N_gauss = 2*N_gauss;
end
A = A./sum(A);
%read corrections
mBG_bb = tcPDAstruct.corrections.BG_bb;
mBG_bg = tcPDAstruct.corrections.BG_bg;
mBG_br = tcPDAstruct.corrections.BG_br;
cr_gr = tcPDAstruct.corrections.ct_gr;
cr_bg = tcPDAstruct.corrections.ct_bg;
cr_br = tcPDAstruct.corrections.ct_br;
de_bg = tcPDAstruct.corrections.de_bg;
de_br = tcPDAstruct.corrections.de_br;
gamma_gr = tcPDAstruct.corrections.gamma_gr;
gamma_br = tcPDAstruct.corrections.gamma_br;
gamma_bg = gamma_br/gamma_gr;
R0_bg = tcPDAstruct.corrections.R0_bg;
R0_br = tcPDAstruct.corrections.R0_br;
R0_gr = tcPDAstruct.corrections.R0_gr;
sampling = tcPDAstruct.sampling;
BSD_BX = tcPDAstruct.BSD_BX;
%valid = Cut_Data([],[]);
dur = tcPDAstruct.duration(tcPDAstruct.valid);
H_meas = tcPDAstruct.H_meas_2d;

pe_b = 1-de_br-de_bg; %probability of blue excitation

total_rolls = numel(BSD_BX);

PrBG = cell(sampling,N_gauss);
PrBR = cell(sampling,N_gauss);
for j=1:N_gauss
    MU = [Rbg(j), Rbr(j), Rgr(j)];
    COV =[sigma_Rbg(j)^2, 0 ,0;0,sigma_Rbr(j)^2,0;0,0,sigma_Rgr(j)^2];
    parfor (i = 1:sampling,UserValues.Settings.Pam.ParallelProcessing)
        r = mvnrnd(MU,COV,total_rolls);
        %distance distribution
        E1 = 1./(1+(r(:,1)./R0_bg).^6);
        E2 = 1./(1+(r(:,2)./R0_br).^6);
        EGR = 1./(1+(r(:,3)./R0_gr).^6);

        EBG_R = E1.*(1-E2)./(1-E1.*E2);
        EBR_G = E2.*(1-E1)./(1-E1.*E2);
        E1A = EBG_R + EBR_G;

        PB = pe_b.*(1-E1A);
        
        PG = pe_b.*(1-E1A).*cr_bg + ...
            pe_b.*EBG_R.*(1-EGR).*gamma_bg + ...
            de_bg.*(1-EGR).*gamma_bg;
        
        PR = pe_b.*(1-E1A).*cr_br + ...
            pe_b.*EBG_R.*(1-EGR).*gamma_bg.*cr_gr + ...
            pe_b.*EBG_R.*EGR.*gamma_br + ...
            pe_b.*EBR_G.*gamma_br + ...
            de_bg.*(1-EGR).*gamma_bg.*cr_gr + ...
            de_bg.*EGR.*gamma_br + ...
            de_br.*gamma_br;
        
        P_total = PB+PG+PR;
        
        PBB = PB./P_total;
        PBG = PG./P_total;
        PBR = PR./P_total;
        
%     PBB = (pe_b*(1-E1A))./ ...
%         (...
%         pe_b*(1-E1A) + ...
%         pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
%         de_bg*(1-EGR)*gamma_bg + ...
%         pe_b*(1-E1A)*cr_bg + ...
%         pe_b*(1-E1A)*cr_br + ...
%         de_bg*(1-EGR)*gamma_bg*cr_gr + ...
%         de_bg*EGR*gamma_br + ...
%         de_br*gamma_br + ...
%         pe_b*EBR_G*gamma_br + ...
%         pe_b*EBG_R.*EGR*gamma_br +...
%         pe_b*EBG_R.*(1-EGR)*gamma_bg*cr_gr);
%     PBG = (...
%          pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
%          de_bg*(1-EGR)*gamma_bg + ...
%          pe_b*(1-E1A)*cr_bg)./...
%          (...
%         pe_b*(1-E1A) + ...
%         pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
%         de_bg*(1-EGR)*gamma_bg + ...
%         pe_b*(1-E1A)*cr_bg + ...
%         pe_b*(1-E1A)*cr_br + ...
%         de_bg*(1-EGR)*gamma_bg*cr_gr + ...
%         de_bg*EGR*gamma_br + ...
%         de_br*gamma_br + ...
%         pe_b*EBR_G*gamma_br + ...
%         pe_b*EBG_R.*EGR*gamma_br +...
%         pe_b*EBG_R.*(1-EGR)*gamma_bg*cr_gr);
% 
%         PBR = 1- PBB - PBG;

        %background correction
        BG_bb = poissrnd(mBG_bb.*dur);
        BG_bg = poissrnd(mBG_bg.*dur);
        BG_br = poissrnd(mBG_br.*dur);
        BSD_BX_bg = BSD_BX - (BG_bb+BG_bg+BG_br);
        PRH = mnrnd(BSD_BX_bg,[PBB,PBG,PBR]); %sorted by NB NG NR

        PrBG{i,j} = (PRH(:,2)+BG_bg)./BSD_BX;
        PrBR{i,j} = (PRH(:,3)+BG_br)./BSD_BX;
    end
end
%PrBG = vertcat(PrBG{:});
%PrBR = vertcat(PrBR{:});  
for i = 1:N_gauss
    dummy = hist2d([vertcat(PrBG{:,i}) vertcat(PrBR{:,i})],nbins+1,nbins+1,[0 1],[0 1]);
    dummy(:,end-1) = dummy(:,end-1) + dummy(:,end);
    dummy(end-1,:) = dummy(end-1,:) + dummy(end,:);
    H_res_dummy(:,:,i) = dummy(1:nbins,1:nbins)'./sampling;
end

H_res = zeros(nbins,nbins,1);
for i = 1:N_gauss
    H_res = H_res + A(i).*H_res_dummy(:,:,i);
end
%normalize
H_res = (H_res./sum(sum(H_res))).*sum(sum(H_meas));

error = sqrt(H_meas);error(error==0) = 1;
dev = (H_res-H_meas)./error;
chi2 = sum(sum(dev.^2))./sum(sum(H_meas~=0));
tcPDAstruct.plots.chi2 = chi2;
tcPDAstruct.plots.dev_2d = dev;

%%% chi2 estimate based on Poissonian statistics
%chi2 = chi2poiss(H_res,H_meas);

%store for plotting
tcPDAstruct.plots.H_res_2d = H_res;
%tcPDAstruct.plots.dev_2d = sign(H_res-H_meas).*sqrt(max(dev_mle,0));
tcPDAstruct.plots.H_res_2d_individual = H_res_dummy;
tcPDAstruct.plots.A_2d = A;
%[tcPDAstruct.plots.chi2, tcPDAstruct.plots.dev_2d] = chi2poiss(H_res,H_meas);

%%% Update Fit Parameter in global struct
for i = 1:numel(fitpar)/7
    tcPDAstruct.fitdata.param{i}(1:7) = fitpar(((i-1)*7+1):((i-1)*7+7));
end

function [ chi2 ] = determine_chi2_mc_dist_3d_cor(fitpar)
global tcPDAstruct UserValues
nbins = UserValues.tcPDA.nbins;
%this ensures that the same random numbers are generated in each fitting
%step to reduce stochastic noise
rng('shuffle');

%10 fit par:
%1 Amplitude
%3 Distances
%3 sigma
%3 elements of cov mat

if ~tcPDAstruct.use_stochasticlabeling
    %%% No stochastic labeling correction
    N_gauss = numel(fitpar)/10; 

    for i = 1:N_gauss
        A(i) =fitpar((i-1)*10+1);
        Rgr(i) = fitpar((i-1)*10+2);
        sigma_Rgr(i) = fitpar((i-1)*10+3);
        Rbg(i) = fitpar((i-1)*10+4);
        sigma_Rbg(i) = fitpar((i-1)*10+5);
        Rbr(i) = fitpar((i-1)*10+6);
        sigma_Rbr(i) = fitpar((i-1)*10+7);
        simga_Rbg_Rbr(i) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(i) = fitpar((i-1)*10+9);
        simga_Rbr_Rgr(i) = fitpar((i-1)*10+10);
    end
elseif tcPDAstruct.use_stochasticlabeling
    %%% use stochastic labeling correction
    %%% this means: every population gets a second population with equal
    %%% RGR but switched RBG and RBR. The fraction of this population is
    %%% given by as well
    N_gauss = numel(fitpar)/10;
    for i = 1:N_gauss
        %%% normal population at position 2*i-1 (1,3,5,7...)
        A(2*i-1) =fitpar((i-1)*10+1)*tcPDAstruct.fraction_stochasticlabeling; %%% multiplied with fraction of "normal" population
        Rgr(2*i-1) = fitpar((i-1)*10+2);
        sigma_Rgr(2*i-1) = fitpar((i-1)*10+3);
        Rbg(2*i-1) = fitpar((i-1)*10+4);
        sigma_Rbg(2*i-1) = fitpar((i-1)*10+5);
        Rbr(2*i-1) = fitpar((i-1)*10+6);
        sigma_Rbr(2*i-1) = fitpar((i-1)*10+7);
        simga_Rbg_Rbr(2*i-1) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(2*i-1) = fitpar((i-1)*10+9);
        simga_Rbr_Rgr(2*i-1) = fitpar((i-1)*10+10);
        %%% second population at position 2*i (2,4,6,8...)
        A(2*i) =fitpar((i-1)*10+1)*(1-tcPDAstruct.fraction_stochasticlabeling);%%% multiplied with fraction of second population
        Rgr(2*i) = fitpar((i-1)*10+2);
        sigma_Rgr(2*i) = fitpar((i-1)*10+3);
        Rbg(2*i) = fitpar((i-1)*10+6); %%% switched with RBR
        sigma_Rbg(2*i) = fitpar((i-1)*10+7);%%% switched with sigma_RBR
        Rbr(2*i) = fitpar((i-1)*10+4);%%% switched with RBG
        sigma_Rbr(2*i) = fitpar((i-1)*10+5);%%% switched with sigma_RBG
        simga_Rbg_Rbr(2*i) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(2*i) = fitpar((i-1)*10+10); %%% switched with sigma_Rbr_Rgr
        simga_Rbr_Rgr(2*i) = fitpar((i-1)*10+9); %%% switched with sigma_Rbg_Rgr
    end
    N_gauss = 2*N_gauss;
end
A = A./sum(A);
%read corrections
mBG_bb = tcPDAstruct.corrections.BG_bb;
mBG_bg = tcPDAstruct.corrections.BG_bg;
mBG_br = tcPDAstruct.corrections.BG_br;
mBG_gg = tcPDAstruct.corrections.BG_gg;
mBG_gr = tcPDAstruct.corrections.BG_gr;
cr_gr = tcPDAstruct.corrections.ct_gr;
cr_bg = tcPDAstruct.corrections.ct_bg;
cr_br = tcPDAstruct.corrections.ct_br;
de_bg = tcPDAstruct.corrections.de_bg;
de_br = tcPDAstruct.corrections.de_br;
de_gr = tcPDAstruct.corrections.de_gr;
gamma_gr = tcPDAstruct.corrections.gamma_gr;
gamma_br = tcPDAstruct.corrections.gamma_br;
gamma_bg = gamma_br/gamma_gr;

R0_bg = tcPDAstruct.corrections.R0_bg;
R0_br = tcPDAstruct.corrections.R0_br;
R0_gr = tcPDAstruct.corrections.R0_gr;
sampling = tcPDAstruct.sampling;
BSD_BX = tcPDAstruct.BSD_BX;
BSD_GX = tcPDAstruct.BSD_GX;
%valid = Cut_Data([],[]);
dur = tcPDAstruct.duration(tcPDAstruct.valid);
H_meas = tcPDAstruct.H_meas;

pe_b = 1-de_br-de_bg; %probability of blue excitation
total_rolls = numel(BSD_BX);


if tcPDAstruct.BrightnessCorrection
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        BSDGX_scaled = cell(N_gauss,1);
        BSDBX_scaled = cell(N_gauss,1);
        for c = 1:N_gauss
            [Qr_b,Qr_g] = calc_relative_brightness(Rgr(c),Rbg(c),Rbr(c));
            %%% Rescale the PN;
            PNGX_scaled = scalePN(tcPDAstruct.BrightnessReference.PNG,Qr_g);
            PNBX_scaled = scalePN(tcPDAstruct.BrightnessReference.PNB,Qr_b);
%             %%% fit PN_scaled to match PN of file
%             PNGX_scaled = PNGX_scaled(1:max(tcPDAstruct.BSD_GX));
%             PNBX_scaled = PNBX_scaled(1:max(tcPDAstruct.BSD_BX));
            PNGX_scaled = PNGX_scaled./sum(PNGX_scaled).*numel(tcPDAstruct.BSD_GX);
            PNBX_scaled = PNBX_scaled./sum(PNBX_scaled).*numel(tcPDAstruct.BSD_BX);
            
            PNGX_scaled = ceil(PNGX_scaled); % round to integer
            PNBX_scaled = ceil(PNBX_scaled);
            BSDGX_scaled{c} = zeros(sum(PNGX_scaled),1);
            BSDBX_scaled{c} = zeros(sum(PNBX_scaled),1);
            count = 0;
            for i = 1:numel(PNGX_scaled)
                BSDGX_scaled{c}(count+1:count+PNGX_scaled(i)) = i;
                count = count+PNGX_scaled(i);
            end
            count = 0;
            for i = 1:numel(PNBX_scaled)
                BSDBX_scaled{c}(count+1:count+PNBX_scaled(i)) = i;
                count = count+PNBX_scaled(i);
            end
            %%% BSD_scaled contains too many bursts now, remove randomly
            BSDGX_scaled{c} = BSDGX_scaled{c}(randperm(numel(BSDGX_scaled{c})));
            BSDGX_scaled{c} = BSDGX_scaled{c}(1:numel(tcPDAstruct.BSD_GX));
            BSDBX_scaled{c} = BSDBX_scaled{c}(randperm(numel(BSDBX_scaled{c})));
            BSDBX_scaled{c} = BSDBX_scaled{c}(1:numel(tcPDAstruct.BSD_BX));
        end  
end
%initialize data
PrGR = cell(sampling,N_gauss);
PrBG = cell(sampling,N_gauss);
PrBR = cell(sampling,N_gauss);

for j=1:N_gauss
    MU = [Rbg(j), Rbr(j), Rgr(j)];
    COV =[sigma_Rbg(j).^2, simga_Rbg_Rbr(j) ,simga_Rbg_Rgr(j);...
        simga_Rbg_Rbr(j),sigma_Rbr(j).^2,simga_Rbr_Rgr(j);...
        simga_Rbg_Rgr(j),simga_Rbr_Rgr(j),sigma_Rgr(j).^2];
    while any(eig(COV)< 0)
        [COV] = fix_covariance_matrix(COV);
    end
    if tcPDAstruct.BrightnessCorrection
        BSD_BX = BSDBX_scaled{j};
        BSD_GX = BSDGX_scaled{j};
    end
    parfor (i = 1:sampling,UserValues.Settings.Pam.ParallelProcessing)
        [PrBG{i,j}, PrBR{i,j}, PrGR{i,j}] = sim_hist_mc_dist_3d_cor_optim_mex(MU,COV,total_rolls,R0_bg,R0_br,R0_gr,cr_bg,cr_br,cr_gr,pe_b,de_bg,de_br,de_gr,mBG_bb,mBG_bg,mBG_br,mBG_gg,mBG_gr,gamma_bg,gamma_br,gamma_gr,BSD_BX,BSD_GX,dur);
        
        %         r = mvnrnd(MU,COV,total_rolls);
        %         %distance distribution
        %         E1 = 1./(1+(r(:,1)./R0_bg).^6);
        %         E2 = 1./(1+(r(:,2)./R0_br).^6);
        %         EGR = 1./(1+(r(:,3)./R0_gr).^6);
        %
        %         PGR = 1-(1+cr_gr+(((de_gr/(1-de_gr)) + EGR) * gamma_gr)./(1-EGR)).^(-1);
        %
        %         EBG_R = E1.*(1-E2)./(1-E1.*E2);
        %         EBR_G = E2.*(1-E1)./(1-E1.*E2);
        %         E1A = EBG_R + EBR_G;
        %
        %
        %         PB = pe_b.*(1-E1A);
        %
        %         PG = pe_b.*(1-E1A).*cr_bg + ...
        %             pe_b.*EBG_R.*(1-EGR).*gamma_bg + ...
        %             de_bg.*(1-EGR).*gamma_bg;
        %
        %         PR = pe_b.*(1-E1A).*cr_br + ...
        %             pe_b.*EBG_R.*(1-EGR).*gamma_bg.*cr_gr + ...
        %             pe_b.*EBG_R.*EGR.*gamma_br + ...
        %             pe_b.*EBR_G.*gamma_br + ...
        %             de_bg.*(1-EGR).*gamma_bg.*cr_gr + ...
        %             de_bg.*EGR.*gamma_br + ...
        %             de_br.*gamma_br;
        %
        %         P_total = PB+PG+PR;
        %
        %         PBB = PB./P_total;
        %         PBG = PG./P_total;
        %         PBR = PR./P_total;
        %
        % %         PBB = (pe_b*(1-E1A))./ ...
        % %             (...
        % %             pe_b*(1-E1A) + ...
        % %             pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
        % %             de_bg*(1-EGR)*gamma_bg + ...
        % %             pe_b*(1-E1A)*cr_bg + ...
        % %             pe_b*(1-E1A)*cr_br + ...
        % %             de_bg*(1-EGR)*gamma_bg*cr_gr + ...
        % %             de_bg*EGR*gamma_br + ...
        % %             de_br*gamma_br + ...
        % %             pe_b*EBR_G*gamma_br + ...
        % %             pe_b*EBG_R.*EGR*gamma_br +...
        % %             pe_b*EBG_R.*(1-EGR)*gamma_bg*cr_gr);
        % %         PBG = (...
        % %              pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
        % %              de_bg*(1-EGR)*gamma_bg + ...
        % %              pe_b*(1-E1A)*cr_bg)./...
        % %             (...
        % %             pe_b*(1-E1A) + ...
        % %             pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
        % %             de_bg*(1-EGR)*gamma_bg + ...
        % %             pe_b*(1-E1A)*cr_bg + ...
        % %             pe_b*(1-E1A)*cr_br + ...
        % %             de_bg*(1-EGR)*gamma_bg*cr_gr + ...
        % %             de_bg*EGR*gamma_br + ...
        % %             de_br*gamma_br + ...
        % %             pe_b*EBR_G*gamma_br + ...
        % %             pe_b*EBG_R.*EGR*gamma_br +...
        % %             pe_b*EBG_R.*(1-EGR)*gamma_bg*cr_gr);
        % %
        % %         PBR = 1- PBB - PBG;
        %
        %         %background correction
        %         BG_bb = poissrnd(mBG_bb.*dur);
        %         BG_bg = poissrnd(mBG_bg.*dur);
        %         BG_br = poissrnd(mBG_br.*dur);
        %         BG_gg = poissrnd(mBG_gg.*dur);
        %         BG_gr = poissrnd(mBG_gr.*dur);
        %
        %         %PRH GR
        %         BSD_GX_bg = BSD_GX-BG_gg-BG_gr;
        
        %PrGR{i,j} = (binornd(BSD_GX_bg,PGR)+BG_gr)./BSD_GX;
        
        %         %PRH BG BR
        %         BSD_BX_bg = BSD_BX - (BG_bb+BG_bg+BG_br);
        %         PRH = mnrnd(BSD_BX_bg,[PBB,PBG,PBR]); %sorted by NB NG NR
        
        % PrBG{i,j} = (PRH(:,2)+BG_bg)./BSD_BX;
        %PrBR{i,j} = (PRH(:,3)+BG_br)./BSD_BX;
    end
end

H_res_dummy = cell(N_gauss,1);
for i = 1:N_gauss
    dummy = histcn([vertcat(PrBG{:,i}),vertcat(PrBR{:,i}),vertcat(PrGR{:,i})],linspace(0,1,nbins+1),linspace(0,1,nbins+1),linspace(0,1,nbins+1));
    dummy(:,:,end-1) = dummy(:,:,end-1) + dummy(:,:,end);
    dummy(:,end-1,:) = dummy(:,end-1,:) + dummy(:,end,:);
    dummy(end-1,:,:) = dummy(end-1,:,:) + dummy(end,:,:);
    H_res_dummy{i} = dummy(1:nbins,1:nbins,1:nbins)./sampling;
end

H_res = zeros(nbins,nbins,nbins);
for i = 1:N_gauss
    H_res = H_res + A(i).*H_res_dummy{i};
end

%normalize
H_res = (H_res./sum(sum(sum((H_res))))).*sum(sum(sum(H_meas)));

sigma_est = sqrt(H_meas); sigma_est(sigma_est == 0) = 1;
dev = (H_res-H_meas)./sigma_est;
chi2 = sum(sum(sum(dev.^2)))./sum(sum(sum(H_meas~=0)));
tcPDAstruct.plots.chi2 = chi2;

%%% chi2 estimate based on Poissonian statistics
%chi2 = chi2poiss(H_res,H_meas);

%store for plotting
%2D BG BR
%tcPDAstruct.plots.H_res_2d = sum(H_res,3);
%tcPDAstruct.plots.dev_2d = (tcPDAstruct.H_meas_2d-tcPDAstruct.plots.H_res_2d)./sqrt(tcPDAstruct.H_meas_2d);
%tcPDAstruct.plots.dev_2d(~isfinite(tcPDAstruct.plots.dev_2d)) = 0;
%tcPDAstruct.plots.H_res_2d_individual = H_res_dummy;
%1D GR
%tcPDAstruct.plots.H_res_1d = squeeze(sum(sum(H_res,1),2));
%tcPDAstruct.plots.dev_gr = (tcPDAstruct.H_meas_gr-tcPDAstruct.plots.H_res_1d)./sqrt(tcPDAstruct.H_meas_gr);
%tcPDAstruct.plots.dev_gr(~isfinite(tcPDAstruct.plots.dev_gr)) = 0;

tcPDAstruct.plots.A_3d = A;
tcPDAstruct.plots.H_res_3d = H_res;
tcPDAstruct.plots.H_res_3d_individual = H_res_dummy;
tcPDAstruct.plots.H_res_3d_bg_br = squeeze(sum(H_res,3));
tcPDAstruct.plots.H_res_3d_bg_gr = squeeze(sum(H_res,2));
tcPDAstruct.plots.H_res_3d_br_gr = squeeze(sum(H_res,1));
tcPDAstruct.plots.H_res_3d_bg = squeeze(sum(sum(H_res,2),3));
tcPDAstruct.plots.H_res_3d_br = squeeze(sum(sum(H_res,1),3));
tcPDAstruct.plots.H_res_3d_gr = squeeze(sum(sum(H_res,1),2));
%[tcPDAstruct.plots.chi2, tcPDAstruct.plots.dev_3d] = chi2poiss(H_res,H_meas);

%%% Update Fit Parameter in global struct
for i = 1:numel(fitpar)/10
    tcPDAstruct.fitdata.param{i}(1:10) = fitpar(((i-1)*10+1):((i-1)*10+10));
end

function [ P_result ] = determine_MLE_mc_dist_3d_cor(fitpar)
global tcPDAstruct

%10 fit par:
%1 Amplitude
%3 Distances
%3 sigma
%3 elements of cov mat

if ~tcPDAstruct.use_stochasticlabeling
    %%% No stochastic labeling correction
    N_gauss = numel(fitpar)/10; 

    for i = 1:N_gauss
        A(i) =fitpar((i-1)*10+1);
        Rgr(i) = fitpar((i-1)*10+2);
        sigma_Rgr(i) = fitpar((i-1)*10+3);
        Rbg(i) = fitpar((i-1)*10+4);
        sigma_Rbg(i) = fitpar((i-1)*10+5);
        Rbr(i) = fitpar((i-1)*10+6);
        sigma_Rbr(i) = fitpar((i-1)*10+7);
        simga_Rbg_Rbr(i) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(i) = fitpar((i-1)*10+9);
        simga_Rbr_Rgr(i) = fitpar((i-1)*10+10);
    end
elseif tcPDAstruct.use_stochasticlabeling
    %%% use stochastic labeling correction
    %%% this means: every population gets a second population with equal
    %%% RGR but switched RBG and RBR. The fraction of this population is
    %%% given by as well
    N_gauss = numel(fitpar)/10;
    
    for i = 1:N_gauss
        %%% normal population at position 2*i-1 (1,3,5,7...)
        A(2*i-1) =fitpar((i-1)*10+1)*tcPDAstruct.fraction_stochasticlabeling; %%% multiplied with fraction of "normal" population
        Rgr(2*i-1) = fitpar((i-1)*10+2);
        sigma_Rgr(2*i-1) = fitpar((i-1)*10+3);
        Rbg(2*i-1) = fitpar((i-1)*10+4);
        sigma_Rbg(2*i-1) = fitpar((i-1)*10+5);
        Rbr(2*i-1) = fitpar((i-1)*10+6);
        sigma_Rbr(2*i-1) = fitpar((i-1)*10+7);
        simga_Rbg_Rbr(2*i-1) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(2*i-1) = fitpar((i-1)*10+9);
        simga_Rbr_Rgr(2*i-1) = fitpar((i-1)*10+10);
        %%% second population at position 2*i (2,4,6,8...)
        A(2*i) =fitpar((i-1)*10+1)*(1-tcPDAstruct.fraction_stochasticlabeling);%%% multiplied with fraction of second population
        Rgr(2*i) = fitpar((i-1)*10+2);
        sigma_Rgr(2*i) = fitpar((i-1)*10+3);
        Rbg(2*i) = fitpar((i-1)*10+6); %%% switched with RBR
        sigma_Rbg(2*i) = fitpar((i-1)*10+7);%%% switched with sigma_RBR
        Rbr(2*i) = fitpar((i-1)*10+4);%%% switched with RBG
        sigma_Rbr(2*i) = fitpar((i-1)*10+5);%%% switched with sigma_RBG
        simga_Rbg_Rbr(2*i) = fitpar((i-1)*10+8);
        simga_Rbg_Rgr(2*i) = fitpar((i-1)*10+10); %%% switched with sigma_Rbr_Rgr
        simga_Rbr_Rgr(2*i) = fitpar((i-1)*10+9); %%% switched with sigma_Rbg_Rgr
    end
    N_gauss = 2*N_gauss;
end
A = A./sum(A);

%read corrections
corrections = tcPDAstruct.corrections;
corrections.gamma_bg = corrections.gamma_br/corrections.gamma_gr;

corrections.steps = 4;
%valid = Cut_Data([],[]);
dur = tcPDAstruct.duration(tcPDAstruct.valid);
%H_meas = tcPDAstruct.H_meas;
corrections.pe_b = 1-corrections.de_br-corrections.de_bg; %probability of blue excitation

P_res = cell(N_gauss,1);
for j=1:N_gauss
    MU = [Rbg(j), Rbr(j), Rgr(j)];
    COV =[sigma_Rbg(j).^2, simga_Rbg_Rbr(j) ,simga_Rbg_Rgr(j);...
          simga_Rbg_Rbr(j),sigma_Rbr(j).^2,simga_Rbr_Rgr(j);...
          simga_Rbg_Rgr(j),simga_Rbr_Rgr(j),sigma_Rgr(j).^2];
    while any(eig(COV)< 0)
       [COV] = fix_covariance_matrix(COV);
    end
    
    param.MU = MU;
    param.COV = COV;
    P_res{j} = posterior_tc(tcPDAstruct.fbb,tcPDAstruct.fbg,tcPDAstruct.fbr,tcPDAstruct.fgg,tcPDAstruct.fgr,dur,corrections,param);
end

%%% evaluate the prior
logPrior = 0;
if tcPDAstruct.use_stochasticlabeling
    N_gauss = N_gauss/2;
end
for j=1:N_gauss
    use_prior = tcPDAstruct.fitdata.use_prior{j};
    prior_center = tcPDAstruct.fitdata.prior_center{j};
    prior_sigma = tcPDAstruct.fitdata.prior_sigma{j};
    for k = 1:numel(use_prior)
        if use_prior(k)
            logPrior = logPrior + log(normpdf(fitpar((j-1)*10+k),prior_center(k),prior_sigma(k)));
        end
    end
end

if tcPDAstruct.BrightnessCorrection
        %%% If brightness correction is to be performed, determine the relative
        %%% brightness based on current distance and correction factors
        PNGX_scaled = cell(N_gauss,1);
        PNBX_scaled = cell(N_gauss,1);
        for c = 1:N_gauss
            [Qr_g,Qr_b] = calc_relative_brightness(Rgr(c),Rbg(c),Rbr(c));
            %%% Rescale the PN;
            PNGX_scaled{c} = scalePN(tcPDAstruct.BrightnessReference.PNG,Qr_g);
            PNGX_scaled{c} = smooth(PNGX_scaled{c},10);
            PNGX_scaled{c} = PNGX_scaled{c}./sum(PNGX_scaled{c});
            PNBX_scaled{c} = scalePN(tcPDAstruct.BrightnessReference.PNB,Qr_b);
            PNBX_scaled{c} = smooth(PNBX_scaled{c},10);
            PNBX_scaled{c} = PNBX_scaled{c}./sum(PNBX_scaled{c});
        end
        %%% calculate the relative probabilty
        PGX_norm = sum(horzcat(PNGX_scaled{:}),2);
        PBX_norm = sum(horzcat(PNBX_scaled{:}),2);
        for c = 1:N_gauss
            PNGX_scaled{c}(PGX_norm~=0) = PNGX_scaled{c}(PGX_norm~=0)./PGX_norm(PGX_norm~=0);
            PNBX_scaled{c}(PBX_norm~=0) = PNBX_scaled{c}(PBX_norm~=0)./PBX_norm(PBX_norm~=0);
            %%% We don't want zero probabilities here!
            PNGX_scaled{c}(PNGX_scaled{c} == 0) = eps;
            PNBX_scaled{c}(PNBX_scaled{c} == 0) = eps;
            %%% Treat case where measured bursts have higher photon number than
            %%% reference
            %%% -> Set probability to 1/N_gauss then
            if numel(PNGX_scaled{c}) < max(tcPDAstruct.fgg+tcPDAstruct.fgr)
                PNGX_scaled{c}(numel(PNGX_scaled{c})+1 : max(tcPDAstruct.fgg+tcPDAstruct.fgr)) = 1/N_gauss;
            end
            if numel(PNBX_scaled{c}) < max(tcPDAstruct.fbb+tcPDAstruct.fbg+tcPDAstruct.fbr)
                PNBX_scaled{c}(numel(PNBX_scaled{c})+1 :  max(tcPDAstruct.fbb+tcPDAstruct.fbg+tcPDAstruct.fbr)) = 1/N_gauss;
            end
            %%% Treat case of zero photons
            PNGX_scaled{c} = [1/N_gauss;PNGX_scaled{c}];
            PNBX_scaled{c} = [1/N_gauss;PNBX_scaled{c}];
        end
        
        
        
        for c = 1:N_gauss
            P_res{c} = P_res{c} + log(PNGX_scaled{c}(1+tcPDAstruct.fgg+tcPDAstruct.fgr)) + log(PNBX_scaled{c}(1+tcPDAstruct.fbb+tcPDAstruct.fbg+tcPDAstruct.fbr)); % +1 for zero photon case
        end
end

%%% combine the likelihoods of the Gauss
PA = A;
P_res = horzcat(P_res{:});
P_res = P_res + repmat(log(PA),numel(tcPDAstruct.fbb),1);
Lmax = max(P_res,[],2);
P_res = Lmax + log(sum(exp(P_res-repmat(Lmax,1,numel(PA))),2));
%%% P_res has NaN values if Lmax was -Inf (i.e. total of zero probability)!
%%% Reset these values to -Inf
P_res(isnan(P_res)) = -Inf;
P_result = sum(P_res);
P_result = P_result + logPrior;
%%% since the algorithm minimizes, it is important to minimize the negative
%%% log likelihood, i.e. maximize the likelihood
P_result = -P_result;

%%% Update Fit Parameter in global struct
for i = 1:N_gauss
    tcPDAstruct.fitdata.param{i}(1:10) = fitpar(((i-1)*10+1):((i-1)*10+10));
end

%%% update BIC
fixed = tcPDAstruct.fitdata.fixed(1:N_gauss);
n_param = sum(~vertcat(fixed{:}));
n_data = numel(tcPDAstruct.fbb);
%%% BIC = -2*lnL + #params * ln(# data points)
%%% P_result is already -lnL
tcPDAstruct.BIC = 2*P_result + n_param*log(n_data);
tcPDAstruct.logL = -P_result;

function P_res = posterior_tc(fbb,fbg,fbr,fgg,fgr,dur,corrections,param)
global tcPDAstruct UserValues
%%% evaluates the loglikelihood that param produce data
%%%
%%% input:
%%% data    -   structure containing the data
%%%             data.fbb,data.fbg ... etc
%%% corrections - structure containing the corretions
%%%               R0bg, R0br, R0gr
%%%               gamma_bg, gamma_br, gamma_gr
%%%               ct_bg, ct_br, ct_gr
%%%               de_bg, de_br, de_gr
%%%               bg_bb, bg_bg, bg_br, bg_gg, bg_gr
%%%               steps: Steps to use for R grid
%%% param   -   contains the parameters
%%%             Rbg, Rbr, Rgr
%%%             sigma_bg, sigma_br, sigma_gr

%%% read out parameters
Rbg = param.MU(1);
Rbr = param.MU(2);
Rgr = param.MU(3);
sigma_bg = sqrt(param.COV(1,1));
sigma_br = sqrt(param.COV(2,2));
sigma_gr = sqrt(param.COV(3,3));

BG_bb = corrections.background.BGbb;
BG_bg = corrections.background.BGbg;
BG_br = corrections.background.BGbr;
BG_gg = corrections.background.BGgg;
BG_gr = corrections.background.BGgr;
NBGbb = corrections.background.NBGbb;
NBGbg = corrections.background.NBGbg;
NBGbr = corrections.background.NBGbr;
NBGgg = corrections.background.NBGgg;
NBGgr = corrections.background.NBGgr;
%%% define the range for R grid
xRbg = (Rbg-2*sigma_bg):(4*sigma_bg/corrections.steps):(Rbg+2*sigma_bg);
xRbr = (Rbr-2*sigma_br):(4*sigma_br/corrections.steps):(Rbr+2*sigma_br);
xRgr = (Rgr-2*sigma_gr):(4*sigma_gr/corrections.steps):(Rgr+2*sigma_gr);
[XRbg, XRbr, XRgr] = meshgrid(xRbg,xRbr,xRgr);
XRbg = XRbg(:);
XRbr = XRbr(:);
XRgr = XRgr(:);
MU = [Rbg Rbr Rgr];
%SIGMA = [sigma_bg, 0, 0; 0, sigma_br, 0; 0, 0, sigma_gr].^2;
SIGMA = param.COV;
PR = mvnpdf([XRbg,XRbr,XRgr],MU,SIGMA);
PR = PR./sum(PR);

%%% calculate expected E values for R grid
EBG = 1./(1+(XRbg./corrections.R0_bg).^6);
EBR = 1./(1+(XRbr./corrections.R0_br).^6);
EGR = 1./(1+(XRgr./corrections.R0_gr).^6);

PGR = 1-(1+corrections.ct_gr+(((corrections.de_gr/(1-corrections.de_gr)) + EGR) * corrections.gamma_gr)./(1-EGR)).^(-1);

EBG_R = EBG.*(1-EBR)./(1-EBG.*EBR);
EBR_G = EBR.*(1-EBG)./(1-EBG.*EBR);
E1A = EBG_R + EBR_G;

pe_b = 1-corrections.de_bg - corrections.de_br;

Pout_B = pe_b.*(1-E1A);

Pout_G = pe_b.*(1-E1A).*corrections.ct_bg + ...
    pe_b.*EBG_R.*(1-EGR).*corrections.gamma_bg + ...
    corrections.de_bg.*(1-EGR).*corrections.gamma_bg;

Pout_R = pe_b.*(1-E1A).*corrections.ct_br + ...
    pe_b.*EBG_R.*(1-EGR).*corrections.gamma_bg.*corrections.ct_gr + ...
    pe_b.*EBG_R.*EGR.*corrections.gamma_br + ...
    pe_b.*EBR_G.*corrections.gamma_br + ...
    corrections.de_bg.*(1-EGR).*corrections.gamma_bg.*corrections.ct_gr + ...
    corrections.de_bg.*EGR.*corrections.gamma_br + ...
    corrections.de_br.*corrections.gamma_br;

P_total = Pout_B+Pout_G+Pout_R;

PBB = Pout_B./P_total;
PBG = Pout_G./P_total;
PBR = Pout_R./P_total;

%%% initialize arrays
%P = cell(numel(PR),1);
if strcmp(tcPDAstruct.timebin,'burstwise')
    %%% burstwise, indivual backgrounds used
%     parfor l = 1:numel(PR)
%         P{l} = eval_prob_3c_mex(fbb,fbg,fbr,fgg,fgr,PBB(l),PBG(l),PGR(l)); 
%     end
        parfor (l = 1:numel(PR),UserValues.Settings.Pam.ParallelProcessing)
            P{l} = eval_prob_3c_bg_burstwise_mex(fbb,fbg,fbr,fgg,fgr,...
                NBGbb,NBGbg,NBGbr,NBGgg,NBGgr,...
                BG_bb,BG_bg,BG_br,BG_gg,BG_gr,...
                PBB(l),PBG(l),PGR(l));
        end
        P = horzcat(P{:});
elseif isnumeric(tcPDAstruct.timebin)
    %% CUDA

    if (gpuDeviceCount > 0) && ~tcPDAstruct.GPU_locked
        
        fbb_single = single(fbb);
        fbg_single = single(fbg);
        fbr_single = single(fbr);
        fgg_single = single(fgg);
        fgr_single = single(fgr);
    
        NBGbb_single = int32(NBGbb);
        NBGbg_single = int32(NBGbg);
        NBGbr_single = int32(NBGbr);
        NBGgg_single = int32(NBGgg);
        NBGgr_single = int32(NBGgr);
    
        BG_bb_single = single(BG_bb);
        BG_bg_single = single(BG_bg);
        BG_br_single = single(BG_br);
        BG_gg_single = single(BG_gg);
        BG_gr_single = single(BG_gr);
    
        PBB_single = single(PBB);
        PBG_single = single(PBG);
        PGR_single = single(PGR);
        
%         P = eval_prob_3c_bg_cuda_lib(fbb_single,fbg_single,fbr_single,fgg_single,fgr_single,...
%                 NBGbb_single,NBGbg_single,NBGbr_single,NBGgg_single,NBGgr_single,...
%                 BG_bb_single',BG_bg_single',BG_br_single',BG_gg_single',BG_gr_single',...
%                 PBB_single,PBG_single,PGR_single,single(tcPDAstruct.lib_b),single(tcPDAstruct.lib_t));
        P = eval_prob_3c_bg_cuda(fbb_single,fbg_single,fbr_single,fgg_single,fgr_single,...
                NBGbb_single,NBGbg_single,NBGbr_single,NBGgg_single,NBGgr_single,...
                BG_bb_single',BG_bg_single',BG_br_single',BG_gg_single',BG_gr_single',...
                PBB_single,PBG_single,PGR_single);
        P = double(P);
    else
        %% CPU
        P = eval_prob_3c_bg_lib(fbb,fbg,fbr,fgg,fgr,...
                NBGbb,NBGbg,NBGbr,NBGgg,NBGgr,...
                BG_bb',BG_bg',BG_br',BG_gg',BG_gr',...
                PBB,PBG,PGR,tcPDAstruct.lib_b,tcPDAstruct.lib_t);
%         P = eval_prob_3c_bg(fbb,fbg,fbr,fgg,fgr,...
%                 NBGbb,NBGbg,NBGbr,NBGgg,NBGgr,...
%                 BG_bb',BG_bg',BG_br',BG_gg',BG_gr',...
%                 PBB,PBG,PGR); 
    end
end
%P = horzcat(P{:});
P = log(P) + repmat(log(PR'),numel(fbb),1);
Lmax = max(P,[],2);
P = Lmax + log(sum(exp(P-repmat(Lmax,1,numel(PR))),2));
%P_res = sum(P);
%%% Treat case when all burst produced zero probability
P_res = P;
P_res(isnan(P_res)) = -Inf;

function [R_gr, R_bg, R_br] = convert_prox_to_dist(PGR,PBG,PBR)

global tcPDAstruct
%read corrections
cr_gr = tcPDAstruct.corrections.ct_gr;
cr_bg = tcPDAstruct.corrections.ct_bg;
cr_br = tcPDAstruct.corrections.ct_br;
de_bg = tcPDAstruct.corrections.de_bg;
de_br = tcPDAstruct.corrections.de_br;
de_gr = tcPDAstruct.corrections.de_gr;
gamma_gr = tcPDAstruct.corrections.gamma_gr;
gamma_br = tcPDAstruct.corrections.gamma_br;
gamma_bg = gamma_br/gamma_gr;
R0_bg = tcPDAstruct.corrections.R0_bg;
R0_br = tcPDAstruct.corrections.R0_br;
R0_gr = tcPDAstruct.corrections.R0_gr;

EGR = -(de_gr/(de_gr - 1) - (cr_gr + 1/(PGR - 1) + 1)/gamma_gr)/((cr_gr + 1/(PGR - 1) + 1)/gamma_gr - 1);

EBG = (cr_bg*gamma_br - cr_bg*de_bg*gamma_br - cr_br*de_bg*gamma_bg + de_bg*gamma_bg*gamma_br + EGR*cr_bg*de_bg*gamma_br + EGR*cr_br*de_bg*gamma_bg - EGR*de_bg*gamma_bg*gamma_br + cr_bg*cr_gr*de_bg*gamma_bg - EGR*cr_bg*cr_gr*de_bg*gamma_bg)/(cr_bg*gamma_br - gamma_bg*gamma_br + EGR*gamma_bg*gamma_br - cr_bg*de_bg*gamma_br - cr_br*de_bg*gamma_bg + de_bg*gamma_bg*gamma_br + EGR*cr_bg*de_bg*gamma_br + EGR*cr_br*de_bg*gamma_bg - EGR*de_bg*gamma_bg*gamma_br + cr_bg*cr_gr*de_bg*gamma_bg - EGR*cr_bg*cr_gr*de_bg*gamma_bg);
EBR = (EGR*cr_bg*gamma_br - cr_br*gamma_bg + EGR*cr_br*gamma_bg + cr_bg*cr_gr*gamma_bg + cr_bg*de_br*gamma_br + cr_br*de_br*gamma_bg - de_br*gamma_bg*gamma_br - EGR*cr_bg*cr_gr*gamma_bg - EGR*cr_bg*de_br*gamma_br - EGR*cr_br*de_br*gamma_bg + EGR*de_br*gamma_bg*gamma_br - cr_bg*cr_gr*de_br*gamma_bg + EGR*cr_bg*cr_gr*de_br*gamma_bg)/(gamma_bg*gamma_br - cr_br*gamma_bg + EGR*cr_bg*gamma_br + EGR*cr_br*gamma_bg - EGR*gamma_bg*gamma_br + cr_bg*cr_gr*gamma_bg + cr_bg*de_br*gamma_br + cr_br*de_br*gamma_bg - de_br*gamma_bg*gamma_br - EGR*cr_bg*cr_gr*gamma_bg - EGR*cr_bg*de_br*gamma_br - EGR*cr_br*de_br*gamma_bg + EGR*de_br*gamma_bg*gamma_br - cr_bg*cr_gr*de_br*gamma_bg + EGR*cr_bg*cr_gr*de_br*gamma_bg);


R_gr = R0_gr*(1/EGR-1)^(1/6);
R_bg = R0_bg*(1/EBG-1)^(1/6);
R_br = R0_br*(1/EBR-1)^(1/6);
%%
% syms cr_gr de_gr gamma_gr EBG_R EBR_G E1A EBG EBR PBB PBR PBG pe_b de_br de_bg cr_gr cr_bg cr_br gamma_bg gamma_br EGR
% pe_b = 1-de_bg-de_br;
% 
% EBG_R = EBG.*(1-EBR)./(1-EBG.*EBR);
% EBR_G = EBR.*(1-EBG)./(1-EBG.*EBR);
% E1A = EBG_R + EBR_G;
%  
% 
% PBB = (pe_b*(1-E1A))./ ...
%             (...
%             pe_b*(1-E1A) + ...
%             pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
%             de_bg*(1-EGR)*gamma_bg + ...
%             pe_b*(1-E1A)*cr_bg + ...
%             pe_b*(1-E1A)*cr_br + ...
%             de_bg*(1-EGR)*gamma_bg*cr_gr + ...
%             de_bg*EGR*gamma_br + ...
%             de_br*gamma_br + ...
%             pe_b*EBR_G*gamma_br + ...
%             pe_b*EBG_R.*EGR*gamma_br +...
%             pe_b*EBG_R.*(1-EGR)*gamma_bg*cr_gr);
% 
% PBG = (...
%              pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
%              de_bg*(1-EGR)*gamma_bg + ...
%              pe_b*(1-E1A)*cr_bg)./...
%             (...
%             pe_b*(1-E1A) + ...
%             pe_b*EBG_R.*(1-EGR)*gamma_bg + ...
%             de_bg*(1-EGR)*gamma_bg + ...
%             pe_b*(1-E1A)*cr_bg + ...
%             pe_b*(1-E1A)*cr_br + ...
%             de_bg*(1-EGR)*gamma_bg*cr_gr + ...
%             de_bg*EGR*gamma_br + ...
%             de_br*gamma_br + ...
%             pe_b*EBR_G*gamma_br + ...
%             pe_b*EBG_R.*EGR*gamma_br +...
%             pe_b*EBG_R.*(1-EGR)*gamma_bg*cr_gr);
%         
% PBR = 1-PBB-PBG;
% 
% [sEBG sEBR] = solve(PBG,PBR,EBG,EBR);
%     
%     

function [ out ] = lsq_mc_dist_3d_cor(fitpar)
global tcPDAstruct UserValues

N_gauss = numel(fitpar)/7;

for i = 1:N_gauss
    A(i) =fitpar((i-1)*7+1);
    Rgr(i) = fitpar((i-1)*7+2);
    sigma_Rgr(i) = fitpar((i-1)*7+3);
    Rbg(i) = fitpar((i-1)*7+4);
    sigma_Rbg(i) = fitpar((i-1)*7+5);
    Rbr(i) = fitpar((i-1)*7+6);
    sigma_Rbr(i) = fitpar((i-1)*7+7);
end
A = A./sum(A);

%read corrections
mBG_bb = tcPDAstruct.corrections.BG_bb;
mBG_bg = tcPDAstruct.corrections.BG_bg;
mBG_br = tcPDAstruct.corrections.BG_br;
mBG_gg = tcPDAstruct.corrections.BG_gg;
mBG_gr = tcPDAstruct.corrections.BG_gr;
cr_gr = tcPDAstruct.corrections.ct_gr;
cr_bg = tcPDAstruct.corrections.ct_bg;
cr_br = tcPDAstruct.corrections.ct_br;
de_bg = tcPDAstruct.corrections.de_bg;
de_br = tcPDAstruct.corrections.de_br;
de_gr = tcPDAstruct.corrections.de_gr;
gamma_gr = tcPDAstruct.corrections.gamma_gr;
gamma_br = tcPDAstruct.corrections.gamma_br;
gamma_bg = gamma_br/gamma_gr;
R0_bg = tcPDAstruct.corrections.R0_bg;
R0_br = tcPDAstruct.corrections.R0_br;
R0_gr = tcPDAstruct.corrections.R0_gr;
sampling = tcPDAstruct.sampling;
BSD_BX = tcPDAstruct.BSD_BX;
BSD_GX = tcPDAstruct.BSD_GX;
%valid = Cut_Data([],[]);
dur = tcPDAstruct.duration(tcPDAstruct.valid);
H_meas = tcPDAstruct.H_meas;

pe_b = 1-de_br-de_bg; %probability of blue excitation
total_rolls = numel(BSD_BX);

%initialize data
PrGR = cell(sampling,N_gauss);
PrBG = cell(sampling,N_gauss);
PrBR = cell(sampling,N_gauss);

for j=1:N_gauss
    MU = [Rbg(j), Rbr(j), Rgr(j)];
    COV =[sigma_Rbg(j)^2, 0 ,0;0,sigma_Rbr(j)^2,0;0,0,sigma_Rgr(j)^2];
    
    parfor (i = 1:sampling,UserValues.Settings.Pam.ParallelProcessing)
        r = mvnrnd(MU,COV,total_rolls);
        %distance distribution
        E1 = 1./(1+(r(:,1)./R0_bg).^6);
        E2 = 1./(1+(r(:,2)./R0_br).^6);
        EGR = 1./(1+(r(:,3)./R0_gr).^6);

        PGR = 1-(1+cr_gr+(((de_gr/(1-de_gr)) + EGR) * gamma_gr)./(1-EGR)).^(-1);

        EBG_R = E1.*(1-E2)./(1-E1.*E2);
        EBR_G = E2.*(1-E1)./(1-E1.*E2);
        E1A = EBG_R + EBR_G;


        PB = pe_b.*(1-E1A);
        
        PG = pe_b.*(1-E1A).*cr_bg + ...
            pe_b.*EBG_R.*(1-EGR).*gamma_bg + ...
            de_bg.*(1-EGR).*gamma_bg;
        
        PR = pe_b.*(1-E1A).*cr_br + ...
            pe_b.*EBG_R.*(1-EGR).*gamma_bg.*cr_gr + ...
            pe_b.*EBG_R.*EGR.*gamma_br + ...
            pe_b.*EBR_G.*gamma_br + ...
            de_bg.*(1-EGR).*gamma_bg.*cr_gr + ...
            de_bg.*EGR.*gamma_br + ...
            de_br.*gamma_br;
        
        P_total = PB+PG+PR;
        
        PBB = PB./P_total;
        PBG = PG./P_total;
        PBR = PR./P_total;
 
        %background correction
        BG_bb = poissrnd(mBG_bb.*dur);
        BG_bg = poissrnd(mBG_bg.*dur);
        BG_br = poissrnd(mBG_br.*dur);
        BG_gg = poissrnd(mBG_gg.*dur);
        BG_gr = poissrnd(mBG_gr.*dur);
        
        %PRH GR
        BSD_GX_bg = BSD_GX-BG_gg-BG_gr;
        PrGR{i,j} = (binornd(BSD_GX_bg,PGR)+BG_gr)./BSD_GX;
        
        %PRH BG BR
        BSD_BX_bg = BSD_BX - (BG_bb+BG_bg+BG_br);
        PRH = mnrnd(BSD_BX_bg,[PBB,PBG,PBR]); %sorted by NB NG NR
        
        PrBG{i,j} = (PRH(:,2)+BG_bg)./BSD_BX;
        PrBR{i,j} = (PRH(:,3)+BG_br)./BSD_BX;
    end
end

H_res_dummy = cell(N_gauss,1);
for i = 1:N_gauss
    dummy = histcn([vertcat(PrBG{:,i}),vertcat(PrBR{:,i}),vertcat(PrGR{:,i})],[0:0.02:1],[0:0.02:1],[0:0.02:1]);
    H_res_dummy{i} = dummy(1:nbins,1:nbins,1:nbins)./sampling;
end

H_res = zeros(50,50,50);
for i = 1:N_gauss
    H_res = H_res + A(i).*H_res_dummy{i};
end

%normalize
H_res = (H_res./sum(sum(sum((H_res))))).*sum(sum(sum(H_meas)));

%dev = (H_res-H_meas);
%chi2 = sum(sum(sum((dev.^2))));

dev = (H_res-H_meas)./sqrt(H_meas);
dev(~isfinite(dev))=0;
out = dev(:);
chi2 = sum(sum(sum(dev.^2)))./sum(sum(sum(H_meas~=0)));


%store for plotting
%2D BG BR
tcPDAstruct.plots.H_res_2d = sum(H_res,3);
tcPDAstruct.plots.dev_2d = (tcPDAstruct.H_meas_2d-tcPDAstruct.plots.H_res_2d)./sqrt(tcPDAstruct.H_meas_2d);
tcPDAstruct.plots.dev_2d(~isfinite(tcPDAstruct.plots.dev_2d)) = 0;
tcPDAstruct.plots.H_res_2d_individual = H_res_dummy;
%1D GR
tcPDAstruct.plots.H_res_1d = squeeze(sum(sum(H_res,1),2));
tcPDAstruct.plots.dev_gr = (tcPDAstruct.H_meas_gr-tcPDAstruct.plots.H_res_1d)./sqrt(tcPDAstruct.H_meas_gr);
tcPDAstruct.plots.dev_gr(~isfinite(tcPDAstruct.plots.dev_gr)) = 0;

tcPDAstruct.plots.A_3d = A;
tcPDAstruct.plots.H_res_3d = H_res;
tcPDAstruct.plots.H_res_3d_individual = H_res_dummy;
tcPDAstruct.plots.H_res_3d_bg_br = squeeze(sum(H_res,3));
tcPDAstruct.plots.H_res_3d_bg_gr = squeeze(sum(H_res,2));
tcPDAstruct.plots.H_res_3d_br_gr = squeeze(sum(H_res,1));
tcPDAstruct.plots.H_res_3d_bg = squeeze(sum(sum(H_res,2),3));
tcPDAstruct.plots.H_res_3d_br = squeeze(sum(sum(H_res,1),3));
tcPDAstruct.plots.H_res_3d_gr = squeeze(sum(sum(H_res,1),2));

function plot_after_fit(handles)
global tcPDAstruct
if ~isfield(tcPDAstruct,'plots')
    return;
end
% 1d plot
if isfield(tcPDAstruct.plots,'H_res_gr')
    set(handles.plots.handle_1d_fit,'YData',[tcPDAstruct.plots.H_res_gr;tcPDAstruct.plots.H_res_gr(end)],'XData',tcPDAstruct.x_axis_stair);
    if (size(tcPDAstruct.plots.H_res_1d_individual,2) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_1d_individual,2)
            set(handles.plots.handles_H_res_1d_individual(i),'YData',tcPDAstruct.plots.A_gr(i).*[tcPDAstruct.plots.H_res_1d_individual(:,i);tcPDAstruct.plots.H_res_1d_individual(end,i)],'XData',tcPDAstruct.x_axis_stair);
        end
    end
    set(handles.plots.handle_1d_dev,'YData',[tcPDAstruct.plots.dev_gr;tcPDAstruct.plots.dev_gr(end)],'XData',tcPDAstruct.x_axis_stair);
end

if isfield(tcPDAstruct.plots,'H_res_2d')
    if (size(tcPDAstruct.plots.H_res_2d_individual,3) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_2d_individual,3)
            set(handles.plots.handles_H_res_2d_individual(i),'ZData',tcPDAstruct.plots.A_2d(i).*tcPDAstruct.plots.H_res_2d_individual(:,:,i),'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
        end
    end
    set(handles.plots.handle_2d_fit,'ZData',tcPDAstruct.plots.H_res_2d,'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);

    set(handles.plots.handle_2d_dev,'ZData',tcPDAstruct.plots.dev_2d,'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
    set(handles.axes_2d_res,'zlim',[min(min(tcPDAstruct.plots.dev_2d)) max(max(tcPDAstruct.plots.dev_2d))]);
end

if isfield(tcPDAstruct.plots,'H_res_3d_bg_br')
    if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
            set(handles.plots.handles_H_res_3d_individual_bg_br(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},3)),'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
        end
    end
    set(handles.plots.handle_3d_fit_bg_br,'ZData',tcPDAstruct.plots.H_res_3d_bg_br,'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
    
    if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
            set(handles.plots.handles_H_res_3d_individual_bg_gr(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},2)),'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
        end
    end
    set(handles.plots.handle_3d_fit_bg_gr,'ZData',tcPDAstruct.plots.H_res_3d_bg_gr,'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
    
    if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
            set(handles.plots.handles_H_res_3d_individual_br_gr(i),'ZData',tcPDAstruct.plots.A_3d(i).*squeeze(sum(tcPDAstruct.plots.H_res_3d_individual{i},1)),'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
        end
    end
    set(handles.plots.handle_3d_fit_br_gr,'ZData',tcPDAstruct.plots.H_res_3d_br_gr,'XData',tcPDAstruct.x_axis,'YData',tcPDAstruct.x_axis);
    
    set(handles.plots.handle_3d_fit_bg,'YData',[tcPDAstruct.plots.H_res_3d_bg;tcPDAstruct.plots.H_res_3d_bg(end)],'XData',tcPDAstruct.x_axis_stair);
    if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
            temp = squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},2),3));
            set(handles.plots.handles_H_res_3d_individual_bg(i),'YData',tcPDAstruct.plots.A_3d(i).*[temp;temp(end)],'XData',tcPDAstruct.x_axis_stair);
        end
    end
    
    set(handles.plots.handle_3d_fit_br,'YData',[tcPDAstruct.plots.H_res_3d_br,tcPDAstruct.plots.H_res_3d_br(end)],'XData',tcPDAstruct.x_axis_stair);
    if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
            temp = squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),3));
            set(handles.plots.handles_H_res_3d_individual_br(i),'YData',tcPDAstruct.plots.A_3d(i).*[temp,temp(end)],'XData',tcPDAstruct.x_axis_stair);
        end
    end
    
    set(handles.plots.handle_3d_fit_gr,'YData',[tcPDAstruct.plots.H_res_3d_gr;tcPDAstruct.plots.H_res_3d_gr(end)],'XData',tcPDAstruct.x_axis_stair);
    if (size(tcPDAstruct.plots.H_res_3d_individual,1) > 1)
        for i = 1:size(tcPDAstruct.plots.H_res_3d_individual,1)
            temp = squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),2));
            set(handles.plots.handles_H_res_3d_individual_gr(i),'YData',tcPDAstruct.plots.A_3d(i).*[temp;temp(end)],'XData',tcPDAstruct.x_axis_stair);
        end
    end
end
UpdateAxesLimits(handles);

function [covNew] = fix_covariance_matrix(cov)
%find eigenvalue smaller 0
k = min(eig(cov));
%add to matrix to make positive semi-definite
A = cov - k*eye(size(cov))+1E-6; %add small increment because sometimes eigenvalues are still slightly negative (~-1E-17)

%rescale A to match the standard deviations on the diagonal

%convert to correlation matrix
Acorr = corrcov(A);
%get standard deviations
sigma = sqrt(diag(cov));

covNew = zeros(3,3);
for i = 1:3
    for j = 1:3
        covNew(i,j) = Acorr(i,j)*sigma(i)*sigma(j);
    end
end

function [fitpar_cor] = fix_covariance_matrix_fitpar(fitpar)

N_gauss = numel(fitpar)/10; 
fitpar_cor = fitpar;
%read sigmas
for i = 1:N_gauss
    sigma_Rgr(i) = fitpar((i-1)*10+3);
    sigma_Rbg(i) = fitpar((i-1)*10+5);
    sigma_Rbr(i) = fitpar((i-1)*10+7);
    sigma_Rbg_Rbr(i) = fitpar((i-1)*10+8);
    sigma_Rbg_Rgr(i) = fitpar((i-1)*10+9);
    sigma_Rbr_Rgr(i) = fitpar((i-1)*10+10);
end

for i = 1:N_gauss
    COV =[sigma_Rbg(i).^2, sigma_Rbg_Rbr(i) ,sigma_Rbg_Rgr(i);...
              sigma_Rbg_Rbr(i),sigma_Rbr(i).^2,sigma_Rbr_Rgr(i);...
              sigma_Rbg_Rgr(i),sigma_Rbr_Rgr(i),sigma_Rgr(i).^2];
    while any(eig(COV)< 0)
       [COV] = fix_covariance_matrix(COV);
    end

    %COV = sqrt(COV);
    
    sigma_Rgr(i) = sqrt(COV(3,3));
    sigma_Rbg(i) = sqrt(COV(1,1));
    sigma_Rbr(i) = sqrt(COV(2,2));
    sigma_Rbg_Rbr(i) = COV(1,2);
    sigma_Rbg_Rgr(i) = COV(1,3);
    sigma_Rbr_Rgr(i) = COV(2,3);
    
    fitpar_cor((i-1)*10+3) = sigma_Rgr(i);
    fitpar_cor((i-1)*10+5) = sigma_Rbg(i);
    fitpar_cor((i-1)*10+7) = sigma_Rbr(i);
    fitpar_cor((i-1)*10+8) = sigma_Rbg_Rbr(i);
    fitpar_cor((i-1)*10+9) = sigma_Rbg_Rgr(i);
    fitpar_cor((i-1)*10+10) = sigma_Rbr_Rgr(i);
end

function save_fitstate(handles,obj)
global tcPDAstruct UserValues
switch obj
    case handles.button_save_fitstate
        tcPDAstruct.nbins = UserValues.tcPDA.nbins;
        save(tcPDAstruct.FullFileName,'tcPDAstruct');
    case handles.button_save_fitstate_external
        fit_data = tcPDAstruct.fitdata;
        corrections = handles.corrections_table.Data;
        filename = tcPDAstruct.FullFileName;
        %remove extension
        filename = [filename(1:end-5) 'fitstate'];
        [FileName,PathName] = uiputfile({'*.fitstate','tcPDA fitstate file (*.fitstate)'},'Select filename for fitstate file',filename);
        save(fullfile(PathName,FileName),'fit_data','corrections');
end

function load_fitstate(handles)
global tcPDAstruct UserValues

[FileName, PathName] = uigetfile('*.fitstate', 'select *.fitstate file for analysis', UserValues.tcPDA.PathName, 'MultiSelect', 'off');
if ~isequal(FileName,0)
    UserValues.tcPDA.PathName = PathName;
else
    return;
end
LSUserValues(1);

load('-mat',fullfile(PathName,FileName));

tcPDAstruct.fitdata = fit_data;
if ~isfield(tcPDAstruct.fitdata,'use_prior')
    for i = 1:5
        tcPDAstruct.fitdata.use_prior{i} = false(1,10);
        tcPDAstruct.fitdata.prior_sigma{i} = [0.1,5,0.2,5,0.2,5,0.2,0,0,0];
    end
    tcPDAstruct.fitdata.prior_center = tcPDAstruct.fitdata.param;
end
UpdateFitTable(handles);

if exist('corrections','var') %%% corrections were saved
    handles.corrections_table.Data = corrections;
end

function chi2 = view_curve(handles)
global tcPDAstruct
tcPDAstruct.BrightnessCorrection = handles.Brightness_Correction_Toggle.Value;
tcPDAstruct.sampling = str2double(get(handles.sampling_edit,'String'));
tcPDAstruct.use_stochasticlabeling = handles.checkbox_stochasticlabeling.Value;
tcPDAstruct.fraction_stochasticlabeling = str2double(handles.edit_stochasticlabeling.String);
%read correction table
corrections = get(handles.corrections_table,'data');
[tcPDAstruct.corrections.ct_gr, tcPDAstruct.corrections.ct_bg, tcPDAstruct.corrections.ct_br,...
    tcPDAstruct.corrections.de_gr, tcPDAstruct.corrections.de_bg, tcPDAstruct.corrections.de_br,...
    tcPDAstruct.corrections.gamma_gr, tcPDAstruct.corrections.gamma_br,...
    tcPDAstruct.corrections.BG_bb, tcPDAstruct.corrections.BG_bg, tcPDAstruct.corrections.BG_br,...
    tcPDAstruct.corrections.BG_gg, tcPDAstruct.corrections.BG_gr,...
    tcPDAstruct.corrections.R0_gr, tcPDAstruct.corrections.R0_bg, tcPDAstruct.corrections.R0_br] = deal(corrections{:});

[tcPDAstruct.valid] = Cut_Data([],[]);

%read initial fit values
fit_data = get(handles.fit_table,'data');
n_gauss = get(handles.popupmenu_ngauss,'value');
for i = 1:n_gauss%number of species
   tcPDAstruct.fitdata.param{i} = cell2mat(fit_data((i-1)*11+1:(i-1)*11+10,2));
end
%get the selected tab
selected_tab = handles.tabgroup.SelectedTab;
%tcPDAstruct.selected_tab = selected_tab;
switch (selected_tab)
    case handles.tab_1d %only a 1D fit
        %create input data
        fitpar = [];
        for i = 1:n_gauss
            fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(1:3)];
        end
        
        chi2 =  determine_chi2_1C_mc_cor(fitpar);
    case handles.tab_2d %2d fit
        %create input data
        fitpar = [];
        for i = 1:n_gauss
            fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(1:7)];
        end
        
        chi2 = determine_chi2_2C_mc_dist_cor(fitpar);  
    case handles.tab_3d %full 3d fit
        %create input data
        fitpar = [];
        
        %covariance matrix read in as well!
        for i = 1:n_gauss
            fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(:)];
        end
        
        %fix covariance matrix before fitting
        fitpar = fix_covariance_matrix_fitpar(fitpar);
        
        chi2 = determine_chi2_mc_dist_3d_cor(fitpar);
end
if isfield(tcPDAstruct,'plots')
    handles.text_chi2.String = sprintf('Chi2 = %.2f',tcPDAstruct.plots.chi2);
end
plot_after_fit(handles);

function pushbutton_view_curve(hObject,eventdata)
global tcPDAstruct
handles = guidata(hObject);
if ~isfield(tcPDAstruct,'NBB')
    return;
end
chi2 = view_curve(handles);

disp(['Chi2 = ' num2str(tcPDAstruct.plots.chi2)]);

function pushbutton_load_fitstate(hObject,eventdata)
handles = guidata(hObject);
load_fitstate(handles);

function pushbutton_save_fitstate(hObject,eventdata)
global tcPDAstruct
if ~isfield(tcPDAstruct,'FullFileName')
    return;
end
handles = guidata(hObject);
save_fitstate(handles,hObject);

function pushbutton_export_figure(hObject,eventdata)
handles = guidata(hObject);
export_figure(handles);

function export_figure(handles)
global tcPDAstruct
if ~isfield(tcPDAstruct,'H_meas')
    return;
end
h=figure('Position',[200 375 1000 600],'Color',[1 1 1],'Units','pixels','Tag','Export_tcPDA');
ha = tight_subplot_tab(2,3,[0.1 0.05],[0.08,0.05],[0.05,0.05],h);
plot4d_export(tcPDAstruct.H_meas,ha);

plot_results(handles)

function plot4d_export(input,ha)
%plots three 2D and three 1D projections of 3 dimensional data array
global tcPDAstruct
handles = guidata(gcbo);
n_gauss = numel(tcPDAstruct.plots.H_res_3d_individual);

x_axis = tcPDAstruct.x_axis;
x_axis_stairs = [x_axis - (x_axis(2)-x_axis(1))/2 1];
fontsize_label = 14;
fontsize_ticks = 12;
axes_bg_color = [1 1 1];

if ismac
    fontsize_label = 1.25*fontsize_label;
    fontsize_ticks = 1.25*fontsize_ticks;
end

w_res_limits = [-3 3];
axes(ha(1));
%%% calculate w_res
data = squeeze(sum(input,3));
fit = tcPDAstruct.plots.H_res_3d_bg_br;
error = sqrt(data); error(error==0) = 1;
w_res = (data-fit)./error;
surf(x_axis,x_axis,squeeze(sum(input,3)),w_res,'EdgeColor',[0,0,0],'FaceAlpha',0.6,'LineWidth',0.5);
caxis(w_res_limits); 
colormap(handles.colormap);
xlim([0 1]);
ylim([0 1]);
zlim([0 max([max(max(squeeze(sum(input,3))))])]);
x=xlabel('PR_{BR}','FontSize',fontsize_label);
y=ylabel('PR_{BG}','FontSize',fontsize_label);
x.Position = [0.5,-0.3,0];
y.Position = [-0.15,0.5,0];
set(gca,'Color',[0.5 0.5 0.5]);
set(gca,'FontSize',fontsize_ticks);
set(gca,'View',[-45,25]);
hold on;
%surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_bg_br,'FaceColor','none','EdgeColor','k');
hold off;
set(gca,'Color',axes_bg_color);
set(gca,'Box','on');
zlabel('counts','FontSize',fontsize_label/1.2);

axes(ha(2));
data = squeeze(sum(input,2));
fit = tcPDAstruct.plots.H_res_3d_bg_gr;
error = sqrt(data); error(error==0) = 1;
w_res = (data-fit)./error;
surf(x_axis,x_axis,squeeze(sum(input,2)),w_res,'EdgeColor',[0,0,0],'FaceAlpha',0.6,'LineWidth',0.5);
caxis(w_res_limits); 
colormap(handles.colormap);
xlim([0 1]);
ylim([0 1]);
zlim([0 max([max(max(squeeze(sum(input,2))))])]);
x=xlabel('PR_{GR}','FontSize',fontsize_label);
y=ylabel('PR_{BG}','FontSize',fontsize_label);
x.Position = [0.5,-0.3,0];
y.Position = [-0.15,0.5,0];
set(gca,'Color',[0.5 0.5 0.5]);
set(gca,'FontSize',fontsize_ticks);
set(gca,'View',[-45,25]);
hold on;
%surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_bg_gr,'FaceColor','none','EdgeColor',[0 0 0]);
hold off;
set(gca,'Color',axes_bg_color);
set(gca,'Box','on');

axes(ha(3));
data = squeeze(sum(input,1));
fit = tcPDAstruct.plots.H_res_3d_br_gr;
error = sqrt(data); error(error==0) = 1;
w_res = (data-fit)./error;
surf(x_axis,x_axis,squeeze(sum(input,1)),w_res,'EdgeColor',[0,0,0],'FaceAlpha',0.6,'LineWidth',0.5);
caxis(w_res_limits); 
colormap(handles.colormap);
xlim([0 1]);
ylim([0 1]);
zlim([0 max([max(max(squeeze(sum(input,1))))])]);
x=xlabel('PR_{GR}','FontSize',fontsize_label);
y=ylabel('PR_{BR}','FontSize',fontsize_label);
x.Position = [0.5,-0.3,0];
y.Position = [-0.15,0.5,0];
set(gca,'Color',[0.5 0.5 0.5]);
set(gca,'FontSize',fontsize_ticks);
set(gca,'View',[-45,25]);
hold on;
%surf(tcPDAstruct.x_axis,tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_br_gr,'FaceColor','none','EdgeColor',[0 0 0]);
hold off;
set(gca,'Color',axes_bg_color);
set(gca,'Box','on');

cbar = colorbar('Position',[0.97 , 0.6,0.01,0.3]);
htext = text(1.06,0.955,'w_{res}','Units','normalized','FontSize',fontsize_label);

%color = {[0 180 0]/255 [220 0 0 ]/255 'b' 'c' 'm'};
color = lines(n_gauss);
color = mat2cell(color,ones(size(color,1),1),size(color,2));

axes(ha(4));
set(gca,'Color','w');
bar(x_axis,squeeze(sum(sum(input,2),3)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
xlim([0 1]);
ylim([0,max(squeeze(sum(sum(input,2),3)))*1.05]);
xlabel('PR_{BG}','FontSize',fontsize_label);
set(gca,'FontSize',fontsize_ticks);
hold on;
%bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_bg,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
if n_gauss > 1
    for i = 1:n_gauss
        data = tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},2),3));
        data(end+1) = data(end);
        stairs(x_axis_stairs,data,'Color',color{i},'LineWidth',2);
    end
end
data = tcPDAstruct.plots.H_res_3d_bg;
data(end+1) = data(end);
stairs(x_axis_stairs,data,'Color','k','LineWidth',2);
hold off;
set(gca,'Box','on');
ax = gca;
ax.Position(4) = ax.Position(4)-0.05;
%%% add w_res axis
ax_wres(1) = axes('Units','normalized','FontSize',fontsize_ticks,'Color','w',...
    'Position',[ax.Position(1)    ax.Position(2)+ax.Position(4)    ax.Position(3)    0.0500]);
linkaxes([ax,ax_wres(1)],'x');
data = squeeze(sum(sum(input,2),3));
fit = tcPDAstruct.plots.H_res_3d_bg;
error = sqrt(data); error(error==0) = 1;
w_res = (data-fit)./error; w_res(end+1) = w_res(end);
stairs(ax_wres(1),x_axis_stairs,w_res,'k','LineWidth',2);
%ax_wres(1).Position = [ax.Position(1)    ax.Position(2)+ax.Position(4)    ax.Position(3)    0.0500];
ax_wres(1).XTickLabel = [];
%yticks = get(ax,'YTick');
%set(ax,'YTick',yticks(1:end-1));
ylabel(ax_wres(1),'w_{res}','FontSize',fontsize_label);
ax_wres(1).YGrid = 'on';
ax_wres(1).FontSize = fontsize_ticks;
ax_wres(1).Color = axes_bg_color;
ax.Color = axes_bg_color;
ylabel(ax,'counts','FontSize',fontsize_label/1.2);
ax.Layer = 'top';
ax.XTick = [0,0.25,0.5,0.75,1];

axes(ha(5));
bar(x_axis,squeeze(sum(sum(input,1),3)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
xlim([0 1]);
ylim([0,max(squeeze(sum(sum(input,1),3)))*1.05]);
xlabel('PR_{BR}','FontSize',fontsize_label);
set(gca,'FontSize',fontsize_ticks);
hold on;
%bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_br,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
if n_gauss > 1
    for i = 1:n_gauss
        data = tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),3));
        data(end+1) = data(end);
        stairs(x_axis_stairs,data,'Color',color{i},'LineWidth',2);
    end
end
data = tcPDAstruct.plots.H_res_3d_br;
data(end+1) = data(end);
stairs(x_axis_stairs,data,'Color','k','LineWidth',2);
hold off;
set(gca,'Box','on');
ax = gca;
ax.Position(4) = ax.Position(4)-0.05;
%%% add w_res axis
ax_wres(2) = axes('Units','normalized','FontSize',fontsize_ticks,'Color','w',...
    'Position',[ax.Position(1)    ax.Position(2)+ax.Position(4)    ax.Position(3)    0.0500]);
linkaxes([ax,ax_wres(2)],'x');
data = squeeze(sum(sum(input,1),3));
fit = tcPDAstruct.plots.H_res_3d_br;
error = sqrt(data); error(error==0) = 1;
w_res = (data-fit)./error; w_res(end+1) = w_res(end);
stairs(ax_wres(2),x_axis_stairs,w_res,'k','LineWidth',2);
%ax_wres(1).Position = [ax.Position(1)    ax.Position(2)+ax.Position(4)    ax.Position(3)    0.0500];
ax_wres(2).XTickLabel = [];
%yticks = get(ax,'YTick');
%set(ax,'YTick',yticks(1:end-1));
%ylabel(ax_wres(2),'w_{res}','FontSize',fontsize_label);
ax_wres(2).YGrid = 'on';
ax_wres(2).FontSize = fontsize_ticks;
ax_wres(2).Color = axes_bg_color;
ax.Color = axes_bg_color;
ax.Layer = 'top';
ax.XTick = [0,0.25,0.5,0.75,1];

axes(ha(6));
bar(x_axis,squeeze(sum(sum(input,1),2)),'BarWidth',1,'FaceColor',[0.5 0.5 0.5],'EdgeColor','none');
xlim([0 1]);
ylim([0,max(squeeze(sum(sum(input,1),2)))*1.05]);
xlabel('PR_{GR}','FontSize',fontsize_label);
set(gca,'FontSize',fontsize_ticks);    
hold on;
%bar(tcPDAstruct.x_axis,tcPDAstruct.plots.H_res_3d_gr,'BarWidth',1,'EdgeColor','k','LineWidth',2,'FaceColor','none');
if n_gauss > 1  
    for i = 1:n_gauss
        data = tcPDAstruct.plots.A_3d(i).*squeeze(sum(sum(tcPDAstruct.plots.H_res_3d_individual{i},1),2));
        data(end+1) = data(end);
        stairs(x_axis_stairs,data,'Color',color{i},'LineWidth',2);
    end
end
data = tcPDAstruct.plots.H_res_3d_gr;
data(end+1) = data(end);
stairs(x_axis_stairs,data,'Color','k','LineWidth',2);
hold off;
set(gca,'Box','on');
ax = gca;
ax.Position(4) = ax.Position(4)-0.05;
%%% add w_res axis
ax_wres(3) = axes('Units','normalized','FontSize',fontsize_ticks,'Color','w',...
    'Position',[ax.Position(1)    ax.Position(2)+ax.Position(4)    ax.Position(3)    0.0500]);
linkaxes([ax,ax_wres(3)],'x');
data = squeeze(sum(sum(input,1),2));
fit = tcPDAstruct.plots.H_res_3d_gr;
error = sqrt(data); error(error==0) = 1;
w_res = (data-fit)./error; w_res(end+1) = w_res(end);
stairs(ax_wres(3),x_axis_stairs,w_res,'k','LineWidth',2);
%ax_wres(1).Position = [ax.Position(1)    ax.Position(2)+ax.Position(4)    ax.Position(3)    0.0500];
ax_wres(3).XTickLabel = [];
%yticks = get(ax,'YTick');
%set(ax,'YTick',yticks(1:end-1));
%ylabel(ax_wres(3),'w_{res}','FontSize',fontsize_label);
ax_wres(3).YGrid = 'on';
ax_wres(3).FontSize = fontsize_ticks;
ax_wres(3).Color = axes_bg_color;
ax.Color = axes_bg_color;
ax.Layer = 'top';
ax.XTick = [0,0.25,0.5,0.75,1];

for i = 4:numel(ha)
    set(ha(i),'Color',[1 1 1]);
end

child = get(gcf,'Children');
for i =1:numel(child)
    if isprop(child(i),'LineWidth')
        child(i).LineWidth = 2;
    end
end
cbar.LineWidth = 1;
for i = 1:numel(child)
    if ~any(strcmp(child(i).Type,{'uicontextmenu','uimenu','uitoolbar'}))
        child(i).Position(1) = child(i).Position(1)+0.02;
        child(i).Position(2) = child(i).Position(2)+0.03;
        child(i).Position(3) = child(i).Position(3)*0.9;
    end
end
cbar.Position(1) = cbar.Position(1)-0.025;
cbar.Position(3) = cbar.Position(3)/0.9;
cbar.Position(3) = 0.015;
htext.Position(1) = htext.Position(1)-0.02;
htext.Position(3) = htext.Position(3)/0.9;

htext.Units = 'pixels';
%%% set all units to pixels!
fig = gcf;
fig.Units = 'pixels';
for i = 1:numel(fig.Children)
    if isprop(fig.Children(i),'Units')
        fig.Children(i).Units = 'pixels';
    end
end
drawnow;

function plot_results(handles)
global tcPDAstruct
h=figure('Position',[200 25 1100 350],'Color',[1 1 1]);
ha = tight_subplot_tab(1,3,[0.05 0.08],[0.2,0.05],[0.08,0.03],h);
for i = 1:numel(ha)
    set(ha(i),'XGrid','on');
    set(ha(i),'YGrid','on');
end
n_gauss = get(handles.popupmenu_ngauss,'Value');

%read parameters of distributions
for i=1:n_gauss
    MU{i} = tcPDAstruct.fitdata.param{i}([4 6 2])';
    COV{i} = [tcPDAstruct.fitdata.param{i}(5).^2 tcPDAstruct.fitdata.param{i}(8) tcPDAstruct.fitdata.param{i}(9);...
                tcPDAstruct.fitdata.param{i}(8) tcPDAstruct.fitdata.param{i}(7).^2 tcPDAstruct.fitdata.param{i}(10);...
                tcPDAstruct.fitdata.param{i}(9) tcPDAstruct.fitdata.param{i}(10) tcPDAstruct.fitdata.param{i}(3).^2];
%     COV{i} = [tcPDAstruct.fitdata.param{i}(5) 0 0 ;...
%                 0 tcPDAstruct.fitdata.param{i}(7) 0;...
%                0 0  tcPDAstruct.fitdata.param{i}(3)].^2;
            
    A(i) = tcPDAstruct.fitdata.param{i}(1);
end
A = A./sum(A);

%%% find maximum value to consider for each dimension
m = vertcat(MU{:})';
for i = 1:n_gauss
    sig(:,i) = [sqrt(COV{i}(1,1));sqrt(COV{i}(2,2));sqrt(COV{i}(3,3))];
end

maxR = m + 3*sig;
minR = m - 3*sig;
maxR = max(maxR,[],2);
minR = min(minR,[],2);

global_boundaries = 0;
if global_boundaries %%% use same limits for all axes
    maxR(:) = max(maxR);
    minR(:) = min(minR);
end

spacing = 100;
gridX = linspace(minR(1),maxR(1),spacing); gridY = linspace(minR(2),maxR(2),spacing); gridZ = linspace(minR(3),maxR(3),spacing);
[X, Y, Z] = meshgrid(gridX,gridY,gridZ);
x = [X(:) Y(:) Z(:)];

PDF = zeros(size(x,1),1);
for i = 1:n_gauss
    %C = COV{i};
    %C(C<1) = 1;
    p_dummy = mvnpdf(x,MU{i},COV{i});
    p_dummy = p_dummy./sum(p_dummy(:));
    PDF = PDF + A(i).*p_dummy;
    P_ind{i} = p_dummy;
end

PDF = reshape(PDF,numel(gridY), numel(gridX), numel(gridZ)); PDF = PDF./sum(PDF(:));
for i = 1:n_gauss
    P_ind{i} = reshape(P_ind{i},numel(gridY), numel(gridX), numel(gridZ)); P_ind{i} = P_ind{i}./sum(P_ind{i}(:));
end
%%% calculate covariance matrix (order is BR|BG|GR, so X = BG, Y = BR, Z = GR) 
P = PDF(:); X = X(:); Y = Y(:); Z = Z(:);
muX = sum(P.*X); muY = sum(P.*Y); muZ = sum(P.*Z);
VarX = sum(P.*((X-muX).^2)); VarY = sum(P.*((Y-muY).^2)); VarZ = sum(P.*((Z-muZ).^2));
covXY = sum(P.*(X-muX).*(Y-muY));
covXZ = sum(P.*(X-muX).*(Z-muZ));
covYZ = sum(P.*(Y-muY).*(Z-muZ));
corXY = covXY./sqrt(VarX*VarY);
corXZ = covXZ./sqrt(VarX*VarZ);
corYZ = covYZ./sqrt(VarY*VarZ);

fontsize_label = 15;
fontsize_ticks = 15;
IsoLineHeight = 0.32;
color = lines(n_gauss);
color = mat2cell(color,ones(size(color,1),1),size(color,2));
disp('Correlation coefficients: ');

axes(ha(1));
x_axis = gridX-min(diff(gridX))/2;
y_axis = gridY-min(diff(gridY))/2;
textpos = [0.5*(x_axis(end)-x_axis(1))+x_axis(1),0.925*(y_axis(end)-y_axis(1))+y_axis(1)];
contourf(x_axis,y_axis,squeeze(sum(PDF,3)),100,'EdgeColor','none');
xlabel('R_{BG}','FontSize',fontsize_label);
ylabel('R_{BR}','FontSize',fontsize_label);
set(gca,'FontSize',fontsize_ticks);
view([0 90]);
text(textpos(1),textpos(2),['\rho_{BG/BR} = ' sprintf('%.2f',corXY)],'Color',[0 0 0],'FontSize',fontsize_label);
disp(sprintf('BG/BR:\t%.4f',corXY));
%%% add contour plots for individual populations
hold on;
for i = 1:n_gauss
    pi = squeeze(sum(P_ind{i},3));
    contour(x_axis,y_axis,A(i)*pi,A(i)*[max(pi(:))*IsoLineHeight,max(pi(:))*IsoLineHeight],'LineColor',color{i},'LineWidth',2);
end
pp = squeeze(sum(PDF,3)); set(ha(1),'CLim',[0,max(pp(:))]);

axes(ha(2));
x_axis = gridZ-min(diff(gridZ))/2;
y_axis = gridX-min(diff(gridX))/2;
textpos = [0.5*(x_axis(end)-x_axis(1))+x_axis(1),0.925*(y_axis(end)-y_axis(1))+y_axis(1)];
contourf(x_axis,y_axis,squeeze(sum(PDF,1)),100,'EdgeColor','none');
xlabel('R_{GR}','FontSize',fontsize_label);
ylabel('R_{BG}','FontSize',fontsize_label);
set(gca,'FontSize',fontsize_ticks);
view([0 90]);
text(textpos(1),textpos(2),['\rho_{GR/BG} = ' sprintf('%.2f',corXZ)],'Color',[0 0 0],'FontSize',fontsize_label);
disp(sprintf('GR/BG:\t%.4f',corXZ));
%%% add contour plots for individual populations
hold on;
for i = 1:n_gauss
    pi = squeeze(sum(P_ind{i},1));
    contour(x_axis,y_axis,A(i)*pi,A(i)*[max(pi(:))*IsoLineHeight,max(pi(:))*IsoLineHeight],'LineColor',color{i},'LineWidth',2);
end
pp = squeeze(sum(PDF,1)); set(ha(2),'CLim',[0,max(pp(:))]);


axes(ha(3));
x_axis = gridZ-min(diff(gridZ))/2;
y_axis = gridY-min(diff(gridY))/2;
textpos = [0.5*(x_axis(end)-x_axis(1))+x_axis(1),0.925*(y_axis(end)-y_axis(1))+y_axis(1)];
contourf(x_axis,y_axis,squeeze(sum(PDF,2)),100,'EdgeColor','none');
xlabel('R_{GR}','FontSize',fontsize_label);
ylabel('R_{BR}','FontSize',fontsize_label);
set(gca,'FontSize',fontsize_ticks);
view([0 90]);
text(textpos(1),textpos(2),['\rho_{GR/BR} = ' sprintf('%.2f',corYZ)],'Color',[0 0 0],'FontSize',fontsize_label);
disp(sprintf('GR/BR:\t%.4f',corYZ));
%%% add contour plots for individual populations
hold on;
for i = 1:n_gauss
    pi = squeeze(sum(P_ind{i},2));
    contour(x_axis,y_axis,A(i)*pi,A(i)*[max(pi(:))*IsoLineHeight,max(pi(:))*IsoLineHeight],'LineColor',color{i},'LineWidth',2);
end
pp = squeeze(sum(PDF,2)); set(ha(3),'CLim',[0,max(pp(:))]);


%colormap(1 - colormap(gray));
colormap(jetvar);
for i = 1:numel(ha)
    set(ha(i),'Layer','top','Box','on');
end

function ha = tight_subplot_tab(Nh, Nw, gap, marg_h, marg_w,parent)

% tight_subplot creates "subplot" axes with adjustable gaps and margins
%
% ha = tight_subplot(Nh, Nw, gap, marg_h, marg_w)
%
%   in:  Nh      number of axes in hight (vertical direction)
%        Nw      number of axes in width (horizontaldirection)
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins 
%
%  out:  ha     array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   going row-wise as in
%
%  Example: ha = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Pekka Kumpulainen 20.6.2010   @tut.fi
% Tampere University of Technology / Automation Science and Engineering


if nargin<3; gap = .02; end
if nargin<4 || isempty(marg_h); marg_h = .05; end
if nargin<5; marg_w = .05; end

if numel(gap)==1; 
    gap = [gap gap];
end
if numel(marg_w)==1; 
    marg_w = [marg_w marg_w];
end
if numel(marg_h)==1; 
    marg_h = [marg_h marg_h];
end

axh = (1-sum(marg_h)-(Nh-1)*gap(1))/Nh; 
axw = (1-sum(marg_w)-(Nw-1)*gap(2))/Nw;

py = 1-marg_h(2)-axh; 

ha = zeros(Nh*Nw,1);
ii = 0;
for ih = 1:Nh
    px = marg_w(1);
    
    for ix = 1:Nw
        ii = ii+1;
        ha(ii) = handle(axes('Units','normalized', ...
            'Position',[px py axw axh], ...
            'nextplot','add',...
            'Parent',parent));
        px = px+axw+gap(2);
    end
    py = py-axh-gap(1);
end

function [count edges mid loc] = histcn(X, varargin)
% function [count edges mid loc] = histcn(X, edge1, edge2, ..., edgeN)
%
% Purpose: compute n-dimensional histogram
%
% INPUT
%   - X: is (M x N) array, represents M data points in R^N
%   - edgek: are the bin vectors on dimension k, k=1...N.
%     If it is a scalar (Nk), the bins will be the linear subdivision of
%     the data on the range [min(X(:,k)), max(X(:,k))] into Nk
%     sub-intervals
%     If it's empty, a default of 32 subdivions will be used
%
% OUTPUT
%   - count: n-dimensional array count of X on the bins, i.e.,
%         count(i1,i2,...,iN) = cardinal of X such that
%                  edge1(i1) <= X(:,i1) < edge1(i1)+1 and
%                       ...
%                  edgeN(iN) <= X(:,iN) < edgeN(iN)+1
%   - edges: (1 x N) cell, each provides the effective edges used in the
%     respective dimension
%   - mid: (1 x N) cell, provides the mid points of the cellpatch used in
%     the respective dimension
%   - loc: (M x N) array, index location of X in the bins. Points have out
%     of range coordinates will have zero at the corresponding dimension.
%
% DATA ACCUMULATE SYNTAX:
%   [ ... ] = histcn(..., 'AccumData', VAL);
%   where VAL is M x 1 array. Each VAL(k) corresponds to position X(k,:)
%   will be accumulated in the cell containing X. The accumulate result
%   is returned in COUNT.
%   NOTE: Calling without 'AccumData' is similar to having VAL = ones(M,1)
%
%   [ ... ] = histcn(..., 'AccumData', VAL, 'FUN', FUN);
%     applies the function FUN to each subset of elements of VAL.  FUN is
%     a function that accepts a column vector and returns
%     a numeric, logical, or char scalar, or a scalar cell.  A has the same class
%     as the values returned by FUN.  FUN is @SUM by default.  Specify FUN as []
%     for the default behavior.
%
% Usage examples:
%   M = 1e5;
%   N = 3;
%   X = randn(M,N);
%   [N edges mid loc] = histcn(X);
%   imagesc(mid{1:2},N(:,:,ceil(end/2)))
%
% % Compute the mean on rectangular patch from scattered data
%   DataSize = 1e5;
%   Lat = rand(1,DataSize)*180;
%   Lon = rand(1,DataSize)*360;
%   Data = randn(1,DataSize);
%   lat_edge = 0:1:180;
%   lon_edge = 0:1:360;
%   meanData = histcn([Lat(:) Lon(:)], lat_edge, lon_edge, 'AccumData', Data, 'Fun', @mean);
%
% See also: HIST, ACCUMARRAY
% 
% Bruno Luong: <brunoluong@yahoo.com>
% Last update: 25/August/2011

if ndims(X)>2
    error('histcn: X requires to be an (M x N) array of M points in R^N');
end
DEFAULT_NBINS = 32;

AccumData = [];
Fun = {};

% Looks for where optional parameters start
% For now only 'AccumData' is valid
split = find(cellfun('isclass', varargin, 'char'), 1, 'first');
if ~isempty(split)
    for k = split:2:length(varargin)
        if strcmpi(varargin{k},'AccumData')
            AccumData = varargin{k+1}(:);
        elseif strcmpi(varargin{k},'Fun')
            Fun = varargin(k+1); % 1x1 cell
        end
    end
    varargin = varargin(1:split-1);
end

% Get the dimension
nd = size(X,2);
edges = varargin;
if nd<length(edges)
    nd = length(edges); % wasting CPU time warranty
else
    edges(end+1:nd) = {DEFAULT_NBINS};
end

% Allocation of array loc: index location of X in the bins
loc = zeros(size(X));
sz = zeros(1,nd);
% Loop in the dimension
for d=1:nd
    ed = edges{d};
    Xd = X(:,d);
    if isempty(ed)
        ed = DEFAULT_NBINS;
    end
    if isscalar(ed) % automatic linear subdivision
        ed = linspace(min(Xd),max(Xd),ed+1);
    end
    edges{d} = ed;
    % Call histc on this dimension
    [dummy loc(:,d)] = histc(Xd, ed, 1);
    % Use sz(d) = length(ed); to create consistent number of bins
    sz(d) = length(ed)-1;
end % for-loop

% Clean
clear dummy

% This is need for seldome points that hit the right border
sz = max([sz; max(loc,[],1)]);

% Compute the mid points
mid = cellfun(@(e) 0.5*(e(1:end-1)+e(2:end)), edges, ...
              'UniformOutput', false);
          
% Count for points where all coordinates are falling in a corresponding
% bins
if nd==1
    sz = [sz 1]; % Matlab doesn't know what is one-dimensional array!
end

hasdata = all(loc>0, 2);
if ~isempty(AccumData)
    count = accumarray(loc(hasdata,:), AccumData(hasdata), sz, Fun{:});
else
    count = accumarray(loc(hasdata,:), 1, sz);
end

return

function [Hout Xbins Ybins] = hist2d(D, varargin) %Xn, Yn, Xrange, Yrange)
%HIST2D 2D histogram
%
% [H XBINS YBINS] = HIST2D(D, XN, YN, [XLO XHI], [YLO YHI])
% [H XBINS YBINS] = HIST2D(D, 'display' ...)
%
% HIST2D calculates a 2-dimensional histogram and returns the histogram
% array and (optionally) the bins used to calculate the histogram.
%
% Inputs:
%     D:         N x 2 real array containing N data points or N x 1 array 
%                 of N complex values 
%     XN:        number of bins in the x dimension (defaults to 200)
%     YN:        number of bins in the y dimension (defaults to 200)
%     [XLO XHI]: range for the bins in the x dimension (defaults to the 
%                 minimum and maximum of the data points)
%     [YLO YHI]: range for the bins in the y dimension (defaults to the 
%                 minimum and maximum of the data points)
%     'display': displays the 2D histogram as a surf plot in the current
%                 axes
%
% Outputs:
%     H:         2D histogram array (rows represent X, columns represent Y)
%     XBINS:     the X bin edges (see below)
%     YBINS:     the Y bin edges (see below)
%       
% As with histc, h(i,j) is the number of data points (dx,dy) where 
% x(i) <= dx < x(i+1) and y(j) <= dx < y(j+1). The last x bin counts 
% values where dx exactly equals the last x bin value, and the last y bin 
% counts values where dy exactly equals the last y bin value.
%
% If D is a complex array, HIST2D splits the complex numbers into real (x) 
% and imaginary (y) components.
%
% Created by Amanda Ng on 5 December 2008

% Modification history
%   25 March 2009 - fixed error when min and max of ranges are equal.
%   22 November 2009 - added display option; modified code to handle 1 bin

    % PROCESS INPUT D
    if nargin < 1 %check D is specified
        error 'Input D not specified'
    end
    
    Dcomplex = false;
    if ~isreal(D) %if D is complex ...
        if isvector(D) %if D is a vector, split into real and imaginary
            D=[real(D(:)) imag(D(:))];
        else %throw error
            error 'D must be either a complex vector or nx2 real array'
        end
        Dcomplex = true;
    end

    if (size(D,1)<size(D,2) && size(D,1)>1)
        D=D';
    end
    
    if size(D,2)~=2;
        error('The input data matrix must have 2 rows or 2 columns');
    end
    
    % PROCESS OTHER INPUTS
    var = varargin;

    % check if DISPLAY is specified
    index = find(strcmpi(var,'display'));
    if ~isempty(index)
        display = true;
        var(index) = [];
    else
        display = false;
    end

    % process number of bins    
    Xn = 200; %default
    Xndefault = true;
    if numel(var)>=1 && ~isempty(var{1}) % Xn is specified
        if ~isscalar(var{1})
            error 'Xn must be scalar'
        elseif var{1}<1 || mod(var{1},1)
            error 'Xn must be an integer greater than or equal to 1'
        else
            Xn = var{1};
            Xndefault = false;
        end
    end

    Yn = 200; %default
    Yndefault = true;
    if numel(var)>=2 && ~isempty(var{2}) % Yn is specified
        if ~isscalar(var{2})
            error 'Yn must be scalar'
        elseif var{2}<1 || mod(var{2},1)
            error 'Xn must be an integer greater than or equal to 1'
        else
            Yn = var{2};
            Yndefault = false;
        end
    end
    
    % process ranges
    if numel(var) < 3 || isempty(var{3}) %if XRange not specified
        Xrange=[min(D(:,1)),max(D(:,1))]; %default
    else
        if nnz(size(var{3})==[1 2]) ~= 2 %check is 1x2 array
            error 'XRange must be 1x2 array'
        end
        Xrange = var{3};
    end
    if Xrange(1)==Xrange(2) %handle case where XLO==XHI
        if Xndefault
            Xn = 1;
        else
            Xrange(1) = Xrange(1) - floor(Xn/2);
            Xrange(2) = Xrange(2) + floor((Xn-1)/2);
        end
    end
    
    if numel(var) < 4 || isempty(var{4}) %if XRange not specified
        Yrange=[min(D(:,2)),max(D(:,2))]; %default
    else
        if nnz(size(var{4})==[1 2]) ~= 2 %check is 1x2 array
            error 'YRange must be 1x2 array'
        end
        Yrange = var{4};
    end
    if Yrange(1)==Yrange(2) %handle case where YLO==YHI
        if Yndefault
            Yn = 1;
        else
            Yrange(1) = Yrange(1) - floor(Yn/2);
            Yrange(2) = Yrange(2) + floor((Yn-1)/2);
        end
    end
        
    % SET UP BINS
    Xlo = Xrange(1) ; Xhi = Xrange(2) ;
    Ylo = Yrange(1) ; Yhi = Yrange(2) ;
    if Xn == 1
        XnIs1 = true;
        Xbins = [Xlo Inf];
        Xn = 2;
    else
        XnIs1 = false;
        Xbins = linspace(Xlo,Xhi,Xn) ;
    end
    if Yn == 1
        YnIs1 = true;
        Ybins = [Ylo Inf];
        Yn = 2;
    else
        YnIs1 = false;
        Ybins = linspace(Ylo,Yhi,Yn) ;
    end
    
    Z = linspace(1, Xn+(1-1/(Yn+1)), Xn*Yn);
    
    % split data
    Dx = floor((D(:,1)-Xlo)/(Xhi-Xlo)*(Xn-1))+1;
    Dy = floor((D(:,2)-Ylo)/(Yhi-Ylo)*(Yn-1))+1;
    Dz = Dx + Dy/(Yn) ;
    
    % calculate histogram
    h = reshape(histc(Dz, Z), Yn, Xn);
    
    if nargout >=1
        Hout = h;
    end
    
    if XnIs1
        Xn = 1;
        Xbins = Xbins(1);
        h = sum(h,1);
    end
    if YnIs1
        Yn = 1;
        Ybins = Ybins(1);
        h = sum(h,2);
    end
    
    % DISPLAY IF REQUESTED
    if ~display
        return
    end
        
    [x y] = meshgrid(Xbins,Ybins);
    dispH = h;

    % handle cases when Xn or Yn
    if Xn==1
        dispH = padarray(dispH,[1 0], 'pre');
        x = [x x];
        y = [y y];
    end
    if Yn==1
        dispH = padarray(dispH, [0 1], 'pre');
        x = [x;x];
        y = [y;y];
    end

    surf(x,y,dispH);
    colormap(jet);
    if Dcomplex
        xlabel real;
        ylabel imaginary;
    else
        xlabel x;
        ylabel y;
    end
    
%%%% Draw Samples from posterior
function mcmc_draw_samples(~,~)
global tcPDAstruct
if ~isfield(tcPDAstruct,'NBB')
    return
end
handles = guidata(findobj('Tag','tcPDA'));
handles.draw_samples_button.Enable = 'off';
tcPDAstruct.BrightnessCorrection = handles.Brightness_Correction_Toggle.Value;
tcPDAstruct.use_stochasticlabeling = handles.checkbox_stochasticlabeling.Value;
tcPDAstruct.fraction_stochasticlabeling = str2double(handles.edit_stochasticlabeling.String);
mcmc_method = handles.mcmc_method.Value;
n_samples = str2double(handles.n_samples_edit.String);

%read initial fit values
fit_data = get(handles.fit_table,'data');
n_gauss = get(handles.popupmenu_ngauss,'value');

corrections = get(handles.corrections_table,'data');
[tcPDAstruct.corrections.ct_gr, tcPDAstruct.corrections.ct_bg, tcPDAstruct.corrections.ct_br,...
    tcPDAstruct.corrections.de_gr, tcPDAstruct.corrections.de_bg, tcPDAstruct.corrections.de_br,...
    tcPDAstruct.corrections.gamma_gr, tcPDAstruct.corrections.gamma_br,...
    tcPDAstruct.corrections.BG_bb, tcPDAstruct.corrections.BG_bg, tcPDAstruct.corrections.BG_br,...
    tcPDAstruct.corrections.BG_gg, tcPDAstruct.corrections.BG_gr,...
    tcPDAstruct.corrections.R0_gr, tcPDAstruct.corrections.R0_bg, tcPDAstruct.corrections.R0_br] = deal(corrections{:});

%%% Apply cuts
[valid] = Cut_Data([],[]);
%n_bins = 1000; valid(cumsum(valid) > n_bins) = false;
tcPDAstruct.fbb = tcPDAstruct.NBB(valid);
tcPDAstruct.fbg = tcPDAstruct.NBG(valid);
tcPDAstruct.fbr = tcPDAstruct.NBR(valid);
tcPDAstruct.fgg = tcPDAstruct.NGG(valid);
tcPDAstruct.fgr = tcPDAstruct.NGR(valid);
tcPDAstruct.valid = valid;
        
%create input data
fitpar = [];
LB = [];
UB = [];
fixed = [];
sigma_prop = [];
%%% make modifyable later
sampleA = str2double(handles.sigma_A_edit.String);
sampleR = str2double(handles.sigma_R_edit.String);
sampleSigma = str2double(handles.sigma_s_edit.String);
s_dummy = [sampleA sampleR sampleSigma sampleR sampleSigma sampleR sampleSigma sampleSigma sampleSigma sampleSigma];
%covariance matrix read in as well!
for i = 1:n_gauss
    fitpar = [fitpar; tcPDAstruct.fitdata.param{i}(:)];
    LB = [LB; tcPDAstruct.fitdata.LB{i}(:)];
    UB = [UB; tcPDAstruct.fitdata.UB{i}(:)];
    fixed = [fixed; tcPDAstruct.fitdata.fixed{i}(:)];
    sigma_prop = [sigma_prop, s_dummy];
end

%%% define parameter names
param_names_dummy= {'A','R_G_R','\sigma_G_R','R_B_G','\sigma_B_G','R_B_R','\sigma_B_R','cov(BG/BR)','cov(BG/GR)','cov(BR/GR)'};
if n_gauss == 1
    param_names = param_names_dummy;
elseif n_gauss > 1
    param_names = {};
    for i = 1:n_gauss
        param_names = horzcat(param_names,cellfun(@(x) [x '_' num2str(i)],param_names_dummy,'UniformOutput',false));
    end
end

tcPDAstruct.grid = 0;
calculate_background();

%%% check if gpu is available (sometimes it locks up...)
tcPDAstruct.GPU_locked = false;
try 
    gpuDevice;
catch
    disp('GPU locked up - Using CPU instead...');
    disp('Restart Matlab to fix.');
    tcPDAstruct.GPU_locked = true;
end
if (gpuDeviceCount==0) || tcPDAstruct.GPU_locked % Use CPU
    % Initialize Array of binomial and trinomial coefficients
    [tcPDAstruct.lib_b,tcPDAstruct.lib_t] = binomial_coefficient_library_mex(tcPDAstruct.fbb,tcPDAstruct.fbg,tcPDAstruct.fbr,tcPDAstruct.fgg,tcPDAstruct.fgr,...
        tcPDAstruct.corrections.background.NBGbb,tcPDAstruct.corrections.background.NBGbg,tcPDAstruct.corrections.background.NBGbr,tcPDAstruct.corrections.background.NBGgg,tcPDAstruct.corrections.background.NBGgr);
end

priorfun = @(x) 1;
probfun = @(x) (-1)*determine_MLE_mc_dist_3d_cor(x); 
plot_params = ~fixed;

switch mcmc_method
    case 1 %%% MH
        [samples,prob,acceptance] =  MHsample(n_samples,probfun,priorfun,sigma_prop,LB',UB',fitpar,fixed,plot_params,param_names,handles.bayesian_plot_panel);
    case 2 %%% MHWG
        [samples,prob,acceptance] =  MWGsample(n_samples,probfun,priorfun,sigma_prop,LB',UB',fitpar,fixed,plot_params,param_names,handles.bayesian_plot_panel);
end

if ~isfield(tcPDAstruct,'samples')
    tcPDAstruct.samples = samples;
    tcPDAstruct.prob = prob;
    tcPDAstruct.acceptance = acceptance;
else
    if ~handles.mcmc_append.Value
        tcPDAstruct.samples = samples;
        tcPDAstruct.prob = prob;
        tcPDAstruct.acceptance = acceptance;
    else
        if size(tcPDAstruct.samples,2) ~= size(samples,2)
            answer = questdlg('Overwrite previous result?','Could not append data since the number of parameters changed.','Yes','No','Yes');
            if strcmp(answer,'Yes')
                tcPDAstruct.samples = samples;
                tcPDAstruct.prob = prob;
                tcPDAstruct.acceptance = acceptance;
            end
        else
            tcPDAstruct.samples = [tcPDAstruct.samples; samples];
            tcPDAstruct.prob = [tcPDAstruct.prob;prob];
            tcPDAstruct.acceptance = mean([tcPDAstruct.acceptance,acceptance]);
            %%% Update plots with total samples
            ax = get(handles.bayesian_plot_panel,'Children');
            for i = 1:numel(ax)
                if strcmp(ax(i).Type,'text')
                    ax(i).String = sprintf('acceptance ratio = %.4f',tcPDAstruct.acceptance);
                end
            end
            val = true(numel(ax),1);
            for i = 1:numel(ax)
                if ~strcmp(ax(i).Type,'axes')
                    val(i) = false;
                end
            end
            ax = ax(val); ax = flipud(ax);
            for i = 1:numel(ax(1).Children)
                if strcmp(ax(1).Children(i).Type,'line')
                    ax(1).Children(i).YData = tcPDAstruct.prob;
                end
            end
            notfixed = find(~fixed);
            for i = 2:numel(ax)
                for j = 1:numel(ax(i).Children)
                    if strcmp(ax(i).Children(j).Type,'line')
                        ax(i).Children(j).YData = tcPDAstruct.samples(:,notfixed(i-1));
                    end
                end
            end
        end
    end
end

%%% fitpar set to mean of gaussian chain
%fitpar = mean(samples,1)';
fitpar = samples(end,:)';
%fix covariance matrix again
fitpar = fix_covariance_matrix_fitpar(fitpar);

%%% save result as backup
[path,file,~] = fileparts(tcPDAstruct.FullFileName);
if ~(exist([path filesep 'temp_tcPDA']) == 7) %%% folder does not exist
    mkdir([path filesep 'temp_tcPDA']);
end
tempfilename = [path filesep 'temp_tcPDA' filesep file '_mcmc_result.mat'];
samples = samples(:,~fixed);
param_names = param_names(~fixed);
save(tempfilename,'samples','prob','acceptance','param_names');

%Update fitpar in tcPDAstruct
for i = 1:n_gauss
    tcPDAstruct.fitdata.param{i} = fitpar(((i-1)*10+1):(10*i));
end
%update table
UpdateFitTable(handles);
handles.draw_samples_button.Enable = 'on';
%%% delete buttons
del = false(numel(handles.bayesian_plot_panel.Children),1);
for i = 1:numel(handles.bayesian_plot_panel.Children)
    if isprop(handles.bayesian_plot_panel.Children(i),'Type')
        if strcmp(handles.bayesian_plot_panel.Children(i).Type,'uicontrol')
            if strcmp(handles.bayesian_plot_panel.Children(i).Style,'pushbutton')
                del(i) = true;
            end
        end
    end
end
delete(handles.bayesian_plot_panel.Children(del));
%%% Show result
MCMC_summary;

%%% displays a summary of the mcmc results or saves as text file
function MCMC_summary(~,~)
global tcPDAstruct UserValues
handles = guidata(gcbo);

%%% check if analysis has been done
if ~isfield(tcPDAstruct,'samples') || isempty(handles.bayesian_plot_panel.Children)
    return;
end
n_gauss = size(tcPDAstruct.samples,2)/10;
fixed = vertcat(tcPDAstruct.fitdata.fixed{:});
fixed = fixed(1:size(tcPDAstruct.samples,2));
samples = tcPDAstruct.samples(:,~fixed);
spacing = str2double(handles.mcmc_spacing_edit.String);

perc = 1.96; % 95% confidence interval at 1.96 sigma
mu = mean(samples(1:spacing:end,:),1);
ci = prctile(samples(1:spacing:end,:),[2.5,97.5],1); %std(samples(1:spacing:end,:),1).*perc;
number_of_samples = numel(1:spacing:size(samples,1));
%%% define parameter names
param_names_dummy= {'A','R(GR)','s(GR)','R(BG)','s(BG)','R(BR)','s(BR)','cov(BG/BR)','cov(BG/GR)','cov(BR/GR)'};
if n_gauss == 1
    param_names = param_names_dummy;
elseif n_gauss > 1
    param_names = {};
    for i = 1:n_gauss
        param_names = horzcat(param_names,cellfun(@(x) [x '_' num2str(i)],param_names_dummy,'UniformOutput',false));
    end
end
param_names = param_names(~fixed);
[path,file,~] = fileparts(tcPDAstruct.FullFileName);

fid = fopen([path filesep file '_mcmc_result.txt'],'w');
fprintf(fid,'MCMC algorithm:\t%s\n',handles.mcmc_method.String{handles.mcmc_method.Value});
fprintf(fid,'Number of samples:\t%d\n',size(samples,1));
fprintf(fid,'Sampling width for amplitudes:\t%s\n',handles.sigma_A_edit.String);
fprintf(fid,'Sampling width for distances:\t%s\n',handles.sigma_R_edit.String);
fprintf(fid,'Sampling width for distribution widths:\t%s\n',handles.sigma_s_edit.String);
fprintf(fid,'Spacing for sampling from chain:\t%d\n\n',spacing);
fprintf(fid,'Parameter\tmean\tci (95%%)\n');
for i = 1:numel(param_names)
    fprintf(fid,'%s\t%.2f\t(%.2f,%.2f)\n',param_names{i},mu(i),ci(1,i),ci(2,i));
end


%%% calculate the summary
switch gcbo
    case {handles.draw_samples_button,handles.mcmc_spacing_edit}
        %%% save a summary in terms of 95% confidence intervals
        %%% Display result using the subplot axis titles
        ax = get(handles.bayesian_plot_panel,'Children');
        val = true(numel(ax),1);
        for i = 1:numel(ax)
            if ~strcmp(ax(i).Type,'axes')
                val(i) = false;
            end
        end
        ax = ax(val); ax = flipud(ax);
        for i = 2:numel(ax)
            %remove old text
            del = false(numel(ax(i).Children),1);
            for j = 1:numel(ax(i).Children)
                if strcmp(ax(i).Children(j).Type,'text')
                    del(j) = true;
                end
            end
            delete(ax(i).Children(del));
            %%% format text
            res = {sprintf('%.2f',mu(i-1)), sprintf('(%.2f,',ci(1,i-1)), sprintf('%.2f)',ci(2,i-1))};
            %%% plot result in axis
            axes(ax(i));
            text(1.08,0.5,res,'Units','normalized','FontSize',12,'Color',UserValues.Look.Fore,'HorizontalAlignment','center');
        end
    case handles.save_mcmc_button
        %%% append the samples
        fprintf(fid,'\n');
        fprintf(fid,'Iter.\t%s',param_names{1});
        for i = 2:numel(param_names)
            fprintf(fid,'\t%s',param_names{i});
        end
        fprintf(fid,'\n');
        format_spec = '%d\t%.4f';
        for i = 2:size(samples,2)
            format_spec = [format_spec '\t%.4f'];
        end
        format_spec = [format_spec '\n'];
        for i = 1:size(samples,1)
            fprintf(fid,format_spec,[i,samples(i,:)]);
        end
        %%% save everything in a matlab file as well
        prob = tcPDAstruct.prob;
        acceptance = tcPDAstruct.acceptance;
        save([path filesep file '_mcmc_result.mat'],'samples','prob','acceptance','param_names');
end
fclose(fid);
%%% Calculate the relative brightness based on FRET value
function [Qr_g,Qr_b] = calc_relative_brightness(Rgr,Rbg,Rbr)
global tcPDAstruct
de_gr = tcPDAstruct.corrections.de_gr;
cr_gr = tcPDAstruct.corrections.ct_gr;
gamma_gr = tcPDAstruct.corrections.gamma_gr;
R0_gr = tcPDAstruct.corrections.R0_gr;
R0_bg = tcPDAstruct.corrections.R0_bg;
R0_br = tcPDAstruct.corrections.R0_br;
de_bg = tcPDAstruct.corrections.de_bg;
de_br = tcPDAstruct.corrections.de_br;
cr_bg = tcPDAstruct.corrections.ct_bg;
cr_br = tcPDAstruct.corrections.ct_br;
gamma_br = tcPDAstruct.corrections.gamma_br;
gamma_bg = gamma_br/gamma_gr;
pe_b = 1-de_bg-de_br;
E_gr = 1/(1+(Rgr/R0_gr).^6);
Qr_g = (1-de_gr)*(1-E_gr) + (gamma_gr/(1+cr_gr))*(de_gr+E_gr*(1-de_gr));

%efficiencies
E1 = 1./(1+(Rbg./R0_bg).^6);
E2 = 1./(1+(Rbr./R0_br).^6);
EGR = 1./(1+(Rgr./R0_gr).^6);

%PGR = 1-(1+cr_gr+(((de_gr/(1-de_gr)) + EGR) * gamma_gr)./(1-EGR)).^(-1);

EBG_R = E1.*(1-E2)./(1-E1.*E2);
EBR_G = E2.*(1-E1)./(1-E1.*E2);
E1A = EBG_R + EBR_G;

%%% calculate FRET brightness
PB = pe_b.*(1-E1A);

PG = pe_b.*(1-E1A).*cr_bg + ...
    pe_b.*EBG_R.*(1-EGR).*gamma_bg + ...
    de_bg.*(1-EGR).*gamma_bg;

PR = pe_b.*(1-E1A).*cr_br + ...
    pe_b.*EBG_R.*(1-EGR).*gamma_bg.*cr_gr + ...
    pe_b.*EBG_R.*EGR.*gamma_br + ...
    pe_b.*EBR_G.*gamma_br + ...
    de_bg.*(1-EGR).*gamma_bg.*cr_gr + ...
    de_bg.*EGR.*gamma_br + ...
    de_br.*gamma_br;

Q_FRET = PB+PG+PR;

%%% calculate Blue only brightness
PB = pe_b;

PG = pe_b.*cr_bg;

PR = pe_b.*cr_br;
 
Q_blueonly = PB+PG+PR;

Qr_b = Q_FRET/Q_blueonly;

%%% Scale Photon Count Distribution to lower brightness (linear scaling,
%%% approximately correct)
function [ PN_scaled ] = scalePN(PN, scale_factor)
PN_scaled = interp1(scale_factor*[1:1:numel(PN)],PN,[1:1:numel(PN)]);
PN_scaled(isnan(PN_scaled)) = 0;

%%% function to calculate poissonian MLE estimator
function [chi2, dev] = chi2poiss(H_res,H_meas)
%%% calculates poissonian likelihood based on:
%%% Laurence, T. A. & Chromy, B. A. Efficient maximum likelihood estimator fitting of histograms. Nat Meth 7, 338?339 (2010).
%%%
%%% The "norm" variable determines whether the returned chi2 should be
%%% normalized to the maximum possible likelihood or not.
%%% i.e. L(data|model)/L(data|data)
%%%
%%% During fitting, norm should be disabled, because otherwise empty data
%%% bins will return Inf values.
%%% When a deviation vector is required, norm is enabled.

%%% Problem:
%%% What to do with empty bins? (Both for Poissonian and Gaussian...)

if nargout < 2
    norm = 0;
else
    norm = 1;
end

%%% remove 0s in fit result since they return Inf
H_res(H_res == 0) = eps;
switch norm
    case 0
        log_term = H_meas.*log(H_res);
        %log_term(~isfinite(log_term)) = 0; %%% remove infinite and NaNs
        Istar = -2*(log_term-H_res);
        Istar(~isfinite(Istar)) = (H_meas(~isfinite(Istar))-H_res(~isfinite(Istar))).^2; %%% Gaussian error with sigma = 1
        chi2 = sum(Istar(:));
    case 1
        log_term = -2*H_meas.*log(H_res./H_meas);
        %log_term(~isfinite(log_term)) = 0; %%% remove infinite and NaNs
        dev_mle = 2*(H_res-H_meas)+log_term;
        dev_mle(~isfinite(dev_mle)) = (H_meas(~isfinite(dev_mle))-H_res(~isfinite(dev_mle))).^2; %%% Gaussian error with sigma = 1
        chi2 = sum(dev_mle(:))./sum(sum(sum(H_meas~=0)));
        %%% we need to remove all "invalid" bins, which make
        %%% log(H_res./H_meas) not return a number (Inf,NaN).
end

if nargout == 2
    dev_mle(dev_mle < 0) = 0;
    dev = sign(H_res-H_meas).*sqrt(max(dev_mle,0));
end

%%% Gaussian Chi2
gaussian = 0;
if gaussian
    sigma = sqrt(H_meas); sigma(sigma==0) = 1;
    chi2 = sum((H_meas(:)-H_res(:)).^2./sigma(:).^2)./sum(sum(sum(H_meas~=0 | H_res~= 0)));
    %%% invalid are all points where either fit or data is zero
end

%%% function to add 2color data
function add_2cPDAData(obj,eData)
global tcPDAstruct UserValues

%%$ Load or Add data
Files = GetMultipleFiles({'*.pda','*.pda file'},'Select *.pda file',UserValues.tcPDA.PathName)
if isempty(Files)
    return;
end
FileName = Files(:,1);
PathName = Files(:,2);
%%% Only executes, if at least one file was selected
if all(FileName{1}==0)
    return
end
for i = 1:numel(FileName)
    if exist(fullfile(PathName{i},FileName{i}), 'file') == 2
        load('-mat',fullfile(PathName{i},FileName{i}));
        tcPDAstruct.twocolordata.FileName{end+1} = FileName{i};
        tcPDAstruct.twocolordata.PathName{end+1} = PathName{i};
        if exist('PDA','var') % file has not been saved before in GlobalPDAFit
            % PDA %structure
            % .NGP
            % ....
            % .NR
            % .Corrections %structure
            %       .CrossTalk_GR
            %       .DirectExcitation_GR
            %       .Gamma_GR
            %       .Beta_GR
            %       .GfactorGreen
            %       .GfactorRed
            %       .DonorLifetime
            %       .AcceptorLifetime
            %       .FoersterRadius
            %       .LinkerLength
            %       .r0_green
            %       .r0_red
            %       ... maybe more in future
            % .Background %structure
            %       .Background_GGpar
            %       .Background_GGperp
            %       .Background_GRpar
            %       .Background_GRperp
            %       ... maybe more in future
            % NOTE: direct excitation correction in Burst analysis is NOT the
            % same as PDA, therefore we put it to zero. In PDA, this factor
            % is either the extcoeffA/(extcoeffA+extcoeffD) at donor laser,
            % or the ratio of Int(A)/(Int(A)+Int(D)) for a crosstalk, gamma
            % corrected double labeled molecule having no FRET at all.
            tcPDAstruct.twocolordata.Data{end+1} = PDA;
            tcPDAstruct.twocolordata.Data{end} = rmfield(tcPDAstruct.twocolordata.Data{end}, 'Corrections');
            tcPDAstruct.twocolordata.Data{end} = rmfield(tcPDAstruct.twocolordata.Data{end}, 'Background');
            tcPDAstruct.twocolordata.timebin(end+1) = timebin;
            tcPDAstruct.twocolordata.Corrections{end+1} = PDA.Corrections; %contains everything that was saved in BurstBrowser
            tcPDAstruct.twocolordata.Background{end+1} = PDA.Background; %contains everything that was saved in BurstBrowser
            if isfield(PDA,'BrightnessReference')
                if ~isempty(PDA.BrightnessReference.N)
                    tcPDAstruct.twocolordata.BrightnessReference = PDA.BrightnessReference;
                    tcPDAstruct.twocolordata.BrightnessReference.PN = histcounts(tcPDAstruct.twocolordata.BrightnessReference.N,1:(max(tcPDAstruct.twocolordata.BrightnessReference.N)+1));
                end
            end
            if isfield(PDA,'Type') %%% Type distinguishes between whole measurement and burstwise
                tcPDAstruct.twocolordata.Type{end+1} = PDA.Type;
            else
                tcPDAstruct.twocolordata.Type{end+1} = 'Burst';
            end
            clear PDA timebin
            tcPDAstruct.twocolordata.FitTable{end+1} = h.FitTab.Table.Data(end-2,:);
        elseif exist('SavedData','var') % file has been saved before in GlobalPDAFit and contains SavedData
            % SavedData %structure
            %   .Data %cell
            %       .NGP
            %       ....
            %       .NR
            %   .Corrections %structure
            %           see above
            %   .Background %structure
            %           see above
            %   .FitParams %1 x 47 cell
            tcPDAstruct.twocolordata.Data{end+1} = SavedData.Data;
            tcPDAstruct.twocolordata.timebin(end+1) = SavedData.timebin;
            tcPDAstruct.twocolordata.Corrections{end+1} = SavedData.Corrections;
            tcPDAstruct.twocolordata.Background{end+1} = SavedData.Background;
            if isfield(SavedData,'Type') %%% Type distinguishes between whole measurement and burstwise
                tcPDAstruct.twocolordata.Type{end+1} = SavedData.Type;
            else
                tcPDAstruct.twocolordata.Type{end+1} = 'Burst';
            end
            % load fit table data from files
            tcPDAstruct.twocolordata.FitTable{end+1} = SavedData.FitTable;        
        end
    else
        errorstr{a} = ['File ' FileName{i} ' on path ' PathName{i} ' could not be found. File omitted from database.'];
        a = a+1;
    end       
end
disp(errorstr);

%%% callback function of 2c pda table
function table_2cPDAData_callback(obj,e)

%%% evaluate 2C PDA likelihood
function evaluate_2C_pda_likelihood(input)
n_gauss = 1; % read out number of populations
steps = 10;
n_sigma = 3; %%% how many sigma to sample distribution width?
L = cell(n_gauss,1); %%% Likelihood per Gauss
for j = 1:n_gauss
    %%% define Gaussian distribution of distances
    xR = (fitpar(j,2)-n_sigma*fitpar(j,3)):(2*n_sigma*fitpar(j,3)/steps):(fitpar(j,2)+n_sigma*fitpar(j,3));
    PR = normpdf(xR,fitpar(j,2),fitpar(j,3));
    PR = PR'./sum(PR);
    %%% Calculate E values for R grid
    E = 1./(1+(xR./R0).^6);
    epsGR = 1-(1+cr+(((de/(1-de)) + E) * gamma)./(1-E)).^(-1);
    
    %%% Calculate the vector of likelihood values
    P = eval_prob_2c_bg(NG,NF,...
        PDAMeta.NBG{file},PDAMeta.NBR{file},...
        PDAMeta.PBG{file}',PDAMeta.PBR{file}',...
        epsGR');
    P = log(P) + repmat(log(PR'),numel(NG),1);
    Lmax = max(P,[],2);
    P = Lmax + log(sum(exp(P-repmat(Lmax,1,numel(PR))),2));
    
    if h.SettingsTab.Use_Brightness_Corr.Value
        %%% Add Brightness Correction Probabilty here
        P = P + log(PN_scaled{j}(NG + NF));
    end
    %%% Treat case when all burst produced zero probability
    P(isnan(P)) = -Inf;
    L{j} = P;
end

%%% normalize amplitudes
fitpar(PDAMeta.Comp{file},1) = fitpar(PDAMeta.Comp{file},1)./sum(fitpar(PDAMeta.Comp{file},1));
PA = fitpar(PDAMeta.Comp{file},1);


L = horzcat(L{:});
L = L + repmat(log(PA'),numel(NG),1);
Lmax = max(L,[],2);
L = Lmax + log(sum(exp(L-repmat(Lmax,1,numel(PA))),2));
%%% P_res has NaN values if Lmax was -Inf (i.e. total of zero probability)!
%%% Reset these values to -Inf
L(isnan(L)) = -Inf;
logL = sum(L);
%%% since the algorithm minimizes, it is important to minimize the negative
%%% log likelihood, i.e. maximize the likelihood
logL = -logL;

function determine_MLE_global()
%%% combine the likelihoods of two-color and three-color measurements
%%% possible to use weighting

%%% function to get multiple files until user cancels
function Files = GetMultipleFiles(FilterSpec,Title,PathName)
FileName = 1;
count = 0;
while FileName ~= 0
    [FileName,PathName] = uigetfile(FilterSpec,Title, PathName, 'MultiSelect', 'on');
    if ~iscell(FileName)
        if FileName ~= 0
            count = count+1;
            Files{count,1} = FileName;
            Files{count,2} = PathName;
        end
    elseif iscell(FileName)
        for i = 1:numel(FileName)
            if FileName{i} ~= 0
                count = count+1;
                Files{count,1} = FileName{i};
                Files{count,2} = PathName;
            end
        end
        FileName = FileName{end};
    end
    PathName= fullfile(PathName,'..',filesep);%%% go one layer above since .*pda files are nested
end