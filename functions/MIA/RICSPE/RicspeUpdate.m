function [D_RICSPE, MSRE, NimagesVec] = RicspeUpdate(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set parameters
Nlags = 15;

lb = [0 0 -Inf];
ub = [Inf Inf Inf];
options = optimset( 'LargeScale', 'on', 'Display', 'off');


temporary = get(handles.table, 'data');
data.PixelTime = temporary(:,1) .* 10^(-6);
data.LineTime = temporary(:,2) .* 10^(-3);

data.SimTime = str2double(get(handles.SimTime,'string'));
data.Concentration = str2double(get(handles.Concentration,'string'));
data.PixelSize = str2double(get(handles.PixelSize,'string')) .* 10^(-3);

data.NX = str2double(get(handles.NX,'string'));
data.NY = str2double(get(handles.NY,'string'));

data.NImages = str2double(get(handles.NImages,'string'));
data.Brightness = str2double(get(handles.Brightness,'string')) .* 10^(3);
data.NRep = str2double(get(handles.NRep,'string'));
data.D = str2double(get(handles.D,'string'));
data.wr = str2double(get(handles.wr,'string')) .* 10^(-3);
data.wz = str2double(get(handles.wz,'string')) .* 10^(-3);
data.CovarianceTot = handles.CovarianceTot;
data.NParticles = str2double(handles.NParticles.String);

if (data.SimTime < Inf )
    NimagesVec = min( floor( data.SimTime ./ (data.NY.*data.LineTime) ) , data.NImages );
else
    NimagesVec = data.NImages .* ones(numel(data.LineTime),1);
end

alpha = data.wz / data.wr; %ratio between axial and lateral waist

if alpha == Inf
    V = ( data.NX * data.PixelSize + 2 ) * ( data.NY * data.PixelSize + 2 );
    omega = pi*data.wr^2;
else
    V = ( data.NX * data.PixelSize + 2 ) * ( data.NY * data.PixelSize + 2 ) * ( (data.NX+data.NY)/2 * data.PixelSize );
    omega = pi^(3/2)*data.wr^3*alpha;
end

M = data.NParticles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation using the analytical Covariance of the ACF
D_RICSPE = zeros(numel(data.PixelTime) , data.NRep);
giD0 = zeros( Nlags + 1 , Nlags + 1 , numel(data.PixelTime) );
MSRE = nan(numel(data.PixelTime),1);

for indtp = 1 : numel( data.PixelTime )
    
    Tp = data.PixelTime( indtp );
    Tl = data.LineTime( indtp );
    
    if alpha == Inf
        q = data.Brightness * Tp;
        m = M * omega / V;
    else
        beta = 1/alpha^2;
        tauc = data.wr^2/(4*data.D);
        fact = ( 1 + beta * Tp / tauc ) ^ 0.5;
        q = data.Brightness * 4 * tauc^2 * ( beta * ( 1 + Tp/tauc ) * atanh( (1-beta)^0.5 * ( fact - 1 ) / ( beta + fact - 1 ) ) - (1-beta)^0.5*( fact - 1 )  ) / ( Tp * beta * (1-beta)^0.5 );
        Mapp = M * data.Brightness * Tp / q;
        m = Mapp * omega / V;
    end
    
    if ( Tp*data.NX <= Tl )
        
        [ X, Y ] = meshgrid ( 0 : Nlags, 0 : Nlags );
        Coeff = ones( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
        Coeff(1,1,4) = 0; %we do not fit the (0,0) lag
        acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
        giD0(:,:,indtp) = acfprova;
        
        Covariance = nearestSPD(data.CovarianceTot(2:end,2:end,indtp)) ./ NimagesVec(indtp);
        errors = zeros(Nlags +1, Nlags +1, data.NRep);
        for ind = 1 : data.NRep
            temporary = mvnrnd( zeros(1,(Nlags +1)^2-1), Covariance );
            temporary = [0, temporary];
            errors(:,:,ind) = reshape(temporary,[Nlags+1, Nlags+1]);
        end
        
        Corrprova = giD0(:,:,indtp) + errors;
        ste = reshape( [0 ;sqrt( diag(Covariance) )], [Nlags+1, Nlags+1]  );
        Corrprova = Corrprova ./ste;
        Corrprova(1,1,:) = 0;
        
        [ X, Y ] = meshgrid ( 0 : Nlags, 0 : Nlags );
        
        % Calculate coefficients for RICS_CorrFun
        Coeff = zeros( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
        Coeff(:,:,4) = 1 ./ ste;
        Coeff(1,1,4) = 0; %we do not fit the (0,0) lag
        
        
        Progress(indtp/(numel(data.PixelTime)),handles.Progress_Axes,handles.Progress_Text,['Updating MSRE for Scanspeed ' num2str(indtp) ' of ' num2str(numel(data.PixelTime)) ':']);
        drawnow
        
        for ind = 1 : data.NRep
            
            D_init = [10.*rand(1) 1 0];
            [DG0,~,~,~,~,~,~] = lsqcurvefit( 'RICS_CorrFun', D_init , Coeff, Corrprova(:,:,ind) , lb , ub , options );
            D_RICSPE(indtp,ind) = DG0(1);
            
        end
        
        MSRE(indtp) = mean( ( (D_RICSPE(indtp,:)-data.D)/data.D ).^2 );
        
    end
    
    
end