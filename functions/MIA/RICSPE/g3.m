function g3 = g3( rho1 , rho2 , rho3 , D , w, alpha , Tp , Tl , S )

rho1 = rho1 .* S;

rho2 = rho2 .* S;

rho3 = rho3 .* S;

tau1 = abs( rho1(1).*Tp + rho1(2).*Tl );

tau2 = abs( rho2(1).*Tp + rho2(2).*Tl );

tau3 = abs( rho3(1).*Tp + rho3(2).*Tl );


term1 = ( 1 + 4.*D.*tau1./w^2 );

term2 = ( 1 + 4.*D.*tau2./w^2 );

term3 = ( 1 + 4.*D.*tau3./w^2 );

term4 = ( 1 + 4.*D.*tau1./(alpha.*w)^2 );

term5 = ( 1 + 4.*D.*tau2./(alpha.*w)^2 );

term6 = ( 1 + 4.*D.*tau3./(alpha.*w)^2 );

term7 = 8 .* term1 .* term2 .* term3 - 8.* D .* (tau1 + tau3) ./ w^2 - 4;

term8 = 8 .* term4 .* term5 .* term6 - 8.* D .* (tau1 + tau3) ./ (alpha.*w)^2 - 4;

term9 = w^2 / 4 + 2*D*tau1;

term10 = w^2 / 4 + 2*D*tau2;

term11 = w^2 / 4 + 2*D*tau3;

term12 = w^2 / 2 + 2*D*tau3;

expterm1 = exp( -0.5 .* norm( rho2 - rho3 , 2 ).^2 ./ term12 );

term13 = rho1 .*  term12 - rho3 .* w.^2./4 + rho2 .* term10; 

term14 = term12 .* ( term10 .* term12 + w^2/4 .* term11 );

expterm2 = exp( -0.5 .* norm( term13 , 2 ).^2 ./ term14 );

term15 = rho1 .* ( w^2/4 .*term11 + 2*D*tau2 .*term12 ) + rho3 .* w^4/16 + rho2 .* term11;

term16 = term9 .* ( term10 .* term12 + w^2/4 .* term11 );

term17 = term16 .* w^6 / 64 .* term7;

expterm3 = exp( -0.5 .* norm( term15 , 2 ).^2 ./ term17 );

g3 = 8 .* expterm1 .* expterm2 .* expterm3 .* term7 .^( -1 ) .* term8 .^ ( -0.5 );