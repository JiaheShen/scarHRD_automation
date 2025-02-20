# 🚀 ScarHRD Pipeline Automation

This pipeline automates the **copying, processing, and cleanup** of `ScarHRD` analysis sample folders.

It consists of two main scripts:
1. **`copy_all_files.sh`** → Copies `.bam` files and workflow files into sample folders.
2. **`process_folders_parallel.sh`** → Runs **ScarHRD analysis in parallel** and **automatically deletes sample folders** to free up space.

---

## 📂 Step 1: Copy Required Files

The script **`copy_all_files.sh`** ensures that all necessary files are placed in the correct sample folders before processing.

### 🔹 Usage
#### 1️⃣ Make the script executable:
```bash
chmod +x copy_all_files.sh




