function time_in_states_gillespie = dyn_sim_arbitrary_states_gillespie(dynamic_rates,SimTime,number_of_timewindows,dynR_tot)

% input check
if nargin < 3
    disp('Not enough inputs given. Requires 4 inputs.');
    return;
end
if size(dynamic_rates,1) ~= size(dynamic_rates,2)
    disp('Rate matrix must be square.');
    return;
end
state_changes = [0,-1,-2; 
                +1, 0,-1;
                +2,+1, 0];

% get number of states
n_states = size(dynamic_rates,1);
% obtain equlibrium distribution by solving K*p_eq = 0 and sum(p_eq) = 1
dynamic_eq = dynamic_rates;
for i = 1:n_states
    dynamic_eq(i,i) = -sum(dynamic_rates(:,i));
end
dynamic_eq(end+1,:) = ones(1,n_states);
b = zeros(n_states,1); b(end+1) = 1;
p_eq = dynamic_eq\b;
% ensure that p is a row vector
if size(p_eq,1) > size(p_eq,2)
    p_eq = p_eq';
end
% roll initial state based on equlibrium distribution
initial_state_random = mnrnd(1,p_eq,number_of_timewindows);

% preallocation for loop
time_in_states_gillespie = zeros(number_of_timewindows,3);

% preallocation while loop
R_max = 100;

% random numbers for state change
rand_nums = rand(1,number_of_timewindows*R_max+R_max+1);

% random numbers for dwell times
tau_rnd = [exprnd(dynR_tot(1,1),[1, number_of_timewindows*R_max+1]);...
    exprnd(dynR_tot(1,2),[1, number_of_timewindows*R_max+1]);...
    exprnd(dynR_tot(1,3),[1, number_of_timewindows*R_max+1])];
    
for i = 1:number_of_timewindows
    nn = find(initial_state_random(i,:),1,'first'); % initial state
    nn_store = zeros(1,R_max+1);
    tau = zeros(1,R_max+1);
    tt = 0; % time
    R_count = 0; % state change counter

    while tt < SimTime % simulate state changes for R_max changes
        R_count = R_count + 1;
        
        
        tau(R_count) = tau_rnd(nn,(i-1)*R_max+R_count);
        
        % indices of valid state changes
        valid_idx = dynamic_rates(1:n_states,nn) > 0;
        
        % valid state changes
        valid_changes = state_changes(valid_idx,nn);

        % cumsum of all valid rates
        valid_rates = cumsum(dynamic_rates(valid_idx,nn));
        
        % normalize to [0,1] interval, find and store segment
        %valid_changes = valid_changes((valid_rates./valid_rates(end) > rand_nums(1,R_count)));
        valid_changes = valid_changes((valid_rates./valid_rates(end) > rand_nums(1,(i-1)*R_max+R_count)));
        
        tt = tt + tau(R_count);
        nn = nn + valid_changes(1);
        nn_store(R_count) = nn;
    end
    nn_store = nn_store(1:R_count-1);
    time_in_states_gillespie(i,:) = [sum(tau(nn_store == 1)),sum(tau(nn_store == 2)),sum(tau(nn_store == 3))]...
    ./ (tt-tau(R_count));
end