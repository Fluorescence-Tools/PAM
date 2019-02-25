function tf = islut(C)
% islut returns true if the input argument is a valid LUT
    % ----------------------------------------------------------------------------------------------
    %
    %                                          islut
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/islut.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % tf = islut(C)
    %
    % DESCRIPTION
    % -----------
    % tf = islut(C) returns true if C is a valid Look-up table (LUT). Such a LUT is actually
    % equivalent to a colormap. A LUT may have any number of rows, but it must have exactly 3
    % columns.  Each row is interpreted as a color, with the first element specifying the intensity
    % of red light, the second green, and the third blue. Color intensity can be specified on the
    % interval 0.0 to 1.0. For example, [0 0 0] is black, [1 1 1] is white, [1 0 0] is pure
    % red, [.5 .5 .5] is gray, and [127/255 1 212/255] is aquamarine.
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
        
    end
    
    
    % EXECUTION
    % ---------
    
    % A LUT is actually a colormap. Therefore, IsColormap is used.
    tf = iscolormap(C);
    
end % end of function 'islut'