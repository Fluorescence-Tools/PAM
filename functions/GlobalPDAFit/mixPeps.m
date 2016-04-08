function PE = mixPeps(eps,PE1,PE2,PofT)
PE = zeros(numel(eps),numel(PofT));
for k = 1:numel(PofT)
    p1 = (k-1)/(numel(PofT)-1);
    for i = 1:numel(eps)
        for j = 1:numel(eps)
            % add weighted prob value at mean distance
            meanEps = p1*eps(i) + (1-p1)*eps(j);
            ix = find(diff(eps <= meanEps) == -1);
            PE(ix,k) = PE(ix,k) + PE1(i)*PE2(j);
        end
    end
end
PE = PE./repmat(sum(PE,1),numel(eps),1);
