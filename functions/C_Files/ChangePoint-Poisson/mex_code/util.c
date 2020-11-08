/***************************************************************************
                           util.c  -  description
                             -------------------
    begin coding                : Tue Jan 27 14:25:30 PST 2004
    peer-reviewed publication   : J. Phys. Chem. B, 109, 617-628 (2005)
    code initial public release : 2020
    copyright                   : © Haw Yang 2020
    email                       : hawyang@princeton.edu
***************************************************************************/

// Change log (for public release):
// 20200811: (HY) Start code clean up for v2.00 initial public release.

#include <stdlib.h>
 
double **dmatrix( nrows, ncolumns )
int nrows, ncolumns;
{
  int i;
  double **m;

  m = malloc( (nrows+1) * sizeof(double *));
  for(i = 0; i <= nrows; i++) 
    m[i] = malloc( (ncolumns+1) * sizeof(double));

  return m;
}

void free_dmatrix( m, nrows, ncolumns )
double **m;
int nrows, ncolumns;
{
  int i;
  for(i = 0; i <= nrows; i++)
    free((void *) m[i]);
  free((void *) m);
}

int **imatrix( nrows, ncolumns )
int nrows, ncolumns;
{
  int i;
  int    **m;

  m = malloc( (nrows+1) * sizeof(int *));
  for(i = 0; i <= nrows; i++) 
    m[i] = malloc( (ncolumns+1) * sizeof(int));

  return m;
}

void free_imatrix( m, nrows, ncolumns )
int    **m;
int nrows, ncolumns;
{
  int i;
  for(i = 0; i <= nrows; i++)
    free((void *) m[i]);
  free((void *) m);
}

