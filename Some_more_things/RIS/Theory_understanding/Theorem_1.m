%%% Code by GSK, MTECH 2024–2026
%%% PF Scheduling with Random UEs and Random IRS States
%%% Comparison: LOS only | RR + Optimal IRS | PF + Random IRS
%%% Adjusted: PF scheduling every slot; IRS switches every Ts slots
%%% Yashvanth_setup Theorem-1 and Theorem-2 both

clc; 
close all;
clear;
tic;

%% Parameters
N = 512;                     % IRS elements
K = 10;                       % Number of users
txt_SNR_dB = 110;             % SNR (dB)
txt_SNR_lin = 10^(txt_SNR_dB/10);
tot_time_slots = 20000000;      % Total time slots
Number_of_setups = 8;        % Monte Carlo iterations
%1800,
Ts_values = [200, 800, 3000];    % IRS switching intervals (slots)
tau_values = [2, 100, 2000,10000,20000,200000,2000000];       % PF averaging memory

%% Fixed Positions

BS_locate = [0; 0];
IRS_locate = [60;20];
max_x_UE_locate = 120; min_x_UE_locate = 80;
max_y_UE_locate = 20;  min_y_UE_locate = -20;

%% Results storage
Rate_matrix_all = zeros(Number_of_setups, length(Ts_values), length(tau_values));
Rate_benchmark_LOS_all = zeros(1, Number_of_setups);
Rate_benchmark_RR_all  = zeros(1, Number_of_setups);

