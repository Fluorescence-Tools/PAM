classdef ScrapBook < handle
    %%% Opens a simple figure with editbox and save option to take notes
    %% Public Properties
    properties
        EditHandle = [];
        creation_date = [];
        figure = [];
        GUIname = [];
        handles = [];
    end
    
    methods
        
        function obj = ScrapBook(GUIname)
            global UserValues;
            obj.GUIname = GUIname;
            obj.creation_date = char(datetime);
            screensize = get(0,'screensize');
            obj.figure = figure(...
                'Position',[screensize(3)*0.75,screensize(4)*0.5,screensize(3)*0.25,screensize(4)*0.5],...
                'Name',[obj.GUIname ' scrapbook - ' obj.creation_date],...
                'Toolbar','none',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Tag',[GUIname '_Scrapbook'],...
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
                'String',UserValues.ScrapBook.(obj.GUIname));
        end
        
        function obj = save(obj,~,~)
            %%% saves the contents of the edit box
            string = obj.EditHandle.String;
            [FileName,PathName,FilterIndex] = uiputfile('*.txt','Choose a location for the text file',fullfile(pwd,[obj.GUIname '_note.txt']));
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
            UserValues.ScrapBook.(obj.GUIname) = obj.EditHandle.String;
            delete(obj.figure);
            delete(obj);
        end
    end
end