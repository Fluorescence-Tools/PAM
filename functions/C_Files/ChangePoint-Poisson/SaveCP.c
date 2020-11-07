/***************************************************************************
                          SaveCP.c  -  description
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
#include <stdio.h>
#include "changepoint.h"

void SaveCP(fp,p)
struct changepoint  *p;
FILE                *fp;
{
  if (p != NULL) {
    SaveCP(fp,p->left);
    fprintf( fp, "%lu %lu %lu\n", (long unsigned int) p->i, (long unsigned int) p->il, (long unsigned int) p->ir );
    SaveCP(fp,p->right);
    }
  }
