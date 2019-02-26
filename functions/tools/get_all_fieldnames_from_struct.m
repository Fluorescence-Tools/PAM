function [list, cntr]  = get_all_fieldnames_from_struct(s, list, level, parents, cntr, size_of_parent, last_field)
% get_all_fieldnames_from_struct returns a cell array with all its fields
	% ----------------------------------------------------------------------------------------------
    %
    %                              get_all_fieldnames_from_struct
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/get_all_fieldnames_from_struct.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % [list]  = get_all_fieldnames_from_struct(s)
    % 
    % DESCRIPTION
    % -----------
    % [list]  = get_all_fieldnames_from_struct(s) returns a n-by-5 cell array list obtained from the
    % structure s, where n is the number of fields. The columns in the cell array hold the name, a
    % cell array of parents, the level of the field, the size of the parent and a logical that is
    % true when the field of interest is the last amongst its siblings.
    % 
    % copyright 2017-2018
    % ==============================================================================================
    
    % INITIALIZATION
    % --------------
    
    % check number of output arguments
    if (nargin ~= 1 && nargin ~= 7) || nargout > 2
        % use chknarg to generate error
        chknarg(nargin, [1 1 7], nargout, [0 2], mfilename);
        
    elseif nargin == 1
        % define start values
        level = 1;
        cntr  = 1;
        parents = {inputname(1)};
        size_of_parent = [1 1];
        last_field = 0;
        list = {inputname(1) {} 0 [1 1] 1}; % No preallocation required
        
    end
    
    
    % EXECUTION
    % ---------

    if isstruct(s)
        % the input is a structure
        
        % get the fieldnames of the structure
        fields = fieldnames(s);
    
        for m = 1 : length(fields)
            % parse through all field names
            
            % increase the counter
            cntr = cntr + 1;
            
            % append current field to the list:
            % list = {name parents(cell-array) level size_of_parent is_this_last_child}
            list(cntr,1:5) = {fields{m} parents level size_of_parent last_field};
            
            if isstruct(s(1).(fields{m}))
                % get the info from the subfield.
                [list, cntr] = get_all_fieldnames_from_struct(s(1).(fields{m}), list, level + 1, [parents(:); fields(m)], cntr, size(s(1).(fields{m})), m == length(fields));
            end
            
        end
        
    end
    
end % end of function 'get_all_fieldnames_from_struct'