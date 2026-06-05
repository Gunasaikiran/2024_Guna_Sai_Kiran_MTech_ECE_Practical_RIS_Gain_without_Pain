clc
clear
clc;
clear;
tic
gamma = 0.99;
% Transition matrix
P = [0.6 0.3 0.1;
     0.2 0.6 0.2;
     0.1 0.3 0.6];

% Function f: happiness values
f = [3; 1; 2];  % Sunny, Cloudy, Rainy

% Compute stationary distribution
A = P' - eye(3);
A(end+1,:) = ones(1,3);
b = [zeros(3,1); 1];
pi = A\b;

% Expected value under stationary distribution
E_pi_f = sum(pi .* f);
g =(E_pi_f^2);
V_pi_f = sum(pi .* (f.^2))-g;
% Compute mixing time using total variation distance
dist = [1 0 0];  % Initial distribution: Cloudy
tv_distances = zeros(1, 500);
for t = 1:500
    dist = dist * P;
    tv_distances(t) = 0.5 * sum(abs(dist - pi'));
end

% Mixing time: first time TV distance < epsilon
epsilon = 0.01;
mixing_time = find(tv_distances < epsilon, 1);
gsk1=log(2/gamma);
gsk=(V_pi_f*gsk1);
% Estimate minimum T needed for convergence
delta = 0.01;
T_min1 = ceil(mixing_time + (gsk / (delta^2)));
T_min2 = ceil(mixing_time + (1/ delta^2));

% Simulate Markov chain
T = 1e6;
X = zeros(1, T);
X(1) = 2;  % Start from Cloudy

for t = 2:T
    X(t) = randsample(1:3, 1, true, P(X(t-1), :));
end
% Compute time average
f_values = f(X);
time_avg = cumsum(f_values(:)) ./ (1:T)';
toc
%% 

% Plot results
figure;

yyaxis left
plot(1:T, time_avg, 'b', 'LineWidth', 1.5); hold on;
yline(E_pi_f, 'r--', 'LineWidth', 2, 'Label', 'E_{\pi}(f)', 'LabelHorizontalAlignment', 'left');
xline(mixing_time, 'g--', 'LineWidth', 2, 'Label', ['Mixing Time = ' num2str(mixing_time)], 'LabelHorizontalAlignment', 'left');
xline(T_min1, 'k--', 'LineWidth', 2, 'Label', ['T_{min1} = ' num2str(T_min1)], 'LabelHorizontalAlignment', 'left');
xline(T_min2, 'k--', 'LineWidth', 2, 'Label', ['T_{min2} = ' num2str(T_min2)], 'LabelHorizontalAlignment', 'left');
xlabel('Time step');
ylabel('Time Average of f(X_t)');
title('Ergodic Theorem Convergence vs Mixing Time');
grid on;

yyaxis right
plot(1:500, tv_distances, 'm', 'LineWidth', 1.5);
ylabel('Total Variation Distance');

legend('Time Average', 'Expected Value', 'Mixing Time', 'T_{min1}','T_{min2}', 'TV Distance');
