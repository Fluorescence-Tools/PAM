function newlist = replace_extension(list, new_ext)
% replace_extension returns the filename with a different extension
    % ----------------------------------------------------------------------------------------------
    %
    %                                    replace_extension
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/replace_extension.m $
    % First Author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % filename = replace_extension(filename, new_extension)
    % filename_list = replace_extension(filenamelist, new_extension)
    %
    % DESCRIPTION
    % -----------
    % filename = replace_extension(filename, new_extension) returns the filename with the new
    % extension.
    % 
    % filename_list = replace_extension(filenamelist, new_extension) returns all file names in the
    % cell array of strings with the new extension.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2008-2017
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 2 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 2, nargout, [0 1], mfilename);
        
    elseif iscellstr(list) && ~isvector(list)
        % When several file names are entered, a vector cell array of
        % strings has to be used
        errorbox('When several file names are entered, a vector cell array of strings has to be used.', 'No vector cell array of strings', 'id', [mfilename ':NoVecCellArray']);
    elseif ~ischar(new_ext)
        errorbox('The new extension should be a character string', 'Bad new extension', [mfilename ':BadExt'])
    elseif new_ext(1) == '.'
        new_ext(1) = [];
    end
        
    
    % EXECUTION
    % ---------
    
    % use a pattern to recognize the extension
    ix = regexp(list, '(.*)\.(\w+)$|(?<![\w\s\/\\%]+)\.(\w+)$', 'Tokens', 'once');
    
    if iscell(list)
        % a cell array is used
        
        % allocate memory
        newlist = cell(size(list));
        
        for m = 1 : length(list)
            % Parse through all file names
            
            if ~isempty(ix{m})
                % extension found
                newlist{m} = [ix{m}{1} '.' new_ext];
            else
                % the extension is not recognized
                errorbox(['The extension of the file ''' list{m} ''' is not recorgnized'], 'Bad extension', [mfilename ':BadExt'])
            end
            
        end
        
    else
        % one single file name is given
        
        if isempty(ix)
            % the extension is not recognized
            errorbox(['The extension of the file ''' list ''' is not recorgnized'], 'Bad extension', [mfilename ':BadExt'])
        else
            % the extension is found
            newlist = [ix{1} '.' new_ext];
        end
        
    end
    
end % end of function 'replace_extension'