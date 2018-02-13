function pixels = cm2pixels(cm)
% cm2pixels converts centimeters to screen pixels
    % ----------------------------------------------------------------------------------------------
    %
    %                                         cm2pixels
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/measures/cm2pixels.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % pixels = cm2pixels(cm)
    % 
    % DESCRIPTION
    % -----------
    % pixels = cm2pixels(cm) converts centimeters to screen pixels.
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
        errorbox('The input argument has to be a numeric matrix.', 'Bad centimeters input', [mfilename ':BadCentimeters']);
    end
    
    
    % EXECUTION
    % ---------
    
    % get the conversion factor to convert pixels to inches
    conversionfactor = get(0, 'ScreenPixelsPerInch');
    
    % convert pixels to inches and subsequently convert these inches to cm
    pixels = cm2inch(cm).*conversionfactor;
    
end % end of function 'cm2pixels'