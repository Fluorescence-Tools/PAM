% define the objective function as the kullback leibler divergence
function k = KBL(g,b,D1,D2)
    % D1 and D2 are vectors of the photon counts NGG, NGR, NRR
    % convert to beta and gamma corrected stoichiometries
    S1 = (g*D1(:,1)+D1(:,2))./(g*D1(:,1)+D1(:,2)+b.*D1(:,3));
    S2 = (g*D2(:,1)+D2(:,2))./(g*D2(:,1)+D2(:,2)+b.*D2(:,3));
    % calculate distributions
    P = histcounts(S1,0:0.05:1);
    P = P./sum(P);
    Q = histcounts(S2,0:0.05:1);
    Q = Q./sum(Q);
    % calculate KBL
    k = P.*log(P./Q);
    k(~isfinite(k)) = 0;
    k = abs(sum(k));
end