function fileExt = addcombinedfileextensions(fileExt)
% addcombinedfileextensions adds a new entry to the top of the file extension list to list all recognized file formats
    % ----------------------------------------------------------------------------------------------
    %
    %                               addcombinedfileextensions
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/addcombinedfileextensions.m $
    % First Author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % fileExt = addcombinedfileextensions(fileExt)
    % 
    % DESCRIPTION
    % -----------
    % fileExt = addcombinedfileextensions(fileExt) adds a new entry to the file extension list to
    % list all recognized file formats. fileExt has to be a two-column cell array with the file
    % extensions in the first column and their corresponding description in the second column.
    % 
    % Copyright 2012-2017
    % ==============================================================================================
    
    % INITIALIZATION
    % --------------
    
    
    % set default values
    if nargin ~= 1|| nargout > 1
        % maximum 1 input and 1 output arguments allowed
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    elseif ~iscell(fileExt) || size(fileExt, 2) ~= 2
        errorbox(['The input argument has to be a two-column cell array' ...
                 'with the file extensions in the first column and their'...
                 'corresponding description in the second column.'], 'Bad input argument', 'id', [mfilename ':BadIptArg']);
    end
    
    
    % EXECUTION
    % ---------
    
    % concatenate all extensions separated by a semicolon
    temp = sprintf('%s;', fileExt{:, 1});
    
    % remove duplicates, empty strings, entries with stars
    temp = unique(regexp(temp, ';', 'split'))';
    temp(strcmpi(temp, '')) = [];
    temp(strcmpi(temp, '*.')) = [];
    % combine to a full list
    allExt = sprintf('%s;', temp{:});
    allExt(end) = [];
    
    % add the full list as the first element
    fileExt = vertcat({allExt, 'All supported formats'}, fileExt);
    
end % end of function 'addcombinedfileextensions'