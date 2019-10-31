function [lib_b, lib_t] = binomial_coefficient_library(f_bb,f_bg,f_br,f_gg,f_gr,bg_bb,bg_bg,bg_br,bg_gg,bg_gr)
%%% This functions computes a library of binomial and trinomial 
%%% coefficients for all combinations of background and fluorescence photon
%%% counts.
%%%
%%% Input:
%%% counts  -   Nx5 array of photon counts (BB,BG,BR,GG,GR) for all bursts
%%% bg      -   1x5 array of maximum background counts to consider
%%%
%%% Output:
%%% lib_b   -   Nx[(bg_gg+1)*(bg_gr+1)] array of binomial coefficients
%%% lib_t   -   Nx[(bg_bb+1)*(bg_bg+1)*(bg_br+1)] array of trinomial coefficients
%%%

B = numel(f_bb); %number of bursts

%%% loop over all possible combintations
max_b = (bg_gg+1)*(bg_gr+1);
lib_b = zeros(B*max_b,1);
for b = 1:B
    for i = 0:min([f_gg(b) bg_gg])
        for j = 0:min([f_gr(b) bg_gr])
            lib_b((b-1)*max_b+i*(bg_gr+1)+(j+1)) = noverk(f_gg(b)+f_gr(b)-i-j,f_gr(b)-j);
        end
    end
end
max_t = (bg_bb+1)*(bg_bg+1)*(bg_br+1);
lib_t = zeros(B*max_t,1);
for b = 1:B
    for i = 0:min([f_bb(b) bg_bb])
        for j = 0:min([f_bg(b) bg_bg])
            for k = 0:min([f_br(b) bg_br])
                lib_t((b-1)*max_t+i*(bg_bg+1)*(bg_br+1)+j*(bg_br+1)+(k+1)) = tricoef(f_bb(b) - i, f_bg(b)- j, f_br(b) - k);
            end
        end
    end
end

function res = noverk(n,k)
%%% use gammaln to compute log(n!)
res = gammaln(n+1)-gammaln(k+1)-gammaln(n-k+1);

function res = tricoef(k1,k2,k3)
res = gammaln(k1+k2+k3+1)-gammaln(k1+1)-gammaln(k2+1)-gammaln(k3+1);