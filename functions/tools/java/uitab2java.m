function jh = uitab2java(h_uitab)
% uitab2java returns references to the java components corresponding to the defined uitab
    % ----------------------------------------------------------------------------------------------
    %
    %                                       uitab2java
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/uitab2java.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % jh = uitab2java(h_uitab)
    % 
    % DESCRIPTION
    % -----------
    % jh = uitab2java(h_uitab) returns references to the java components corresponding to
    % the defined uitab with handle h_uitab. Two different java components are associated
    % with the uitab. They are sorted in the cell array from parent to child. 
    % 
    % Copyright 2014
    % ==============================================================================================
    
    if verLessThan('matlab', '8.4');
        % this function does not work for older matlab versions
        % get the version number of the current installation.
        v = ver('matlab');
        % show the problem to the user
        errorbox(['The function ''' mfilename ''' does not work on your current matlab installation with version number ''' v.Version ''' ' v.Release '. Minimum version number required to run this function is ''8.4'' (R2014b).'], ...
                 'Unsupported version number', [mfilename ':Ver2low'])
    end
    
    
    % make sure that the input argument is a valid uitab
    if ~isgraphics(h_uitab) || ~strcmpi(h_uitab.Type, 'uitab')
        % the input is not a valid uitab
        errorbox('The input argument is not a valid uitab.', 'Bad uitab', [mfilename ':BadUITab']);
    
    elseif isprop(h_uitab, 'jvhandle') && ~isempty(h_uitab.jvhandle);
        % values stored in the field 'jvhandle' correspond to the java components of the uipanel
        jh = h_uitab.jvhandle;
        
        try
            % check the classes of the java components
            chkjavaclasses(jh)
           
        catch
            h_uitab.jvhandle = [];
            jh = uipanel2java(h_uitab);
            return
            
        end
        
    else
        try
            % get the parent of the uitab
            parent = h_uitab.Parent;
            
            temp = uitabgroup2java(parent);
            
            % get the last java component
            jparent = temp{end};
            
            % get all uitab panels
            ix = find(strcmpi(cellfun(@(x) char(x.getClass.getCanonicalName), num2cell(jparent.getComponents), 'uniformoutput', false), 'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight'))-1;
            if isempty(ix)
                % no UIComponentLightweightContainer found among the children
                errorbox('No uitab java component found.', 'Java component not found', [mfilename ':NoJavaCompFound']);
            else
                % get all the FigurePanelContainerLight
                jh_tabs = arrayfun(@(x) jparent.getComponent(x), ix, 'uniformoutput', false);
                
%                 com.mathworks.hg.peer.FigureComponentContainer
                if numel(ix) > 1
                    % several tabs found
                    
                    % get the number of tabs
                    n_tabs = jparent.getTabCount;
                    
                    if numel(ix) ~= n_tabs
                        errorbox('There is a discrepancy between the number of tabs found and the number of tabs that should be present.', 'Bad Number of tabs', [mfilename ':BadNTabs']);
                    end
                    
                    % get all tab titles
                    titles = cell(n_tabs, 1);
                    for m = 1 : n_tabs
                        titles{m,1} = char(jparent.getTitleAt(m-1));
                    end
                    
                    % get the tab with the identical title
                    ix = find(strcmpi(titles, h_uitab.Title));
                    
                    if isempty(ix)
                        % no tab with identical title found
                        errorbox('No uitab java component with identical title found.', 'Java component not found', [mfilename ':NoJavaCompFoundWIdenticalTitle']);
                    end
                    
                    jh_tab = jh_tabs{ix};
                    
                else
                    % jh_tabs is good
                    jh_tab = jh_tabs{1};
                end
            end
                
            % get all java components
            jh = {jh_tab; jh_tab.getComponent(0)};
            
            % check the classes of the java components
            chkjavaclasses(jh);
            
            % stored the references to the java components of the uipanel in the field 'jvhandle'
            if ~isprop(h_uitab, 'jvhandle')
                % the field 'jvhandle' does not exist yet.
                h_uitab.addprop('jvhandle');
            end
            h_uitab.jvhandle = jh;
            
        catch ME
            nME.message = ['The java component that belongs to the uitab could not be resolved. The following error message occurred:' char(10) ME.message];
            errorbox(nME, 'uitab to java conversion failed.', [mfilename ':BadJavaClasses'])
        end
    end
    
end % end of function 'uitab2java'


%% -------------------------------------------------------------------------------------------------
function chkjavaclasses(jh)
    % chkjavaclasses checks the class of the java components of the uitab.
    
    % get the class of each java object
    classes = cellfun(@(x) char(x.getClass.getCanonicalName), jh, 'UniformOutput', false);
    
    if ~all(strcmp(classes, {'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight';...
                             'com.mathworks.hg.peer.FigureComponentContainer'}))
        % quick check of the classes of the retrieved java components.
        errorbox('The java components of the uitab are of a different class.', 'Bad Classes', [mfilename ':BadJavaClasses'])
    end

end % end of subfunction 'chkjavaclasses'