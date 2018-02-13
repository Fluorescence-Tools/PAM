function [prefix, F] = factor2siprefix(f)
% factor2siprefix converts a multiplication factor to its corresponding SI prefix
    % ----------------------------------------------------------------------------------------------
    %
    %                                       factor2siprefix
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/factor2siprefix.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % prefix = factor2siprefix(f)
    % [prefix, F] = factor2siprefix(f)
    % 
    % DESCRIPTION
    % -----------
    % prefix = factor2siprefix(f) converts a multiplication factor to its corresponding SI prefix. f
    % has to be numeric.
    % 
    % [prefix, F] = factor2siprefix(f) converts a multiplication factor to its corresponding SI
    % prefix. The optional output argument F holds the factor by which the f has to be divided.
    % 
    % Copyright 2013-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargout > 2 || nargin ~= 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 2], mfilename);
    elseif ~isnumeric(f)
        errorbox(sprintf(['The input argument of %s has to be a valid, numeric '...
                 'matrix.'], mfilename), ...
                 'Bad factor input argument', 'id', [mfilename ':BadFactorNum']);
    end
    
    
    % EXECUTION
    % ---------
    
    % get the size of the original matrix
    dims = size(f);
    
    % construct vectors
    prefix = cell(numel(f),1);
    F = zeros(numel(f),1);
    f = f(:);
    
    % define prefixes and multiplication factors
    F_list      = [ -8;  -7;  -6;  -5;  -4; -3; -2; -1;  1;  2;  3;  4;  5;  6;  7;  8];
    prefix_list = {'y'; 'z'; 'a'; 'f'; 'p';'n';'µ';'m';'k';'M';'G';'T';'P';'E';'Z';'Y'};
    
    for m = 1 : length(f)
        if f(m) >=1 && f(m) < 1000
            prefix{m} = '';
            F(m) = 1;
            continue
        else
            F(m) = 10^floor(floor(log10(f(m)))/3);
        end
        prefix{m} =  prefix_list{log10(F(m)) == F_list};
        F(m) = 10^(log10(F(m))*3);
    end
    
    % prepare proper output formats.
    prefix = reshape(prefix, dims);
    F = reshape(F,dims);
    if isscalar(f)
        prefix = prefix{1};
    end
    
end % end of function 'factor2siprefix'