function mat = numcell2mat(cel)
% numcell2mat converts a numeric cell array to a numeric matrix
    % ----------------------------------------------------------------------------------------------
    %
    %                                      numcell2mat
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/numcell2mat.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % mat = numcell2mat(cel)
    % 
    % DESCRIPTION
    % -----------
    % mat = numcell2mat(cel) converts a numeric cell array to a numeric matrix with similar
    % dimensions.
    % 
    % REMARKS
    % -------
    % The MATLAB function cell2mat can also be used to achieve this result, but this function is
    % about ten times slower and it does not support cell arrays with empty entries.
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
        
    elseif ~iscell(cel)
        % the input argument should be a numeric cell array
        errorbox('The input argument should be a numeric cell array.', 'Bad cell array', [mfilename ':BadCell']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    % get the dimensions of the cell array
    s = size(cel);
    
    try
        % concatenate all cells to form the output matrix
        mat = reshape([cel{:}], s);
        
    catch ME
        % an error is expected when empty cells are present.
        
        if strcmpi('MATLAB:getReshapeDims:notSameNumel', ME.identifier)
            % the number of elements is not correct. There might be empty
            % positions in the cell array
            
            % get the empty cells
            tf = cellfun(@isempty, cel, 'uniformoutput', true);
            
            if ~any(tf)
                % no empty cell. Unknown cause
                
                % find the colon in the error identifier
                k = strfind(ME.identifier, ':');
                
                % throw error
                errorbox(ME.message, 'Error', [mfilename ME.identifier(k(end):end)]);
                
            else
                % allocate memory for the output matrix
                mat = zeros(s);
                
                % only fill the empty holes
                mat(~tf) = [cel{:}];
                
            end
        
        else
            % unknown error
            
            % find the colon in the error identifier
            k = strfind(ME.identifier, ':');
            
            % throw error
            errorbox(ME.message, 'Error', [mfilename ME.identifier(k(end):end)]);
            
        end
    end
    
end % end of function 'numcell2mat'