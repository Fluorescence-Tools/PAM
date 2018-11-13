function PofT = calc_dynamic_distribution(dT,N,k1,k2)
%%% Calculates probability distribution of dynamic mixing of states for
%%% two-state kinetic scheme
%%% Inputs:
%%% dT  -   Bin time
%%% N   -   Number of time steps to compute
%%% k1  -   Rate from state 1 to state 2
%%% k2  -   Rate from state 2 to state 1

% Split in N+1 time bins
PofT = zeros(1,N+1);
dt = dT/N;

%%% catch special case where k1 = k2 = 0
if (k1 == 0) && (k2 == 0)
    %%% No dynamics, i.e. equal weights
    PofT(1) = 0.5;
    PofT(end) = 0.5;
    return;
end
%%% first and last bin are special cases
PofT(1) = k1/(k1+k2)*exp(-k2*dT) + calcPofT(k1,k2,dt/2,dT-dt/2,dt/2);
PofT(end) = k2/(k1+k2)*exp(-k1*dT) + calcPofT(k1,k2,dT-dt/2,dt/2,dt/2);

%%% rest is determined by formula (2d) in paper giving P(i*dt-dt/2 < T < i*dt+dt/2)
for i = 1:N-1
    T1 = i*dt;
    T2 = dT-T1;
    PofT(i+1) = calcPofT(k1,k2,T1,T2,dt); 
end
PofT = PofT./sum(PofT);


function PofT = calcPofT(k1,k2,T1,T2,dt)
%%% calculates probability for cumulative time spent in state 1(T1) to lie
%%% in range T1-dt, T1+dt based on formula from Seidel paper
%%% besseli is the MODIFIED bessel function of first kind
PofT = (...
       (2*k1*k2/(k1+k2))*besseli(0,2*sqrt(k1*k2*T1*T2)) + ...
       ((k2*T1+k1*T2)/(k1+k2))*(sqrt(k1*k2)/sqrt(T1*T2))*...
       besseli(1,2*sqrt(k1*k2*T1*T2)) ...
       ) * exp(-k1*T1-k2*T2)*dt;