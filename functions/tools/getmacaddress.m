function macaddress = getmacaddress
% getmacaddress returns the MAC-address of the current computer
    % ----------------------------------------------------------------------------------------------
    %
    %                                  getmacaddress
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/getmacaddress.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % macaddress = getmacaddress
    % 
    % DESCRIPTION
    % -----------
    % macaddress = getmacaddress returns the MAC-address of the current computer. This function
    % works on Windows OS and linux OS.
    % 
    % Copyright 2010-2017
    % ==============================================================================================
    
    
    % INITIALIZATION
    % --------------

    if nargin > 0 || nargout > 1
        chknarg(nargin, 0, nargout, [0 1], mfilename);
    elseif ismac 
        % the current function does not run a Mac OS.
        errorbox(sprintf('The current version of %s only supports a Windows and linux OS.', mfilename), 'OS not supported', 'id', [mfilename ':OSNotSupported']);
    end
    
    
    % EXECUTION
    % ---------
    
    if ispc
        % for Windows
        
        % get the information using dos
        [~, result] = dos('ipconfig /all');
        
        % search for the address in the output
        [start, finish] = regexp(result, '\w*-\w*-\w*-\w*-\w*-\w*');
        
        try
            macaddress = result(start(1):finish(1));
        catch ME
            % the address could not be found
            % display a warning message and return empty MAC address
            warningbox(sprintf('The MAC address could not be retrieved due to the following reason:\n\n"%s"', ME.message), ...
                'No MAC found', 'id', [mfilename ':NoMacFound' getidtail(ME.identifier)]);
            macaddress = '';
        end
    else
        % for linux
        
        % get the information using unix
        [~, result] = unix('ifconfig -a');
        
        % search for the address in the output
        [start, finish] = regexp(result, 'HWaddr \w\w:\w\w:\w\w:\w\w:\w\w:\w\w');
        
        try
            for m = 1 : length(start)
                macaddress(m,:) = regexprep(result(start(m)+7:finish(m)), ':', '-'); %#ok<AGROW>
            end
        catch ME
            % the address could not be found
            % display a warning message and return empty MAC address
            warningbox(sprintf('The MAC address could not be retrieved due to the following reason:\n\n"%s"', ME.message), ...
                'No MAC found', 'id', [mfilename ':NoMacFound' getidtail(ME.identifier)]);
            macaddress = '';
        end
        
    end
    
end % end of function 'getmacaddress'