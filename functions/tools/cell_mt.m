function mt_c = cell_mt(varargin)
% cell_mt returns an empty cell array
    % ----------------------------------------------------------------------------------------------
    %
    %                                        cell_mt
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/cell_mt.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % mt_c = cell_mt([n,m,s,...])
    % mt_c = cell_mt(n,m,s,...)
    % 
    % DESCRIPTION
    % -----------
    % mt_c = cell_mt([n,m,s,...]) creates an empty cell array with dimensions n, m, s, ..., of which
    % exactly one dimension equals zero.
    % 
    % mt_c = cell_mt(n,m,s,...) also excepts each dimension as a separate input argument.
    % 
    % Copyright 2015-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin == 0 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, [1 Inf], nargout, [0 1], mfilename);
    end
    
    
    % EXECUTION
    % ---------
    
    if nargin == 1
        if ~isvector(varargin{1})
            errorbox('The input argument has to be a vector.', 'Bad input argument', [mfilename ':BadIpt'])
        else
            s = varargin{1};
        end
    else
        % multiple input arguments defined
        tf = ~cellfun(@(x) all(isscalar(x)), varargin);
        if any(tf) || length(varargin)<2
            errorbox('At least 2 input arguments have to be defined, with each argument being a scalar.', 'Bad input argument', [mfilename ':BadIpt']);
        else
            s = numcell2mat(varargin);
        end
    end
    
    % find zero
    tf = s==0;
    
    if nnz(tf) ~= 1
        % no or more than one 0 found
        errorbox('Exactly one input argument has to be zero', 'Bad input argument', [mfilename ':BadIpt']);
    end
    
    % construct vector to make cell array
    s2 = s;
    s2(tf) = 1;
    % make cell array
    temp   = cell(s2);
    
    % create cell array with indices
    ix = cell(1,length(s2));
    for m = 1 : length(s2)
        ix{m} = 1 : s2(m);
    end
    ix(tf) = {false};
    
    % finally, create the empty cell array
    mt_c  = temp(ix{:});
    
end % end of function 'cell_mt'