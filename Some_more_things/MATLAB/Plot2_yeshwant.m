clc; clear;

% Simulation Parameters
tau = 5000;
numSlots = 40000;
N = 8; % Number of IRS elements
P_dBm = -10;
sigma2_dBm = -117.83;
P = 10^(P_dBm/10); % Convert dBm to linear scale
sigma2 = 10^(sigma2_dBm/10);
userCounts = [1,5,10,20,70,100,500,1000,1500];
avgThroughputRandom = zeros(size(userCounts));
avgThroughputBF = zeros(size(userCounts));

% Fixed Locations
BS = [0, 0];
IRS = [0, 250];
x_min = 100; x_max = 500;
y_min = 500; y_max = 1000;

for idx = 1:length(userCounts)
    K = userCounts(idx);
    T_rand = zeros(K,1);
    T_bf = zeros(K,1);
    totalRateRand = 0;
    totalRateBF = 0;

    % Generate user positions
    userPos = [x_min + (x_max - x_min) * rand(K,1), ...
               y_min + (y_max - y_min) * rand(K,1)];

    % Compute distances and path losses
    d_BS_IRS = norm(BS - IRS);
    alpha_BS_IRS = 2;
    beta_BS_IRS = 1 / d_BS_IRS^alpha_BS_IRS;

    d_IRS_user = vecnorm(userPos - IRS, 2, 2);
    d_BS_user = vecnorm(userPos - BS, 2, 2);
    beta_IRS_user = 1 ./ d_IRS_user.^2.8;
    beta_BS_user = 1 ./ d_BS_user.^3.6;

    for t = 1:numSlots
        h1 = (randn(N,1) + 1i*randn(N,1)) / sqrt(2); % BS to IRS
        h2 = (randn(N,K) + 1i*randn(N,K)) / sqrt(2); % IRS to users
        hd = (randn(1,K) + 1i*randn(1,K)) / sqrt(2); % Direct BS to users

        % Random IRS configuration
        theta_rand = 2*pi*rand(N,1);
        Theta_rand = diag(exp(1i*theta_rand));
        h_eff_rand = sqrt(beta_BS_IRS) * (sum(h2 .* (Theta_rand * h1), 1))' .* sqrt(beta_IRS_user) + sqrt(beta_BS_user) .* hd.';
        R_rand = log2(1 + P * abs(h_eff_rand).^2 / sigma2);
        PF_rand = R_rand ./ max(T_rand, 1e-6);
        [~, k_star_rand] = max(PF_rand);
        totalRateRand = totalRateRand + R_rand(k_star_rand);
        for k = 1:K
            if k == k_star_rand
                T_rand(k) = (1 - 1/tau) * T_rand(k) + (1/tau) * R_rand(k);
            else
                T_rand(k) = (1 - 1/tau) * T_rand(k);
            end
        end

        % Beamforming IRS configuration
        h_eff_bf = zeros(K,1);
        R_bf = zeros(K,1);
        PF_bf = zeros(K,1);
        for k = 1:K
            theta_bf = angle(hd(k)) - angle(h1 .* h2(:,k));
            Theta_bf = diag(exp(1i * theta_bf));
            h_eff_bf(k) = sqrt(beta_BS_IRS) * (h2(:,k)' * Theta_bf * h1) * sqrt(beta_IRS_user(k)) + sqrt(beta_BS_user(k)) * hd(k);
            R_bf(k) = log2(1 + P * abs(h_eff_bf(k))^2 / sigma2);
            PF_bf(k) = R_bf(k) / max(T_bf(k), 1e-6);
        end
        [~, k_star_bf] = max(PF_bf);
        totalRateBF = totalRateBF + R_bf(k_star_bf);
        for k = 1:K
            if k == k_star_bf
                T_bf(k) = (1 - 1/tau) * T_bf(k) + (1/tau) * R_bf(k);
            else
                T_bf(k) = (1 - 1/tau) * T_bf(k);
            end
        end
    end

    avgThroughputRandom(idx) = totalRateRand / numSlots;
    avgThroughputBF(idx) = totalRateBF / numSlots;
end

% Plotting
figure;
plot(userCounts, avgThroughputRandom, 'b-o', 'LineWidth', 2); hold on;
plot(userCounts, avgThroughputBF, 'r-s', 'LineWidth', 2);
xlabel('Number of Users');
ylabel('Average Throughput (bps/Hz)');
legend('Random IRS', 'Beamforming IRS');
title('Monte Carlo Simulation: IRS-Aided PF Scheduling');
grid on;
