function logL = GP_logL_burst(t,c,K,E)
% t -   Macrotimes of photons (cell array)
% c -   Color of photons (1->D,2->A) (cell array)
% K -   transition rate matrix
% E -   FRET efficiencies of states
logL = 0;
for i = 1:numel(t)
    logL = logL + GP_logL_mex(t{i},c{i},K,E);
end