/***************************************************************************
                         AddCPNode.c  -  description
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
 
void AddCPNode( k, kl, kr, p, h)
size_t              k;                        // change point index
size_t              kl;                       // change point left bound
size_t              kr;                       // change point right bound
struct changepoint  **p;
enum bool           *h;
{
  struct changepoint *p1, *p2;

  if (*p == NULL) {                           // Not in tree, insert it
    (*p) = (struct changepoint *) malloc(sizeof(struct changepoint));
    *h = true;
    (*p)->i = k;        
    (*p)->il = kl;  
    (*p)->ir = kr;
    (*p)->left = NULL;
    (*p)->right = NULL;
    (*p)->bal = 0;
    }
  else if ( k < (*p)->i ) {
    AddCPNode(k,kl,kr,&((*p)->left),h);
    if (*h) {                                 // left branch has grown higher
      switch ((*p)->bal) {
        case 1:
          (*p)->bal = 0;
          *h = false;
          break;
        case 0:
          (*p)->bal = -1;
          break;
        case -1:                              // Rebalance
          p1 = (*p)->left;
          if (p1->bal == -1) {                // Single LL rotation
            (*p)->left = p1->right;
            p1->right = *p;
            (*p)->bal = 0;
            *p = p1;
            }
//          else {                            // Double LR rotation
//            p2 = p1->right;
//            p1->right = p2->left;
//            p2->left = p1;
//            (*p)->left = p2->right;
//            p2->right = *p;
//            if (p2->bal == -1) (*p)->bal = 1; else (*p)->bal = 0;
//            if (p2->bal == 1) p1->bal = -1; else p1->bal = 0;
//            *p = p2;
//            }
          (*p)->bal = 0;
          *h = false;
          break;
        } // Switch
      } // if (h)
    } // if ( [.] < p->Key )
  else if ( k > (*p)->i ) {
    AddCPNode(k,kl,kr,&((*p)->right),h);
    if (*h) {                                 // right branch has grown higher
      switch ((*p)->bal) {
        case -1:
          (*p)->bal = 0;
          *h = false;
          break;
        case 0:
          (*p)->bal = 1;
          break;
        case 1:                               // Rebalance
          p1 = (*p)->right;
          if(p1->left==NULL) break;
          if (p1->bal == 1) {                 // Single RR rotation
            (*p)->right = p1->left;
            p1->left = (*p);
            (*p)->bal = 0;
            (*p) = p1;
            }
          else {                              // Double RL rotation
            p2 = p1->left;
            p1->left = p2->right;
            p2->right = p1;
            (*p)->right = p2->left;
            p2->left = (*p);
            if (p2->bal == 1) (*p)->bal = -1; else (*p)->bal = 0;
            if (p2->bal == -1) p1->bal = 1; else p1->bal = 0;
            (*p) = p2;
            }
          (*p)->bal = 0;
          *h = false;
          break;
        } //Switch
      } //if (h)
    } //if ( [.]p->Key) 
  else {
    *h = false;
    }
  } // AddCPNode
