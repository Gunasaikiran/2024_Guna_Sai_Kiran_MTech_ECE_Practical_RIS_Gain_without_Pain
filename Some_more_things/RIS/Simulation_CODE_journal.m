%%% Code by GSK, MTECH 2024–2026
%%% PF Scheduling with Random UEs and Random IRS States
%%% Comparison: LOS only | RR + Optimal IRS | PF + Random IRS
%%% Adjusted: PF scheduling every slot; IRS switches every Ts slots


clc; 
close all;
clear;
tic;

%% Parameters
N = 256;                     % IRS elements
K = 10;                       % Number of users
txt_SNR_dB = 110;             % SNR (dB)
txt_SNR_lin = 10^(txt_SNR_dB/10);
Number_of_setups = 4;        % Monte Carlo iterations

%1800,
%Ts_values = [200, 1000, 1800]; 
Ts_values = [200, 1000, 3000]; % IRS switching intervals (slots)
tau_values =[2,200,2000,20000, 500000, 1000000];         % PF averaging memory

%% Fixed Positions

BS_locate = [0; 0];
IRS_locate = [60;20];
max_x_UE_locate = 120; min_x_UE_locate = 70;
max_y_UE_locate = 20;  min_y_UE_locate = -20;

%% Results storage
Rate_matrix_all = zeros(Number_of_setups, length(Ts_values), length(tau_values));
Rate_benchmark_LOS_all = zeros(1, Number_of_setups);
Rate_benchmark_RR_all  = zeros(1, Number_of_setups);

%% Monte Carlo loop
for setup = 1:Number_of_setups
    %fprintf('Starting Setup %d\n', setup);

    %% --- UE random positions ---
    UEs_locate_x = (max_x_UE_locate - min_x_UE_locate) * rand(1, K) + min_x_UE_locate;
    UEs_locate_y = (max_y_UE_locate - min_y_UE_locate) * rand(1, K) + min_y_UE_locate;
    UE_loc = [UEs_locate_x; UEs_locate_y];

    %% --- Channel and Path Loss ---
    eta_d = 4.1; eta_BS_IRS = 2; eta_IRS_UE = 2.3;
    C0_lin = 0.001;

    dist_BS_IRS = norm(BS_locate - IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate - UE_loc);
    dist_BS_UE  = vecnorm(BS_locate - UE_loc);

    beta_BS_IRS = C0_lin * ((1 / dist_BS_IRS)^eta_BS_IRS);
    beta_BS_UE  = C0_lin * ((1 ./ dist_BS_UE).^eta_d);
    beta_IRS_UE = C0_lin * ((1 ./ dist_IRS_UE).^eta_IRS_UE);

    % Small-scale fading (Rayleigh)
    h_BS_IRS = sqrt(beta_BS_IRS/2) * (randn(N, 1) + 1i * randn(N, 1));
    h_IRS_UE = sqrt(beta_IRS_UE/2) .* (randn(N, K) + 1i * randn(N, K));
    h_BS_UE  = sqrt(beta_BS_UE)   .* (randn(1, K) + 1i * randn(1, K));

    %% --- LOS Only Benchmark ---
    rate_los = log2(1 + (abs(h_BS_UE).^2) * txt_SNR_lin);
    Rate_benchmark_LOS_all(setup) = mean(rate_los);

    %% --- Optimal IRS Configurations (one per UE) ---
    IRS_config_user = cell(1, K);

    for k = 1:K
        phase_opt = angle(h_BS_UE(k))-(angle(h_IRS_UE(:, k)) + angle(h_BS_IRS));
        IRS_config_user{k} = diag(exp(1j * phase_opt));
    end

    %% --- PF Scheduling + Random IRS (IRS switches every Ts slots) ---
    local_rate_matrix = zeros(length(Ts_values), length(tau_values));
    local_rate_matrix_1 = zeros(length(Ts_values), length(tau_values));
    for ts_idx = 1:length(Ts_values)
        Ts = Ts_values(ts_idx);
        %fprintf('Setup %d: PF Scheduling (Ts = %d)\n', setup, Ts);
        
        for tau_idx = 1:length(tau_values)
            tau = tau_values(tau_idx);
            tot_time_slots = tau * 100;
            %fprintf('Setup %d: Ts = %d: PF Scheduling (Tc = %d)\n', setup, Ts,tau);
            rate_random = zeros(1, tot_time_slots);
            T_k = ones(1, K);              % PF average throughput init

            % Initialize IRS state for the first block
            rand_user = randi(K);
            IRS_config_diag = IRS_config_user{rand_user};
            rate_rr_opt = zeros(1, tot_time_slots);
            for t = 1:tot_time_slots
                %% --- Round-Robin + Optimal IRS Benchmark ---
                k_rr = mod(t - 1, K) + 1;
                IRS_config_diag_RR = IRS_config_user{k_rr};  % IRS aligned to current RR user
                h_eff_RR = h_BS_UE(k_rr) + (h_IRS_UE(:, k_rr).') * IRS_config_diag_RR * h_BS_IRS;
                rate_rr_opt(t) = log2(1 + (abs(h_eff_RR)^2) * txt_SNR_lin);
                % IRS switches only every Ts slots
                if mod(t - 1, Ts) == 0
                    rand_user = randi(K);
                    IRS_config_diag = IRS_config_user{rand_user};
                end
                fprintf('Setup %d: Ts = %d: PF Scheduling Tc = %d Timeslot T = %d\n', setup, Ts,tau,t);
                % Effective channels for all users with current IRS state
                h_eff = h_BS_UE + (h_IRS_UE.' * IRS_config_diag * h_BS_IRS).';
                rate_inst = log2(1 + (abs(h_eff).^2) * txt_SNR_lin);

                % PF metric and scheduling (per slot)
                PF_metric = rate_inst ./ T_k;
                [~, k_sch] = max(PF_metric);

                % PF averaging memory update
                T_k = (1 - 1/tau) * T_k;
                T_k(k_sch) = T_k(k_sch) + (1/tau) * rate_inst(k_sch);

                % Record scheduled rate
                rate_random(t) = rate_inst(k_sch);
            end
            
            local_rate_matrix(ts_idx, tau_idx) = mean(rate_random);
            local_rate_matrix_1(ts_idx, tau_idx) = sum(T_k);
            Rate_benchmark_RR_all(setup) = mean(rate_rr_opt);
        end
        
    end

    Rate_matrix_all(setup, :, :) = local_rate_matrix_1;
    
end

%% --- Averages over setups ---
Rate_matrix = squeeze(mean(Rate_matrix_all, 1));
Rate_benchmark_RR  = mean(Rate_benchmark_RR_all);
Rate_benchmark_LOS = mean(Rate_benchmark_LOS_all);

toc;
delete(gcp('nocreate'));
% save('ALL_10_UES.mat');