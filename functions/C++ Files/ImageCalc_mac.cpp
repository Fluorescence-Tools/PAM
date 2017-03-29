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

void CalculateImage(
        double *MT, __int64_t Photons, 
        double *PixelTimes, unsigned long Pixel, unsigned long Max,
        unsigned long *Bin, unsigned long *Int)
{
    __int64_t phot = 0;
    unsigned long pix_tot = 0;
    unsigned long pix = 0;
    
    //Go to first photon in frame
    while (MT[phot]<PixelTimes[0]) 
    {
        phot++;
        Bin[phot]=0;
    }
    
    pix_tot = 1;
    pix = 0;    
    while (phot<Photons && pix_tot<=Pixel)
    {
        if (MT[phot]<PixelTimes[pix_tot]) // Add photon to pixel
        {
            Bin[phot] = pix+1;
            Int[pix]++;   
            phot++;
        }
        else //Go to next pixel
        {
            pix_tot++;
            if (Max != 0) {pix = (pix_tot-1) % Max;} //Full Information
            else {pix = pix_tot-1;} //Collaps to single frame    
        }          
    }
}


///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if(nrhs!=5)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","5 inputs required."); }
    if (nlhs!=2)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","2 outputs required."); }
    
    
    // Input parameters
    double *MT = mxGetPr(prhs[0]);
    __int64_t Photons = (__int64_t)mxGetScalar(prhs[1]);
    double *PixelTimes = mxGetPr(prhs[2]);
    unsigned long Pixel = (unsigned long)mxGetScalar(prhs[3]);   
    unsigned long Max = (unsigned long)mxGetScalar(prhs[4]);
    

    
    // Output/Calculated parameters
    unsigned long *Bin;
    Bin = (unsigned long*) mxCalloc(Photons, sizeof(unsigned long*));
    
    unsigned long *Int;
    if (Max==0)
    {Int = (unsigned long*) mxCalloc(Pixel, sizeof(unsigned long));}
    else
    {Int = (unsigned long*) mxCalloc(Max, sizeof(unsigned long));}

    //Perform calculation
    CalculateImage(MT, Photons,
            PixelTimes, Pixel, Max,
            Bin, Int); //Outputs
    
    mwSize NPix[]={(int)Pixel,1};
    if (Max!=0) 
    {NPix[0]=Max;}

   
    mwSize NPhot[]={(int)Photons,1};
    
    plhs[0] = mxCreateNumericArray(2, NPix, mxINT32_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, NPhot, mxINT32_CLASS, mxREAL);
    
    mxSetData(plhs[0], Int);
    mxSetData(plhs[1], Bin);
}