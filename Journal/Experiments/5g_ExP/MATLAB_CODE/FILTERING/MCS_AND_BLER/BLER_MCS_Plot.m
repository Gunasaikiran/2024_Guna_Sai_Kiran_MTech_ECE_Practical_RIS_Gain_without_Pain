clc
clear

% Define the full paths to the Excel files
sourceDir0 = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/MCS_AND_BLER';

inputFile1 = fullfile(sourceDir0, 'MCS_values_UE_1.xlsx');
inputFile2 = fullfile(sourceDir0, 'MCS_values_UE_2.xlsx');

% Read data from Excel files
data1 = readmatrix(inputFile1);
data2 = readmatrix(inputFile2);

ue1_mcs = data1(:,2);
ue2_mcs = data2(:,2);
% 
% %% Envelope seen by system (max MCS across UEs)
% system_envelope = max(ue1_mcs, ue2_mcs);
% 
% % Smooth the envelope
% system_envelope_smooth = smooth(system_envelope, 8);  % adjust window if needed
% system_envelope_smooth = system_envelope_smooth + 2;
%% 
% Plot histograms (raw counts, no normalization)
figure;
histogram(ue1_mcs, 30, 'FaceColor', [0.2 0.6 0.8], 'FaceAlpha', 0.5);
hold on;
histogram(ue2_mcs, 30, 'FaceColor', [0.8 0.2 0.2], 'FaceAlpha', 0.5);
xlabel('MCS Index values');  
legend('UE-1','UE-2');
grid on;

%% Plot
figure;
plot(1:length(ue1_mcs), ue1_mcs, 'b', 'LineWidth', 2); hold on;
plot(1:length(ue2_mcs), ue2_mcs, 'r', 'LineWidth', 2);
% plot(1:length(system_envelope_smooth), system_envelope_smooth, ...
%      'g--', 'LineWidth', 2.5);

xlabel('Time samples per 1.28 seconds');
ylabel('BLER');
%'Envelop seen by system'
legend('UE-1', 'UE-2');
xlim([0 120])
ylim([0 0.7])
grid on;
hold off;
