function color = color_setter()
    %%% opens a GUI to input a color as RGB triplet
    d = dialog('Position',[300 300 300 100],'Name','Please specify a color');

    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[10 60 300 25],...
           'HorizontalAlignment','center',...
           'FontSize',12,...
           'String','Specify a color as RGB triplet in the range [0,1]:');

    table = uitable('Parent',d,'Data',[0,0,1],'Position',[15,30,270,21],...
        'RowName',[],'ColumnName',[],'ColumnEditable',true,...
        'CellEditCallback',@check_value,'ColumnWidth',{85,85,85},...
        'ColumnFormat',{'numeric','numeric','numeric'});

    button = uicontrol('Parent',d,'Style','pushbutton',...
        'Position',[100,5,100,20],'String','Accept',...
        'Callback','delete(gcf)');
    color = table.Data;
    % Wait for d to close before running to completion
    uiwait(d);

    function check_value(htable,event)
      val = event.NewData;
      if val > 1
          htable.Data(event.Indices(1),event.Indices(2)) = 1;
      end
      if val < 0
          htable.Data(event.Indices(1),event.Indices(2)) = 0;
      end
      color = htable.Data;
    end
    
end


