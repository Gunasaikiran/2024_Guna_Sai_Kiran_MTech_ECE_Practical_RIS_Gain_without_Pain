clc
clear
% Define transition matrix for a simple DTMC
P = [0.3 0.7 0.0;
     0.2 0.5 0.3;
     0.1 0.2 0.7];

% Number of states
n = size(P, 1);

% Initial distribution (e.g., starting from state 1)
pi0 = [1 0 0];

% Compute stationary distribution
[V, D] = eig(P');
[~, idx] = min(abs(diag(D) - 1)); % Find eigenvalue closest to 1
pi_stationary = V(:, idx)';
pi_stationary = pi_stationary / sum(pi_stationary); % Normalize

% Total variation distance function
tv_distance = @(pi1, pi2) 0.5 * sum(abs(pi1 - pi2));

% Simulate the chain and compute total variation distance over time
max_steps = 100;
tv_distances = zeros(1, max_steps);
pi_t = pi0;

for t = 1:max_steps
    pi_t = pi_t * P; % Evolve distribution
    tv_distances(t) = tv_distance(pi_t, pi_stationary);
end

% Plot total variation distance
figure;
plot(1:max_steps, tv_distances, 'LineWidth', 2);
xlabel('Time Step');
ylabel('Total Variation Distance');
title('Mixing Time Estimation for DTMC');
grid on;

% Estimate mixing time (first time TV distance < epsilon)
epsilon = 0.001;
mixing_time = find(tv_distances < epsilon, 1);
fprintf('Estimated mixing time (TV distance < %.2f): %d steps\n', epsilon, mixing_time);