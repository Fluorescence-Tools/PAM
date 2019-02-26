function K = celsius2kelvin(C)
% celsius2kelvin converts the temperature in degree Celsius to degree Kelvin
    % ----------------------------------------------------------------------------------------------
    %
    %                                        celsius2kelvin
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/temperature/celsius2kelvin.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % K = celsius2kelvin(C)
    % 
    % DESCRIPTION
    % -----------
    % K = celsius2kelvin(C) converts the temperature in degree Celsius to degree Kelvin.
    % 
    % ACKNOWLEDGEMENTS
    % ----------------
    % The CRC 'Handbook of Chemistry and Physics', 60th edition, 1979-1980, pages F-113 and F-128.
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
    
    K = C + 273.15;
    
end % end of function 'celsius2kelvin'