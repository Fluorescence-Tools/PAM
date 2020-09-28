
// Include Files
#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include <algorithm>
#include "time.h"
#include "matrix.h"
#include <fstream>
#include <iostream>
#include "eigenmvn.h"

using namespace std;

void sim_hist_mc_dist_3d_cor_optim_dynamicCPP(double *MU1, double *COV1, double *MU2, 
  double *COV2, double k12, double k21, double *Qr_g, double *Qr_b, const int total_rolls, 
  double R0_bg, double R0_br, double R0_gr, double cr_bg, double cr_br, double cr_gr, 
  double pe_b, double de_bg, double de_br, double de_gr, double mBG_bb, double mBG_bg, 
  double mBG_br, double mBG_gg, double mBG_gr, double gamma_bg , double gamma_br, 
  double gamma_gr, double *BSD_BX, double *BSD_GX, double dur, double *PrBG,
  double *PrBR, double *PrGR)
{
    int i;
    int j;
    int k;
    double BG_bg;
    double BG_br;
    double BG_gr;
    int IntB[2];
    int IntG[2];
    double BSD_GX_bg;
    double BSD_BX_bg;
    double fracInt_G1;
    double fracInt_B1;
    int PRH1[3] = {0,0,0};
    int PRH2[3] = {0,0,0};
    double PGR[2];
    double PBB[2];
    double PBG[2];
    double PBR[2];
    double E1;
    double E2;
    double EGR;
    double EBG_R;
    double EBR_G;
    double E1A;
    double PB;
    double PG;
    double PR;
    double P_total;
    double dwell_mean[2] = {(double) 1 / k12, (double) 1 / k21};
    double p_eq[2] = {k21 / (k12 + k21), k12 / (k12 + k21)};
    double fracT[2];
    bool state;
    double t;
    double tau;

    random_device rd;
    mt19937 mt(rd());
    uniform_real_distribution<double> equal_dist(0.0,1.0); // roll dwell time tau
    binomial_distribution<int> roll(1,p_eq[1]); // roll initial state (state 2 = true(1), state 1 = false(0))
    poisson_distribution<int> BG_bb_rnd(mBG_bb*dur);
    poisson_distribution<int> BG_bg_rnd(mBG_bg*dur);
    poisson_distribution<int> BG_br_rnd(mBG_br*dur);
    poisson_distribution<int> BG_gg_rnd(mBG_gg*dur);
    poisson_distribution<int> BG_gr_rnd(mBG_gr*dur);

    Eigen::Matrix3d cov;
    Eigen::Matrix<double,1,3> mu;
    Eigen::VectorXd mvrnd_v(3,1);

    for (i=0;i<total_rolls;++i)
    {
        for (j=0;j<2;++j)
        {
            fracT[j] = 0;
            if (j==0)
            {
                mu << MU1[0],MU1[1],MU1[2];
                cov << COV1[0],COV1[1],COV1[2],
                COV1[3],COV1[4],COV1[5],
                COV1[6],COV1[7],COV1[8];
            }
            else
            {
                mu << MU2[0],MU2[1],MU2[2];
                cov << COV2[0],COV2[1],COV2[2],
                COV2[3],COV2[4],COV2[5],
                COV2[6],COV2[7],COV2[8];
            }
            normal_random_variable sample_mvrnd { mu, cov };
            mvrnd_v << sample_mvrnd();
            double *r = mvrnd_v.data();

            E1 = 1/(1+(r[0]/R0_bg)*(r[0]/R0_bg)*(r[0]/R0_bg)*(r[0]/R0_bg)*(r[0]/R0_bg)*(r[0]/R0_bg));
            E2 = 1/(1+(r[1]/R0_br)*(r[1]/R0_br)*(r[1]/R0_br)*(r[1]/R0_br)*(r[1]/R0_br)*(r[1]/R0_br));
            EGR = 1/(1+(r[2]/R0_gr)*(r[2]/R0_gr)*(r[2]/R0_gr)*(r[2]/R0_gr)*(r[2]/R0_gr)*(r[2]/R0_gr));

            PGR[j] = 1-1/(1+cr_gr+(((de_gr/(1-de_gr))+EGR)*gamma_gr)/(1-EGR));

            EBG_R = E1*(1-E2)/(1-E1*E2);
            EBR_G = E2*(1-E1)/(1-E1*E2);
            E1A = EBG_R+EBR_G;

            PB = pe_b*(1-E1A);

            PG = pe_b*(1-E1A)*cr_bg +
                pe_b*EBG_R*(1-EGR)*gamma_bg +
                de_bg*(1-EGR)*gamma_bg;

            PR = pe_b*(1-E1A)*cr_br +
                pe_b*EBG_R*(1-EGR)*gamma_bg*cr_gr +
                pe_b*EBG_R*EGR*gamma_br +
                pe_b*EBR_G*gamma_br +
                de_bg*(1-EGR)*gamma_bg*cr_gr +
                de_bg*EGR*gamma_br +
                de_br*gamma_br;

            P_total = PB+PG+PR;

            PBB[j] = PB/P_total;
            PBG[j] = PG/P_total;
            PBR[j] = PR/P_total;
        }
        //  evaluate background
        BG_bg = BG_bg_rnd(mt);
        BG_br = BG_br_rnd(mt);
        BG_gr = BG_gr_rnd(mt);
        // subtract background
        BSD_GX_bg = BSD_GX[i]-BG_gg_rnd(mt)-BG_gr;
        BSD_BX_bg = BSD_BX[i]-(BG_bb_rnd(mt)+BG_bg+BG_br);
        if (BSD_GX_bg<0)
        {
        BSD_GX_bg = 0;
        }
        if (BSD_BX_bg<0)
        {
        BSD_BX_bg = 0;
        }
        // roll time spent in state 1 and 2
        // duration in ms, rates in 1/ms
        // Gillespie Algorithm
        state = roll(mt);
        t = 0;
        while (t < dur)
        {
            tau = -log(equal_dist(mt)) * dwell_mean[state];
            t += tau;
            if (t > dur)
            {
                tau = dur - t + tau;
            }
            fracT[state] += tau;
            state = !state;
        }
        fracInt_G1 = (Qr_g[0]) * fracT[0] / 
        ((Qr_g[0]) * fracT[0] + (Qr_g[1]) * fracT[1]);
        fracInt_B1 = (Qr_b[0]) * fracT[0] / 
        ((Qr_b[0]) * fracT[0] + (Qr_b[1]) * fracT[1]);

        // evaluate intensity contributions of state 1 and 2
        binomial_distribution<int> rollIntG(BSD_GX_bg,fracInt_G1);
        IntG[0] = rollIntG(mt);
        IntG[1] = (int)BSD_GX[i] - IntG[0];

        binomial_distribution<int> rollIntB(BSD_BX_bg,fracInt_B1);

        IntB[0] = rollIntB(mt);
        IntB[1] = (int)BSD_BX[i] - IntB[0];

        binomial_distribution<int> rollPrGR_1(IntG[0],PGR[0]);
        binomial_distribution<int> rollPrGR_2(IntG[1],PGR[1]);
        PrGR[i] = (rollPrGR_1(mt) + rollPrGR_2(mt) + BG_gr) / BSD_GX[i];

        discrete_distribution<int> rollPRH1 ({PBB[0],PBG[0],PBR[0]});
        discrete_distribution<int> rollPRH2 ({PBB[1],PBG[1],PBR[1]});

        for (j=0;j<IntB[0];++j)
        {
            ++PRH1[rollPRH1(mt)];
        }
        for (j=0;j<IntB[1];++j)
        { 
            ++PRH2[rollPRH2(mt)];
        }
        PrBG[i] = (PRH1[1]+PRH2[1]+BG_bg) / BSD_BX[i];
        PrBR[i] = (PRH1[2]+PRH2[2]+BG_br) / BSD_BX[i];
        for (j=1;j<3;++j)
        {
            PRH1[j] = 0;
            PRH2[j] = 0;
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
  if(nrhs!=30)
  { mexErrMsgIdAndTxt("dyn_Sim:nrhs","30 inputs required."); }
  if (nlhs!=3)
  { mexErrMsgIdAndTxt("dyn_Sim:nlhs","3 output required."); }
  double *MU1 = mxGetPr(prhs[0]);
  double *COV1 = mxGetPr(prhs[1]);
  double *MU2 = mxGetPr(prhs[2]);
  double *COV2 = mxGetPr(prhs[3]);
  double k12 = mxGetScalar(prhs[4]);
  double k21 = mxGetScalar(prhs[5]);
  double *Qr_g = mxGetPr(prhs[6]);
  double *Qr_b = mxGetPr(prhs[7]);
  const int total_rolls = mxGetScalar(prhs[8]);
  double R0_bg = mxGetScalar(prhs[9]);
  double R0_br = mxGetScalar(prhs[10]);
  double R0_gr = mxGetScalar(prhs[11]);
  double cr_bg = mxGetScalar(prhs[12]);
  double cr_br = mxGetScalar(prhs[13]);
  double cr_gr = mxGetScalar(prhs[14]);
  double pe_b = mxGetScalar(prhs[15]);
  double de_bg = mxGetScalar(prhs[16]);
  double de_br = mxGetScalar(prhs[17]);
  double de_gr = mxGetScalar(prhs[18]);
  double mBG_bb = mxGetScalar(prhs[19]);
  double mBG_bg = mxGetScalar(prhs[20]);
  double mBG_br = mxGetScalar(prhs[21]);
  double mBG_gg = mxGetScalar(prhs[22]);
  double mBG_gr = mxGetScalar(prhs[23]);
  double gamma_bg = mxGetScalar(prhs[24]);
  double gamma_gr = mxGetScalar(prhs[25]);
  double gamma_br = mxGetScalar(prhs[26]);
  double *BSD_BX = mxGetPr(prhs[27]);
  double *BSD_GX = mxGetPr(prhs[28]);
  double dur = mxGetScalar(prhs[29]);
  double *PrGR = (double*) mxCalloc(total_rolls, sizeof(double));
  double *PrBG = (double*) mxCalloc(total_rolls, sizeof(double));
  double *PrBR = (double*) mxCalloc(total_rolls, sizeof(double));
  sim_hist_mc_dist_3d_cor_optim_dynamicCPP(MU1, COV1, MU2, COV2, k12, k21, 
  Qr_g, Qr_b, total_rolls, R0_bg, R0_br, R0_gr, cr_bg, cr_br, cr_gr, pe_b, 
  de_bg, de_br, de_gr, mBG_bb, mBG_bg, mBG_br, mBG_gg, mBG_gr, gamma_bg, 
  gamma_gr, gamma_br, BSD_BX, BSD_GX, dur, PrGR, PrBG, PrBR);
  plhs[0] = mxCreateNumericMatrix(total_rolls,1,mxDOUBLE_CLASS,mxREAL);
  plhs[1] = mxCreateNumericMatrix(total_rolls,1,mxDOUBLE_CLASS,mxREAL);
  plhs[2] = mxCreateNumericMatrix(total_rolls,1,mxDOUBLE_CLASS,mxREAL);
  mxSetData(plhs[0], PrGR);
  mxSetData(plhs[1], PrBG);
  mxSetData(plhs[2], PrBR);
}