function F = celsius2fahrenheit(C)
% celsius2fahrenheit converts the temperature in degree Celsius to degree Fahrenheit
    % ----------------------------------------------------------------------------------------------
    %
    %                                    celsius2fahrenheit
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/temperature/celsius2fahrenheit.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % F = celsius2fahrenheit(C)
    % 
    % DESCRIPTION
    % -----------
    % F = celsius2fahrenheit(C) converts the temperature in degree Celsius to degree Fahrenheit.
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
    
    F = (9/5).*C +32;
    
end % end of function 'celsius2fahrenheit'