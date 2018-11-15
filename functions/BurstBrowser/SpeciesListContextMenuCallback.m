function SpeciesListContextMenuCallback(hTree,eventData,jmenu)
if eventData.isMetaDown  % right-click is like a Meta-button
  % Get the clicked node
  clickX = eventData.getX;
  clickY = eventData.getY;
  jtree = eventData.getSource;
  
  % Display the (possibly-modified) context menu
  jmenu.show(jtree, clickX, clickY);
  jmenu.repaint;
end