clc;
clear;
close all;
% Load MAT files
data1 = load('ALL_10_UES.mat');
Ts_values = data1.Ts_values;
tau_values = data1.tau_values;
LOS_10  = data1.Rate_benchmark_LOS;      % example
RR_benchmark_10  = data1.Rate_benchmark_RR;      % example
PF_10 = data1.Rate_matrix; 

%% --- Plot
figure;
colors = lines(length(Ts_values));
for ts_idx = 1:length(Ts_values)
    plot(tau_values, PF_10(ts_idx,:), '-o', 'LineWidth', 2, ...
        'Color', colors(ts_idx,:)); hold on;
end
% yline(RR_benchmark_10, 'k--', 'LineWidth', 2, 'DisplayName', 'Round-Robin + Optimal IRS');
% yline(LOS_10, 'LineWidth', 2, 'DisplayName', 'NO IRS');
RR_vec  = RR_benchmark_10 * ones(1,length(tau_values));
LOS_vec = LOS_10 * ones(1,length(tau_values));

plot(tau_values, RR_vec, 'k--s', 'LineWidth',2,'MarkerSize',7); hold on;
plot(tau_values, LOS_vec, '--d', 'LineWidth',2,'MarkerSize',7);
xlabel('PF parameter \tau'); ylabel('Average Rate (bps/Hz)');
legend_labels = [ ...
    arrayfun(@(x) sprintf('PF + Random IRS (T_s = %d)', x), Ts_values, 'UniformOutput', false), ...
    {'Round-Robin + Optimal IRS'} ...
{'NO IRS'}];
legend(legend_labels, 'Location', 'best');
title('PF Scheduling vs Optimal IRS Benchmark (K=10, Random IRS switching every T_s)');
grid on;
xticks(tau_values); xticklabels(string(tau_values));

%% --- Plot: Relative Throughput Error vs Tc with theorem bounds ---



% Parameters for theorem bound
eps1 = 0.1;  
eps2 = 0.1;  
eta1 = 0.1;  
eta2 = 0.1;
M = 10;        
p_min = 0.3;   % <-- IMPORTANT: set based on your RIS distribution
% Relative error (normalized infinity norm)
Rel_Error_matrix = abs(PF_10 - RR_benchmark_10) / RR_benchmark_10;
figure;
colors = lines(length(Ts_values));
line_handles  = gobjects(length(Ts_values),1);
bound_handles = gobjects(length(Ts_values),1);
theory_bound = 2*M*(eps1 + eps2);

for ts_idx = 1:length(Ts_values)

    % Relative error curve
    line_handles(ts_idx) = semilogx(tau_values, Rel_Error_matrix(ts_idx,:), '-o', ...
        'LineWidth',2,'Color',colors(ts_idx,:)); hold on;

    % Updated theorem bounds
    Tc_min1 = Ts_values(ts_idx) * (1/(2*eps1^2)) * log(2*M/eta1);
    Tc_min2 = (1/(2*(p_min - 2*eps1)*eps2^2)) * log(2*M/eta2);
    Tc_min  = max(Tc_min1, Tc_min2);

    % Create multiple y-values (log-spaced looks better)
    y_vals = [1,0.5,0.1,0.05,0.009];   % [1e-3 ... 1]

    % Same Tc_min repeated
    Tc_vec = Tc_min * ones(size(y_vals));

    % Plot markers
    bound_handles(ts_idx) = semilogx(Tc_vec, y_vals, '-o','HandleVisibility','off');
end
yline(eps1);
ylim([0.009 1]);
xlabel('Averaging Window $T_c$', 'Interpreter','latex');
ylabel('$\frac{\|\hat{\mathbf{T}}(T_c)-\mathbf{T}^*\|_\infty}{\|\mathbf{T}^*\|_\infty}$', ...
    'Interpreter','latex');

title('Relative Error vs $T_c$ with Theoretical Bounds', 'Interpreter','latex');

legend(arrayfun(@(x) sprintf('T_s = %d', x), Ts_values, 'UniformOutput', false), ...
    'Location','northeast');

grid on;
set(gca, 'YScale', 'log');  % better visualization for relative error