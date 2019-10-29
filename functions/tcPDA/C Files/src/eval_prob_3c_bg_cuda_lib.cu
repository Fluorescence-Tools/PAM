/* eval_prob_3c_bg.cu - Evaluate probabilty for 3-Color PDA after 
 *       blue and green excitation using CUDA
 *
 *========================================================*/

 /* For Matlab interaction */
#include "mex.h"

 /* Standard c libs */
#include <stdio.h>                       
#include <stdlib.h>
// #include <stddef.h>
// #include <limits.h>
#include <string.h>
#include <errno.h>
//#include <math.h>

//#include "randist/randist_cuda.h"                        /* Statistical distributions */
#include "randist/sys/minmax.h"                            /* Minimum/Maximum Makro */
#include "sys/tcpda_cuda_lib.h"                                /* Data Structure of Calculations */

#include "randist/specfunc/eval_cuda.h"                    /* Data Structure of Calculations */
#include "randist/specfunc/result_cuda.h"                  /* Evaluvating results of calculations */

 /* For gpu calculation using CUDA */ 
#include <cuda.h>

/* Here we define an inline macro for error checking the results of the CUDA APIs
 * It simply saves typing, simply use it with 'check_cuda_errors( <<CUDA_API>> );' */ 
#define check_cuda_errors(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
   if (code != cudaSuccess) 
   {
      fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}

 /* Forward declarations:
  * I couldn't split the source file without compile errors, even after customizing
  * mex_CUDA_win64.xml (contains matlab (mex) and cuda compile instructions for the
  * nvcc, the nvidia C/C++ Compiler) and adding '-rdc=true' as compile option and the
  * libraries 'cudart.lib' and 'cudadevrt.lib' */

__global__ void eval_prob_3c_bg(tcpda_data *data);
__device__ int sf_lnfact_e(const unsigned int n, sf_result * result);
__device__ int sf_lnchoose_e(unsigned int n, unsigned int m, sf_result * result);
__device__ float sf_lnfact(const unsigned int n);
__device__ float sf_lnchoose(unsigned int n, unsigned int m);
__device__ float ran_multinomial_lnpdf (const size_t K, const float p[], const unsigned int n[]);
__device__ float ran_multinomial_pdf (const size_t K, const float p[], const unsigned int n[]);
__device__ float ran_binomial_pdf (const unsigned int k, const float p, const unsigned int n);

