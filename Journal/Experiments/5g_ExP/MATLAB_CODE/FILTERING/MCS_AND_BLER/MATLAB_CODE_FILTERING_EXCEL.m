clc
clear
close all
% Define source and destination directories
sourceDir = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/MCS_AND_BLER';   

% Define file names
inputFile = fullfile(sourceDir, 'MCS_filtered_UE_2.txt');
outputExcel = fullfile(sourceDir, 'MCS_values_UE_2.xlsx');

% Open input file for reading
fid= fopen(inputFile, 'r');
if fid == -1
    error('Cannot open input file: %s', inputFile);
end

% Initialize arrays
bler_values = [];
mcs_values = [];

% Read and extract values
while ~feof(fid)
    line = fgetl(fid);
    
    % Extract BLER value
    bler_token = regexp(line, 'BLER\s+([0-9.]+)', 'tokens');
    
    % Extract MCS value
    mcs_token = regexp(line, 'MCS\s*\(\d+\)\s*(\d+)', 'tokens');
    
    if ~isempty(bler_token) && ~isempty(mcs_token)
        bler = str2double(bler_token{1}{1});
        mcs = str2double(mcs_token{1}{1});
        
        bler_values(end+1, 1) = bler;
        mcs_values(end+1, 1) = mcs;
    end
end

% Close the file
fclose(fid);

% Combine into a matrix
result_matrix = [bler_values, mcs_values];

% Write to Excel
writematrix(result_matrix, outputExcel);

disp(['✅ BLER and MCS values saved to: ', outputExcel]);


