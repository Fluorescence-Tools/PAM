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
using namespace tr1;

void CalcPhasor(
        double Pixel,double *G, double *S,
        unsigned short *MI, unsigned long *Bin, double Photons,
        double *g, double *s, double *Mean_LT)
{
    __int64 phot = 0;
    __int64 pix = 0;
    
    unsigned long *Norm;
    Norm = (unsigned long*) mxCalloc(Pixel, sizeof(unsigned long));
    
    for (phot=0; phot<Photons;phot++) // Loops through every photon
    {
        Norm[Bin[phot]]++;
        g[Bin[phot]] = g[Bin[phot]] + G[MI[phot]];
        s[Bin[phot]] = s[Bin[phot]] + S[MI[phot]];
        Mean_LT[Bin[phot]] = Mean_LT[Bin[phot]] + MI[phot];
    }
    for (pix=0; pix<Pixel;pix++)
    {
        g[pix]=g[pix]/Norm[pix];
        s[pix]=s[pix]/Norm[pix];
        Mean_LT[pix]=Mean_LT[pix]/Norm[pix];
    }
}


void CalcPhasor_Particle(
        double Pixel,double *G, double *S,
        unsigned short *MI, unsigned long *Bin, double Photons,        
        unsigned short *Particle, unsigned long *ParticleFirst,
        double *g, double *s, double *Mean_LT)
{
    __int64 phot = 0;
    __int64 pix = 0;
    
    unsigned long *Norm;
    Norm = (unsigned long*) mxCalloc(Pixel, sizeof(unsigned long));
    
    for (phot=0; phot<Photons;phot++) // Loops through every photon
    {
        if (Particle[Bin[phot]]==0)
        {
            Norm[Bin[phot]]++;
            g[Bin[phot]] = g[Bin[phot]] + G[MI[phot]];
            s[Bin[phot]] = s[Bin[phot]] + S[MI[phot]];
            Mean_LT[Bin[phot]] = Mean_LT[Bin[phot]] + MI[phot];
        }
        else
        {
            Norm[ParticleFirst[Particle[Bin[phot]]-1]]++;
            g[ParticleFirst[Particle[Bin[phot]]-1]] = g[ParticleFirst[Particle[Bin[phot]]-1]] + G[MI[phot]];
            s[ParticleFirst[Particle[Bin[phot]]-1]] = s[ParticleFirst[Particle[Bin[phot]]-1]] + S[MI[phot]];
            Mean_LT[ParticleFirst[Particle[Bin[phot]]-1]] = Mean_LT[ParticleFirst[Particle[Bin[phot]]-1]] + MI[phot];
        }
    }
    for (pix=0; pix<Pixel;pix++)
    {
        g[pix]=g[pix]/Norm[pix];
        s[pix]=s[pix]/Norm[pix];
        Mean_LT[pix]=Mean_LT[pix]/Norm[pix];
    }
}


///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(__int64 nlhs, mxArray *plhs[], __int64 nrhs, const mxArray *prhs[])
{
    if(nrhs!=9)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","9 inputs required."); }
    if (nlhs!=3)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","3 outputs required."); }
    
    
    // Input parameters
    unsigned short *MI = (unsigned short*)mxGetData(prhs[0]);
    unsigned long *Bin = (unsigned long*)mxGetData(prhs[1]);
    double Photons = mxGetScalar(prhs[2]);
    double Pixel = mxGetScalar(prhs[3]);
    double *G = mxGetPr(prhs[4]);
    double *S = mxGetPr(prhs[5]);
    
    double UseParticles = mxGetScalar(prhs[6]);
    

    
    // Output/Calculated parameters
    double *g;
    g = (double*) mxCalloc(Pixel, sizeof(double));
    double *s;
    s = (double*) mxCalloc(Pixel, sizeof(double));
    double *Mean_LT;
    Mean_LT = (double*) mxCalloc(Pixel, sizeof(double));
    
    
    if(UseParticles==0)
    {
        //Perform calculation
        CalcPhasor( Pixel, G, S,
                MI, Bin, Photons,
                g, s, Mean_LT); //Outputs
    }
    else
    {
        unsigned short *Particle = (unsigned short*)mxGetPr(prhs[7]);
        unsigned long *ParticleFirst = (unsigned long*)mxGetPr(prhs[8]);
        //Perform calculation
        CalcPhasor_Particle( Pixel, G, S,
                MI, Bin, Photons,
                Particle, ParticleFirst,
                g, s, Mean_LT); //Outputs
    }
    
    
    const mwSize NP[]={(int)Pixel,1};
    
    plhs[0] = mxCreateNumericArray(2, NP, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, NP, mxDOUBLE_CLASS, mxREAL);
    plhs[2] = mxCreateNumericArray(2, NP, mxDOUBLE_CLASS, mxREAL);
    
    mxSetData(plhs[0], Mean_LT);
    mxSetData(plhs[1], g);
    mxSetData(plhs[2], s);
}