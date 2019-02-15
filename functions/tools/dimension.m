classdef dimension
% dimension is an object to store information about the data dimensions
    % ----------------------------------------------------------------------------------------------
    %
    %                                       dimension
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-29 11:10:42 +0100 (Mon, 29 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 15 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/tools/dimension.m $
    % Original author: Nick Smisdom, Hasselt University
    % 
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % obj = dimension
    % obj = dimension(s)
    % 
    % DESCRIPTION
    % -----------
    % obj = dimension returns a dimension object holding information on the dimensions of the data.
    % 
    % obj = dimension(s) returns a dimension object with the values specified in s. s can be a
    % structure (or an array of structures), or it can be a list of parameter - parameter value
    % pairs. A template for structure s can be generated using the code: dimension.template_txt.
    % This method also copies the text to the clipboard so that it can directly be pasted into the
    % code.
    % 
    % Valid parameters are:
    %   * sn_dim                  % the serial number of the dimension
    %   * abbreviation            % the abbreviation of the dimension. Valid strings are:
    %                                   * X     horizontal direction
    %                                   * Y     vertical direction
    %                                   * Z     depth
    %                                   * T     time (macrotime)
    %                                   * C     channel
    %                                   * dT    differential time
    %                                   * t     microtime, e.g. arrival time in lifetime spectroscopy
    %                                   * L     wavelength (lambda)
    %    name                    % the name of the dimension, as displayed for the user
    %    description             % the description of the dimension
    %    total_size              % the current total size of the dimension (i.e. size of matrix dimension)
    %    unit_name               % unit name of the dimension (m, s, ...)
    %    unit_type               % type of the dimension described by unit: distance, time, wavelength, ...
    %    unit_size               % physical size of a single value in the given unit, e.g. pixel size
    %    total_phys_size         % (current) total physical size of the dimension
    %    origin                  % origin of the dimension, i.e. offset
    %    values                  % values associated with the dimension, can be a vector or cell array
    %    disp_unit_name          % unit name of the dimension (m, s, ...) as used during display
    %    disp_unit_scalefactor   % scale factor to convert unit of the dimension to the display unit
    % 
    % Copyright 2016-2018
    % ==============================================================================================
    
    properties
        sn_dim = 0;                               % the serial number of the dimension
        abbreviation@char                         % the abbreviation of the dimension. Valid strings are:
                                                  %   * X     spatial, euclidian coordinate, horizontal direction
                                                  %   * Y     spatial, euclidian coordinate, vertical direction
                                                  %   * Z     spatial, euclidian coordinate, depth
                                                  %   * T     time (macrotime)
                                                  %   * C     channel
                                                  %   * dT    differential time
                                                  %   * t     microtime, e.g. arrival time in lifetime spectroscopy
                                                  %   * L     wavelength (lambda)
                                                  %   * MP    emission polarization angle
                                                  %   * XP    excitation polarization angle
                                                  %   * R     rotation of the field of view
                                                  %   * B     block index in segmented experiments
                                                  %   * M     mosaic tile index
                                                  %   * H     phase index
                                                  %   * V     view index
        name@char                                 % the name of the dimension, as displayed for the user
        description@char                          % the description of the dimension
        total_size = 0;                           % the current total size of the dimension (i.e. size of matrix dimension)
        unit_name@char                            % unit name of the dimension (m, s, ...)
        unit_type@char                            % type of the dimension described by unit: distance, time, wavelength, ...
        unit_size@double = [];                    % physical size of a single value in the given unit, e.g. pixel size
        origin@double = 0;                        % origin of the dimension, i.e. offset
        values                                    % values associated with the dimension, can be a vector or cell array
        disp_unit_name@char                       % unit name of the dimension (m, s, ...) as used during display
        disp_unit_scalefactor@double scalar = 1;  % scale factor to convert unit of the dimension to the display unit
    end
    
    properties (SetAccess=private, Hidden)
        ori_sn_dim                  % original serial number of the dimension as retrieved from the file
        ori_abbreviation@char       % the original abbreviation of the dimension
        ori_name@char               % the original name of the dimension
        ori_description@char        % the original description of the dimension
        ori_total_size              % original total size of the dimension (i.e. size of matrix dimension)
        ori_unit_name@char          % original unit name of the dimension
        ori_unit_type@char          % type of the dimension described by unit: distance, time, wavelength, ...
        ori_unit_size               % original physical size of a single value in the given unit
        ori_origin                  % original origin of the dimension (offset)
        ori_values                  % original values associated with the dimension, can be a vector or cell array
        ori_disp_unit_name@char     % original unit name of the dimension (m, s, ...) as used during display
        ori_disp_unit_scalefactor   % original scale factor to convert unit of the dimension to the display unit
    end
    
    properties (Hidden, Constant)
        valid_abbreviations = {'X'; 'Y'; 'Z'; 'T'; 'dT'; 't'; 'C'; 'L'; 'MP'; 'XP', 'R', 'B', 'M', 'H', 'V'};     % list of valid abbreviations used to indicate a dimension
        valid_unit_types    = {'distance'; 'time'; 'channel'; 'wavelength'; 'angle'}; % list of valid abbreviations used to indicate a dimension
    end
    
    properties (Dependent)
        total_phys_size             % (current) total physical size of the dimension
    end
    
    properties (Dependent, Hidden)
        ori_total_phys_size         % original physical length of the dimension ori_physical length of the dimension
    end
    
    methods
        %% -----------------------------------------------------------------------------------------
        function obj = dimension(varargin)
            % dimension is the constructor function of the object.
            
            if nargin > 0
                % input arguments are defined.
                
                if nargin == 1 && isstruct(varargin{1}) && ~isscalar(varargin{1})
                    obj = dimension.empty(length(varargin{1}),0);
                    for m = 1 : length(varargin{1})
                        obj(m,1) = dimension(varargin{1}(m));
                    end
                    
                else
                    
                    % parse the input arguments
                    vals = obj.parse_ipt(varargin{:});
                    
                    % get the fieldnames
                    names = fieldnames(vals);
                    
                    % add the fieldnames to the object
                    for m = 1 : length(names)
                        obj.(names{m}) = vals.(names{m});
                    end
                end
            end
            
            % copy the original values to the 'ori' fields
            obj = copy2ori(obj);
            
        end % end of constructor 'dimension'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj = copy2ori(obj)
            % this function copies the current values to the 'ori' fields, to store the original
            % values.
            
            % get all public and non-dependent properties
            pub_props = get_obj_public_access_prop(obj);
            
            % cope with object arrays
            N = numel(obj);
            for n = 1 : N
                for m = 1 : length(pub_props)
                    obj(N).(['ori_' pub_props{m}]) = obj(N).(pub_props{m});
                end
            end
            
        end % end of function 'copy2ori'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj = reset(obj, varargin)
            % this function resets all properties to the original property values. An optional input
            % argument can be defined that specifies what properties need to be reset.
            
            if nargin > 1
                % an optional list of properties that has to be reset, is defined
                if nargin == 2
                    if iscell(varargin{1})
                        list = varargin{1};
                    else
                        list = varargin(1);
                    end
                else
                    list = varargin;
                end
            else
                % complete reset
                list = get_obj_public_access_prop(obj);
            end
            
            % get all public and non-dependent properties
            pub_props = get_obj_public_access_prop(obj);
            
            tf = cellfun(@(x) ismember(x, pub_props), list);
            if ~all(tf)
                % not all fields exist
                errorbox('Not all defined properties exist in the object.', 'Bad properties', [mfilename ':BadProps2Reset']);
            end
            
            % copy all properties
            % cope with object arrays
            N = numel(obj);
            for n = 1 : N
                for m = 1 : length(list)
                    obj(N).(list{m}) = obj(N).(['ori_' list{m}]);
                end
            end
            
        end % end of function 'reset'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj = set.abbreviation(obj, val)
            % this function makes sure that only one of the valid abbreviations can be set.
            
            if ~any(strcmp(val, obj.valid_abbreviations))
                errorbox(['The input ''' val ''' is not a valid dimension abbreviation.'], 'Bad dimension abbreviation', [mfilename ':BadDimAbbrev']);
            else
                obj.abbreviation = val;
                
                switch val
                    case 'X'
                        t.name        = 'Distance in X';
                        t.description = 'Spatial coordinate along the X axis';
                        t.unit_name   = 'm';
                        t.unit_type   = 'distance';
                        
                    case 'Y'
                        t.name        = 'Distance in Y';
                        t.description = 'Spatial coordinate along the Y axis';
                        t.unit_name   = 'm';
                        t.unit_type   = 'distance';
                        
                    case 'Z'
                        t.name        = 'Distance in Z';
                        t.description = 'Spatial coordinate along the Z axis';
                        t.unit_name   = 'm';
                        t.unit_type   = 'distance';
                        
                    case 'T'
                        t.name        = 'Time';
                        t.description = 'Time since the start of the experiment. Also known as macrotime';
                        t.unit_name   = 's';
                        t.unit_type   = 'time';
                        
                    case 'dT'
                        t.name        = 'Differentail time';
                        t.description = 'Time since the start of the experiment, stored as time since the last registered event';
                        t.unit_name   = 's';
                        t.unit_type   = 'time';
                        
                    case 't'
                        t.name        = 'Arrival time';
                        t.description = 'Time elapsed since the last excitation pulse. Also known as microtime';
                        t.unit_name   = 's';
                        t.unit_type   = 'time';
                        
                    case 'C'
                        t.name        = 'Detection channel';
                        t.description = 'The detection channel';
                        t.unit_name   = '';
                        t.unit_type   = 'channel';
                        
                    case 'L'
                        t.name        = 'Wavelength';
                        t.description = 'Wavelength';
                        t.unit_name   = 'm';
                        t.unit_type   = 'wavelength';
                        
                    case 'MP'
                        t.name        = 'Emission polarization angle';
                        t.description = 'Emission polarization angle';
                        t.unit_name   = '°';
                        t.unit_type   = 'angle';
                    
                	case 'XP'
                        t.name        = 'Excitation polarization angle';
                        t.description = 'Excitation polarization angle';
                        t.unit_name   = '°';
                        t.unit_type   = 'angle';
                        
                    otherwise
                        warning([mfilename ':NodefaultNameDesc'], ['No default name nor description exists for dimension type ''' val '''.'])
                end
                
                % replace fields when empty. Otherwise, fields are probably already filled by the
                % user.
                names = fieldnames(t);
                for m = 1 : length(names)
                    if isempty(obj.(names{m}))
                        obj.(names{m}) = t.(names{m});
                    end
                end
                
            end
            
        end % end of function 'set.abbreviation'
        
        
        %% -----------------------------------------------------------------------------------------
        function obj = set.unit_type(obj, val)
            % this function makes sure that only one of the valid unit types can be set.
            
            if ~any(strcmp(val, obj.valid_unit_types))
                errorbox(['The input ''' val ''' is not a valid unit type.'], 'Bad dimension unit type', [mfilename ':BadDimUnitType']);
            else
                obj.unit_type = val;
            end
            
        end % end of function 'set.unit_type'
        
        
        %% -----------------------------------------------------------------------------------------
        function val = get.total_phys_size(obj)
            % this function returns the total physical size of the dimension based on the unit size
            % and the total size of the matrix.
            
            val = obj.unit_size .* obj.total_size;
            
        end % end of function 'get.total_phys_size'
        
        
        %% -----------------------------------------------------------------------------------------
        function val = get.ori_total_phys_size(obj)
            % this function returns the total physical size of the dimension based on the unit size
            % and the total size of the matrix.
            
            val = obj.ori_unit_size .* obj.ori_total_size;
            
        end % end of function 'get.ori_total_phys_size'
        
        
        %% -----------------------------------------------------------------------------------------
        function val = get.values(obj)
            % returns the values associated with the dimension
            if ~isempty(obj.values)
                % the values are stored in the object
                val = obj.values;
                return
                
            elseif isempty(obj.values)
                % no values are stored
                
                if strcmp(obj.unit_type, 'channel')
                    val = {};
                    for m = 1 : obj.total_size
                        val{end+1,1} = sprintf('Channel %1d', m);
                    end
                else
                    if ~isempty(obj.unit_size) && ~isempty(obj.total_size)
                        val = (0:obj.total_size-1)' .* obj.unit_size;
                    else
                        val = [];
                    end
                end
            end
            
        end % end of method 'get.data_file'
        
        
        
    end
    
    
    methods (Hidden)
        %% -----------------------------------------------------------------------------------------
        function sdata = saveobj(obj)
            % this function returns a structure holding all essential data of the current object
            
            % get all independent properties of the object
          	proplist = get_obj_indep_prop(obj);
            % also save constant properties! (never know what is going to happen)
            
            for m = 1 : length(proplist)
                sdata.(proplist{m}) = obj.(proplist{m});
            end
            
        end % end of function 'saveobj'
                
    end
    
    
    methods (Static, Hidden)
        %% -----------------------------------------------------------------------------------------
        function txt = template_txt%(obj)
            % this function generates a template to create a structure to initialize a dimension
            % object. It also copies this text to the clipboard
            
            obj = dimension;
            
            % get all public and non-dependent properties
            pub_props = get_obj_public_access_prop(obj);
            
            % get the maximum length of these property names
            L = cellfun(@length, pub_props);
            max_L = max(L);
            
            lb = sprintf('\n');
            
            txt = '';
            for m = 1 : length(pub_props)
                if m == 1
                    txt = [txt 'dim_props(1) = struct(' repmat(' ', 1, max_L-L(m)) '''' pub_props{m} ''', ,...' lb]; %#ok<*AGROW>
                elseif m == length(pub_props)
                    txt = [txt repmat(' ', 1, 22) repmat(' ', 1, max_L-L(m)) '''' pub_props{m} ''', );'];
                else
                    txt = [txt repmat(' ', 1, 22) repmat(' ', 1, max_L-L(m)) '''' pub_props{m} ''', ,...' lb];
                end
            end
            
            % copy the text to clipboard
            clipboard('copy', txt);
            
        end % end of function 'template_txt'
        
        
        %% -----------------------------------------------------------------------------------------
        function vals = parse_ipt(varargin)
            % parsing the input arguments and returning a structure with fixed fields
            
            if nargin == 0 
                % no special action required
                vals = struct();
                return
                
            else
                
                L = length(varargin); % total number of input arguments
                c = 0;                % counter to keep track of input argument
                
                while c < L
                    % increase the counter
                    c = c + 1;
                    
                    if isstruct(varargin{c})
                        % convert structure to cell array as it were individual input arguments.
                        temp = struct2cellwfieldnames(varargin{c});
                        varargin = [varargin(1:(c-1)) temp varargin((c+1):end)];
                        c    = c - 1;            % reset the counter
                        L    = length(varargin); % reset the total number of input arguments
                        continue
                    end
                    
                    % parse through all remaining parameter - parameter value pairs
                    switch lower(varargin{c})
                        case 'sn_dim'
                            % the serial number of the dimension
                            if ~isempty(varargin{c+1}) && (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}) || round(varargin{c+1})~=varargin{c+1})
                                % the serial number of the dimension has to be a positive integer.
                                errorbox('The dimension option ''sn_dim'' should be a positive integer.', 'Bad dimension option ''sn_dim''', [mfilename ':BadSNDim']);
                            else
                                vals.sn_dim = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'abbreviation'
                            % the abbreviation of the dimension. Valid strings are:
                                %   * X     horizontal direction
                                %   * Y     vertical direction
                                %   * T     time (macrotime)
                                %   * C     channel
                                %   * dT    differential time
                                %   * t     microtime, e.g. arrival time in lifetime spectroscopy
                                %   * L     wavelength (lambda)
                            if ~isempty(varargin{c+1}) && ~ischar(varargin{c+1})
                                % the abbreviation of the dimension has to be a valid string
                                errorbox('The dimension option ''abbreviation'' should be a valid string.', 'Bad dimension option ''abbreviation''', [mfilename ':BadAbbrev']);
                            else
                                vals.abbreviation = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'name'
                            % the name of the dimension, as displayed for the user
                            if ~isempty(varargin{c+1}) && ~ischar(varargin{c+1})
                                % the name of the dimension has to be a valid string
                                errorbox('The dimension option ''name'' should be a valid string.', 'Bad dimension option ''name''', [mfilename ':BadName']);
                            else
                                vals.name = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'description'
                            % the description of the dimension
                            if ~isempty(varargin{c+1}) && ~ischar(varargin{c+1})
                                % the description of the dimension has to be a valid string
                                errorbox('The dimension option ''description'' should be a valid string.', 'Bad dimension option ''description''', [mfilename ':BadDescription']);
                            else
                                vals.description = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'total_size'
                            % the current total size of the dimension (i.e. size of matrix dimension)
                            if ~isempty(varargin{c+1}) && (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}) || varargin{c+1}<0)
                                % the total size of the dimension has to be a number
                                errorbox('The dimension option ''total_size'' should be a positive number.', 'Bad dimension option ''total_size''', [mfilename ':BadTotSize']);
                            else
                                vals.total_size = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'unit_name'
                            % unit name of the dimension (m, s, ...)
                            if ~isempty(varargin{c+1}) && ~ischar(varargin{c+1})
                                % the unit name of the dimension has to be a valid string
                                errorbox('The dimension option ''unit_name'' should be a valid string.', 'Bad dimension option ''unit_name''', [mfilename ':BadUnitName']);
                            else
                                vals.unit_name = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'unit_type'
                            % type of the dimension described by unit: distance, time, wavelength, ...
                            if ~isempty(varargin{c+1}) && ~ischar(varargin{c+1})
                                % the unit type of the dimension has to be a valid string
                                errorbox('The dimension option ''unit_type'' should be a valid string.', 'Bad dimension option ''unit_type''', [mfilename ':BadUnitType']);
                            else
                                vals.unit_type = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'unit_size'
                            % physical size of a single value in the given unit, e.g. pixel size
                            if ~isempty(varargin{c+1}) && (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}) || varargin{c+1}<0)
                                % the unit size of the dimension has to be a number
                                errorbox('The dimension option ''unit_size'' should be a number.', 'Bad dimension option ''unit_size''', [mfilename ':BadUnitSize']);
                            else
                                vals.unit_size = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
