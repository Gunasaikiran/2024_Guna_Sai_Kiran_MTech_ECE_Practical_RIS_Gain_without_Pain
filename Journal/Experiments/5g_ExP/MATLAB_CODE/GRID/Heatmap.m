clc
clear
close all

%% Grid definition
angles = [15 30 60 75];
dist_labels = {'d1','d2','d3'};

%% ================= INPUT YOUR DATA =================
% format: rows = distance, columns = [00 01 10 11]

% UE1 Throughput (RIS ON)
UE1_on = [
18.5 22.7 26.2 30.1;
22.7 19.5 23.3 27.2;
25.6 11.7 23 25.5
];                                       

% UE2 Throughput (RIS ON)
UE2_on = [
25.9 29.4 14.4 25.4;
17.2 27.3 16.1 26.8;
15.3 29.7 16.5 26
];

% UE1 Throughput (RIS OFF)
UE1_off = [
15.3 21.6 10.8 16.1;
13.9 15.3 9.8 12.9;
12.6 19.1 9.6 10.6
];

% UE2 Throughput (RIS OFF)
UE2_off = [
17 18.3 10.5 11.2;
13.6 21.8 12.3 13.6;
14.1 19.1 9.28 14
];

%% ================================================

heat_on = zeros(3,4);
heat_off = zeros(3,4);

for i = 1:3
    
    %% RIS ON
    
    r1 = UE1_on(i,:);
    r2 = UE2_on(i,:);
    
    angle15 = mean([r1(1) r1(2)]);
    angle30 = mean([r1(3) r1(4)]);
    
    angle60 = mean([r2(2) r2(4)]);
    angle75 = mean([r2(1) r2(3)]);
    
    heat_on(i,:) = [angle15 angle30 angle60 angle75];
    
    
    %% RIS OFF
    
    r1 = UE1_off(i,:);
    r2 = UE2_off(i,:);
    
    angle15 = mean([r1(1) r1(2)]);
    angle30 = mean([r1(3) r1(4)]);
    
    angle60 = mean([r2(2) r2(4)]);
    angle75 = mean([r2(1) r2(3)]);
    
    heat_off(i,:) = [angle15 angle30 angle60 angle75];
    
end

% %% RIS Gain
% gain = heat_on - heat_off;
% 
% %% Plot
% 
% figure('Position',[200 200 1400 400])
% 
% subplot(1,3,1)
% imagesc(angles,1:3,heat_off)
% colorbar
% colormap(jet)
% title('RIS OFF Throughput')
% xlabel('Angle (degrees)')
% ylabel('Distance from RIS')
% yticks(1:3)
% yticklabels(dist_labels)
% set(gca,'FontSize',12)
% 
% subplot(1,3,2)
% imagesc(angles,1:3,heat_on)
% colorbar
% colormap(jet)
% title('RIS ON Throughput')
% xlabel('Angle (degrees)')
% ylabel('Distance from RIS')
% yticks(1:3)
% yticklabels(dist_labels)
% set(gca,'FontSize',12)
% 
% subplot(1,3,3)
% imagesc(angles,1:3,gain)
% colorbar
% colormap(jet)
% title('RIS Throughput Gain')
% xlabel('Angle (degrees)')
% ylabel('Distance from RIS')
% yticks(1:3)
% yticklabels(dist_labels)
% set(gca,'FontSize',12)

%% 
clim_min = min([heat_on(:); heat_off(:)]);
clim_max = max([heat_on(:); heat_off(:)]);
figure('Position',[200 200 1400 400])

subplot(1,2,1)
imagesc(angles,1:3,heat_off)
colorbar
colormap(jet)
caxis([clim_min clim_max])
title('RIS OFF Throughput')
xlabel('Angle (degrees)')
ylabel('Distance from RIS')
yticks(1:3)
yticklabels(dist_labels)

subplot(1,2,2)
imagesc(angles,1:3,heat_on)
colorbar
colormap(jet)
caxis([clim_min clim_max])
title('RIS ON Throughput')
xlabel('Angle (degrees)')
ylabel('Distance from RIS')
yticks(1:3)
yticklabels(dist_labels)

% subplot(1,3,3)
% imagesc(angles,1:3,gain)
% colorbar
% colormap(jet)
% title('RIS Throughput Gain')
% xlabel('Angle (degrees)')
% ylabel('Distance from RIS')
% yticks(1:3)
% yticklabels(dist_labels)
