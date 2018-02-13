function jh = uitabgroup2java(h_uitabgroup)
% uitabgroup2java returns references to the java components corresponding to the defined uitabgroup
    % ----------------------------------------------------------------------------------------------
    %
    %                                    uitabgroup2java
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/uitabgroup2java.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % jh = uitabgroup2java(h_uitabgroup)
    % 
    % DESCRIPTION
    % -----------
    % jh = uitabgroup2java(h_uitabgroup) returns references to the java components corresponding to
    % the defined uitabgroup with handle h_uitabgroup. Four different java components are associated
    % with the uitabgroup. They are sorted in the cell array from parent to child. 
    % 
    % Copyright 2014-2017
    % ==============================================================================================
    
    if verLessThan('matlab', '8.4')
        % this function does not work for older matlab versions
        % get the version number of the current installation.
        v = ver('matlab');
        % show the problem to the user
        errorbox(['The function ''' mfilename ''' does not work on your current matlab installation with version number ''' v.Version ''' ' v.Release '. Minimum version number required to run this function is ''8.4'' (R2014b).'], ...
                 'Unsupported version number', [mfilename ':Ver2low'])
    end
    
    
    % make sure that the input argument is a valid uitabgroup
    if ~isgraphics(h_uitabgroup) || ~strcmpi(h_uitabgroup.Type, 'uitabgroup')
        % the input is not a valid uitabgroup
        errorbox('The input argument is not a valid uitabgroup.', 'Bad uitabgroup', [mfilename ':BadUITabgroup']);
    
    elseif isprop(h_uitabgroup, 'jvhandle') && ~isempty(h_uitabgroup.jvhandle);
        % values stored in the field 'jvhandle' correspond to the java components of the uipanel
        jh = h_uitabgroup.jvhandle;
        
        try
            % check the classes of the java components
            chkjavaclasses(jh)
           
        catch
            h_uitabgroup.jvhandle = [];
            jh = uipanel2java(h_uitabgroup);
            return
            
        end
        
    else
        try
            % get the parent of the uitabgroup
            parent = h_uitabgroup.Parent;
            
            if isfig(parent)
                % the parent is a figure
                temp = figure2java(parent);
            else
                % the parent is a uipanel
                temp = uipanel2java(parent);
            end
            
            % get the last java component
            jparent = temp{end};
            
            ix = find(strcmpi(cellfun(@(x) char(x.getClass.getCanonicalName), num2cell(jparent.getComponents), 'uniformoutput', false), 'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.UIComponentLightweightContainer'))-1;
            if isempty(ix)
                % no UIComponentLightweightContainer found among the children
                errorbox('No uitabgroup java component found.', 'Java component not found', [mfilename ':NoJavaCompFound']);
            else
                % get all the UIComponentLightweightContainers
                jh_tabs = arrayfun(@(x) jparent.getComponent(x), ix, 'uniformoutput', false);
                
                if numel(ix) > 1
                    % several components found
                    % select all components wich have a com.mathworks.mwswing.MJPanel on the next
                    % level
                    ix = find(strcmpi(cellfun(@(x) char(x.getComponent(0).getClass.getCanonicalName), jh_tabs, 'uniformoutput', false), 'com.mathworks.mwswing.MJPanel'));
                    
                    if isempty(ix)
                        % no MJPanel found among the children
                        errorbox('No uitabgroup java component found.', 'Java component not found', [mfilename ':NoJavaCompFound']);
                    else
                        jh_tabs = jh_tabs(ix);
                        % select all components wich have a com.mathworks.mwswing.MJTabbedPane on
                        % the next level
                        ix = find(strcmpi(cellfun(@(x) char(x.getComponent(0).getComponent(0).getClass.getCanonicalName), jh_tabs, 'uniformoutput', false), 'com.mathworks.mwswing.MJTabbedPane'));
                        
                        if isempty(ix)
                            % no MJTabbedPane found among the children
                            errorbox('No uitabgroup java component found.', 'Java component not found', [mfilename ':NoJavaCompFound']);
                        elseif numel(ix) == 1
                            jh_tabgroup = jh_tabs{ix};
                        
                        else
                            % select uitabgroup based on its position
                            ix = getcompbydim(h_uitabgroup, jh_tabs);
                            % TODO: further discrimination required when uitabgroups share exactly the
                            % same dimensions
                            jh_tabgroup = jh_tabs{ix};
                        end
                    end
                    
                else
                    % jh_tabs is good
                    jh_tabgroup = jh_tabs{1};
                end
            end
                
            % get all java components
            jh = {jh_tabgroup; jh_tabgroup.getComponent(0); jh_tabgroup.getComponent(0).getComponent(0)};
            
            % check the classes of the java components
            chkjavaclasses(jh);
            
            % stored the references to the java components of the uipanel in the field 'jvhandle'
            if ~isprop(h_uitabgroup, 'jvhandle')
                % the field 'jvhandle' does not exist yet.
                h_uitabgroup.addprop('jvhandle');
            end
            h_uitabgroup.jvhandle = jh;
            
        catch ME
            nME.message = ['The java component that belongs to the uitabgroup could not be resolved. The following error message occurred:' newline ME.message];
            errorbox(nME, 'uitabgroup to java conversion failed.', [mfilename ':BadJavaClasses'])
        end
    end
    
end % end of function 'uitabgroup2java'


%% -------------------------------------------------------------------------------------------------
function chkjavaclasses(jh)
    % chkjavaclasses checks the class of the java components of the uitabgroup.
    
    % get the class of each java object
    classes = cellfun(@(x) char(x.getClass.getCanonicalName), jh, 'UniformOutput', false);
    
    if ~all(strcmp(classes, {'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.UIComponentLightweightContainer';...
                             'com.mathworks.mwswing.MJPanel';...
                             'com.mathworks.mwswing.MJTabbedPane'}))
        % quick check of the classes of the retrieved java components.
        errorbox('The java components of the uitabgroup are of a different class.', 'Bad Classes', [mfilename ':BadJavaClasses'])
    end

end % end of subfunction 'chkjavaclasses'


%% -------------------------------------------------------------------------------------------------
function ix = getcompbydim(h_uitabgroup, jcomps)
    % returns the java component with the best agreement with the position of the uitabgroup
    
    % get the component with the offset closed to that of the uitabgroup
    ix = getcompbyoffset(h_uitabgroup, jcomps);
    if numel(ix) == 1
        return
    else
        jcomps = jcomps(ix);
        % Find the proper java control by size
        ix = getcompbysize(h_uitabgroup, jcomps);
    end
    
end % end of subfunction 'getcompbydim'


%% -------------------------------------------------------------------------------------------------
function ix = getcompbyoffset(h_uitabgroup, jcomps)
    % returns the java component with the smallest distance between its offset and the offset of the
    % uitabgroup.
    
    if ~iscolumn(jcomps)
        jcomps = jcomps';
    end
    
    % get the java offsets
    offset = cellfun(@getjpixelposition, jcomps, 'uniformoutput', false);
    offset = vertcat(offset{:});
    
    % get matlab offset
    offset_uitabgroup = getuitabgrouppos(h_uitabgroup);
    
    % do the calculation
    [~, ix] = min(sqrt(bsxfun(@minus, offset_uitabgroup(1), offset(:,1)).^2 + bsxfun(@minus, offset_uitabgroup(2), offset(:,2)).^2));
    
end % end of subfunction 'getcompbyoffset'


%% -------------------------------------------------------------------------------------------------
function ix = getcompbysize(h_uitabgroup, jcomps)
    % returns the java component with the smallest deviation of its size to the size of the
    % uitabgroup.
    
    if ~iscolumn(jcomps)
        jcomps = jcomps';
    end
    
    % get the java sizes
    jsize = cellfun(@getjpixelsize, jcomps, 'uniformoutput', false);
    jsize = vertcat(jsize{:});
    
    % get the matlab sizes
    size_uitabgroup = getuitabgroupsize(h_uitabgroup);
    
    % do the calculation
    [~, ix] = min(sqrt(bsxfun(@minus, size_uitabgroup(1), jsize(:,1)).^2 + bsxfun(@minus, size_uitabgroup(2), jsize(:,2)).^2));
    
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
function offset = getuitabgrouppos(h_uitabgroup)
    % returns the offset of the uitabgroup in matlab pixel coordinates
    
    % get the current position units to reset afterwards
    old_units = h_uitabgroup.Units;
    % set the units to pixels
    h_uitabgroup.Units = 'pixels';
    % retrieve the offset
    offset = h_uitabgroup.Position(1:2);
    % restore the units
    h_uitabgroup.Units = old_units;
    
end % end of subfunction 'getuitabgrouppos'


%% -------------------------------------------------------------------------------------------------
function offset = getuitabgroupsize(h_uitabgroup)
    % returns the size (X,Y) of the uitabgroup in matlab pixel coordinates
    
    % get the current position units to reset afterwards
    old_units = h_uitabgroup.Units;
    % set the units to pixels
    h_uitabgroup.Units = 'pixels';
    % retrieve the offset
    offset = h_uitabgroup.Position(3:4);
    % restore the units
    h_uitabgroup.Units = old_units;
    
end % end of subfunction 'getuitabgroupsize'