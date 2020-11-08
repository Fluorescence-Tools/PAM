/***************************************************************************
                          FindCP.c  -  description
                             -------------------
    begin coding                : Tue Jan 27 14:25:30 PST 2004
    peer-reviewed publication   : J. Phys. Chem. B, 109, 617-628 (2005)
    code initial public release : 2020
    copyright                   : © Haw Yang 2020
    email                       : hawyang@princeton.edu
***************************************************************************/

// Change log (for public release):
// 20200811: (HY) Start code clean up for v2.00 initial public release.
//
// References:
// 1. "A problem with the likelihood ratio test for a change-point hazard rate model,"
//    Robin Henderson, Biometrika, 77, 835-843 (1990).
//

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <stdio.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_sf_gamma.h>
#include <gsl/gsl_sf_erf.h>
#include "changepoint.h"

#define MAX_X 10.0
#define DX    0.01
#define TOL   1.0e-8

double C_ac();
double Vostrikova();

size_t FindCP( cp, traj, cpl, cpr, alpha, beta, Ncp, ta, ca, Na, rc )
struct changepoint  **cp;
struct data         *traj;
size_t              cpl, cpr;                   // change point left and right index
size_t              Na;                         // size of ta and ca
double              alpha, beta;
int                 *Ncp;
double              *ta;                        // tabulated critical region
double              *ca;                        // tabulated confidence interval threshold
int                 rc;				// recurse on failure (0,1)
{
  size_t            n,i,k,k_max;
  size_t            LB, RB;                     // left and right bounds of confidence region
  size_t            cp2=0, cp1=0, cp_max;       // largest change point in absolute index
  double            T, kL, iL, nL, term, Vk;
  double            critical_region, *llrt, llrt_max=0.0;
  double            *Tk, lambda0, *lambda1, *lambda2;
  double            *u, *u1, *v2, *v21, *sk;
  enum bool         dummy_bool = false;
  static int dcnum=0;
  n = cpr - cpl;
  LB = cpl;
  RB = cpr;
  cp_max = 0;
  if ( n > 1 ) {
    // create work space
    Tk = (double *) malloc( (n+1) * sizeof(double) );
    lambda1 = (double *) malloc( (n+1) * sizeof(double) );
    lambda2 = (double *) malloc( (n+1) * sizeof(double) );
    llrt = (double *) malloc( (n+1) * sizeof(double) );
    u = (double *) malloc( n * sizeof(double) );
    u1 = (double *) malloc( n * sizeof(double) );
    v2 = (double *) malloc( n * sizeof(double) );
    v21 = (double *) malloc( n * sizeof(double) );
    sk = (double *) malloc( n * sizeof(double) );
    // total time in this trajectory segment
    T = traj[cpr].time - traj[cpl].time;
    lambda0 = (double) n / T + DBL_EPSILON;
    // calculate the critical region
    //critical_region = C_ac(alpha,n); // use Horvath's approximation
    critical_region = ta[n];         // use Henderson's statistic
    // compute expection values and standard deviations
    for (i=1; i<n; i++)
      u[i] = u1[i] = v2[i] = v21[i] = 0.0;
    for (i=1; i<n; i++) {
      iL = (double) i;
      for (k=i; k<n; k++) {
        kL = (double) k;
        u[i] -= 1.0/kL;                         // expection value for log(Vk)
        v2[i] += 1.0/kL/kL;                     // variance for [log(Vk)]^2
        }
      }
    for (i=1; i<n; i++) {
      u1[n-i] = u[i];                           // expection value for log(1-Vk)
      v21[n-i] = v2[i];                         // variance for [log(1-Vk)]^2
      }
    nL = (double) n;
    term = M_PI*M_PI/6.0-v2[1];
    for (i=1; i<n; i++) {
      iL = (double) i;
      sk[i] = 4.0*iL*iL*v2[i]+4.0*(nL-iL)*(nL-iL)*v21[i]-8.0*iL*(nL-iL)*term;
      sk[i] = sqrt(sk[i]);
      }
    for ( k=1,k_max=0; k<n; k++ ) {
      kL = (double) k;
      Tk[k] = traj[cpl+k].time - traj[cpl].time;

      // Henderson's standardization
      Vk = Tk[k] / T;
      llrt[k] = (-2.0*kL*log(Vk)+2.0*kL*u[k]-2.0*(nL-kL)*log(1.0-Vk)
                +2.0*(nL-kL)*u1[k])/sk[k]+0.5*log(4.0*kL*(nL-kL)/nL/nL);
      // traditional Generalized Log-likelihood ratio test
      /*
      lambda1[k] = kL / Tk[k] + DBL_EPSILON;
      lambda2[k] = (nL-kL) / (T-Tk[k]) + DBL_EPSILON;
      llrt[k] = (double) k*log(lambda1[k]) + (double) (n-k)*log(lambda2[k])
              - (double) n*log(lambda0);
      llrt[k] = 2.0 * llrt[k];
      */
      if ( llrt[k] > llrt_max ) {
        // find the maximum of the likelihood functions
        llrt_max = llrt[k];
        k_max = k;
        }
      }
    if ( llrt_max > critical_region ) {
      // max{llrt} is the change point
      // find the confidence interval, threshold given by ca
      // find the left-hand bound
      k = k_max;
      while ( (k>0) && (llrt[k]+ca[n]-llrt_max > 0) ) k--;
      LB = k;
      // find the right-hand bound
      k = k_max;
      while ( (k<n) && (llrt[k]+ca[n]-llrt_max > 0) ) k++;
      RB = k;
      cp_max = RB+cpl;
      // record this change point
      AddCPNode( k_max+cpl, LB+cpl, RB+cpl, cp, &dummy_bool );
      (*Ncp)++;
      if(rc==3){
        free(Tk);
        free(lambda1);
        free(lambda2);
        free(llrt);
        free(u);
        free(u1);
        free(v2);
        free(v21);
        free(sk);
        return k_max+cpl;
        }
      if((rc==1)||(rc==0)){
        // recursively go on to the left branch
        cp1 = FindCP( cp, traj, cpl, LB+cpl, alpha, beta, Ncp, ta, ca, Na, 1 );
        // recursively go on to the right branch
        cp1 = FindCP( cp, traj, RB+cpl, cpr, alpha, beta, Ncp, ta, ca, Na, 1 );
        if ( cp1 > cp_max ) cp_max = cp1;
        }
      }
    else if(rc==1){
      for(i=cpl+1;i<cpr-1;i+=1){
        cp1 = FindCP( cp, traj, cpl, i, alpha, beta, Ncp, ta, ca, Na, 0 );
        if(cp1>0) {
          cp2 = FindCP( cp, traj, cp1, cpr, alpha, beta, Ncp, ta, ca, Na, 1 );
          break;
          }
        }
        if ( cp1 > cp_max ) cp_max = cp1;
        if ( (cp2 > cp_max)&&(cp2>cp1) ) cp_max = cp2;
      }
    // free up work space
    free(Tk);
    free(lambda1);
    free(lambda2);
    free(llrt);
    free(u);
    free(u1);
    free(v2);
    free(v21);
    free(sk);
    } // end of if n > 1
  if(rc==3) cp_max=0;
  return cp_max;
  } // end of FindCP()
