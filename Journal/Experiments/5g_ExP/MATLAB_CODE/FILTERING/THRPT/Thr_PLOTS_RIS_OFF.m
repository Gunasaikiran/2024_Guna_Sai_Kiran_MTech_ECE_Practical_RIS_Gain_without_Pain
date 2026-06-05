clc
clear

sourceDir0 = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/THRPT';

inputFile1 = fullfile(sourceDir0, 'Throughput_values_1.xlsx');
inputFile2 = fullfile(sourceDir0, 'Throughput_values_2.xlsx');


% Read data from Excel files
data1 = readmatrix(inputFile1);
data2 = readmatrix(inputFile2);

% Extract first column and remove the last row (average)
firstColumn1 = data1(1:end-1, 1);
firstColumn2 = data2(1:end-1, 1);
%% 
% Plot histograms (raw counts, no normalization)
figure;
histogram(firstColumn1, 30, 'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.5);
hold on;
histogram(firstColumn2, 30, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.5);
xlabel('Thrpt values');
legend('UE-1','UE-2');
grid on;
%% 

% Extract average throughput from the last row
avg1 = data1(end, 1);
avg2 = data2(end, 1);

% Plot the throughput time traces
figure;
plot(1:length(firstColumn1), firstColumn1, 'b', 'LineWidth', 2);
hold on;
plot(1:length(firstColumn2), firstColumn2, 'r', 'LineWidth', 2);
xlim([0 120])
xlabel('Time samples per 1.28 seconds');
ylabel('Throughput (in Mbps)');
legend('UE - 1', 'UE - 2');
grid on;

% % Add a text box with average throughput values
% textStr = sprintf('Average Throughput RIS ON:\nUser 1: %.2f\nUser 2: %.2f\nAverage Throughput RIS OFF:\nUser 1: %.2f\nUser 2: %.2f', avg1, avg2,avg3,avg4);
% annotation('textbox', [0.15, 0.75, 0.2, 0.1], 'String', textStr, ...
%     'FitBoxToText', 'on', 'BackgroundColor', 'w', 'EdgeColor', 'k');

hold off;
