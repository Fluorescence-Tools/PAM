function [MSRE, DRICS,CovarianceTot] = RICSPE( PixelTime , LineTime , PixelSize , NX , NY , Nparticles , D , wr , wz , Brightness , NImages , SimTime, NRep , handles)


if (SimTime < Inf )
    NimagesVec = min( floor( SimTime ./ (NY.*LineTime) ) , NImages );
else
    NimagesVec = NImages .* ones(numel(LineTime));
end

alpha = wz / wr; %ratio between axial and lateral waist

if alpha == Inf
    gamma(1) = 1/2;
    gamma(2) = gamma(1)/2;
    gamma(3) = gamma(1)/3;
    gamma(4) = gamma(1)/4;
    V = ( NX * PixelSize + 2 ) * ( NY * PixelSize + 2 );
    omega = pi*wr^2;
else
    gamma(1) = 1/(2*sqrt(2));
    gamma(2) = gamma(1)/(2*sqrt(2));
    gamma(3) = gamma(1)/(3*sqrt(3));
    gamma(4) = gamma(1)/8;
    V = ( NX * PixelSize + 2 ) * ( NY * PixelSize + 2 ) * ( (NX+NY)/2 * PixelSize );
    omega = pi^(3/2)*wr^3*alpha;
end

M = Nparticles;% * omega / V;
Nlags = 15;

giD0 = zeros( Nlags + 1 , Nlags + 1 , numel(PixelTime) );
CovarianceTot = zeros( (Nlags + 1)^2 , (Nlags + 1)^2 , numel(PixelTime) );
MSRE = nan(numel(PixelTime),1);

Progress(0,handles.Progress_Axes,handles.Progress_Text,['Calculating variance for Scanspeed 1 of ' num2str(numel(PixelTime)) ':']);
drawnow
for indtp = 1 : numel(PixelTime)
    
    Progress(indtp/(2*numel(PixelTime)),handles.Progress_Axes,handles.Progress_Text,['Calculating variance for Scanspeed ' num2str(indtp) ' of ' num2str(numel(PixelTime)) ':']);
    drawnow
    Tp = PixelTime( indtp );
    Tl = LineTime( indtp );
    
    if alpha == Inf
        q = Brightness * Tp;
        m = M * omega / V;
        F = M*q*omega*gamma(1)/V;
    else
        beta = 1/alpha^2;
        tauc = wr^2/(4*D);
        fact = ( 1 + beta * Tp / tauc ) ^ 0.5;
        q = Brightness * 4 * tauc^2 * ( beta * ( 1 + Tp/tauc ) * atanh( (1-beta)^0.5 * ( fact - 1 ) / ( beta + fact - 1 ) ) - (1-beta)^0.5*( fact - 1 )  ) / ( Tp * beta * (1-beta)^0.5 );
        Mapp = M * Brightness * Tp / q;
        m = Mapp * omega / V;
        F = Mapp*q*omega*gamma(1)/V;
    end
    
    if ( Tp*NX <= Tl )
        
        [CovarianceTmp] = res_covariance( Nlags , NX , NY , D , F , wr, alpha , Tp , Tl , PixelSize, m , q , gamma );
        
        CovarianceTot(:,:,indtp) = CovarianceTmp;
        
        [ X, Y ] = meshgrid ( 0 : Nlags, 0 : Nlags );
        Coeff = ones( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( PixelSize*X' ).^2 + ( PixelSize*Y' ).^2 ) / wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / wz^2;
        Coeff(1,1,4) = 0; %we do not fit the (0,0) lag
        acfprova = RICS_CorrFun([D (1/m) 0], Coeff);
        giD0(:,:,indtp) = acfprova;
        
        
    end
end


DRICS = zeros(numel(PixelTime) , NRep);
options = optimset( 'LargeScale', 'on', 'Display', 'off');
for indtp = 1 : numel( PixelTime )
    
    Tp = PixelTime( indtp );
    Tl = LineTime( indtp );
    
    Progress(0.5+indtp/(2*numel(PixelTime)),handles.Progress_Axes,handles.Progress_Text,['Calculating MSRE for Scanspeed ' num2str(indtp) ' of ' num2str(numel(PixelTime)) ':']);
    drawnow
    
    if ( Tp*NX <= Tl )
        
        Covariance = nearestSPD(CovarianceTot(2:end,2:end,indtp)) ./ NimagesVec(indtp);
        errors = zeros(Nlags +1, Nlags +1, NRep);
        for ind = 1 : NRep
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
        Coeff(:,:,1) = - ( ( PixelSize*X' ).^2 + ( PixelSize*Y' ).^2 ) / wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / wz^2;
        Coeff(:,:,4) = 1 ./ ste;
        Coeff(1,1,4) = 0; %we do not fit the (0,0) lag
        
        lb = [0 0 -Inf];
        ub = [Inf Inf Inf];
        
        for ind = 1 : NRep
            
            D_init = [10.*rand(1) 1 0];
            [DG0,~,~,~,~,~,~] = lsqcurvefit( 'RICS_CorrFun', D_init , Coeff, Corrprova(:,:,ind) , lb , ub , options );
            DRICS(indtp,ind) = DG0(1);
            
        end
        
        MSRE(indtp) = mean( ( (DRICS(indtp,:)-D)/D ).^2 );
        
    end
    
    
end