%% Monte Carlo loop
for setup = 1:Number_of_setups
    fprintf('Starting Setup %d\n', setup);

    %% --- UE random positions ---
    UEs_locate_x = (max_x_UE_locate - min_x_UE_locate) * rand(1, K) + min_x_UE_locate;
    UEs_locate_y = (max_y_UE_locate - min_y_UE_locate) * rand(1, K) + min_y_UE_locate;
    UE_loc = [UEs_locate_x; UEs_locate_y];

    %% --- Channel and Path Loss ---
    eta_d = 3.8; eta_BS_IRS = 2; eta_IRS_UE = 2.8;
    C0_lin = 0.001;

    dist_BS_IRS = norm(BS_locate - IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate - UE_loc);
    dist_BS_UE  = vecnorm(BS_locate - UE_loc);

    beta_BS_IRS = C0_lin * ((1 / dist_BS_IRS)^eta_BS_IRS);
    beta_BS_UE  = C0_lin * ((1 ./ dist_BS_UE).^eta_d);
    beta_IRS_UE = C0_lin * ((1 ./ dist_IRS_UE).^eta_IRS_UE);

    % Small-scale fading (Rayleigh)
    h_BS_IRS = sqrt(beta_BS_IRS/2) * (randn(N, 1) + 1i * randn(N, 1));
    h_IRS_UE = sqrt(beta_IRS_UE/2) .* (randn(N, K) + 1i * randn(N, K));
    h_BS_UE  = sqrt(beta_BS_UE)   .* (randn(1, K) + 1i * randn(1, K));

    %% --- LOS Only Benchmark ---
    rate_los = log2(1 + (abs(h_BS_UE).^2) * txt_SNR_lin);
    Rate_benchmark_LOS_all(setup) = mean(rate_los);

    %% --- Optimal IRS Configurations (one per UE) ---
    IRS_config_user = cell(1, K);

    for k = 1:K
        phase_opt = angle(h_BS_UE(k))-(angle(h_IRS_UE(:, k)) + angle(h_BS_IRS));
        IRS_config_user{k} = diag(exp(1j * phase_opt));
    end

    %% --- Round-Robin + Optimal IRS Benchmark ---
    rate_rr_opt = zeros(1, tot_time_slots);
    for t = 1:tot_time_slots
        k_rr = mod(t - 1, K) + 1;
        IRS_config_diag = IRS_config_user{k_rr};  % IRS aligned to current RR user
        h_eff = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * IRS_config_diag * h_BS_IRS;
        rate_rr_opt(t) = log2(1 + (abs(h_eff)^2) * txt_SNR_lin);
    end
    Rate_benchmark_RR_all(setup) = mean(rate_rr_opt);

    %% --- PF Scheduling + Random IRS (IRS switches every Ts slots) ---
    local_rate_matrix = zeros(length(Ts_values), length(tau_values));
    local_rate_matrix_1 = zeros(length(Ts_values), length(tau_values));
    for ts_idx = 1:length(Ts_values)
        Ts = Ts_values(ts_idx);
        fprintf('Setup %d: PF Scheduling (Ts = %d)\n', setup, Ts);

        for tau_idx = 1:length(tau_values)
            tau = tau_values(tau_idx);
            fprintf('Setup %d: Ts = %d: PF Scheduling (Tc = %d)\n', setup, Ts,tau);
            rate_random = zeros(1, tot_time_slots);
            T_k = ones(1, K);              % PF average throughput init

            % Initialize IRS state for the first block
            rand_user = randi(K);
            IRS_config_diag = IRS_config_user{rand_user};

            for t = 1:tot_time_slots
                % IRS switches only every Ts slots
                if mod(t - 1, Ts) == 0
                    rand_user = randi(K);
                    IRS_config_diag = IRS_config_user{rand_user};
                end

                % Effective channels for all users with current IRS state
                h_eff = h_BS_UE + (h_IRS_UE.' * IRS_config_diag * h_BS_IRS).';
                rate_inst = log2(1 + (abs(h_eff).^2) * txt_SNR_lin);

                % PF metric and scheduling (per slot)
                PF_metric = rate_inst ./ T_k;
                [~, k_sch] = max(PF_metric);

                % PF averaging memory update
                T_k = (1 - 1/tau) * T_k;
                T_k(k_sch) = T_k(k_sch) + (1/tau) * rate_inst(k_sch);

                % Record scheduled rate
                rate_random(t) = rate_inst(k_sch);
            end

            local_rate_matrix(ts_idx, tau_idx) = mean(rate_random);
            local_rate_matrix_1(ts_idx, tau_idx) = sum(T_k);
        end
    end

    Rate_matrix_all(setup, :, :) = local_rate_matrix_1;
end

%% --- Averages over setups ---
Rate_matrix = squeeze(mean(Rate_matrix_all, 1));
Rate_benchmark_RR  = mean(Rate_benchmark_RR_all);
Rate_benchmark_LOS = mean(Rate_benchmark_LOS_all);

toc;
delete(gcp('nocreate'));

%% --- Plot
figure;
colors = lines(length(Ts_values));
for ts_idx = 1:length(Ts_values)
    plot(tau_values, Rate_matrix(ts_idx,:), '-o', 'LineWidth', 2, ...
        'Color', colors(ts_idx,:)); hold on;
end
yline(Rate_benchmark_RR, 'k--', 'LineWidth', 2, 'DisplayName', 'Round-Robin + Optimal IRS');
xlabel('PF parameter \tau'); ylabel('Average Rate (bps/Hz)');
legend_labels = [ ...
    arrayfun(@(x) sprintf('PF + Random IRS (T_s = %d)', x), Ts_values, 'UniformOutput', false), ...
    {'Round-Robin + Optimal IRS'} ...
];
legend(legend_labels, 'Location', 'best');
title('PF Scheduling vs Optimal IRS Benchmark (K=2, Random IRS switching every T_s)');
grid on;
xticks(tau_values); xticklabels(string(tau_values));
%% %% --- Plot 2: Throughput Error vs T_c with theorem bounds ---
Error_matrix = abs(Rate_matrix - Rate_benchmark_RR);  

% Parameters for theorem bound
eps1 = 0.1;  % tolerance for RIS states
eps2 = 0.1;  % tolerance for users
eta1 = 0.1;  % confidence
eta2 = 0.1;
M = K;        

figure;
colors = lines(length(Ts_values));
line_handles  = gobjects(length(Ts_values),1);
bound_handles = gobjects(length(Ts_values),1);

for ts_idx = 1:length(Ts_values)
    % Plot error curve
    line_handles(ts_idx) = semilogx(tau_values, Error_matrix(ts_idx,:), '-o', ...
        'LineWidth', 2, 'Color', colors(ts_idx,:)); hold on;

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

%` Build combined legend: curves + bounds
legend([line_handles; bound_handles], ...
    [arrayfun(@(x) sprintf('Error curve (T_s=%d)', x), Ts_values, 'UniformOutput', false), ...
     arrayfun(@(x) sprintf('Bound (T_s=%d)', x), Ts_values, 'UniformOutput', false)], ...
    'Location','northeast');

grid on;
