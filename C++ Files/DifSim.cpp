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

void Simulate_Diffusion(
        __int64 SimTime,  double *Box,
        double ScanType, double *Step, double *Pixel, double *ScanTicks,
        double D, double *Pos,
        double *Wr, double *Wz, double *ShiftX, double *ShiftY, double *ShiftZ,
        double *ExP, double *DetP, double *BlP,
        double *Rates, double *Cross,
        double *Macrotimes, unsigned char *Channel, __int64 *NPhotons)        
{
    /// Counting variable definition
	__int64 i = 0;
    unsigned char j = 0;
    unsigned char k = 0;
    unsigned char m = 0;
    unsigned char n = 0;
    unsigned char p = 0;
    unsigned char q = 0;
    double FRET[4];
    double CROSS[4];
    double prob;

    /// Random number generator
	mt19937 mt; // initialize mersenne twister engine
    mt.seed((unsigned long)time(NULL)); // engine seeding
    //normal distribtion for diffusion
	normal_distribution<double> normal(0.0, D); //mu = 0.0, sigma = 1.0
    
    double Ex;
//     double Em;
//     double Bl;
    
    /// Determines active colors (Excitation probability > 1E-10, because 0 is not always exactly 0)
    bool Active [4][2];    
    for (p = 0; p<4; p++)
    {
        if ((ExP[4*p] + ExP[4*p+1] + ExP[4*p+2] + ExP[4*p+3]) > 1E-10)
        {
            Active [p][0] = true;
            Active [p][1] = true;
        }
        else
        {
            Active [p][0] = false;
            Active [p][1] = false;
        }
    }
    
    /// Starting point of focus
    double x0 = -Pixel[0]*Step[0]/2;
    double y0 = -Pixel[0]*Step[0]/2;
    /// Initializes focus positions
    double x = 0;
    double y = 0;
    
    for (i=0; i<SimTime; i++) 
    {
        /// Particle movement /////////////////////////////////////////////
        Pos[0] = Pos[0] + normal(mt); // Go one step in x direction
        Pos[1] = Pos[1] + normal(mt); // Go one step in y direction
        if (Box[2] > 0) { Pos[2] = Pos[2] + normal(mt); } // Go one step in z direction, if not 2D
        else { Box[2] = 0; } // Puts particle inside plane
                
        /// Particle exits border /////////////////////////////////////////
        if ((Pos[0] < 0.0) || (Pos[0] > Box[0]) || (Pos[1] < 0.0) || (Pos[1] > Box[1]) || (Pos[2] < 0.0) || (Pos[2] > Box[2]))
        {
            // Unbleach on box border crossing
            for (p = 0; p<4; p++) { Active[p][0] = Active[p][1]; }
            // Put particle back on the other side
            Pos[0] = fmod((Pos[0] + Box[0]), Box[0]);
            Pos[1] = fmod((Pos[1] + Box[1]), Box[1]);
            if (Box[2] > 0) { Pos[2] = fmod((Pos[2] + Box[2]), Box[2]) ; } 
        }
        
        /// Focus movement ////////////////////////////////////////////////
        switch ((int)ScanType)
        {
            case 1: /// Point measurement
                x = 0;
                y = 0;
                break;
            case 2: /// Raster scan (includes point and line)
                x = fmod((double)(i / ScanTicks[0]), Pixel[0]) * Step[0] + x0;
                y = fmod((double)(i / ScanTicks[1]), Pixel[1]) * Step[1] + x0;
                break;
            case 3: /// Line scan
                x = fmod((double)(i / ScanTicks[0]), Pixel[0]) * Step[0] + x0;
                y = 0;
                break;
            default: 
                x = 0;
                y = 0;
                break;
        }
        
        
        ///////////////////////////////////////////////////////////////////
        /// Photon generation /////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////
        /// j determines excitation color (accounts for PIE cycle)
        /// k determines excited dye (accounts for direct excitation)
        /// m determines emition dye (accounts for FRET of multi-step FRET)
        /// n determines detection channel (daccounts for cross-talk)
        
        ///////////////////////////////////////////////////////////////////
        /// Laser Color (PIE) /////////////////////////////////////////////
        ///////////////////////////////////////////////////////////////////
        for (j=0; j<4; j++) 
        {            
            ///////////////////////////////////////////////////////////////
            /// Excited dye (Direct excitation) ///////////////////////////
            ///////////////////////////////////////////////////////////////
            for (k=0; k<4; k++)
            {
                if (Active[k][0] && ExP[4*j+k]>0) /// Only calculates, if particle is active/not bleached and direct excitation enabled
                {
                    /// Calculate absolute excitation probability
                    Ex = ExP[4*j+k]*exp(-2*((Pos[0]-Box[0]/2+ShiftX[j]-x)*(Pos[0]-Box[0]/2+ShiftX[j]-x) /// X
                    + (Pos[1]-Box[1]/2+ShiftY[j]-y)*(Pos[1]-Box[1]/2+ShiftY[j]-y))/(Wr[j]*Wr[j]) ///Y
                    -2*(Pos[2]-Box[2]/2+ShiftZ[j])*(Pos[2]-Box[2]/2+ShiftZ[j])/(Wz[j]*Wz[j])); ///Z
                    if (Ex > 1E-4) /// Only roll if Excitation is larger than 0.01% = 1E-4
                    {
                        /// Create binomial distribution for excitation probability
                        binomial_distribution<__int64, double> binomial(1, Ex);
                        if ((double) binomial(mt))/// Generates photons with probability
                        {                            
                            ///////////////////////////////////////////////
                            //// Emitting dye (FRET) //////////////////////
                            ///////////////////////////////////////////////                            
                            m = k;
                            while (m<4) /// Determines emitting dye (Only downward transfer possible)
                            {
                                for (p=m; p<4; p++) /// Extracts current FRET rates
                                { 
                                    if (Active[p][1]) { FRET[p] = Rates[4*m+p]; } /// Dye is active
                                    else { FRET[p] = 0; } /// Dye is not active
                                } 
                                for (p=m+1; p<4; p++) { FRET[p] = FRET[p] + FRET[p-1]; } /// Extract cummulative FRET rates
                                
                                if ((FRET[3]-1) > 1E-4) /// FRET is feasíble
                                {
                                    for (p=m; p<4; p++) { FRET[p] = FRET[p]/FRET[3]; }  /// Calculates cummulative FRET Probabilites
                                    /// Generates uniform distributed random number between 0 and 1
                                    uniform_real_distribution<double> equal_dist(0.0,1.0);
                                    prob = equal_dist(mt);
                                    for (p=m; p<4; p++) /// Determines em. dye according to rates
                                    { if (prob<=FRET[p]) { break; } }
                                    
                                    if  (p == m) { break; } /// No FRET occured
                                    else if (p == 3) { m = 3; break; } /// FRET to lowest energy dye occuded, therefor no more FRET possible
                                    else { m = p; } /// FRET occured; next round of checks starts
                                }
                                else { break; } /// No FRET can occure, therefore ex.dye = em.dye
                            }
                            if (BlP[m] > 0.0) /// If bleaching is enabled
                            {
                                binomial_distribution<__int64, double> binomial(1, BlP[m]);
                                if ( ((double) binomial(mt)) ) /// Bleaches particle
                                { Active[m][0] = false; }
                                
                            }
                            if (Active[m][0]) // If particle doesn't bleach
                            {                                
                                ///////////////////////////////////////////
                                /// Determines detection channel //////////
                                ///////////////////////////////////////////
                                for (p=0; p<4; p++) { CROSS[p] = Cross[4*m+p]; } /// Extracts crosstalk rates
                                for (p=1; p<4; p++) { CROSS[p] = CROSS[p] + CROSS[p-1]; } /// Extracts cummulative crosstalk rates
                                
                                if ((CROSS[3]-1) > 1E-5) /// Crosstalk is realistic
                                {
                                    for (p=0; p<4; p++) { CROSS[p] = CROSS[p]/CROSS[3]; }  /// Calculates cummulative detection probabilites
                                    uniform_real_distribution<double> equal_dist(0.0,1.0);
                                    prob = equal_dist(mt);
                                    for (n=m; n<4; n++) /// Determines detection color
                                    { if (prob<=CROSS[n]) { break; } }
                                }
                                else {n = m; } /// No crosstalk, therefore detection channel == emitting dye                                
                                
                                ///////////////////////////////////////////
                                /// Determines, if photon was emitteddetected
                                ///////////////////////////////////////////
                                if (DetP[4*m+n] > 1E-5)
                                {
                                    binomial_distribution<__int64, double> binomial(1, DetP[4*m+n]);
                                    if ( ((double) binomial(mt)) ) /// Bleaches particle
                                    {
                                        /// Adds photon
                                        Macrotimes[NPhotons[0]] = (double) i;
                                        // 2 bits each for:    laser      ex. dye    em. dye    det.
                                        Channel[NPhotons[0]] = (j << 6) | (k << 4) | (m << 2) | n ;
                                        NPhotons[0]++;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(__int64 nlhs, mxArray *plhs[], __int64 nrhs, const mxArray *prhs[])
{    
    if(nrhs!=18)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","18 inputs required."); }
    if (nlhs!=3)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","3 outputs required."); }
    
    
    // General and Scanning parameters
    __int64 SimTime = (__int64)mxGetScalar(prhs[0]);
    double *Box = mxGetPr(prhs[1]);
    double ScanType = mxGetScalar(prhs[2]);
    double *Step = mxGetPr(prhs[3]);
    double *Pixel = mxGetPr(prhs[4]);
    double *ScanTicks = mxGetPr(prhs[5]);
    
    // Particle Parameters
    double D = mxGetScalar(prhs[6]);  
    double *Pos = mxGetPr(prhs[7]);

    // Color Parameters
    double *Wr = mxGetPr(prhs[8]);
    double *Wz = mxGetPr(prhs[9]);
    double *ShiftX = mxGetPr(prhs[10]);
    double *ShiftY = mxGetPr(prhs[11]);
    double *ShiftZ = mxGetPr(prhs[12]);
    double *ExP = mxGetPr(prhs[13]);
    double *DetP =  mxGetPr(prhs[14]);
    double *BlP = mxGetPr(prhs[15]);
    double *Rates =  mxGetPr(prhs[16]);
    double *Cross = mxGetPr(prhs[17]);
        
    

    double *Macrotimes;
    Macrotimes = (double*) mxCalloc(4*SimTime, sizeof(double));
    unsigned char *Channel;
    Channel = (unsigned char*) mxCalloc(4*SimTime, sizeof(unsigned char));
    __int64 *NPhotons;
    NPhotons=(__int64*) mxCalloc(1, sizeof(__int64));
    
    Simulate_Diffusion(
        SimTime, Box, // General parameters
        ScanType, Step, Pixel, ScanTicks, // Scanning parameters
        D, Pos, // Particle parameters
        Wr, Wz, ShiftX, ShiftY, ShiftZ, // Focus parameters
        ExP, DetP, BlP, 
        Rates, Cross, // Parameter containing FRET/Crosstalk rates
        Macrotimes, Channel, NPhotons); // Outputparameters
        
    const mwSize NP[]={NPhotons[0],1};
    const mwSize SizePos[]={3,1};
     
    double* Final_Pos;
    Final_Pos =(double*) mxCalloc(3, sizeof(double));
    Final_Pos[0] = Pos[0];
    Final_Pos[1] = Pos[1];
    Final_Pos[2] = Pos[2];
    
    plhs[0] = mxCreateNumericArray(2, NP, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, NP, mxUINT8_CLASS, mxREAL);
    plhs[2] = mxCreateNumericArray(2, SizePos, mxDOUBLE_CLASS, mxREAL);
    
    mxSetData(plhs[0], Macrotimes);
    mxSetData(plhs[1], Channel);
    mxSetData(plhs[2], Final_Pos);

        
}