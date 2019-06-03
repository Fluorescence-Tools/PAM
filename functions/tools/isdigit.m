function tf = isdigit(s)
% isdigit returns true when s is a character string representing a number
	% ----------------------------------------------------------------------------------------------
    %
    %                                        isdigit
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-09 14:17:53 +0100 (Tue, 09 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 12 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/find_field.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % tf = isdigit(s)
    % 
    % DESCRIPTION
    % -----------
    % tf = isdigit(s) returns true when s is a character string representing a number. s can be a
    % scalar character of a string.
    % 
    % copyright 2018
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    elseif ~ischar(s)
        % the input argument has to be a valid character string
        errorbox('The first input argument has to be a valid structure.', 'Bad structure', [mfilename ':BadStruct']);
        
    
    % EXECUTION
    % ---------
        
    elseif isscalar(s)
        tf = any(s == '0123456789-+,.');
        
    elseif isvector(s)
        % preallocate logical matrix to store result
        tf = zeros(14,length(s));
        t  = '0123456789-+,.';
        for m = 1 : length(t)
            tf(m,:) = (t(m) == s);
        end
        
        % combine the result. Each column should have at least one 1.
        tf = all(any(tf));
        
    else
        error([mfilebame ':UnsupFormat'], 'This function cannot handle character matrices or cell array of strings yet.')
    end
    
end % end of function 'isdigit'