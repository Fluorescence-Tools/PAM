/***************************************************************************
                        DeleteCPNode.c  -  description
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

void balance1();
void balance2();
void del();

void DeleteCPNode(k,p,h)
size_t             k;
struct changepoint **p;
enum bool          *h;
{
  struct changepoint *q;

  if ( (*p)==NULL ) {
    printf( "!!!! Index %lu is not in change point tree.\n", (long unsigned int)k );
    (*h) = false;
    exit(1);
    }
  else if ( k < (*p)->i ) {
    // go down to the left branch
    DeleteCPNode( k, &((*p)->left), h );
    if ( *h ) balance1( p, h );
    }
  else if ( k > (*p)->i ) {
    // go down to the right branch
    DeleteCPNode( k, &((*p)->right), h );
    if ( *h ) balance2( p, h );
    }
  else { //k==(*p)->i
    q = *p;
    if ( q->right == NULL ) {
      (*p) = q->left;
      free(q);
      (*h) = true;
      }
    else if ( q->left == NULL ) {
      (*p) = q->right;
      free(q);
      (*h) = true;
      }
    else {
      del( q, &(q->left), h );
      if (*h) balance1( p, h );
      }
    }
  } // DeleteCPNode

/***************************************************************************
 This section of code is still buggy...
 ***************************************************************************/
void del(q,r,h)
struct changepoint *q,**r;
enum bool          *h;
{
  struct changepoint *discard;
  
  if ( (*h) == false ) {
    if ( (*r)->right != NULL ) {
      del( q, &((*r)->right), h );
      if (*h) balance2(r,h);
      }
    else {
      discard = (*r);
      q->i = (*r)->i;
      q->il = (*r)->il;
      q->ir = (*r)->ir;
      (*r) = (*r)->left;
      free(discard);
      (*h) = true;
      }
    }
  }

/***************************************************************************
    begin                : Thu Jan 29 2004
    balance1: The left branch is shorter.
 ***************************************************************************/
void balance1(p,h)
struct changepoint **p;
enum bool          *h;
{
  struct changepoint  *p1, *p2;
  int                 b1, b2;
  
  if (*h) {                               
    switch ((*p)->bal) {
      case -1:
        (*p)->bal = 0;
        break;
      case 0:
        (*p)->bal = 1;
        (*h) = false;
        break;
      case 1:                                // Rebalance
        p1 = (*p)->right;
        if(!p1) return;
        b1 = p1->bal;
        if (p1->bal >= 0) {                   // Single RR rotation
          (*p)->right = p1->left;
          p1->left = *p;
          if ( b1 == 0 ) {
            (*p)->bal = 1;
            p1->bal = -1;
            (*h) = false;
            }
          else {
            (*p)->bal = 0;
            p1->bal = 0;
            }
          *p = p1;
          }
        else {                                // Double RL rotation
          p2 = p1->left;
          if(p2==NULL) break;
          b2 = p2->bal;
          p1->left = p2->right;
          p2->right = p1;
          (*p)->right = p2->left;
          p2->left = *p;
          if (b2 == -1) p1->bal = 1; else p1->bal = 0;
          if (b2 == 1) (*p)->bal = -1; else (*p)->bal = 0;
          *p = p2;
          p2->bal = 0;
          }
        break;
      } // Switch
    } // if (h)
  } // balance1

/***************************************************************************
    begin                : Thu Jan 29 2004
    balance2: The right branch is shorter.
 ***************************************************************************/
void balance2(p,h)
struct changepoint **p;
enum bool          *h;
{
  struct changepoint  *p1, *p2;
  int                 b1, b2;

  if (*h) {                                   // left branch has grown higher
    switch ((*p)->bal) {
      case 1:
        (*p)->bal = 0;
        break;
      case 0:
        (*p)->bal = -1;
        (*h) = false;
        break;
      case -1:                                // Rebalance
        p1 = (*p)->left;
        if(p1==NULL) break;
        b1 = p1->bal;
        if (b1 <= 0) {                        // Single LL rotation
          (*p)->left = p1->right;
          p1->right = *p;
          if ( b1 == 0 ) {
            (*p)->bal = -1;
            p1->bal = 1;
            (*h) = false;
            }
          else {
            (*p)->bal = 0;
            p1->bal = 0;
            }
          *p = p1;
          }
        else {                                // Double LR rotation
          p2 = p1->right;
          if(p2==NULL) break;
          b2 = p2->bal;
          p1->right = p2->left;
          p2->left = p1;
          (*p)->left = p2->right;
          p2->right = *p;
          if (b2 == -1) (*p)->bal = 1; else (*p)->bal = 0;
          if (b2 == 1) p1->bal = -1; else p1->bal = 0;
          *p = p2;
          p2->bal = 0;
          }
        break;
      } // Switch
    } // if (h)
  } // balance2
