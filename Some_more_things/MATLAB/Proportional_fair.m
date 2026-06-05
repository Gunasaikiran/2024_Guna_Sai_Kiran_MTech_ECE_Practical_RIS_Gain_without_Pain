clc;
clear;
close all;
% Parameters
alpha = 0; % Channel correlation
sigma2 = 1; % Noise power
num_time_slots = 10000;
beta_values = linspace(1.0, 0.0001, 2000); % β from 1 to 0
user_counts = [5,20,40,60,80,100];

% Preallocate results
throughput_results = zeros(length(user_counts), length(beta_values));

for i = 1:length(user_counts)
    K = user_counts(i);
    for j = 1:length(beta_values)
        beta = beta_values(j);
        Tc = 1 / beta;
        T = zeros(K, 1);
        h = zeros(K, 1);
        total_throughput = 0;

        for t = 1:num_time_slots
            v = (randn(K,1) + 1i*randn(K,1)) / sqrt(2);
            h = alpha * h + sqrt(1 - alpha^2) * v;
            R = log2(1 + abs(h).^2 / sigma2);
            PF = R ./ (T + eps);
            [~, k_star] = max(PF);
            total_throughput = total_throughput + R(k_star);

            for k = 1:K
                if k == k_star
                    T(k) = (1 - 1/Tc) * T(k) + (1/Tc) * R(k);
                else
                    T(k) = (1 - 1/Tc) * T(k);
                end
            end
        end

        throughput_results(i, j) = total_throughput / num_time_slots;
    end
end

% Plotting
figure;
hold on;
for i = 1:length(user_counts)
    plot(1/beta_values, throughput_results(i,:), 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%d Users', user_counts(i)));
end
xlabel('Beta (1/Tc)');
ylabel('Average Throughput (bps/Hz)');
title('Average Throughput vs Beta for PF Scheduling');
legend('Location', 'best');
grid on;

