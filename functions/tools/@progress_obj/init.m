function obj = init(obj)
    
    % each mode of the object (waitbar and statusbar) require a different approach
    switch obj.mode
        
        case 'waitbar'
            % the waitbar will be shown in a separate figure dedicated for one or multiple waitbars
            if isempty(obj.parent) || ~obj.parent.isvalid
                % no parent defined
                
                % get all existing waitbar figures
                [pgbar_list, serial_number] = obj.get_all_waitbar_figs;
                
                if isempty(serial_number)
                	% no figure exists yet
                    obj = obj.mk_progress_fig(1);
                    % move the figure to the requested location
                    movegui(obj.parent, obj.waitbar_location);
                else
                    if obj.combine_bars
                        % a single figure for multiple waitbars. Reuse an existing waitbar figure.
                        [~, ix] = sort(serial_number, 'descend');
                        L = length(ix);
                        c = 0;
                        while c < L
                            c = c + 1;
                            temp_fig = pgbar_list(ix(c));
                            if ~isprop(temp_fig, 'progress_obj')
                                warning([mfilename ':NoProgressObj'], 'Every PROGRESS_BAR figure should have the field ''progress_obj''.')
                                delete(temp_fig);
                                continue
                            else
                                other_obj = temp_fig.progress_obj;
                                if other_obj(1).combine_bars
                                    obj.parent = temp_fig;
                                    break
                                else
                                    continue
                                end
                            end
                        end
                        
                        if isempty(obj.parent) || ~obj.parent.isvalid
                            % no suitable figure found
                            % create a new figure
                            obj = obj.mk_progress_fig(max(serial_number)+1);
                            % move the figure to the requested location
                            movegui(obj.parent, obj.waitbar_location);
                        end
                    else
                        % no combination of waitbars requested
                        % create a new figure
                        obj = obj.mk_progress_fig(max(serial_number)+1);
                        % move the figure to the requested location
                        movegui(obj.parent, obj.waitbar_location);
                    end
                end
                
                
                % add javabar
                
%                 drawnow
%                 obj.add_javabar
                
            else
                % TODO:what to do when valid parent is defined.
                
                
            end
            
            % show the parent
            set(obj.parent, 'visible', 'on');
            figure(obj.parent)
            
            if ~isprop(obj.parent, 'progress_obj')
                obj.parent.addprop('progress_obj'); % create the field
                obj.parent.progress_obj = obj;      % save the obj into this field so that it is always available
            else
                obj.parent.progress_obj(end+1,1) = obj;     % save the obj into this field so that it is always available
            end
            
            % save the current time to measure the elapsed time since this action
            obj.time_last_call = tic;
            
            
            obj.update_and_resize;
            
            
            
            
            
        case 'statusbar'
            
    end

    
    
end % end of function 'init'