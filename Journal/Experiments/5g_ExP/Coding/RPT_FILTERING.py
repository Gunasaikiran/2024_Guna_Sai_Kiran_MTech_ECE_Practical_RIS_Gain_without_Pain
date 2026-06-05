import re
import pandas as pd

# File paths
input_path = "/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/TC_20000_TS_5/UE2_iperf.tx"
output_path = "/home/gunasaikiran/Desktop/5g_ExP/MATLAB_CODE/FILTERING/TC_20000_TS_5/Throughput_values_2.xlsx"

throughput_values = []

with open(input_path, "r") as file:
    for line in file:
        # Regex to capture throughput value and unit (e.g. "6.29 Mbits/sec", "768 Kbits/sec", "12345 bits/sec")
        match = re.search(r"([\d\.]+)\s*(Mbits/sec|Kbits/sec|bits/sec)", line)
        if match:
            value = float(match.group(1))
            unit = match.group(2).lower()

            if "mbits/sec" in unit:
                throughput_mbps = value
            elif "kbits/sec" in unit:
                throughput_mbps = value / 1000
            elif "bits/sec" in unit:
                throughput_mbps = value / 1_000_000
            else:
                continue

            throughput_values.append(throughput_mbps)

# Save to Excel
df = pd.DataFrame(throughput_values, columns=["Throughput (Mbits/sec)"])
df.to_excel(output_path, index=False)

print(f"Excel file saved to: {output_path}")
