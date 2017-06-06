classdef FileHistory < handle
    %% Implements a simple file history list
    %  
    %  Add a field to the UserValues with the name of your GUI in 
    %  UserValues.File.FileHistory and call FileHistory with arguments:
    %
    %  container:     parent container of the listbox (i.e. a panel)
    %  GUIname:       the name of the GUI as string. This needs to be
    %                 identical with the name chosen for the UserValues 
    %                 FileHistory field
    %  load_function: load_function for data files. Needs to accept a cell
    %                 array of full paths to the files.
    %
    %  To add new files to the FileHistory on load, call the add_file
    %  method on the constructed object with string input. For multiple
    %  files, call the method multiple times.
    %% Public properties
    properties
        FileList;
        listHandle = [];
        load_function;
        GUIname = [];
    end
    
    methods
        
        function obj = FileHistory(container,GUIname,load_function)
            global UserValues
            filenames = UserValues.File.FileHistory.(GUIname);
            obj.FileList = filenames;
            obj.load_function = load_function;
            obj.GUIname = GUIname;
            filenamestring = [];
            if ~isempty(filenames)
                for i = 1:numel(filenames)
                    [pn,fn,ext] = fileparts(filenames{i});
                    fn = [fn,ext];
                    filenamestring{end+1} = [fn ' (path:' pn ')'];
                end
            end
            
            obj.listHandle = uicontrol(...
            'Parent',container,...
            'Tag','Database_List',...
            'Style','listbox',...
            'Units','normalized',...
            'FontSize',12,...
            'Max',2,...
            'String',filenamestring,...
            'BackgroundColor', UserValues.Look.List,...
            'ForegroundColor', UserValues.Look.ListFore,...
            'Callback',{@Database,obj},...
            'KeyPressFcn',{@Database,obj},...
            'Tooltipstring', ['<html>'...
                          'File history<br>',...
                          '<i>"return"</i>: Loads selected files<br>',...
                          '<I>"delete"</i>: Removes selected files from list </b>'],...
            'Position',[0.01 0.01 0.98 0.98]);
            
        end
        
        
        
        function obj = add_file(obj,new_file)
            if ~isempty(obj.FileList)
                if strcmp(new_file,obj.FileList{1})
                    %%% do not add if file is already in position 1
                    return;
                end
            end
            if sum(strcmp(new_file,obj.FileList)) > 0
                %%% file exists already, remove it from its old position
                pos = find(strcmp(new_file,obj.FileList));
                obj.FileList(pos) = [];
            end
            %%% add the new file to the top
            obj.FileList = [{new_file}, obj.FileList];
            
            if numel(obj.FileList) > 20 %%% only keep 20 files
                obj.FileList = obj.FileList(1:20);
            end
            
            filenamestring = [];
            for i = 1:numel(obj.FileList)
                [pn,fn,ext] = fileparts(obj.FileList{i});
                fn = [fn,ext];
                filenamestring{end+1} = [fn ' (path:' pn ')'];
            end
            obj.listHandle.String = filenamestring;
        end
        
        function delete(obj)
            global UserValues
            %%% store in UserValues
            UserValues.File.FileHistory.(obj.GUIname) = obj.FileList;
            delete(obj);
        end
    end
end

function Database(hList,e,obj)
switch e.EventName
    case 'KeyPress' %%% key press
        switch e.Key
            case 'return'
                obj.load_function(obj.FileList(hList.Value));
        end
    case 'Action' %%% mouse-click
        switch get(gcf,'SelectionType')
            case 'open' %%% double click
                obj.load_function(obj.FileList(hList.Value));
        end
end
end