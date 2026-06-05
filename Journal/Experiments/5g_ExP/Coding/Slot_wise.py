
import re

# Change this to your actual filename
filename = "/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/Slot_wise/Slot_filtered_UE_2.txt"

# Regex: finds 'RSRP' followed by an optional colon/space and a signed integer
rsrp_regex = re.compile(r'\bRSRP\b[:\s]*(-?\d+)')

count_110 = 0
count_97 = 0
total_lines = 0

with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        total_lines += 1
        m = rsrp_regex.search(line)
        if m:
            val = int(m.group(1))
            if val == -110:
                count_110 += 1
            elif val == -97:
                count_97 += 1

print(f"Total lines scanned: {total_lines}")
print(f"RSRP -110 count: {count_110}")
print(f"RSRP -100 count: {count_97}")
