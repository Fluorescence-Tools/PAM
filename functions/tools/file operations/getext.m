function ext = getext(list)
% getext returns the extension of a file name
    % ----------------------------------------------------------------------------------------------
    %
    %                                        getext
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/getext.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % ext = getext(filename)
    % ext = getext(filenamelist)
    %
    % DESCRIPTION
    % -----------
    % ext = getext(filename) returns the extension of the given file name.
    % 
    % ext = getext(filenamelist) returns the extensions of all file names in the cell array of
    % strings.
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
        
    elseif iscellstr(list) && ~isvector(list)
        % When several file names are entered, a vector cell array of
        % strings has to be used
        errorbox('When several file names are entered, a vector cell array of strings has to be used.', 'No vector cell array of strings', [mfilename ':NoVecCellArray']);
    end
        
    
    % EXECUTION
    % ---------
    
    % use a pattern to recognize the extension
    ix = regexp(list, '\.(\w+)$|(?<![\w\s\/\\%]+)\.(\w+)$', 'Tokens', 'once');
    
    if iscell(list)
        % a cell array is used
        
        % allocate memory
        ext = cell(size(list));
        
        for m = 1 : length(list)
            % Parse through all file names
            
            if ~isempty(ix{m})
                % extension found
                ext{m} = ['.' ix{m}{1}];
                
            else
                % no extension found
                ext{m} = '';
                
            end
            
        end
        
    else
        % one single file name is given
        
        if isempty(ix)
            % the extension is not recognized
            ext = {};
            
        else
            % the extension is found
            ext = ['.' ix{1}];
            
        end
        
    end
    
end % end of function 'getext'