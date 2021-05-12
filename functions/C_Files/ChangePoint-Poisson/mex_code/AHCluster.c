/***************************************************************************
                         AHCluster.c  -  description
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
#include "changepoint.h"

void delta();

void AHCluster( traj, N, cp_root, Yi, Ny, Ng_max, trace )
struct data         *traj;
struct changepoint  *cp_root;
size_t              N;                          // total number of data points
double              **Yi;                       // pointer to grouping matrix
                    // Yi[:][1], intensity levels between change points
                    // Yi[:][2:Ng_max], the group to which it belongs
                    // Yi[:][Ng_max+1], number of photons in this group
                    // Yi[:][Ng_max+2], time duration of this group
                    // Yi[:][Ng_max+3], uncertainties in time duration of this group
int                 Ny;                         // number of intensity levels
int                 Ng_max;                     // maximum number of groups
int                 trace;                      // debug print flag
{
  size_t            *cps=NULL;                  // change point array
  size_t            *cpsl=NULL, *cpsr=NULL;   
  int               Ncp=0;                      // number of change points
  size_t            i,j,ni;
  double            Ti;                         // time span of the i-th change point state
  double            dT1, dT2;                   // uncertainties in time span
  int               Ng;                         // number of groups
  size_t            ii,jj;                      // indices for the two merging groups
  struct group      *g;                         // pointer to an array of group
  size_t            *member_tmp;

  /***************************************
  *  create an array cps[] to store data *
  ***************************************/
  MakeCPArray( cp_root, &cps, &cpsl, &cpsr, &Ncp );
  printf("  Ncp: %i",Ncp);
  cps = (size_t *) realloc( cps, (Ncp+2)*sizeof(size_t) );
  cps[0] = 0;
  cps[Ncp+1] = N;

  /*********************************
  *  assign intensity levels to Yi *
  *********************************/
  Ti = traj[cps[1]].time - traj[cps[0]].time;
  Yi[1][1] = cps[1]/Ti;
  Yi[1][Ng_max+1] = cps[1];
  Yi[1][Ng_max+2] = Ti;
  Yi[1][Ng_max+3] = traj[cpsr[1]].time - traj[cpsl[1]].time;
  for (i=2;i<=Ncp;i++) {
    Ti = traj[cps[i]].time - traj[cps[i-1]].time;
    dT1 = traj[cpsr[i-1]].time - traj[cpsl[i-1]].time;
    dT2 = traj[cpsr[i]].time - traj[cpsl[i]].time;
    ni = cps[i] - cps[i-1];
    Yi[i][1] = ni/Ti;
    Yi[i][Ng_max+1] = ni;
    Yi[i][Ng_max+2] = Ti;
    Yi[i][Ng_max+3] = sqrt(dT1*dT1+dT2*dT2);
    }
  Ti = traj[cps[Ny]].time - traj[cps[Ncp]].time;
  ni = cps[Ny] - cps[Ncp];
  Yi[Ny][1] = ni/Ti;
  Yi[Ny][Ng_max+1] = ni;
  Yi[Ny][Ng_max+2] = Ti;
  Yi[Ny][Ng_max+3] = traj[cpsr[Ncp]].time - traj[cpsl[Ncp]].time;

  /*******************************************
  *  create working space and initialization *
  *******************************************/
  Ng = Ny;                                      // number of groups
  g = (struct group *) malloc( (Ng+1)*sizeof(struct group) );
  for (i=1; i<=Ng; i++) {
    g[i].n = Yi[i][Ng_max+1];
    g[i].T = Yi[i][Ng_max+2];
    g[i].dT = Yi[i][Ng_max+3];
    g[i].m = 1;
    g[i].member = (size_t *) malloc( 2 * sizeof(size_t) );
    g[i].member[1] = i;
    }
  
  /**********************************************************
  *  agglomerative hierachical clustering without recording *
  **********************************************************/
  while ( Ng > Ng_max ) {
    // find the merging pairs, ii and jj, ii < jj
    delta( &ii, &jj, g, Ng );
    if (trace==1) printf( "  (%lu,%lu) merged\n", (long unsigned int) ii, (long unsigned int) jj );
    // merge the jj-th group into the ii-th group
    for (j=1; j<=g[jj].m; j++) {
      g[ii].member = (size_t *) realloc(g[ii].member,(g[ii].m+1+j)*sizeof(size_t) );
      g[ii].member[g[ii].m+j] = g[jj].member[j];
      } // for j
    g[ii].T = g[ii].T + g[jj].T;
    g[ii].n = g[ii].n + g[jj].n;
    g[ii].m = g[ii].m + g[jj].m;
    g[ii].dT = sqrt(g[ii].dT*g[ii].dT + g[jj].dT*g[jj].dT);
    member_tmp = g[jj].member;
    for (j=jj; j<Ng; j++) g[j] = g[j+1];
    // Note: This sometimes caused an error "pointer being freed was not allocated", so it was commented here
    //free( member_tmp ); // release the memory occupied by the jj.member
    Ng--;
    } // while Ng
  
  /******************************************************************
  *  continue agglomerative hierachical clustering and save results *
  ******************************************************************/
  while ( Ng > 1 ) {
    // save the results to Yi
    for (j=1; j<=Ng; j++)
      for (i=1; i<=g[j].m; i++)
        Yi[g[j].member[i]][Ng] = j;
    // find the merging pairs, ii and jj, ii < jj
    delta( &ii, &jj, g, Ng );
    if (trace==1) printf( "  (%lu,%lu) merged\n", (long unsigned int) ii, (long unsigned int) jj );
    // merge the jj-th group into the ii-th group
    for (j=1; j<=g[jj].m; j++) {
      g[ii].member = (size_t *) realloc(g[ii].member,(g[ii].m+1+j)*sizeof(size_t) );
      g[ii].member[g[ii].m+j] = g[jj].member[j];
      } // for j
    g[ii].T = g[ii].T + g[jj].T;
    g[ii].n = g[ii].n + g[jj].n;
    g[ii].m = g[ii].m + g[jj].m;
    g[ii].dT = sqrt(g[ii].dT*g[ii].dT + g[jj].dT*g[jj].dT);
    member_tmp = g[jj].member;
    for (j=jj; j<Ng; j++) g[j] = g[j+1];
    // Note: This sometimes caused an error "pointer being freed was not allocated", so it was commented here
    //free( member_tmp ); // release the memory occupied by the jj.member
    Ng--;
    } // while Ng > 1

  free(g); // release the work space
  free(cps);
  free(cpsr);
  free(cpsl);
  } // end of AHCluster()

void delta(ii,jj,g,Ng)
size_t       *ii,*jj;
struct group *g;
int          Ng;
{
  double     dta, dta_min;
  double     nij, Tij;
  size_t     i,j,tmp;

  for (i=1,dta_min=DBL_MAX; i<=Ng; i++) {
    for (j=i+1;j<=Ng;j++) {
      Tij = g[i].T + g[j].T;
      nij = g[i].n + g[j].n;    
      dta = g[i].n*log(g[i].n/g[i].T) +
            g[j].n*log(g[j].n/g[j].T) -
            nij*log(nij/Tij);
      if ( dta < dta_min ) {
        *ii = i;
        *jj = j;
        dta_min = dta;
        }
      }
    }
    if ( (*jj) < (*ii) ) {
      // swap
      tmp = *jj;
      *jj = *ii;
      *ii = tmp;
      }
  }

