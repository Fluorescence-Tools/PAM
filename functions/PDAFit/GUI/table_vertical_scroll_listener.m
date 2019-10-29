function table_vertical_scroll_listener(scr,event,tables)
% synchronize the vertical scroll bar position
pos = scr.getVerticalScrollBar.getValue./scr.getVerticalScrollBar.getMaximum;
tables.FitTable_JScrollPane.getVerticalScrollBar.setValue(pos*tables.FitTable_JScrollPane.getVerticalScrollBar.getMaximum);
tables.KineticRatesTable_JScrollPane.getVerticalScrollBar.setValue(pos*tables.KineticRatesTable_JScrollPane.getVerticalScrollBar.getMaximum);