%                             
%                         case 'total_phys_size'
%                             % total physical size of the dimension
%                             if ~isempty(varargin{c+1}) && (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}) || varargin{c+1}<0)
%                                 % the total physical size of the dimension has to be a number
%                                 errorbox('The dimension option ''total_phys_size'' should be a number.', 'Bad dimension option ''total_phys_size''', [mfilename ':BadTotPhysSize']);
%                             else
%                                 vals.total_phys_size = varargin{c+1};
%                                 c = c + 1; % increase the counter
%                             end
                            
                        case 'origin'
                            % origin of the dimension, i.e. offset
                            if ~isempty(varargin{c+1}) && (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}))
                                % the origin of the dimension has to be a number
                                errorbox('The dimension option ''origin'' should be a number.', 'Bad dimension option ''origin''', [mfilename ':BadOrigin']);
                            else
                                vals.origin = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'values'
                            % values associated with the dimension, can be a vector or cell array
                            if ~isempty(varargin{c+1}) && ((~isvector(varargin{c+1}) || ~isnumeric(varargin{c+1})) || iscell(varargin{c+1}))
                                % the values of the dimension has to be a vector
                                errorbox('The dimension option ''values'' should be a scalar or vector.', 'Bad dimension option ''values''', [mfilename ':BadValues']);
                            else
                                vals.values = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'disp_unit_name'
                            % unit name of the dimension (m, s, ...) as used during display
                            if ~isempty(varargin{c+1}) && ~ischar(varargin{c+1})
                                % the display unit name of the dimension has to be a valid string
                                errorbox('The dimension option ''disp_unit_name'' should be a valid string.', 'Bad dimension option ''disp_unit_name''', [mfilename ':BadDispUnitName']);
                            else
                                vals.disp_unit_name = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                            
                        case 'disp_unit_scalefactor'
                            % scale factor to convert unit of the dimension to the display unit
                            if ~isempty(varargin{c+1}) && (~isscalar(varargin{c+1}) || ~isnumeric(varargin{c+1}) || varargin{c+1}<0)
                                % the scale factor of the dimension has to be a number
                                errorbox('The dimension option ''disp_unit_scalefactor'' should be a number.', 'Bad dimension option ''disp_unit_scalefactor''', [mfilename ':BadDispUnitScaleFactor']);
                            else
                                vals.disp_unit_scalefactor = varargin{c+1};
                                c = c + 1; % increase the counter
                            end
                        
                        otherwise
                            % parameter not recognized
                            errorbox(['The parameter ''' varargin{c} ''' is not supported by ' mfilename '.'], 'Optional parameter not supported', [mfilename ':BadOptionalIpt']);
                            
                    end
                    
                end % end of while loop
            end % end of large if
            
        end % end of function 'parse_ipt'
        
        %% -----------------------------------------------------------------------------------------
        function obj = loadobj(ldata)
            % this function restores the object using the structure produced by saveobj
            
            if isstruct(ldata)
                
                % Call default constructor
                obj = dimension;
                
                % get all independent properties of the object
                proplist = get_obj_indep_prop(obj);
                
                % remove all constant properties from this list
                constant = get_obj_constant_prop(obj);
                proplist(ismember(proplist, constant)) = [];
                
                % Assign property values from struct
                fields = fieldnames(ldata);
                
                % remove fields with constant properties
                fields(ismember(fields, constant)) = [];
                
                % check values of constant properties
                for m = 1 : length(constant)
                    if isfield(ldata, constant{m})
                        if ~isequal(obj.(constant{m}), ldata.(constant{m}))
                            warning([mfilename ':Constant changed'], ['The constant property ''' constant{m} ''' saved for the object differs from the current value.'])
                        end
                    end
                end
                
                for m = 1 : length(fields)
                    if any(strcmp(fields{m}, proplist))
                        obj.(fields{m}) = ldata.(fields{m});
                    else
                        errorbox(['Error upon loading ''dimension'' object. The field ''' fields{m} ''' does not exist'], 'Bad dimension object load', [mfilename ':BadObjLoad']);
                    end
                end
                
            else
                errorbox('The load function of the object ''dimension'' expected a structure.', 'Bad load structure', [mfilename ':BadLoadStruct']);
            end
            
        end % end of function 'loadobj'
        
    end % end of static methods
    
end % end of class definition 'dimension'