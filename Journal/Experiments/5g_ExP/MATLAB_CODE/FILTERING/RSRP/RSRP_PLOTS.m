clc;
clear;
close all;

% Define the full paths to the Excel files
sourceDir0 = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/RSRP';

inputFile1 = fullfile(sourceDir0, 'RSRP_values_UE_1.xlsx');
inputFile2 = fullfile(sourceDir0, 'RSRP_values_UE_2.xlsx');

% Read data from Excel files
data1 = readmatrix(inputFile1);
data2 = readmatrix(inputFile2);

firstColumn1 = data1(:,1);
firstColumn2 = data2(:,1);
%% 

% Plot histograms (raw counts, no normalization)
figure;
histogram(firstColumn1, 30, 'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.5);
hold on;
histogram(firstColumn2, 30, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.5);
xlabel('RSRP values');
ylabel('Count');  
legend('UE-1','UE-2');
grid on;

%% 

% Plot the throughput time traces
figure;
plot(1:length(firstColumn1), firstColumn1, 'b', 'LineWidth', 2);
hold on;
plot(1:length(firstColumn2), firstColumn2, 'r', 'LineWidth', 2);
xlabel('Time samples per 1.28 seconds');
ylabel('RSRP (in dBm)');
ylim([-111 -96])
xlim([0 120])
legend('UE - 1', 'UE - 2');
grid on;


hold off;
