function print_eps(hfig, filename)
% wrapper function to save figure contents as eps file.
% hfig:     Handle to figure
% filename: full path to file, including eps extension

% Make changing paper type possible
set(hfig,'PaperType','<custom>');

% Set units to all be the same
set(hfig,'PaperUnits','inches');
set(hfig,'Units','inches');

% Set the page size and position to match the figure's dimensions
position = get(hfig,'Position');
set(hfig,'PaperPosition',[0,0,position(3:4)]);
set(hfig,'PaperSize',position(3:4));
set(hfig,'InvertHardCopy', 'off');
print(hfig,filename,'-depsc','-painters')
