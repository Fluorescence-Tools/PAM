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
// void Simulate_States(double * dur, double *dwell_mean, double * p_eq,
//         vector<double> state_dwell_time, vector<double> in_state)        
// {
//     /// Counting variable definition
//     int i;
//     int trans;
//     double t;
//     bool state;
//     double tau;
// //     double SimTime = (double) dur;
//     random_device rd;
//     mt19937 mt(rd()); // initialize mersenne twister engine
//     uniform_real_distribution<double> equal_dist(0.0,1.0);
//     binomial_distribution<int> roll(1,p_eq[1]);
//     state = roll(mt);
//     t = 0;
//     trans = 0;
//     while (t<*dur){
//         tau = -log(equal_dist(mt)) * dwell_mean[state];
//         t += tau;
//         if (t > *dur){
//             tau = *dur - t + tau;
//         }
//         state_dwell_time.push_back(tau);
//         in_state.push_back(state);
//         state = !state;
//     }
// }

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=5)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","5 inputs required."); }
    if (nlhs!=2)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","2 outputs required."); }
    double * dur = mxGetPr(prhs[0]);
    const int n_states = mxGetScalar(prhs[1]);
    double * dwell_mean = mxGetPr(prhs[2]);
    double * p_eq = mxGetPr(prhs[3]);
    double * k_dyn = mxGetPr(prhs[4]);
    vector<double> state_dwell_time;
    vector<double> in_state;
    double * alloc_state_dwell;
    double * alloc_in_state;
//     Simulate_States(dur, dwell_mean, p_eq, state_dwell_time, in_state);
     /// Counting variable definition
    int i;
    int trans;
    double t;
    int s;
    int state;
    double tau;
    double prob;
    double state_changes[] = {1,1,2,-1,0,1,-2,-1};
    random_device rd;
    mt19937 mt(rd()); // initialize mersenne twister engine
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    discrete_distribution<> distribution {p_eq[0],p_eq[1],p_eq[2]};
    state = distribution(mt);
    t = 0;
    while (t<*dur){
        tau = -log(equal_dist(mt)) * dwell_mean[state];
        t += tau;
        if (t > *dur){
            t = *dur;
        }
        state_dwell_time.push_back(t);
        in_state.push_back(state);
        prob = equal_dist(mt);
        for (s=0; s<n_states; ++s){
            if (prob<=k_dyn[(n_states)*state+s]){
                state += state_changes[(n_states)*state+s];
                break;
            }
        }
    }
    int n1 = state_dwell_time.size();
    int n2 = in_state.size();
    alloc_state_dwell = (double*) mxCalloc(n1, sizeof(double));
    for ( i = 0; i < n1; i++ ) {
        alloc_state_dwell[i] = state_dwell_time[i];
    }
    alloc_in_state = (double*) mxCalloc(n2, sizeof(double));
    for ( i = 0; i < n2; i++ ) {
        alloc_in_state[i] = in_state[i];
    }
    plhs[0] = mxCreateNumericMatrix(n1,1,mxDOUBLE_CLASS,mxREAL);
    plhs[1] = mxCreateNumericMatrix(n2,1,mxDOUBLE_CLASS,mxREAL);
    mxSetData(plhs[0], alloc_state_dwell);
    mxSetData(plhs[1], alloc_in_state);
}