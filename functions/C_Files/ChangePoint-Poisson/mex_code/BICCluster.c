/***************************************************************************
                        BICCluster.c  -  description
                             -------------------
    begin coding                : Tue Jan 27 14:25:30 PST 2004
    peer-reviewed publication   : J. Phys. Chem. B, 109, 617-628 (2005)
    code initial public release : 2020
    copyright                   : © Haw Yang 2020
    email                       : hawyang@princeton.edu
***************************************************************************/

// Change log (for public release):
// 20200811: (HY) Start code clean up for v2.00 initial public release.

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include <time.h>
#include <gsl/gsl_sf_gamma.h>
#include "changepoint.h"

#define N_PARM 2                                // number of parameters in estimation
                                                // they are pk and yk in this case

void BICCluster( Yi, Ny, Yem, Ng_max, Yim, Nym, bic, trace )
double              **Yi, **Yim;                // pointer to grouping matrix
       // Yi[:][1], intensity levels between change points
       // Yi[:][2:Ng_max], the group to which it belongs
       // Yi[:][Ng_max+1], number of photons in this group
       // Yi[:][Ng_max+2], time duration of this group
       // Yi[:][Ng_max+3], uncertainties in time duration of this group
int                 Ny, *Nym;
struct em_group     Yem;                        // EM cluster results
int                 Ng_max;                     // maximum number of groups
double              *bic;                       // Bayesian information number of grouping
int                 trace;                      // debug print flag
{
  int               i,j,k;
  int               G=1;                        // number of groups
  double            T=0.0;                      // total time duration
  double            N=0.0;                      // total number of photons
  double            poisson;
  double            I0;                         // mean intensity for the entire traj
  double            n_exp;                      // expected number of photons
  double            ll;                         // log likelihood
  int		    d;				// dimension of model

  /*******************************
  *         Initialization       *
  *******************************/
  for (k=1; k<=Ng_max; k++) bic[k] = 0.0;
  for (j=1,T=0.0,N=0.0; j<=Ny; j++ ) {
    N += Yi[j][Ng_max+1];
    T += Yi[j][Ng_max+2];
    }
  /*******************************
  *       BIC for 1 group        *
  *******************************/
  I0 = N/T;
  for (i=1,ll=0.0,d=0; i<=Ny; i++) {
    n_exp = I0*Yi[i][Ng_max+2];
    poisson = Yi[i][Ng_max+1]*log(n_exp) - n_exp
            - gsl_sf_lngamma(Yi[i][Ng_max+1]+1);
    ll += poisson;
    }
  G = 1;
  bic[G] = 2.0*(ll-0.5*(-1+N_PARM*G)*log(Ny));
  /*******************************
  *   BIC for more than 1 group  *
  *******************************/
  for (G=2; G<=Ng_max; G++) {
    for (i=1,ll=0.0,d=0; i<=Ny; i++) {
      n_exp = Yem.intensity[i][G] * Yi[i][Ng_max+2];
      poisson = Yi[i][Ng_max+1]*log(n_exp) - n_exp
              - gsl_sf_lngamma(Yi[i][Ng_max+1]+1);
      //ll += log(Yem.prob[i][G])+poisson;
      ll += poisson;
      if((i>1)&&(Yi[i][G]!=Yi[i-1][G]))
        d++;
      }
//    bic[G] = 2.0*(ll-0.5*(-1+N_PARM*G)*log(Ny));
    bic[G] = 2.0*(ll-0.5*(-1+N_PARM*G)*log(d)-0.5*d*log(N));
    }
  }
