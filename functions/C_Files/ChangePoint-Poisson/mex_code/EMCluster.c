/***************************************************************************
                         EMCluster.c  -  description
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

void EMCluster( Yi, Ny, Yem, Ng_max, TOL, trace )
double              **Yi;                       // pointer to grouping matrix
       // Yi[:][1], intensity levels between change points
       // Yi[:][2:Ng_max], the group to which it belongs
       // Yi[:][Ng_max+1], number of photons in this group
       // Yi[:][Ng_max+2], time duration of this group
int                 Ny;
struct em_group     Yem;                        // EM cluster results
int                 Ng_max;                     // maximum number of groups
double              TOL;                        // tolerance for EM convergence
int                 trace;                      // debug print flag
{
  int               Ng;
  int               i,j,k;
  double            T;                          // total time
  double            **old_pki;                  // conditional probability of Yi
                                                // belonging to the g-th group
  double            **pki;
  double            delta_pki;                  // change in total Pki
  double            *nk;                        // total number of photons in the k-th group
  double            *pk;                        // probability of getting the k-th group
  double            *yk;                        // mena of the k-th group
  double            *Tk;                        // total time duration of the k-th gorup
  double            n_exp;                      // expected number of photons in EMCluster
  double            poisson;
  double            k_norm;
  double            pki_max;
  int               k_class=0;
  int               iter;
  time_t            time0, time1;

  /*******************************
  *         Initialization       *
  *******************************/
  pki = dmatrix(Ny,Ng_max);
  old_pki = dmatrix(Ny,Ng_max);
  for (j=1,T=0.0; j<=Ny; j++ ) T += Yi[j][Ng_max+2];
  nk = (double *) malloc( (Ng_max+1)*sizeof(double));
  pk = (double *) malloc( (Ng_max+1)*sizeof(double));
  yk = (double *) malloc( (Ng_max+1)*sizeof(double));
  Tk = (double *) malloc( (Ng_max+1)*sizeof(double));

  /*************************************
  * Do EM Clustering for each grouping *
  *************************************/
  for (Ng=2; Ng<=Ng_max; Ng++) {
    printf( "  performing E-M classification for %i groups ...\n", Ng );
    /*******************************
    *      Reset variable values   *
    *******************************/
    for (i=1; i<=Ny; i++) {
      Yem.c[i][Ng] = 0;
      Yem.intensity[i][Ng] = 0.0;
      Yem.prob[i][Ng] = 0.0;
      for (k=1; k<=Ng; k++)
        if ( k==(int) Yi[i][Ng] ) pki[i][k] = 1.0;
        else pki[i][k] = 0.0;
      } // end of for (i<Ny)
    /****************************************************
    * Do EM Clustering iteration for the Ng-th grouping *
    ****************************************************/
    delta_pki = 1.0;
    iter = 0;
    time0 = time((time_t *)NULL);
    while ( delta_pki > TOL ) {
      /**********************************************
      * M-step: maximization of likelihood function *
      **********************************************/
      for (k=1; k<=Ng; k++) {
        for (i=1,Tk[k]=0.0,nk[k]=0.0; i<=Ny; i++) {
          Tk[k] += pki[i][k] * Yi[i][Ng_max+2];
          nk[k] += pki[i][k] * Yi[i][Ng_max+1];
          } // end of for i<Ny
        pk[k] = Tk[k] / T;
        if ( Tk[k] > 0 ) yk[k] = nk[k] / Tk[k];
        else yk[k] = 0.0;
        } // end of for k<Ng
      /*********************************************************
      * E-step: estimation of classification of the i-th point *
      *********************************************************/
      for (i=1; i<=Ny; i++) {
        for (k=1,k_norm=0.0,pki_max=0.0; k<=Ng; k++) {
          n_exp = yk[k]*Yi[i][Ng_max+2]; // <n_i> = <y_k> * Ti
          if ( n_exp > 0 && Yi[i][Ng_max+1] > 0 ) {
            // calculate the probability of detecting Yi[i][Ng_max+1]
            // within the time period of Yi[i][Ng_max+2] if the estimated intensity
            // is yk[k]
            poisson = Yi[i][Ng_max+1]*log(n_exp) - n_exp
                    - gsl_sf_lngamma(Yi[i][Ng_max+1]+1);
            poisson = exp(poisson);
            } // end of if n_exp > 0
          else poisson = 0.0;
          pki[i][k] = pk[k] * poisson; // calculate posterior probability
          /*
          if ( i==10 ) {
            printf( "ni = %e, Ti = %e, <ni> = %e\n", Yi[i][Ng_max+1], Yi[i][Ng_max+2], n_exp );
            printf( "pk[%u] = %e, poisson = %e\n", k, pk[k], poisson );
            }
          */
          if ( pki[i][k] > pki_max ) {
            pki_max = pki[i][k];
            k_class = k;
            }
          k_norm += pki[i][k];
          } // end of for k
        // normalize the posterior probabilities
        for (k=1; k<=Ng; k++) pki[i][k] /= k_norm;
        /*******************************************
        * C-step: classification of the i-th point *
        *******************************************/
        Yem.c[i][Ng] = k_class;
        Yem.intensity[i][Ng] = yk[k_class];
        Yem.prob[i][Ng] = pki[i][k_class];
        } // end of for i
      /*********************************
      * Calculate convergence criteria *
      *********************************/
      for (i=1,delta_pki=0.0; i<=Ny; i++)
        for (k=1; k<=Ng; k++) {
          delta_pki += fabs(pki[i][k]-old_pki[i][k]);
          old_pki[i][k] = pki[i][k];
          }
      time1 = time((time_t *)NULL);
      iter++;
      if (trace==1) printf( "   > Iter %i: delta_pki = %e [%.0f s]\n", iter, delta_pki, difftime(time1,time0) );
      } // end of while ( delta_pki > TOL )
    } // end of for Ng<Ng_max

  /***********************
  * Clean up work space  *
  ***********************/
  free_dmatrix(pki,Ny,Ng_max);
  free_dmatrix(old_pki,Ny,Ng_max);
  free(nk);
  free(pk);
  free(yk);
  free(Tk);

  } // end of EMCluster()