/* The gateway function to matlab */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{

    /* check for proper number of arguments */
    if(nrhs!=20) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nrhs","20 inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("tcPDA:eval_prob_3c_bg:nlhs","One output required.");
    }

    size_t burst_cols, burst_rows;              /* Dimension of Burst Arrray */
    size_t p_cols, p_rows;                      /* Dimension of Probability Array */
    
    
    /* get dimensions of the burst matrices */
    burst_cols = mxGetN(prhs[0]);
    burst_rows = mxGetM(prhs[0]);
    
    /* get dimensions of the P matrix */
    p_cols = mxGetN(prhs[15]);
    p_rows = mxGetM(prhs[15]);

    /* The burst_row size (column length) determines how many warps are required for 
     * calculation to dynamically maximize occupancy (i.e. utilization).
     * See the CUDA Programming Guide for C and the CUDA_Occupancy_calculator.xls together
     * with the output of nvcc with the options '--resource-usage' and '-Xptxas=-v' for more */
    const int warp_size = 32;				/* By definition 32 for CUDA enabled devices, 
											 * so we always start a multiple of 32 threads */
    const int max_grid_size = 112; 			/* this is 8 blocks (112 / 32) per MP for a compute
											 * capability 5.2 device. (Maxwell GPU (GTX 9x0)) */

    int warp_count = (burst_rows / warp_size) + (((burst_rows % warp_size) == 0) ? 0 : 1);
    int warp_per_block = max(1, min(4, warp_count));

    /* For the eval_prob_3c_bg kernel, the block size is allowed to grow to
     * four warps per block, and the block count becomes the warp count over four
     * or the GPU "fill" whichever is smaller */
    int thread_count = warp_size * warp_per_block;
    int block_count = min( max_grid_size, max(1, warp_count/warp_per_block) );
    dim3 block_dim = dim3(thread_count, 1, 1);
    dim3 grid_dim  = dim3(block_count, 1, 1);

    /* Sizes for gpu memory allocation */
    size_t size_burst_matrix, size_p_matrix, size_lib_b, size_lib_t;

    size_burst_matrix = burst_cols * burst_rows * sizeof(float);
    size_p_matrix = p_cols * p_rows * sizeof(float);
    size_t vNBGbb, vNBGbg, vNBGbr, vNBGgg, vNBGgr;
    vNBGbb = mxGetScalar(prhs[5]);
    vNBGbg = mxGetScalar(prhs[6]);
    vNBGbr = mxGetScalar(prhs[7]);
    vNBGgg = mxGetScalar(prhs[8]);
    vNBGgr = mxGetScalar(prhs[9]);
    size_lib_b = burst_cols * burst_rows * (vNBGgg+1) * (vNBGgr+1) * sizeof(float);
    size_lib_t = burst_cols * burst_rows * (vNBGbb+1) * (vNBGbg+1) * (vNBGbr+1) * sizeof(float);

    /* Allocate device pointer for the matlab input on the gpu. */
    tcpda_data *d_thread_data;          /* TCPDA data struct for gpu memory */

	float *d_fbb;        				/* Bursts */
	float *d_fbg;
	float *d_fbr;
	float *d_fgg;
	float *d_fgr;
	
	int *d_NBGbb;       				/* NBGbb = numel(BGbb)-1 */
	int *d_NBGbg;
	int *d_NBGbr;
	int *d_NBGgg;
	int *d_NBGgr;
	
	float *d_BGbb;       				/* Background corrections */
	float *d_BGbg;
	float *d_BGbr;
	float *d_BGgg;
	float *d_BGgr;
	
	float *d_p_bb;       				/* percentage of 'PBB = Pout_B./P_total;' */
	float *d_p_bg;       
	float *d_p_gr;
    
    float *d_lib_b;
    float *d_lib_t;

    float *d_out_matrix_device;     	/* calculation space on the gpu */
    float *d_P_binomial;
    float *d_P_trinomial;
    	
	int *d_burst_cols;  				/* Dimension of Burst Array */
	int *d_burst_rows;
	
	int *d_p_cols;          			/* Dimension of P Array */  
	int *d_p_rows;

	int *d_thread_count;         		/* Number of threads running on gpu */
	int *d_block_count;

    /* Allocate the real memory on the gpu */
	/* tcpda struct */
    cudaMalloc((void **) &d_thread_data, sizeof(tcpda_data));

	/* bursts */
    cudaMalloc((void **) &d_fbb, size_burst_matrix);   
    cudaMalloc((void **) &d_fbg, size_burst_matrix);   
    cudaMalloc((void **) &d_fbr, size_burst_matrix);   
    cudaMalloc((void **) &d_fgg, size_burst_matrix);   
    cudaMalloc((void **) &d_fgr, size_burst_matrix);   

	/* NBG */
    cudaMalloc((void **) &d_NBGbb, sizeof(int));   
    cudaMalloc((void **) &d_NBGbg, sizeof(int));   
    cudaMalloc((void **) &d_NBGbr, sizeof(int));   
    cudaMalloc((void **) &d_NBGgg, sizeof(int));   
    cudaMalloc((void **) &d_NBGgr, sizeof(int));   

	/* Background */
    cudaMalloc((void **) &d_BGbb, size_burst_matrix);   
    cudaMalloc((void **) &d_BGbg, size_burst_matrix);   
    cudaMalloc((void **) &d_BGbr, size_burst_matrix);   
    cudaMalloc((void **) &d_BGgg, size_burst_matrix);   
    cudaMalloc((void **) &d_BGgr, size_burst_matrix); 

	/* P Matrix */
    cudaMalloc((void **) &d_p_bb, size_p_matrix);   
    cudaMalloc((void **) &d_p_bg, size_p_matrix);   
    cudaMalloc((void **) &d_p_gr, size_p_matrix);   
    
    /* binomial and trinomial coefficient library */
    cudaMalloc((void **) &d_lib_b, size_lib_b);
    cudaMalloc((void **) &d_lib_t, size_lib_t);

    cudaMalloc((void **) &d_out_matrix_device,(burst_rows * p_rows * sizeof(float)));   
    cudaMalloc((void **) &d_P_binomial, (burst_rows * p_rows * sizeof(float)));   
    cudaMalloc((void **) &d_P_trinomial, (burst_rows * p_rows * sizeof(float)));   
    cudaMalloc((void **) &d_burst_cols, sizeof(int));   
    cudaMalloc((void **) &d_burst_rows, sizeof(int)); 
    cudaMalloc((void **) &d_p_cols, sizeof(int));   
    cudaMalloc((void **) &d_p_rows, sizeof(int)); 

    cudaMalloc((void **) &d_thread_count, sizeof(int));   
    cudaMalloc((void **) &d_block_count, sizeof(int)); 


    /* Copy the content from the host to the device (gpu) and set calculation memory to zero. */
    cudaMemset(d_out_matrix_device, 0, (burst_rows * p_rows * sizeof(float)));
    cudaMemset(d_P_binomial, 0, (burst_rows * p_rows * sizeof(float)));
    cudaMemset(d_P_trinomial, 0, (burst_rows * p_rows * sizeof(float)));

    cudaMemcpy(d_fbb, ((float *)mxGetData(prhs[0])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_fbg, ((float *)mxGetData(prhs[1])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_fbr, ((float *)mxGetData(prhs[2])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_fgg, ((float *)mxGetData(prhs[3])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_fgr, ((float *)mxGetData(prhs[4])), size_burst_matrix, cudaMemcpyHostToDevice);
    
    cudaMemcpy(d_NBGbb, ((int *)mxGetData(prhs[5])), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_NBGbg, ((int *)mxGetData(prhs[6])), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_NBGbr, ((int *)mxGetData(prhs[7])), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_NBGgg, ((int *)mxGetData(prhs[8])), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_NBGgr, ((int *)mxGetData(prhs[9])), sizeof(int), cudaMemcpyHostToDevice);
    
    cudaMemcpy(d_BGbb, ((float *)mxGetData(prhs[10])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_BGbg, ((float *)mxGetData(prhs[11])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_BGbr, ((float *)mxGetData(prhs[12])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_BGgg, ((float *)mxGetData(prhs[13])), size_burst_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_BGgr, ((float *)mxGetData(prhs[14])), size_burst_matrix, cudaMemcpyHostToDevice);
    
    cudaMemcpy(d_p_bb, ((float *)mxGetData(prhs[15])), size_p_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_p_bg, ((float *)mxGetData(prhs[16])), size_p_matrix, cudaMemcpyHostToDevice);
    cudaMemcpy(d_p_gr, ((float *)mxGetData(prhs[17])), size_p_matrix, cudaMemcpyHostToDevice);

    cudaMemcpy(d_burst_cols, ((int *)&burst_cols), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_burst_rows, ((int *)&burst_rows), sizeof(int), cudaMemcpyHostToDevice);

    cudaMemcpy(d_p_cols, ((int *)&p_cols), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_p_rows, ((int *)&p_rows), sizeof(int), cudaMemcpyHostToDevice);
    
    /* initialize lib_b and lib_t */
    /* size information requires background numbers */
    cudaMemcpy(d_lib_b, ((float *)mxGetData(prhs[18])), size_lib_b, cudaMemcpyHostToDevice);
    cudaMemcpy(d_lib_t, ((float *)mxGetData(prhs[19])), size_lib_t, cudaMemcpyHostToDevice);
    
    /* Update the device pointer to the real data. */
    cudaMemcpy(&(d_thread_data->fbb), &d_fbb, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->fbg), &d_fbg, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->fbr), &d_fbr, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->fgg), &d_fgg, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->fgr), &d_fgr, sizeof(float*), cudaMemcpyHostToDevice);

    cudaMemcpy(&(d_thread_data->NBGbb), &d_NBGbb, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->NBGbg), &d_NBGbg, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->NBGbr), &d_NBGbr, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->NBGgg), &d_NBGgg, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->NBGgr), &d_NBGgr, sizeof(int*), cudaMemcpyHostToDevice);

    cudaMemcpy(&(d_thread_data->BGbb), &d_BGbb, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->BGbg), &d_BGbg, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->BGbr), &d_BGbr, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->BGgg), &d_BGgg, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->BGgr), &d_BGgr, sizeof(float*), cudaMemcpyHostToDevice);

    cudaMemcpy(&(d_thread_data->p_bb), &d_p_bb, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->p_bg), &d_p_bg, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->p_gr), &d_p_gr, sizeof(float*), cudaMemcpyHostToDevice);    

    cudaMemcpy(&(d_thread_data->burst_cols), &d_burst_cols, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->burst_rows), &d_burst_rows, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->p_cols), &d_p_cols, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->p_rows), &d_p_rows, sizeof(int*), cudaMemcpyHostToDevice);

    cudaMemcpy(&(d_thread_data->lib_b), &d_lib_b, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->lib_t), &d_lib_t, sizeof(float*), cudaMemcpyHostToDevice);

    cudaMemcpy(&(d_thread_data->out_matrix_device), &d_out_matrix_device, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->P_binomial), &d_P_binomial, sizeof(float*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->P_trinomial), &d_P_trinomial, sizeof(float*), cudaMemcpyHostToDevice);

    cudaMemcpy(d_thread_count, ((int *)&thread_count), sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_block_count, ((int *)&block_count), sizeof(int), cudaMemcpyHostToDevice);

    cudaMemcpy(&(d_thread_data->thread_count), &d_thread_count, sizeof(int*), cudaMemcpyHostToDevice);
    cudaMemcpy(&(d_thread_data->block_count), &d_block_count, sizeof(int*), cudaMemcpyHostToDevice);
    
    /* Start the calculation on the gpu device and check for errors */
    eval_prob_3c_bg <<< grid_dim,block_dim >>> (d_thread_data);
    cudaPeekAtLastError();
    
    /* wait for all threads on the gpu to finish before copying the evaluated values back to the host */
    cudaDeviceSynchronize();
    
    /* create 2d output matrix in Matlab for double precision (i.e. 2D double array) */
    plhs[0] = mxCreateNumericMatrix((mwSize)burst_rows,(mwSize)p_rows,mxSINGLE_CLASS, mxREAL);

    /* copy the calculated values back into matlab */
    cudaMemcpy((float *)mxGetData(plhs[0]), d_out_matrix_device, (p_rows * burst_rows * sizeof(float)), cudaMemcpyDeviceToHost);  

    /* Clean up *
    /* deallocate device memory on the gpu */
    cudaFree(d_fbb);
    cudaFree(d_fbg);
    cudaFree(d_fbr);
    cudaFree(d_fgg);
    cudaFree(d_fgr);

    cudaFree(d_NBGbb);
    cudaFree(d_NBGbg);
    cudaFree(d_NBGbr);
    cudaFree(d_NBGgg);
    cudaFree(d_NBGgr);

    cudaFree(d_BGbb);
    cudaFree(d_BGbg);
    cudaFree(d_BGbr);
    cudaFree(d_BGgg);
    cudaFree(d_BGgr);

    cudaFree(d_p_bb);
    cudaFree(d_p_bg);
    cudaFree(d_p_gr);

    cudaFree(d_lib_b);
    cudaFree(d_lib_t);

    cudaFree(d_burst_cols);
    cudaFree(d_burst_rows);
    cudaFree(d_p_cols);
    cudaFree(d_p_rows);

    cudaFree(d_out_matrix_device);
    cudaFree(d_P_binomial);
    cudaFree(d_P_trinomial);

    cudaFree(d_thread_count);
    cudaFree(d_block_count);

    cudaFree(d_thread_data);
}

 /* The computational routine */

