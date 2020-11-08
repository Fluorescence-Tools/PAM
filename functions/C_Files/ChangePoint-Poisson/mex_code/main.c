/***************************************************************************
                            main.c  -  description
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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <float.h>
#include <gsl/gsl_version.h>
#include "changepoint.h"
#include "critical_values.h"

#define TOL 1.0e-10

int main(int argc, char *argv[])
{
  FILE          *fpin, *fpout;
  char          in_name[255], out_name[255], *endptr[255], filename[255], dummy_str[255];
  char          buffer[65536];                  // input buffer
  char          *pch;                           // a pointer for strtok operation
  double        alpha=0.075;                    // Type-I error, mis-specify transition
  double        beta=0.314598;                  // Type-II error, miss transition
  double        delta_t=50e-9;                  // time unit of the first column, interphoton duration
  size_t        N;                              // total number of photons
  size_t        N_ta;                           // total number of ta
  size_t        N_ca;                           // total number of ca
  size_t        Na;                             // Na = min(N_ta, N_ca);
  size_t        cpl;                            // FindCP left start
  size_t        cpr;                            // FindCP right end
  size_t        cp1;
  double        T;                              // total length in time
  int           Ngmax;                          // maximum number of states
  int           Ncp=0;                          // total number of change points
  int           Ncpdlt=0;                       // total number of spurious change points deleted
  int           Ny=0;                           // number of intensity levels
  int           *Nym;                           // number of intensity levels after merging EM results
  double        dt;                             // variable for inter-photon duration
  double        **Yi, **Yim;                    // intensity
  struct data   *traj=NULL;                     // trajectory
  struct changepoint *cp_root=NULL;             // to change point binary tree structure
  struct em_group Yem;                          // expectation-maximization classification
  time_t        time0, time1;                   // variables for timing
  int           i,j;                            // dummy index
  size_t        ui;                             // dummy index
  int           trace=0;                        // debug flag
  double        *bic;                           // Bayesian information number
  double        *ta=NULL;                       // critical region threshold for change point detection
  double        *ca=NULL;                       // critical region threshold for confidence interval
  double        bic_max;
  int           g_max=0;
  enum bool     done;

  /*******************************
  *  Get command line arguments  *
  *******************************/
  if (argc != 6) {
    // No file name entered in the command line
    printf( "\nchangepoint %s%s build %s (GSL version %s)\n",
            CHANGEPOINT_VERSION, PLATFORM, COMPILE_DATE, GSL_VERSION );
    printf( "Syntax : changepoint.exe filename delta_t alpha beta Ngmax\n" );
    printf( "Example: changepoint myfile 50e-9 0.05 0.69 5\n" );
    printf( "         produces myfile.cp with type-I error (alpha) of 5%% and \n" );
    printf( "         a selection confidence interval of 0.69. The maximum possible number\n" );
    printf( "         of states is 5. The units for the first data column, the inter-photon\n");
    printf( "         duration is 50 ns.\n" );
    printf( "BUG    : Please send emails to hawyang-at-princeton.edu\n\n" );
    //scanf( "%s\n", dummy_str );
    exit(1);
    }
  else if (argc == 6) {
    // Set the output filename
    strcpy( in_name, argv[1] );
    strcpy( out_name, argv[1] );
    delta_t = strtod( argv[2], endptr );
    alpha = strtod( argv[3], endptr );
    beta = strtod( argv[4], endptr );
    Ngmax = atoi( argv[5] );
    }
  //printf("%i\n",Ngmax);
  /*******************************
  *          Print Title         *
  *******************************/
  printf( "\n" );
  printf( "*******************************************************************\n");
  printf( "* Photon by photon change point localization and state resolution *\n");
  printf( "*******************************************************************\n");
  printf( "Version: %s%s build %s (GSL version %s)\n\n",
           CHANGEPOINT_VERSION, PLATFORM, COMPILE_DATE, GSL_VERSION );

  /*******************************
  *    Read in critical region   *
  *******************************/
  // 20040325-HY
  // Type-I error (alpha) critical region data
  if (alpha == 0.01) {
	  N_ta = N_ta99;
	  ta = (double *) realloc(ta,N_ta*sizeof(double));
	  for (ui=0; ui<N_ta; ui++)
		  ta[ui] = ta99[ui];
	  }
  else if (alpha == 0.05) {
	  N_ta = N_ta95;
	  ta = (double *) realloc(ta,N_ta*sizeof(double));
	  for (ui=0; ui<N_ta; ui++)
		  ta[ui] = ta95[ui];
	  }
  else if (alpha == 0.1) {
	  N_ta = N_ta90;
	  ta = (double *) realloc(ta,N_ta*sizeof(double));
	  for (ui=0; ui<N_ta; ui++)
		  ta[ui] = ta90[ui];
	  }
  else if (alpha == 0.31) {
	  N_ta = N_ta69;
	  ta = (double *) realloc(ta,N_ta*sizeof(double));
	  for (ui=0; ui<N_ta; ui++)
		  ta[ui] = ta69[ui];
	  }
  else {
    printf( "Critical region threshold for type-I error rate of %.2f is not supplied.\n",
            alpha );
    printf( "Available error rates are: 0.01, 0.05, 0.1, and 0.31.\n" );
    exit(1);
    }

  // Confidence interval (beta) critical region data
  if (beta == 0.99) {
	  N_ca = N_ca99;
	  ca = (double *) realloc(ca,N_ca*sizeof(double));
	  for (ui=0; ui<N_ca; ui++)
		  ca[ui] = ca99[ui];
	  }
  else if (beta == 0.95) {
	  N_ca = N_ca95;
	  ca = (double *) realloc(ca,N_ca*sizeof(double));
	  for (ui=0; ui<N_ca; ui++)
		  ca[ui] = ca95[ui];
	  }
  else if (beta == 0.9) {
	  N_ca = N_ca90;
	  ca = (double *) realloc(ca,N_ca*sizeof(double));
	  for (ui=0; ui<N_ca; ui++)
		  ca[ui] = ca90[ui];
	  }
  else if (beta == 0.69) {
	  N_ca = N_ca69;
	  ca = (double *) realloc(ca,N_ca*sizeof(double));
	  for (ui=0; ui<N_ca; ui++)
		  ca[ui] = ca69[ui];
	  }
  else {
    printf( "Critical region threshold for confidence region of %.2f is not supplied.\n",
            beta );
    printf( "Available are: 0.01, 0.05, 0.1, and 0.31.\n" );
    exit(1);
    }
  Na = 1000; // limit the change-point search to 1000 photons / search

  /*******************************
  *          Read in data        *
  *******************************/
  if ( (fpin=fopen(in_name,"r")) == NULL ) {
    // file does not exist, exit with error
    printf( "File [%s] does not exist. Exiting ...\n", in_name );
    exit(1);
  }
  else {
    // file exists. start reading in data and correlate
    printf( "] Reading in data file ...\n");
    N = 0;
    T = 0.0;
    traj = (struct data *) realloc(traj,sizeof(struct data));
    traj[0].dt = 0.0;
    traj[0].time = 0.0;
    traj[0].value = 0.0;

    while ( !feof(fpin) ) {
      // (HY)-20080122, tidy-up this part of the code.
      // (HY)-20060804, use strtok to deal with generalized input
      //      inter-photon-integer(1) val1(1) val2(1) val3(1)
      //      inter-photon-integer(2) val1(2) val2(2) val3(2)
      //               :                 :       :      :
      //      inter-photon-integer(N) val1(N) val2(N) val3(N)
      if (fgets(buffer,65535,fpin)!=NULL) { 
	// (HY)-20200816 fixed a potential compilation error by adding this IF-ELSE clause
        N++;                        // keep track of # data points
        dt = delta_t * (double) strtol( buffer, endptr, 10 );
        T += dt;
        traj = (struct data *) realloc(traj,(N+1)*sizeof(struct data));
        traj[N].dt = dt;
        traj[N].time = T;
        traj[N].value = 0.0; // this is an auxiliary storage space (not used in cp)
      } 
    }
    fclose( fpin );
    N--;                                        // take care of overshot data
    T -= dt;                                    //
    printf( "  Total of %lu photons, %.3lf seconds read in.\n", (long unsigned int) N, T);
  }

  /******************************************************
  * Find change points using log-likelihood ratio tests *
  ******************************************************/
  // 20040325-HY
  // 20040128-HY

  printf( "] Finding change points recursively ...\n");
  time0 = time((time_t *)NULL);
  if ( Na > N )
    cp1 = FindCP( &cp_root, traj, 1, N, alpha, beta, &Ncp, ta, ca, Na, 1 );
  else { // N > Na, segment process
    cpl = 1;
    cpr = Na;
    done = false;
    while ( !done ) {
      cp1 = FindCP( &cp_root, traj, cpl, cpr, alpha, beta, &Ncp, ta, ca, Na, 1 );
      if ( cpr < N ) {
        if ( cp1 == 0 ) cpl = cpr - NA_OVERLAP; // no change points found
        else cpl = cp1;
        cpr = cpl + Na - 1;
        if ( cpr > N ) cpr = N;
        done = false;
        }
      else done = true;
      } // end of while !done
    } // end of else Na > N
  time1 = time((time_t *)NULL);
  printf( "  %i change points found. [%.0f s]\n", Ncp, difftime(time1,time0) );
  // Save results...
  strcpy( filename, out_name );
  strcat( filename, ".cp" );
  printf( "  saving file: %s \n", filename );
  fpout = fopen( filename, "w" );
  SaveCP( fpout, cp_root );
  fclose( fpout );

  /*************************************************************************
  * Check if change points are ok. Spurious change points will be removed. *
  *************************************************************************/
  // 20040128-HY

