// Compile by simply typing mex simulate.cpp

#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include <vector>
#include <algorithm>
#include "time.h"
#include "matrix.h"

// #include <omp.h> 
// #include <process.h>
// #include <windows.h>

using namespace std;
// using namespace tr1;
void Simulate_States(double mBG_gg, double mBG_gr, double *R, double *sigmaR, const double R0, const double cr, const double de, const double ct, const double gamma, const int time_windows, const double SimTime, double *BSD, double *dwell_mean, double *p_eq, const char sampling, double *PRH)
{
    /// Counting variable definition
    int i;
    char n;
    char s;
    bool state;
    double t;
    double tau;
    vector<double> r(2);
    vector<double> FRET(2);
    vector<double> eps(2);
    int BG_gr;
    int BSD_bg;
    double E;
    vector<double> Q(2);
    vector<int> f_i(2);
    vector<double> fracTauT(2);
    random_device rd{};
    mt19937 mt{rd()}; // initialize mersenne twister engine
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    binomial_distribution<int> roll(1,p_eq[1]);
    poisson_distribution<int> BG_gg_rnd(mBG_gg*SimTime);
    poisson_distribution<int> BG_gr_rnd(mBG_gr*SimTime);
    normal_distribution<double> rollR0(R[0],sigmaR[0]);
    normal_distribution<double> rollR1(R[1],sigmaR[1]);
    for (i=0;i<2;++i){
            E = 1/(1+(R[i]/R0)*(R[i]/R0)*(R[i]/R0)*(R[i]/R0)*(R[i]/R0)*(R[i]/R0));
            Q[i] = (1-de)*(1-E)+(gamma/(1+ct))*(de+E*(1-de));
        }
    for (n=0;n<sampling;++n){
        for (i=0;i<time_windows;++i){
            state = roll(mt);
            while (t<SimTime){
                tau = -log(equal_dist(mt)) * dwell_mean[state];
                t += tau;
                if (t > SimTime){
                    tau = SimTime - t + tau;
                }
                fracTauT[state] += tau;
                state = !state;
            }
            t = 0;
            BG_gr = BG_gr_rnd(mt);
            BSD_bg = BSD[i] - BG_gg_rnd(mt) - BG_gr;
            binomial_distribution<int> Intrnd(BSD_bg,Q[0]*fracTauT[0]/(Q[0]*fracTauT[0]+Q[1]*fracTauT[1]));
            f_i[0] = Intrnd(mt);
            f_i[1] = BSD_bg - f_i[0];
            r[0] = rollR0(mt);
            r[1] = rollR1(mt);
            for (s=0;s<2;++s){
                FRET[s] = 1/(1+(r[s]/R0)*(r[s]/R0)*(r[s]/R0)*(r[s]/R0)*(r[s]/R0)*(r[s]/R0));
                eps[s] = 1-1/(1+cr+(((de/(1-de))+FRET[s])*gamma)/(1-FRET[s]));
                fracTauT[s]=0;
            }
            binomial_distribution<int> EPSrnd0(f_i[0],eps[0]);
            binomial_distribution<int> EPSrnd1(f_i[1],eps[1]);
            PRH[i+n*time_windows] = ((EPSrnd0(mt)+EPSrnd1(mt)+BG_gr)/BSD[i]);
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=15)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","15 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }
    double mBG_gg = mxGetScalar(prhs[0]);
    double mBG_gr = mxGetScalar(prhs[1]);
    double *R = mxGetPr(prhs[2]);
    double *sigmaR = mxGetPr(prhs[3]);
    const double R0 = mxGetScalar(prhs[4]);
    const double cr = mxGetScalar(prhs[5]);
    const double de = mxGetScalar(prhs[6]);
    const double ct = mxGetScalar(prhs[7]);
    const double gamma = mxGetScalar(prhs[8]);
    const int time_windows = mxGetScalar(prhs[9]);
    const double SimTime = mxGetScalar(prhs[10]);
    double *BSD = mxGetPr(prhs[11]);
    double *dwell_mean = mxGetPr(prhs[12]);
    double *p_eq = mxGetPr(prhs[13]);
    const char sampling = mxGetScalar(prhs[14]);
    const mwSize NP[]={(mwSize)time_windows*2*sampling,1};
    double *PRH = (double*) mxCalloc(sampling*time_windows, sizeof(double));
    Simulate_States(mBG_gg, mBG_gr, R, sigmaR, R0, cr, de, ct, gamma, time_windows, SimTime, BSD, dwell_mean, p_eq, sampling, PRH);
    plhs[0] = mxCreateNumericMatrix(time_windows*sampling,1,mxDOUBLE_CLASS,mxREAL);
    mxSetData(plhs[0], PRH);
}














