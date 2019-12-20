function color = letter2color(letter)
% letter2color converts a color letter to the rgb value of the color
    % ----------------------------------------------------------------------------------------------
    %
    %                                        letter2color
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/letter2color.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % color = letter2color(letter)
    %
    % DESCRIPTION
    % -----------
    % color = letter2color(letter) converts a color letter to the rgb value of the color. letter can
    % be a single letter or the full name of a color. Accepted input arguments are:
    %   'r' 'red'       [1 0 0]
    %   'g' 'green'     [0 1 0]
    %   'b' 'blue'      [0 0 1]
    %   'm' 'magenta'   [1 0 1]
    %	'c' 'cyan'      [0 1 1]
    %   'y' 'yellow'    [1 1 0]
    % 	'k' 'black'     [0 0 0]
    %   'w' 'white'     [1 1 1]
    % 
    %
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    end
    
    
    % EXECUTION
    % ---------
    
    switch letter
        case {'r' 'red'}
            color = [1 0 0];
        case {'g' 'green'}
            color = [0 1 0];
        case {'b' 'blue'}
            color = [0 0 1];
        case {'m' 'magenta'}
            color = [1 0 1];
        case {'c' 'cyan'}
            color = [0 1 1];
        case {'y' 'yellow'}
            color = [1 1 0];
        case {'k' 'black'}
            color = [0 0 0];
        case {'w' 'white'}
            color = [1 1 1];
        otherwise
            errorbox(sprintf('The letter %s is not recognized to convert to a color.', letter), 'Invalid letter', [mfilename ':BadColorLetter']);
    end


end % end of function 'letter2color'