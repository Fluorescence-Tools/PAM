function Progress(Fraction,Axes,Progress_Text,TypeString)
persistent Lastupdate Starttime Progresspatch


%% Only updates every 10 ms
if ~isempty(Lastupdate) && etime(clock,Lastupdate) < 0.01 && Fraction<1
    return    
end

%% Resets last update time
Lastupdate=clock;

%% Uses standard inputs, if none were given
if nargin<4 || isempty(TypeString)
   TypeString = 'Calculating:'; 
end
if nargin<3 || isempty(Progress_Text)
    Progress_Text=handle(findobj('Tag','Progress_Text_Substitute'));
end
if nargin<2 || isempty(Axes)
    Axes=handle(findobj('Tag','Progress_Axes_Substitute'));
end
if nargin<1
    Fraction=0;
end

%% Defines start time and deletes old figure
if isempty(Starttime) || Fraction ==0
    delete(findobj('Tag','Progress_Figure'));
    if ~isempty(Progresspatch)
        delete(Progresspatch);
    end
    Progresspatch=[];   
    Starttime=clock;
end

%% Initializes figure and axes if none exists/was deleted
if isempty(Axes) || ~ishandle(Axes)
   h=figure(...
        'Units',            'normalized',...
        'Position',         [0.4 0.5 0.2 0.02],...
        'Tag',              'Progress_Figure',...
        'NumberTitle',      'off',...
        'Resize',           'off',...
        'MenuBar',          'none',...
        'BackingStore',     'off');
   Axes = handle(axes(....
        'Parent',h,...
        'Tag',              'Progress_Axes_Substitute',...
        'Units',            'normalized',...
        'ytick',            [],...
        'xtick',            [],...
        'Position',         [0 0 1 1]));

end
Axes.XLim=[0 1];Axes.YLim=[0 1];
 
%% Initializes text if none exists/was deleted
if isempty(Progress_Text) || ~ishandle(Progress_Text)
   Progress_Text = handle(text(...
        'Units',            'normalized',...
        'FontSize',         12,...
        'FontWeight',       'bold',...
        'Position',         [0.5 0.5],...
        'Tag',              'Progress_Text_Substitute',...
        'String',           [TypeString, '0%'],...
        'Color',            [0 0 0]));
end

%% Initializes progress patch if none exists/was deleted
if isempty(Progresspatch) || ~ishandle(Progresspatch)
    Progresspatch=handle(patch(...
        'parent',           findobj(Axes,'-depth',0),...
        'XData',            [0 0 0 0],...
        'YData',            [0 0 1 1],...
        'Edgecolor',        [1 0 0],...
        'FaceColor',        [1 0 0]));
    uistack(Progresspatch,'bottom');
end

%% Does actual work
if Fraction>=1
    %% Delets figure, patch and resets persistent variables
    Progress_Text.String = 'Done';
    delete(Progresspatch);
    delete(findobj('Tag','Progress_Text_Substitute'));    
    delete(findobj('Tag','Progress_Figure'));
    Progresspatch=[];
    Starttime=[];
    Lastupdate=[];    
    
    %%% Added: Reset Mouse Pointer to Arrow
    set(gcf, 'pointer', 'arrow'); drawnow;
else
    %% Updates patch and text
    Progresspatch.XData([2 3])=Fraction;
    RunTime=etime(clock,Starttime);
    TimeLeft=RunTime/Fraction-RunTime;
    TimeLeftStr = sec2timestr(TimeLeft);
    Progress_Text.String = sprintf([TypeString ' %2d%%    %s remaining'],floor(100*Fraction),TimeLeftStr);
    %%% Added: Change Mouse Pointer to Wheel
    set(gcf, 'pointer', 'watch'); drawnow;
end
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convert a time measurement from seconds into a human readable string %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timestr = sec2timestr(sec)
% Convert seconds to other units
d = floor(sec/86400); % Days
sec = sec - d*86400;
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

% Create time string
if d > 0
    if d > 9
        timestr = sprintf('%d day',d);
    else
        timestr = sprintf('%d day, %d hr',d,h);
    end
elseif h > 0
    if h > 9
        timestr = sprintf('%d hr',h);
    else
        timestr = sprintf('%d hr, %d min',h,m);
    end
elseif m > 0
    if m > 9
        timestr = sprintf('%d min',m);
    else
        timestr = sprintf('%d min, %d sec',m,s);
    end
else
    timestr = sprintf('%d sec',s);
end

