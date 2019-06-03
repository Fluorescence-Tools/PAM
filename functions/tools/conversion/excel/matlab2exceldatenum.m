function ExcelDateNum = matlab2exceldatenum(MATLABDateNum)
% matlab2exceldatenum converts MATLAB serial date format to excel serial date format
    % ----------------------------------------------------------------------------------------------
    %
    %                                       matlab2exceldatenum
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/excel/matlab2exceldatenum.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % ExcelDateNum = matlab2exceldatenum(MATLABDateNum)
    %
    % DESCRIPTION
    % -----------
    % ExcelDateNum = matlab2exceldatenum(MATLABDateNum) converts the serial date MATLABDateNum, as
    % returned by MATLAB, to the Microsoft Excel serial date number. MATLABDateNum has to be a
    % numeric matrix.
    %
    % REMARKS
    % -------
    % * For pc's, Excel starts date serial numbers from the first of January 1900. Dates before this
    %   offset are not possible. This offset is different for Macintosh systems. Matlab, in
    %   contrast, starts counting from the first of January 0000. Any date before this offset is set
    %   to NaN.
    % * Excel includes 29 February 1900 into its list, while MATLAB does not. As a result, all dates
    %   returned by Excel beyond the 28th of February 1900 deviate by one day from the MATLAB
    %   notation. This effect is corrected for in this function.
    % 
    % EXAMPLES
    % --------
    % * suppose MATLAB returns a serial date of 693962 for the first of January 1900. Its Excel
    %   counterpart can be calculated as: 
    %   matlab2exceldatenum(693962)
    %   This returns the serial number '1'. When inserted in Excel, this serial date number returns
    %   '01-Jan-1900'.
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
    
    elseif ~isnumeric(MATLABDateNum)
        % the input argument should be numeric
        errorbox('The input argument specifying the MATLAB serial date (or dates) should be numeric.', 'Bad date serial number', [mfilename ':BadMATLABDataSerial']);
        
    end
    
    
    % EXECUTION
    % ---------
    
    if ~ispc
        % the current system is not a pc. Inform the user about possible
        % errors
        warningbox('The system is not a pc. Notice that Excel uses a different date offset on Macintosh machines. This offset is not yet fully tested.', 'Difference due to Macintosh', [mfilename ':MacintoshDiff']);
        
        % determine the offset
        
        % 31 dec 1903 should return zero in Excel
        offset = datenum('31 dec 1903');
        
        % calculate the date
        ExcelDateNum = double(MATLABDateNum - offset);
        
        % set all serial date numbers smaller than 1 to NAN
        ExcelDateNum(ExcelDateNum<1) = NaN;
        
    else
        % the current system is a pc
        
        % determine the offset
        
        % '31 dec 1899' should return zero in Excel
        offset = datenum('31 dec 1899');
        
        % calculate the excel serial dates for all dates as if they are all
        % later than the 29 of Februari 1900.
        ExcelDateNum = double(MATLABDateNum - offset + 1);
        
        % set all serial date numbers smaller than 1 to NAN
        ExcelDateNum(ExcelDateNum<1) = NaN;
        
        % decrease all serial date numbers smaller than or equal to 60 with
        % 1 to correct for the missing 29 February 1900
        ExcelDateNum(ExcelDateNum<=60) = ExcelDateNum(ExcelDateNum<=60) - 1;
        
    end
    
end % end of function 'matlab2exceldatenum'