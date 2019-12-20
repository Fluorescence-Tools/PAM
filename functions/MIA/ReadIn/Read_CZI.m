function [data, imfo] = Read_CZI(varargin)
% Read_CZI returns data and metadata from a Zeiss CZI file
	% ----------------------------------------------------------------------------------------------
    %
    %                                       Read_CZI
    %
    % ----------------------------------------------------------------------------------------------
    %
    % $LastChangedDate: 2018-01-30 23:59:05 +0100 (Tue, 30 Jan 2018) $
    % $LastChangedBy: SmisdomN $
    % $Revision: 17 $
    % $HeadURL: svn+ssh://biophysicsnick/home/lucp1791/core_tlbx/trunk/IO/zeiss/Read_CZI.m $
    % Original author: Nick Smisdom, Hasselt University
    %
    % ----------------------------------------------------------------------------------------------
    % 
    % SYNTAX
    % ------
    % [data, info] = Read_CZI(filename)
    % 
    % DESCRIPTION
    % -----------
    % 
    % [data, info] = Read_CZI(info) to save time
    % tile is dimension M
    % 
    % copyright 2017-2018
    % ==============================================================================================
    
    % INITIALIZATION
    % --------------
    
    % check number of output arguments
    if nargout < 1 || nargout > 2
        % use chknarg to generate error
        chknarg(nargin, [0 40], nargout, [1 2], mfilename);
    else
        % parse the input arguments
        [opts, imfo] = parse_iptargs(varargin{:});
    end
    
    
    % EXECUTION
    % ---------
    
    % document used: ZISRAW (CZI) File Format, Design specification, V 1.2.2 (12 July 2016)

    % DEVELOPMENT NOTES
    % -----------------
    % Datatypes
    %   * Byte --> uint8 or char
    %   * Int --> uint32
    %   * Int32 --> int32
    %   * Int64 --> int64
    %   * Float --> single
    %   * Bool --> int32, values 0 or 65535
    
    % prepare the file for actual reading
    if ~opts.imfo_set
        % no information structure supplied. Read the file in a regular way
        
        % open the czi file
        opts.fid = openfile(opts.filename, 'extension', '*.czi', 'extensiontitle', 'Zeiss image data file');
        
        if opts.fid == 0
            % no proper file is selected.
            % return empty outputs
            data = [];
            imfo = [];            
            return
            
        else
            % make sure that we have the correct file name
            imfo.file.fullpath = fopen(opts.fid);
            % get the name of the file
            [~, imfo.filename, xt] = fileparts(imfo.file.fullpath);
            imfo.filename = [imfo.filename xt];
            % get the date of the file
            a = dir(imfo.file.fullpath);
            imfo.file.date    = a.date;
            imfo.file.datenum = a.datenum;
                        
            % For tracking purpose, add specifications on the read function
            imfo.read_fcn.name           = mfilename;
            imfo.read_fcn.version        = '1.1';
            imfo.read_fcn.type           = 'Zeiss image data file';
            imfo.read_fcn.file_extension = 'czi';
            imfo.read_fcn.date           = datestr(now);
        end
    
    else
        % the information structure is supplied by the user.
        
        % make sure that the file exists
        if ~isfile(opts.filename)
            errorbox('The file defined in the information structure does not exist.', 'Bad file', [mfilename ':BadFileInImfo']);
        end
        
        % open the file
        [opts.fid, msg] = fopen(opts.filename, 'r','l');
        
        if opts.fid == -1
            % the file is not opened correctly
            [~, filename, xt] = fileparts(imfo.file.fullpath);
            errorbox(['The file ''' filename xt ''' could not be opened correctly:' newline msg], 'Unable to open file', [mfilename ':FileCouldNotBeOpened']);
        end
        
    end
        
    % close the file properly upon any error, or just at the end
    cleanup = onCleanup(@() fclose(opts.fid));
    
    
    % at this point, the file is open and can be read from.
    
    % Anders: disabling waitbar as the progress_obj class causes issue on
    % compilation of PAM
    opts.wb_tf = false;
    if opts.wb_tf
        % prepare the waitbar if required
        
        % inform the user about the current status
        %opts.h_wb = progress_obj([], ['Reading ''' imfo.filename ''' ...'], 'min_elapsed_time', 0.5, 'reduce_calls', 'on');
        
        % close the waitbar when the function stops
        %wb_stop = onCleanup(@() opts.h_wb.close);
    else
        opts.h_wb.update = @() true;
    end
    
    % display text if wanted
    if opts.verbose_tf
        % inform the user about the current progress
        fprintf(1, ['Started reading ''' imfo.filename ''' in folder ''' regexprep(fileparts(imfo.file.fullpath), '\\', '\\\\') '''' newline])
    end
    
    %%
    % FILE HEADER SEGMENT
    % -------------------
    % read the file header segment
    
    if ~opts.imfo_set
        % no information structure supplied. Read the file header segment
        
        % display text if wanted
        if opts.verbose_tf
            % inform the user about the current progress
            fprintf(1, ['\tReading header information...' newline])
        end
        
        % read the file header segment ID. (see section 4.2, p.11-12)
        imfo.debug.fileheader.id = fread(opts.fid, 16, '*char')';
        if isempty(imfo.debug.fileheader.id) || ~isequal(['ZISRAWFILE' char([0 0 0 0 0 0])], imfo.debug.fileheader.id)
            % The first 16 characters of the file should match 'ZISRAWFILE      '
            errorbox(['Invalid CZI file. A valid CZI file has to start with ''ZISRAWFILE'', while the current file (' imfo.filename ') starts with ''' imfo.debug.fileheader.id '''.'], 'Bad CZI file header', [mfilename ':BadcziHeader']);
        end

        % read the allocated size of the segment
        imfo.debug.fileheader.allocated_size = fread(opts.fid, 1, '*int64');
        % read the size used by the segment
        imfo.debug.fileheader.used_size = fread(opts.fid, 1, '*int64');

        % make sure that used_size is smaller than allocated_size
        if imfo.debug.fileheader.allocated_size < imfo.debug.fileheader.used_size
            % If the current number of bytes used is larger than the total number of bytes allocated for
            % this segment, this segment is invalid. This is not allowed for the initial file header
            errorbox(['Invalid CZI file. The number of bytes used by the file header segment (' num2str(imfo.debug.fileheader.used_size) ' bytes) is larger than the allocated number of bytes (' num2str(imfo.debug.fileheader.allocated_size) ' bytes).'], 'Bad CZI file header segment', [mfilename ':BadcziHeaderSegment']);
        end


        % read the file header content
        imfo.debug.fileheader.major = fread(opts.fid, 1, '*uint32');
        if imfo.debug.fileheader.major ~= 1
            errorbox(['The ''Major'' field should be ''1'', but is ''' num2str(imfo.debug.fileheader.major) ''' instead.'], 'Bad ''Major'' field', [mfilename ':BadMajor']);
        end

        % read minor and skip 8 bytes from Reserved1 and Reserved2
        imfo.debug.fileheader.minor = fread(opts.fid, 1, '*uint32',8);
        if imfo.debug.fileheader.minor ~= 0
            errorbox(['The ''Minor'' field should be ''0'', but is ''' num2str(imfo.debug.fileheader.minor) ''' instead.'], 'Bad ''Major'' field', [mfilename ':BadMinor']);
        end

        % unique ID of master file (filepart 0)
        imfo.file.PrimaryFileGuid = sprintf('%d', fread(opts.fid, 4, '*int32')');
        imfo.debug.fileheader.PrimaryFileGuid = imfo.file.PrimaryFileGuid;
        % unique ID of file
        imfo.file.FileGuid = sprintf('%d', fread(opts.fid, 4, '*int32')');
        imfo.debug.fileheader.FileGuid = imfo.file.FileGuid;
        % get the part number in multi-file scenarios
        imfo.file.FilePart = fread(opts.fid, 1, '*int32');
        imfo.debug.fileheader.FilePart = imfo.file.FilePart;
        imfo.debug.fileheader.DirectoryPosition = fread(opts.fid, 1, '*int64');
        imfo.debug.fileheader.MetadataPosition  = fread(opts.fid, 1, '*int64');
        imfo.debug.fileheader.UpdatePending     = logical(fread(opts.fid, 1, '*uint32'));
        imfo.offsets.directory = imfo.debug.fileheader.DirectoryPosition;
        imfo.offsets.metadata = imfo.debug.fileheader.MetadataPosition;
        if imfo.debug.fileheader.UpdatePending ~= 0
            warning([mfilename ':UpdatePending'], 'Update of the file is currently pending')
        end
        imfo.debug.fileheader.AttachmentDirectoryPosition = fread(opts.fid, 1, '*int64');
        imfo.offsets.Attachment = imfo.debug.fileheader.AttachmentDirectoryPosition;
    else
        
        % display text if wanted
        if opts.verbose_tf
            % inform the user about the current progress
            fprintf(1, ['\tFile information and metadata supplied by user.' newline])
        end
        
    end
    
    
    % the resulting structure in imfo.debug.fileheader has 3 fields (DirectoryPosition, MetadataPosition, and
    % AttachmentDirectoryPosition) that refer to the offset of these 3 segments.
    
    %%
    % SUBBLOCKDIRECTORY
    % -----------------
    
    % This block is required to read images
    
    if ~opts.imfo_set
        % no information structure supplied. Read the subblock directory
        
        % go to the position of the directory
        if fseek(opts.fid, imfo.offsets.directory, 'bof')
            errorbox('The offset to the directory list could not be reached.', 'Offset to directory not reached.', [mfilename ':OffsetDirNotReached']);
        end
        % read the Directory segment ID.(see section 4.2, p.19-20)
        imfo.debug.directory.id = fread(opts.fid, 16, '*char')';
        if isempty(imfo.debug.directory.id) || ~isequal(['ZISRAWDIRECTORY' char(0)], imfo.debug.directory.id)
            % The first 16 characters should match 'ZISRAWDIRECTORY '
            errorbox(['Invalid CZI file. The directory Segment should start with ''ZISRAWDIRECTORY'', while in the current file (' imfo.filename ') it starts with ''' imfo.debug.directory.id '''.'], 'Bad CZI file header', [mfilename ':BadcziHeader']);
        end
        % read the allocated size of the segment
        imfo.debug.directory.allocated_size = fread(opts.fid, 1, '*int64');
        % read the size used by the segment
        imfo.debug.directory.used_size = fread(opts.fid, 1, '*int64');
        
        % make sure that used_size is smaller than allocated_size
        if imfo.debug.directory.allocated_size < imfo.debug.directory.used_size
            % If the current number of bytes used is larger than the total number of bytes allocated for
            % this segment, this segment is invalid. This is not allowed for a segment
            errorbox(['Invalid CZI file. The number of bytes used by the directort segment (' num2str(imfo.debug.directory.used_size) ' bytes) is larger than the allocated number of bytes (' num2str(imfo.debug.directory.allocated_size) ' bytes).'], 'Bad CZI file directory segment', [mfilename ':BadcziDirectorySegment']);
        end
        
        % read the number of entries, but skip the reserved bytes first
        imfo.debug.directory.entrycount = fread(opts.fid, 1, '*int32', 124);
        
        % preallocate memory to store directory information
        imfo.offsets.images = zeros(imfo.debug.directory.entrycount, 7, 'int32');
        ImageDims = cell(imfo.debug.directory.entrycount,1);
        
        % parse through all directories
        for m = 1 : imfo.debug.directory.entrycount
            [imfo.offsets.images(m,:), ImageDims{m,1}] = read_directory_entry(opts);
        end
        
        % save the description to keep track of their meaning
        imfo.offsets.images_description = {'PixelType' 'FilePosition_byte14' 'FilePosition_byte58' 'Filepart' 'Compression' 'PyramidType' 'DimensionCount'};
        
        % note:
        % offsets.images = [PixelType FilePosition_byte14 FilePosition_byte58 Filepart Compression PyramidType DimensionCount]
        % Note: the correct offset of each image can be calculated as typecast([FilePosition_byte14 FilePosition_byte58], 'int64').
    
        % ImageDims = [dimension name (in 'uint8'),
        %              the start position or index
        %              the size in units of pixels,
        %              physical start coordinate (units e.g. micrometers or seconds)--> use typecast(x,'single') for a correct representation
        %              stored size (if sub/supersampling, else 0)
        
        % Make sure that all image directories have the same number of dimensions
        if numel(unique(imfo.offsets.images(:,7))) > 1
            errorbox('Not all image frames have the same number of dimensions. The routine to read the data can''t handle this situation.', 'Unsupported situation with number of dimensions.', [mfilename ':UnsupNDims'])
        else
            % combine the image dimensions to a single matrix
            ImageDims = cat(3, ImageDims{:});
            imfo.dimensions.props = ImageDims;
        end
        
        % Make sure that the images all have the same kind of dimensions
        if any(any(diff((squeeze(ImageDims(:,1,:))),[], 2)))
            % Different types of dimensions are specified. This is not supported
            errorbox('Not all image frames have the same kind of dimensions. The routine to read the data can''t handle this situation.', 'Unsupported situation with kind of dimensions.', [mfilename ':UnsupKindDims'])
        end
        
        % at this point we know that each frame has identical dimensions
        
        % check for under- or oversampling
        imfo.dimensions.regularsampling = ~logical(any(any(squeeze(ImageDims(:,3,:)) - squeeze(ImageDims(:,end,:)))));
        if opts.verbose_tf && ~imfo.dimensions.regularsampling
            % inform the user about the current progress
            fprintf(1, ['\tOver- or undersampling detected...' newline])
        end
        
        imfo.dimensions.good_indices = true;
        imfo.dimensions.good_indices_D3_and_higher = true;
        imfo.dimensions.good_indices_D1_and_D2 = true;
        % no negative start of dimensions allowed
        if any(any(squeeze(ImageDims(:,2,:))<0))
            % negative start of dimensions are not allowed
            imfo.dimensions.good_indices = false;
            if any(any(squeeze(ImageDims(3:end,2,:))<0))
                imfo.dimensions.good_indices_D3_and_higher = false;
            end
            if any(any(squeeze(ImageDims(1:2,2,:))<0))
                imfo.dimensions.good_indices_D1_and_D2 = false;
            end
        end
        if opts.verbose_tf && ~imfo.dimensions.good_indices
            % inform the user about the current progress
            fprintf(1, ['\tNegative indices detected...' newline])
        end
        
        % verify that only the first 2 dimensions have a value larger than 1
        imfo.dimensions.expected_sizes = ~any(any(squeeze(ImageDims(3:end,5,:))~=1));
        if opts.verbose_tf && ~imfo.dimensions.expected_sizes
            % inform the user about the current progress
            fprintf(1, ['\t3rd dimension or higher not stored as singular frames...' newline])
        end
        
        % get the name of each dimension
        imfo.dimensions.names = char(ImageDims(:,1))';
                
        imfo.dimensions.same_frame_sizes = true;
        for m = 1:size(ImageDims,1)
            if numel(unique(squeeze(ImageDims(m,5,:)))) > 1
                imfo.dimensions.same_frame_sizes = false;
                break
            end
        end
        if opts.verbose_tf && ~imfo.dimensions.same_frame_sizes
            % inform the user about the current progress
            fprintf(1, ['\tFrame sizes differ throughout the data stack...' newline])
        end
        
        if any(diff(imfo.offsets.images(:,1)))
            % There are different pixel types present
            errorbox('Not all image have the same pixel type. The routine to read the data can''t handle this situation.', 'Unsupported situation with pixel types.', [mfilename ':UnsupPixelTypes'])
        end
        
        switch imfo.offsets.images(1)
            case 0
                imfo.dimensions.format = 'uint8';
            case 1
                imfo.dimensions.format = 'uint16';
            case 2
                imfo.dimensions.format = 'Gray32Float';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 3
                imfo.dimensions.format = 'Bgr24';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 4
                imfo.dimensions.format = 'Bgr48';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 8
                imfo.dimensions.format = 'Bgr96Float';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 9
                imfo.dimensions.format = 'Bgra32';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 10
                imfo.dimensions.format = 'Gray64ComplexFloat';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 11
                imfo.dimensions.format = 'Bgr192ComplexFloat';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 12
                imfo.dimensions.format = 'Gray32';
                error(['Pixel type ''' format ''' not supported yet.'])
            case 13
                imfo.dimensions.format = 'Gray64';
                error(['Pixel type ''' format ''' not supported yet.'])
        end
        
    else
        % get the image dimensions
        ImageDims = imfo.dimensions.props;
        
        if opts.verbose_tf 
            
            if ~imfo.dimensions.regularsampling
                % inform the user about the current progress
                fprintf(1, ['\tOver- or undersampling detected...' newline])
            end
            if ~imfo.dimensions.good_indices
                % inform the user about the current progress
                fprintf(1, ['\tNegative indices detected...' newline])
            end
            if ~imfo.dimensions.expected_sizes
                % inform the user about the current progress
                fprintf(1, ['\t3rd dimension or higher not stored as singular frames...' newline])
            end
            if ~imfo.dimensions.same_frame_sizes
                % inform the user about the current progress
                fprintf(1, ['\tFrame sizes differ throughout the data stack...' newline])
            end
        end
    end
    
    % apply frame or dimension selection
    offsets = imfo.offsets.images;
    % ImageDims is already in memory
    
    
    % prepare information for subset
    imfo.dimensions.subset.selected = false;
    if opts.frames_selected || opts.dims_selected
        if opts.verbose_tf 
            % inform the user about the current progress
            fprintf(1, ['\tPreparing to return a subset of the image...' newline])
        end
        imfo.dimensions.subset.frames_selected = opts.frames_selected;
        imfo.dimensions.subset.dims_selected = opts.dims_selected;
        imfo.dimensions.subset.frames = opts.frames;
        imfo.dimensions.subset.dims = opts.dims;
        imfo.dimensions.subset.ImageDims = [];
        imfo.dimensions.subset.offsets = [];
        
        imfo.dimensions.subset.selected = true;
        
        if opts.frames_selected
            % get the maximum number of frames
            
            max_frames = size(offsets,1);
            if any(opts.frames > max_frames)
                fprintf(2, ['\tAt least one frame number requested that is larger than the total number of frames...' newline])
                opts.frames(opts.frames > max_frames) = [];
                if isempty(opts.frames)
                    % no valid frame requested
                    errorbox('The requested frame numbers do not exist.', 'Bad frame number', [mfilename ':BadFrameNumber']);
                end
            end
            
            imfo.dimensions.subset.frames = opts.frames;
            offsets   = imfo.offsets.images(:,:,imfo.dimensions.subset.frames);
            ImageDims = ImageDims(:,:,imfo.dimensions.subset.frames);
            imfo.dimensions.subset.ImageDims = ImageDims;
            imfo.dimensions.subset.offsets = offsets;
            
        elseif opts.dims_selected
            % subset selection via dimensions
            
            % get non-empty fields in structure
            dims = fieldnames(imfo.dimensions.subset.dims);
            tf_non_empty = ~cellfun(@(x) isempty(imfo.dimensions.subset.dims.(x)), dims);
            dims = dims(tf_non_empty);
            
            tf = true(size(offsets,1),1);
            
            % select only frames that have this dimension
            for m = 1 : length(dims)
                % find the dimension number
                ix = strcmpi(dims{m}, num2cell(char(ImageDims(:,1,1))));
                
                tf = tf & any(squeeze(ImageDims(ix,2,:))+1 == imfo.dimensions.subset.dims.(dims{m})(:)',2);
                
            end
            
            offsets   = imfo.offsets.images(tf,:);
            ImageDims = ImageDims(:,:,tf);
            imfo.dimensions.subset.ImageDims = ImageDims;
            imfo.dimensions.subset.offsets = offsets;
            
        end
        
        
        % get the name of each dimension
        imfo.dimensions.names = char(ImageDims(:,1))';
                
        imfo.dimensions.same_frame_sizes = true;
        for m = 1:size(ImageDims,1)
            if numel(unique(squeeze(ImageDims(m,5,:)))) > 1
                imfo.dimensions.same_frame_sizes = false;
                break
            end
        end
        if opts.verbose_tf && ~imfo.dimensions.same_frame_sizes
            % inform the user about the current progress
            fprintf(1, ['\tFrame sizes differ throughout the data stack...' newline])
        end
    else
        if opts.verbose_tf 
            % inform the user about the current progress
            fprintf(1, ['\tPreparing to return the full image...' newline])
        end
    end
    
    
    % X an Y coordinate are reversed in comparison to matlab. There are two options to handle this:
    % load the data as is, and permute the dimensions at the end, or transpose each frame
    % separately. The second approach seems to be a bit faster (up to 10%)
    
    if opts.imdata_tf
        % keep track of elapsed time
        opts.time_log = testimator(size(imfo.offsets.images,1));
        
        imfo.dimensions.squeeze = opts.squeeze_tf;
        
        if imfo.dimensions.same_frame_sizes && imfo.dimensions.good_indices_D3_and_higher && ~opts.dims_selected && ~opts.frames_selected
            % sum start and size of each dimension
            N = [max(ImageDims(2:-1:1,5,:),[],3); max(ImageDims(3:end,2,:)+ImageDims(3:end,5,:),[],3)];
            
            % preallocate memory
            data = zeros(N', imfo.dimensions.format);
            imfo.dimensions.frames = zeros([1,1, N(3:end)'], 'uint32');
            
            if opts.verbose_tf 
                % inform the user about the current progress
                fprintf(1, ['\tReading the full image...' newline])
            end
            
            for m = 1 : size(offsets,1)
                % update waitbar if present
                if opts.wb_tf
                    % keep track of elpased time
                    %opts.time_log = testimator(opts.time_log, m);
                        
                    %if ~opts.h_wb.update(opts.time_log.ratio, ['Reading ''' imfo.filename ''': frame ' num2str(m) ' of ' num2str(size(offsets,1)) ' ' opts.time_log.txt])
                        % stop the current operation
                    %     data = [];
                    %     imfo = [];
                    %    return
                    %end
                end
                
                temp = read_imagesubblock_segment(opts, typecast(offsets(m,2:3), 'int64'));
                
                ix = cell(size(ImageDims,1),1);
                for n = 3 : size(ImageDims,1)
                    ix{n} = ImageDims(n,2,m)+1:ImageDims(n,2,m)+ImageDims(n,5,m);
                end
                try
                    data(:,:,ix{3:end}) = reshape(temp, ImageDims(:,5,m)')';
                    imfo.dimensions.frames(1,1,ix{3:end}) = m;
                catch
                    error('call Nick or send dataset to Nick (nick.smisdom@uhasselt.be)')
%                     temp = reshape(temp, ImageDims(:,3,m)');
%                     data(ix{[2 1 3:end]}) = permute(temp, [2 1 3:10]);
                end
                
            end
            
            % construct cell array that will hold the size of each dimension
            tf = cell(1,size(imfo.dimensions.props,1));
            
            % get the size of each dimensions from the data
            [tf{:}] = size(data);
            
            imfo.dimensions.all_dims_size = numcell2mat(tf);
            
            if opts.squeeze_tf
                % get a logical vector with all non-singular dimensions
                tf = imfo.dimensions.all_dims_size>1;
                
                % keep only the names that will be remained after removal of singular dimensions
                imfo.dimensions.names = imfo.dimensions.names(tf);
                imfo.dimensions.dims_size = imfo.dimensions.all_dims_size(tf);
                imfo.dimensions.included_dims = tf;
                
                % remove singular dimensions from data
                data = squeeze(data);
                s = size(imfo.dimensions.frames); s = s(3:end);
                imfo.dimensions.frames = reshape(imfo.dimensions.frames, [1 1 s(s>1)]);
                
            else
                imfo.dimensions.dims_size = imfo.dimensions.all_dims_size;
                imfo.dimensions.included_dims = imfo.dimensions.all_dims_size>1;
                
            end
            if opts.verbose_tf 
                % inform the user about the current progress
                fprintf(1, ['\tCompleted reading the full image...' newline])
            end
%         elseif imfo.dimensions.same_frame_sizes && imfo.dimensions.good_indices
%             % sum start and size of each dimension
%             N = max(ImageDims(:,2,:)+ImageDims(:,3,:),[],3);
%             
%             % preallocate memory
%             data = zeros(N([2 1 3:end])', imfo.dimensions.format);
%             
%             for m = 1 : size(imfo.offsets.images,1)
%                 % update waitbar if present
%                 if opts.wb_tf
%                     % keep track of elpased time
%                     opts.time_log = testimator(opts.time_log, m);
%                         
%                     if ~opts.h_wb.update(opts.time_log.ratio, ['Reading ''' imfo.filename ''': frame ' num2str(m) ' of ' num2str(size(imfo.offsets.images,1)) ' ' opts.time_log.txt])
%                         % stop the current operation
%                         data = [];
%                         imfo = [];
%                         return
%                     end
%                 end
%                 
%                 temp = read_imagesubblock_segment(opts, typecast(imfo.offsets.images(m,2:3), 'int64'));
%                 
%                 ix = cell(size(ImageDims,1),1);
%                 for n = 1 : size(ImageDims,1)
%                     ix{n} = ImageDims(n,2,m)+1:ImageDims(n,2,m)+ImageDims(n,3,m);
%                 end
%                 try
%                     data(ix{[2 1 3:end]}) = reshape(temp, ImageDims(:,3,m)')';
%                 catch
%                     temp = reshape(temp, ImageDims(:,3,m)');
%                     data(ix{[2 1 3:end]}) = permute(temp, [2 1 3:10]);
%                 end
%                 
%             end
%             
%             if opts.squeeze_tf
%                 % construct cell array that will hold the size of each dimension
%                 tf = cell(1,size(imfo.dimensions.props,1));
%                 
%                 % get the size of each dimensions from the data
%                 [tf{:}] = size(data);
%                 
%                 imfo.dimensions.all_dims_size = numcell2mat(tf);
%                 
%                 % get a logical vector with all non-singular dimensions
%                 tf = imfo.dimensions.all_dims_size>1;
%                 
%                 % keep only the names that will be remained after removal of singular dimensions
%                 imfo.dimensions.names = imfo.dimensions.names(tf);
%                 imfo.dimensions.dims_size = imfo.dimensions.all_dims_size(tf);
%                 imfo.dimensions.included_dims = tf;
%                 
%                 
%                 
%                 % expand this logical vector to have the same number of elements 
%                 data = squeeze(data);
%                 
%             else
%                 % construct cell array that will hold the size of each dimension
%                 tf = cell(1,size(imfo.dimensions.props,1));
%                 
%                 % get the size of each dimensions from the data
%                 [tf{:}] = size(data);
%                 
%                 imfo.dimensions.all_dims_size = numcell2mat(tf);
%                 imfo.dimensions.dims_size = imfo.dimensions.all_dims_size;
%                 % get a logical vector with all non-singular dimensions
%                 imfo.dimensions.included_dims = imfo.dimensions.all_dims_size>1;
%                 
%             end
        elseif imfo.dimensions.same_frame_sizes && imfo.dimensions.good_indices_D3_and_higher && ~opts.dims_selected && opts.frames_selected
            % specific frames requested. Return them as a single 3D stack
            
            % sum start and size of each dimension
            N = [max(ImageDims(2:-1:1,5,:),[],3); max(ImageDims(3:end,2,:)+ImageDims(3:end,5,:),[],3)];
            
            % preallocate memory
            data = zeros([N(1:2)' size(offsets,1)], imfo.dimensions.format);
            imfo.dimensions.frames = zeros([size(offsets,1) 1], 'uint32');
            
            if opts.verbose_tf 
                % inform the user about the current progress
                fprintf(1, ['\tReading the requested frames only...' newline])
            end
            
            for m = 1 : size(offsets,1)
                % update waitbar if present
                if opts.wb_tf
                    % keep track of elpased time
                    %opts.time_log = testimator(opts.time_log, m);
                        
                    %if ~opts.h_wb.update(opts.time_log.ratio, ['Reading ''' imfo.filename ''': frame ' num2str(m) ' of ' num2str(size(offsets,1)) ' ' opts.time_log.txt])
                        % stop the current operation
                    %    data = [];
                    %    imfo = [];
                    %    return
                    %end
                end
                
                temp = read_imagesubblock_segment(opts, typecast(offsets(m,2:3), 'int64'));
                
%                 ix = cell(size(ImageDims,1),1);
%                 for n = 3 : size(ImageDims,1)
%                     ix{n} = ImageDims(n,2,m)+1:ImageDims(n,2,m)+ImageDims(n,5,m);
%                 end
                try
                    data(:,:,m) = reshape(temp, ImageDims(:,5,m)')';
                    imfo.dimensions.frames(m,1) = m;
                catch
                    error('call Nick or send dataset to Nick (nick.smisdom@uhasselt.be)')
%                     temp = reshape(temp, ImageDims(:,3,m)');
%                     data(ix{[2 1 3:end]}) = permute(temp, [2 1 3:10]);
                end
                
            end
            
            if opts.verbose_tf 
                % inform the user about the current progress
                fprintf(1, ['\tCompleted reading the requested frames only...' newline])
            end
            
        elseif imfo.dimensions.same_frame_sizes && imfo.dimensions.good_indices_D3_and_higher && opts.dims_selected && ~opts.frames_selected
            % a subset based on dimension is queried
            
            ImageDims2 = ImageDims;
            
            % return the images in requested order
            
            % get non-empty fields in structure
            dims = fieldnames(imfo.dimensions.subset.dims);
            tf_non_empty = ~cellfun(@(x) isempty(imfo.dimensions.subset.dims.(x)), dims);
            dims = dims(tf_non_empty);
            
            for m = 1 : length(dims)
                % find the dimension number
                ix = strcmpi(dims{m}, num2cell(char(ImageDims2(:,1,1))));
                
                for d = 1 : size(ImageDims2,3)
                    val = ImageDims2(ix,2,d)+1;
                    ImageDims2(ix,2,d) = find(val == imfo.dimensions.subset.dims.(dims{m})(:)')-1;
                end
            end
                        
            % sum start and size of each dimension
            N = [max(ImageDims2(2:-1:1,5,:),[],3); max(ImageDims2(3:end,2,:)+ImageDims2(3:end,5,:),[],3)];
            
            % preallocate memory
            data = zeros(N', imfo.dimensions.format);
            imfo.dimensions.frames = zeros([1,1, N(3:end)'], 'uint32');
            
            if opts.verbose_tf 
                % inform the user about the current progress
                fprintf(1, ['\tReading the full image...' newline])
            end
            
            for m = 1 : size(offsets,1)
                % update waitbar if present
                if opts.wb_tf
                    % keep track of elpased time
                    % opts.time_log = testimator(opts.time_log, m);
                        
                    % if ~opts.h_wb.update(opts.time_log.ratio, ['Reading ''' imfo.filename ''': frame ' num2str(m) ' of ' num2str(size(offsets,1)) ' ' opts.time_log.txt])
                    %     % stop the current operation
                    %     data = [];
                    %    imfo = [];
                    %     return
                    % end
                end
                
                temp = read_imagesubblock_segment(opts, typecast(offsets(m,2:3), 'int64'));
                
                ix = cell(size(ImageDims2,1),1);
                for n = 3 : size(ImageDims2,1)
                    ix{n} = ImageDims2(n,2,m)+1:ImageDims2(n,2,m)+ImageDims2(n,5,m);
                end
                try
                    data(:,:,ix{3:end}) = reshape(temp, ImageDims2(:,5,m)')';
                    imfo.dimensions.frames(1,1,ix{3:end}) = m;
                catch
                    error('call Nick or send dataset to Nick (nick.smisdom@uhasselt.be)')
%                     temp = reshape(temp, ImageDims(:,3,m)');
%                     data(ix{[2 1 3:end]}) = permute(temp, [2 1 3:10]);
                end
                
            end
            
            % construct cell array that will hold the size of each dimension
            tf = cell(1,size(imfo.dimensions.props,1));
            
            % get the size of each dimensions from the data
            [tf{:}] = size(data);
            
            imfo.dimensions.all_dims_size = numcell2mat(tf);
            
            if opts.squeeze_tf
                % get a logical vector with all non-singular dimensions
                tf = imfo.dimensions.all_dims_size>1;
                
                % keep only the names that will be remained after removal of singular dimensions
                imfo.dimensions.names = imfo.dimensions.names(tf);
                imfo.dimensions.dims_size = imfo.dimensions.all_dims_size(tf);
                imfo.dimensions.included_dims = tf;
                
                % remove singular dimensions from data
                data = squeeze(data);
                s = size(imfo.dimensions.frames); s = s(3:end);
                imfo.dimensions.frames = reshape(imfo.dimensions.frames, [1 1 s(s>1)]);
                
            else
                imfo.dimensions.dims_size = imfo.dimensions.all_dims_size;
                imfo.dimensions.included_dims = imfo.dimensions.all_dims_size>1;
                
            end
            if opts.verbose_tf 
                % inform the user about the current progress
                fprintf(1, ['\tCompleted reading the full image...' newline])
            end
            
%             
%             % construct cell array that will hold the size of each dimension
%             tf = cell(1,size(imfo.dimensions.props,1));
%             
%             % get the size of each dimensions from the data
%             [tf{:}] = size(data);
%             
%             imfo.dimensions.all_dims_size = numcell2mat(tf);
%             
%             if opts.squeeze_tf
%                 % get a logical vector with all non-singular dimensions
%                 tf = imfo.dimensions.all_dims_size>1;
%                 
%                 % keep only the names that will be remained after removal of singular dimensions
%                 imfo.dimensions.names = imfo.dimensions.names(tf);
%                 imfo.dimensions.dims_size = imfo.dimensions.all_dims_size(tf);
%                 imfo.dimensions.included_dims = tf;
%                 
%                 % remove singular dimensions from data
%                 data = squeeze(data);
%                 s = size(imfo.dimensions.frames); s = s(3:end);
%                 imfo.dimensions.frames = reshape(imfo.dimensions.frames, [1 1 s(s>1)]);
%                 
%             else
%                 imfo.dimensions.dims_size = imfo.dimensions.all_dims_size;
%                 imfo.dimensions.included_dims = imfo.dimensions.all_dims_size>1;
%                 
%             end
            
            
%         elseif imfo.dimensions.same_frame_sizes && ~imfo.dimensions.good_indices
%             % sum start and size of each dimension
%             N = max(ImageDims(:,2,:)+ImageDims(:,3,:),[],3);
%             N(1:2) = max(ImageDims(1:2,3,:),[],3);
%             
%             % preallocate memory
%             data = zeros(N([2 1 3:end])', imfo.dimensions.format);
%             
%             for m = 1 : size(imfo.offsets.images,1)
%                 % update waitbar if present
%                 if opts.wb_tf
%                     % keep track of elpased time
%                     opts.time_log = testimator(opts.time_log, m);
%                         
%                     if ~opts.h_wb.update(opts.time_log.ratio, ['Reading ''' imfo.filename ''': frame ' num2str(m) ' of ' num2str(size(imfo.offsets.images,1)) ' ' opts.time_log.txt])
%                         % stop the current operation
%                         data = [];
%                         imfo = [];
%                         return
%                     end
%                 end
%                 
%                 temp = read_imagesubblock_segment(opts, typecast(imfo.offsets.images(m,2:3), 'int64'));
%                 
%                 ix = cell(size(ImageDims,1),1);
%                 for n = 1 : size(ImageDims,1)
%                     if n == 1 || n == 2
%                         ix{n} = 1:ImageDims(n,3,m);
%                     else
%                         ix{n} = ImageDims(n,2,m)+1:ImageDims(n,2,m)+ImageDims(n,3,m);
%                     end
%                 end
%                 data(ix{[2 1 3:end]}) = reshape(temp, ImageDims(:,3,m)')';
%                 
%             end
            
            
            
        else
            % preallocate memory
%             N_cell = num2cell(N(3:end));
%             data = cell(N_cell{:});
%             
%             for m = 1 : size(imfo.offsets.images,1)
%                 % update waitbar if present
%                 if opts.wb_tf
%                     % keep track of elpased time
%                     opts.time_log = testimator(opts.time_log, m);
%                         
%                     if ~opts.h_wb.update(opts.time_log.ratio, ['Reading ''' imfo.filename ''': frame ' num2str(m) ' of ' num2str(size(imfo.offsets.images,1)) ' ' opts.time_log.txt])
%                         % stop the current operation
%                         data = [];
%                         imfo = [];
%                         return
%                     end
%                 end
%                 
%                 temp = read_imagesubblock_segment(opts, typecast(imfo.offsets.images(m,2:3), 'int64'));
%                 
%                 ix = cell(size(ImageDims,1),1);
%                 for n = 1 : size(ImageDims,1)
%                     ix{n} = ImageDims(n,2,m)+1:ImageDims(n,2,m)+ImageDims(n,3,m);
%                 end
%                 data{ix{3:end}} = reshape(temp, ImageDims(:,3,m)')';
%                 
%             end
            imfo.dimensions
            errorbox('Unsupported case', 'Unsupported case', [mfilename ':UnsupCaseCallNick'])

        end
    else
        data = [];
    end
    
    % read the information
    
    if ~opts.imfo_set
        [imfo.metadata, imfo.xml] = read_metadata_segment(opts, imfo.offsets.metadata);
        
        imfo = read_attachment_directory(imfo, opts, imfo.offsets.Attachment);
        
        % calculate the expected number of megaBytes
        imfo.metadata.size_in_Mb = (sum(prod(imfo.dimensions.props(:,3,:))).*imfo.metadata.imagedocument.metadata.information.image.componentbitcount/8)/1e6;
                
    end
%     imfo.dimension_names = imfo.dimension_names(1:ndims(data));
    
end % end of function 'Read_CZI'


%% -------------------------------------------------------------------------------------------------
function [Dir, DirDim] = read_directory_entry(opts)
    % read_directory_entry reads a directory entry of variable length. Dir is a int32 matrix holding
    % the following information: 
    %  [PixelType FilePosition_byte14 FilePosition_byte58 Filepart Compression PyramidType DimensionCount]
    % Note that the correct offset of each image can be calculated as typecast([FilePosition_byte14
    % FilePosition_byte58], 'int64').
    % [description in file 'ZISRAW (CZI) File Format V 1.2.2', section 4.1 p15, 12/07/2016]
    
    % read schema type
    if ~isequal(fread(opts.fid, 2, '*char')', 'DV')
        error('this should read ''DV''.')
    end
    
    % read the directory content
%     Dir = [fread(opts.fid, 5, '*int32')' int32(fread(opts.fid, 1, '*uint8', 5)) fread(opts.fid, 1, '*int32')];
    Dir = [fread(opts.fid, 5, '*int32')' int32(fread(opts.fid, 1, '*uint8', 5)) fread(opts.fid, 1, '*int32')];
    % [PixelType FilePosition_byte14 FilePosition_byte58 Filepart Compression PyramidType DimensionCount]
    
    % Read the list of dimension entries. These entries are stored in a N-by-5 matrix in uint32
    % format to save memory.    % 
    % Description of the columns:
    %   * dimension name, e.g. 'X' --> use char(typecast(x, 'uint8')) for a correct representation
    %   * the start position or index
    %   * the size in units of pixels
    %   * physical start coordinate (units e.g. micrometers or seconds)
    %     --> use typecast(x,'single') for a correct representation
    %   * stored size (if sub/supersampling, else 0)
    % [description in file 'ZISRAW (CZI) File Format V 1.2.2', section 4.1 p15, 12/07/2016]
    
    DirDim = reshape(fread(opts.fid, 5*Dir(end), '*int32'), 5, Dir(end))';
    % read the dimension entries. These are returned as described in 'read_dimension_entry'
    
end % end of subfunction 'read_directory_entry'


%% -------------------------------------------------------------------------------------------------
function Data = read_imagesubblock_segment(opts, offset)
    % read_subblock_segment reads ...
    
    % go to the position of the subblock segment
    if ~~fseek(opts.fid, offset, 'bof')
        errorbox('The offset to the image could not be reached.', 'Bad offset', [mfilename ':OffsetNotReached'])
    end
    
    % read the file header segment ID.
    id = fread(opts.fid, 16, '*char')';
    if isempty(id) || ~isequal(['ZISRAWSUBBLOCK' char([0 0])], id)
        % The first 16 characters of the file should match 'ZISRAWSUBBLOCK  '
        error('bad header')
    end
    
    % read the allocated size of the segment
    allocated_size = fread(opts.fid, 1, '*int64');
    % read the size used by the segment
    used_size = fread(opts.fid, 1, '*int64');
    
    % make sure that used_size is smaller than allocated_size
    if allocated_size < used_size
        % If the current number of bytes used is larger than the total number of bytes allocated for
        % this segment, this segment is invalid. This is not allowed for a segment
        errorbox(['Invalid CZI file. The number of bytes used by the image subblock segment (' num2str(used_size) ' bytes) is larger than the allocated number of bytes (' num2str(allocated_size) ' bytes).'], 'Bad CZI image subblock segment', [mfilename ':BadcziImageBlockSegment']);
    end
    
    MetadataSize = fread(opts.fid, 1, '*int32');
    
    AttachmentSize = fread(opts.fid, 1, '*int32');
    
    DataSize = fread(opts.fid, 1, '*int64');
    
    [Dir] = read_directory_entry(opts);
    
    % go to the position of the subblock segment
    if ~~fseek(opts.fid, max(256 - (16 + 32 + Dir(end)*20), 0), 'cof')
        %TODO: check offset
        error('fout')
    end
    
    switch Dir(1)
        case 0
            format = 'uint8';
            f = 1;
        case 1
            format = 'uint16';
            f = 2;
        case 2
            format = 'Gray32Float';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 3
            format = 'Bgr24';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 4
            format = 'Bgr48';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 8
            format = 'Bgr96Float';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 9
            format = 'Bgra32';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 10
            format = 'Gray64ComplexFloat';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 11
            format = 'Bgr192ComplexFloat';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 12
            format = 'Gray32';
            error(['Pixel type ''' format ''' not supported yet.'])
        case 13
            format = 'Gray64';
            error(['Pixel type ''' format ''' not supported yet.'])
    end
    
    if MetadataSize > 0
        MetaData = fread(opts.fid, MetadataSize, '*char')';
    end
    
    Data = fread(opts.fid, DataSize/f, ['*' format])';
    
    if AttachmentSize > 0
        Attachments = fread(opts.fid, AttachmentSize, '*uint8')'
    end
    
end % end of subfunction 'read_directory_entry'


%% -------------------------------------------------------------------------------------------------
function [xml, xml_out] = read_metadata_segment(opts, offset)
    % read_subblock_segment reads ...
    
    % go to the position of the subblock segment
    if ~~fseek(opts.fid, offset, 'bof')
        %TODO: check offset
        error('fout')
    end
    
    % read the header of the segment.
    id = fread(opts.fid, 16, '*char')';
    if isempty(id) || ~isequal(['ZISRAWMETADATA' char([0 0])], id)
        % The first 16 characters of the file should match 'ZISRAWMETADATA  '
        error('bad header')
    end
    
    % read the allocated size of the segment
    allocated_size = fread(opts.fid, 1, '*int64');
    % read the size used by the segment
    used_size = fread(opts.fid, 1, '*int64');
      
    % read the size of the XML data
    xmlSize = fread(opts.fid, 1, '*int32');
    % read the size of the attachment
    attachmentSize = fread(opts.fid, 1, '*int32');
    
    if ~~fseek(opts.fid, 248, 'cof')
        %TODO: check offset
        error('fout')
    end
    
    xml_out = fread(opts.fid, xmlSize, '*char')';
    
%     xml = czi_xml2struct(xml_out);
    
    xml = xml2struct(xml_out);
    
    
end % end of subfunction 'read_directory_entry'


%% -------------------------------------------------------------------------------------------------
function imfo = read_attachment_directory(imfo, opts, offset)
    % read_attachment_segment reads ...
    
    % go to the position of the subblock segment
    if ~~fseek(opts.fid, offset, 'bof')
        %TODO: check offset
        error('fout')
    end
    
    % read the header of the segment.
    id = fread(opts.fid, 16, '*char')';
    if isempty(id) || ~isequal(['ZISRAWATTDIR' char([0 0 0 0])], id)
        % The first 16 characters of the file should match 'ZISRAWATTACH    '
        error('bad header')
    end
    
    % read the allocated size of the segment
    imfo.debug.attachment.allocated_size = fread(opts.fid, 1, '*int64');
    % read the size used by the segment
    imfo.debug.attachment.used_size = fread(opts.fid, 1, '*int64');
    
    % make sure that used_size is smaller than allocated_size
    if imfo.debug.attachment.allocated_size < imfo.debug.attachment.used_size
        % If the current number of bytes used is larger than the total number of bytes allocated for
        % this segment, this segment is invalid. This is not allowed for a segment
        errorbox(['Invalid CZI file. The number of bytes used by the attachment directory segment (' num2str(imfo.debug.directory.used_size) ' bytes) is larger than the allocated number of bytes (' num2str(imfo.debug.directory.allocated_size) ' bytes).'], 'Bad CZI file attachment directory segment', [mfilename ':BadcziAttachDirectorySegment']);
    end
    
    % read the number of entries, but skip the reserved bytes first
    imfo.debug.attachment.entrycount  = fread(opts.fid, 1, '*int32', 252);
    
    for m = 1 : imfo.debug.attachment.entrycount
        if m == 1
            directory = read_attachment_entry(opts);
        else
            directory(m,1) = read_attachment_entry(opts);
        end
    end
    
    for m = 1 : imfo.debug.attachment.entrycount
        
        imfo = read_attachment_segment(opts, directory(m),imfo);
        
    end
end % end of subfunction 'read_attachment_directory'


%% -------------------------------------------------------------------------------------------------
function attachment = read_attachment_entry(opts)
    % read_attachment_entry reads ...
    
    % The function assumes that the pointer is at the correct location in the file
    
    
    % read the schema type
    attachment.schema_type = fread(opts.fid, 2, '*char')';
    % read reserved keywords
    fread(opts.fid, 10, '*char');
    
    attachment.offset      = fread(opts.fid, 1, '*int64')';
    attachment.filepart    = fread(opts.fid, 1, '*int32')';
    attachment.content_guid = sprintf('%d', fread(opts.fid, 4, '*int32')');
    attachment.content_filetype = deblank(strtrim(fread(opts.fid, 8, '*char')'));
    attachment.name = deblank(strtrim(fread(opts.fid, 80, '*char')'));
    
end % end of subfunction 'read_attachment_entry'



%% -------------------------------------------------------------------------------------------------
function imfo = read_attachment_segment(opts, directory, imfo)
    % read_attachment_segment reads ...
    
    if nargin < 3
        imfo = struct;
    end
    
    % go to the position of the subblock segment
    if ~~fseek(opts.fid, directory.offset, 'bof')
        %TODO: check offset
        error('fout')
    end
    
    % read the header of the segment.
    id = fread(opts.fid, 16, '*char')';
    if isempty(id) || ~isequal(['ZISRAWATTACH' char([0 0 0 0])], id)
        % The first 16 characters of the file should match 'ZISRAWATTACH    '
        error('bad header')
    end
    
    % read the allocated size of the segment
    debug.attachment.allocated_size = fread(opts.fid, 1, '*int64');
    % read the size used by the segment
    debug.attachment.used_size = fread(opts.fid, 1, '*int64');
    
    % make sure that used_size is smaller than allocated_size
    if debug.attachment.allocated_size < debug.attachment.used_size
        % If the current number of bytes used is larger than the total number of bytes allocated for
        % this segment, this segment is invalid. This is not allowed for a segment
        errorbox(['Invalid CZI file. The number of bytes used by the attachment directory segment (' num2str(debug.directory.used_size) ' bytes) is larger than the allocated number of bytes (' num2str(debug.directory.allocated_size) ' bytes).'], 'Bad CZI file attachment directory segment', [mfilename ':BadcziAttachDirectorySegment']);
    end
    
    % read the size of the data section
    data_size = fread(opts.fid, 1, '*int32');

    % read reserved keywords
    fread(opts.fid, 12, '*char');
    
    entry = read_attachment_entry(opts);
    directory.size = data_size;
    
    % read reserved keywords
    fread(opts.fid, 112, '*char');
    
    
    
    
    
    switch directory.content_filetype
%         
        case 'JPG' % thumbnail
%             
            data = fread(opts.fid, directory.size, '*uint8')';
            imfo.extra.thumbnail = decode_jpeg(data);
            
        case 'CZTIMS'
            % read the size of the data section
            size = fread(opts.fid, 1, '*int32');
            NumberTimeStamps = fread(opts.fid, 1, '*int32');
            imfo.extra.time_stamps = fread(opts.fid, NumberTimeStamps, 'double');
            
        case 'CZEVL'
            size = fread(opts.fid, 1, '*int32');
            NumberEvents = fread(opts.fid, 1, '*int32');
            
            for m = 1 : NumberEvents
                size = fread(opts.fid, 1, '*int32');
                if isfield(imfo, 'extra') && isfield(imfo.extra, 'event')
                    imfo.extra.event(m).time = fread(opts.fid, 1, 'double');
                else
                    imfo.extra.event.time = fread(opts.fid, 1, 'double');
                end
                
                imfo.extra.event(m).num_type = fread(opts.fid, 1, '*int32');
                
                switch imfo.extra.event(m).num_type
                    case 0 % experimental annotation
                        imfo.extra.event(m).type = 'experimental annotation';
                    case 1 % time interval has changed
                        imfo.extra.event(m).type = 'time interval change';
                    case 2 % start of a bleach operation
                        imfo.extra.event(m).type = 'start of bleach operation';
                    case 3 % end of a bleach operation
                        imfo.extra.event(m).type = 'end of bleach operation';
                    case 4 % a trigger signal was detected on the user port of the electronic module
                        imfo.extra.event(m).type = 'user trigger signal';
                    otherwise
                        ['event ' num2str(imfo.extra.event(m).num_type) 'not supported'];
                end
                
                descriptionsize = fread(opts.fid, 1, '*int32');
                imfo.extra.event(m).description = deblank(strtrim(fread(opts.fid, descriptionsize, '*char')'));
                
            end
            
            
        case 'CZLUT'
            % read the allocated size
            allocated_size = fread(opts.fid, 1, '*int32');
            % read the number of lookup tables
            n_luts = fread(opts.fid, 1, '*int32');
            
            for m = 1 : n_luts
                size = fread(opts.fid, 1, '*int32');
                if isfield(imfo, 'extra') && isfield(imfo.extra, 'lut')
                    imfo.extra.lut(m).id = deblank(strtrim(fread(opts.fid, 80, '*char')'));
                else
                    imfo.extra.lut.id = deblank(strtrim(fread(opts.fid, 80, '*char')'));
                end
                
                n_components = fread(opts.fid, 1, '*int32');
                
                for n = 1 : n_components
                    size = fread(opts.fid, 1, '*int32');
                    if isfield(imfo.extra.lut(m), 'component')
                        imfo.extra.lut(m).component(n).numtype = fread(opts.fid, 1, '*int32');
                    else
                        imfo.extra.lut(m).component.numtype = fread(opts.fid, 1, '*int32');
                    end
                    
                    switch imfo.extra.lut(m).component(n).numtype
                        case -1
                            % all
                            imfo.extra.lut(m).component(n).type = 'rgb';
                        case 0
                            % red
                            imfo.extra.lut(m).component(n).type = 'red';
                        case 1
                            % green
                            imfo.extra.lut(m).component(n).type = 'green';
                        case 2
                            % blue
                            imfo.extra.lut(m).component(n).type = 'blue';
                        otherwise
                            ['component type ' num2str(imfo.extra.lut(m).component(n).numtype) 'not supported'];
                    end
                    
                    n_intensities = fread(opts.fid, 1, '*int32');
                    
                    imfo.extra.lut(m).component(n).intensity = fread(opts.fid, n_intensities , '*int16');
                    
                end
%                 length(imfo.extra.lut(m).component)
%                 if length(imfo.extra.lut(m).component) == 3
                    imfo.extra.lut(m).rgb = [imfo.extra.lut(m).component.intensity];
%                 end
                
            end
            
            
            
            
%             imfo.data.n_luts
%             
%             
%             
% %             attachment.data = decode_jpeg(attachment.data);
%             
        otherwise
            [directory.content_filetype ' not supported yet.']
    end
end

function imdata = decode_jpeg(data)

    jImg = javax.imageio.ImageIO.read(java.io.ByteArrayInputStream(data));
    h = jImg.getHeight;
    w = jImg.getWidth;
    p = reshape(typecast(jImg.getData.getDataStorage, 'uint8'), [3,w,h]);
    imdata = cat(3, ...
        transpose(reshape(p(3,:,:), [w,h])), ...
        transpose(reshape(p(2,:,:), [w,h])), ...
        transpose(reshape(p(1,:,:), [w,h])));

end %% end of function 'decode_jpeg'


%% -------------------------------------------------------------------------------------------------
function [opts, imfo] = parse_iptargs(varargin)
    % parse_iptargs parses the input arguments of the Read_CZI function
    
    opts.imfo_tf          = true;     % logical: true returns the information
    opts.imdata_tf        = true;     % logical: true returns the image data, false returns empty matrix
    opts.filename         =   '';     % character string holding the image filename
    opts.wb_tf            = true;     % logical: true displays a waitbar
    opts.verbose_tf       = true;     % logical : true displays progress text in the command window
    opts.squeeze_tf       = true;     % reduces the number of dimensions by removing singular dimensions
    opts.imfo_set         = false;    % logical: when true, the original imformation structure is 
                                      % supplied by the user.
    opts.dims_selected    = false;    % logical: true when only a selection of a dimension is requested
    opts.frames_selected  = false;    % logical: true when only a subset of frames is requested
    opts.dims = struct('X', [], 'Y', [], 'C', [], 'Z', [], 'T', [], 'R', [], 'S', [], 'I', [], 'B', [], 'M', [], 'H', [], 'V', []);
    opts.frames = [];
    
    
    imfo = struct(); % imfo is an empty structure that will hold the information on the file.
    
    if mod(nargin,2)
        % odd number of input arguments. The first input argument has to be a character string
        % defining the full path of the file, or a structure holding al information on the file.
        if ~ischar(varargin{1}) && ~isempty(varargin{1}) && ~isstruct(varargin{1})
            errorbox('The first input argument of an odd set of input arguments should be a valid character string or a valid information structure.', 'Bad file name or information structure', [mfilename ':BadFilenameOrInfoStruct'])
        elseif ischar(varargin{1})
            % the filename is defined
            opts.filename = varargin{1};
            varargin(1) = [];
        else
            % save the structure as imfo structure.
            imfo = varargin{1};
            
            % make sure that it is a valid structure
            if ~isfield(imfo, 'read_fcn')
                if nargin == 1
                    % not a valid imfo structure. Assume that it is a structure with all input
                    % arguments.
                    
                    % convert structure to cell array as it were individual input arguments.
                    varargin = struct2cellwfieldnames(imfo);
                    imfo = struct();
                    
                else
                    % ambiguous situation. Throw an error.
                    errorbox('The supplied information structure is invalid.', 'Invalid information structure', [mfilename ':InfoStructInvalid'])
                end
            
            else
                opts.imfo_set = true;
                % store the filename
                opts.filename = imfo.file.fullpath;
                % remove the input from the list
                varargin(1) = [];
            end
            
        end
    end
    
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
        
        % parse input arguments
        switch lower(varargin{c})
            case {'frame' 'frames'}
                % the number of frames that need to be loaded
                if ~vector(varargin{c+1})
                    errorbox('The selection of frames should be a vector.', 'Bad frame selection', [mfilename ':BadFrameSelection'])
                elseif opts.dims_selected
                    % the user already selected some dimensions. This cannot be combined with frames
                    errorbox('The selection of frames is not compatible with the selection of dimensions.', 'Frame selection not compatible with dimensions selection', [mfilename ':BadSelection'])
                else
                    opts.frames = varargin{c+1};
                    opts.frames_selected = true;
                    c = c + 1;
                end
            case {'x' 'y' 'c' 'z' 't' 'r' 's' 'i' 'b' 'm' 'h' 'v'}
                % the dimensions that have to be loaded
                if ~isvector(varargin{c+1})
                    errorbox(['The selection of dimension ''' varargin{c} ''' should be a vector.'], 'Bad dimension selection', [mfilename ':BadDimSelection'])
                elseif opts.frames_selected
                    % the user already selected some frames. This cannot be combined with dimensions
                    errorbox('The selection of dimensions is not compatible with the selection of frames.', 'Dimension selection not compatible with frames selection', [mfilename ':BadSelection'])
                else
                    opts.dims.(upper(varargin{c})) = varargin{c+1};
                    opts.dims_selected = true;
                    c = c + 1;
                end
            case 'filename'
                % the name of the file
                if ~ischar(varargin{c+1})
                    errorbox('The file name should be a valid character string.', 'Bad file name', [mfilename ':BadFilename'])
                else
                    opts.filename = varargin{c+1};
                    c = c + 1;
                end
            case {'data' 'image', 'imdata'}
                % return stack of images or or empty matrix
                if ~istforonoff(varargin{c+1})
                    errorbox('The ''image'' option has to be either ''on'' or ''off''.', 'bad image option', [mfilename ':BadImageOption'])
                else
                    opts.imdata_tf = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            case {'info' 'imfo'}
                % return the information of the image or not
                if ~istforonoff(varargin{c+1})
                    errorbox('The ''info'' option has to be either ''on'' or ''off''.', 'bad info option', [mfilename ':BadInfoOption'])
                else
                    opts.imfo_tf = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            case {'wb' 'waitbar'}
                % show a waitbar or not
                if ~istforonoff(varargin{c+1})
                    errorbox('The ''wb'' option has to be either ''on'' or ''off''.', 'bad wb option', [mfilename ':BadWbOption'])
                else
                    opts.wb_tf = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            case {'verbose'}
                % show text or not
                if ~istforonoff(varargin{c+1})
                    errorbox('The ''verbose'' option has to be either ''on'' or ''off''.', 'Bad ''verbose'' option', [mfilename ':BadVerbOption'])
                else
                    opts.verbose_tf = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            case 'squeeze'
                % reduces the number of dimensions by removing all singular dimensions
                if ~istforonoff(varargin{c+1})
                    errorbox('The ''squeeze'' option has to be either ''on'' or ''off''.', 'Bad ''squeeze'' option', [mfilename ':BadSqueezeOption'])
                else
                    opts.squeeze_tf = tforonoff2tf(varargin{c+1});
                    c = c + 1;
                end
            otherwise
                % invalid parameter
                errorbox(['Parameter ''' lower(varargin{c}) ''' is not supported by the routine ' mfilename '.'], 'Invalid optional parameter', [mfilename 'InvalidOptionalIpt']);
        end
    end
    
    % set the byte ordering to Little-endian. This means that the most significant byte is on the
    % last position. (mf stands for machine format) %I am not sure whether this is also valid for
    % Mac.
    opts.mf = 'l';
    
    
    
end % end of subfunction 'parse_iptargs'