classdef Notepad < handle
    %%% Opens a simple figure with editbox and save option to take notes
    %%%
    %%% Call with the input string of the name of the respective GUI
    %%%
    %%% Requires implementation of a UserValues field in UserValues.Notepad.(GUIname)
    %%% The figure can be found via its GUIname specific Tag of GUIname_Notepad.
    %%%
    %%% Implement the following callback in your GUI to open the notepad:
    %%%
    %%% function Open_Notepad(~,~)
    %%% %%% Check whether notepad is open
    %%% notepad = findobj('Tag','GUIname_Notepad');
    %%% if isempty(notepad)
    %%%     Notepad('GUIname');
    %%% else
    %%%     figure(notepad);
    %%% end
    %% Public Properties
    properties
        EditHandle = [];
        creation_date = [];
        figure = [];
        GUIname = [];
        handles = [];
    end
    
    methods
        
        function obj = Notepad(GUIname)
            global UserValues;
            obj.GUIname = GUIname;
            obj.creation_date = char(datetime);
            screensize = get(0,'screensize');
            obj.figure = figure(...
                'Position',[screensize(3)*0.75,screensize(4)*0.5,screensize(3)*0.25,screensize(4)*0.5],...
                'Name',[obj.GUIname ' notepad - ' obj.creation_date],...
                'Toolbar','none',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Tag',[GUIname '_Notepad'],...
                'CloseRequestFcn',@obj.close_function);
            obj.handles.contextmenu = uicontextmenu;
            obj.handles.save_menu = uimenu(...
                'Parent',obj.handles.contextmenu,...
                'Label','Save contents',...
                'Callback',@obj.save);
            obj.EditHandle = uicontrol(...
                'Style','edit',...
                'Parent',obj.figure,...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Max',1000,...
                'FontSize',12,...
                'HorizontalAlignment','left',...
                'UIContextMenu',obj.handles.contextmenu,...
                'String',UserValues.Notepad.(obj.GUIname));
        end
        
        function obj = save(obj,~,~)
            %%% saves the contents of the edit box
            string = obj.EditHandle.String;
            [FileName,PathName,FilterIndex] = uiputfile('*.txt','Choose a location for the text file',fullfile(pwd,[obj.GUIname '_notes.txt']));
            if FilterIndex == 0
                return;
            end
            fileID = fopen(fullfile(PathName,FileName),'w');
            for i = 1:size(string,1)
                fprintf(fileID,'%s\n',string(i,:));
            end
            fclose(fileID);
        end
        
        function close_function(obj,~,~)
            global UserValues
            UserValues.Notepad.(obj.GUIname) = obj.EditHandle.String;
            delete(obj.figure);
            delete(obj);
        end
    end
end