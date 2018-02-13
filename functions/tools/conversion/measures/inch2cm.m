function cm = inch2cm(inch)
% inch2cm converts inches to centimeters
    % ----------------------------------------------------------------------------------------------
    %
    %                                         inch2cm
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/measures/inch2cm.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % cm = inch2cm(inch)
    % 
    % DESCRIPTION
    % -----------
    % cm = inch2cm(inch) converts inches to centimeters.
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
        
    elseif ~isnumeric(inch)
        % the input argument has to be a valid matrix
        errorbox('The input argument has to be a numeric matrix.', 'Bad inches input', [mfilename ':BadInches']);
    end
    
    
    % EXECUTION
    % ---------
    
    cm = inch.*2.54;
    
end % end of function 'inch2cm'