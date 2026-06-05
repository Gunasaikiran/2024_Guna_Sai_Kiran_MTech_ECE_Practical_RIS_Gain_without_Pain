clc;
clear;
close all;

% Define the file path
sourceDir = '/home/gunasaikiran/Desktop/5g_ExP/Dec27_RIS_expts_with_MCS_fast_adaptation_based_on_RSRP/GRID.xlsx';

% Read the table
T = readtable(sourceDir);

% Extract columns as numeric arrays
ris_on  = T{:,1};   % RIS ON throughput values
ris_off = T{:,2};   % RIS OFF throughput values

% Compute ECDF values
[f_on,x_on]   = ecdf(ris_on);
[f_off,x_off] = ecdf(ris_off);

% Extend curves to show 0 before increasing and 1 after saturating
x_on_ext  = [min(ris_on)-eps; x_on; max(ris_on)+eps];
f_on_ext  = [0; f_on; 1];

x_off_ext = [min(ris_off)-eps; x_off; max(ris_off)+eps];
f_off_ext = [0; f_off; 1];

% Plot
figure;
plot(x_on_ext,f_on_ext,'LineWidth',2); hold on;
plot(x_off_ext,f_off_ext,'LineWidth',2);

legend('RIS ON','RIS OFF','Location','best');
xlabel('Throughput');
ylabel('CDF');
title('CDF of Throughputs: RIS ON vs RIS OFF');
grid on;
