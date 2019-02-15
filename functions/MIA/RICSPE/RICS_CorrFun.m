function Corr = RICS_CorrFun( DG0, Coeff )
% This function is called by RICS_FitCorr during fitting

  % Extract fit-parameters from arrays
    D    = DG0(1); % diffusion coefficient
    G0   = DG0(2); % center value of correlation function
    Ginf = DG0(3); % offset of correlation function
    Coeff1 = Coeff(:,:,1); 
    Coeff2 = Coeff(:,:,2);
    Coeff3 = Coeff(:,:,3);
    Coeff4 = Coeff(:,:,4);
    
  % Calculate the correlation function
  % Temporal contribution
    CorrTemp = 1./ ( 1 + D.*Coeff2 ) ./ sqrt( 1 + D.*Coeff3 );
  % Spatial contribution
    CorrSpat = exp( Coeff1 ./ ( 1 + D.*Coeff2 ) );
  % Weighted spatial correlation function
    Corr = Coeff4 .* ( G0 .* CorrTemp .* CorrSpat + Ginf );

end