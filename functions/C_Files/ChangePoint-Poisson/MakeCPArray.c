/***************************************************************************
                        MakeCPArray.c  -  description
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
 
void MakeCPArray(p,cps,cpsl,cpsr,Ncp)
struct changepoint  *p;
size_t              **cps,**cpsl,**cpsr;
int                 *Ncp;
{
  if (p != NULL) {
    MakeCPArray(p->left,cps,cpsl,cpsr,Ncp);
    (*Ncp)++;
    (*cps) = realloc(*cps,((*Ncp)+1)*sizeof(size_t));
    (*cpsl) = realloc(*cpsl,((*Ncp)+1)*sizeof(size_t));
    (*cpsr) = realloc(*cpsr,((*Ncp)+1)*sizeof(size_t));
    (*cps)[*Ncp] = p->i;
    (*cpsl)[*Ncp] = p->il;
    (*cpsr)[*Ncp] = p->ir;
    MakeCPArray(p->right,cps,cpsl,cpsr,Ncp);
    }
  }

void SizeCPArray(struct changepoint *p,int *N)
{
  if(p!=NULL){
    SizeCPArray(p->left,N);
    SizeCPArray(p->right,N);
    (*N)++;
    }
}
