function c = struct2cellwfieldnames(s)
% struct2cellwfieldnames returns the fieldnames and the values of these field as one single cell array
    % ----------------------------------------------------------------------------------------------
    %
    %                                 struct2cellwfieldnames
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/struct2cellwfieldnames.m $
    % Original author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % c = struct2cellwfieldnames(s)
    % 
    % DESCRIPTION
    % -----------
    % c = struct2cellwfieldnames(s) returns the structure s as a cell array in the format
    % [{fieldname 1} {value 1} {fieldname 2} {value 2} ... {fieldname n} {value n}]. This function
    % can be used to convert a structure input to its cell array equivalent. This function only
    % works for scalar structures.
    % 
    % Copyright 2014-2017
    % ==============================================================================================

    
    % INITIALISATION
    % --------------
    
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    elseif ~isstruct(s)
        % the input argument has to be a valid structure
        errorbox('The input argument is not a valid structure.', 'Bad structure', 'id', [mfilename ':NoStruct']);
    elseif ~isscalar(s)
        % the input argument has to be a scalar structure
        errorbox('The input argument is not a scalar structure.', 'Bad structure', 'id', [mfilename ':NotScalarStruct']);
    end
    
    
    
    % EXECUTION
    % ---------
    
    if isempty(s)
        % empty structure is a special case
        c = [fieldnames(s) cell(length(fieldnames(s)),1)]';
    else
        c = [fieldnames(s) struct2cell(s)]';
    end
    
    % reshape the cell array to its final format
    c = c(:)';
    
end % end of function 'struct2cellwfieldnames'