#!/bin/bash

# Prompt user for start and end sample numbers
read -p "Enter starting sample number: " start_sample
read -p "Enter ending sample number: " end_sample

# Validate that input numbers are integers
if ! [[ "$start_sample" =~ ^[0-9]+$ && "$end_sample" =~ ^[0-9]+$ ]]; then
    echo "Error: Both starting and ending sample numbers must be valid integers."
    exit 1
fi

# Ensure start_sample is less than or equal to end_sample
if [[ "$start_sample" -gt "$end_sample" ]]; then
    echo "Error: Starting sample number ($start_sample) cannot be greater than the ending sample number ($end_sample)."
    exit 1
fi

# Define the source directory containing the numbered sample folders
SRC_DIR="../"  # Modify this if necessary

# Define the destination directory (current directory where the script is run)
DEST_DIR="$(pwd)"

# Track if any valid sample was found
valid_sample_found=0

# Loop through the range of sample numbers
for sample_num in $(seq "$start_sample" "$end_sample"); do
    # Find the corresponding source folder (handles cases where some numbers may not exist)
    src_folder=$(find "$SRC_DIR" -maxdepth 1 -type d -name "${sample_num}_*N_*T" | head -n 1)

    if [[ -d "$src_folder" ]]; then
        valid_sample_found=1
        dest_folder="${DEST_DIR}/${sample_num}_ScarHRD"
        mkdir -p "$dest_folder"

        echo "Processing sample: $sample_num"

        # Loop through germline and normal folders
        for sub_dir in "germline" "normal"; do
            src_sub_dir="${src_folder}/${sub_dir}"

            if [[ -d "$src_sub_dir" ]]; then
                # Find .bam and .bam.bai files (excluding repeats.bam)
                bam_file=$(find "$src_sub_dir" -maxdepth 1 -type f -name "*.bam" ! -name "*repeats.bam" | head -n 1)
                bai_file=$(find "$src_sub_dir" -maxdepth 1 -type f -name "*.bam.bai" | head -n 1)

                if [[ -f "$bam_file" && -f "$bai_file" ]]; then
                    cp "$bam_file" "$dest_folder"
                    cp "$bai_file" "$dest_folder"
                    echo "Copied files from $sub_dir for sample $sample_num."
                else
                    echo "Warning: Missing BAM or BAI file in $sub_dir for sample $sample_num."
                fi
            else
                echo "Warning: $sub_dir folder not found for sample $sample_num."
            fi
        done
    else
        echo "Skipping sample $sample_num: No matching folder found."
    fi
done

# Exit with an error if no valid sample folders were found in the entire range
if [[ "$valid_sample_found" -eq 0 ]]; then
    echo "Error: No valid sample folders found in the given range ($start_sample to $end_sample)."
    exit 1
fi

echo "File copying process completed."
