function time_in_state1 = dynamic_sim(dynamic_rates,simtime,frequency,number_of_timewindows)
%%% Simulates dynamic system interconverting between size(dynamic_rates,1)
%%% states. Currently only supports two states!
%%%
%%% Input parameters:
%%% dynamic_rates   -   Rate matrix where element ij describes the rate
%%%                     from state i to state j.
%%%                     Rates are given in Hz, i.e. 1/s.
%%%                     Diagonal elements are ignored, as they are
%%%                     recomputed from the off-diagonal elements.
%%%
%%%                     Example:
%%%                     ( 11 12 13 14 )
%%%                     ( 21 22 23 24 )
%%%                     ( 31 32 33 34 )
%%%                     ( 41 42 43 44 )
%%%
%%% simtime         -   Duration of the simulation in seconds.
%%% frequency       -   Probing frequency, i.e. how often the current state
%%%                     is output. This should be at least an order of
%%%                     magnitude higher than the largest rate in the rate
%%%                     matrix. Given in Hz
%%%
%%% Output parameters:
%%% time_in_state1   -   number of time steps spent in state1


% input check
if nargin < 4
    disp('Not enough inputs given. Requires 4 inputs.');
    return;
end
if size(dynamic_rates,1) ~= size(dynamic_rates,2)
    disp('Rate matrix must be square.');
    return;
end
% convert simTime to number of TimeSteps
timesteps = round(simtime * frequency);
%%% convert to probability per step
% Assuming k/f is close to zero, we can approximate:
% pTrans = dynamic_rates./frequency;
% However, this breaks down if k/f is larger.
% The correct formula is:
pTrans = 1-exp(-dynamic_rates./frequency);
% This is the probability of having a transition in the time interval
% deltaT = 1/f for an exponential distribution.
% P(transition) = 1 - P(no transition) = 1 - P_exp(deltaT|k)
%               = 1- exp(-k/f)

% fix possible NaN entries
pTrans(isnan(pTrans)) = 0;

% calculate diagonal elements from off-diagonal elements
% diagonal elements are 1-sum(p_else)
for i = 1:size(pTrans,1)
    pTrans(i,i) = 1-sum(pTrans(i,:));
end

%%% For input to the mex file, the rates must have the following structure:
%%% p = [p11,p12,13,...p21,p22,p23,...p31,p32,p33,...]
p=[];
for i = 1:size(pTrans,1)
    p = [p,pTrans(i,:)];
end

% get number of states
n_states = size(dynamic_rates,1);
% roll initial state based on equlibrium distribution
p1 = dynamic_rates(2,1)/(dynamic_rates(2,1)+dynamic_rates(1,2));
% note: This needs to be adapted for 3 or more states!

initial_state = binornd(n_states-1,1-p1,1,number_of_timewindows);
% generate seed
seed = randi([1,2^20],1);
% simulate states for all time windows
time_in_state2 = dyn_Sim_array(timesteps,n_states,p,initial_state,seed,number_of_timewindows);
% note: the function returns the sum over the state trajectory.
% Since state1 == 0 and state2 == 1 in C, the functions thus return the
% number of time steps in state2.
% The C function needs to be adapted for 3 or more states!

% return time in state 1 as fraction
time_in_state1 = 1-double(time_in_state2)./timesteps;
