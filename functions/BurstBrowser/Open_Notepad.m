function Open_Notepad(~,~)
%%% Check whether notepad is open
notepad = findobj('Tag','BurstBrowser_Notepad');
if isempty(notepad)
    Notepad('BurstBrowser');
else
    figure(notepad);
end