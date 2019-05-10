function obj = mk_progress_fig(obj, X)
% a new figure will be created. This figure will also be the parent. The figure has the tag
% 'PROGRESS_BAR_X', where X can be any number.
    
    if nargin == 1
        X = 1;
    elseif nargin == 2
        if ~isscalar(X) || ~isnumeric(X)
            errorbox('The serial number of the progress figure should be a valid, positive integer.', 'Bad serial number', [mfilename ':BadSerialNumberProgressFig'])
        end
    else
        chknarg(nargin, [1 2], nargout, [0 1], mfilename);
    end
    
    % set the default size of the figure
    size_fig = [360 75]; % [X Y]
    
    % create the parent
    obj.parent = figure(   'units',       'pixels',...
                        'position', [0 0 size_fig],...
                         'visible',         'off',...
                          'resize',          'off',...
                         'toolbar',         'none',...
                         'menubar',         'none',...
                     'NumberTitle',          'off',...
                        'nextplot',          'new',...
                   'integerhandle',          'off',...
                             'tag',    ['PROGRESS_BAR_' num2str(X)],...
                    'DockControls',          'off',...
                'handlevisibility',          'off',...
                 'closerequestfcn',  @(src,~) end_waiting(obj, src));
        
end % end of subfunction 'mk_progress_fig'


%% -------------------------------------------------------------------------------------------------
function end_waiting(obj, src)
    % end_waiting closes the waitbar figure and sets the field stop of the object to true to
    % indicate that the wait process has to stop.
    
    obj.stop = true;
    delete(src);
    
end % end of subfunction 'end_waiting'