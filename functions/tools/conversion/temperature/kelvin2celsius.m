function C = kelvin2celsius(K)
% kelvin2celsius converts the temperature in degree Kelvin to degree Celsius
    % ----------------------------------------------------------------------------------------------
    %
    %                                      kelvin2celsius
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/temperature/kelvin2celsius.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % C = kelvin2celsius(K)
    % 
    % DESCRIPTION
    % -----------
    % C = kelvin2celsius(K) converts the temperature in degree Kelvin to degree Celsius
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
    
    C = K - 273.15;
    
end % end of function 'kelvin2celsius'