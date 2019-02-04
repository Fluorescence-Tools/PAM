function MATLABDateNum = excel2matlabdatenum(ExcelDateNum)
% excel2matlabdatenum converts excel serial date format to MATLAB serial date format
    % ----------------------------------------------------------------------------------------------
    %
    %                                      excel2matlabdatenum
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/excel/excel2matlabdatenum.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % MATLABDateNum = excel2matlabdatenum(ExcelDateNum)
    %
    % DESCRIPTION
    % -----------
    % MATLABDateNum = excel2matlabdatenum(ExcelDateNum) converts the serial date ExcelDateNum, as
    % returned by Microsoft Excel, to the MATLAB serial date number. ExcelDateNum has to be a
    % numeric matrix.
    %
    % REMARKS
    % -------
    % * For pc's, Excel starts date serial numbers from the first of January 1900. Dates before this
    %   offset are not possible. This offset is different for Macintosh systems. Matlab, in
    %   contrast, starts counting from the first of January 0000.<br>
    % * Excel includes 29 February 1900 into its list, while MATLAB does not. As a result, all dates
    %   returned by Excel beyond the 28th of February 1900 deviate by one day from the MATLAB
    %   notation. This effect is corrected for in this function. The function will also return NaN
    %   when 29 February 1900 is inserted.
    % 
    % EXAMPLES
    % --------
    % * suppose Excel returns a serial date of 1 for the first of January 1900. Its MATLAB
    % counterpart can be calculated as:<br> 
    %   excel2matlabdatenum(1)<br>
    %   This returns the serial number '693962'. By using the function datestr, this number can be
    %   converted to the date string
    %   '01-Jan-1900'
    % 
    % MODIFICATIONS
    % -------------
    %
    % 
    % Copyright 2008-2017
    % ==============================================================================================
     
    % INITIALISATION
    % --------------
    
    % check number of input and output arguments
    if nargin ~= 1
        % use chknarg to generate error
        chknarg(nargin, 1, nargout, [0 1], mfilename);
    
    elseif ~isnumeric(ExcelDateNum)
        % the input argument should be numeric
        errorbox('The input argument specifying the Excel serial date (or dates) should be numeric.', 'Bad date serial number', 'id', [mfilename ':BadExcellDataSerial']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    if ~ispc
        % the current system is not a pc. Inform the user about possible
        % errors
        warningbox('The system is not a pc. Notice that Excel uses a different date offset on Macintosh machines. This offset is not yet fully tested.', 'Difference due to Macintosh', 'id', [mfilename ':MacintoshDiff']);
        
        % determine the offset
        
        % 31 dec 1903 should return zero in Excel
        offset = datenum('31 dec 1903');
        
        % calculate the date
        MATLABDateNum = double(ExcelDateNum + offset);
        
    else
        % the current system is a pc
        
        % determine the offset
        
        % '31 dec 1899' should return zero in Excel
        offset = datenum('31 dec 1899');
        
        % get all serial date numbers smaller than or equal to 60
        group = floor(ExcelDateNum)<=60;
        
        % allocate memory to store the MATLAB serial numbers. This is
        % necessary to enable logical indexing
        MATLABDateNum = zeros(size(ExcelDateNum));
        
        % calculate the MATLAB serial dates for all dates earlier than the
        % 29 of Februari 1900.
        MATLABDateNum(group) = ExcelDateNum(group) + offset;
        
        % set all dates equal to the 29 of Februari 1900 to NaN
        MATLABDateNum(floor(ExcelDateNum)==60) = NaN;
        
        % calculate the MATLAB serial dates for all dates later than the
        % 29 of Februari 1900. Remove the number for the unexisting 29 of
        % Februari 1900.
        MATLABDateNum(~group) = ExcelDateNum(~group) + offset - 1;
        
    end
    
end % end of function 'excel2matlabdatenum'