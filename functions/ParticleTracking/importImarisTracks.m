function [tracks, mask, particles] = importImarisTracks(dataPath, imageSize, spotRadius)
%IMPORTIMARISTRACKS Imports position coordinates from Imaris csv export
%   Input: 
%   dataPath: path to exported file.
%   imageSize: size of the tracked image stack
%   spotRadius: radius of the spot in pixels
%   Output:
%   tracks: struct array containing the track id, frames, and positions for
%   each track.
%   mask: logical matrix with same dimensions as the image stack
%   particles: label matrix with same dimensions as the image stack

%% Import data as table
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames'); % disable warnings regarding variable names
data = readtable(dataPath);
warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');

%% Extrack trackIDs and initialize struct array
trackIDs = cellfun(@(X) regexp(X, 'x\d+', 'match'), data.Properties.VariableNames(2:3:end-1), 'UniformOutput', false);
tracks = cell2struct(trackIDs, {'id'}, 1);

%% Extract and store frame and position information for each track
numTracks = floor((size(data,2)-2)/3);
data = table2array(data(:,1:end-1));
for i = 1:numTracks
    startCol = 3*(i-1)+2;
    currentTrack = [data(:,1) data(:, startCol:startCol+1)];
    currentTrack = currentTrack(all(~isnan(currentTrack), 2), :); % remove frames with NaN values
    tracks(i).Frames = currentTrack(:, 1) + 1; % add 1 as Imaris frames start from 0
    tracks(i).Position = currentTrack(:, 2:end) + 1; % add 1 as Imaris positions start from 0;
end

%% Generate masks
particles = zeros(imageSize);
for i = 1:length(tracks)
    pos = round(tracks(i).Position);
    for j = 1:length(tracks(i).Frames)
        particles(pos(j,2), pos(j,1), tracks(i).Frames(j)) = i;
    end
end
mask = particles > 0;

% dilate masks with disk structuring element
se = strel('disk', spotRadius, 0);
mask = imdilate(mask, se);
particles = imdilate(particles, se);