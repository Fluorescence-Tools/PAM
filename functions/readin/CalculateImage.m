function [imageseries, Stack, Bins, Photons] = CalculateImage(PIE_MT, mode)
global FileInfo UserValues

% function that groups everything concerning image calculations from SPC data

% mode = 1 is called from Pam
% mode = 2 is called from Phasor_Calc in Pam (most of it is still in the phasor function, this needs a clean-up)
% mode = 3 is called from Mia

% function discerns 'HydraHarp' from 'SPC' from 'FabsurfSPC' files
% function discerns point measurements (do nothing) from imaging (calculate images)

imageseries = [];
Stack = [];
Bins = [];
Photons = [];

switch FileInfo.FileType
    case 'HydraHarp'
        if isfield(FileInfo, 'LineStart')
            % It's an imaging file
            
            % e.g. Leuven PTU data, image does not contain the laser retractions
            
            % Function that generates the image for PTU data containing framestarts, linestarts and linestops
            % Called in Pam (Update_Data and Phasor_Calc) and in Mia
            
            % FileInfo.FrameStart is not used here at the moment, since there was no
            % need for it.
            
            
            % Imaging bits might have a delay with respect to the actual galvo mirror
            % movement
            delay = 1.2*10^(-3); %seconds
            
            %Macrotimes of the line starts and line stop
            LStart = FileInfo.LineStart*FileInfo.ClockPeriod + delay;
            LStop = FileInfo.LineStop*FileInfo.ClockPeriod + delay;
            
            % Join the macrotimes of the line starts and line stops
            Bins = union(LStop,LStart);
            
            %assuming squared images
            npix = FileInfo.Lines;
            
            %calculate the pixel start macrotimes
            PStart = zeros(size(LStop,1)*npix,1);
            for a = 1:size(LStop,1)
                pixtime = (LStop(a)-LStart(a))/npix;
                PStart((a-1)*npix+1:a*npix) = linspace(LStart(a),LStop(a)-pixtime,npix);
            end
            
            %Create a bin vector and sort macrotimes per bin
            Bins = union(Bins, PStart);
            Stack1 = single(histc(PIE_MT,Bins));
            
            %Create a vector of size lines*pixel*frame
            Stack = zeros(FileInfo.Lines*npix*FileInfo.NoF,1);
            
            %Remove interline data (so between line stop and next line start)
            for i = 1:FileInfo.Lines*FileInfo.NoF
                Stack((1 + npix*(i-1)):(i*npix)) = Stack1((i+npix*(i-1)):(i*npix + (i-1)));
            end
            
            %Reshape data into a line*pix*frame 3D matrix
            imageseries  = reshape(Stack,FileInfo.Lines,npix,FileInfo.NoF);
            if isfield(FileInfo, 'bidir')
                if FileInfo.bidir %if bidirectional, flip each other line
                    for i = 1:size(imageseries,3)
                        for j = 1:2:size(imageseries,1)
                            imageseries(j,:,i) = fliplr(imageseries(j,:,i));
                        end
                    end
                end
            end
            
            %Flip the image lr
            for i = 1:size(imageseries,3)
                imageseries(:,:,i) = fliplr(imageseries(:,:,i));
            end
            
            switch mode
                case 1 %Pam wants the summed image
                    imageseries = permute(sum(imageseries,3),[2 1 3]);
                case 2 % Phasor
                    clear Bins;
                    
                    %Macrotimes of the first frame line start and line stop
                    LStart = LStart(1:FileInfo.Lines);
                    LStop = LStop(1:FileInfo.Lines);
                    
                    % Join the macrotimes of the line starts and line stops
                    Bins = union(LStop,LStart);
                    
                    %calculate the pixel start macrotimes
                    PStart = zeros(size(LStop,1)*npix,1);
                    for a = 1:size(LStop,1)
                        pixtime = (LStop(a)-LStart(a))/npix;
                        PStart((a-1)*npix+1:a*npix) = linspace(LStart(a),LStop(a)-pixtime,npix);
                    end
                    
                    %Create a bin vector and sort macrotimes per bin
                    Bins = union(Bins, PStart);
                    
                    small = (PIE_MT<LStart(1));
                    big = (PIE_MT > FileInfo.LineStop(end)*FileInfo.ClockPeriod);
                    Photons = PIE_MT;
                    Photons(big) = [];
                    Photons(small) = [];
                    
                case 3 % Mia, output the actual series
                    imageseries = flip(permute(imageseries,[2 1 3]),1);
            end
        end
    case 'SPC'
        if isfield(FileInfo, 'LineStart')
            % It's a B&H FIFO imaging file
            
            % e.g. Hasselt FIFO imaging data
            
            %pixstart = FileInfo.PixelStart;
            linestart = FileInfo.LineStart; %in seconds
            framestart = FileInfo.FrameStart; %in seconds
            linetime = FileInfo.LineTime; %in seconds
            %pixdwell = FileInfo.PixDwellTime;
            pixx = FileInfo.PixelsX;
            pixy = FileInfo.PixelsY;
            imagetime = FileInfo.ImageTime; %in seconds
            frames = FileInfo.NoF;
            
            imageseries = zeros(pixx, pixy, frames);
            
            x = 1; % the pixel
            y = 1; % the line
            m = 1; % the line marker index
            z = 1; % the frame
            i = 1; % line start
            j = 1; % next line start
            %h = waitbar(0,'Converting photons to image series');
            
            while i < (numel(PIE_MT)+1)
                while z < (frames+1)
                    while (PIE_MT(i) < framestart(z))
                        i = i + 1; %photon is before the framestart, go to next photon
                        if i > numel(PIE_MT)
                            break, end
                    end
                    while (PIE_MT(i) < linestart(m))
                        i = i + 1; %photon is before the linestart, go to next photon
                        if i > numel(PIE_MT)
                            break, end
                    end
                    j = i;
                    while (PIE_MT(j) < linestart(m)+linetime)
                        j = j + 1; %photon is before the next linestart
                        if j > numel(PIE_MT)
                            break, end
                    end
                    j = j - 1;
                    line = PIE_MT(i:j); %all photons of a line
                    pixtime = linetime/pixx;
                    pixstart = linestart(m):pixtime:(linestart(m)+linetime); %pixstart is the end time of the pixel
                    k = 1;
                    x = 1;
                    while x < (pixx + 1)
                        if ~isempty(line)
                            while (line(k) < pixstart(x))
                                imageseries(x,y,z) = imageseries(x,y,z) + 1;
                                k = k + 1;
                                if k > numel(line)
                                    break, end
                            end
                            if k > numel(line)
                                break, end
                            x = x + 1;
                            if x > numel(pixstart)
                                break, end
                        else
                            break
                        end
                    end
                    m = m + 1;
                    if m > numel(linestart)
                        break, end
                    y = y + 1;
                    if (linestart(m) > (framestart(z)+imagetime)) || (y > pixy)
                        % next line is the next frame, restart y counter
                        y = 1;
                        %waitbar((z-1)/frames, h, ['Converting frame ' num2str(z) ' of ' num2str(frames) ' frames'])
                        z = z + 1;
                    end
                end
                i = i + 1;
                if m > numel(linestart)
                    break, end
            end
            %close(h);
            
            % crop the image series to the part that contains the data
            imageseries = imageseries(43:pixy+42,:,:);
            
            switch mode
                case 1 %Pam wants the summed image
                    imageseries = permute(sum(imageseries,3),[2 1 3]);
                case 2 % Phasor
                    clear Bins;
                    
                    %Macrotimes of the first frame line start and line stop
                    LStart = LStart(1:FileInfo.Lines);
                    LStop = LStop(1:FileInfo.Lines);
                    
                    % Join the macrotimes of the line starts and line stops
                    Bins = union(LStop,LStart);
                    
                    %calculate the pixel start macrotimes
                    PStart = zeros(size(LStop,1)*npix,1);
                    for a = 1:size(LStop,1)
                        pixtime = (LStop(a)-LStart(a))/npix;
                        PStart((a-1)*npix+1:a*npix) = linspace(LStart(a),LStop(a)-pixtime,npix);
                    end
                    
                    %Create a bin vector and sort macrotimes per bin
                    Bins = union(Bins, PStart);
                    
                    small = (PIE_MT<LStart(1));
                    big = (PIE_MT > FileInfo.LineStop(end)*FileInfo.ClockPeriod);
                    Photons = PIE_MT;
                    Photons(big) = [];
                    Photons(small) = [];
                case 3 % Mia, output the actual series
                    imageseries = flip(permute(imageseries,[2 1 3]),1);
            end
        end
    case 'FabsurfSPC'
        % It's an imaging file
        % Munich Fabsurf, image will contain the laser retractions
        switch mode
            case 1 %Pam - summed image
                %%% Goes back from total microtime to file microtime
                PIE_MT=mod(PIE_MT,FileInfo.ImageTime);
                %%% Calculates Pixel vector
                Pixeltimes=0;
                for j=1:FileInfo.Lines
                    Pixeltimes(end:(end+FileInfo.Lines))=linspace(FileInfo.LineTimes(j),FileInfo.LineTimes(j+1),FileInfo.Lines+1);
                end
                Pixeltimes(end)=[];
                %%% Calculate image vector
                imageseries=histc(PIE_MT,Pixeltimes*FileInfo.ClockPeriod);
                %%% Reshapes pixel vector to image
                imageseries=flipud(reshape(imageseries,FileInfo.Lines,FileInfo.Lines)');
            case 2 % Phasor
                
            case 3 % Mia
                %%% Gets the photons
                if UserValues.PIE.Detector(Sel)~=0 %%% Normal PIE channel
                    Stack=PIE_MT;
                else
                    Stack = [];
                    for j = UserValues.PIE.Combined{Sel} %%% Combined channel
                        Stack = [Stack; PIE_MT]; %#ok<AGROW>
                    end
                end
                
                %%% Calculates pixel times for each line and file
                %%Pixeltimes=zeros(FileInfo(1).Lines^2,FileInfo(1).NumberOfFiles);
                NoF = floor(FileInfo(1).MeasurementTime/FileInfo(1).ImageTime);
                Pixeltimes=zeros(FileInfo(1).Lines^2,NoF);
                for j=1:NoF
                    for k=1:FileInfo.Lines
                        Pixel=linspace(FileInfo.LineTimes(k,j),FileInfo.LineTimes(k+1,j),FileInfo.Lines+1);
                        Pixeltimes(((k-1)*FileInfo.Lines+1):(k*FileInfo.Lines),j)=Pixel(1:end-1);
                    end
                end
                
                %%% Histograms photons to pixels
                Stack = single(histc(Stack,Pixeltimes(:)));
                %%% In case no photons exist
                if numel(Stack)==0
                    Stack = zeros(size(Stack,1),1);
                end
                %%% Reshapes pixelvector to a pixel x pixel x frames matrix
                imageseries = flip(permute(reshape(Stack,FileInfo.Lines,FileInfo.Lines,NoF),[2 1 3]),1);
                clear Stack;
        end
end
end

