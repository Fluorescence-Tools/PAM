function AddDerivedParameters(~,~,h)
global BurstData BurstMeta
file = BurstMeta.SelectedFile;

%% Add/Update distance (from intensity), E (from lifetime) and distance (from lifetime) entries
if any(BurstData{file}.BAMethod == [1,2,5]) % 2-color MFD
    % FD/FA FRET indicator
    if ~sum(strcmp(BurstData{file}.NameArray,'log(FD/FA)'))
        BurstData{file}.NameArray{end+1} = 'log(FD/FA)';
        BurstData{file}.DataArray(:,end+1) = NaN;
    end    
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'log(FD/FA)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)'))./BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
    
     % M1-M2, difference between first and second normalized moment of the
     % lifetime distribution
    if ~sum(strcmp(BurstData{file}.NameArray,'M1-M2'))
        BurstData{file}.NameArray{end+1} = 'M1-M2';
        BurstData{file}.DataArray(:,end+1) = NaN;
    end    
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'M1-M2')) = ...
        (1-BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'))).*(1-BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'))./BurstData{file}.Corrections.DonorLifetime);
    
    % No. of Photons (GX) and Countrate (GX)
    if ~sum(strcmp(BurstData{file}.NameArray,'Number of Photons (DX)'))
        BurstData{file}.NameArray{end+1} = 'Number of Photons (DX)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DX)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DD)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'));
    
    if ~sum(strcmp(BurstData{file}.NameArray,'Count rate (DX) [kHz]'))
        BurstData{file}.NameArray{end+1} = 'Count rate (DX) [kHz]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Count rate (DX) [kHz]')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DX)')) ./ BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Duration [ms]'));
         
    % distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    E = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency'));
    E(E<0 | E>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from intensity) [A]')) = ((1./E-1).*R0^6).^(1/6);
    % E (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'FRET efficiency (from lifetime)'))
        BurstData{file}.NameArray{end+1} = 'FRET efficiency (from lifetime)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime D [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (from lifetime)')) = El;
    
    % distance (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance (from lifetime) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance (from lifetime) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
    
    %FRET from sensitized acceptor emission
    if ~sum(strcmp(BurstData{file}.NameArray,'FRET efficiency (sens. Acc. Em.)'))
        BurstData{file}.NameArray{end+1} = 'FRET efficiency (sens. Acc. Em.)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    E_A = BurstData{file}.Corrections.Beta_GR*BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (DA)'))./BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (AA)'));
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency (sens. Acc. Em.)')) = E_A;
elseif any(BurstData{file}.BAMethod == [3,4]) % 3-color MFD
     %No. of Photons (GX) and Countrate (GX)
    if ~sum(strcmp(BurstData{file}.NameArray,'Number of Photons (GX)'))
        BurstData{file}.NameArray{end+1} = 'Number of Photons (GX)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GX)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GG)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GR)'));
    
    if ~sum(strcmp(BurstData{file}.NameArray,'Count rate (GX) [kHz]'))
        BurstData{file}.NameArray{end+1} = 'Count rate (GX) [kHz]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Count rate (GX) [kHz]')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (GX)')) ./ BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Duration [ms]'));
    %No. of Photons (BX) and Countrate (BX)
    if ~sum(strcmp(BurstData{file}.NameArray,'Number of Photons (BX)'))
        BurstData{file}.NameArray{end+1} = 'Number of Photons (BX)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BX)')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BB)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BG)')) + BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BR)'));
    
    if ~sum(strcmp(BurstData{file}.NameArray,'Count rate (BX) [kHz]'))
        BurstData{file}.NameArray{end+1} = 'Count rate (BX) [kHz]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Count rate (BX) [kHz]')) = ...
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Number of Photons (BX)')) ./ BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Duration [ms]'));
    
    % GR distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance GR (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance GR (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end 
    EGR = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency GR'));
    EGR(EGR<0 | EGR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadius;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from intensity) [A]')) = ((1./EGR-1).*R0^6).^(1/6);
    
    % E GR (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'FRET efficiency GR (from lifetime)'))
        BurstData{file}.NameArray{end+1} = 'FRET efficiency GR (from lifetime)';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    tauDA = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Lifetime GG [ns]'));
    tauD = BurstData{file}.Corrections.DonorLifetime;
    El = 1-tauDA./tauD;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET efficiency GR (from lifetime)')) = El;

    % distance GR (from lifetime)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance GR (from lifetime) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance GR (from lifetime) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    El(El<0 | El>1) = NaN;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance GR (from lifetime) [A]')) = ((1./El-1).*R0^6).^(1/6);
    
    % BG distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance BG (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance BG (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    EBG= BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency BG'));
    EBG(EBG<0 | EBG>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBG;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BG (from intensity) [A]')) = ((1./EBG-1).*R0^6).^(1/6);
    % BR distance (from intensity)
    if ~sum(strcmp(BurstData{file}.NameArray,'Distance BR (from intensity) [A]'))
        BurstData{file}.NameArray{end+1} = 'Distance BR (from intensity) [A]';
        BurstData{file}.DataArray(:,end+1) = 0;
    end
    EBR = BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'FRET Efficiency BR'));
    EBR(EBR<0 | EBR>1) = NaN;
    R0 = BurstData{file}.Corrections.FoersterRadiusBR;
    BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Distance BR (from intensity) [A]')) = ((1./EBR-1).*R0^6).^(1/6);
end
if isfield(BurstData{file},'AdditionalParameters')
    %%% Add diffusion time/diffusion coefficient
    if isfield(BurstData{file}.AdditionalParameters,'tauD')
        if ~sum(strcmp(BurstData{file}.NameArray,'Diffusion time [ms]'))
            BurstData{file}.NameArray{end+1} = 'Diffusion time [ms]';
            BurstData{file}.DataArray(:,end+1) = 0;
        end
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Diffusion time [ms]')) = BurstData{file}.AdditionalParameters.tauD./1E-3;
    end
    if isfield(BurstData{file}.AdditionalParameters,'DiffusionCoefficient')
        if ~sum(strcmp(BurstData{file}.NameArray,'Diffusion coefficient [mum2/s]'))
            BurstData{file}.NameArray{end+1} ='Diffusion coefficient [mum2/s]';
            BurstData{file}.DataArray(:,end+1) = 0;
        end
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'Diffusion coefficient [mum2/s]')) = BurstData{file}.AdditionalParameters.DiffusionCoefficient;
    end
    if isfield(BurstData{file}.AdditionalParameters,'BVAStandardDeviation')
        if ~sum(strcmp(BurstData{file}.NameArray,'BVA standard deviation'))
            BurstData{file}.NameArray{end+1} ='BVA standard deviation';
            BurstData{file}.DataArray(:,end+1) = 0;
        end
        BurstData{file}.DataArray(:,strcmp(BurstData{file}.NameArray,'BVA standard deviation')) = BurstData{file}.AdditionalParameters.BVAStandardDeviation;
    end
end