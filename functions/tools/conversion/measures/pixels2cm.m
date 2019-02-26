function cm = pixels2cm(pixels)
% pixels2cm converts screen pixels to centimeters
    % ----------------------------------------------------------------------------------------------
    %
    %                                        pixels2cm
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/measures/pixels2cm.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % cm = pixels2cm(pixels)
    % 
    % DESCRIPTION
    % -----------
    % cm = pixels2cm(pixels) converts screen pixels to centimeters.
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
        
    elseif ~isnumeric(pixels)
        % the input argument has to be a valid matrix
        errorbox('The input argument has to be a numeric matrix.', 'Bad pixels input', 'id', [mfilename ':BadPixels']);
    end
    
    
    % EXECUTION
    % ---------
    
    % get the conversion factor to convert pixels to centimeters
    conversionfactor = get(0, 'ScreenPixelsPerInch');
    
    % convert pixels to inches and subsequently convert these inches to cm
    cm = inch2cm(pixels./conversionfactor);
    
end % end of function 'pixels2cm'