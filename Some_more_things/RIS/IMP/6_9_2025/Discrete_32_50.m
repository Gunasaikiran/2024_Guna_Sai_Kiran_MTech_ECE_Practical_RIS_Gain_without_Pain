clc; close all; clear; tic;

%% Parameters
N = 32; % IRS elements
K = 50; % Fixed number of users
txt_SNR_dB = 107.83;
txt_SNR_lin = 10^(txt_SNR_dB/10);
tot_time_slots = 50000;
Number_of_setups = 100;

Ts_values = [1, 50, 100, 1000, 25000, 50000];
tau_values = [2, 10, 25, 50, 100, 250, 500, 1000, 5000];

%% DFT codebook using FFT matrix
DFT_codebook = (1/sqrt(N)) * fft(eye(N)); % N x N normalized DFT matrix

%% UE location bounds
BS_locate = [0; 0];
IRS_locate = [0; 250];
max_x_UE_locate = 500; min_x_UE_locate = 100;
max_y_UE_locate = 1000; min_y_UE_locate = 500;

%% Result storage
Rate_matrix_all = zeros(Number_of_setups, length(Ts_values), length(tau_values));
Rate_benchmark_IRS_all = zeros(1, Number_of_setups);
Rate_benchmark_LOS_all = zeros(1, Number_of_setups);
Rate_benchmark_RR_Random_IRS_all = zeros(1, Number_of_setups);

%% Parallel Monte Carlo loop
parfor setup = 1:Number_of_setups
    fprintf('Starting Monte Carlo Setup %d\n', setup);

    % UE placement
    UEs_x = (rand(1, K) * (max_x_UE_locate - min_x_UE_locate)) + min_x_UE_locate;
    UEs_y = (rand(1, K) * (max_y_UE_locate - min_y_UE_locate)) + min_y_UE_locate;
    UE_loc = [UEs_x; UEs_y];

    % Path loss
    eta_d = 3.6; eta_BS_IRS = 2; eta_IRS_UE = 2.8;
    C0_lin = 1;
    dist_BS_IRS = vecnorm(BS_locate - IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate - UE_loc);
    dist_BS_UE = vecnorm(BS_locate - UE_loc);
    beta_BS_IRS = C0_lin * ((1 / dist_BS_IRS)^eta_BS_IRS);
    beta_BS_UE = C0_lin * ((1 ./ dist_BS_UE).^eta_d);
    beta_IRS_UE = C0_lin * ((1 ./ dist_IRS_UE).^eta_IRS_UE);

    % Small scale fading
    h_BS_IRS = sqrt(beta_BS_IRS / 2) * (randn(N, 1) + 1i * randn(N, 1));
    h_IRS_UE = sqrt(beta_IRS_UE / 2) .* (randn(N, K) + 1i * randn(N, K));
    h_BS_UE = sqrt(beta_BS_UE) .* (randn(1, K) + 1i * randn(1, K));

    % Benchmark: LOS only
    rate_los = log2(1 + (abs(h_BS_UE).^2) * txt_SNR_lin);
    Rate_benchmark_LOS_all(setup) = mean(rate_los);

    % Benchmark: Round-Robin with Random IRS & Optimized IRS
    rate_rr_random = zeros(1, tot_time_slots);
    rate_rr_opt = zeros(1, tot_time_slots);
    for t = 1:tot_time_slots
        k_rr = mod(t - 1, K) + 1;

        % Random IRS config
        h_rr = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * diag(DFT_codebook(:, randi(N))) * h_BS_IRS;
        rate_rr_random(t) = log2(1 + (abs(h_rr)^2) * txt_SNR_lin);

        % Optimized IRS config
        best_rate = 0;
        for l = 1:N
            h_opt = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * diag(DFT_codebook(:, l)) * h_BS_IRS;
            rate_l = log2(1 + (abs(h_opt)^2) * txt_SNR_lin);
            if rate_l > best_rate
                best_rate = rate_l;
            end
        end
        rate_rr_opt(t) = best_rate;
    end
    Rate_benchmark_RR_Random_IRS_all(setup) = mean(rate_rr_random);
    Rate_benchmark_IRS_all(setup) = mean(rate_rr_opt);

    % PF Scheduling with Random IRS (varying Ts and tau)
    local_rate_matrix = zeros(length(Ts_values), length(tau_values));
    for ts_idx = 1:length(Ts_values)
        Ts = Ts_values(ts_idx);
        fprintf('Setup %d: Running PF Scheduling for Ts = %d\n', setup, Ts);

        for tau_idx = 1:length(tau_values)
            tau = tau_values(tau_idx);
            T_k = zeros(1, K);
            rate_random = zeros(1, tot_time_slots);

            IRS_config_diag = diag(DFT_codebook(:, randi(N))); % Initial IRS config
            for t = 1:tot_time_slots
                if mod(t - 1, Ts) == 0
                    IRS_config_diag = diag(DFT_codebook(:, randi(N)));
                end

                h_eff = transpose(h_BS_UE.' + (h_IRS_UE.' * IRS_config_diag * h_BS_IRS));
                rate_inst = log2(1 + (abs(h_eff).^2) * txt_SNR_lin);
                PF_metric = rate_inst ./ T_k;
                [~, k_sch] = max(PF_metric);
                T_k = (1 - 1 / tau) * T_k;
                T_k(k_sch) = T_k(k_sch) + (1 / tau) * rate_inst(k_sch);
                rate_random(t) = rate_inst(k_sch);
            end

            local_rate_matrix(ts_idx, tau_idx) = mean(rate_random);
        end
    end

    Rate_matrix_all(setup, :, :) = local_rate_matrix;
end

%% Averaging over setups
Rate_matrix = squeeze(mean(Rate_matrix_all, 1));
Rate_benchmark_IRS = mean(Rate_benchmark_IRS_all);
Rate_benchmark_LOS = mean(Rate_benchmark_LOS_all);
Rate_benchmark_RR_Random_IRS = mean(Rate_benchmark_RR_Random_IRS_all);

toc;
delete(gcp('nocreate')); % End parallel computing

%% Plotting
figure;
colors = lines(length(Ts_values));
for ts_idx = 1:length(Ts_values)
    plot(tau_values, Rate_matrix(ts_idx,:), '-o', 'LineWidth', 2, ...
        'Color', colors(ts_idx,:)); hold on;
end

% Add benchmarks
yline(Rate_benchmark_IRS, 'k--', 'LineWidth', 2, 'DisplayName', 'Optimized IRS (Round-Robin)');
yline(Rate_benchmark_LOS, 'm-.', 'LineWidth', 2, 'DisplayName', 'LOS Only (No IRS)');
yline(Rate_benchmark_RR_Random_IRS, 'b--', 'LineWidth', 2, 'DisplayName', 'Random IRS (Round-Robin)');

xlabel('PF Parameter \tau');
ylabel('Average Rate (bps/Hz)');
legend([arrayfun(@(x) sprintf('Ts = %d', x), Ts_values, 'UniformOutput', false), ...
        {'Optimized IRS (Round-Robin)', 'LOS Only (No IRS)', 'Random IRS (Round-Robin)'}], ...
        'Location', 'best');
title('PF Scheduling: Rate vs \tau for Different IRS Switching Times');
grid on;
% Save the figure
saveas(gcf, 'PF_Rate_vs_Tau_32N_50K.fig');   % Save as .fig (MATLAB format)
saveas(gcf, 'PF_Rate_vs_Tau_32N_50K.png');   % Save as .png (image format)
