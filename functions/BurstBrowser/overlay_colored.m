function [zz,color] = overlay_colored(H)
global UserValues
%%% H is a Nx1 cell array of the individual histograms
%%% white specifies the mode
white = 1-UserValues.BurstBrowser.Display.MultiPlotMode;
num_species = numel(H);
color = zeros(3,1,3);
color(1,1,:) = [0    0.4471    0.7412];
color(2,1,:) = [0.8510    0.3255    0.0980];
color(3,1,:) = [0.4667    0.6745    0.1882];
if num_species == 2
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,:) = zz(:,:,:) + repmat(H{1}/max(max(H{1})),1,1,3).*repmat(color(1,1,:),size(H{1},1),size(H{1},2),1); %%% color1
        zz(:,:,:) = zz(:,:,:) + repmat(H{2}/max(max(H{2})),1,1,3).*repmat(color(2,1,:),size(H{2},1),size(H{2},2),1); %%% color2
    elseif white == 1
        %%% sub
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
    end
elseif num_species == 3
    H{1}(isnan(H{1})) = 0;
    H{2}(isnan(H{2})) = 0;
    H{3}(isnan(H{3})) = 0;
    if white == 0
        zz = zeros(size(H{1},1),size(H{1},2),3);
        zz(:,:,:) = zz(:,:,:) + repmat(H{1}/max(max(H{1})),1,1,3).*repmat(color(1,1,:),size(H{1},1),size(H{1},2),1); %%% color1
        zz(:,:,:) = zz(:,:,:) + repmat(H{2}/max(max(H{2})),1,1,3).*repmat(color(2,1,:),size(H{2},1),size(H{2},2),1); %%% color2
        zz(:,:,:) = zz(:,:,:) + repmat(H{3}/max(max(H{3})),1,1,3).*repmat(color(3,1,:),size(H{3},1),size(H{3},2),1); %%% color3
    elseif white == 1
        zz = ones(size(H{1},1),size(H{1},2),3);
        zz(:,:,1) = zz(:,:,1) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{1}./max(max(H{1})); %%% blue
        zz(:,:,2) = zz(:,:,2) - H{2}./max(max(H{2})); %%% red
        zz(:,:,3) = zz(:,:,3) - H{2}./max(max(H{2})); %%% red
        zz(:,:,1) = zz(:,:,1) - H{3}./max(max(H{3})); %%% green
        zz(:,:,3) = zz(:,:,3) - H{3}./max(max(H{3})); %%% green
    end
else
    return;
end
if white == 0
    beta = UserValues.BurstBrowser.Display.BrightenColorMap;
    if beta > 0
        zz = zz.^(1-beta);
    elseif beta <= 0
        zz = zz.^(1/(1+beta));
    end
end