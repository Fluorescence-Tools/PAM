function states = dyn_sim_arbitrary_states_gillespie_trajectory(dynamic_rates,SimTime,number_of_timewindows)

% dynamic_rates = [   0, 500, 700;
%                  1000,   0, 900;
%                   800, 600,   0];
dynamic_rates(isinf(dynamic_rates)) = 0;
dynR_tot = 1 ./ sum(dynamic_rates) * 1000;
state_changes = [0,-1,-2; 
                +1, 0,-1;
                +2,+1, 0];
%number_of_timewindows = 1000;
%SimTime = 0.1;
R_max = 100;

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

% time_in_states_gillespie = zeros(number_of_timewindows,3);
% nn = find(initial_state_random(i,:),1,'first'); % initial state

states = cell(number_of_timewindows,1);

for i = 1:number_of_timewindows
    nn = find(initial_state_random(i,:),1,'first'); % initial state
    nn_store = zeros(1,R_max+1);
    %tt_store = zeros(1,R_max+1);
    tau = zeros(1,R_max+1);
    rand_nums = rand(1,R_max+1); % generate random numbers for dwell times and state
    tt = 0; % time
    R_count = 0; % state change counter
    states_temp = cell(1);
    while tt < SimTime % simulate state changes for R_max changes
        R_count = R_count + 1;
        
        tau(R_count) = exprnd(dynR_tot(1,nn)); % draw dwell time according to total rate
        %tau(R_count) = -log(exprand_nums(1,R_count))/dynR_tot;
        
        valid_idx = dynamic_rates(1:n_states,nn) > 0; % indices of valid state changes
        %valid_rates = dynamic_rates(valid_idx,nn); % valid rates
        valid_changes = state_changes(valid_idx,nn); % valid state changes
        
        %trying to improve performance
        valid_rates = cumsum(dynamic_rates(valid_idx,nn)); % cumsum of all valid rates
        
        % normalize to [0,1] interval, find and store segment
        valid_changes = valid_changes((valid_rates./valid_rates(end) > rand_nums(1,R_count)));
        
        state_array = zeros(1,ceil(1000*tau(R_count)));
        state_array(:) = nn;
        states_temp{R_count} = state_array;
        tt = tt + tau(R_count);
        nn = nn + selected_change;
        nn = nn + valid_changes(1);
        
        %tt_store(R_count) = tt;
        %nn_store(R_count) = nn;
    end
    states{i} = horzcat(cell2mat(states_temp));
    %nn_store = nn_store(1:end-1);
    %time_in_states_gillespie(i,:) = [sum(tau(nn_store == 1)),sum(tau(nn_store == 2)),sum(tau(nn_store == 3))] ./ (tt-tau(end));
end
states = cell2mat(states')';
