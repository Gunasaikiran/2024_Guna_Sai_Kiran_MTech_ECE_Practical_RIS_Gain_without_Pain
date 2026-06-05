%%% Code by GSK, MTECH 2024–2026
%%% PF Scheduling with Fixed UEs and Alternating IRS States
%%% Comparison: LOS only | RR + Optimal IRS | PF + Alternating IRS

clc; 
close all; 
clear; 
tic;

%% Parameters
N = 16;                      % IRS elements
K = 2;                       % Two users
txt_SNR_dB = 20;             % SNR (realistic)
txt_SNR_lin = 10^(txt_SNR_dB/10);
tot_time_slots = 200000;      % Total time slots
Number_of_setups = 10;        % Monte Carlo iterations

Ts_values = [200, 800, 1800, 3000];            % IRS switching intervals
tau_values = [2, 50, 100, 2000, 10000, 20000]; % PF averaging parameters

%% Fixed Positions
BS_locate = [0; 0];
IRS_locate = [200; 250];
UE_loc = [400 50; 700 150];  

%% Results storage
Rate_matrix_all = zeros(Number_of_setups, length(Ts_values), length(tau_values));
Rate_benchmark_LOS_all = zeros(1, Number_of_setups);
Rate_benchmark_RR_all  = zeros(1, Number_of_setups);

%% Monte Carlo loop (parallel-safe)
parfor setup = 1:Number_of_setups
    fprintf('Starting Setup %d\n', setup);

    %% --- Channel and Path Loss ---
    eta_d = 3.6; eta_BS_IRS = 2; eta_IRS_UE = 2.8;
    C0_lin = 1;

    dist_BS_IRS = vecnorm(BS_locate - IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate - UE_loc);
    dist_BS_UE  = vecnorm(BS_locate - UE_loc);

    beta_BS_IRS = C0_lin * ((1 / dist_BS_IRS)^eta_BS_IRS);
    beta_BS_UE  = C0_lin * ((1 ./ dist_BS_UE).^eta_d);
    beta_IRS_UE = C0_lin * ((1 ./ dist_IRS_UE).^eta_IRS_UE);

     % Small scale fading
    h_BS_IRS = (randn(N, 1) + 1i * randn(N, 1));
    h_IRS_UE = (randn(N, K) + 1i * randn(N, K));
    h_BS_UE = (randn(1, K) + 1i * randn(1, K));

    %% --- LOS Only Benchmark ---
    rate_los = log2(1 + (abs(h_BS_UE).^2) * txt_SNR_lin);
    Rate_benchmark_LOS_all(setup) = mean(rate_los);

    %% --- Optimal IRS Configurations (one per UE) ---
    IRS_config_user = cell(1, K);
    for k = 1:K
        phase_opt = -(angle(h_IRS_UE(:, k)) + angle(h_BS_IRS));
        IRS_config_user{k} = diag(exp(1j * phase_opt));  % continuous-phase optimized IRS
    end

    %% --- Round-Robin + Optimal IRS Benchmark ---
    rate_rr_opt = zeros(1, tot_time_slots);
    for t = 1:tot_time_slots
        k_rr = mod(t - 1, K) + 1;                % scheduled user
        IRS_config_diag = IRS_config_user{k_rr}; % IRS points to that user
        h_eff = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * IRS_config_diag * h_BS_IRS;
        rate_rr_opt(t) = log2(1 + (abs(h_eff)^2) * txt_SNR_lin);
    end
    Rate_benchmark_RR_all(setup) = mean(rate_rr_opt);

    %% --- PF Scheduling + Alternating IRS ---
    local_rate_matrix = zeros(length(Ts_values), length(tau_values));

    for ts_idx = 1:length(Ts_values)
        Ts = Ts_values(ts_idx);
        fprintf('Setup %d: PF Scheduling (Ts = %d)\n', setup, Ts);

        for tau_idx = 1:length(tau_values)
            tau = tau_values(tau_idx);

            % Initialize PF variables
            IRS_state = 1; % start pointing to UE1
            IRS_config_diag = IRS_config_user{IRS_state};
            h_eff_init = h_BS_UE + (h_IRS_UE.' * IRS_config_diag * h_BS_IRS).';

            rate_random = zeros(1, tot_time_slots);
            user_sched_count = zeros(1, K);
            T_k = ones(1, K);
            % --- PF Scheduling Loop ---
            for t = 1:tot_time_slots
                % Alternate IRS between user 1 and 2 every Ts slots
                if mod(t - 1, Ts) == 0
                    IRS_state = 3 - IRS_state; % toggle 1 <-> 2
                end
                IRS_config_diag = IRS_config_user{IRS_state};

                % Effective channels and instantaneous rates
                h_eff = h_BS_UE + (h_IRS_UE.' * IRS_config_diag * h_BS_IRS).';
                rate_inst = log2(1 + (abs(h_eff).^2) * txt_SNR_lin);

                % PF metric and scheduling
                PF_metric = rate_inst ./ T_k;
                [~, k_sch] = max(PF_metric);

                % Update PF averaging memory
                T_k = (1 - 1/tau) * T_k;
                T_k(k_sch) = T_k(k_sch) + (1/tau) * rate_inst(k_sch);

                % Record user statistics
                rate_random(t)  = rate_inst(k_sch);
                user_sched_count(k_sch) = user_sched_count(k_sch) + 1;
            end

            % Compute per-user average rate (true PF fairness)
            local_rate_matrix(ts_idx, tau_idx) = mean(rate_random);
        end
    end
    Rate_matrix_all(setup, :, :) = local_rate_matrix;
end

%% --- Averages over setups ---
Rate_matrix = squeeze(mean(Rate_matrix_all, 1));
Rate_benchmark_RR  = mean(Rate_benchmark_RR_all);
Rate_benchmark_LOS = mean(Rate_benchmark_LOS_all);

toc;
delete(gcp('nocreate'));

%% --- Plot: Average Rate vs τ (log-scale) ---
figure;
colors = lines(length(Ts_values));
for ts_idx = 1:length(Ts_values)
    plot(tau_values, Rate_matrix(ts_idx,:), '-o', 'LineWidth', 2, ...
        'Color', colors(ts_idx,:)); hold on;
end

% Benchmarks
yline(Rate_benchmark_RR, 'k--', 'LineWidth', 2, 'DisplayName', 'Round-Robin + Optimal IRS');
%yline(Rate_benchmark_LOS, 'm-.', 'LineWidth', 2, 'DisplayName', 'LOS Only');
ylim([13.7, 16])
xlabel('PF parameter \tau (log scale)');
ylabel('Average Rate (bps/Hz)');
legend([arrayfun(@(x) sprintf('Ts (in sec) = %d', x), Ts_values./200, 'UniformOutput', false), ...
        {'Round-Robin + Optimal IRS'}], 'Location', 'best');
title('PF Scheduling with Alternating IRS States');
grid on;
%set(gca, 'XScale', 'log', 'FontSize', 12);
xticks(tau_values);
xticklabels(string(tau_values));

%saveas(gcf, 'PF_Rate_vs_Tau_AlternateIRS_Log.fig');
%saveas(gcf, 'PF_Rate_vs_Tau_AlternateIRS_Log.png');