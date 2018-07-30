function [interpArea, interpPixelIdx, interpPixelPos, interpPixelValue,...
    interpMeanInt, interpMaxInt, interpTotalCounts, interpFrames]...
    = InterpPixel(PixelIdxList, Centroid, ImageStack)
% INTERPPIXEL Interpolate particle pixel indices using interpolated
% centroid positions
%  Inputs:
%    PixelIdxList: vector containing the PixelIdxList of tracked particle
%    Centroid: m-by-2 matrix containing the interpolated x and y
%    coordinates of the tracked particle.
%    ImageStack: the intensity image stack that PixelIdxList refers to.
%  Outputs:
%    Area, PixelIdx, PixelPos, PixelValue, Mean Intensity, MaxIntensity,
%    Total Counts and Frames as vectors or matrices similar to values
%    extracted through REGIONPROPS.

% convert indices to subscript values
stackSize = size(ImageStack);
[c(:,1), c(:,2), c(:,3)] = ind2sub(stackSize, PixelIdxList);

% preallocate variables
interpFrames = (c(1,3):c(end,3))';
nFrames = interpFrames(end) - interpFrames(1) + 1;
interpPixelPos = cell(nFrames, 1);
interpPixelIdx = cell(nFrames, 1);
interpPixelValue = cell(nFrames, 1);
interpArea = zeros(nFrames, 1);
interpMeanInt = zeros(nFrames, 1);
interpMaxInt = zeros(nFrames, 1);

% fill in missing pixel positions using interpolated centroids
for i = 1 : nFrames
    interpPixelPos{i} = c(c(:,3) == interpFrames(i), :);
    if i >= 2 && isempty(interpPixelPos{i})
        interpPixelPos{i} = interpPixelPos{i-1}(:,1:2) + fliplr(Centroid(i,:)-Centroid(i-1,:));
        interpPixelPos{i}(:,3) = interpPixelPos{i-1}(:,3) + 1;
    end
end

% extract information from valid indices
for i = 1:nFrames
    % remove out of range indices
    validPix = all(interpPixelPos{i}(:, 1:2) >= 0.5 & interpPixelPos{i}(:, 1:2) < stackSize(1:2)+0.5, 2);
    interpPixelPos{i} = interpPixelPos{i}(validPix,:);
    
    % calculate interpolated pixel indices
    interpPixelPos{i} = round(interpPixelPos{i});
    interpPixelIdx{i} = sub2ind(stackSize, interpPixelPos{i}(:,1),...
        interpPixelPos{i}(:,2), interpPixelPos{i}(:,3));
    
    % extract pixel values and roi properties
    interpPixelValue{i} = ImageStack(interpPixelIdx{i});
    interpArea(i) = length(interpPixelValue{i});
    interpMeanInt(i) = mean(interpPixelValue{i});
    interpMaxInt(i) = max(interpPixelValue{i});

end

% calculate total counts
interpTotalCounts = interpArea .* interpMeanInt;

% formats output
interpPixelPos = cat(1, interpPixelPos{:});
interpPixelPos = fliplr(interpPixelPos(:, 1:2));
interpPixelIdx = cat(1, interpPixelIdx{:});
interpPixelValue = cat(1, interpPixelValue{:});

