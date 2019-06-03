function NewPos = chkpos(OldPos, MinSize)
% chkpos prevents the width and height in a position vector to be negative
    % ----------------------------------------------------------------------------------------------
    %
    %                                        chkpos
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/chkpos.m $
    % First Author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % NewPos = chkpos(OldPos)
    % NewPos = chkpos(OldPos, [minWidth minHeight])
    % NewPos = chkpos(OldPos, 'normalized')
    % 
    % DESCRIPTION
    % -----------
    % NewPos = chkpos(OldPos) makes sure that the width and the height of
    % the position vector OldPos, which are respectively the third and
    % fourth element, are not negative nor zero. Therefore, the minimum of
    % both measures is 0.01.
    %
    % NewPos = chkpos(OldPos, [minWidth minHeight]) allows to set the
    % minimum of the measures. The second, optional input argument has to
    % be a two element vector with respectively the minimal width and the
    % minimal height of the uielement.
    % 
    % NewPos = chkpos(OldPos, 'normalized') verifies that the position as specified in OldPos is a
    % valid 'normalized' position. Every element has to be a number between 0 and 1.
    % 
    % EXAMPLES
    % --------
    % This function is expecially intended for resize functions of figures
    % and uipanels. Negative widths and heights are not accepted by
    % MATLAB for uielement. chkpos prevents these problems. Suppose the
    % position vector [0.25 0.25 -1 0.5] (expressed in normalized units)
    % is obtained to position a figure. When suplying this position vector
    % to a uielement, an error will arise and al subsequent processing is
    % aborted.
    % 
    % set(figure(1), 'units', 'normalized', 'position', [0.25 0.25 -1 0.5])
    % 
    % By using chkpos, this error is prevented.
    %
    % set(figure(1), 'units', 'normalized', 'position', chkpos([0.25 0.25 -1 0.5]))
    % 
    % 
    % MODIFICATIONS
    % -------------
    %   04-Oct-2014 11:35:17
    %       * enabled the option 'normalized'
    % 
    % Copyright 2008-2014
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
 	% check number of input and output arguments
    if nargin < 1 || nargin > 2 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [1 2], nargout, [0 1], mfilename);
        
    % Parse input arguments
    elseif ~isvector(OldPos) || numel(OldPos)~=4
        % the position vector has to be a four element vector
        errorbox('The position vector of the uielement has to be a four element vector specifying respectively the horizontal and vertical offset, the width and the height of the uielement.', 'Bad Position vector', [mfilename ':BadPosVec']);
    end
    
    if nargin == 1
        % set default minimal size
        MinSize = [0.001 0.001];
        norm    = false;
        
    elseif ischar(MinSize)
        if ~strncmpi(MinSize, 'normalized', length(MinSize))
            errorbox('The second input argument should be either a two element vector specifying the minimal width and height of the uielement, or the string ''normalized''.', 'Bad minimal size', 'id', [mfilename ':BadMinSize']);
        else
            norm = true;
        end
        
    elseif numel(MinSize) ~= 2
        % there need to be two elements
        errorbox('The second input argument should be either a two element vector specifying the minimal width and height of the uielement, or the string ''normalized''.', 'Bad minimal size', 'id', [mfilename ':BadMinSize']);
            
    else
        norm = false;
        
    end
    
    
    % EXECUTION
    % ---------
    
    if norm
        % normalized position required
        NewPos = [max(min(OldPos(1),1),0) max(min(OldPos(2),1),0) max(min(OldPos(3),1),0) max(min(OldPos(4),1),0)]; 
        
    else
        % check only width and height
        NewPos = [OldPos(1) OldPos(2) max(OldPos(3), MinSize(1)) max(OldPos(4), MinSize(2))];
        
    end
    
end % end of function 'chkpos'