//trace = 1;                                  // set trace = 1 to turn debugging output
  printf( "] Examining %i change points sequentially ...\n",Ncp);
  time0 = time((time_t *)NULL);
  CheckCP( &cp_root, traj, alpha, beta, N, &Ncpdlt, trace, ta, ca, Na );
  time1 = time((time_t *)NULL);
  printf( "  %i spurious change points removed. [%.0f s]\n", Ncpdlt, difftime(time1,time0) );
  Ncp = Ncp-Ncpdlt;                           // update number of change points
  // Save results...
  strcpy( filename, out_name );
  strcat( filename, ".cp" );
  printf( "  saving file: %s \n", filename );
  fpout = fopen( filename, "w" );
  SaveCP( fpout, cp_root );
  fclose( fpout );


  /**************************************************************************
  * Agglomerative Hierachical Clustering as initial guess for EM Clustering *
  **************************************************************************/
  // 20040130-HY
  // 20040201-HY
  Ny = Ncp+1;
  Ny=0;
  SizeCPArray(cp_root,&Ny);
  Ny=Ny+1;
  printf( "] Starting agglomerative hierachical clustering ...\n");
  time0 = time((time_t *)NULL);
  Yi = dmatrix(Ny,Ngmax+3);
       // Yi[:][1], intensity levels between change points
       // Yi[:][2:Ngmax], the group to which it belongs
       // Yi[:][Ngmax+1], number of photons in this group
       // Yi[:][Ngmax+2], time duration of this group
       // Yi[:][Ngmax+3], uncertainties in time duration of this group
  Yim = dmatrix(Ny,Ngmax+3); // intensity level data after EM / merging
  Nym = (int *) malloc( (Ny+1)*sizeof(int) ); // number of levels
  AHCluster( traj, N, cp_root, Yi, Ny, Ngmax, trace );
  time1 = time((time_t *)NULL);
  printf( "  %i groups clustered. [%.0f s]\n", Ngmax, difftime(time1,time0) );
  // report ...
  strcpy( filename, out_name );
  strcat( filename, ".ah" );
  printf( "  saving file: %s \n", filename );
  fpout = fopen( filename, "w" );
  for (i=1; i<=Ny; i++) {
    for (j=1; j<=Ngmax+3; j++)
      if ( j>1 && j<=Ngmax )
        fprintf( fpout, "%2u ", (int) Yi[i][j] );
      else if ( j==Ngmax+1 )
        fprintf( fpout, "%lu ", (long unsigned int) Yi[i][j] );
      else
        fprintf( fpout, "%e ", Yi[i][j] );
    fprintf( fpout, "\n" );
    }
  fclose( fpout );

  /**************************************
  * Expectation-Maximization Clustering *
  **************************************/
  // 20040201-HY
  printf( "] Starting expectation-maximization clustering ...\n");
  time0 = time((time_t *)NULL);
  Yem.c = imatrix(Ny,Ngmax);
  Yem.intensity = dmatrix(Ny,Ngmax);
  Yem.prob = dmatrix(Ny,Ngmax);
  EMCluster( Yi, Ny, Yem, Ngmax, TOL, trace );
  time1 = time((time_t *)NULL);
  printf( "  End of EM Clustering. %i groups clustered. [%.0f s]\n", Ngmax, difftime(time1,time0) );
  // report ...
  for (j=2; j<=Ngmax; j++) {
    strcpy( filename, out_name );
    strcat( filename, ".em" );
    sprintf( dummy_str, ".%i", j );
    strcat( filename, dummy_str );
    printf( "  saving file: %s \n", filename );
    fpout = fopen( filename, "w" );
    for (i=1; i<=Ny; i++)
      fprintf( fpout, "%3i %e %e\n", Yem.c[i][j], Yem.intensity[i][j], Yem.prob[i][j] );
    fclose( fpout );
    }

  /**************************************
  * Change point refinement subroutines *
  **************************************/
  // 20040202-HY
  // The purpose of adding this subroutine is that there might be change points the
  // up (or down) transition is not picked up. In these cases, we remove this change
  // point regardless of its selection power. After this refinement, the number of
  // sections (Ny) will become dependent of the number of groups.
  //
  // 20200815-HY
  // Comment: These subroutines tend to be time consuming. Activate when needed, e.g.,
  //          when extremely precise accounting of number and position of change points
  //          is critical, as opposed to statistical precision.

