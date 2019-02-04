function [D_RICSPE, MSRE, NimagesVec] = RicspeResults(fname, SimTime, NImages, plotflag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set parameters
Nlags = 15;
Nrep = 2000;

lb = [0 0 -Inf];
ub = [Inf Inf Inf];
options = optimset( 'LargeScale', 'on', 'Display', 'off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load data
load(fname);

data.PixelTime = data.PixelTime .* 10^(-6);
data.LineTime = data.LineTime .* 10^(-3);
data.PixelSize = data.PixelSize .* 10^(-3);
data.wr = data.wr * 10^(-3);
data.wz = data.wz * 10^(-3);
data.Brightness = data.Brightness * 10^(3);

if (SimTime < Inf )
    NimagesVec = min( floor( SimTime ./ (data.NY.*data.LineTime) ) , NImages );
else
    NimagesVec = NImages .* ones(numel(data.LineTime),1);
end

alpha = data.wz / data.wr; %ratio between axial and lateral waist

if alpha == Inf
    V = ( data.NX * data.PixelSize + 2 ) * ( data.NY * data.PixelSize + 2 );
    omega = pi*data.wr^2;
else
    V = ( data.NX * data.PixelSize + 2 ) * ( data.NY * data.PixelSize + 2 ) * ( (data.NX+data.NY)/2 * data.PixelSize );
    omega = pi^(3/2)*data.wr^3*alpha;
end

if isfield(data,'NParticles')
    M = data.NParticles;
else
    M = data.Concentration;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Simulation using the analytical Covariance of the ACF
D_RICSPE = zeros(numel(data.PixelTime) , Nrep);
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
        errors = zeros(Nlags +1, Nlags +1, Nrep);
        for ind = 1 : Nrep
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
        
        
        for ind = 1 : Nrep
            
            D_init = [10.*rand(1) 1 0];
            [DG0,~,~,~,~,~,~] = lsqcurvefit( 'RICS_CorrFun', D_init , Coeff, Corrprova(:,:,ind) , lb , ub , options );
            D_RICSPE(indtp,ind) = DG0(1);
            
        end
        
        MSRE(indtp) = mean( ( (D_RICSPE(indtp,:)-data.D)/data.D ).^2 );
        
    end
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting section

switch plotflag
    
    case 1
        figure(4)
        hold on
        figure(5)
        hold on
        CM = jet(numel(data.PixelTime));
        
        for indtp = 1 : numel(data.PixelTime)
            
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
            
            Coeff = ones( Nlags+1, Nlags+1, 4 );
            Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
            Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
            Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
            
            
            
            acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
            figure(4)
            h2=plot( 1:Nlags , acfprova( 2:end , 1 ), 'color', CM(indtp,:));
            figure(5)
            h4=plot( 1:Nlags , acfprova( 1 , 2:end ), 'color', CM(indtp,:) );
            
            legendInfo{indtp} = [string(data.PixelTime(indtp)*10^6)];
            
            
        end
        
        m = M * omega / V;
        PSF = RICS_CorrFun([0 (1/m) 0], Coeff);
        figure(4)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        legendInfo{end+1} = ['PSF'];
        ylabel('G(\xi,0)')
        xlabel('lag (number of pixel)')
        legend(legendInfo)
        
        figure(5)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        ylabel('G(0,\psi)')
        xlabel('lag (number of pixel)')
        legend(legendInfo)
        
    case 2
        
        figure(4)
        hold on
        figure(5)
        hold on
        
        [~ , MSRE_minimizer] = min(MSRE);
        
        Tp = data.PixelTime( MSRE_minimizer );
        Tl = data.LineTime( MSRE_minimizer );
        
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
        
        Coeff = ones( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
        
        
        
        acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
        figure(4)
        h2=plot( 1:Nlags , acfprova( 2:end , 1 ), 'color', 'k');
        figure(5)
        h4=plot( 1:Nlags , acfprova( 1 , 2:end ), 'color', 'k' );
        
        legendInfo{1} = [strcat('[',string(data.PixelTime(MSRE_minimizer)*10^6) ,',',string(data.LineTime(MSRE_minimizer)*10^3), ']' , ' (best)')];
        
        
        
        [~ , MSRE_maximizer] = max(MSRE);
        
        Tp = data.PixelTime( MSRE_maximizer );
        Tl = data.LineTime( MSRE_maximizer );
        
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
        
        Coeff = ones( Nlags+1, Nlags+1, 4 );
        Coeff(:,:,1) = - ( ( data.PixelSize*X' ).^2 + ( data.PixelSize*Y' ).^2 ) / data.wr^2;
        Coeff(:,:,2) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wr^2;
        Coeff(:,:,3) = 4 * abs( Tp*X'  + Tl*Y' ) / data.wz^2;
        
        
        
        acfprova = RICS_CorrFun([data.D (1/m) 0], Coeff);
        figure(4)
        h2=plot( 1:Nlags , acfprova( 2:end , 1 ), 'color', 'b');
        figure(5)
        h4=plot( 1:Nlags , acfprova( 1 , 2:end ), 'color', 'b' );
        
        legendInfo{2} = [strcat('[',string(data.PixelTime(MSRE_maximizer)*10^6) ,',',string(data.LineTime(MSRE_maximizer)*10^3), ']' , ' (worst)')];
        
        m = M * omega / V;
        PSF = RICS_CorrFun([0 (1/m) 0], Coeff);
        figure(4)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        legendInfo{end+1} = ['PSF'];
        ylabel('G(\xi,0)')
        xlabel('lag (number of pixel)')
        hleg=legend(legendInfo);
        title(hleg,'[\tau_p,\tau_l]')
        
        figure(5)
        h5=plot( 1:Nlags , PSF( 1 , 2:end ) , 'm');
        ylabel('G(0,\psi)')
        xlabel('lag (number of pixel)')
        hleg=legend(legendInfo);
        title(hleg,'[\tau_p,\tau_l]')
        
        
end