__global__ void eval_prob_3c_bg(tcpda_data *thread_data)
{
    /* index is an identifier number of every single thread running on the gpu */
    int index = blockIdx.x * blockDim.x + threadIdx.x;
        
    /* Calculate the probability */

    /* Loop over all the probabilities */
    for (size_t i=0; i < *thread_data->p_rows; i++) {
        
        /* blue-red = blue-blue - blue-green */
        float p_br = 1 - thread_data->p_bb[i] - thread_data->p_bg[i];
        
        /* Loop over all bursts.
         * Here, we split up the work equally for the calculation threads
         * using the Thread ID in the data struct.
         * Every thread calculates the index+NUM_OF_TOTAL_THREADS'th 
         * probabilities, so we don't have to lock and synchronize the 
         * threads for writing the results, since the order does not
         * matter and no race conditions can occur.
         * For example: 6 (0-5) calculation threads are available, thread 
         * 0 calculates the probabilities for 0, 6, 12, 18, .. bursts.
         */
        for (size_t j=index; j < *thread_data->burst_rows; j=j+((*thread_data->thread_count) * (*thread_data->block_count))) {
            
            /* trinomal calculation */
            int bg_bb;
            for (size_t a=0; a <= MIN(thread_data->fbb[j], *thread_data->NBGbb) ; a++) {
                bg_bb = a;
                int bg_bg;
                for (size_t b=0; b <= MIN(thread_data->fbg[j], *thread_data->NBGbg) ; b++) {
                    bg_bg = b;
                    int bg_br;
                        for (size_t c=0; c <= MIN(thread_data->fbr[j], *thread_data->NBGbr) ; c++) {
                        bg_br = c;
                        
                        int ix = (int) j*(*thread_data->NBGbb+1)*(*thread_data->NBGbg+1)*(*thread_data->NBGbr+1)+bg_bb*(*thread_data->NBGbg+1)*(*thread_data->NBGbr+1)+bg_bg*(*thread_data->NBGbr+1)+bg_br;
                        
                        //float background[3] = {thread_data->p_bb[i], thread_data->p_bg[i], p_br};
                        //const unsigned int bursts[3] = {
                        //   (unsigned int) thread_data->fbb[j] - bg_bb,
                        //    (unsigned int) thread_data->fbg[j] - bg_bg,
                        //    (unsigned int) thread_data->fbr[j] - bg_br};

                        thread_data->P_trinomial[j+(*thread_data->burst_rows * i)] = thread_data->P_trinomial[j+(*thread_data->burst_rows * i)] +  // cumulative sum
                                thread_data->BGbb[bg_bb] *       // Background
                                thread_data->BGbg[bg_bg] *
                                thread_data->BGbr[bg_br] *
                                expf(
                                thread_data->lib_t[ix] +
                                logf(thread_data->p_bb[i])*(thread_data->fbb[j] - bg_bb) +
                                logf(thread_data->p_bg[i])*(thread_data->fbg[j] - bg_bg) +
                                logf(p_br)*(thread_data->fbr[j] - bg_br)
                                );
                                //ran_multinomial_pdf(3,background,bursts);
                        }
                }
            }

            /* bionomal calculation */

            size_t bg_gg;
            for (size_t a=0; a <= MIN(thread_data->fgg[j], *thread_data->NBGgg) ; a++) {
                bg_gg = a;
                size_t bg_gr;
                for (size_t b=0; b <= MIN(thread_data->fgr[j], *thread_data->NBGgr) ; b++) {
                    bg_gr = b;
                    
                    int ix = (int) j*(*thread_data->NBGgg+1)*(*thread_data->NBGgr+1)+bg_gg*(*thread_data->NBGgr+1)+bg_gr;
                    /* Subtract Background counts for FRET evaluation */
                    thread_data->P_binomial[j+(*thread_data->burst_rows * i)] = thread_data->P_binomial[j+(*thread_data->burst_rows * i)] +             // cumulative sum
                           thread_data->BGgg[bg_gg] *
                           thread_data->BGgr[bg_gr] *
                           expf(
                           thread_data->lib_b[ix] + 
                           logf(thread_data->p_gr[i])*(thread_data->fgr[j] - bg_gr) +
                           logf((1-thread_data->p_gr[i]))*(thread_data->fgg[j] - bg_gg)
                           );
                           //ran_binomial_pdf((unsigned int)(thread_data->fgr[j] - bg_gr),
                           //thread_data->p_gr[i], 
                           //(unsigned int) (thread_data->fgr[j] - bg_gr + thread_data->fgg[j] - bg_gg) );
                }
            }
        }
    }

    /* multiply element wise P_binomal by P_trinomal and fill the output array */
    for (size_t i=0; i < *thread_data->p_rows; i++) {
        for (size_t j=index; j < *thread_data->burst_rows; j=j+((*thread_data->thread_count) * (*thread_data->block_count))) {
            thread_data->out_matrix_device[j+(*thread_data->burst_rows * i)] = thread_data->P_binomial[j+(*thread_data->burst_rows * i)] * thread_data->P_trinomial[j+(*thread_data->burst_rows * i)];
        }
    }
        
    /* Clean up */
}

