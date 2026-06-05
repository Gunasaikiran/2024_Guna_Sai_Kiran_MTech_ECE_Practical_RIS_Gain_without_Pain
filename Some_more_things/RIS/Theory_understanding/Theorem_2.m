%%% Code by GSK, MTECH 2024–2026
%%% PF Scheduling with Fixed UEs and Random IRS States
%%% Comparison: LOS only | RR + Optimal IRS | PF + Alternating IRS
%%% Extended: Plot 1 (Error vs Tc with theorem bounds), Plot 2 (Frequency deviation vs Tc)

clc; close all; clear; tic;

%% Parameters
N = 16;                      % IRS elements
K = 2;                       % Two users
txt_SNR_dB = 70;             % SNR (realistic)
txt_SNR_lin = 10^(txt_SNR_dB/10);
tot_time_slots = 4000000;
Number_of_setups = 4;       % Monte Carlo iterations

Ts_values = [200, 800, 3000];            
tau_values = [2, 50, 100, 2000, 10000, 25000,100000,400000]; 

%% Fixed Positions
BS_locate = [0; 0];
IRS_locate = [200; 250];
UE_loc = [400 50; 700 150];  

%% Results storage
Rate_matrix_all = zeros(Number_of_setups, length(Ts_values), length(tau_values));
Sched_freq_all  = zeros(Number_of_setups, length(Ts_values), length(tau_values), K);
Rate_benchmark_LOS_all = zeros(1, Number_of_setups);
Rate_benchmark_RR_all  = zeros(1, Number_of_setups);

%% Monte Carlo loop (parallelized)
parfor setup = 1:Number_of_setups
    fprintf('Starting Setup %d\n', setup);
    %% --- Channel and Path Loss ---
    eta_d = 3.6; eta_BS_IRS = 2; eta_IRS_UE = 2.8;
    C0_lin = 1;

    dist_BS_IRS = vecnorm(BS_locate - IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate - UE_loc);
    dist_BS_UE  = vecnorm(BS_locate - UE_loc);

    % Small scale fading
    h_BS_IRS = (randn(N, 1) + 1i * randn(N, 1));
    h_IRS_UE = (randn(N, K) + 1i * randn(N, K));
    h_BS_UE =  (randn(1, K) + 1i * randn(1, K));

    %% --- LOS Only Benchmark ---
    rate_los = log2(1 + (abs(h_BS_UE).^2) * txt_SNR_lin);
    Rate_benchmark_LOS_all(setup) = mean(rate_los);

    %% --- Optimal IRS Configurations (one per UE) ---
    IRS_config_user = cell(1, K);
    for k = 1:K
        phase_opt = -(angle(h_IRS_UE(:, k)) + angle(h_BS_IRS));
        IRS_config_user{k} = diag(exp(1j * phase_opt));  
    end

    %% --- Round-Robin + Optimal IRS Benchmark ---
    rate_rr_opt = zeros(1, tot_time_slots);
    for t = 1:tot_time_slots
        k_rr = mod(t - 1, K) + 1;                
        IRS_config_diag = IRS_config_user{k_rr}; 
        h_eff = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * IRS_config_diag * h_BS_IRS;
        rate_rr_opt(t) = log2(1 + (abs(h_eff)^2) * txt_SNR_lin);
    end
    Rate_benchmark_RR_all(setup) = mean(rate_rr_opt);

    %% --- PF Scheduling + Alternating IRS ---
    local_rate_matrix = zeros(length(Ts_values), length(tau_values));
    local_sched_freq  = zeros(length(Ts_values), length(tau_values), K);

    for ts_idx = 1:length(Ts_values)
        Ts = Ts_values(ts_idx);

        for tau_idx = 1:length(tau_values)
            tau = tau_values(tau_idx);

            IRS_state = 1; 
            IRS_config_diag = IRS_config_user{IRS_state};

            rate_random = zeros(1, tot_time_slots);
            user_sched_count = zeros(1, K);
            T_k = ones(1, K);

            for t = 1:tot_time_slots
                if mod(t - 1, Ts) == 0
                      IRS_state = randi(K); 
                end
                IRS_config_diag = IRS_config_user{IRS_state};

                h_eff = h_BS_UE + (h_IRS_UE.' * IRS_config_diag * h_BS_IRS).';
                rate_inst = log2(1 + (abs(h_eff).^2) * txt_SNR_lin);

                PF_metric = rate_inst ./ T_k;
                [~, k_sch] = max(PF_metric);

                T_k = (1 - 1/tau) * T_k;
                T_k(k_sch) = T_k(k_sch) + (1/tau) * rate_inst(k_sch);

                rate_random(t)  = rate_inst(k_sch);
                user_sched_count(k_sch) = user_sched_count(k_sch) + 1;
            end

            local_rate_matrix(ts_idx, tau_idx) = mean(rate_random);
            local_sched_freq(ts_idx, tau_idx, :) = user_sched_count / sum(user_sched_count);
        end
    end
    Rate_matrix_all(setup, :, :) = local_rate_matrix;
    Sched_freq_all(setup, :, :, :) = local_sched_freq;
end

%% --- Averages over setups ---
Rate_matrix = squeeze(mean(Rate_matrix_all, 1));
Sched_freq  = squeeze(mean(Sched_freq_all, 1));
Rate_benchmark_RR  = mean(Rate_benchmark_RR_all);
Rate_benchmark_LOS = mean(Rate_benchmark_LOS_all);

%% --- Plot 1: Throughput Error vs T_c with theorem bounds ---
%Error_matrix = abs(Rate_matrix - Rate_benchmark_RR);  

% Parameters for theorem bound
eps1 = 0.15;  % tolerance for RIS states
eps2 = 0.15;  % tolerance for users
eta1 = 0.01;  % confidence
eta2 = 0.01;
M = N;        % number of RIS states (example: N elements)

figure;
colors = lines(length(Ts_values));
line_handles  = gobjects(length(Ts_values),1);
bound_handles = gobjects(length(Ts_values),1);

for ts_idx = 1:length(Ts_values)
    % Plot error curve
%     line_handles(ts_idx) = semilogx(tau_values, Error_matrix(ts_idx,:), '-o', ...
%         'LineWidth', 2, 'Color', colors(ts_idx,:)); hold on;

    % Compute theoretical Tc bound for this Ts
    Tc_min1 = Ts_values(ts_idx) * (1/(2*eps1^2)) * log(2*M/eta1);
    Tc_min2 = (1/(2*eps2^2)) * log(2*K/eta2);
    Tc_min  = max(Tc_min1, Tc_min2);

    % Overlay vertical line with bright color (use hsv colormap for variety)
    bright_colors = hsv(length(Ts_values));
    bound_handles(ts_idx) = xline(Tc_min, '--', ...
        'Color', bright_colors(ts_idx,:), 'LineWidth', 2);
end

xlabel('Averaging Window $T_c$', 'Interpreter','latex');
ylabel('$\|\hat{T}(T_c) - T^*\|_\infty$ (bps/Hz)', 'Interpreter','latex');
title('Plot 1: Error vs $T_c$ with Theorem Bounds', 'Interpreter','latex');

% Build combined legend: curves + bounds
legend([line_handles; bound_handles], ...
    [arrayfun(@(x) sprintf('Error curve (T_s=%d)', x), Ts_values, 'UniformOutput', false), ...
     arrayfun(@(x) sprintf('Bound (T_s=%d)', x), Ts_values, 'UniformOutput', false)], ...
    'Location','northeast');

grid on;
%% 


toc;
delete(gcp('nocreate'));