clc; close all; clear; tic;

%% Parameters
N = 16; % IRS elements
txt_SNR_dB = 107.83;
txt_SNR_lin = 10^(txt_SNR_dB/10);
max_K = 50;
K_subset_points = [1,2,4,10,25,50];
tau = 5;
tot_time_slots = 50;
Number_of_setups = 1e3;

%% Discrete IRS phase setup using FFT
DFT_codebook = fft(eye(N)); % N x N DFT matrix

%% UE location bounds
BS_locate = [0;0];
IRS_locate = [0;250];
max_x_UE_locate = 500; min_x_UE_locate = 100;
max_y_UE_locate = 1000; min_y_UE_locate = 500;

%% Result storage
Rate_randomIRS = zeros(Number_of_setups,length(K_subset_points));
Rate_beamformingBenchmark = zeros(Number_of_setups,length(K_subset_points));

%% Monte Carlo loop
for setup = 1:Number_of_setups
    % UE placement
    UEs_x = (rand(1,max_K)*(max_x_UE_locate-min_x_UE_locate))+min_x_UE_locate;
    UEs_y = (rand(1,max_K)*(max_y_UE_locate-min_y_UE_locate))+min_y_UE_locate;
    UE_loc = [UEs_x;UEs_y];

    % Path loss
    eta_d = 3.6; eta_BS_IRS = 2; eta_IRS_UE = 2.8;
    C0_lin = 1;
    dist_BS_IRS = vecnorm(BS_locate-IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate-UE_loc);
    dist_BS_UE = vecnorm(BS_locate-UE_loc);
    beta_BS_IRS = C0_lin*((1/dist_BS_IRS)^eta_BS_IRS);
    beta_BS_UE = C0_lin*((1./dist_BS_UE).^eta_d);
    beta_IRS_UE = C0_lin*((1./dist_IRS_UE).^eta_IRS_UE);

    % Small scale fading
    h_BS_IRS = sqrt(beta_BS_IRS/2)*(randn(N,1)+1i*randn(N,1));
    h_IRS_UE = sqrt(beta_IRS_UE/2).*(randn(N,max_K)+1i*randn(N,max_K));
    h_BS_UE = sqrt(beta_BS_UE).*(randn(1,max_K)+1i*randn(1,max_K));

    idx = 1;

    for K = K_subset_points
        h_IRS_UE_K = h_IRS_UE(:,1:K);
        h_BS_UE_K = h_BS_UE(1:K);

        %% 1. PF Scheduling with Random IRS (from FFT matrix)
        T_k = zeros(1,K);
        rate_random = zeros(1,tot_time_slots);

        for t = 1:tot_time_slots
            disp(['setup = ', num2str(setup), ', K = ', num2str(K), ', slot = ', num2str(t)]);

            % Randomly select one column from FFT matrix
            IRS_config_vector = DFT_codebook(:, randi(N));
            IRS_config_diag = diag(IRS_config_vector);

            % Effective channel
            h_eff = transpose(h_BS_UE_K.' + ...
                (h_IRS_UE_K.' * IRS_config_diag * h_BS_IRS));

            rate_inst = log2(1 + (abs(h_eff).^2)*txt_SNR_lin);
            PF_metric = rate_inst ./ T_k;
            [~, k_sch] = max(PF_metric);

            T_k = (1 - 1/tau)*T_k;
            T_k(k_sch) = T_k(k_sch) + (1/tau)*rate_inst(k_sch);

            rate_random(t) = rate_inst(k_sch);
        end
        Rate_randomIRS(setup,idx) = sum(T_k);

        %% 2. Beamforming Benchmark (Discrete Phase Search, Round-Robin)
        BF_rate_k = zeros(1,K);
        for k = 1:K
            best_rate = 0;
            for l = 1:N
                IRS_config_diag = diag(DFT_codebook(:, l));
                h_opt = h_BS_UE_K(k) + (h_IRS_UE_K(:,k).') * IRS_config_diag * h_BS_IRS;
                rate_l = log2(1 + (abs(h_opt)^2)*txt_SNR_lin);
                if rate_l > best_rate
                    best_rate = rate_l;
                end
            end
            BF_rate_k(k) = best_rate;
        end
        Rate_beamformingBenchmark(setup,idx) = mean(BF_rate_k);

        idx = idx + 1;
    end
end
toc;

%% Averaging over setups
Rate_avg = mean(Rate_randomIRS, 1); 
Rate_beam = mean(Rate_beamformingBenchmark, 1);

%% Plotting
figure;
plot(K_subset_points, Rate_avg, 'b-o', 'LineWidth', 2); hold on;
plot(K_subset_points, Rate_beam, 'r--s', 'LineWidth', 2);
xlabel('Number of Users (K)');
ylabel('Average Rate (bps/Hz)');
legend('PF Scheduling (Random IRS)', ...
       'Beamforming Benchmark (Discrete Phase Search)', ...
       'Location', 'best');
title('Rate vs Number of Users with Discrete IRS Phases (FFT)');
grid on;