__device__
int sf_lnfact_e(const unsigned int n, sf_result * result)
{

  result->val = lgammaf(n+1.0);
  return EXIT_SUCCESS;

}

__device__
int sf_lnchoose_e(unsigned int n, unsigned int m, sf_result * result)
{
  /* CHECK_POINTER(result) */

  if(m > n) {
	  /* Handle Error */
    //DOMAIN_ERROR(result);
	return EXIT_FAILURE;
  }
  else if(m == n || m == 0) {
    result->val = 0.0;
    result->err = 0.0;
	return EXIT_SUCCESS;
  }
  else {
    sf_result nf;
    sf_result mf;
    sf_result nmmf;
    if(m*2 > n) m = n-m;
    sf_lnfact_e(n, &nf);
    sf_lnfact_e(m, &mf);
    sf_lnfact_e(n-m, &nmmf);
    result->val  = nf.val - mf.val - nmmf.val;
    //result->err  = nf.err + mf.err + nmmf.err;
    //result->err += 2.0 * GSL_DBL_EPSILON * fabs(result->val);
	return EXIT_SUCCESS;
  }
}

__device__
float sf_lnfact(const unsigned int n)
{
  EVAL_RESULT(sf_lnfact_e(n, &result));
}

__device__
float sf_lnchoose(unsigned int n, unsigned int m)
{
  EVAL_RESULT(sf_lnchoose_e(n, m, &result));
}

