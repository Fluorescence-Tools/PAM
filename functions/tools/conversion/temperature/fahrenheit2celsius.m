function C = fahrenheit2celsius(F)
% fahrenheit2celsius converts the temperature in degree Fahrenheit to degree Celsius
    % ----------------------------------------------------------------------------------------------
    %
    %                                    fahrenheit2celsius
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/temperature/fahrenheit2celsius.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % C = fahrenheit2celsius(F)
    % 
    % DESCRIPTION
    % -----------
    % C = fahrenheit2celsius(F) converts the temperature in degree Fahrenheit to degree Celsius.
    % 
    % ACKNOWLEDGEMENTS
    % ----------------
    % The CRC 'Handbook of Chemistry and Physics', 60th edition, 1979-1980, pages F-106, F-128 and
    % F-134.
    % 
    % copyright 2008-2017
    % ==============================================================================================
    
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1 || nargout > 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
        
    end
    
    
    % EXECUTION
    % ---------
    
    C = (F-32)*(5/9);
    
end % end of function 'fahrenheit2celsius'