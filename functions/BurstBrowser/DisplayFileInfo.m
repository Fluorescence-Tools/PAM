function DisplayFileInfo(~,~)
global BurstMeta BurstData

fid = fopen(fullfile(BurstData{BurstMeta.SelectedFile}.PathName,[BurstData{BurstMeta.SelectedFile}.FileName(1:end-3) 'txt']));
if fid == -1
    disp('No file info found.');
    return;
end
screensize = get(0,'screensize');

f = figure('menu','none','toolbar','none',...
    'numbertitle','off','name','',...
    'Units','pixels',...
    'Position',[screensize(3)/2-300,screensize(4)/2-400,600,800]);
ph = uipanel(f,'Units','normalized','position',[0 0 1 1],'title',...
    ['File Info for ' BurstData{BurstMeta.SelectedFile}.FileName],'FontSize',12);
lbh = uicontrol(ph,'style','edit','Units','normalized','position',...
    [0 0 1 1],'FontSize',12,'HorizontalAlignment','left');
indic = 1;
while 1
     tline = fgetl(fid);
     if ~ischar(tline), 
         break
     end
     strings{indic}=tline; 
     indic = indic + 1;
end
fclose(fid);
set(lbh,'Max',numel(strings));
set(lbh,'string',strings);