function [Covariance] = res_covariance( Nlags , NX , NY , D , F , w, alpha , Tp , Tl , PixelSize, m , q , gamma )

Covariance = zeros( (Nlags+1)^2 , (Nlags+1)^2 );

chiv = 0:Nlags;
psiv = 0:Nlags;
nuv = 0:Nlags;
muv = 0:Nlags;

% giD0 = zeros( Nlags + 1 , Nlags + 1  );

for indchi = 1 : ( Nlags + 1 )
    
    chi = chiv( indchi );
    
    for indpsi = 1 : ( Nlags + 1 )
        
        psi = psiv( indpsi );
        
        %         giD0( indchi , indpsi ) = g1( [chi,psi] , D , w, alpha , Tp , Tl , PixelSize ) ./ m;
        
        for indnu = 1 : ( Nlags + 1 )
            
            nu = nuv( indnu );
            
            for indmu = 1 : ( Nlags + 1 )
                
                mu = muv( indmu );
                
                if ( ( norm( [ chi psi ] ) > 0 || norm( [nu mu] ) > 0 ) && indchi + (Nlags+1)*(indpsi-1) <= indnu + (Nlags+1)*(indmu-1) )
                    term1 = 0;
                    
                    if ( nu == chi && mu == psi )
                        term1 = 2*(NX-2*chi)*(NY-2*psi)*( m*q^4*gamma(4)* g3( [chi psi] , [0 0] , [chi psi] , D , w, alpha , Tp , Tl , PixelSize ) );
                    end
                    
                    clear rho
                    clear Coeff
                    x = (1-NX+chi):(NX-chi-1) ;
                    y = (1-NY+psi):(NY-psi-1);
                    
                    [X,Y] = meshgrid(x,y);
                    
                    rho(:,:,1) = X;
                    rho(:,:,2) = Y;
                    
                    Coeff(:,:,1) = - ( ( PixelSize*rho(:,:,1) ).^2 + ( PixelSize*rho(:,:,2) ).^2 ) / w^2;
                    Coeff(:,:,2) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / w^2;
                    Coeff(:,:,3) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / (alpha*w)^2;
                    
                    CorrTemp = 1./ ( 1 + D*Coeff(:,:,2) ) ./ sqrt( 1 + D*Coeff(:,:,3) );
                    CorrSpat = exp( Coeff(:,:,1) ./ ( 1 + D*Coeff(:,:,2) ) );
                    g1tmp = CorrTemp .* CorrSpat;
                    
                    g1v1 = m*q^2*gamma(2) .* g1tmp;
                    g1v1( ceil(numel(y)/2) , ceil(numel(x)/2) ) = g1v1( ceil(numel(y)/2) , ceil(numel(x)/2) ) + m*q*gamma(1);
                    
                    [~, Xtmp] = meshgrid(1:(NX-chi),1:(NX-chi));
                    tmpx = Xtmp-Xtmp';
                    tmpx = tmpx(:);
                    countx = sum(tmpx==unique(tmpx)');
                    [~, Ytmp] = meshgrid(1:(NY-psi),1:(NY-psi));
                    tmpy = Ytmp-Ytmp';
                    tmpy  = tmpy(:);
                    county = sum(tmpy==unique(tmpy)');
                    count = county' * countx;
                    
                    rho(:,:,1) = X + nu - chi;
                    rho(:,:,2) = Y + mu - psi;
                    
                    Coeff(:,:,1) = - ( ( PixelSize*rho(:,:,1) ).^2 + ( PixelSize*rho(:,:,2) ).^2 ) / w^2;
                    Coeff(:,:,2) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / w^2;
                    Coeff(:,:,3) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / (alpha*w)^2;
                    
                    CorrTemp = 1./ ( 1 + D*Coeff(:,:,2) ) ./ sqrt( 1 + D*Coeff(:,:,3) );
                    CorrSpat = exp( Coeff(:,:,1) ./ ( 1 + D*Coeff(:,:,2) ) );
                    g1tmp = CorrTemp .* CorrSpat;
                    
                    g1v2 = m*q^2*gamma(2) .* g1tmp;
                    g1v2( g1v2 == max(g1v2(:)) ) = g1v2( g1v2 == max(g1v2(:)) ) + m*q*gamma(1);
                    
                    temp = count .* ( g1v1 .* g1v2 );
                    
                    term2 = sum( temp(:) );
                    
                    rho(:,:,1) = X + nu;
                    rho(:,:,2) = Y + mu;
                    
                    Coeff(:,:,1) = - ( ( PixelSize*rho(:,:,1) ).^2 + ( PixelSize*rho(:,:,2) ).^2 ) / w^2;
                    Coeff(:,:,2) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / w^2;
                    Coeff(:,:,3) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / (alpha*w)^2;
                    
                    CorrTemp = 1./ ( 1 + D*Coeff(:,:,2) ) ./ sqrt( 1 + D*Coeff(:,:,3) );
                    CorrSpat = exp( Coeff(:,:,1) ./ ( 1 + D*Coeff(:,:,2) ) );
                    g1tmp = CorrTemp .* CorrSpat;
                    
                    g2v1 = m*q^2*gamma(2) .* g1tmp;
                    g2v1( g2v1 == max(g2v1(:)) ) = g2v1( g2v1 == max(g2v1(:)) ) + m*q*gamma(1);
                    
                    rho(:,:,1) = X - chi;
                    rho(:,:,2) = Y - psi;
                    
                    Coeff(:,:,1) = - ( ( PixelSize*rho(:,:,1) ).^2 + ( PixelSize*rho(:,:,2) ).^2 ) / w^2;
                    Coeff(:,:,2) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / w^2;
                    Coeff(:,:,3) = 4 * ( abs(Tp*( rho(:,:,1) ) + Tl*( rho(:,:,2) )) ) / (alpha*w)^2;
                    
                    CorrTemp = 1./ ( 1 + D*Coeff(:,:,2) ) ./ sqrt( 1 + D*Coeff(:,:,3) );
                    CorrSpat = exp( Coeff(:,:,1) ./ ( 1 + D*Coeff(:,:,2) ) );
                    g1tmp = CorrTemp .* CorrSpat;
                    
                    g2v2 =  m*q^2*gamma(2) .* g1tmp;
                    g2v2( g2v2 == max(g2v2(:)) ) = g2v2( g2v2 == max(g2v2(:)) ) + m*q*gamma(1);
                    
                    temp = count .* g2v1 .* g2v2;
                    term3 = sum( temp(:) );
                    
                    Covariance( indchi + (Nlags+1)*(indpsi-1) , indnu + (Nlags+1)*(indmu-1) ) = (term1 + term2 + term3 ) ./ ( (NX-chi)*(NX-nu)*(NY-psi)*(NY-mu) .* F^4 );
                    
                    
                end
                
            end
            
        end
    end
end
Covariance = Covariance + triu(Covariance,1)';