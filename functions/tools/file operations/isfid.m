function [tf, filename] = isfid(fid)
% isfid returns true if the scalar is a valid integer file identifier
    % ----------------------------------------------------------------------------------------------
    %
    %                                          isfid
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/file%20operations/isfid.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % tf = isfid(fid)
    % [tf, filename] = isfid(fid)
    % 
    % DESCRIPTION
    % -----------
    % tf = isfid(fid) returns true if the specified integer file identifier exists.
    % 
    % [tf, filename] = isfid(fid) returns the name of the corresponding file as optional output
    % argument.
    % 
    % REMARKS
    % -------
    % The file identifier values 0, 1, and 2 are not considered.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % 
    % Copyright 2010-2017
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------
    
    % set default values
    tf       = false; % logical value indicating validity of file identifier
    filename = '';    % character string hosting the name of the file
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 2
        % use chknarg to throw error when these numbers are invalid
        chknarg(nargin, 1, nargout, [0 2], mfilename);
        
    elseif ~isscalar(fid)
        % the file identifier has to be a valid scalar
        errorbox('The file identifier has to be a valid scalar.', 'Invalid file identifier', [mfilename ':BadFID']);
        
    elseif isempty(fid)
        % the file identifier is empty. Return default output
        return
        
    end
    
    
    % EXECUTION
    % ---------
    
    % get all existing file identifiers
    fid_list = fopen('all');
    
    if isempty(fid_list)
        % no file is currently opened. This means that the given file
        % identifier can never be valid. The default values apply
        return
        
    else
        % is the specified file identifier present in the present list of
        % identifiers?
        tf = any(fid == fid_list);
        
        if tf && nargout > 1
            % the file identifier exists. Get the name of the corresponding
            % file
            filename = fopen(fid);
        end
    end
    
end % end of function 'isfid'