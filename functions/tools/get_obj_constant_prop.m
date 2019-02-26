function proplist = get_obj_constant_prop(obj)
% get_obj_constant_prop returns the list of independent, constant properties of the object
    % ----------------------------------------------------------------------------------------------
    %
    %                                  get_obj_constant_prop
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/get_obj_constant_prop.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % proplist = get_obj_constant_prop(obj)
    % 
    % DESCRIPTION
    % -----------
    % proplist = get_obj_constant_prop(obj) returns the list of independent, constant properties of
    % the given object.
    % 
    % MODIFICATIONS
    % -------------
    % 
    % Copyright 2017
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
    proplist = cell(length(Props),1);
    
    for m = 1 : length(Props)
        % parse through all properties and save the name to the list if the
        % property is not dependent and if it is constant
        if ~Props{m}.Dependent && Props{m}.Constant
            proplist{m} = Props{m}.Name;
        end
    end
    
    % remove empty cells
    proplist(cellfun(@isempty, proplist)) = [];
    
end % end of function 'get_obj_constant_prop'