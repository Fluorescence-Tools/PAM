% get_changepoints.c should accept matlab arrays
% main_mex.c is equivalent to the original program and reads files from disc
mex -lgsl -I/Users/Anders/opt/anaconda3/include -largeArrayDims get_changepoints_mex.c AddCPNode.c AHCluster.c BICCluster.c CheckCP.c DeleteCPNode.c EMCluster.c FindCP.c MakeCPArray.c MergeCP.c SaveCP.c util.c