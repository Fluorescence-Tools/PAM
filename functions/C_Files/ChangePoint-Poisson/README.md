# Change Point Analysis of Poisson Time Series
This code finds the locations of abrupt changes in an otherwise piece-wise constant-level Poisson time series in a model-free way. For example, the time series can be a signle-molecule intensity-time trajectory acquired photon by phon using an APD detector. Assuming that there are finite number of constant-level states, it uses Agglomerative Hierarchical clustering followed by Expectation-Maximization clustering to find the most likely level values for a given number of states. It finally uses Bayesian Information Criteria (BIC) to determine the number of states. The development was originally at UC Berkeley (2004-2009) and continues at Princeton University (2009-). The associated publication is: Watkins, L.P. & H. Yang (2004). Detection of Intensity Change Points in Time-Resolved Single Molecule Measurements. <em>J. Phys. Chem. B</em>, **109**, 617-628.

## Requirements
This C code requires the GNU Scientific Library (GSL) and has been tested using the gcc compiler on both the OSX and Linux platforms.

## Syntax
$ changepoint.exe YourDataFileName TimeBase Alpha CI MaxStates

After having successfully compiled the code, switch to the /Example directory (make a copy of the /Example content first!) and try,
```
$ ../changepoint.exe TT4.dat 50e-9 0.05 0.69 5
```

## Input arguments
* `TT4.dat` — your data file name.
* `50e-9` — the time unit of the inter-photon interval entries in the data file, 50 ns in this example.
* `0.05` — the desired type-I error of change point detection, 5% in this example.
* `0.69` — the desired confidence level for backeting change point detection, 69% in this example.
* `5` — the maximum number of intensity states.

## Output
* `YourDataFileName.cp` — change point in units of data entry indicies, left confidence interval, right confidence interval
* `YourDataFileName.ah` — agglomerative hierarchical clustering results
* `YourDataFileName.em.2` — expectation maximization clustering results, 2 states
* `YourDataFileName.em.n` — expectation maximization clustering results, n states
* `YourDataFileName.em.MaxStates` — expectation maximization clustering results, MaxStates states
* `YourDataFileName.bic` — Bayesian information criteria scoring for each number of states

