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

void Simulate_Diffusion(__int64_t SimTime, const int n_states, double *k_dyn, int initial_state, unsigned char *state, __int64_t seed)        
{
    /// Counting variable definition
	__int64_t i = 0;
    __int64_t s = 0;

    double *TRANS = new double [n_states];
    double prob;
    /// Random number generator
	mt19937 mt; // initialize mersenne twister engine
    mt.seed((unsigned long)time(NULL)+(unsigned long)seed); // engine seeding
    /// Generates uniform distributed random number between 0 and 1
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    state[0] = (unsigned char) initial_state;
    for (i=0; i<SimTime; i++) 
    {    
        /// Dynamic step //////////////////////////////////////////////////
        if (i > 0) {state[i] = state[i-1];}
        // calculate cumulative probability from outgoing rates of current state
        for (s=0;s<n_states;s++) {
            TRANS[s] = k_dyn[n_states*state[i]+s];
            }
        for (s=1; s<n_states; s++) { TRANS[s] = TRANS[s] + TRANS[s-1]; }  /// Calculates cummulative Transition Probabilites
        prob = equal_dist(mt);
        for (s=0; s<n_states; s++) /// Determines transition according to rates
        { if (prob<=TRANS[s]) {break;}  } 
        state[i] = (unsigned char) s; // Update State
    }
}
///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=5)
    { mexErrMsgIdAndTxt("dyn_Sim:nrhs","5 inputs required."); }
    if (nlhs!=1)
    { mexErrMsgIdAndTxt("dyn_Sim:nlhs","1 output required."); }
    
    
    // General and Scanning parameters
    __int64_t SimTime = (__int64_t)mxGetScalar(prhs[0]);
        
    // Dynamic Parameters
    const int n_states = mxGetScalar(prhs[1]);
    double *k_dyn = mxGetPr(prhs[2]);
    int initial_state = mxGetScalar(prhs[3]);
    __int64_t seed = (__int64_t)mxGetScalar(prhs[4]);
            
    unsigned char *state;
    state = (unsigned char*) mxCalloc(4*SimTime, sizeof(unsigned char));   
    
    Simulate_Diffusion(
        SimTime,
        n_states, k_dyn, initial_state, state, // Dynamic parameters
        seed); // Map for quenching/barriers etc.

    const mwSize NP[]={(int)SimTime,1};
    plhs[0] = mxCreateNumericArray(2, NP, mxUINT8_CLASS, mxREAL);
    
    mxSetData(plhs[0], state);

}