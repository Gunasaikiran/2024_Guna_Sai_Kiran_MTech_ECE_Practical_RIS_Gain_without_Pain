clc;
clear;
close all;

% Define the file path
sourceDir = '/home/gunasaikiran/Desktop/5g_ExP/Dec27_RIS_expts_with_MCS_fast_adaptation_based_on_RSRP/Throuphut_date.xlsx';

% Read the table
T = readtable(sourceDir);

% PF case (3 alphas)
T_c = 1./[0.005, 0.0005, 0.00005];
T_cs = fliplr(T_c);  % Plot decreasing alpha
%RR+Optimal RIS
user1_c4 = T{1, 2}; user2_c4 = T{1, 3};
System_throughput_RR_Optimal_RIS = (user1_c4 + user2_c4)/2;

%RR+random RIS Case -1
user1_c2_a = T{1:2, 2}; user2_c2_a = T{1:2, 3};
System_throughput_RR_random_RIS_a = sum((user1_c2_a + user2_c2_a)/4);

%RR+random RIS Case -2 (Tc_3)
user1_c2_b_Tc_3 = T{3, 2}; user2_c2_b_Tc_3 = T{3, 3};
System_throughput_RR_random_RIS_b_Tc_3 = (user1_c2_b_Tc_3 + user2_c2_b_Tc_3)/2;
%RR+random RIS Case -2 (Tc_5)
user1_c2_b_Tc_5 = T{4, 2}; user2_c2_b_Tc_5 = T{4, 3};
System_throughput_RR_random_RIS_b_Tc_5 = (user1_c2_b_Tc_5 + user2_c2_b_Tc_5)/2;
%RR+random RIS Case -2 (Tc_9)
user1_c2_b_Tc_9 = T{5, 2}; user2_c2_b_Tc_9 = T{5, 3};
System_throughput_RR_random_RIS_b_Tc_9 = (user1_c2_b_Tc_9 + user2_c2_b_Tc_9)/2;
%RR+random RIS Case -2 (Tc_15)
user1_c2_b_Tc_15 = T{6, 2}; user2_c2_b_Tc_15 = T{6, 3};
System_throughput_RR_random_RIS_b_Tc_15 = (user1_c2_b_Tc_15 + user2_c2_b_Tc_15)/2;

System_throughput_RR_random_RIS_b = (System_throughput_RR_random_RIS_b_Tc_3+System_throughput_RR_random_RIS_b_Tc_5+System_throughput_RR_random_RIS_b_Tc_9+System_throughput_RR_random_RIS_b_Tc_15)/4;
%PF + Random RIS Ts = 3 sec
user1_c3_Ts_3 = flipud(T{7:9, 2});
user2_c3_Ts_3 = flipud(T{7:9, 3});
System_throughput_PF_Ts_3 = user1_c3_Ts_3 + user2_c3_Ts_3;

%PF + Random RIS Ts = 5 sec
user1_c3_Ts_5 = flipud(T{10:12, 2});
user2_c3_Ts_5 = flipud(T{10:12, 3});
System_throughput_PF_Ts_5 = user1_c3_Ts_5 + user2_c3_Ts_5;

%PF + Random RIS Ts = 9 sec
user1_c3_Ts_9 = flipud(T{13:15, 2});
user2_c3_Ts_9 = flipud(T{13:15, 3});
System_throughput_PF_Ts_9 = user1_c3_Ts_9 + user2_c3_Ts_9;

%PF + Random RIS Ts = 15 sec
user1_c3_Ts_15 = flipud(T{16:18, 2});
user2_c3_Ts_15 = flipud(T{16:18, 3});
System_throughput_PF_Ts_15 = user1_c3_Ts_15 + user2_c3_Ts_15;


% RIS Off + RR
user1_c1_a = T{19, 2}; user2_c1_a = T{19, 3};
System_throughput_RIS_OFF_RR = (user1_c1_a + user2_c1_a)/2;

% RIS Off + PF
user1_c1_b = flipud(T{20:22, 2}); 
user2_c1_b = flipud(T{20:22, 3});
System_throughput_RIS_OFF_PF = user1_c1_b + user2_c1_b;



