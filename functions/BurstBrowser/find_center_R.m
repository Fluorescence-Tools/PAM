function centerR = find_center_R(E,sigma,R0)
%%% finds the center R of a gaussian distribution of distances that
%%% corresponds to an input average E value
r = 1:1:3*R0;
E_of_R = @(R,sigma) sum(normpdf(r,R,sigma)./(1+(r./R0).^6))./sum(normpdf(r,R,sigma));
div = @(R) (E-E_of_R(R,sigma)).^2;
centerR = fminsearch(div,R0.*(1/E-1)^(1/6));
