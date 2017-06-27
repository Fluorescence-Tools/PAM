function P = likelihood_library(fbb,fbg,fbr,fgg,fgr,NBbb,NBbg,NBbr,NBgg,NBgr,BGbb,BGbg,BGbr,BGgg,BGgr,p_bb,p_bg,p_gr,lib_b,lib_t)
%%% evaluates the probability after blue excitation and after green
p_br = 1 - p_bb - p_bg;
P_binomial = zeros(numel(fbb),1);
P_trinomial = zeros(numel(fbb),1);
max_t = (NBbb+1)*(NBbg+1)*(NBbr+1);
max_b = (NBgg+1)*(NBgr+1);
for k = 1:numel(fbb) %%% loop over burst
    %%% Evaluate trinomial
    for bg_bb = 0:min([fbb(k) NBbb])
        for bg_bg = 0:min([fbg(k) NBbg])
            for bg_br = 0:min([fbr(k) NBbr])
                %%% Subtract Background counts for FRET evaluation
                P_trinomial(k) = P_trinomial(k) + ... %%% cumulative sum
                BGbb(bg_bb+1)*BGbg(bg_bg+1)*BGbr(bg_br+1)*... %%% Background (+1 since also zero is included)
                exp(lib_t((k-1)*max_t+(NBbg+1)*(NBbr+1)*bg_bb+(NBbr+1)*bg_bg+(bg_br+1))+...
                log(p_bb)*(fbb(k)-bg_bb)+log(p_bg)*(fbg(k)-bg_bg)+log(p_br)*(fbr(k)-bg_br));
                %mnpdf([(fbb(k)-bg_bb),(fbg(k)-bg_bg),(fbg(k)-bg_bg)],[p_bb,p_bg,p_br]);
            end
        end
    end
    %%% Evaluate binomial
    for bg_gg = 0:min([fgg(k) NBgg])
        for bg_gr = 0:min([fgr(k) NBgr])
            %%% Subtract Background counts for FRET evaluation
            P_binomial(k) = P_binomial(k) + ... %%% cumulative sum
                BGgg(bg_gg+1)*BGgr(bg_gr+1)*... %%% Background (+1 since also zero is included)
                exp(lib_b((k-1)*max_b+(NBgr+1)*bg_gg+(bg_gr+1))+log(p_gr)*(fgr(k)-bg_gr)+log(1-p_gr)*(fgg(k) - bg_gg));
                %binopdf( (fgr(k)-bg_gr) ,(fgr(k) - bg_gr +fgg(k) - bg_gg),p_gr);
        end
    end
end

%%% multiply
P = P_binomial.*P_trinomial;