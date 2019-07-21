function f = siprefix2factor(prefix)
% siprefix2factor converts a SI prefix to its corresponding multiplication factor
    % ----------------------------------------------------------------------------------------------
    %
    %                                        siprefix2factor
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/siprefix2factor.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % f = siprefix2factor(prefix)
    % 
    % DESCRIPTION
    % -----------
    % f = siprefix2factor(prefix) converts a SI prefix to its corresponding multiplication factor.
    % prefix can be a character string or a cell array of strings
    % 
    % 
    % Copyright 2013-2017
    % ==============================================================================================
    
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargout > 1 || nargin ~= 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    elseif isempty(prefix)
        % this is the easiest case. No prefix means no factor
        f = 1;
        return
    elseif ischar(prefix)
        prefix = {prefix};
    elseif ~iscellstr(prefix)
        errorbox(sprintf(['The input argument of %s has to be either a valid '...
                 'string or a cell array of strings.'], mfilename), ...
                 'Bad prefix input argument', [mfilename ':BadPrefixString']);
    end
    
    
    % EXECUTION
    % ---------
    
    f = cell(size(prefix));
    for m = 1 : length(prefix)
        if isempty(prefix{m})
            f{m} = 1;
        else
            f{m} = 10^str2double(regexprep(prefix{m},...
                  {  'y',  'z',  'a',  'f',  'p', 'n', 'µ', 'm', 'c', 'd','da','h','k','M','G', 'T', 'P', 'E', 'Z', 'Y'},...
                  {'-24','-21','-18','-15','-12','-9','-6','-3','-2','-1', '1','2','3','6','9','12','15','18','21','24'}));
        end
    end
    
    if numel(f)==1
        f = f{1};
    end
    
end % end of function 'siprefix2factor'