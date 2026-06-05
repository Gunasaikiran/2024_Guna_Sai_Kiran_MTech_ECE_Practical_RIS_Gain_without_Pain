% Define source and destination directories
sourceDir = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/TC_20000_TS_5';   
destDir   = '/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/Slot_wise'; 

% Define file names
inputFile = fullfile(sourceDir, 'BOTH_UES.log');
outputFile = fullfile(destDir, 'Slot_filtered_UE_1.txt');
% Open input file for reading
fid_in = fopen(inputFile, 'r');
if fid_in == -1
    error('Cannot open input file: %s', inputFile);
end

% Open output file for writing
fid_out = fopen(outputFile, 'w');
if fid_out == -1
    fclose(fid_in);
    error('Cannot open output file: %s', outputFile);
end
% Read and filter lines
while ~feof(fid_in)
    line = fgetl(fid_in);
    if  contains(line, 'Sched UE 335e MCS') 
         fprintf(fid_out, '%s\n', line);
    end
end
%d5aa
% Close files
fclose(fid_in);
fclose(fid_out);

disp(['Filtered lines saved to: ', outputFile]);
%UE RNTI 335e CU-UE-ID 1
%UE RNTI d5aa CU-UE-ID 2
% UE 335e: dlsch_rounds
% UE d5aa: dlsch_rounds 