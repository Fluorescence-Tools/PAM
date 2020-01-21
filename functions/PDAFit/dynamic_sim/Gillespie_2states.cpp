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
void Simulate_States(const double SimTime, double *dwell_mean, const int time_windows, double *time_in_states, double * p_eq)        
{
    /// Counting variable definition
    int i;
    double t;
    bool state;
    double tau;

    random_device rd;
    mt19937 mt(rd()); // initialize mersenne twister engine
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    binomial_distribution<int> roll(1,p_eq[1]);
    for (i=0;i<time_windows;++i){
        state = roll(mt);
        t = 0;
        while (t<SimTime){
            tau = -log(equal_dist(mt)) * dwell_mean[state];
            t = t + tau;
            if (t > SimTime){
                tau = SimTime - t + tau;
            }
            time_in_states[i+time_windows*state] += tau;
            state = !state;
        }  
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=4)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","4 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }

    const double SimTime = mxGetScalar(prhs[0]);
    double * dwell_mean = mxGetPr(prhs[1]);
    const int time_windows = mxGetScalar(prhs[2]);
    double * p_eq = mxGetPr(prhs[3]);
    const mwSize NP[]={(mwSize)time_windows*2,1};
    double * time_in_states = (double*) mxCalloc(2*time_windows, sizeof(double));
    Simulate_States(SimTime, dwell_mean, time_windows, time_in_states, p_eq);
    plhs[0] = mxCreateNumericMatrix(time_windows,2,mxDOUBLE_CLASS,mxREAL);
    mxSetData(plhs[0], time_in_states);
}