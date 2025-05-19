
# scarHRD Automation Scripts

These two bash scripts automate the **collection of necessary BAM/BAI files** and the **execution of the scarHRD pipeline** in a batch fashion.

---

## Script 1: `copy_all_files.sh`

**Purpose**:  
Copies the necessary `.bam` and `.bam.bai` files from sample folders into local project directories (e.g. `020_ScarHRD/`, `057_ScarHRD/`), along with workflow files required for scarHRD.

**Usage**:
```bash
bash copy_all_files.sh
```

**What it does**:
1. Prompts the user for a **starting** and **ending** sample number.
2. Searches for folders in `../FINAL_HG38_DRAGEN_OUTPUT_TN_WGS/` that match:
   - either zero-padded or unpadded format (e.g., `020_8N_4T` or `20_8N_4T`)
3. For each valid sample:
   - Creates a destination folder like `20_ScarHRD/`
   - Copies:
     - One pair of `.bam` and `.bam.bai` from `germline/`
     - One pair from `normal/`
     - Workflow files from `./Workflow_Files_Needed/`

**Note**:
- Sample folders must contain a `germline/` and/or `normal/` subdirectory.
- Modify the `SRC_DIR` and `WORKFLOW_FILES_DIR` variables inside the script as needed.

**Example Folder Structure (Before Running)**:
```
../FINAL_HG38_DRAGEN_OUTPUT_TN_WGS/
├── 020_8N_4T/
│   ├── germline/
│   │   ├── sample1.bam
│   │   ├── sample1.bam.bai
│   ├── normal/
│       ├── sample2.bam
│       ├── sample2.bam.bai
```

**Example Output Structure (After Running)**:
```
./
├── 020_ScarHRD/
│   ├── sample1.bam
│   ├── sample1.bam.bai
│   ├── sample2.bam
│   ├── sample2.bam.bai
│   ├── setupStep.sh
│   ├── run_scarHRD_workflow_debug.sh
│   └── ...
```

---

## Script 2: `process_folders_parallel.sh`

**Purpose**:  
Runs the scarHRD setup and execution workflow for each `_ScarHRD` folder in parallel.

**Usage**:
```bash
bash process_folders_parallel.sh
```

**What it does**:
1. Locates all directories in the current path matching `*_ScarHRD`
2. For each:
   - Runs `setupStep.sh`
   - Waits for `scarhrd_fileList.txt` to appear
   - Runs `run_scarHRD_workflow_debug.sh`
3. Processes up to 2 directories at a time using parallel execution (`xargs -P 2`)

**Requirements**:
- Each `_ScarHRD` folder must contain:
  - `setupStep.sh`
  - `run_scarHRD_workflow_debug.sh`

**Tip**: You can increase the `-P 2` parameter to run more processes in parallel, depending on system resources.

---

## Typical Workflow

```bash
# Step 1: Prepare the folders with required files
./copy_all_files.sh

# Step 2: Run scarHRD pipeline in all prepared folders
./process_folders_parallel.sh
```
