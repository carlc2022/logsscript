#!/bin/bash

### === BEGIN: dcgmi_install.sh contents ===
# (These lines are directly from your uploaded script)

# Install NVIDIA DCGM
echo "Downloading NVIDIA CUDA keyring..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb

echo "Installing keyring..."
sudo dpkg -i cuda-keyring_1.0-1_all.deb

echo "Adding CUDA repository..."
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"

echo "Updating package list..."
sudo apt-get update

echo "Installing datacenter-gpu-manager..."
sudo apt-get install -y datacenter-gpu-manager
### === END: dcgmi_install.sh contents ===

# === Start DCGM and run discovery ===
echo "Starting nvidia-dcgm service..."
sudo systemctl start nvidia-dcgm.service

echo "Running dcgmi discovery -l..."
dcgmi discovery -l | tee dcgmi_discovery.txt


# === Step 2: Ask user a yes/no question (response doesn't affect flow) ===
read -p "Did you see the output? (yes/no): " user_response

# === Step 3: Continue with diagnostics ===

# Prompt for RMA number
read -p "Enter RMA Number: " rma_num
rma_dir="RMA_${rma_num}"

# Create RMA directory
mkdir -p "$rma_dir"
echo "Created directory: $rma_dir"

# Move discovery log into RMA folder
mv dcgmi_discovery.txt "${rma_dir}/"

# Start NVIDIA DCGM service
echo "Starting nvidia-dcgm service..."
sudo systemctl start nvidia-dcgm

# Run dcgmi diagnostics and save outputs
echo "Running dcgmi diag -r 1..."
dcgmi diag -r 1 > "${rma_dir}/dcgmi_diag_r_1.txt"
echo -e "\nOutput of dcgmi_diag_r_1.txt:"
cat "${rma_dir}/dcgmi_diag_r_1.txt"

echo "Running dcgmi diag -r 2..."
dcgmi diag -r 2 > "${rma_dir}/dcgmi_diag_r_2.txt"
echo -e "\nOutput of dcgmi_diag_r_2.txt:"
cat "${rma_dir}/dcgmi_diag_r_2.txt"

echo "Running dcgmi diag -r 3..."
dcgmi diag -r 3 > "${rma_dir}/dcgmi_diag_r_3.txt"
echo -e "\nOutput of dcgmi_diag_r_3.txt:"
cat "${rma_dir}/dcgmi_diag_r_3.txt"

# Run nvidia-smi and save output
echo "Running nvidia-smi..."
nvidia-smi > "${rma_dir}/nvidia_smi.txt"

# Run NVIDIA bug report
echo "Running nvidia-bug-report.sh (this may take a few moments)..."
sudo nvidia-bug-report.sh
mv nvidia-bug-report.log.gz "${rma_dir}/"

# Copy directory to remote host
echo "Transferring diagnostics to remote server..."
sudo scp -r "$rma_dir" carlos@10.100.14.199:/home/carlos/Repair_LOGS

echo "All diagnostics completed. Files saved in: $rma_dir and transferred to remote server."

