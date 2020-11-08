/***************************************************************************
                          CheckCP.c  -  description
                             -------------------
    begin coding                : Tue Jan 27 14:25:30 PST 2004
    peer-reviewed publication   : J. Phys. Chem. B, 109, 617-628 (2005)
    code initial public release : 2020
    copyright                   : © Haw Yang 2020
    email                       : hawyang@princeton.edu
***************************************************************************/

// Change log (for public release):
// 20200811: (HY) Start code clean up for v2.00 initial public release.

// References:
// 1. "A problem with the likelihood ratio test for a change-point hazard rate model,"
//    Robin Henderson, Biometrika, 77, 835-843 (1990).
//
// Change Log:
// 20130919: (DPR) Bug fix at line ca. 78 by Ducan P. Ryan for potential inifinite loop  
//                 caused by change-point intervals greater than Na window size.
// 20120512: (AvA) Implement a bug fix at line ca. 115, credited to Arno van Amersfoort
//

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <gsl/gsl_sf_erf.h>
#include <gsl/gsl_math.h>
#include "changepoint.h"

void CheckCP(cp_root, traj, alpha, beta, N, Ncpdlt, trace, ta, ca, Na )
struct changepoint  **cp_root;
struct data         *traj;
double              alpha, beta;
double              *ta, *ca;
int                 *Ncpdlt;
size_t              N, Na;
int                 trace;
{
  size_t			winl, winr, last_winl, last_winr=0;
  size_t            *cps=NULL, *cpsl=NULL, *cpsr=NULL, cp1;
  int               Ncp=0, Ny=0, Ny2=0;
  size_t            i, istart=1, iend=0;
  enum bool         deletion_adjustment=true, h=false;

  // create an array, cps[], to store data
  *Ncpdlt=0;
  while(deletion_adjustment){
    deletion_adjustment=false;
    MakeCPArray( *cp_root, &cps, &cpsl, &cpsr, &Ncp );
    cps = (size_t *) realloc( cps, (Ncp+2)*sizeof(size_t) );
    cps[0] = 0;
    cps[Ncp+1] = N;

    cpsl = (size_t *) realloc( cpsl, (Ncp+2)*sizeof(size_t) );
    cpsl[0] = 0;
    cpsl[Ncp+1] = N;

    cpsr = (size_t *) realloc( cpsr, (Ncp+2)*sizeof(size_t) );
    cpsr[0] = 0;
    cpsr[Ncp+1] = N;

    if(iend>1)
      istart=iend;
    else
      istart=1;
	//printf("%i\n",istart);

    for(i=istart;i<Ncp+1;i++){
      DeleteCPNode(cps[i],cp_root,&h);
      Ncp--;
      if(cps[i]<cpsr[i-1]){
        deletion_adjustment=true;
        (*Ncpdlt)++;
        break;
        }
	  /*
	  added: 9/19/2013
	  author: Duncan P Ryan
	  */
	  if (cps[i+1]-cps[i-1]-1 < Na) { // fix segment fault associated with addressing ta and ca out of range with window
		winl = cps[i-1]+1;
		winr = cps[i+1]-1;
		}
	  else { // unless window endpoints are fixed, possibility of a changepoint at slightly different location will cause infinite loop
	    if (last_winr==0) { // only use cps[i] as a reference location for the first time a windowed changepoint is checked
		  if (cps[i]-Na/2 < cps[i-1]+1) {
		    winl = cps[i-1]+1;
			winr = winl + Na;
			}
		  else if (cps[i]+Na/2 > cps[i+1]-1) {
		    winr = cps[i+1]-1;
			winl = winr - Na;
			}
		  else {
		    winl = cps[i]-Na/2;
			winr = winl + Na;
		    }
		  }
		else {
		  winl = last_winl;
		  winr = last_winr;
		  }
	    }
	  /*
	  end addition
	  */
	  cp1=FindCP(cp_root,traj,winl,winr,alpha,beta,&Ncp,ta,ca,Na,3); 
      if (cp1==0){
        printf("    %lu/%i Checking node %lu %lu %lu...",(long unsigned int) i,Ncp,(long unsigned int) winl, (long unsigned int) cps[i], (long unsigned int) winr);
        printf("not found! RESTARTING\n");
        deletion_adjustment=true;
        (*Ncpdlt)++;
        iend = (i > 10) ? i : 10; // bug fix credited to Arno van Amersfoort
        last_winr=0; // clear window
        break;
        }
      else if(cp1!=cps[i]){
        printf("    %lu/%i Checking node %lu %lu %lu...",(long unsigned int) i,Ncp,(long unsigned int) winl, (long unsigned int) cps[i], (long unsigned int) winr);
        printf("found at %lu.\n",(long unsigned int) cp1);
        deletion_adjustment=true;
        iend=i;
        break;
        }
        last_winr=0; // clear window
      }
    free(cps);
    free(cpsl);
    free(cpsr);
    cps=NULL;
    cpsl=NULL;
    cpsr=NULL;
    Ncp=0;
    }
}

