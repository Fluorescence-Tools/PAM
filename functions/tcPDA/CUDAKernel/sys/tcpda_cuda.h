/* sys/tcpda.h
 *
 *  Contains tcPDA data for 3 Color MFD probability evaluation
 *
 */
 
#ifndef TCPDA_H
#define TCPDA_H

#include <stdlib.h>									/* for size_t */

typedef struct tcpda_data_struct {
	float *fbb;        /* Bursts */
	float *fbg;
	float *fbr;
	float *fgg;
	float *fgr;
	
	int *NBGbb;       /* NBGbb = numel(BGbb)-1 */
	int *NBGbg;
	int *NBGbr;
	int *NBGgg;
	int *NBGgr;
	
	float *BGbb;       /* Background corrections */
	float *BGbg;
	float *BGbr;
	float *BGgg;
	float *BGgr;
	
	float *p_bb;       /* percentage of 'PBB = Pout_B./P_total;' */
	float *p_bg;       
	float *p_gr;
    
    float *out_matrix_device;       /* storage for computation */
    float *P_binomial;
    float *P_trinomial;
    	
	int *burst_cols;        /* Dimension of Burst Array */
	int *burst_rows;
	
	int *p_cols;            /* Dimension of P Array */
	int *p_rows;
    
    int *thread_count;   /* number of threads on the gpu */
    int *block_count;
} tcpda_data;
//typedef struct tcpda_data_struct tcpda_data;

#endif /* TCPDA_H */
