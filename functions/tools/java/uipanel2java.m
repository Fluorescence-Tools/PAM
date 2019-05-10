function jh = uipanel2java(h_uipanel)
% uipanel2java returns references to the java components corresponding to the defined uipanel
    % ----------------------------------------------------------------------------------------------
    %
    %                                      uipanel2java
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/uipanel2java.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % jh = uipanel2java(h_uipanel)
    % 
    % DESCRIPTION
    % -----------
    % jh = uipanel2java(h_uipanel) returns references to the java components corresponding to the
    % defined uipanel with handle h_uipanel. Four different java components are associated with the
    % uipanel. They are sorted in the cell array from parent to child. 
    % 
    % Copyright 2014-2015
    % ==============================================================================================
    
    if verLessThan('matlab', '8.4');
        % this function does not work for older matlab versions
        % get the version number of the current installation.
        v = ver('matlab');
        % show the problem to the user
        errorbox(['The function ''' mfilename ''' does not work on your current matlab installation with version number ''' v.Version ''' ' v.Release '. Minimum version number required to run this function is ''8.4'' (R2014b).'], ...
                 'Unsupported version number', [mfilename ':Ver2low'])
    end
    
    
    % make sure that the input argument is a valid uipanel
    if ~ispanel(h_uipanel)
        % the input is not a valid uipanel
        errorbox('The input argument is not a valid uipanel.', 'Bad uipanel', [mfilename ':BadUIPanel']);
    
    elseif isprop(h_uipanel, 'jvhandle') && ~isempty(h_uipanel.jvhandle);
        % values stored in the field 'jvhandle' correspond to the java components of the uipanel
        jh = h_uipanel.jvhandle;
        
        try
            % check the classes of the java components
            chkjavaclasses(jh)
           
        catch
            h_uipanel.jvhandle = [];
            jh = uipanel2java(h_uipanel);
            return
            
        end
        
    else
        try
            % Obtain the java handle using 'JavaFrame'. This property might disappear in future
            % releases. The 'PrintableComponent' holds a reference to one of the java objects of the
            % actual panel.
            j = h_uipanel.JavaFrame.getPrintableComponent;
            
            % a matlab uipanel has three java elements:
            %   * the highest-level object is a UIPanelLightweightContainer
            %   * the second-level object is a UIPanelJPanel. This is refered to as the
            %     'PrintableComponent'
            %   * the third element is a FigurePanelContainerLight
            %   * the fourth element is a FigureComponentContainer
            
            if j.getComponentCount ~= 1
                % exactly one component expected
                error(['The java component ''UIPanelJPanel'' of the uipanel was expected to hold exactly one component, but it holds ' num2str(j.getComponentCount) ' components.'])
            elseif j.getComponent(0).getComponentCount ~= 1
                % exactly one component expected
                error(['The java component ''FigurePanelContainerLight'' of the uipanel was expected to hold exactly one component, but it holds ' num2str(j.getComponentCount) ' components.'])
            end
            
            % get all java components
            jh = {j.getParent; j; j.getComponent(0); j.getComponent(0).getComponent(0)};
            
            % check the classes of the java components
            chkjavaclasses(jh);
            
            % stored the references to the java components of the uipanel in the field 'jvhandle'
            if ~isprop(h_uipanel, 'jvhandle')
                % the field 'jvhandle' does not exist yet.
                h_uipanel.addprop('jvhandle');
            end
            h_uipanel.jvhandle = jh;
            
        catch ME
            nME.message = ['The java component that belongs to the uipanel could not be resolved. The following error message occurred:' char(10) ME.message];
            errorbox(nME, 'uipanel to java conversion failed.', [mfilename ':BadJavaClasses'])
        end
    end
    
end % end of function 'uipanel2java'


% --------------------------------------------------------------------------------------------------
function chkjavaclasses(jh)
    % chkjavaclasses checks the class of the java components of the uipanel.
    
    % get the class of each java object
    classes = cellfun(@(x) char(x.getClass.getCanonicalName), jh, 'UniformOutput', false);
    
    if ~all(strcmp(classes, {'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.UIPanelLightweightContainer';...
                             'com.mathworks.hg.peer.ui.UIPanelPeer.UIPanelJPanel';...
                             'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight';...
                             'com.mathworks.hg.peer.FigureComponentContainer'}))
        % quick check of the classes of the retrieved java components.
        errorbox('The java components of the uipanel are of a different class.', 'Bad Classes', [mfilename ':BadJavaClasses'])
    end

end % end of subfunction 'chkjavaclasses'