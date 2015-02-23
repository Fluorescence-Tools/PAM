function P = eval_prob_3c_bg_C(fbb,fbg,fbr,fgg,fgr,NBbb,NBbg,NBbr,NBgg,NBgr,BGbb,BGbg,BGbr,BGgg,BGgr,p_bb,p_bg,p_gr)
%%% evaluates the probability after blue excitation and after green
p_br = 1 - p_bb - p_bg;
P_binomial = zeros(numel(fbb),1);
P_trinomial = zeros(numel(fbb),1);

for k = 1:numel(fbb) %%% loop over burst
    %%% Evaluate trinomial
    for bg_bb = 0:min([fbb(k) NBbb])
        for bg_bg = 0:min([fbg(k) NBbg])
            for bg_br = 0:min([fbr(k) NBbr])
                %%% Subtract Background counts for FRET evaluation
                P_trinomial(k) = P_trinomial(k) + ... %%% cumulative sum
                BGbb(bg_bb+1)*BGbg(bg_bg+1)*BGbr(bg_br+1)*... %%% Background (+1 since also zero is included)
                mnpdf([(fbb(k)-bg_bb),(fbg(k)-bg_bg),(fbr(k)-bg_br)],[p_bb,p_bg,p_br]);
            end
        end
    end
    %%% Evaluate binomial
    for bg_gg = 0:min([fgg(k) NBgg])
        for bg_gr = 0:min([fgr(k) NBgr])
            %%% Subtract Background counts for FRET evaluation
            P_binomial(k) = P_binomial(k) + ... %%% cumulative sum
                BGgg(bg_gg+1)*BGgr(bg_gr+1)*... %%% Background (+1 since also zero is included)
                binopdf( (fgr(k)-bg_gr) ,(fgr(k) - bg_gr +fgg(k) - bg_gg),p_gr);
        end
    end
end

%%% multiply
P = P_binomial.*P_trinomial;