clc
clear
close all
% % Define source and destination directories
% sourceDir = '/home/gunasaikiran/Downloads/RIS_on_expts_Sep1_filtered/Both_UE1_and_UE2_RIS_on_BeamSweep_alpha_0p00005';   
% 
% % Define file names
% inputFile = fullfile(sourceDir, 'MCS_filtered_UE_2.txt');
% outputExcel = fullfile(sourceDir, 'MCS_values_UE_2.xlsx');
% 
% % Open input file for reading
% fid= fopen(inputFile, 'r');
% if fid == -1
%     error('Cannot open input file: %s', inputFile);
% end
% 
% % Initialize arrays
% bler_values = [];
% mcs_values = [];
% 
% % Read and extract values
% while ~feof(fid)
%     line = fgetl(fid);
%     
%     % Extract BLER value
%     bler_token = regexp(line, 'BLER\s+([0-9.]+)', 'tokens');
%     
%     % Extract MCS value
%     mcs_token = regexp(line, 'MCS\s*\(\d+\)\s*(\d+)', 'tokens');
%     
%     if ~isempty(bler_token) && ~isempty(mcs_token)
%         bler = str2double(bler_token{1}{1});
%         mcs = str2double(mcs_token{1}{1});
%         
%         bler_values(end+1, 1) = bler;
%         mcs_values(end+1, 1) = mcs;
%     end
% end
% 
% % Close the file
% fclose(fid);
% 
% % Combine into a matrix
% result_matrix = [bler_values, mcs_values];
% 
% % Write to Excel
% writematrix(result_matrix, outputExcel);
% 
% disp(['✅ BLER and MCS values saved to: ', outputExcel]);


% %% 
% 
close all
% Define source and destination directories
sourceDir = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/RSRP';   

% Define file names
inputFile = fullfile(sourceDir, 'RSRP_filtered_UE_2.txt');
outputExcel = fullfile(sourceDir, 'RSRP_values_UE_2.xlsx');

% Open input file for reading
fid_in = fopen(inputFile, 'r');
if fid_in == -1
    error('Cannot open input file: %s', inputFile);
end

% Initialize array to store RSRP values
rsrp_values = [];

% Read and filter lines
while ~feof(fid_in)
    line = fgetl(fid_in);
    

        % Extract RSRP value using regular expression
        tokens = regexp(line, 'RSRP\s+(-?\d+)', 'tokens');
        if ~isempty(tokens)
            rsrp = str2double(tokens{1}{1});
            rsrp_values(end+1, 1) = rsrp;  % Store as a column vector
        end
end

% Close input file
fclose(fid_in);

% Write RSRP values to Excel
writematrix(rsrp_values, outputExcel);

disp(['RSRP values saved to: ', outputExcel]);
