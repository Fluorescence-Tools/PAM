function [Imageseries, Stack, Bin] = CalculateImage(PIE_MT, mode)

global FileInfo
% function that groups everything concerning image calculations from SPC data

% mode = 1 is called for summed up intensity image only
% mode = 2 is called for summed up intensity image with photon-to-pixel
% assignement
% mode = 3 is called for full Stack
Pixel = zeros(FileInfo.Lines,FileInfo.Pixels+1);
Bin=[];
Imageseries = [];
Stack = [];
if ~isfield(FileInfo, 'LineStops') %%% Standard data with just a line/frame start or no markers
    
    Linedurations = diff(FileInfo.LineTimes,1,2);
    %%% Faster and less memory intensive way or creating a summed
    %%% up image when all linetimes are identical
    if mode<3 && (FileInfo.Pixels > 1 && FileInfo.Lines > 1) && (numel(FileInfo.ImageTimes)==2 || max(abs(diff(diff(FileInfo.ImageTimes))))/mean((FileInfo.ImageTimes))<10^9) && (max(abs(diff(Linedurations(:))))/mean(Linedurations(:))<10^6)
        for j=1:FileInfo.Lines
            Pixel(j,:)=linspace(FileInfo.LineTimes(1,j),FileInfo.LineTimes(1,j+1),FileInfo.Pixels+1);
        end
        Pixeltimes = reshape(Pixel(:,1:(end-1))',1,[]);
        Pixeltimes(end+1)=FileInfo.ImageTimes(2);
        PIE_MT = mod(PIE_MT,FileInfo.ImageTimes(2));
        if mode ==2 %%% Phasor. Needs a linear intensity vector and a vector for photon-to-pixel assignement.
            [Imageseries,~,Bin]=histcounts(PIE_MT,Pixeltimes);
            Bin=uint32(Bin); %%% Photon-to-Pixel assignement vector
            Imageseries=reshape(Imageseries,[],1);
        else %%% Does not return i
            [Imageseries,~,~]=histcounts(PIE_MT,Pixeltimes);
            %%% Reshapes pixel vector to image
            Imageseries=flipud(permute(reshape(Imageseries,FileInfo.Pixels,FileInfo.Lines),[2 1]));
        end
        
        
    else %%% Slower than the above, but calculates full stack
        %%% Calculates Pixel vector
        Pixeltimes=[];
        for i=1:(numel(FileInfo.ImageTimes)-1)
            for j=1:FileInfo.Lines
                Pixel(j,:)=linspace(FileInfo.LineTimes(i,j),FileInfo.LineTimes(i,j+1),FileInfo.Pixels+1);
            end
            Pixeltimes = [Pixeltimes, reshape(Pixel(:,1:(end-1))',1,[])]; %#ok<AGROW>
        end
        Pixeltimes(end+1)=FileInfo.MeasurementTime;
        %%% Calculate image vector
        if mode == 2 %%% Summed up image with photon-to-pixel assignement
            [Stack,~,Bin]=histcounts(PIE_MT,Pixeltimes);
            Bin=uint32(Bin); %%% Photon-to-Pixel assignement vector
            Bin = mod(Bin,FileInfo.Pixels*FileInfo.Lines); %%% Collapses to single frame
            %%% Reshapes pixel vector to image
            Stack=reshape(Stack,[],i);
            Imageseries = sum(Stack,2);
        elseif mode == 4 %%% Full stack with photon-to-pixel assignement
            [Stack,~,Bin]=histcounts(PIE_MT,Pixeltimes);
            Bin=uint32(Bin); %%% Photon-to-Pixel assignement vector
            %%% Reshapes pixel vector to image
            Stack=reshape(Stack,[],i);
            Imageseries = sum(Stack,2);
        else %%% Calculates full stack
            [Stack,~,~]=histcounts(PIE_MT,Pixeltimes);
            %%% Reshapes pixel vector to image
            Stack=flipud(permute(reshape(Stack,FileInfo.Pixels,FileInfo.Lines,i),[2 1 3]));
            Imageseries = sum(Stack,3);
        end
    end
    
    
else %%% Image data with additional line/frame stop markers and other more complex setups
    Pixeltimes=[];
    for i=1:(numel(FileInfo.ImageTimes))
        for j=1:FileInfo.Lines
            Pixel(j,:)=linspace(FileInfo.LineTimes(i,j),FileInfo.LineStops(i,j),FileInfo.Pixels+1);
        end
        Pixeltimes = [Pixeltimes, reshape(Pixel',1,[])]; %#ok<AGROW>
    end
    Pixeltimes(end+1)=max([FileInfo.MeasurementTime,Pixeltimes(end)]);
    %%% Calculate image vector
    if mode == 2 %%% Summed up image with photon-to-pixel assignement
        [Stack,~,Bin]=histcounts(PIE_MT,Pixeltimes);
        Bin = mod(Bin,(FileInfo.Pixels+1)*FileInfo.Lines); %%% Collapses to single frame
        Bin(mod(Bin,FileInfo.Pixels+1)==0)=0;
        Bin=Bin-floor(Bin/(FileInfo.Pixels+1));
        Bin=uint32(Bin); %%% Photon-to-Pixel assignement vector
        %%% Reshapes pixel vector to image
        Stack=reshape(Stack,FileInfo.Pixels+1,FileInfo.Lines,i);
        Stack=Stack(1:end-1,:,:);
        Stack=reshape(Stack,[],i);
        Imageseries = sum(Stack,2);
    elseif mode == 4 %%% Full stack with photon-to-pixel assignement
        [Stack,~,Bin]=histcounts(PIE_MT,Pixeltimes);
        Bin(mod(Bin,FileInfo.Pixels+1)==0)=0;
        Bin=Bin-floor(Bin/(FileInfo.Pixels+1));
        Bin=uint32(Bin); %%% Photon-to-Pixel assignement vector
        %%% Reshapes pixel vector to image
        Stack=reshape(Stack,FileInfo.Pixels+1,FileInfo.Lines,i);
        Stack=Stack(1:end-1,:,:);
        Stack=reshape(Stack,[],i);
        Imageseries = sum(Stack,2);
    else %%% Calculates full stack
        [Stack,~,~]=histcounts(PIE_MT,Pixeltimes);
        %%% Reshapes pixel vector to image
        Stack=flipud(permute(reshape(Stack,FileInfo.Pixels+1,FileInfo.Lines,i),[2 1 3]));
        Stack = Stack(:,1:end-1,:);
        Imageseries = sum(Stack,3);
    end
end
            
    