/* The multinomial distribution has the form

                                      N!           n_1  n_2      n_K
   prob(n_1, n_2, ... n_K) = -------------------- p_1  p_2  ... p_K
                             (n_1! n_2! ... n_K!) 

   where n_1, n_2, ... n_K are nonnegative integers, sum_{k=1,K} n_k = N,
   and p = (p_1, p_2, ..., p_K) is a probability distribution. 

   Random variates are generated using the conditional binomial method.
   This scales well with N and does not require a setup step.

   Ref: 
   C.S. David, The computer generation of multinomial random variates,
   Comp. Stat. Data Anal. 16 (1993) 205-217
*/
 
__device__
float
ran_multinomial_lnpdf (const size_t K,
                           const float p[], const unsigned int n[])
{
  size_t k;
  unsigned int N = 0;
  float log_pdf = 0.0;
  float norm = 0.0;

  for (k = 0; k < K; k++)
    {
      N += n[k];
    }

  for (k = 0; k < K; k++)
    {
      norm += p[k];
    }

  log_pdf = sf_lnfact (N);

  for (k = 0; k < K; k++)
    {
      /* Handle case where n[k]==0 and p[k]==0 */

      if (n[k] > 0) 
        {
          log_pdf += logf (p[k] / norm) * n[k] - sf_lnfact (n[k]);
        }
    }

  return log_pdf;
}

__device__
float
ran_multinomial_pdf (const size_t K,
                         const float p[], const unsigned int n[])
{
  return expf (ran_multinomial_lnpdf (K, p, n));
}

/* The binomial distribution has the form,

   prob(k) =  n!/(k!(n-k)!) *  p^k (1-p)^(n-k) for k = 0, 1, ..., n

   This is the algorithm from Knuth */

__device__
float
ran_binomial_pdf (const unsigned int k, const float p,
                      const unsigned int n)
{
  if (k > n)
    {
      return 0;
    }
  else
    {
      float P;

      if (p == 0) 
        {
          P = (k == 0) ? 1 : 0;
        }
      else if (p == 1)
        {
          P = (k == n) ? 1 : 0;
        }
      else
        {
          float ln_Cnk = sf_lnchoose (n, k);
          P = ln_Cnk + k * logf (p) + (n - k) * log1pf (-p);
          P = expf (P);
        }

      return P;
    }
}