/*
  printf( "] Refining E-M clustering results by merging sequentially repeating levels ...\n");
  time0 = time((time_t *)NULL);
  Yemm.c = imatrix(Ny,Ngmax);
  Yemm.intensity = dmatrix(Ny,Ngmax);
  Yemm.prob = dmatrix(Ny,Ngmax);
  MergeCP( Yi, Ny, Yem, Ngmax, Yim, Nym, Yemm );
  time1 = time((time_t *)NULL);
  printf( "  Merging EM results complete. [%.0f s]\n", difftime(time1,time0) );
  for (j=2; j<=Ngmax; j++) {
    printf( "    %i-group: %u samples merged.\n", j, Ny-Nym[j] );
    }
*/

  /*********************************************
  *  Bayesian Information Criteria Clustering  *
  *********************************************/
  // 20040201-HY
  printf( "] Starting Bayesian information criteria clustering ...\n");
  time0 = time((time_t *)NULL);
  bic = (double *) malloc( (Ngmax+1)*sizeof(double) );
  BICCluster( Yi, Ny, Yem, Ngmax, Yim, Nym, bic, trace );
  time1 = time((time_t *)NULL);
  for (j=1,bic_max=-DBL_MAX; j<=Ngmax; j++) {
    printf( "    %i-group classification BIC = %e\n", j, bic[j] );
    if ( bic[j] > bic_max ) {
      bic_max = bic[j];
      g_max = j;
      }
    }
  printf( "  BIC Clustering complete. Most likely %i groups are involved. [%.0f s]\n", g_max, difftime(time1,time0) );
  // report ...
  strcpy( filename, out_name );
  strcat( filename, ".bic" );
  printf( "  saving file: %s \n", filename );
  fpout = fopen( filename, "w" );
  for (j=1; j<=Ngmax; j++)
    fprintf( fpout, "%3i %e\n", j, bic[j] );
  fclose( fpout );

  /******************************************
  * Free up work space and exit the program *
  ******************************************/
  printf( "*******************************************************************\n");
  printf( "*                            All Done.                            *\n");
  printf( "*******************************************************************\n");
  free_dmatrix(Yi,Ny,Ngmax+3);
  free_dmatrix(Yim,Ny,Ngmax+3);
  free_imatrix(Yem.c,Ny,Ngmax);
  free_dmatrix(Yem.intensity,Ny,Ngmax);
  free_dmatrix(Yem.prob,Ny,Ngmax);
  free(traj);
  free(bic);
  free(Nym);
  free(ta);
  free(ca);

  return EXIT_SUCCESS;
}

