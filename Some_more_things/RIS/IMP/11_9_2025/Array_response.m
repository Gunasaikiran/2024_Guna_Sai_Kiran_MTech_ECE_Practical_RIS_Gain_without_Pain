clc; clear;

%% Parameters
N = 16; K = 2;
txt_SNR_dB = 107.83;
txt_SNR_lin = 10^(txt_SNR_dB/10);
tot_time_slots = 500000;
Ts_values = [1, 1000, 10000, 50000, 100000];
tau_values = [2, 10, 25, 50, 100, 250, 500, 1000, 5000, 10000, 20000, 30000, 40000, 50000];

%% Locations
BS_locate = [0; 0];
IRS_locate = [0; 250];
UE_loc = [100, 400; 800, 900]; % User A and B

%% Array response setup
lambda = 1; d = lambda/2;
a = @(theta) exp(1j * 2 * pi * d * (0:N-1)' * sin(theta) / lambda);
theta_BS_IRS = atan2(IRS_locate(2) - BS_locate(2), IRS_locate(1) - BS_locate(1));
theta_IRS_UE = atan2(UE_loc(2,:) - IRS_locate(2), UE_loc(1,:) - IRS_locate(1));
a_BS_IRS = a(theta_BS_IRS);
a_IRS_UE = [a(theta_IRS_UE(1)), a(theta_IRS_UE(2))];

%% Path loss
eta_d = 3.6; eta_BS_IRS = 2; eta_IRS_UE = 2.8;
C0_lin = 1;
dist_BS_IRS = norm(BS_locate - IRS_locate);
dist_IRS_UE = vecnorm(IRS_locate - UE_loc);
dist_BS_UE = vecnorm(BS_locate - UE_loc);
beta_BS_IRS = C0_lin * ((1 / dist_BS_IRS)^eta_BS_IRS);
beta_BS_UE = C0_lin * ((1 ./ dist_BS_UE).^eta_d);
beta_IRS_UE = C0_lin * ((1 ./ dist_IRS_UE).^eta_IRS_UE);

%% Channels
h_BS_IRS = sqrt(beta_BS_IRS) * a_BS_IRS;
h_IRS_UE = sqrt(beta_IRS_UE) .* a_IRS_UE;
h_BS_UE = sqrt(beta_BS_UE) .* exp(1j * 2 * pi * rand(1, K));

%% IRS configs
IRS_config_A = diag(conj(a(theta_IRS_UE(1))));
IRS_config_B = diag(conj(a(theta_IRS_UE(2))));

%% Benchmarks
rate_rr_opt = zeros(1, length(Ts_values));
rate_rr_random = zeros(1, length(Ts_values));
rate_los = mean(log2(1 + (abs(h_BS_UE).^2) * txt_SNR_lin));

for ts_idx = 1:length(Ts_values)
    Ts = Ts_values(ts_idx);
    rr_opt = zeros(1, tot_time_slots);
    rr_rand = zeros(1, tot_time_slots);

    for t = 1:tot_time_slots
        k_rr = mod(t-1, K) + 1;

        % Random IRS
        rand_phase = exp(1j * 2 * pi * rand(N, 1));
        IRS_rand = diag(rand_phase);
        h_rand = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * IRS_rand * h_BS_IRS;
        rr_rand(t) = log2(1 + (abs(h_rand)^2) * txt_SNR_lin);

        % Optimized IRS
        IRS_opt = (k_rr == 1) * IRS_config_A + (k_rr == 2) * IRS_config_B;
        h_opt = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * IRS_opt * h_BS_IRS;
        rr_opt(t) = log2(1 + (abs(h_opt)^2) * txt_SNR_lin);
    end

    rate_rr_random(ts_idx) = mean(rr_rand);
    rate_rr_opt(ts_idx) = mean(rr_opt);
end

%% PF + Random IRS
Rate_matrix_pf_random = zeros(length(Ts_values), length(tau_values));

for ts_idx = 1:length(Ts_values)
    Ts = Ts_values(ts_idx);
    for tau_idx = 1:length(tau_values)
        tau = tau_values(tau_idx);
        T_k = zeros(1, K);
        rate_pf = zeros(1, tot_time_slots);

        for t = 1:tot_time_slots
            % IRS switching
            if mod(floor((t-1)/Ts), 2) == 0
                IRS_config_diag = IRS_config_A;
            else
                IRS_config_diag = IRS_config_B;
            end

            h_eff = h_BS_UE + (h_IRS_UE' * IRS_config_diag * h_BS_IRS).';
            rate_inst = log2(1 + (abs(h_eff).^2) * txt_SNR_lin);
            PF_metric = rate_inst ./ (T_k + eps);
            [~, k_sch] = max(PF_metric);
            T_k = (1 - 1 / tau) * T_k;
            T_k(k_sch) = T_k(k_sch) + (1 / tau) * rate_inst(k_sch);
            rate_pf(t) = rate_inst(k_sch);
        end

        Rate_matrix_pf_random(ts_idx, tau_idx) = mean(rate_pf);
    end
end

%% Plotting
figure;
colors = lines(length(Ts_values));

% PF + Random IRS
for ts_idx = 1:length(Ts_values)
    plot(tau_values, Rate_matrix_pf_random(ts_idx,:), '-o', ...
        'LineWidth', 2, 'Color', colors(ts_idx,:), ...
        'DisplayName', sprintf('PF+Rand IRS, Ts=%d', Ts_values(ts_idx)));
    hold on;
end
% RR + Optimized IRS
for ts_idx = 1:length(Ts_values)
    yline(rate_rr_opt(ts_idx), '--', 'Color', colors(ts_idx,:), ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('RR+Opt IRS, Ts=%d', Ts_values(ts_idx)));
end

% RR + Random IRS
for ts_idx = 1:length(Ts_values)
    yline(rate_rr_random(ts_idx), ':', 'Color', colors(ts_idx,:), ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('RR+Rand IRS, Ts=%d', Ts_values(ts_idx)));
end

% LOS only
yline(rate_los, 'k-.', 'LineWidth', 2, 'DisplayName', 'LOS only');

xlabel('PF Averaging Parameter \tau');
ylabel('Average Rate (bps/Hz)');
title('Rate vs \tau for Different Ts and Scheduling Schemes');
legend('Location', 'bestoutside');
grid on;

% Save
saveas(gcf, 'Rate_vs_Tau_AllSchemes.png');
saveas(gcf, 'Rate_vs_Tau_AllSchemes.fig');
