function inch = cm2inch(cm)
% cm2inch converts centimeters to inches
    % ----------------------------------------------------------------------------------------------
    %
    %                                        cm2inch
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/measures/cm2inch.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % inch = cm2inch(cm)
    % 
    % DESCRIPTION
    % -----------
    % inch = cm2inch(cm) converts centimeters to inches.
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
        
    elseif ~isnumeric(cm)
        % the input argument has to be a valid matrix
        errorbox('The input argument has to be a numeric matrix.', 'Bad centimeters input', [mfilename ':BadCM']);
    end
    
    
    % EXECUTION
    % ---------
    
    inch = cm./2.54;
    
end % end of function 'cm2inch'