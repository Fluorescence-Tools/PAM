function jh = figure2java(hfig)
% figure2java returns references to the java components corresponding to the defined figure
    % ----------------------------------------------------------------------------------------------
    %
    %                                      figure2java
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/gui/java/figure2java.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % jh = figure2java(hfig)
    % 
    % DESCRIPTION
    % -----------
    % jh = figure2java(hfig) returns references to the java components corresponding to the
    % defined figure with handle hfig. 10 different java components associated with the
    % figure are returned in the cell array jh, sorted from parent to child. Branches in the java
    % tree are not returned.
    % 
    % 
    % REMARKS
    % -------
    % This function might not work for hidden figures. In that case, they will temporarily made
    % visible.
    % 
    % ACKNOWLEDGEMENTS
    % ----------------
    % This function is partially based on getRootPane in findjobj written by Yair Altman.
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
    
    
    % make sure that the input argument is a valid figure
    if ~isfig(hfig)
        % the input is not a valid figure
        errorbox('The input argument is not a valid figure.', 'Bad figure', [mfilename ':BadFig']);
    
    elseif isprop(hfig, 'jvhandle') && ~isempty(hfig.jvhandle)
        % values stored in the field 'jvhandle' correspond to the java components of the figure
        jh = hfig.jvhandle;
        
        % superfluous to thest the jvhandle field
%         try
%             % check the classes of the java components
%             chkjavaclasses(jh)
%             return
%         catch ME
%             warning([mfilename ':BadJavaHandlesStored'], ['The stored java handles of the figure are invalid! Reconstructing the correct handles.' newline 'Reason of failing is:' newline '    ' ME.identifier newline '    ' ME.message]);
%             hfig.jvhandle = [];
%             jh = figure2java(hfig);
%             return
%         end
        
    else
        % there is no field 'jvhandle' in the matlab handle
        try
        	% obtain the java handle as one of the clients of the matlab desktop using its name.
        
            if strcmpi(hfig.NumberTitle,'on')
                % get the name of the parent preceeded by 'Figure' and its number.
                hfig_name = regexprep(['Figure ' num2str(hfig.Number) ': ' hfig.Name],': $','');
            else
                % get the name of the parent
                hfig_name = hfig.Name;
            end
            
            try
                % get the java component of the figure as client of the matlab desktop
                mde = com.mathworks.mde.desk.MLDesktop.getInstance;
                jparent = mde.getClient(hfig_name);

                % get the root of the figure
                jRootPane = jparent.getRootPane;
            catch
                % the client approach didn't work the first time
                
                % invoke an update of the interface
                drawnow();
                
                % get the java component of the figure as client of the matlab desktop
                mde = com.mathworks.mde.desk.MLDesktop.getInstance;
                jparent = mde.getClient(hfig_name);
                
                % get the root of the figure
                jRootPane = jparent.getRootPane;
            end
        catch
            % the first method didn't work out. Try other options.
            warningbox('javahandle to figure not found using client. Please notify Nick on exact circumstances.', 'Unexpected, but should still work', 'id',  [mfilename ':IsThisDeployedMode'])
            
            try
                % disable the warning about future disappearance of 'JavaFrame'
                warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');  % R2008b compatibility
                % get the rootpane using 'JavaFrame'
                jRootPane = hfig.JavaFrame.getFigurePanelContainer.getComponent(0).getRootPane;
                
            catch
                % second methods also didn't work
                
                try
                    % second attempt using 'JavaFrame' (third attempt in total)
                    jRootPane = hfig.JavaFrame.getAxisComponent.getParent.getParent.getRootPane;
                catch ME
                    % If invalid RootPane, retry up to N times
                    tries = 10;
                    jRootPane = [];
                    while isempty(jRootPane) && tries>0  % might happen if figure is still undergoing rendering...
                        drawnow; pause(0.01);
                        tries = tries - 1;
                        try
                            jRootPane = hfig.JavaFrame.getFigurePanelContainer.getComponent(0).getRootPane;
                        catch
                            % do nothing
                        end
                    end
                    
