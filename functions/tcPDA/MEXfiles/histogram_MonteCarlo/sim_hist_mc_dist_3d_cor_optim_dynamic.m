function [ PrBG, PrBR, PrGR ] = sim_hist_mc_dist_3d_cor_optim_dynamic(MU1,COV1,MU2,COV2,k12,k21,Qr_g,Qr_b,total_rolls,R0_bg,R0_br,R0_gr,cr_bg,cr_br,cr_gr,pe_b,de_bg,de_br,de_gr,mBG_bb,mBG_bg,mBG_br,mBG_gg,mBG_gr,gamma_bg,gamma_br,gamma_gr,BSD_BX,BSD_GX,dur)
coder.extrinsic('mvnrnd');
r = zeros(total_rolls,3);
PBB = zeros(total_rolls,2);
PBG = zeros(total_rolls,2);
PBR = zeros(total_rolls,2);
PGR = zeros(total_rolls,2);
for i = 1:2
    if i == 1
        MU = MU1;
        COV = COV1;
    elseif i == 2
        MU = MU2;
        COV = COV2;
    end
    r = mvnrnd(MU,COV,total_rolls);

    %distance distribution
    E1 = 1./(1+(r(:,1)./R0_bg).^6);
    E2 = 1./(1+(r(:,2)./R0_br).^6);
    EGR = 1./(1+(r(:,3)./R0_gr).^6);

    PGR(:,i) = 1-(1+cr_gr+(((de_gr/(1-de_gr)) + EGR) * gamma_gr)./(1-EGR)).^(-1);

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

    PBB(:,i) = PB./P_total;
    PBG(:,i) = PG./P_total;
    PBR(:,i) = PR./P_total;
end
% evaluate background
BG_bb = poissrnd(mBG_bb.*dur);
BG_bg = poissrnd(mBG_bg.*dur);
BG_br = poissrnd(mBG_br.*dur);
BG_gg = poissrnd(mBG_gg.*dur);
BG_gr = poissrnd(mBG_gr.*dur);
% subtract background
BSD_GX_bg = BSD_GX-BG_gg-BG_gr;
BSD_BX_bg = BSD_BX - (BG_bb+BG_bg+BG_br);

% roll time spent in state 1 and 2
% duration in ms, rates in 1/ms
dwell_mean = [1./k12,1./k21]; % dwelltimes in the states
p_eq = [k21,k12]./(k12+k21); % equ. populations
FracT = Gillespie_2states(dur,dwell_mean,total_rolls,p_eq);

FracInt_G1 = Qr_g(1).*FracT(:,1)./(Qr_g(1).*FracT(:,1)+Qr_g(2).*FracT(:,2));
FracInt_B1 = Qr_b(1).*FracT(:,1)./(Qr_b(1).*FracT(:,1)+Qr_b(2).*FracT(:,2));

% evaluate intensity contributions of state 1 and 2
IntG(:,1) = binornd(BSD_GX_bg,FracInt_G1);
IntG(:,2) = BSD_GX - IntG(:,1);

IntB(:,1) = binornd(BSD_BX_bg,FracInt_B1);
IntB(:,2) = BSD_BX - IntB(:,1);

%PRH GR
PrGR = (binornd(IntG(:,1),PGR(:,1))+binornd(IntG(:,2),PGR(:,2))+BG_gr)./BSD_GX;

%PRH BG BR
PRH1 = zeros(total_rolls,3);
PRH2 = zeros(total_rolls,3);

PRH1 = mnrnd(IntB(:,1),[PBB(:,1),PBG(:,1),PBR(:,1)]); %sorted by NB NG NR
PRH2 = mnrnd(IntB(:,2),[PBB(:,2),PBG(:,2),PBR(:,2)]);

PrBG = (PRH1(:,2)+PRH2(:,2)+BG_bg)./BSD_BX;
PrBR = (PRH1(:,3)+PRH2(:,3)+BG_br)./BSD_BX;

% %replace mnrnd with loop
% for i = 1:total_rolls
%     %reset vars
%     NBB = 0;
%     NBG = 0;
%     NBR = 0;
%     for j = 1:BSD_BX_bg(i)
%         %roll a uniform random number
%         result = rand;
%         if result <= PBB(i)
%             NBB = NBB+1;
%         elseif ( (result > PBB(i)) && (result <= (PBB(i)+PBG(i))) )
%             NBG = NBG +1;
%         else
%             NBR = NBR +1;
%         end
%         PRH(i,1) = NBB;
%         PRH(i,2) = NBG;
%         PRH(i,3) = NBR;
%     end
% end