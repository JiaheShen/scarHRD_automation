#!/bin/bash

# Function to process a single folder
process_folder() {
  dir="$1"
  cd "$dir" || exit 1

  echo "Processing folder: $dir"

  # Step 1: Run setupStep.sh
  if [ -f "setupStep.sh" ]; then
    echo "Running setupStep.sh in $dir"
    bash setupStep.sh
    
    # Wait for fileList.txt to be generated
    if [ ! -f "scarhrd_fileList.txt" ]; then
      echo "scarhrd_fileList.txt not found in $dir. Skipping..."
      cd ..
      return 1
    fi
  else
    echo "setupStep.sh not found in $dir. Skipping..."
    cd ..
    return 1
  fi

  # Step 2: Run run_scarHRD_workflow.sh
  if [ -f "run_scarHRD_workflow_debug.sh" ]; then
    echo "Running run_scarHRD_workflow_debug.sh in $dir"
    bash run_scarHRD_workflow_debug.sh
    echo "Finished run_scarHRD_workflow_debug.sh in $dir"
  else
    echo "run_scarHRD_workflow_debug.sh not found in $dir"
  fi

  cd ..
}

export -f process_folder  # Export the function for parallel to use

# Find directories and run them in parallel using xargs 
find . -maxdepth 1 -type d -name '*_ScarHRD' | xargs -I {} -n 1 -P 2 bash -c 'process_folder "$@"' _ {}
