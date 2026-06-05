clc;
clear;
% close all;

case_counts = [40907, 137745, 53253, 165578];   % [C1, C2, C3, C4]

% Convert counts to fractions of total
total_cases = sum(case_counts);
fractions = case_counts / total_cases;

% Labels for each configuration
config_labels = {'C_1','C_2','C_3','C_4'};




% Plot each bar separately so legend works
figure;
hold on;
b = bar(1, fractions(1), 'FaceColor', [0.2 0.6 0.8]);
b2 = bar(2, fractions(2), 'FaceColor', [0.4 0.7 0.2]);
b3 = bar(3, fractions(3), 'FaceColor', [0.8 0.4 0.2]);
b4 = bar(4, fractions(4), 'FaceColor', [0.6 0.2 0.8]);
hold off;
set(gca, 'XTick', 1:4, ...
         'XTickLabel', config_labels, ...
         'FontName', 'Calibri', ...
         'FontSize', 12, ...
         'TickLabelInterpreter', 'tex');
ylabel('Fraction of time slots', 'FontSize', 12);
ylim([0 0.5]);
grid on;



% Optional: add value labels on top of bars
text(1:4, fractions, ...
     arrayfun(@(x) sprintf('%.2f', x), fractions, 'UniformOutput', false), ...
     'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);
