#!/bin/bash
# --------------------------------------------------------------
# Script: extract_trj_xtc.sh
# Purpose: Extract trajectory frames at user-defined intervals
#          to generate md_0_500_cent_*ns.xtc files.
# --------------------------------------------------------------

# === User input ===
read -p "Enter total simulation length (in ns): " total_ns
read -p "Enter extraction interval (e.g., '10ps', '20ns', or '50ss' for 50 snapshots): " interval_input
read -p "Enter .tpr filename (default: topol.tpr): " tpr_file
read -p "Enter .xtc filename (default: md_0_500_center.xtc): " xtc_file
read -p "Enter index filename (default: index.ndx): " ndx_file
read -p "Enter group number to echo (default: 14): " group_num

# === Defaults ===
tpr_file=${tpr_file:-topol.tpr}
xtc_file=${xtc_file:-md_0_500_center.xtc}
ndx_file=${ndx_file:-index.ndx}
group_num=${group_num:-14}

# === Validate total_ns ===
if ! [[ "$total_ns" =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$total_ns <= 0" | bc -l) )); then
    echo "❌ Error: Total simulation length must be a positive number (in ns)"
    exit 1
fi

total_ps=$(( total_ns * 1000 ))  # convert ns → ps

# === Determine mode: snapshots or fixed interval ===
if [[ "$interval_input" == *ss ]]; then
    # --- Case: number of snapshots ---
    num_ss=${interval_input%ss}
    if ! [[ "$num_ss" =~ ^[0-9]+$ ]] || (( num_ss <= 0 )); then
        echo "❌ Error: Number of snapshots must be a positive integer"
        exit 1
    fi

    interval_ps=$(( total_ps / num_ss ))
    echo "📦 Generating $num_ss snapshots (interval = ${interval_ps} ps)"
    
    for (( i=1; i<=num_ss; i++ )); do
        time_ps=$(( i * interval_ps ))
        time_ns=$(echo "scale=2; $time_ps / 1000" | bc)
        outfile="md_0_500_cent_${time_ns}ns.xtc"
        echo "→ Extracting ${time_ns} ns (${time_ps} ps)"
        echo "$group_num" | gmx trjconv -s "$tpr_file" -f "$xtc_file" -n "$ndx_file" \
            -o "$outfile" -pbc mol -ur compact -b $((time_ps - 1)) -e $time_ps -dt $time_ps
    done

elif [[ "$interval_input" == *ns ]]; then
    # --- Case: fixed interval in ns ---
    interval_ns=${interval_input%ns}
    if ! [[ "$interval_ns" =~ ^[0-9]+(\.[0-9]+)?$ ]] || (( $(echo "$interval_ns <= 0" | bc -l) )); then
        echo "❌ Error: Interval must be a positive number (in ns)"
        exit 1
    fi

    interval_ps=$(( interval_ns * 1000 ))
    echo "📦 Extracting every ${interval_ns} ns"
    
    for (( i=interval_ps; i<=total_ps; i+=interval_ps )); do
        time_ns=$(echo "scale=0; $i / 1000" | bc)
        outfile="md_0_500_cent_${time_ns}ns.xtc"
        echo "→ Extracting ${time_ns} ns frame (${i} ps)"
        echo "$group_num" | gmx trjconv -s "$tpr_file" -f "$xtc_file" -n "$ndx_file" \
            -o "$outfile" -pbc mol -ur compact -b $((i - 1)) -e $i -dt $i
    done

elif [[ "$interval_input" == *ps ]]; then
    # --- Case: fixed interval in ps ---
    interval_ps=${interval_input%ps}
    if ! [[ "$interval_ps" =~ ^[0-9]+$ ]] || (( interval_ps <= 0 )); then
        echo "❌ Error: Interval must be a positive integer (in ps)"
        exit 1
    fi

    echo "📦 Extracting every ${interval_ps} ps"
    
    for (( i=interval_ps; i<=total_ps; i+=interval_ps )); do
        time_ns=$(echo "scale=2; $i / 1000" | bc)
        outfile="md_0_500_cent_${time_ns}ns.xtc"
        echo "→ Extracting ${time_ns} ns frame (${i} ps)"
        echo "$group_num" | gmx trjconv -s "$tpr_file" -f "$xtc_file" -n "$ndx_file" \
            -o "$outfile" -pbc mol -ur compact -b $((i - 1)) -e $i -dt $i
    done

else
    echo "❌ Error: Please specify units properly ('10ns', '100ps', or '50ss')"
    exit 1
fi

echo "✅ All extraction tasks completed successfully!"

