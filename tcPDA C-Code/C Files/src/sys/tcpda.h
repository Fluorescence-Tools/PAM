/* sys/tcpda.h
 *
 *  Contains tcPDA data for 3 Color MFD probability evaluation
 *
 */
 
#ifndef TCPDA_H
#define TCPDA_H

#include <stdlib.h>									/* for size_t */

typedef struct tcpda_data_struct {
	double *fbb;        /* Bursts */
	double *fbg;
	double *fbr;
	double *fgg;
	double *fgr;
	
	double NBGbb;       /* NBGbb = numel(BGbb)-1 */
	double NBGbg;
	double NBGbr;
	double NBGgg;
	double NBGgr;
	
	double *BGbb;       /* Background corrections */
	double *BGbg;
	double *BGbr;
	double *BGgg;
	double *BGgr;
	
	double *p_bb;       /* percentage of 'PBB = Pout_B./P_total;' */
	double *p_bg;       
	double *p_gr;
    
    double **out_matrix;
    int num_cores;
    
    int thread_id;
	
	size_t burst_cols;  /* Dimension of Burst Array */
	size_t burst_rows;
	
	size_t p_cols;     
	size_t p_rows;
};
typedef struct tcpda_data_struct tcpda_data;

#endif /* TCPDA_H */
