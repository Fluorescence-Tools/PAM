function update_and_resize(obj)
% update_and_resize performs a full update of the progress bar elements
    % ----------------------------------------------------------------------------------------------
    %
    %                                  update_and_resize
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/@progress_obj/update_and_resize.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % update_and_resize(obj)
    % 
    % DESCRIPTION
    % -----------
    % update_and_resize(obj) performs a full update of the progress bar elements. It uses the
    % information stored in the progress_obj to modify the components.
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % no parsing of input argument required
    
    
    % EXECUTION
    % ---------
    
    if ~obj.isvalid
        return
    end
    
    % store the required dimensions in the handle of the parent to prevent repetitive execution
    if ~isprop(obj.parent, 'PROGRESS_BAR_GUI_SETTINGS')
        % the field 'PROGRESS_BAR_GUI_SETTINGS' does not exist yet.
        
        obj.parent.addprop('PROGRESS_BAR_GUI_SETTINGS');
        % set default dimensions of the progressbar elements
        gui.border_offset_x = cm2pixels(0.4);  % space between left side of figure and waitbar
        gui.border_offset_y = cm2pixels(0.4);  % space between bottom of figure and the waitbar
        gui.txt_offset_y    = cm2pixels(0.0);  % vertical offset of the text from the top of the waitbar
        gui.txt_height      = strheight(obj.parent);  % height of the text
        gui.wb_height       = cm2pixels(0.55); % height of waitbar
        gui.btn_height      = cm2pixels(0.55); % height of the cancel button
        gui.btn_space       = cm2pixels(0.3);  % space between waitbar and cancel button
        gui.wb_parent_width = cm2pixels(9.5);  % minimum width of waitbar figure
        gui.section_height  = gui.txt_offset_y + gui.wb_height + gui.txt_height; % height of one waitbar section
        
        % create a typical cancel button
        cancel_btn = uicontrol('parent', obj.parent, 'style', 'pushbutton', 'string', 'Cancel', 'units', 'pixels', 'horizontalalignment', 'center');
        
        % get size of 'cancel'. The two extra c are to accomodate shape of button
        gui.cancel_width = strwidth(obj.parent, 'Cancelcc');
        % remove the cancel button
        delete(cancel_btn);
        
        % store the required dimensions in the handle of the parent
        obj.parent.PROGRESS_BAR_GUI_SETTINGS = gui;
        
        if ~isprop(obj.parent, 'PROGRESS_BAR_GUI_max_str_length')
            obj.parent.addprop('PROGRESS_BAR_GUI_max_str_length');
        end
        obj.parent.PROGRESS_BAR_GUI_max_str_length = 1;
        
    else
        % retrieve the required dimensions from the handle
        gui = obj.parent.PROGRESS_BAR_GUI_SETTINGS;
    end
    
    % get the list of all objects
    obj_list = obj.parent.progress_obj;
    
    if isempty(obj_list)
        close(obj.parent);
        % nothing to show. Close the figure and return.
        return
    end
        
    % get the available width in the current waitbar parent
    oldW = obj.parent.Position(3);
    
    % get the longest message
    [~, ix] = max(cellfun(@length, {obj_list.message}'));
    
    if length(obj_list(ix).message) ~= obj.parent.PROGRESS_BAR_GUI_max_str_length
        % store the number of characters of this message
        obj.parent.PROGRESS_BAR_GUI_max_str_length = length(obj_list(ix).message);
        
        % get the length of this longest message (in pixels)
        max_msg_width = strwidth(obj.parent, obj_list(ix).message);
        
        W = min(max(gui.wb_parent_width, max_msg_width+2*gui.border_offset_x), 1800);
        
    else
        W = oldW;
        
    end
    
    % start with the offset
    v_offset = gui.border_offset_y;
    h_offset = gui.border_offset_x;
    
    % is there a cancel button
    if any([obj_list.show_cancel_btn])
        % at least 1 cancel button is shown
        
        % get size of 'cancel'. The two extra c are to accomodate shape of button
%         gui.cancel_width = strwidth(obj.parent, 'cancelccc');
        
        % get the default position of the waitbar
        default_bar_pos = [h_offset 0 W-2*gui.border_offset_x-gui.cancel_width-gui.btn_space gui.wb_height];
        
        % get the default position of the cancel button
        default_cancel_pos = [default_bar_pos(1)+default_bar_pos(3)+gui.btn_space -0.2 gui.cancel_width gui.btn_height];
    
    else
        % get the default position of the waitbar
        default_bar_pos = [h_offset 0 W-2*gui.border_offset_x gui.wb_height];
        
    end
    
    % get the default position of the message text
    default_message_pos = [default_bar_pos(1) default_bar_pos(2)+default_bar_pos(4)+gui.txt_offset_y W-2*gui.border_offset_x gui.txt_height];
    
    for m = length(obj_list):-1:1
        % starting from bottom up.
        
        if isempty(obj_list(m).progressbar)
            % add the waitbar
            
            if strcmpi(obj_list(m).waitbar_type, 'java')
                % a Jprogressbar will be used
                
                % invoke the jave object constructor
                jw = javaObjectEDT('javax.swing.JProgressBar');
                
                % create the waitbar
                [obj_list(m).progressbar{1,2}, obj_list(m).progressbar{1,1}] = javacomponent(jw, default_bar_pos + [0 v_offset 0 0], obj.parent);
                obj_list(m).progressbar{1,1}.Units = 'pixels';
                
            else
                
            end
        end
        
        % set the progress bar to the required value
        if isempty(obj_list(m).fraction)
            obj_list(m).progressbar{1,2}.setIndeterminate(true);
        else
            obj_list(m).progressbar{1,2}.setIndeterminate(false);
            obj_list(m).progressbar{1,2}.setValue(obj_list(m).fraction*100);            
        end
        
        % adjust the position of the bar
        obj_list(m).progressbar{1,1}.Position = default_bar_pos + [0 v_offset 0 0];
        
        if obj_list(m).show_cancel_btn
            if isempty(obj_list(m).cancel_btn)
                obj_list(m).cancel_btn = uicontrol('parent', obj.parent, 'style', 'pushbutton', 'string', 'Cancel', 'units', 'pixels', 'horizontalalignment', 'center', 'callback', @(~,~) obj.halt);
            end
            obj_list(m).cancel_btn.Position = default_cancel_pos + [0 v_offset 0 0];
        end
        
        if ~isempty(obj_list(m).message)
            if isempty(obj_list(m).message_text)
                obj_list(m).message_text = uicontrol('parent', obj.parent, 'style', 'text', 'units', 'pixels', 'horizontalalignment', 'left');
            end
            obj_list(m).message_text.String = obj_list(m).message;
            obj_list(m).message_text.Position = default_message_pos + [0 v_offset 0 0];
            v_offset = sum(obj_list(m).message_text.Position([2 4])) + ((gui.txt_offset_y+4)*2);
        else
            if ~isempty(obj_list(m).message_text)
                delete(obj_list(m).message_text)
                obj_list(m).message_text = [];
            end
            v_offset = sum(obj_list(m).progressbar{1,1}.Position([2 4])) + ((gui.txt_offset_y+4)*2);
            
        end
        
    end
    
    
    if isequal(obj.parent.Type, 'figure')
        obj.parent.Units = 'pixels';
        pos = obj.parent.Position;
        
        if isempty(obj_list(1).message_text)
            newheight = sum(obj_list(1).progressbar{1,1}.Position([2 4])) + gui.border_offset_y;
        else
            newheight = sum(obj_list(1).message_text.Position([2 4])) + gui.border_offset_y;
        end
        
        pos([2 4]) = [pos(2)-(newheight-pos(4)) newheight];
        pos(3) = pos(3) + W - oldW;
        obj.parent.Position = pos;
    end
    
    % show the result
    drawnow('nocallbacks');
    
end % end of function 'update_and_resize'