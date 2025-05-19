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

# Define the source directories
SRC_DIR="../FINAL_HG38_DRAGEN_OUTPUT_TN_WGS/"  # Modify this based on actual location
WORKFLOW_FILES_DIR="./Workflow_Files_Needed"  # Modify if needed

# Ensure the workflow files directory exists
if [[ ! -d "$WORKFLOW_FILES_DIR" ]]; then
    echo "Error: Workflow files directory '$WORKFLOW_FILES_DIR' does not exist."
    exit 1
fi

# Define the destination directory (current working directory)
DEST_DIR="$(pwd)"

# Track if any valid sample was found
valid_sample_found=0

# Set max parallel jobs (adjust based on system capabilities)
MAX_PARALLEL_JOBS=4
running_jobs=0

# Function to copy necessary files
copy_files() {
    local sample_num=$1
    local src_folder=$2
    local dest_folder=$3
    local sub_dir=$4

    src_sub_dir="${src_folder}/${sub_dir}"
    if [[ -d "$src_sub_dir" ]]; then
        bam_file=$(find "$src_sub_dir" -maxdepth 1 -type f -name "*.bam" ! -name "*repeats.bam" | head -n 1)
        bai_file=$(find "$src_sub_dir" -maxdepth 1 -type f -name "*.bam.bai" | head -n 1)

        if [[ -f "$bam_file" && -f "$bai_file" ]]; then
            echo "Copying files from $sub_dir for sample $sample_num..."
            cp "$bam_file" "$dest_folder" & pid_bam=$!
            cp "$bai_file" "$dest_folder" & pid_bai=$!

            # Wait for both files to fully copy before proceeding
            wait "$pid_bam"
            wait "$pid_bai"
        else
            echo "Warning: Missing BAM or BAI file in $sub_dir for sample $sample_num."
        fi
    else
        echo "Warning: $sub_dir folder not found for sample $sample_num."
    fi
}

# Loop through the range of sample numbers
for sample_num in $(seq "$start_sample" "$end_sample"); do
    printf -v padded_sample_num "%03d" "$sample_num"

    # Try matching both padded and unpadded versions
    src_folder=$(find "$SRC_DIR" -maxdepth 1 -type d \( \
        -name "${padded_sample_num}_*N_*T" -o \
        -name "${sample_num}_*N_*T" \) | head -n 1)

    if [[ -d "$src_folder" ]]; then
        valid_sample_found=1
        dest_folder="${DEST_DIR}/${sample_num}_ScarHRD"
        mkdir -p "$dest_folder"

        echo "Processing sample: $sample_num"

        copy_files "$sample_num" "$src_folder" "$dest_folder" "germline"
        copy_files "$sample_num" "$src_folder" "$dest_folder" "normal"

        cp -r "$WORKFLOW_FILES_DIR"/* "$dest_folder"/
        echo "Workflow files copied to $dest_folder."
        echo "All required files have been copied successfully for sample $sample_num."
    else
        echo "Skipping sample $sample_num: No matching folder found."
    fi
done

# Exit with an error if no valid sample folders were found
if [[ "$valid_sample_found" -eq 0 ]]; then
    echo "Error: No valid sample folders found in the given range ($start_sample to $end_sample)."
    exit 1
fi

echo "All required files have been copied successfully."
