% Written by Yashvanth, IISc Bangalore

clear all;
tic;
N = 100; % Number of IRS elements
txt_SNR_dB = 70; % in dB
txt_SNR_lin = 10^(txt_SNR_dB/10); % txt SNR in linear scale
max_K = 1000; % Total number of UEs
K_subset_points = [1,2,4,8,10,25,50,100,500,1000];
tau = 5000; % The constant in PF scheduler
tot_time_slots = 50000; % Total number of time slots
Number_of_setups = 100;

%% Large scale channel modeling

BS_locate = [0;0]; % location of BS
IRS_locate = [100;0]; % location of IRS
max_x_UE_locate = 120;
min_x_UE_locate = 80;
max_y_UE_locate = 20;
min_y_UE_locate = -20;

Rate_this_UE_index = zeros(Number_of_setups,length(K_subset_points));
Final_BF_rate_this_UE_index = zeros(Number_of_setups,length(K_subset_points));

for large_scale_loop = 1:Number_of_setups
    
    UEs_locate_x = (rand(1,max_K)*(max_x_UE_locate-min_x_UE_locate))+min_x_UE_locate;
    UEs_locate_y = (rand(1,max_K)*(max_y_UE_locate-min_y_UE_locate))+min_y_UE_locate;
    UE_locate = [UEs_locate_x;UEs_locate_y];
    eta_d = 4.5;
    eta_BS_IRS = 1.5;
    eta_IRS_UE = 2;
    C0_dB = 0;%-30; % Reference path loss in dB
    C0_lin = 10^(C0_dB/10);
    dist_BS_IRS = vecnorm(BS_locate-IRS_locate);
    dist_IRS_UE = vecnorm(IRS_locate-UE_locate);
    dist_BS_UE = vecnorm(BS_locate-UE_locate);
    beta_BS_IRS = C0_lin*((1/dist_BS_IRS)^eta_BS_IRS);
    beta_BS_UE = C0_lin*((1./dist_BS_UE).^eta_d);
    beta_IRS_UE = C0_lin*((1./dist_IRS_UE).^eta_IRS_UE);
    
    % Final path-losses
    beta_d = beta_BS_UE;
    beta_r = beta_BS_IRS.*beta_IRS_UE;
    
    %% Small scale fading
    
    cascaded_fading_ch_BS_IRS = sqrt(beta_BS_IRS/2)*(randn(N,1)+1i*randn(N,1));
    cascaded_fading_ch_IRS_UE = sqrt(beta_IRS_UE/2).*(randn(N,max_K)+1i*randn(N,max_K));
    direct_fading_ch_BS_UE = sqrt(beta_BS_UE).*(randn(1,max_K)+1i*randn(1,max_K));
    innner_loop_K_index = 1;
    
    
    % IRS configurations across time slots for opp. scheduling
    IRS_config = exp(1i*((rand(N,tot_time_slots)*(2*pi))-pi));
    
    for K_subset = K_subset_points
        
        % Selected channels
        selected_cascaded_ch_BS_IRS = cascaded_fading_ch_BS_IRS;
        selected_cascaded_ch_IRS_UE = cascaded_fading_ch_IRS_UE(:,1:K_subset);
        selected_direct_ch_BS_UE = direct_fading_ch_BS_UE(1:K_subset);
        
        
        %% Opportunistic scheduling based performance
        
        % Beginning of time slots
        T_k = zeros(1,K_subset);
        rate_this_slot = zeros(1,tot_time_slots);
        for time_slot = 1:tot_time_slots
            
            % Printing over console
            print_text_1 = sprintf('setup value = %d, K value = %d, slot no = %d',large_scale_loop,K_subset,time_slot);
            disp(print_text_1);
            
            % UE scheduling using the PF metric
            instant_ch_K_subset_UEs = transpose(selected_direct_ch_BS_UE.' + (selected_cascaded_ch_IRS_UE.'*...
                diag(IRS_config(:,time_slot))*selected_cascaded_ch_BS_IRS));
            instant_UE_rate = log2(1+(abs(instant_ch_K_subset_UEs).^2)*txt_SNR_lin);
            PF_metric = instant_UE_rate./T_k;
            [~,k_sch] = max(PF_metric);
            
            % Updating the Average rate
            for k=1:K_subset
                if(k==k_sch)
                    T_k(k) = ((1-(1/tau))*T_k(k)) + ((1/tau)*instant_UE_rate(k));
                else
                    T_k(k) = T_k(k);
                end
            end
            
            % Enumerating the Opportunsitic rate
            rate_this_slot(time_slot) = instant_UE_rate(k_sch);
            
        end
        
        Rate_this_UE_index(large_scale_loop,innner_loop_K_index) = mean(rate_this_slot);
        
        %% Round-robin based scheduling - the benchmark performance
        
        BF_rate_k = zeros(1,K_subset);
        for k=1:K_subset
            
            % Determining the optimal IRS config
            opt_IRS_config = zeros(N,1);
            for n=1:N
                opt_IRS_config(n) = exp(1i*(angle(selected_direct_ch_BS_UE(k))...
                    -angle(selected_cascaded_ch_BS_IRS(n))-angle(selected_cascaded_ch_IRS_UE(n,k))));
            end
            
            % Determining the BF rate
            opt_ch_k = selected_direct_ch_BS_UE(k) + ((selected_cascaded_ch_IRS_UE(:,k).')*diag(opt_IRS_config)*...
                selected_cascaded_ch_BS_IRS);
            %opt_ch_k/exp(1i*(angle(selected_direct_ch_BS_UE(k))))
            BF_rate_k(k) = log2(1+(abs(opt_ch_k)^2)*txt_SNR_lin);
        end
        
        Final_BF_rate_this_UE_index(large_scale_loop,innner_loop_K_index) = (1/K_subset)*sum(BF_rate_k);
        innner_loop_K_index = innner_loop_K_index +1;
        
    end
end
toc;

%% Plots
figure();
plot(K_subset_points,mean(Rate_this_UE_index));
hold on;
plot(K_subset_points,mean(Final_BF_rate_this_UE_index));