%                     % If still invalid, use FigurePanelContainer which is good enough in 99% of cases... (menu/tool bars won't be accessible, though)
%                     if isempty(jRootPane)
%                         jRootPane = parent.JavaFrame.getFigurePanelContainer;
%                     end
                    
                    if strcmp(hfig.Visible, 'off')
                        hfig.Visible = 'on';
                        drawnow;
                        pause(0.01);
                        try
                            jh = figure2java(hfig);
                        catch
                            ME.message = ['The java component that belongs to the figure could not be resolved. The following error message occurred:' char(10) ME.message];
                            errorbox(ME, 'figure to java conversion failed.', [mfilename ':NoRootFound'])
                        end
                        hfig.Visible = 'off';
                        drawnow;
                    else
                        if isempty(jRootPane)
                            ME.message = ['The java component that belongs to the figure could not be resolved. The following error message occurred:' char(10) ME.message];
                            errorbox(ME, 'figure to java conversion failed.', [mfilename ':NoRootFound'])
                        end
                    end
                end
            end
        end
        
        if isempty(jRootPane)
            if strcmp(hfig.Visible, 'off')
                hfig.Visible = 'on';
                drawnow();
                pause(0.1);
                try
                    jh = figure2java(hfig);
                catch ME
                    ME.message = ['The java component that belongs to the figure could not be resolved. The following error message occurred:' char(10) ME.message];
                    errorbox(ME, 'figure to java conversion failed.', [mfilename ':NoRootFound'])
                    
                end
                hfig.Visible = 'off';
                drawnow;
                return
            else
                drawnow();
                pause(0.1);
                
                try
                    jh = figure2java(hfig);
                catch ME
                    ME.message = ['The java component that belongs to the figure could not be resolved. The following error message occurred:' char(10) ME.message];
                    errorbox(ME, 'figure to java conversion failed.', [mfilename ':NoRootFound'])
                end
                return
            end
        end
        
%         if ~strcmp(hfig.WindowStyle, 'docked')
            try
                % make sure that the rootpane if of class 'com.mathworks.widgets.desk.DTRootPane'
                chkjavaclass(jRootPane, 'com.mathworks.widgets.desk.DTRootPane')

                % preallocate cell array to hold java handles
                jh = cell(10,1);

                % get the upper parent and check its class
                jh(1:2,1) = {jRootPane.getParent; jRootPane};
                chkjavaclass(jh{1}, 'com.mathworks.hg.peer.FigureFrameProxy.FigureFrame');

                % expect list of classes as children
                list_to_retrieve = {'javax.swing.JLayeredPane';...
                                    'javax.swing.JPanel';...
                                    'com.mathworks.widgets.desk.DTClientFrame';...
                                    'javax.swing.JPanel';...
                                    'com.mathworks.hg.peer.FigureClientProxy.FigureDTClientBase';...
                                    'com.mathworks.hg.peer.FigureClientProxyPanel';...
                                    'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight';...
                                    'com.mathworks.hg.peer.FigureComponentContainer'};

                cntr = 2;
                % parse through the listed java components
                for m = 1 : length(list_to_retrieve)
                    cntr = cntr + 1;
                    ix = find(strcmpi(cellfun(@(x) char(x.getClass.getCanonicalName), num2cell(jh{cntr-1}.getComponents), 'uniformoutput', false), list_to_retrieve{m}))-1;
                    
                    if isempty(ix)
                        % no JLayeredPane found among the children
                        errorbox(['Java component ''' list_to_retrieve{m} ''' could not be found.'], 'Java component not found', [mfilename ':NoJavaCompFound']);
                    else
                        jh{cntr} = jh{cntr-1}.getComponent(ix);
                    end
                end

                % a matlab figure consists of several java components
                %   * com.mathworks.hg.peer.FigureFrameProxy.FigureFrame
                %   * com.mathworks.widgets.desk.DTRootPane: This is
                %     refered to as the RootPanel
                %   * javax.swing.JLayeredPane
                %   * javax.swing.JPanel {javax.swing.Box with the docking controls}{com.mathworks.hg.peer.FigureMenuBar with uimenu's}
                %   * com.mathworks.widgets.desk.DTClientFrame
                %   * javax.swing.JPanel
                %   * com.mathworks.hg.peer.FigureClientProxy.FigureDTClientBase {com.mathworks.widgets.desk.DTToolBarContainer}
                %   * com.mathworks.hg.peer.FigureClientProxyPanel
                %   * com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight
                %   * com.mathworks.hg.peer.FigureComponentContainer

                % stored the references to the java components of the uipanel in the field 'jvhandle'
                if ~isprop(hfig, 'jvhandle')
                    % the field 'jvhandle' does not exist yet.
                    hfig.addprop('jvhandle');
                end
                hfig.jvhandle = jh;

            catch ME
                nME = struct('message', ME.message, 'identifier', ME.identifier, 'stack', ME.stack);
                nME.message = ['The java component that belongs to the figure could not be resolved. The following error message occurred:' newline ME.message];
%                 errorbox(nME, 'figure to java conversion failed.', [mfilename ':BadJavaClass']);
                error([mfilename ':BadJavaClass'], nME.message);
            end
%         else
%             
%             error('This function does not work yet with docked figure windows!')
%             try
%                 % make sure that the rootpane if of class 'com.mathworks.widgets.desk.DTRootPane'
%                 chkjavaclass(jRootPane, 'com.mathworks.widgets.desk.DTRootPane')
% 
%                 % preallocate cell array to hold java handles
%                 jh = cell(10,1);
% 
%                 % get the upper parent and check its class
%                 jh(1:2,1) = {jRootPane.getParent; jRootPane};
%                 chkjavaclass(jh{1}, 'com.mathworks.mde.desk.MLMainFrame');
% 
%                 % expect list of classes as children
%                 list_to_retrieve = {'javax.swing.JLayeredPane';...
%                                     'javax.swing.JPanel';...
%                                     'com.mathworks.mwswing.MJPanel';...
%                                     'javax.swing.JPanel';...
%                                     'com.mathworks.hg.peer.FigureClientProxy.FigureDTClientBase';...
%                                     'com.mathworks.hg.peer.FigureClientProxyPanel';...
%                                     'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight';...
%                                     'com.mathworks.hg.peer.FigureComponentContainer'};
% 
%                 cntr = 2;
%                 % parse through the listed java components
%                 for m = 1 : length(list_to_retrieve)
%                     cntr = cntr + 1;
%                     ix = find(strcmpi(cellfun(@(x) char(x.getClass.getCanonicalName), num2cell(jh{cntr-1}.getComponents), 'uniformoutput', false), list_to_retrieve{m}))-1;
%                     if isempty(ix)
%                         % no JLayeredPane found among the children
%                         errorbox(['Java component ''' list_to_retrieve{m} ''' could not be found.'], 'Java component not found', [mfilename ':NoJavaCompFound']);
%                     else
%                         jh{cntr} = jh{cntr-1}.getComponent(ix);
%                     end
%                 end
% 
%                 % a matlab figure consists of several java components
%                 %   * com.mathworks.hg.peer.FigureFrameProxy.FigureFrame
%                 %   * com.mathworks.widgets.desk.DTRootPane: This is
%                 %     refered to as the RootPanel
%                 %   * javax.swing.JLayeredPane
%                 %   * javax.swing.JPanel {javax.swing.Box with the docking controls}{com.mathworks.hg.peer.FigureMenuBar with uimenu's}
%                 %   * com.mathworks.widgets.desk.DTClientFrame
%                 %   * javax.swing.JPanel
%                 %   * com.mathworks.hg.peer.FigureClientProxy.FigureDTClientBase {com.mathworks.widgets.desk.DTToolBarContainer}
%                 %   * com.mathworks.hg.peer.FigureClientProxyPanel
%                 %   * com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight
%                 %   * com.mathworks.hg.peer.FigureComponentContainer
% 
%                 % stored the references to the java components of the uipanel in the field 'jvhandle'
%                 if ~isprop(hfig, 'jvhandle')
%                     % the field 'jvhandle' does not exist yet.
%                     hfig.addprop('jvhandle');
%                 end
%                 hfig.jvhandle = jh;
% 
%             catch ME
%                 nME = struct('message', ME.message, 'identifier', ME.identifier, 'stack', ME.stack);
%                 nME.message = ['The java component that belongs to the figure could not be resolved. The following error message occurred:' newline ME.message];
%                 errorbox(nME, 'figure to java conversion failed.', [mfilename ':BadJavaClass']);
%             end
%         end
        
    end
    
end % end of function 'figure2java'


%% -------------------------------------------------------------------------------------------------
function chkjavaclass(jh, jclass_name)
    % chkjavaclass checks the class of a java component
    
    if ~strcmp(jh.getClass.getCanonicalName, jclass_name)
        % quick check of the class of the retrieved java component.
        errorbox(['The java component of the figure is of class ''' char(jh.getClass.getCanonicalName) ''' while it should be ''' jclass_name '''.'], 'Bad java Class', [mfilename ':BadJavaClass'])
    end

end % end of subfunction 'chkjavaclass'


% %% -------------------------------------------------------------------------------------------------
% function chkjavaclasses(jh)
%     % chkjavaclasses checks the class of the java components of the uipanel.
%     
%     % get the class of each java object
%     classes = cellfun(@(x) char(x.getClass.getCanonicalName), jh, 'UniformOutput', false);
%     
%     if ~all(strcmp(classes, {'com.mathworks.hg.peer.FigureFrameProxy.FigureFrame';...
%                              'com.mathworks.widgets.desk.DTRootPane';...
%                              'javax.swing.JLayeredPane';...
%                              'javax.swing.JPanel';...
%                              'com.mathworks.widgets.desk.DTClientFrame';...
%                              'javax.swing.JPanel';...
%                              'com.mathworks.hg.peer.FigureClientProxy.FigureDTClientBase';...
%                              'com.mathworks.hg.peer.FigureClientProxyPanel';...
%                              'com.mathworks.hg.peer.HeavyweightLightweightContainerFactory.FigurePanelContainerLight';...
%                              'com.mathworks.hg.peer.FigureComponentContainer'}))
%         % quick check of the classes of the retrieved java components.
%         errorbox('The java components of the figure are of a different class.', 'Bad Classes', [mfilename ':BadJavaClasses'])
%     end
%     
% end % end of subfunction 'chkjavaclasses'