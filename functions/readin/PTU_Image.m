function [imageseries, Stack, Bins, PIE_MT] = PTU_Image(PIE_MT, mode)
% Function that generates the image for PTU data containing framestarts, linestarts and linestops
% Called in Pam (Update_Data and Phasor_Calc) and in Mia

global FileInfo 

%Macrotimes of the line starts and line stop
LStart = FileInfo.LineStart*FileInfo.ClockPeriod;
LStop = FileInfo.LineStop*FileInfo.ClockPeriod;

% Imaging bits might have a delay with respect to the actual galvo mirror
% movement
delay = 1200/10^6; %seconds
LStart = LStart+delay;
LStop = LStop+delay;

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
for i = 1:size(LStop,1)
    Stack((1 + npix*(i-1)):(i*npix)) = Stack1((i+npix*(i-1)):(i*npix + (i-1)));
end

%Reshape data into a line*pix*frame 3D matrix
imageseries  = reshape(Stack,FileInfo.Lines,npix,FileInfo.NoF);
if isfield(FileInfo, 'bidir')
    if FileInfo.bidir %if bidirectional, flip each other line
        for a = 1:size(imageseries,3)
            for b = 1:2:size(imageseries,1)
                imageseries(b,:,a) = fliplr(imageseries(b,:,a));
            end
        end
    end
end

if mode == 2 % for the phasor analysis, returns the microtime vector
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
    
    PIE_MT(big) = [];
    PIE_MT(small) = [];
    
end
end