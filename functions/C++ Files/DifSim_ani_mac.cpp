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

void Simulate_Diffusion(
        __int64_t SimTime,  double *Box,
        double ScanType, double *Step, double *Pixel, double *ScanTicks, int DiffusionStep,
        double *IRFparam, int MI_Bins,
        double *D, double *Pos,
        double *Wr, double *Wz, double *ShiftX, double *ShiftY, double *ShiftZ,
        double *ExP, double *DetP, double *BlP,
        double *LT, double *p_aniso,
        double *Dist, double *sigmaDist, double linkerlength, double *R0, int heterogeneity_step, double *Cross, 
        int n_states, double *k_dyn, int initial_state, int DynamicStep,
        double *Macrotimes, unsigned short *Microtimes, unsigned char *Channel, __int64_t *NPhotons, unsigned char *Polarization, int *final_state,
        unsigned long Time,
        int Map_Type, double *Map)        
{
    /// Counting variable definition
	__int64_t i = 0;
    unsigned char j = 0;
    unsigned char k = 0;
    unsigned char m = 0;
    unsigned char n = 0;
    unsigned char p = 0;
    unsigned char q = 0;
    int s = 0;
    double FRET[4];
    double TRANS[n_states];
    double CROSS[4];
    double prob;
    double LT_RATE;
    
    /// Random number generator
	mt19937 mt; // initialize mersenne twister engine
    mt.seed((unsigned long)time(NULL) + Time); // engine seeding
    //normal distribtion for diffusion
	normal_distribution<double> normal(0.0, 1.0); //mu = 0.0, sigma = 1.0
    /// Generates uniform distributed random number between 0 and 1
    uniform_real_distribution<double> equal_dist(0.0,1.0);
    /// Generates microtimes from IRF
    normal_distribution<double> IRF(IRFparam[0],IRFparam[1]);
    double Ex;
    
    int state = initial_state;
    
    /// Generate anisotropy probability distribution based on microtime
//     double p_par[n_states*4*MI_Bins]; // probability of photon to be detected in parallel channel, based on microtime
//     double r_dummy;
//     /* aniso_param stores the values in order: r0, r_inf, tau_rot, G
//     G must be defined as g_perp/g_par */
//     for (s=0;s<n_states;s++)
//         {
//         for (j=0;j<4;j++){
//             for (i=0;i<MI_Bins;i++)
//             {
//                 r_dummy = (aniso_param[16*s+4*j+0]-aniso_param[16*s+4*j+1])*exp(-i/aniso_param[16*s+4*j+2])+aniso_param[16*s+4*j+1];
//                 p_par[MI_Bins*4*s+MI_Bins*j+i] = (1+2*r_dummy)/((1+2*r_dummy)+aniso_param[16*s+4*j+3]*(1-r_dummy));
//             }
//         }
//     }
    // Initialize interdye distances to center distances
    double R[16*n_states];
    for (j=0;j<16*n_states;j++) {R[j] = Dist[j];}
    // initialize rates
    double Rates[16*n_states];
    for (j=0;j<16*n_states;j++) {
        if (R0[j] > 0) // for no FRET R0 should be 0
        {
        Rates[j] = pow(R0[j]/R[j],6.0); 
        //printf("Rate %i: %f , R %f, R0 %f\n",j,Rates[j],R[j],R0[j]);
        }
        else {Rates[j] = 0;}
    } 
    // make identity matrix for FRET rates donor->donor
    for (s=0;s<n_states;s++) {
        for (j=0;j<4;j++) {
            Rates[16*s+4*j+j] = 1;
            }
        }
    
    /// Sets all colors to active
    bool Active [4] = {true, true, true, true};

    /// Starting point of focus
    double x0 = -Pixel[0]*Step[0]/2;
    double y0 = -Pixel[0]*Step[0]/2;
    /// Initializes focus positions
    double x = 0;
    double y = 0;
    
    /// Variables for current Particle Position
    double New_Pos [3] = {0, 0, 0};
    int New_Index = 0;
    int Old_Index = 0;
    
    /// Toggle for valid particle position
    bool Invalid_Pos = true;
    
    //printf("Starting diffusion sim \n");
    for (i=0; i<SimTime; i++) 
    {
        if ( (i % (__int64_t)DiffusionStep) == 0) { // Only calculate diffusion at larger time intervals
            Invalid_Pos = true;
            while (Invalid_Pos)
            {
                /// Particle movement /////////////////////////////////////////////
                if (Map_Type != 8) /// Standard movement
                {
                    New_Pos[0] = Pos[0] + D[state]*normal(mt); // Go one step in x direction
                    New_Pos[1] = Pos[1] + D[state]*normal(mt); // Go one step in y direction
                }
                else /// Position dependent diffusion
                {
                    Old_Index = (int)(floor(Pos[0]) + Box[0]*floor(Pos[1]));
                    New_Pos[0] = Pos[0] + sqrt(Map[Old_Index])*D[state]*normal(mt); // Go one step in x direction
                    New_Pos[1] = Pos[1] + sqrt(Map[Old_Index])*D[state]*normal(mt); // Go one step in y direction
                }
                if (Box[2] > 0) { New_Pos[2] = New_Pos[2] + D[state]*normal(mt); } // Go one step in z direction, if not 2D
                else { Box[2] = 0; } // Puts particle inside plane

                /// Particle exits border /////////////////////////////////////////
                while ((New_Pos[0] < 0.0) || (New_Pos[0] > Box[0]) || (New_Pos[1] < 0.0) || (New_Pos[1] > Box[1]) || (New_Pos[2] < 0.0) || (New_Pos[2] > Box[2]))
                {
                    // Unbleach on box border crossing
                    for (p = 0; p<4; p++) { Active[p] = true; }
                    // Put particle back on the other side
                    New_Pos[0] = fmod((New_Pos[0] + Box[0]), Box[0]);
                    New_Pos[1] = fmod((New_Pos[1] + Box[1]), Box[1]);
                    if (Box[2] > 0) { New_Pos[2] = fmod((New_Pos[2] + Box[2]), Box[2]) ; }
                }
                switch (Map_Type)
                {
                    case 1: case 2: case 8: /// Free Diffusion
                        Pos[0] = New_Pos[0];
                        Pos[1] = New_Pos[1];
                        Pos[2] = New_Pos[2];
                        Invalid_Pos = false;
                        break;
                    case 3: case 6: /// Diffusion with restricted zones
                        New_Index = (int)(floor(New_Pos[0]) + Box[0]*floor(New_Pos[1]));
                        if (Map[New_Index] != 0) 
                        {
                            Pos[0] = New_Pos[0];
                            Pos[1] = New_Pos[1];
                            Pos[2] = New_Pos[2];
                            Invalid_Pos = false;
                            break;
                        }                    
                    case 4: case 7: /// Transition Barriers with equal directional transition probabilities (Only in 2D)
                        New_Index = (int)(floor(New_Pos[0]) + Box[0]*floor(New_Pos[1]));
                        Old_Index = (int)(floor(Pos[0]) + Box[0]*floor(Pos[1]));

                        /// Only calculates transition probability, if it is <100%
                        if ((Map[New_Index] - Map[Old_Index])==0) { prob = 1; }
                        else { prob = equal_dist(mt); }
                        /// Checks, if particle crosses barrier
                        if  (prob >= abs(Map[New_Index] - Map[Old_Index])) /// Map difference as reflection probability
                        { 
                            Pos[0] = New_Pos[0];
                            Pos[1] = New_Pos[1];
                            Pos[2] = New_Pos[2];
                            Invalid_Pos = false; 
                        } 
                        break;
                    case 5: /// Transition Barriers with unequal directional transition probabilities (Only in 2D)
                        New_Index = (int)(floor(New_Pos[0]) + Box[0]*floor(New_Pos[1]));
                        Old_Index = (int)(floor(Pos[0]) + Box[0]*floor(Pos[1]));

                        /// Only calculates transition probability, if it is <100%
                        if ((Map[New_Index] - Map[Old_Index])==0) { prob = 0; }
                        else { prob = equal_dist(mt); }

                        /// Checks, if particle crosses barrier
                        if ((Map[New_Index] - Map[Old_Index])<0) /// Downward direction => Decimal difference as reflection probability
                        { 
                            if  (prob >= abs((fmod(Map[New_Index],1) - fmod(Map[Old_Index],1)))) 
                            {
                                Pos[0] = New_Pos[0];
                                Pos[1] = New_Pos[1];
                                Pos[2] = New_Pos[2];
                                Invalid_Pos = false;
                            } 
                        }
                        else /// Upward direction => Difference/1000 as reflection probability
                        { 
                            if  (prob >=  ((floor(Map[New_Index]) - floor(Map[Old_Index])) / 10000)) 
                            { 
                                Pos[0] = New_Pos[0];
                                Pos[1] = New_Pos[1];
                                Pos[2] = New_Pos[2];
                                Invalid_Pos = false;
                            } 
                        }  
                        break;
                    default: /// Free Diffusion
                        Pos[0] = New_Pos[0];
                        Pos[1] = New_Pos[1];
                        Pos[2] = New_Pos[2]; 
                        Invalid_Pos = false; 
                        break;
                }
            }
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
        
        /// Dynamic step //////////////////////////////////////////////////
        if (DynamicStep > 0) {
            if (n_states > 1) {
                if ( (i % (__int64_t)DynamicStep) == 0) { // Only calculate dynamic transitions at larger time intervals
                    // calculate cumulative probability from outgoing rates of current state
                    for (s=0;s<n_states;s++) {
                        TRANS[s] = k_dyn[n_states*state+s];
                        }
                    for (s=1; s<n_states; s++) { TRANS[s] = TRANS[s] + TRANS[s-1]; }  /// Calculates cummulative Transition Probabilites
                    prob = equal_dist(mt);
                    for (s=0; s<n_states; s++) /// Determines transition according to rates
                    { if (prob<=TRANS[s]) {break;}  } 
                    state = s; // Update State
                    // printf("State updated: %i\n",state);
                }
            }
        }
        /// Heterogeneity step - Used for simulating conformational heterogeneity (i.e. sigma in PDA) ///
        if (heterogeneity_step > 0) // only execute if heterogeneity step is enabled
        {
            if ( (i % (__int64_t)heterogeneity_step) == 0) // only evaluate at fixed time interval
            { 
                // redraw distances according to distribution
                for (s=0;s<16*n_states;s++) {
                    if (sigmaDist[s] > 0) // only calculate for relevant distances
                    {
                        normal_distribution<double> normal_dist(Dist[s], sigmaDist[s]); //mu = Dist, sigma = sigmaDist
                        R[s] = normal_dist(mt);
                        //printf("State: %i Redrawn distance: %f\n",state,R[s]);
                        // recalculate rates
                        Rates[s] = pow((R0[s]/R[s]),6.0);
                    }
                }
            }
            // printf("Redrawn distances\n");
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
                if (Active[k] && ExP[4*j+k]>0) /// Only calculates, if particle is not bleached and direct excitation enabled
                {
                    /// Calculate absolute excitation probability
                    Ex = ExP[4*j+k]*exp(-2*((Pos[0]-Box[0]/2+ShiftX[j]-x)*(Pos[0]-Box[0]/2+ShiftX[j]-x) /// X
                    + (Pos[1]-Box[1]/2+ShiftY[j]-y)*(Pos[1]-Box[1]/2+ShiftY[j]-y))/(Wr[j]*Wr[j]) ///Y
                    -2*(Pos[2]-Box[2]/2+ShiftZ[j])*(Pos[2]-Box[2]/2+ShiftZ[j])/(Wz[j]*Wz[j])); ///Z
                    
                    /// Calculates quenching efficiency
                    if (Map_Type == 2) 
					{	
						int Index = (int)(floor(Pos[0]) + Box[0]*floor(Pos[1]));
						Ex = Ex * Map[Index]; 
					} 
                    
                    if (Ex > 1E-4) /// Only roll if Excitation is larger than 0.01% = 1E-4
                    {
                        /// Create binomial distribution for excitation probability
                        binomial_distribution<__int64_t> binomial(1, Ex);
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
                                    if (Active[p]) { FRET[p] = Rates[16*state+4*m+p];
                                    } /// Dye is active
                                    else { FRET[p] = 0; } /// Dye is not active
                                } 
                                for (p=m+1; p<4; p++) { FRET[p] = FRET[p] + FRET[p-1]; } /// Extract cummulative FRET rates
                                
                                if (LT[4*state+m]>0)
                                {
                                    if (linkerlength == 0)
                                    {LT_RATE = FRET[3];}
                                    else if (linkerlength > 0)// redraw rates according to linker length distribution
                                    {
                                        for (p=m; p<4; p++) /// Extracts current FRET rates
                                        {
                                            if (Active[p]) {
                                                if (R0[16*state+4*m+p] > 0) { // only recalculate for cross-color elements
                                                    normal_distribution<double> normal_dist(R[16*state+4*m+p], linkerlength); //mu = Dist, sigma = linkerlength
                                                    double R_LT = normal_dist(mt);
                                                    //printf("Redrawn distance for linker fluctuations: %f (State %i)\n",R_LT,state);
                                                    FRET[p] = pow(R0[16*state+4*m+p]/R_LT,6.0);
                                                }
                                                else {FRET[p] =  Rates[16*state+4*m+p];}
                                            }
                                            else { FRET[p] = 0; }
                                            //printf("State: %i, From Dye: %i, To Dye: %i, Rate: %f\n",state,m,p,FRET[p]);
                                        }
                                        for (p=m+1; p<4; p++) { FRET[p] = FRET[p] + FRET[p-1]; } /// Extract cummulative FRET rates
                                        LT_RATE = FRET[3];
                                        //printf("State: %i Lifetime Rate: %f\n",state, LT_RATE);
                                    }
                                    // printf("LT Rate: %f\n",LT_RATE/LT[4*state+m]);
                                    geometric_distribution<unsigned short> exponential(LT_RATE/LT[4*state+m]); /// FRET modified exponential distribution for lifetime
                                    Microtimes[NPhotons[0]] += exponential(mt); /// Convolutes with lifetime of current dye
                                }
                                
                                if ((FRET[3]-1) > 1E-4) /// FRET is feas?ble
                                {
                                    for (p=m; p<4; p++) { FRET[p] = FRET[p]/FRET[3]; 
                                    //printf("State: %i, From Dye: %i, To Dye: %i, Prob: %f\n",state,m,p,FRET[p]);
                                    } 

                                    prob = equal_dist(mt);
                                    for (p=m; p<4; p++) /// Determines em. dye according to rates
                                    { if (prob<=FRET[p]) { break; } }
                                    
                                    if  (p == m) { break; } /// No FRET occured
                                    else { m = p; } /// FRET occured; next round of checks starts
                                }
                                else { break; } /// No FRET can occure, therefore ex.dye = em.dye
                            }
                            // Microtime checkup
                            Microtimes[NPhotons[0]] %= MI_Bins;
                            // Evaluate Anisotropy
                            //printf("State %i, MI %i, aniso %f\n",state,Microtimes[NPhotons[0]],p_aniso[MI_Bins*4*state+MI_Bins*m+(int)Microtimes[NPhotons[0]]]);
                            binomial_distribution<unsigned char> binomial_aniso(1,p_aniso[MI_Bins*4*state+MI_Bins*m+(int)Microtimes[NPhotons[0]] ]); //define distribution
                            Polarization[NPhotons[0]] = 1-binomial_aniso(mt); // 0 -> par, 1 -> per
                            // convolute Microtime with IRF
                            Microtimes[NPhotons[0]] += (unsigned short)IRF(mt); /// PIE Laser pulse for microtime, IRF
                            Microtimes[NPhotons[0]] += (unsigned short)(j*(int)(MI_Bins/4)); /// PIE Laser pulse for microtime
                            if (Microtimes[NPhotons[0]] < 1) {Microtimes[NPhotons[0]] = 1;};
                            // Microtime checkup
                            Microtimes[NPhotons[0]] %= MI_Bins;
                            // printf("Emitted after excitation: %i Microtime: %i, Pol: %i\n",j,Microtimes[NPhotons[0]],Polarization[NPhotons[0]]);
                            if (BlP[m] > 0.0) /// If bleaching is enabled
                            {
                                binomial_distribution<__int64_t> binomial(1, BlP[4*k+m]);
                                if ( ((double) binomial(mt)) ) /// Bleaches particle
                                { Active[m] = false; }
                                
                            }
                            if (Active[m]) // If particle doesn't bleach
                            {                                
                                ///////////////////////////////////////////
                                /// Determines detection channel //////////
                                ///////////////////////////////////////////
                                for (p=0; p<4; p++) { CROSS[p] = Cross[4*m+p]; } /// Extracts crosstalk rates
                                for (p=1; p<4; p++) { CROSS[p] = CROSS[p] + CROSS[p-1]; } /// Extracts cummulative crosstalk rates
                                
                                if ((CROSS[3]-1) > 1E-5) /// Crosstalk is realistic
                                {
                                    for (p=0; p<4; p++) { CROSS[p] = CROSS[p]/CROSS[3]; }  /// Calculates cummulative detection probabilites
                                    prob = equal_dist(mt);
                                    for (n=0; n<4; n++) /// Determines detection color
                                    { if (prob<=CROSS[n]) { break; } }
                                }
                                else { n = m; } /// No crosstalk, therefore detection channel == emitting dye                                
                                
                                ///////////////////////////////////////////
                                /// Determines, if photon was emitted/detected
                                ///////////////////////////////////////////
                                if (DetP[4*m+n] > 1E-5)
                                {
                                    binomial_distribution<__int64_t> binomial(1, DetP[4*m+n]);
                                    if ( ((double) binomial(mt)) ) /// Detects particle
                                    {
                                        /// Adds photon
                                        Macrotimes[NPhotons[0]] = (double) i;
                                        // 2 bits each for:    laser      ex. dye    em. dye    det.
                                        Channel[NPhotons[0]] = (j << 6) | (k << 4) | (m << 2) | n ;
                                        NPhotons[0]++;
                                    }
                                }
                                else if (DetP[4*m+n] >= 1)
                                {
                                    /// Adds photon
                                    Macrotimes[NPhotons[0]] = (double) i;
                                    // 2 bits each for:    laser      ex. dye    em. dye    det.
                                    Channel[NPhotons[0]] = (j << 6) | (k << 4) | (m << 2) | n ;
                                    NPhotons[0]++;
                                }
                            }
                            Microtimes[NPhotons[0]] = 0; /// Resets microtime, if no photons were detected 
                        }
                    }
                }
            }
        }
    }
    final_state[0] = state;
}
///////////////////////////////////////////////////////////////////////////
/// Defines input parameter and function to be used ///////////////////////
/// This function is called by matlab /////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{    
    if(nrhs!=34)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","34 inputs required."); }
    if (nlhs!=6)
    { mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","6 outputs required."); }
    
    
    // General and Scanning parameters
    __int64_t SimTime = (__int64_t)mxGetScalar(prhs[0]);
    double *Box = mxGetPr(prhs[1]);
    double ScanType = mxGetScalar(prhs[2]);
    double *Step = mxGetPr(prhs[3]);
    double *Pixel = mxGetPr(prhs[4]);
    double *ScanTicks = mxGetPr(prhs[5]);
    int DiffusionStep = mxGetScalar(prhs[6]);
    
    // IRF Parameters
    double *IRFparam = mxGetPr(prhs[7]);
    int MI_Bins = mxGetScalar(prhs[8]);
    
    // Particle Parameters
    double *D = mxGetPr(prhs[9]);  
    double *Pos = mxGetPr(prhs[10]);

    // Color Parameters
    double *Wr = mxGetPr(prhs[11]);
    double *Wz = mxGetPr(prhs[12]);
    double *ShiftX = mxGetPr(prhs[13]);
    double *ShiftY = mxGetPr(prhs[14]);
    double *ShiftZ = mxGetPr(prhs[15]);
    double *ExP = mxGetPr(prhs[16]);
    double *DetP =  mxGetPr(prhs[17]);
    double *BlP = mxGetPr(prhs[18]);
    double *LT = mxGetPr(prhs[19]);
    double *p_aniso = mxGetPr(prhs[20]);
    double *Dist =  mxGetPr(prhs[21]);
    double *sigmaDist = mxGetPr(prhs[22]);
    double linkerlength = mxGetScalar(prhs[23]);
    double *R0 = mxGetPr(prhs[24]);
    int heterogeneity_step = mxGetScalar(prhs[25]);
    double *Cross = mxGetPr(prhs[26]);
    
    // Dynamic Parameters
    int n_states = mxGetScalar(prhs[27]);
    double *k_dyn = mxGetPr(prhs[28]);
    int initial_state = mxGetScalar(prhs[29]);
    int DynamicStep = mxGetScalar(prhs[30]);
    
    unsigned long Time = mxGetScalar(prhs[31]);
    
    int Map_Type = mxGetScalar(prhs[32]); 
    double *Map = mxGetPr(prhs[33]);    
    

    double *Macrotimes;
    Macrotimes = (double*) mxCalloc(4*SimTime, sizeof(double));
    unsigned short *Microtimes;
    Microtimes = (unsigned short*) mxCalloc(4*SimTime, sizeof(unsigned short));
    unsigned char *Channel;
    Channel = (unsigned char*) mxCalloc(4*SimTime, sizeof(unsigned char));
    unsigned char *Polarization;
    Polarization = (unsigned char*) mxCalloc(4*SimTime, sizeof(unsigned char));   
    __int64_t *NPhotons;
    NPhotons=(__int64_t*) mxCalloc(1, sizeof(__int64_t));
    int *final_state;
    final_state = (int*) mxCalloc(1, sizeof(int));
    
    //printf("Starting main function\n");
    
    Simulate_Diffusion(
        SimTime, Box, // General parameters
        ScanType, Step, Pixel, ScanTicks, // Scanning parameters
        DiffusionStep,
        IRFparam, MI_Bins, //
        D, Pos, // Particle parameters
        Wr, Wz, ShiftX, ShiftY, ShiftZ, // Focus parameters
        ExP, DetP, BlP, // Excitation, Detection and Bleching Probabilities
        LT, p_aniso, // Lifetime, Anisotropy
        Dist, sigmaDist, linkerlength, R0, heterogeneity_step, Cross, // Parameter containing FRET/Crosstalk rates
        n_states, k_dyn, initial_state, DynamicStep, // Dynamic parameters
        Macrotimes, Microtimes, Channel, NPhotons, Polarization, final_state,// Output parameters
        Time, // Additional random seed value
        Map_Type, Map); // Map for quenching/barriers etc.
        
    const mwSize NP[]={(int)NPhotons[0],1};
    const mwSize SizePos[]={3,1};
    const mwSize SizeInt[]={1,1};
    
    double* Final_Pos;
    Final_Pos =(double*) mxCalloc(3, sizeof(double));
    Final_Pos[0] = Pos[0];
    Final_Pos[1] = Pos[1];
    Final_Pos[2] = Pos[2];
    
    plhs[0] = mxCreateNumericArray(2, NP, mxDOUBLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericArray(2, NP, mxUINT16_CLASS, mxREAL);
    plhs[2] = mxCreateNumericArray(2, NP, mxUINT8_CLASS, mxREAL);
    plhs[3] = mxCreateNumericArray(2, NP, mxUINT8_CLASS, mxREAL);
    plhs[4] = mxCreateNumericArray(2, SizePos, mxDOUBLE_CLASS, mxREAL);
    plhs[5] = mxCreateNumericArray(2, SizeInt, mxUINT8_CLASS, mxREAL);
    
    mxSetData(plhs[0], Macrotimes);
    mxSetData(plhs[1], Microtimes);
    mxSetData(plhs[2], Channel);
    mxSetData(plhs[3], Polarization);
    mxSetData(plhs[4], Final_Pos);
    mxSetData(plhs[5], final_state);
        
}