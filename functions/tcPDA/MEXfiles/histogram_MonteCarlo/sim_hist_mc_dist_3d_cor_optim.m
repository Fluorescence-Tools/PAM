function [ PrBG, PrBR, PrGR ] = sim_hist_mc_dist_3d_cor_optim(MU,COV,total_rolls,R0_bg,R0_br,R0_gr,cr_bg,cr_br,cr_gr,pe_b,de_bg,de_br,de_gr,mBG_bb,mBG_bg,mBG_br,mBG_gg,mBG_gr,gamma_bg,gamma_br,gamma_gr,BSD_BX,BSD_GX,dur)
        coder.extrinsic('mvnrnd');
        r = zeros(total_rolls,3);
        r = mvnrnd(MU,COV,total_rolls);
        
        %distance distribution
        E1 = 1./(1+(r(:,1)./R0_bg).^6);
        E2 = 1./(1+(r(:,2)./R0_br).^6);
        EGR = 1./(1+(r(:,3)./R0_gr).^6);

        PGR = 1-(1+cr_gr+(((de_gr/(1-de_gr)) + EGR) * gamma_gr)./(1-EGR)).^(-1);

        EBG_R = E1.*(1-E2)./(1-E1.*E2);
        EBR_G = E2.*(1-E1)./(1-E1.*E2);
        E1A = EBG_R + EBR_G;


        PB = pe_b.*(1-E1A);
        
        PG = pe_b.*(1-E1A).*cr_bg + ...
            pe_b.*EBG_R.*(1-EGR).*gamma_bg + ...
            de_bg.*(1-EGR).*gamma_bg;
        
        PR = pe_b.*(1-E1A).*cr_br + ...
            pe_b.*EBG_R.*(1-EGR).*gamma_bg.*cr_gr + ...
            pe_b.*EBG_R.*EGR.*gamma_br + ...
            pe_b.*EBR_G.*gamma_br + ...
            de_bg.*(1-EGR).*gamma_bg.*cr_gr + ...
            de_bg.*EGR.*gamma_br + ...
            de_br.*gamma_br;
        
        P_total = PB+PG+PR;
        
        PBB = PB./P_total;
        PBG = PG./P_total;
        PBR = PR./P_total;
        
        BG_bb = poissrnd(mBG_bb.*dur);
        BG_bg = poissrnd(mBG_bg.*dur);
        BG_br = poissrnd(mBG_br.*dur);
        BG_gg = poissrnd(mBG_gg.*dur);
        BG_gr = poissrnd(mBG_gr.*dur);
        
        %PRH GR
        BSD_GX_bg = BSD_GX-BG_gg-BG_gr;
        PrGR = (binornd(BSD_GX_bg,PGR)+BG_gr)./BSD_GX;
        
        %PRH BG BR
        BSD_BX_bg = BSD_BX - (BG_bb+BG_bg+BG_br);
        PRH = zeros(total_rolls,3);
        
        %replace mnrnd with loop
        for i = 1:total_rolls
            %reset vars
            NBB = 0;
            NBG = 0;
            NBR = 0;
            for j = 1:BSD_BX_bg(i)
                %roll a uniform random number
                result = rand;
                if result <= PBB(i)
                    NBB = NBB+1;
                elseif ( (result > PBB(i)) && (result <= (PBB(i)+PBG(i))) )
                    NBG = NBG +1;
                else
                    NBR = NBR +1;
                end
                PRH(i,1) = NBB;
                PRH(i,2) = NBG;
                PRH(i,3) = NBR;
            end
        end
        %PRH = mnrnd(BSD_BX_bg,[PBB,PBG,PBR]); %sorted by NB NG NR
        
        PrBG = (PRH(:,2)+BG_bg)./BSD_BX;
        PrBR = (PRH(:,3)+BG_br)./BSD_BX;