% %% 
% 
% % Plotting
% figure;
% 
% % RR Optimal RIS
% plot(T_cs, System_throughput_RR_Optimal_RIS * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Optimal RIS');
% hold on;
% 
% %RR Random RIS Case a
% %plot(T_cs, System_throughput_RR_random_RIS_a * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Random RIS case - a');
% %RR Random RIS Case a
% %plot(T_cs, System_throughput_RR_random_RIS_b * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Random RIS case - b');
% % %RR Random RIS Ts = 3sec
% plot(T_cs, System_throughput_RR_random_RIS_b_Tc_3 * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR + Random RIS');
% % %RR Random RIS Ts = 5sec
% %plot(T_cs, System_throughput_RR_random_RIS_b_Tc_5 * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Random RIS Ts = 5 sec');
% % %RR Random RIS Ts = 9sec
% %plot(T_cs, System_throughput_RR_random_RIS_b_Tc_9 * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Random RIS Ts = 9 sec');
% % %RR Random RIS Ts = 15sec
% %plot(T_cs, System_throughput_RR_random_RIS_b_Tc_15 * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Random RIS Ts = 15 sec');
% % 
% % % PF Scheduling TS = 3sec
% %plot(T_cs, System_throughput_PF_Ts_3,'LineWidth', 2, 'DisplayName', 'PF Scheduling, Ts = 3 sec');
% % PF Scheduling TS = 5sec
% plot(T_cs, System_throughput_PF_Ts_5,'LineWidth', 2, 'DisplayName', 'PF Scheduling, Ts = 5 sec');
% % % PF Scheduling TS = 9sec
% %plot(T_cs, System_throughput_PF_Ts_9,'LineWidth', 2, 'DisplayName', 'PF Scheduling, Ts = 9 sec');
% % % PF Scheduling TS = 15sec
% %plot(T_cs, System_throughput_PF_Ts_15,'LineWidth', 2, 'DisplayName', 'PF Scheduling, Ts = 15 sec');
% 
% % RIS OFF RR
% plot(T_cs, System_throughput_RIS_OFF_RR * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RIS OFF + RR');
% % RIS OFF PF
% plot(T_cs, System_throughput_RIS_OFF_PF ,'LineWidth', 2, 'DisplayName', 'RIS OFF + PF');
% 
% % Formatting
% xlabel('T_c');
% xlim([200 20000])
% ylabel('System Throughput');
% title('System Throughput vs T_c');
% legend('Location', 'best');
% grid on;
% set(gca, 'XScale', 'log');  % Log scale for alpha
% %set(gca, 'YScale', 'log');  % Log scale for alpha
% % ax = gca;
% % get(ax,'YLim')
% % ax = gca;
% % ylim(ax,[0 55]);              % make sure 25–40 is inside
% % breakyaxis(ax,[28 43]); 
%% Throughput vs Ts for different Tc values

% Ts values
Ts_values = [3, 5, 15];

% Build a matrix where:
%   rows = Ts values [3; 5; 9; 15]
%   cols = Tc values [200, 2000, 20000]
PF_matrix = [
    System_throughput_PF_Ts_3.';   % [Tc=200, Tc=2000, Tc=20000]
    System_throughput_PF_Ts_5.';   % [Tc=200, Tc=2000, Tc=20000]
  % [Tc=200, Tc=2000, Tc=20000]
    System_throughput_PF_Ts_15.'   % [Tc=200, Tc=2000, Tc=20000]
];

% % RR random RIS (same across Tc for each Ts) → single curve vs Ts
RR_random_RIS_vec = [
    System_throughput_RR_random_RIS_b_Tc_3, ...
    System_throughput_RR_random_RIS_b_Tc_5, ...
    System_throughput_RR_random_RIS_b_Tc_15 ...
];

% Labels for Tc columns
Tc_labels = [200, 2000, 20000];

% Plot
figure; hold on;
plot(Ts_values, PF_matrix(:,1), '-o', 'LineWidth', 2, 'DisplayName', 'PF, Tc = 20000');
plot(Ts_values, PF_matrix(:,2), '-s', 'LineWidth', 2, 'DisplayName', 'PF, Tc = 2000');
plot(Ts_values, PF_matrix(:,3), '-^', 'LineWidth', 2, 'DisplayName', 'PF, Tc = 200');

% RR random RIS (independent of Tc)
plot(Ts_values, RR_random_RIS_vec, '--d', 'LineWidth', 2, 'DisplayName', 'RR Random RIS (case b)');

% Optional reference lines (constant w.r.t Ts)
yline(System_throughput_RR_Optimal_RIS, ':', 'LineWidth', 2, 'DisplayName', 'RR Optimal RIS');
%yline(System_throughput_RIS_OFF_RR, ':', 'LineWidth', 2, 'DisplayName', 'RIS OFF + RR');
xlabel('T_s (s)');
legend('Location','best');
ylabel('System Throughput');
title('System Throughput vs T_s for different T_c');
grid on;
% ax = gca;
% get(ax,'YLim')
% ax = gca;
%ylim(ax,[0 55]);              % make sure 25–40 is inside
%breakyaxis(ax,[29 38]);       
%% 
figure;
%RR Optimal RIS
plot(T_cs, System_throughput_RR_Optimal_RIS * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR Optimal RIS');
hold on;
plot(T_cs, System_throughput_RR_random_RIS_b_Tc_3 * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RR + Random RIS');
plot(T_cs, System_throughput_PF_Ts_5,'LineWidth', 2, 'DisplayName', 'PF Scheduling, Ts = 5 sec');

% RIS OFF RR
plot(T_cs, System_throughput_RIS_OFF_RR * ones(size(T_cs)),'LineWidth', 2, 'DisplayName', 'RIS OFF + RR');
% RIS OFF PF
plot(T_cs, System_throughput_RIS_OFF_PF ,'LineWidth', 2, 'DisplayName', 'RIS OFF + PF');

% Formatting
xlabel('T_c');
xlim([200 20000])
ylabel('System Throughput');
title('System Throughput vs T_c');
legend('Location', 'best');
grid on;
set(gca, 'XScale', 'log');  % Log scale for alpha

