#!/bin/bash

# Prompt for RMA number
read -p "Enter RMA Number: " rma_num
rma_dir="RMA_${rma_num}"

# Create RMA directory
mkdir -p "$rma_dir"
echo "Created directory: $rma_dir"

# Start NVIDIA DCGM service
echo "Starting nvidia-dcgm service..."
sudo systemctl start nvidia-dcgm

# Run dcgmi diagnostics and save outputs
echo "Running dcgmi diag -r 1..."
dcgmi diag -r 1 > "${rma_dir}/dcgmi_diag_r_1.txt"

echo "Running dcgmi diag -r 2..."
dcgmi diag -r 2 > "${rma_dir}/dcgmi_diag_r_2.txt"

echo "Running dcgmi diag -r 3..."
dcgmi diag -r 3 > "${rma_dir}/dcgmi_diag_r_3.txt"

# Run nvidia-smi and save output
echo "Running nvidia-smi..."
nvidia-smi > "${rma_dir}/nvidia_smi.txt"

# Run NVIDIA bug report
echo "Running nvidia-bug-report.sh (this may take a few moments)..."
sudo nvidia-bug-report.sh
mv nvidia-bug-report.log.gz "${rma_dir}/"

echo "All diagnostics completed. Files saved in: $rma_dir"

