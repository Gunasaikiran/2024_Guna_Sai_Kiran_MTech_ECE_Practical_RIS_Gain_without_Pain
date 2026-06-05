import re
import pandas as pd

# File paths
input_path = "/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/TC_20000_TS_5/UE1_iperf.txt"
output_path = "/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/TC_20000_TS_5/Throughput_values_1.xlsx"

# Read and extract throughput values
throughput_values = []

with open(input_path, "r") as file:
    for line in file:
        words = line.split()
        if len(words) >= 7:
            try:
                value = float(words[6])
                unit = words[7].lower()

                if "mbits/sec" in unit:
                    throughput_mbps = value
                elif "kbits/sec" in unit:
                    throughput_mbps = value / 1000
                elif "bits/sec" in unit:
                    throughput_mbps = value / 1_000_000
                else:
                    continue  # Skip unknown units

                throughput_values.append(throughput_mbps)
            except ValueError:
                continue

# Save to Excel
df = pd.DataFrame(throughput_values, columns=["Throughput (Mbits/sec)"])
df.to_excel(output_path, index=False)

print(f"Excel file saved to: {output_path}")

