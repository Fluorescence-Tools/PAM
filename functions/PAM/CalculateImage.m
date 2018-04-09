function [Image,Bin] = CalculateImage(PIE_MT, mode)

global FileInfo
% function that groups everything concerning image calculations from SPC data

% mode = 1 is called for summed up intensity image only
% mode = 2 is called for summed up intensity image with photon-to-pixel (for phasor) assignement
% mode = 3 is called for full Image
% mode = 4 is called for full Image with photon-to-pixel (for phasor) assignement

Pixel = zeros(FileInfo.Lines,FileInfo.Pixels+1);
Bin=[];
Image = [];
if ~isfield(FileInfo, 'LineStops') %%% Standard data with just a line/frame start or no markers
    
        Pixeltimes=[];
        for i=1:(numel(FileInfo.ImageTimes)-1)
            for j=1:FileInfo.Lines
                Pixel(j,:)=linspace(FileInfo.LineTimes(i,j),FileInfo.LineTimes(i,j+1),FileInfo.Pixels+1);
            end
            Pixeltimes = [Pixeltimes, reshape(Pixel(:,1:(end-1))',1,[])]; %#ok<AGROW>
        end
        Pixeltimes(end+1)=FileInfo.MeasurementTime;
        
        switch mode
            case 1 %%% Summed up image              
                [Image, ~] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(FileInfo.Lines*FileInfo.Pixels));
                Image = flipud(permute(reshape(Image,FileInfo.Pixels,FileInfo.Lines),[2 1]));
            case 2 %%% Summed up image vector with photon-to-pixel assignement
                [Image, Bin] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(FileInfo.Lines*FileInfo.Pixels));                
            case 3 %%% Full image
                [Image, Bin] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(0));
                Image = flipud(permute(reshape(Image,FileInfo.Pixels,FileInfo.Lines,[]),[2 1 3]));
            case 4 %%% Full image vector with photon-to-pixel assignement
                [Image, Bin] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(0));
        end    
    
else %%% Image data with additional line/frame stop markers and other more complex setups
    Pixeltimes=[];
    for i=1:(numel(FileInfo.ImageTimes)-1)
        for j=1:FileInfo.Lines
            Pixel(j,:)=linspace(FileInfo.LineTimes(i,j),FileInfo.LineStops(i,j),FileInfo.Pixels+1);
        end
        Pixeltimes = [Pixeltimes, reshape(Pixel',1,[])]; %#ok<AGROW>
    end
    Pixeltimes(end+1)=max([FileInfo.MeasurementTime,Pixeltimes(end)]);
    switch mode
        case 1 %%% Summed up image
            [Image, ~] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(FileInfo.Lines*(FileInfo.Pixels+1)));
            Image = flipud(permute(reshape(Image,FileInfo.Pixels+1,FileInfo.Lines),[2 1]));
            Image = Image(:,1:end-1);
        case 2 %%% Summed up image vector with photon-to-pixel assignement
            [Image, Bin] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(FileInfo.Lines*(FileInfo.Pixels+1)));
            Bin(mod(Bin,FileInfo.Pixels+1)==0)=0;
            Bin=double(Bin)-floor(double(Bin)/(FileInfo.Pixels+1));
            Bin=int64(Bin);
            
            Image(mod(1:numel(Image),FileInfo.Pixels+1)==0)=[];
            %%% Reshapes pixel vector to image
            %Image = flipud(permute(reshape(Image,FileInfo.Pixels+1,FileInfo.Lines),[2 1]));
            %Image = Image(:,1:end-1);
        case 3 %%% Full image
            [Image, ~] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(0));
            Image = flipud(permute(reshape(Image,FileInfo.Pixels+1,FileInfo.Lines,[]),[2 1 3]));
            Image = Image(:,1:(end-1),:);    
        case 4 %%% Full image vector with photon-to-pixel assignement
            [Image, Bin] = ImageCalc(PIE_MT, int64(numel(PIE_MT)), Pixeltimes, uint32(numel(Pixeltimes)-1), uint32(0));
            Bin(mod(Bin,FileInfo.Pixels+1)==0)=0;
            Bin=double(Bin)-floor(double(Bin)/(FileInfo.Pixels+1));
            Bin=int64(Bin); %%% Photon-to-Pixel assignement vector
            %%% Reshapes pixel vector to image
            Image=reshape(Image,FileInfo.Pixels+1,FileInfo.Lines,i);
            Image=Image(1:end-1,:,:);
            Image = Image(:);
            %Image=reshape(Image,[],i);
    end
end
            
    

