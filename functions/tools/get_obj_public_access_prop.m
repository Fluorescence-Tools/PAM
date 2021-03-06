function pub_proplist = get_obj_public_access_prop(obj)
% get_obj_public_access_prop returns the list of non-dependent properties of the object with public access
    % ----------------------------------------------------------------------------------------------
    %
    %                                get_obj_public_access_prop
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/get_obj_public_access_prop.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % pub_proplist = get_obj_public_access_prop(obj)
    % 
    % DESCRIPTION
    % -----------
    % pub_proplist = get_obj_public_access_prop(obj) returns the list of non-dependent properties
    % of the object with public access as a column cell array.
    % 
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2015-2017
    % ==============================================================================================

    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    elseif ~isobject(obj)
        % the input argument should be an object
        errorbox(['The input argument should be an object and not ''' class(obj) '''.'], 'Bad object', [mfilename ':Badobject']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    % get the meta class of the object
    meta = metaclass(obj);
    
    % get the cell array with meta properties of the meta class
    Props = meta.Properties;
    
    % allocate memory
    pub_proplist = cell(length(Props),1);
    
    for m = 1 : length(Props)
        % parse trhough all properties and save the name to the list
        
        if strcmpi(Props{m}.SetAccess, 'public') && ~Props{m}.Dependent
            pub_proplist{m} = Props{m}.Name;
        end
        
    end
    
    % remove empty cells
    pub_proplist(cellfun(@isempty, pub_proplist)) = [];
    
end % end of function 'get_obj_public_access_prop'