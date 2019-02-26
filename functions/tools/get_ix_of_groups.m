function [group_linix, start_linix, v_start] = get_ix_of_groups(tf, v)
% getlinixofgroups returns for each member of the vector the linear index of the first member of the group to which it belongs
    % ---------------------------------------------------------------------
    %
    %                        getlinixofgroups, v. 1.0
    %
    % ---------------------------------------------------------------------
    %
    % FILENAME: getlinixofgroups.m
    % VERSION : 1.0
    % DATE    : 01-Aug-2008 09:38:37
    % AUTHOR  : Nick Smisdom
    % PLACE   : University Hasselt, Belgium
    %
    % ---------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % [group_linix, start_linix] = getlinixofgroups(tf)
    % [group_linix, start_linix, v_start] = getlinixofgroups(tf, v)
    % 
    % DESCRIPTION
    % -----------
    % [group_linix, start_linix] = getlinixofgroups(tf) returns for each
    % member of the vector the linear index of the first member of the
    % group to which it belongs. A 1 in the logical vector tf indicates the
    % start of a new group. The optional output argument start_linix holds
    % the linear indix of the starts that are present in the vector.
    % 
    % [group_linix, start_linix, v_start] = getlinixofgroups(tf, v)
    % directly applies the linear indexing such that v_start holds for each
    % member of v the value of the first member of the group to which
    % it belongs. This third element can only be queried when two input
    % arguments are specified.
    % 
    % EXAMPLE
    % -------
    % Let 
    %     tf = [1 0 0 1 0  0 1 1 1 1 0 0 1 0];
    %     v  = [7 7 2 2 5 10 4 6 3 8 3 6 7 9];
    % For this situation the function can be executed and will return the
    % following vectors:
    %     group_linix = [1 1 1 4 4  4  7 8 9 10 10 10 13 13];
    %     start_linix = [1 4 7 8 9 10 13];
    %     v_start     = [7 7 7 2 2  2  4 6 3  8  8  8  7  7];
    % 
    % copyright 2008-2009
    % =====================================================================
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin < 1 || nargin > 2
        % incorrect number of input arguments
        chknarg(nargin, [1 2], nargout, [0 3], mfilename);
        
    elseif nargin == 1 && nargout > 2
        % when only one input argument is specified, maximum two output
        % arguments can be returned
        errorbox('Maximum 2 output arguments can be returned when only 1 input argument is specified', 'Too many output arguments specified', 'id', [mfilename ':2ManyOutputArgs']);
        
    elseif ~((islogical(tf) || all(tf == 1 | tf == 0))&& isvector(tf))
        % the first input argument should be a logical vector, or a vector
        % with only ones and zeros.
        errorbox('The first input argument should be a logical vector, or a vector with only ones and zeros.', 'Bad first input argument', 'id', [mfilename ':BadFirstIptArg'])
        
    elseif nargin == 2 && ~isequal(size(v), size(tf))
        % the second input argument should have the same dimensions as
        % first input vector
        errorbox('The second input argument should have the same dimensions as first input vector.', 'Bad dimensions of second input', 'id', [mfilename ':BadSecondIptArg'])
        
    end
    
    
    % EXECUTION
    % ---------
    
    % the first element of the logical vector indicating the start of each
    % group should also be true
    tf(1) = true;
    
    % find the linear indices of all elements that start a group
    start_linix = find(tf);
    
    % calculate the cumulative sum of the logical vector to construct the
    % linear index of the start in start_linix and get these elements from
    % this vector
    group_linix = start_linix(cumsum(double(tf)));
    
    if nargout == 3
        % a third input argument is specified. Create a vector that
        % contains for each member the value of the first member of the
        % group to which it belongs.
        v_start = v(group_linix);
    end
    
end % end of function 'getlinixofgroups'