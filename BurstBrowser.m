function BurstBrowser %Burst Browser

hfig=findobj('Name','BurstBrowser');
global BurstData

if isempty(hfig)
    h.AxesColor = [0.5 0.5 0.5];
    h.BackColor = [0.2 0.2 0.2];
    h.BackColorTabs = [0.5 0.5 0.5];
    h.ControlColor = [0.4 0.4 0.4];
    h.DisabledColor = [0 0 0];
    h.ShadowColor = [0.4 0.4 0.4];
    h.ForeColor = [1 1 1];    
    h.Int=1;
    
    %define main window
    h.Figure = figure(...
    'Units','normalized',...
    'Name','Bowser',...
    'MenuBar','none',...
    'OuterPosition',[0.01 0.05 0.98 0.95],...
    'UserData',[],...
    'Visible','on',...
    'Tag','BurstBrowser');
    %'WindowScrollWheelFcn',@Bowser_Wheel,...
    %'KeyPressFcn',@Bowser_KeyPressFcn,...
    whitebg(h.Figure, h.ForeColor);
    set(h.Figure,'Color',h.BackColor);
    
    %define menu items
     h.Load_Bursts = uimenu(...
    'Parent',h.Figure,...
    'Label','Load Burst Data',...
    'Callback',@Load_Burst_Data_Callback,...
    'Tag','Load_Burst_Data');

    %define tabs
    %main tab
    h.Main_Tab = uitabgroup(...
    'Parent',h.Figure,...
    'Tag','Main_Tab',...
    'Units','normalized',...
    'Position',[0 0.01 0.65 0.98]);

    h.Main_Tab_General = uitab(h.Main_Tab,...
    'title','General',...
    'Tag','Main_Tab_General'); 

    h.Main_Tab_Corrections= uitab(h.Main_Tab,...
    'title','Corrections',...
    'Tag','Main_Tab_Corrections'); 

    h.Main_Tab_Lifetime= uitab(h.Main_Tab,...
    'title','Lifetime',...
    'Tag','Main_Tab_Lifetime'); 
    
    %secondary tab
    h.Secondary_Tab = uitabgroup(...
    'Parent',h.Figure,...
    'Tag','Secondary_Tab',...
    'Units','normalized',...
    'Position',[0.65 0.01 0.34 0.98]);

    h.Secondary_Tab_Selection = uitab(h.Secondary_Tab,...
    'title','Selection',...
    'Tag','Secondary_Tab_Selection'); 

    h.Secondary_Tab_Corrections= uitab(h.Secondary_Tab,...
    'title','Correction factors',...
    'Tag','Secondary_Tab_Corrections'); 

    h.Secondary_Tab_DisplayOptions= uitab(h.Secondary_Tab,...
    'title','Display Options',...
    'Tag','Secondary_Tab_DisplayOptions'); 

    %define species list
    h.SpeciesList = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'KeyPressFcn',@List_KeyPressFcn,...
    'Max',5,...
    'Position',[0 0 1 0.2],...
    'Style','listbox',...
    'Tag','SpeciesList'); 
    %'ButtonDownFcn',@List_ButtonDownFcn,...
    %'CallBack',@List_ButtonDownFcn,...
    % for right click selection to work, we need to access the underlying
    % java object
    %see: http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
    jScrollPane = findjobj(h.SpeciesList);
    jSpeciesList = jScrollPane.getViewport.getComponent(0);
    jSpeciesList = handle(jSpeciesList, 'CallbackProperties');
    set(jSpeciesList, 'MousePressedCallback',{@SpeciesList_ButtonDownFcn,h.SpeciesList});
    
    %define the cut table
    cname = {'min','max','active','delete'};
    cformat = {'numeric','numeric','logical','logical'};
    ceditable = [true true true true];
    table_dat = {'','',false,false};
    cwidth = {50,50,50,50};
    
    h.CutTable = uitable(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'Position',[0 0.2 1 0.3],...
    'Tag','CutTable',...
    'ColumnName',cname,...
    'ColumnFormat',cformat,...
    'ColumnEditable',ceditable,...
    'Data',table_dat,...
    'ColumnWidth',cwidth,...
    'CellEditCallback',@CutTableChange); 
    
    %define the parameter selection listboxes
    h.ParameterListX = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'KeyPressFcn',@ParameterList_KeyPressFcn,...
    'Max',5,...
    'Position',[0 0.55 0.5 0.3],...
    'Style','listbox',...
    'Tag','ParameterListX',...
    'Enable','on');
    
    h.ParameterListY = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'KeyPressFcn',@ParameterList_KeyPressFcn,...
    'Max',5,...
    'Position',[0.5 0.55 0.5 0.3],...
    'Style','listbox',...
    'Tag','ParameterListY',...
    'Enable','on');

    % for right click selection to work, we need to access the underlying
    % java object
    %see: http://undocumentedmatlab.com/blog/setting-listbox-mouse-actions
    jScrollPaneX = findjobj(h.ParameterListX);
    jScrollPaneX = findjobj(h.ParameterListX); %%% Execute twice because it fails to work on the first call
    jScrollPaneY = findjobj(h.ParameterListY);
    jParameterListX = jScrollPaneX.getViewport.getComponent(0);
    jParameterListY = jScrollPaneY.getViewport.getComponent(0);
    jParameterListX = handle(jParameterListX, 'CallbackProperties');
    jParameterListY = handle(jParameterListY, 'CallbackProperties');
    set(jParameterListX, 'MousePressedCallback',{@ParameterList_ButtonDownFcn,h.ParameterListX});
    set(jParameterListY, 'MousePressedCallback',{@ParameterList_ButtonDownFcn,h.ParameterListY});
    
    %define plot button
    h.PlotButton = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'Position',[0 0.51 0.2 0.03],...
    'Style','pushbutton',...
    'Tag','PlotButton',...
    'String','Plot',...
    'Callback',@UpdatePlot);

    h.MultiPlotButton = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'Position',[0.2 0.51 0.2 0.03],...
    'Style','pushbutton',...
    'Tag','MutliPlotButton',...
    'String','Plot multiple species',...
    'Callback',@MultiPlot);

    %define manual cut button
     h.CutButton = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'Position',[0.6 0.51 0.2 0.03],...
    'Style','pushbutton',...
    'Tag','CutButton',...
    'String','Manual Cut',...
    'Callback',@ManualCut);

    %define add species button
     h.CutButton = uicontrol(...
    'Parent',h.Secondary_Tab_Selection,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'Position',[0.8 0.51 0.2 0.03],...
    'Style','pushbutton',...
    'Tag','AddSpeciesButton',...
    'String','Add Species',...
    'Callback',@add_species);

    %%%buttons in correction tab
    h.PlotCorrections = uicontrol(...
    'Parent',h.Secondary_Tab_Corrections,...
    'Units','normalized',...
    'BackgroundColor', h.AxesColor,...
    'ForegroundColor', h.ForeColor,...
    'Position',[0 0.91 0.2 0.03],...
    'Style','pushbutton',...
    'Tag','PlotCorrectionsButton',...
    'String','Plot Corrections',...
    'Callback',@PlotCorrections);

    
    
    
    %%%define axes in main_tab_general
    %define 2d axis
    h.axes_general =  axes(...
    'Parent',h.Main_Tab_General,...
    'Units','normalized',...
    'Position',[0.05 0.05 0.75 0.75],...
    'Box','on',...
    'Tag','Axes_General',...
    'FontSize',20,...
    'ButtonDownFcn',@SetAxes,...
    'View',[0 90]);
    
    %define 1d axes
    h.axes_1d_x =  axes(...
    'Parent',h.Main_Tab_General,...
    'Units','normalized',...
    'Position',[0.05 0.8 0.75, 0.15],...
    'Box','on',...
    'Tag','Axes_1D_X',...
    'FontSize',20,...
    'XAxisLocation','top',...
    'ButtonDownFcn',@SetAxes,...
    'View',[0 90]);

    h.axes_1d_y =  axes(...
    'Parent',h.Main_Tab_General,...
    'Units','normalized',...
    'Position',[0.8 0.05 0.15, 0.75],...
    'Tag','Main_Tab_General_Plot',...
    'Box','on',...
    'Tag','Axes_1D_Y',...
    'FontSize',20,...
    'XAxisLocation','top',...
    'ButtonDownFcn',@SetAxes,...
    'View',[90 90]);
    
    %%%define axes in Corrections tab
    h.axes_crosstalk =  axes(...
    'Parent',h.Main_Tab_Corrections,...
    'Units','normalized',...
    'Position',[0.05 0.55 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_crosstalk',...
    'Box','on',...
    'FontSize',20,...
    'ButtonDownFcn',@SetAxes,...
    'View',[0 90]);
    
    h.axes_direct_excitation =  axes(...
    'Parent',h.Main_Tab_Corrections,...
    'Units','normalized',...
    'Position',[0.55 0.55 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_direct_excitation',...
    'Box','on',...
    'FontSize',20,...
    'ButtonDownFcn',@SetAxes,...
    'View',[0 90]);

    h.axes_artifacts =  axes(...
    'Parent',h.Main_Tab_Corrections,...
    'Units','normalized',...
    'Position',[0.05 0.05 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_artifacts',...
    'Box','on',...
    'FontSize',20,...
    'ButtonDownFcn',@SetAxes,...
    'View',[0 90]);

    h.axes_gamma=  axes(...
    'Parent',h.Main_Tab_Corrections,...
    'Units','normalized',...
    'Position',[0.55 0.05 0.4 0.4],...
    'Tag','Main_Tab_Corrections_Plot_gamma',...
    'Box','on',...
    'FontSize',20,...
    'ButtonDownFcn',@SetAxes,...
    'View',[0 90]);

    guidata(h.Figure,h);    
    %set(Figure,'WindowButtonMotionFcn',@Update_Position);
    colormap(hot);

else
    figure(h);
end


%Load File
function Load_Burst_Data_Callback(~,~)

h = guidata(gcbo);
global BurstData UserValues

LSUserValues(0);
[FileName,PathName] = uigetfile({'*.bur'}, 'Choose a file', UserValues.File.Path, 'MultiSelect', 'off');

UserValues.PathName=PathName;

load('-mat',fullfile(PathName,FileName));

%find positions of Efficiency and Stoichiometry in NameArray
posE = find(strcmp(BurstData.NameArray,'Efficiency'));
if sum(strcmp(BurstData.NameArray,'Stoichiometry')) == 0
    BurstData.NameArray{find(strcmp(BurstData.NameArray,'Stochiometry'))} = 'Stoichiometry';
end
posS = find(strcmp(BurstData.NameArray,'Stoichiometry'));

set(h.ParameterListX, 'String', BurstData.NameArray);
set(h.ParameterListX, 'Value', posE);

set(h.ParameterListY, 'String', BurstData.NameArray);
set(h.ParameterListY, 'Value', posS);

if ~isfield(BurstData,'PlotType')
    BurstData.PlotType = 1;
end

UpdatePlot();

function ParameterList_KeyPressFcn(hObject,eventdata)

function ParameterList_ButtonDownFcn(jListbox,jEventData,hListbox)
% Determine the click type
% (can similarly test for CTRL/ALT/SHIFT-click)
if jEventData.isMetaDown  % right-click is like a Meta-button
  clickType = 'Right-click';
else
  clickType = 'Left-click';
end

% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;
listValues = get(hListbox,'string');
clickedValue = listValues{clickedIndex};

h = guidata(hListbox);
global BurstData

if strcmpi(clickType,'Right-click')
    %%%add to cut list if right-clicked
    if ~isfield(BurstData,'Cut')
        %initialize Cut Cell Array
        BurstData.Cut{1} = {};
        %add species to list
        BurstData.SpeciesNames{1} = 'Species 1';
        %update species list
        set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
        BurstData.SelectedSpecies = 1;
    end
    species = get(h.SpeciesList,'Value');
    param = clickedIndex;
    
    BurstData.Cut{species}{end+1} = {BurstData.NameArray{param}, min(BurstData.DataArray(:,param)),max(BurstData.DataArray(:,param)), true,false};
    UpdateCutTable(h);
    UpdateCuts();
    UpdateCorrections;
end

function SpeciesList_ButtonDownFcn(jListbox,jEventData,hListbox)
% Determine the click type
% (can similarly test for CTRL/ALT/SHIFT-click)
if jEventData.isMetaDown  % right-click is like a Meta-button
  clickType = 'Right-click';
else
  clickType = 'Left-click';
end


% Determine the current listbox index
% Remember: Java index starts at 0, Matlab at 1
mousePos = java.awt.Point(jEventData.getX, jEventData.getY);
clickedIndex = jListbox.locationToIndex(mousePos) + 1;
listValues = get(hListbox,'string');
clickedString = listValues{clickedIndex};

h = guidata(hListbox);
global BurstData
if strcmpi(clickType,'Right-click')
    if numel(get(hListbox,'String')) > 1 %remove selected field
        val = clickedIndex;
        BurstData.SpeciesNames(val) = [];
        set(hListbox,'Value',val-1);
        set(hListbox,'String',BurstData.SpeciesNames); 
    end
else %leftclick
    set(hListbox,'Value',clickedIndex);
    BurstData.SelectedSpecies = clickedIndex;
end
UpdateCutTable(h);
UpdateCuts();
UpdatePlot;

function add_species(~,~)
global BurstData
h= guidata(gcbo);
hListbox = h.SpeciesList;
%add a species to the list
BurstData.SpeciesNames{end+1} = ['Species ' num2str(1+numel(get(hListbox,'String')))];
set(hListbox,'String',BurstData.SpeciesNames);
%set to new species
set(hListbox,'Value',numel(get(hListbox,'String')));
BurstData.SelectedSpecies = get(hListbox,'Value');

%initialize new species Cut array
BurstData.Cut{BurstData.SelectedSpecies} = {};

UpdateCutTable(h);
UpdateCuts();
UpdatePlot;

%plots in the main axes
function UpdatePlot(~,~)

h = guidata(gcf);
global BurstData UserValues

axes(h.axes_general);
cla(gca);
x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');
if ~isfield(BurstData,'Cut') || isempty(BurstData.Cut{BurstData.SelectedSpecies})
    datatoplot = BurstData.DataArray;
elseif isfield(BurstData,'Cut')
    datatoplot = BurstData.DataCut;
end

[H xbins_hist ybins_hist] = hist2d([datatoplot(:,x) datatoplot(:,y)],51, 51, [min(datatoplot(:,x)) max(datatoplot(:,x))], [min(datatoplot(:,y)) max(datatoplot(:,y))]);
H(:,end-1) = H(:,end-1) + H(:,end); H(:,end) = [];
H(end-1,:) = H(end-1,:) + H(end-1,:); H(end,:) = [];
l = H>0;
xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;
%xbins1d=linspace(min(datatoplot(:,x)),max(datatoplot(:,x)),50)+(max(datatoplot(:,x))-min(datatoplot(:,x)))/100;
%ybins1d=linspace(min(datatoplot(:,y)),max(datatoplot(:,y)),50)+(max(datatoplot(:,y))-min(datatoplot(:,y)))/100;

switch BurstData.PlotType
    case 1 %%%image plot
        BurstData.PlotHandle = imagesc(xbins,ybins,H./max(max(H)));
        set(BurstData.PlotHandle,'AlphaData',l);
        set(gca,'YDir','normal');
    case 2 %%%contour plot
        zc=linspace(1, ceil(max(max(H))),20);
        set(gca,'CLim',[0 ceil(2*max(max(H)))]);
        H(H==0) = NaN;
        [~, BurstData.PlotHandle]=contourf(xbins,ybins,H,[0 zc]);
        set(BurstData.PlotHandle,'EdgeColor','none');
        colormap(hot);
end
axis('tight');
set(gca,'FontSize',20);

%plot 1D hists    
axes(h.axes_1d_x);
cla(gca);
hx = histc(datatoplot(:,x),xbins_hist);
hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
bar(xbins,hx,'BarWidth',1);
axis('tight');
set(gca,'XAxisLocation','top','FontSize',20)
ylabel = get(gca,'YTick');
set(gca,'YTick',ylabel(2:end));

axes(h.axes_1d_y);
cla(gca);
hy = hist(datatoplot(:,y),ybins_hist);
hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
bar(ybins,hy,'BarWidth',1);
axis('tight');
set(gca,'View',[90 90],'XDir','reverse');
set(gca,'XAxisLocation','top','FontSize',20)
ylabel = get(gca,'YTick');
set(gca,'YTick',ylabel(2:end));

function MultiPlot(~,~)
h = guidata(gcf);
global BurstData UserValues

axes(h.axes_general);
cla(gca);

x = get(h.ParameterListX,'Value');
y = get(h.ParameterListY,'Value');

num_species = numel(get(h.SpeciesList,'String'));
if num_species > 3
    num_species = 3;
end

for i = 1:num_species
    UpdateCuts(i);
    if ~isfield(BurstData,'Cut') || isempty(BurstData.Cut{i})
        datatoplot{i} = BurstData.DataArray;
    elseif isfield(BurstData,'Cut')
        datatoplot{i} = BurstData.DataCut;
    end
end

%find data ranges
minx = [];
miny = [];
maxx = [];
maxy = [];
for i = 1:num_species
    minx = [minx min(datatoplot{i}(:,x))];
    miny = [miny min(datatoplot{i}(:,y))];
    maxx = [maxx max(datatoplot{i}(:,x))];
    maxy = [maxy max(datatoplot{i}(:,y))];
end
x_boundaries = [min(minx) max(maxx)];
y_boundaries = [min(miny) max(maxy)];

H = cell(num_species,1);
for i = 1:num_species
    [H{i} xbins_hist ybins_hist] = hist2d([datatoplot{i}(:,x) datatoplot{i}(:,y)],50, 50, x_boundaries, y_boundaries);
    H{i}(H{i}==0) = NaN;
    H{i}(:,end-1) = H{i}(:,end-1) + H{i}(:,end); H{i}(:,end) = [];
    H{i}(end-1,:) = H{i}(end-1,:) + H{i}(end-1,:); H{i}(end,:) = [];
end

xbins = xbins_hist(1:end-1) + diff(xbins_hist)/2;
ybins = ybins_hist(1:end-1) + diff(ybins_hist)/2;

%%% prepare image plot
white = 1;
axes(h.axes_general);
if num_species == 2
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,3) = H{1}/max(max(H{1})); %%% blue
        zz(:,:,1) = H{2}/max(max(H{2})); %%% red
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
    end
elseif num_species == 3
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    H{3}(isnan(H{3})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,3) = H{1}/max(max(H{1})); %%% blue
        zz(:,:,1) = H{2}/max(max(H{2})); %%% red
        zz(:,:,2) = H{3}/max(max(H{3})); %%% green
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
        zz(:,:,1) = zz(:,:,1) - H{3}./max(max(H{3})); %%% green
        zz(:,:,3) = zz(:,:,3) - H{3}./max(max(H{3})); %%% greenrt?f?
    end
else
    return;
end


%%% plot
imagesc(xbins,ybins,zz);
set(gca,'YDir','normal');

set(gca,'FontSize',20);

%plot 1D hists
%xbins1d=linspace(min(datatoplot(:,x)),max(datatoplot(:,x)),50)+(max(datatoplot(:,x))-min(datatoplot(:,x)))/100;
%ybins1d=linspace(min(datatoplot(:,y)),max(datatoplot(:,y)),50)+(max(datatoplot(:,y))-min(datatoplot(:,y)))/100;
%xbins1d=linspace(x_boundaries(1),x_boundaries(2),50)+(x_boundaries(2)-x_boundaries(1))/100;
%ybins1d=linspace(y_boundaries(1),y_boundaries(2),50)+(y_boundaries(2)-y_boundaries(1))/100;

axes(h.axes_1d_x);
cla(gca);
%plot first histogram
hx = hist(datatoplot{1}(:,x),xbins_hist);
hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
%normalize
hx = hx./sum(hx);
% transform to area plot to enable alpha property
%[xx, hxx] = stairs([0 xbins+min(diff(xbins))/2],[hx, hx(end)]);
%barx(1) = bar(xbins,hx,'BarWidth',1,'FaceColor',[0 0 1],'EdgeColor',[0 0 1]);
stairsx(1) = stairs([0 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','b','LineWidth',2);
hold on;
%plot rest of histograms
color = {[1 0 0], [0 1 0]};
for i = 2:num_species
    hx = hist(datatoplot{i}(:,x),xbins_hist);
    hx(end-1) = hx(end-1) + hx(end); hx(end) = [];
    %normalize
    hx = hx./sum(hx);
    if i == 2 %%% plot red
        stairsx(i) = stairs([0 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','r','LineWidth',2);
    elseif i == 3 %%% plot green
        stairsx(i) = stairs([0 xbins+min(diff(xbins))/2],[hx, hx(end)],'Color','g','LineWidth',2);
    end
    %barx(i) =bar(xbins,hx,'BarWidth',1,'FaceColor',color{i-1},'EdgeColor',color{i-1});
end

axis('tight');
set(gca,'XAxisLocation','top','FontSize',20)
ylabel = get(gca,'YTick');
set(gca,'YTick',ylabel(2:end));

axes(h.axes_1d_y);
cla(gca);
%plot first histogram
hy = hist(datatoplot{1}(:,y),ybins_hist);
hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
%normalize
hy = hy./sum(hy);
%%% transform to area plot to enable alpha property
%[yy, hy] = stairs([0 ybins+min(diff(ybins))/2],[hy, hy(end)]);
%bary(1) = bar(ybins,hy,'BarWidth',1,'FaceColor',[0 0 1],'EdgeColor',[0 0 1]);
stairsy(1) = stairs([0 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','b','LineWidth',2);
hold on;
%plot rest of histograms
for i = 2:num_species
    hy = hist(datatoplot{i}(:,y),ybins_hist);
    hy(end-1) = hy(end-1) + hy(end); hy(end) = [];
    %normalize
    hy = hy./sum(hy);
    %bary(i) = bar(ybins,hy,'BarWidth',1,'FaceColor',color{i-1},'EdgeColor',color{i-1});
    if i == 2 %%% plot red
        stairsy(i) = stairs([0 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','r','LineWidth',2);
    elseif i == 3 %%% plot green
        stairsy(i) = stairs([0 ybins+min(diff(ybins))/2],[hy, hy(end)],'Color','g','LineWidth',2);
    end
end
axis('tight');
set(gca,'View',[90 90],'XDir','reverse');
set(gca,'XAxisLocation','top','FontSize',20)
ylabel = get(gca,'YTick');
set(gca,'YTick',ylabel(2:end));

%set transparency of bar plots
% for i = 1:num_species
%     dummy_x = allchild(barx(i));
%     dummy_y = allchild(bary(i));
%     set(dummy_x,'FaceAlpha',0.33);
%     set(dummy_y,'FaceAlpha',0.33);
% end

function ManualCut(~,~)

h = guidata(gcbo);
global BurstData UserValues
set(gcf,'Pointer','cross');
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;           % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
set(gcf,'Pointer','Arrow');
point1 = point1(1,1:2);
point2 = point2(1,1:2);

if (all(point1(1:2) == point2(1:2)))
    'error'
    return;
end
    
if ~isfield(BurstData,'Cut')
    %initialize Cut Cell Array
    BurstData.Cut{1} = {};
    %add species to list
    BurstData.SpeciesNames{1} = 'Species 1';
    %update species list
    set(h.SpeciesList,'String',BurstData.SpeciesNames,'Value',1);
    BurstData.SelectedSpecies = 1;
end

species = get(h.SpeciesList,'Value');
BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListX,'Value')}, min([point1(1) point2(1)]),max([point1(1) point2(1)]), true,false};
BurstData.Cut{species}{end+1} = {BurstData.NameArray{get(h.ParameterListY,'Value')}, min([point1(2) point2(2)]),max([point1(2) point2(2)]), true,false};

UpdateCutTable(h);
UpdateCuts();
UpdatePlot;

function UpdateCutTable(h)

global BurstData
species = BurstData.SelectedSpecies;

if ~isempty(BurstData.Cut{species})
    data = vertcat(BurstData.Cut{species}{:});
    rownames = data(:,1);
    data = data(:,2:end);
else %data has been deleted, reset to default values
    data = {'','',false,false};
    rownames = {''};
end
    
set(h.CutTable,'Data',data,'RowName',rownames);

function UpdateCuts(species)

global BurstData
if nargin < 1
    species = BurstData.SelectedSpecies;
end
if ~isfield(BurstData,'Cut')
    return;
end

CutState = vertcat(BurstData.Cut{species}{:});
Valid = ones(size(BurstData.DataArray,1),1);
for i = 1:size(CutState,1)
    Index = find(strcmp(CutState(i,1),BurstData.NameArray));
    Valid = Valid & (BurstData.DataArray(:,Index) >= CutState{i,2}) & (BurstData.DataArray(:,Index) <= CutState{i,3});
end

BurstData.DataCut = BurstData.DataArray(Valid,:);

function SetAxes(hObject,~)
axes(hObject);

function CutTableChange(hObject,eventdata)
%this executes if a value in the CutTable is changed
h = guidata(gcbo);
global BurstData
%check which cell was changed
index = eventdata.Indices;
%change value in structure
NewData = eventdata.NewData;
switch index(2)
    case {1} %min boundary was changed
        if BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{3} < eventdata.NewData
            NewData = eventdata.PreviousData;
        end
    case {2} %max boundary was changed
        if BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{2} > eventdata.NewData
            NewData = eventdata.PreviousData;
        end
    case {3} %active/inactive change
        NewData = eventdata.NewData;
end

if index(2) ~= 4        
    BurstData.Cut{BurstData.SelectedSpecies}{index(1)}{index(2)+1}=NewData;
elseif index(2) == 4 %delete this entry
    BurstData.Cut{BurstData.SelectedSpecies}(index(1)) = [];
end
UpdateCutTable(h);
UpdateCuts();
UpdatePlot;

function PlotCorrections(~,~)
h = guidata(findobj('Tag','Bowser'));
global BurstData
S = find(strcmp(BurstData.NameArray,'Stoichiometry'));
E = find(strcmp(BurstData.NameArray,'Efficiency'));
T_threshold = 0.2;

cutT = 1;
if cutT == 0
    data_for_corrections = BurstData.DataArray;
elseif cutT == 1
    T = find(strcmp(BurstData.NameArray,'|TGX-TRR| Filter'));
    valid = (BurstData.DataArray(:,T) < T_threshold);
    data_for_corrections = BurstData.DataArray(valid,:);
end
%plot raw Efficiency for S>0.9
Smin = 0.9;
S_threshold = (data_for_corrections(:,S)>Smin);
x_axis = linspace(0,0.3,50);
BurstData.Corrections.histE_donly = histc(data_for_corrections(S_threshold,E),x_axis);
axes(h.axes_crosstalk);
cla(gca);
bar(x_axis, BurstData.Corrections.histE_donly,'BarWidth',1);
axis tight;
%fit single gaussian
mean_ct = GaussianFit(x_axis',BurstData.Corrections.histE_donly,1,1);
BurstData.Corrections.CrossTalk = mean_ct./(1-mean_ct);

%plot raw data for S > 0.3 for direct excitation
Smax = 0.2;
S_threshold = (data_for_corrections(:,S)<Smax);
x_axis = linspace(0,Smax,20);
BurstData.Corrections.histS_aonly = histc(data_for_corrections(S_threshold,S),x_axis);
axes(h.axes_direct_excitation);
cla(gca);
bar(x_axis, BurstData.Corrections.histS_aonly,'BarWidth',1);
axis tight;
%fit single gaussian
mean_de = GaussianFit(x_axis',BurstData.Corrections.histS_aonly,2,1);
BurstData.Corrections.DirectExcitation = mean_de./(1-mean_de);

%plot TFRET-TRED (or ALEX_2CDE)
T = find(strcmp(BurstData.NameArray,'|TGX-TRR| Filter'));
x_axis = linspace(0,1,50);
BurstData.Corrections.histTFRET = histc(BurstData.DataArray(:,T),x_axis);

x_threshold = find((x_axis-T_threshold)>0,1,'first');
axes(h.axes_artifacts);
cla(gca);
bar(x_axis(1:x_threshold), BurstData.Corrections.histTFRET(1:x_threshold),'BarWidth',1,'FaceColor',[0 0 0]);
hold on;
bar(x_axis(x_threshold+1:end), BurstData.Corrections.histTFRET(x_threshold+1:end),'BarWidth',1,'FaceColor',[1 1 1]);
hold off;
axis tight;

%plot gamma plot for two populations (or lifetime versus E)

function [mean] = GaussianFit(x_data,y_data,N_gauss,display,start_param)
if N_gauss == 1
    Gauss = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
    if nargin <5 %no start parameters specified
        A = max(y_data);%set amplitude as max value
        m = sum(y_data.*x_data)./sum(y_data);%mean as center value
        s = sqrt(sum(y_data.*(x_data-m).^2)./sum(y_data));%std as sigma
        b=0;%assume zero background
        param = [A,m,s,b];
    end
    gauss = fit(x_data,y_data,Gauss,'StartPoint',param);
    coefficients = coeffvalues(gauss);
    mean = coefficients(2);
elseif N_gauss == 2
    Gauss = @(A1,m1,s1,A2,m2,s2,b,x) A1*exp(-(x-m1).^2./s1^2)+A2*exp(-(x-m2).^2./s2^2)+b;
    if nargin <5 %no start parameters specified
        A1 = max(y_data);%set amplitude as max value
        A2 = A1;
        m1 = sum(y_data.*x_data)./sum(y_data);%mean as center value
        m2 = m1;
        s1 = sqrt(sum(y_data.*(x_data-m1).^2)./sum(y_data));%std as sigma
        s2 = s1;
        b=0;%assume zero background
        param = [A1,m1,s1,A2,m2,s2,b];
    end
    gauss = fit(x_data,y_data,Gauss,'StartPoint',param);
    coefficients = coeffvalues(gauss);
    %get maximum amplitude
    [~,Amax] = max([coefficients(1) coefficients(4)]);
    if Amax == 1
        mean = coefficients(2);
    elseif Amax == 2
        mean = coefficients(5);
    end
end
if display
    axes(gca);
    hold on;
    pfit = plot(gauss);
    set(pfit,'LineWidth',2);      
    if N_gauss == 2
        Gauss1 = @(A,m,s,b,x) A*exp(-(x-m).^2./s^2)+b;
        G1 = Gauss1(coefficients(1),coefficients(2),coefficients(3),coefficients(7),x_data);
        G2 = Gauss1(coefficients(4),coefficients(5),coefficients(6),coefficients(7),x_data);
        plot(x_data,G1,'LineStyle','--','Color','r');
        plot(x_data,G2,'LineStyle','--','Color','r');
    end
    hold off; 
end

function List_ButtonDownFcn(hObject,eventdata)
h = guidata(hObject);
global BurstData

if strcmpi(get(h.Figure,'SelectionType'),'open')
    %add a species to the list
    BurstData.SpeciesNames{end+1} = ['Species ' num2str(1+numel(get(hObject,'String')))];
    set(hObject,'String',BurstData.SpeciesNames);
    set(hObject,'Value',numel(get(hObject,'String')));
elseif strcmpi(get(h.Figure,'SelectionType'),'alt')
    if numel(get(hObject,'String')) > 1 %remove selected field
        val = get(hObject,'Value');
        BurstData.SpeciesNames(val) = [];
        set(hObject,'Value',val-1);
        set(hObject,'String',BurstData.SpeciesNames); 
    end
end
UpdateCutTable(h);
UpdateCuts();
UpdatePlot;

function List_KeyPressFcn(hObject,eventdata)

function UpdateCorrections()
global BurstData

function [Hout, Xbins, Ybins] = hist2d(D, varargin) %Xn, Yn, Xrange, Yrange)
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
