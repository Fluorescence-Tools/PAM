// Compile by simply typing mex simulate.cpp

#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include <algorithm>
#include "time.h"
#include "matrix.h"

// #include <omp.h> 
// #include <process.h>
// #include <windows.h>

using namespace std;
// using namespace tr1;
void Simulate_States(const double SimTime, const int n_states, double *dwell_mean, int time_windows, double *time_in_states, double *p_eq, double *k_dyn)        
{
    /// Counting variable definition
    unsigned int i;
    double t;
    char s;
    char state;
    double tau;
    double prob;
    char state_changes[] = {1,1,2,-1,0,1,-2,-1};
    random_device rd;
    mt19937 mt(rd()); // initialize mersenne twister engine
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    discrete_distribution<> distribution {p_eq[0],p_eq[1],p_eq[2]};
    for (i=0;i<time_windows;++i){

        state = distribution(mt);
        t = 0;
        while (t<SimTime){
            tau = -log(equal_dist(mt)) * dwell_mean[state];
            t += tau;
            if (t > SimTime){
                tau = SimTime - t + tau;
                // break;
            }
            time_in_states[i+time_windows*state] += tau;
            prob = equal_dist(mt);
            for (s=0; s<n_states; ++s){
                if (prob<=k_dyn[(n_states)*state+s]){
                    state += state_changes[(n_states)*state+s];
                    break;
                }
            }
        }
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=6)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","6 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }

    const double SimTime = mxGetScalar(prhs[0]);
    const int n_states = mxGetScalar(prhs[1]);
    double *dwell_mean = mxGetPr(prhs[2]);
    int time_windows = (int)mxGetScalar(prhs[3]);
    double *p_eq = mxGetPr(prhs[4]);
    double *k_dyn = mxGetPr(prhs[5]);
    const mwSize NP[]={(unsigned long)time_windows*n_states,1};
    double *time_in_states = (double*) mxCalloc(n_states*time_windows, sizeof(double));
    Simulate_States(SimTime, n_states, dwell_mean, time_windows, time_in_states, p_eq, k_dyn);
    plhs[0] = mxCreateNumericMatrix(time_windows,n_states,mxDOUBLE_CLASS,mxREAL);
    mxSetData(plhs[0], time_in_states);
}