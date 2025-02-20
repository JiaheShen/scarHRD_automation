# README: ScarHRD Pipeline Automation

This pipeline automates the copying, processing, and cleanup of ScarHRD analysis sample folders.

It consists of two main scripts:

- `copy_all_files.sh` → Copies required `.bam` files and workflow files into sample folders.
- `process_folders_parallel.sh` → Runs ScarHRD analysis in parallel and automatically deletes sample folders to free up space.

## Step 1: Copy Required Files

The script `copy_all_files.sh` ensures that all necessary files are placed in the correct sample folders before processing.

### 🔹 Usage

1. Make the script executable:

   ```bash
   chmod +x copy_all_files.sh
   ```

2. Run the script:

   ```bash
   ./copy_all_files.sh
   ```

3. Enter the range of sample numbers when prompted:

   ```yaml
   Enter starting sample number: 541
   Enter ending sample number: 550
   ```

The script will create `*_ScarHRD` sample folders.

It will copy:

- `.bam` and `.bam.bai` files from germline and normal directories.
- Additional workflow files required for ScarHRD.

### 🔹 Example Output

```sql
Processing sample: 541
Copying files from germline for sample 541...
Copying files from normal for sample 541...
Workflow files copied to 541_ScarHRD.
All required files have been copied successfully for sample 541.
...
All required files have been copied successfully.
```

### 🔹 What This Script Does

✅ Finds valid sample folders (`*_N_*T`) and creates corresponding `*_ScarHRD` folders.  
✅ Copies `.bam` and `.bam.bai` files while avoiding `repeats.bam`.  
✅ Copies workflow files to each `*_ScarHRD` folder.  
✅ Handles missing sample numbers gracefully (skips and logs warnings).  
✅ Runs in parallel to optimize file copying time.  

---

## Step 2: Process ScarHRD Analysis in Parallel

Once the sample folders are ready, use `process_folders_parallel.sh` to process them efficiently.

### 🔹 Usage

1. Make the script executable:

   ```bash
   chmod +x process_folders_parallel.sh
   ```

2. Run the script:

   ```bash
   ./process_folders_parallel.sh
   ```

This script:

- Runs `setupStep.sh` and `run_scarHRD_workflow_debug.sh` inside each sample folder.
- Runs in parallel using multiple CPU cores.
- Automatically deletes each sample folder after processing to free up space.

### 🔹 Example Output

```sql
Processing folder: 541_ScarHRD
Running setupStep.sh in 541_ScarHRD...
Waiting for scarhrd_fileList.txt...
Finished setupStep.sh in 541_ScarHRD
Running run_scarHRD_workflow_debug.sh in 541_ScarHRD
Finished run_scarHRD_workflow_debug.sh in 541_ScarHRD
Deleting folder: 541_ScarHRD to free up space...
Successfully deleted 541_ScarHRD.
...
Processing complete. Check logs in ./logs.
```

### 🔹 What This Script Does

✅ Automatically detects and processes `*_ScarHRD` sample folders.  
✅ Runs `setupStep.sh` first and waits for `scarhrd_fileList.txt` before continuing.  
✅ Runs `run_scarHRD_workflow_debug.sh` to perform ScarHRD analysis.  
✅ Uses multiple CPU cores for faster parallel execution.  
✅ Deletes sample folders after analysis to prevent disk space overload.  
✅ Logs everything for debugging (`logs/<sample>.log`).  

---

## 🛠 Troubleshooting & Logs

All logs are stored in `logs/` for debugging.

### 🔹 View logs while processing

```bash
tail -f logs/*.log
```

### 🔹 Check if a sample was processed correctly

```bash
cat logs/541_ScarHRD.log
```

If a sample fails, the logs will show error messages.

---

## ⚙ Customization Options

### 🔹 Change Parallel Processing Speed

By default, the processing script uses half of the available CPU cores for efficiency.  
To change the number of parallel jobs, modify this line in `process_folders_parallel.sh`:

```bash
MAX_PARALLEL_JOBS=4  # Adjust based on system capabilities
```

Increase to `6` for faster processing, or reduce to `2` if the system is slow.

### 🔹 Keep Sample Folders Instead of Deleting

If you do not want to delete the sample folders after processing, remove or comment out this line in `process_folders_parallel.sh`:

```bash
rm -rf "$dir"
```

