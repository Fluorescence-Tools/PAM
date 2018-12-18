// Compile by simply typing mex simulate.cpp

#include "mex.h"
#include "stdlib.h"
#include <iostream>
#include <cmath>
#include <random>
#include <fstream>
#include "time.h"
#include "matrix.h"

// #include <omp.h>
// #include <process.h>
// #include <windows.h>

using namespace std;
// using namespace tr1;

void Simulate_Diffusion(__int64_t SimTime, const int n_states, double *k_dyn, double *initial_state, __int64_t *time_in_states, __int64_t seed, __int64_t time_windows)        
{
    /// Counting variable definition
	__int64_t i = 0;
    __int64_t s = 0;
    __int64_t tw = 0;
    __int64_t state;
    double *TRANS = new double [n_states];
    double prob;
    /// Random number generator
	mt19937 mt; // initialize mersenne twister engine
    mt.seed((unsigned long)time(NULL)+(unsigned long)seed); // engine seeding
    /// Generates uniform distributed random number between 0 and 1
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    /// Loop over all time windows
    for (tw=0;tw<time_windows;tw++){
        state = (__int64_t)initial_state[tw];
        //printf("Initial state is %i.\n",state);
        for (i=0; i<SimTime; i++){    
            /// Dynamic step //////////////////////////////////////////////////
            // if (i > 0) {state[i] = state[i-1];}
            // calculate cumulative probability from outgoing rates of current state
            for (s=0;s<n_states;s++) {
                TRANS[s] = k_dyn[n_states*state+s];
                }
            for (s=1; s<n_states; s++) { TRANS[s] = TRANS[s] + TRANS[s-1]; }  /// Calculates cummulative Transition Probabilites
            prob = equal_dist(mt);
            for (s=0; s<n_states; s++) /// Determines transition according to rates
            { if (prob<=TRANS[s]) {break;}  } 
            state = s; // Update State
            //printf("Updated state is %i.\n",state);
            // sum up the states to obtain the fraction of time spent in state 1
            time_in_states[tw+s*time_windows] += 1;
        }
       // printf("Computed time window %i, time is %i.\n",tw,time_in_state1[tw]);
    }
}
///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=6)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","6 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }
    
    
    // General and Scanning parameters
    __int64_t SimTime = (__int64_t)mxGetScalar(prhs[0]);
        
    // Dynamic Parameters
    const int n_states = mxGetScalar(prhs[1]);
    double *k_dyn = mxGetPr(prhs[2]);
    double *initial_state = mxGetPr(prhs[3]);
    __int64_t seed = (__int64_t)mxGetScalar(prhs[4]);
    __int64_t time_windows = (__int64_t)mxGetScalar(prhs[5]);
    //printf("Number of time windows is %i.\n",time_windows);
    __int64_t *time_in_states = (__int64_t*) mxCalloc(n_states*time_windows, sizeof(__int64_t));   
    //printf("Starting calculation.\n");
    Simulate_Diffusion(
        SimTime,
        n_states, k_dyn, initial_state, time_in_states, // Dynamic parameters
        seed, time_windows); // seed and number of time windows
    // return the number of time points spent in state 2 for every time window
    const mwSize NP[]={(int)time_windows*n_states,1};
    plhs[0] = mxCreateNumericArray(2, NP, mxUINT64_CLASS, mxREAL);
    
    mxSetData(plhs[0], time_in_states);

}