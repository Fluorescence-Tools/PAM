%%% Assign data to variables
global MIAData
%Green = uint8(MIAData.Data{1,1});
%Red = uint8(MIAData.Data{2,1});

%%% Name of Files
G_Name = 'G.tif';
R_Name = 'O.tif';
Tot_Name = 'GO.tif';

%%% Create a gaussian distribution
%dist = makedist('normal','mu',0,'sigma',3);
G_Dist = cumsum(GFP);
G_Dist = (G_Dist-G_Dist(1))/(G_Dist(end)-G_Dist(1));

R_Dist = cumsum(OFP);
R_Dist = (R_Dist-R_Dist(1))/(R_Dist(end)-R_Dist(1));

%%% Size of image
Pixels = 300;
Lines = 300;
Frames = 200;

%%% Spectral parameters
G_Shift = 12.5;
R_Shift = 17.5;
Width = 40;


if ~isempty(Green) && isempty(G)
    tic;
    G = zeros(Pixels,Lines,40,Frames,'uint8');
    for i=1:Pixels
        for j=1:Lines
            for k=1:Frames
                Rand = rand(Green(i,j,k),1);
                if ~isempty(Rand)
                    Spec = sum(bsxfun(@ge,Rand,G_Dist'),2);
                    Spec = uint8(histcounts(Spec,0:40));
                    G(i,j,:,k) = Spec;
                end
            end
        end
       disp(i)
       toc
    end
    tic
    
    
    Tagstruct.ImageLength = size(G,1);
    Tagstruct.ImageWidth = size(G,2);
    Tagstruct.Compression = 5; %1==None; 5==LZW
    Tagstruct.SampleFormat = 1; %UInt
    Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
    Tagstruct.SamplesPerPixel = 1;
    Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    
    TIFF_handle = Tiff(G_Name, 'w');
    TIFF_handle.setTag(Tagstruct);
    
    for i=1:size(G,4)
        for j=1:size(G,3)
            TIFF_handle.write(uint16(squeeze(G(:,:,j,i))));
            if j<size(G,3) || i<size(G,4)
                TIFF_handle.writeDirectory();
                TIFF_handle.setTag(Tagstruct);
            end
        end
    end
    TIFF_handle.close()
    toc
end

if ~isempty(Red)
    tic;
    R = zeros(Pixels,Lines,40,Frames,'uint8');
    for i=1:Pixels
        for j=1:Lines
            for k=1:Frames
                Rand = rand(Red(i,j,k),1);
                if ~isempty(Rand)
                    Spec = sum(bsxfun(@ge,Rand,R_Dist'),2);
                    Spec = uint8(histcounts(Spec,0:40));
                    
                    R(i,j,:,k) = Spec;
                end
            end
        end
        disp(i)
        toc
    end
    toc
    
    tic

    
    Tagstruct.ImageLength = size(R,1);
    Tagstruct.ImageWidth = size(R,2);
    Tagstruct.Compression = 5; %1==None; 5==LZW
    Tagstruct.SampleFormat = 1; %UInt
    Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
    Tagstruct.SamplesPerPixel = 1;
    Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    
    TIFF_handle = Tiff(R_Name, 'w');
    TIFF_handle.setTag(Tagstruct);
    
    for i=1:size(R,4)
        for j=1:size(R,3)
            TIFF_handle.write(uint16(squeeze(R(:,:,j,i))));
            if j<size(R,3) || i<size(R,4)
                TIFF_handle.writeDirectory();
                TIFF_handle.setTag(Tagstruct);
            end
        end
    end
    TIFF_handle.close()
    toc
end

if ~isempty(Green) && ~isempty(Red)
    tic
    Stack = G+R;
    
    Tagstruct.ImageLength = size(Stack,1);
    Tagstruct.ImageWidth = size(Stack,2);
    Tagstruct.Compression = 5; %1==None; 5==LZW
    Tagstruct.SampleFormat = 1; %UInt
    Tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    Tagstruct.BitsPerSample =  16;                        %32= float data, 16= Andor standard sampling
    Tagstruct.SamplesPerPixel = 1;
    Tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    
    TIFF_handle = Tiff(Tot_Name, 'w');
    TIFF_handle.setTag(Tagstruct);
    
    for i=1:size(Stack,4)
        for j=1:size(Stack,3)
            TIFF_handle.write(uint16(squeeze(Stack(:,:,j,i))));
            if j<size(Stack,3) || i<size(Stack,4)
                TIFF_handle.writeDirectory();
                TIFF_handle.setTag(Tagstruct);
            end
        end
    end
    TIFF_handle.close()
    toc
end

