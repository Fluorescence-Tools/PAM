function cm = points2cm(points)
% points2cm converts points to centimeters
    % ----------------------------------------------------------------------------------------------
    %
    %                                         points2cm
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-03 17:28:01 +0100 (Wed, 03 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 11 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/conversion/measures/points2cm.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    %
    % SYNTAX
    % ------
    % cm = points2cm(points)
    % 
    % DESCRIPTION
    % -----------
    % cm = points2cm(points) converts points to centimeters.
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
        
    elseif ~isnumeric(points)
        % the input argument has to be a valid matrix
        errorbox('The input argument has to be a numeric matrix.', 'Bad points input', [mfilename ':Badpoints']);
    end
    
    
    % EXECUTION
    % ---------
    
    % convert points to pixels and subsequently convert these pixels to cm
    cm = pixels2cm(points./(cm2inch(72)/cm2pixels(1)));
    
end % end of function 'points2cm'