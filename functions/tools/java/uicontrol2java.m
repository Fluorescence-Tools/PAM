function jh = uicontrol2java(h_uicontrol)
% uicontrol2java returns references to the java components corresponding to the defined uicontrol
    % ----------------------------------------------------------------------------------------------
    %
    %                                   uicontrol2java
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/uicontrol2java.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % jh = uicontrol2java(h_uicontrol)
    % 
    % DESCRIPTION
    % -----------
    % jh = uicontrol2java(h_uicontrol) returns references to the java components corresponding to the
    % defined uicontrol with handle h_uicontrol. A number of different java components are
    % associated with the uicontrol. They are sorted in the cell array from parent to child. 
    % 
    % Copyright 2014
    % ==============================================================================================
    
    if verLessThan('matlab', '8.4')
        % this function does not work for older matlab versions
        % get the version number of the current installation.
        v = ver('matlab');
        % show the problem to the user
        errorbox(['The function ''' mfilename ''' does not work on your current matlab installation with version number ''' v.Version ''' ' v.Release '. Minimum version number required to run this function is ''8.4'' (R2014b).'], ...
                 'Unsupported version number', [mfilename ':Ver2low'])
    end
    
    % make sure that the input argument is a valid uicontrol
    if ~isgraphics(h_uicontrol) || ~strcmpi(h_uicontrol.Type, 'uicontrol')
        % the input is not a valid uicontrol object
        errorbox('The input argument is not a valid uicontrol.', 'Bad uicontrol', [mfilename ':BadUicontrol']);
    
    elseif isprop(h_uicontrol, 'jvhandle') && ~isempty(h_uicontrol.jvhandle)
        % values stored in the field 'jvhandle' correspond to the java components of the uipanel
        jh = h_uicontrol.jvhandle;
        
        % assume that the handle is still valid
%         try
%             % check the classes of the java components
%             chkjavaclasses(jh)
%            
%         catch
%             h_uicontrol.jvhandle = [];
%             jh = uicontrol2java(h_uicontrol);
%             return
%             
%         end
        
    else
        try
            % get the parent of the uicontrol
            parent = h_uicontrol.Parent;
            
            % set the class of the java component that is expected based on the style of the
            % uicontrol
            switch lower(h_uicontrol.Style)
                case 'text'
                    name = 'com.mathworks.hg.peer.LabelPeer';
                case 'slider'
                    name = 'com.mathworks.hg.peer.SliderPeer';
                case 'radiobutton'
                    name = 'com.mathworks.hg.peer.RadioButtonPeer';
                case 'pushbutton'
                    name = 'com.mathworks.hg.peer.PushButtonPeer';
                case 'popupmenu'
                    name = 'com.mathworks.hg.peer.ComboboxPeer';
                case 'listbox'
                    name = 'com.mathworks.hg.peer.ListboxPeer';
                case 'edit'
                    name = 'com.mathworks.hg.peer.EditTextPeer';
                case 'checkbox'
                    name ='com.mathworks.hg.peer.CheckboxPeer';
                otherwise
                    errorbox(['The uicontrol style ''' h_uicontrol.Style ''' is unsupported.'], 'Unsupported style', [mfilename ':UnsupStyle']);
            end
            
            if isfig(parent)
                % the parent is a figure
                temp = figure2java(parent);
            elseif ispanel(parent)
                % the parent is a uipanel
                temp = uipanel2java(parent);
            else %if strcmpi(parent.Type, 'uitab')
                % the parent is a uipanel
                temp = uitab2java(parent);
            end
            
            % get the last java component
            jparent = temp{end};
            
            ix = find(strcmpi(cellfun(@(x) char(x.getClass.getCanonicalName), num2cell(jparent.getComponents), 'uniformoutput', false), 'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.UIComponentLightweightContainer'))-1;
            if isempty(ix)
                % no UIComponentLightweightContainer found among the children
                errorbox('No uicontrol java component found.', 'Java component not found', [mfilename ':NoJavaCompFound']);
            else
                % get all the UIComponentLightweightContainers
                jh_all = arrayfun(@(x) jparent.getComponent(x), ix, 'uniformoutput', false)';
                
                % get for each component the children (with some constraints) such that the last
                % java component of each element is the component giving acces to the data
                jh_all = cellfun(@(x) getallcomponents(x), jh_all, 'uniformoutput', false);
                % get all those last components in a new cell array
                jh_last = cellfun(@(x) x{end}, jh_all, 'uniformoutput', false)';
                
                % filter these java components based on their Class.
                styles = cellfun(@(x) regexp(char(x.getClass.toString), 'class ([\w\.]*)\$*.*', 'tokens', 'once'), jh_last, 'uniformoutput', false);
                styles = vertcat(styles{:});
                ix = find(strcmpi(styles, name));
                jh_all = horzcat(jh_all{ix});
                jh_last = jh_last(ix);
                
                % get all properties of the uicontrols in a single structure
                s = cellfun(@(x) get(x), jh_last);
                
                % compare values with specified uicontrol
                switch lower(h_uicontrol.Style)
                    case 'text'
                        % For a reason that is unclear to me, the text property of the JLabel can
                        % not be retrieved. Find the proper uicontrol based on its offset
                        
                        % Find the proper uicontrol based on its dimensions (offset and size). This
                        % function requires the top-level java components of the uicontrols
                        ix = getcompbydim(h_uicontrol, jh_all(1,:));
                        jh = jh_all(:,ix);
                        
                    case 'slider'
                        % Find the proper uicontrol based on its offset. This function requires the
                        % top-level java components of the uicontrols
                        
                        % Find the proper uicontrol based on its dimensions (offset and size). This
                        % function requires the top-level java components of the uicontrols
                        ix = getcompbydim(h_uicontrol, jh_all(1,:));
                        jh = jh_all(:,ix);
                        
                    case 'radiobutton'
                        
                        ix = strcmp(h_uicontrol.String, {s.Text}) & [s.Enabled] == ison(h_uicontrol.Enable) & [s.Selected] == ison(h_uicontrol.Value);
                        
                        if nnz(ix) == 1
                            % only one uicontrol left. ok.
                            jh = jh_all(:,ix);
                        else
                            % Find the proper uicontrol based on its dimensions (offset and size). This
                            % function requires the top-level java components of the uicontrols
                            ix = getcompbydim(h_uicontrol, jh_all(1,:));
                            jh = jh_all(:,ix);
                        end
                        
                    case 'pushbutton'
                        ix = strcmp(h_uicontrol.String, {s.Text}) & [s.Enabled] == ison(h_uicontrol.Enable);
                        
                        if nnz(ix) == 1
                            % only one uicontrol left. ok.
                            jh = jh_all(:,ix);
                        else
                            % Find the proper uicontrol based on its dimensions (offset and size). This
                            % function requires the top-level java components of the uicontrols
                            ix = getcompbydim(h_uicontrol, jh_all(1,:));
                            jh = jh_all(:,ix);
                        end
                        
                    case 'popupmenu'
                        str = cellfun(@getlistfromJComboBox, jh_last, 'uniformoutput', false);
                        template = h_uicontrol.String;
                        % compare the strings
                        ix = cellfun(@(x) isequal(x, template), str);
                        
                        if nnz(ix) == 1
                            % only one uicontrol left. ok.
                            jh = jh_all(:,ix);
                        else
                            % Find the proper uicontrol based on its dimensions (offset and size). This
                            % function requires the top-level java components of the uicontrols
                            ix = getcompbydim(h_uicontrol, jh_all(1,:));
                            jh = jh_all(:,ix);
                        end
                        
                    case 'listbox'
                        % get the strings in the listboxes
                        str = cellfun(@(x) cell(x.getModel.toArray), jh_last, 'uniformoutput', false);
                        % get the strings from the uicontrol
                        template = h_uicontrol.String;
                        % compare the strings
                        ix = cellfun(@(x) isequal(x, template), str);
                        
                        if nnz(ix) == 1
                            % only one uicontrol left. ok.
                            jh = jh_all(:,ix);
                        else
                            % Find the proper uicontrol based on its dimensions (offset and size). This
                            % function requires the top-level java components of the uicontrols
                            ix = getcompbydim(h_uicontrol, jh_all(1,:));
                            jh = jh_all(:,ix);
                        end
                        
                    case 'edit'
                        if (h_uicontrol.Max-h_uicontrol.Min) > 1
                            % multiline case
                            str = h_uicontrol.String;
                            ix = strcmp([str{:}], {s.Text}) & ~[s.Enabled] == ~isoff(h_uicontrol.Enable);
                        else
                            % enable is special case
                            ix = strcmp(h_uicontrol.String, {s.Text}) & ~[s.Enabled] == ~isoff(h_uicontrol.Enable);
                        end
                        
                        if nnz(ix) == 1
                            % only one uicontrol left. ok.
                            jh = jh_all(:,ix);
                        else
                            % Find the proper uicontrol based on its dimensions (offset and size). This
                            % function requires the top-level java components of the uicontrols
                            ix = getcompbydim(h_uicontrol, jh_all(1,:));
                            jh = jh_all(:,ix);
                        end
                        
                    case 'checkbox'
                        ix = strcmp(h_uicontrol.String, {s.Text}) & (h_uicontrol.Value == [s.Selected]) & [s.Enabled] == ison(h_uicontrol.Enable);
                        if nnz(ix) == 1
                            % only one uicontrol left. ok.
                            jh = jh_all(:,ix);
                        else
                            % Find the proper uicontrol based on its dimensions (offset and size). This
                            % function requires the top-level java components of the uicontrols
                            ix = getcompbydim(h_uicontrol, jh_all(1,:));
                            jh = jh_all(:,ix);
                        end
                        
                    otherwise
                        errorbox(['The uicontrol style ''' h_uicontrol.Style ''' is unsupported.'], 'Unsupported style', [mfilename ':UnsupStyle']);
                end
            end
                        
            % stored the references to the java components of the uipanel in the field 'jvhandle'
            if ~isprop(h_uicontrol, 'jvhandle')
                % the field 'jvhandle' does not exist yet.
                h_uicontrol.addprop('jvhandle');
            end
            h_uicontrol.jvhandle = jh;
            
        catch ME
            
            nME.message = ['The java component that belongs to the uipanel could not be resolved. The following error message occurred:' char(10) ME.message];
            errorbox(nME, 'uipanel to java conversion failed.', [mfilename ':BadJavaClasses'])
        end
    end
    
end % end of function 'uicontrol2java'


%% -------------------------------------------------------------------------------------------------
function list = getallcomponents(parent)
    % this function returns all java children components of the given parent.
    
    % save the current component to the list
    list = {parent};
    
    if any(strcmpi(parent.getClass.getCanonicalName, {'com.mathworks.hg.peer.ComboboxPeer.MLComboBox'; ...
                                                      'com.mathworks.hg.peer.SliderPeer.MLScrollBar';...
                                                      'com.mathworks.hg.peer.ListboxPeer.UicontrolList'}));
        % don't proceed any further
        return
    else
        % get the number of children
        c = parent.getComponentCount;
        
        if c== 0
            % no child
            return
            
        elseif c == 1
            % only one child
            temp = getallcomponents(parent.getComponent(0));
            if ~isempty(temp)
                list((end+1):(end+length(temp)),1) = temp;
            end
            
        elseif strcmpi(parent.getClass.getCanonicalName, 'com.mathworks.hg.peer.utils.UIScrollPane')
            ix = find(strcmpi(cellfun(@(x) char(x.getClass.getCanonicalName), num2cell(parent.getComponents), 'uniformoutput', false), 'javax.swing.JViewport'))-1;
            if isempty(ix)
                % no JViewport found among the children
                errorbox('No JViewport component found for the listbox.', 'JViewport not found', [mfilename ':NoJViewportFound']);
            else
                temp = getallcomponents(parent.getComponent(ix));
                if ~isempty(temp)
                    list((end+1):(end+length(temp)),1) = temp;
                end
            end
            
        else
             errorbox(['The uicontrol style ''' h_uicontrol.Style ''' is unsupported.'], 'Unsupported style', [mfilename ':UnsupStyle']);
        end
        
    end
    
end % end of subfunction 'getallcomponents'


%% -------------------------------------------------------------------------------------------------
function txtlist = getlistfromJComboBox(jcomp)
    % returns the list of a popupmenu (actualy a combobox)
    
    txtlist = cell(jcomp.getItemCount,1);
    
    for m = 1 : jcomp.getItemCount
        txtlist{m} = char(jcomp.getItemAt(m-1));
    end
    
end % end of subfunction 'getlistfromJComboBox'


%% -------------------------------------------------------------------------------------------------
function ix = getcompbydim(h_uicontrol, jcomps)
    % returns the java component with the best agreement with the position of the uitabgroup
    
    % get the component with the offset closed to that of the uitabgroup
    ix = getcompbyoffset(h_uicontrol, jcomps);
    if numel(ix) == 1
        return
    else
        jcomps = jcomps(ix);
        % Find the proper java control by size
        ix = getcompbysize(h_uicontrol, jcomps);
    end
    
end % end of subfunction 'getcompbydim'


%% -------------------------------------------------------------------------------------------------
function ix = getcompbyoffset(h_uicontrol, jcomps)
    % returns the java component with the smallest distance between its offset and the offset of the
    % uicontrol.
    
    if ~iscolumn(jcomps)
        jcomps = jcomps';
    end
    
    % get the java offsets
    offset = cellfun(@getjpixelposition, jcomps, 'uniformoutput', false);
    offset = vertcat(offset{:});
    
    % get matlab offset
    offset_uicontrol = getuicontrolpos(h_uicontrol);
    
    % do the calculation
    [~, ix] = min(sqrt(bsxfun(@minus, offset_uicontrol(1), offset(:,1)).^2 + bsxfun(@minus, offset_uicontrol(2), offset(:,2)).^2));
    
end % end of subfunction 'getcompbyoffset'

%% -------------------------------------------------------------------------------------------------
function ix = getcompbysize(h_uicontrol, jcomps)
    % returns the java component with the smallest deviation of its size to the size of the
    % uicontrol.
    
    if ~iscolumn(jcomps)
        jcomps = jcomps';
    end
    
    % get the java sizes
    jsize = cellfun(@getjpixelsize, jcomps, 'uniformoutput', false);
    jsize = vertcat(jsize{:});
    
    % get the matlab sizes
    size_uicontrol = getuicontrolsize(h_uicontrol);
    
    % do the calculation
    [~, ix] = min(sqrt(bsxfun(@minus, size_uicontrol(1), jsize(:,1)).^2 + bsxfun(@minus, size_uicontrol(2), jsize(:,2)).^2));
    
end % end of subfunction 'getcompbysize'


%% -------------------------------------------------------------------------------------------------
function offset = getjpixelposition(jcomp)
    % returns the offset of the java component in matlab pixel coordinates
    
    jparent = jcomp.getParent;
    offset = [jcomp.getX jparent.getHeight-jcomp.getY-jcomp.getHeight]+1;
    
end % end of subfunction 'getjpixelposition'


%% -------------------------------------------------------------------------------------------------
function offset = getjpixelsize(jcomp)
    % returns the size (X, Y) of the java component in matlab pixel coordinates
    
    offset = [jcomp.getWidth jcomp.getHeight];
    
end % end of subfunction 'getjpixelsize'


%% -------------------------------------------------------------------------------------------------
function offset = getuicontrolpos(h_uicontrol)
    % returns the offset of the uicontrol in matlab pixel coordinates
    
    % get the current position units to reset afterwards
    old_units = h_uicontrol.Units;
    % set the units to pixels
    h_uicontrol.Units = 'pixels';
    % retrieve the offset
    offset = h_uicontrol.Position(1:2);
    % restore the units
    h_uicontrol.Units = old_units;
    
end % end of subfunction 'getuicontrolpos'


%% -------------------------------------------------------------------------------------------------
function offset = getuicontrolsize(h_uicontrol)
    % returns the size (X,Y) of the uicontrol in matlab pixel coordinates
    
    % get the current position units to reset afterwards
    old_units = h_uicontrol.Units;
    % set the units to pixels
    h_uicontrol.Units = 'pixels';
    % retrieve the offset
    offset = h_uicontrol.Position(3:4);
    % restore the units
    h_uicontrol.Units = old_units;
    
end % end of subfunction 'getuicontrolsize'