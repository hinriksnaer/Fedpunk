#!/bin/bash

# Waybar GPU monitoring script
# Supports both NVIDIA and AMD GPUs

# Check for NVIDIA GPU
if command -v nvidia-smi &> /dev/null; then
    GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -n 1)
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -n 1)
    GPU_MEM_USED=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | head -n 1)
    GPU_MEM_TOTAL=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | head -n 1)
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -n 1)

    # Calculate memory percentage
    GPU_MEM_PERCENT=$(awk "BEGIN {printf \"%.0f\", ($GPU_MEM_USED / $GPU_MEM_TOTAL) * 100}")

    echo "{\"text\":\"${GPU_USAGE}%\",\"tooltip\":\"${GPU_NAME}\\nUsage: ${GPU_USAGE}%\\nTemperature: ${GPU_TEMP}°C\\nMemory: ${GPU_MEM_USED}MB / ${GPU_MEM_TOTAL}MB (${GPU_MEM_PERCENT}%)\"}"

# Check for AMD GPU
elif command -v radeontop &> /dev/null; then
    # radeontop requires more complex parsing, using rocm-smi if available
    if command -v rocm-smi &> /dev/null; then
        GPU_USAGE=$(rocm-smi --showuse | grep "GPU use" | awk '{print $4}' | tr -d '%')
        GPU_TEMP=$(rocm-smi --showtemp | grep "Temperature" | awk '{print $3}' | tr -d 'c')
        GPU_MEM=$(rocm-smi --showmeminfo vram | grep "VRAM Total Used Memory" | awk '{print $6}')

        echo "{\"text\":\"${GPU_USAGE:-0}%\",\"tooltip\":\"AMD GPU\\nUsage: ${GPU_USAGE:-0}%\\nTemperature: ${GPU_TEMP:-N/A}°C\\nMemory: ${GPU_MEM:-N/A}\"}"
    else
        # Fallback for AMD without rocm-smi
        echo "{\"text\":\"N/A\",\"tooltip\":\"AMD GPU detected\\nInstall rocm-smi for stats\"}"
    fi

# Check for Intel GPU
elif command -v intel_gpu_top &> /dev/null; then
    # Intel GPU monitoring requires intel-gpu-tools
    GPU_INFO=$(timeout 1s intel_gpu_top -J 2>/dev/null | jq -r '.engines."Render/3D/0".busy' 2>/dev/null)
    if [ -n "$GPU_INFO" ] && [ "$GPU_INFO" != "null" ]; then
        echo "{\"text\":\"${GPU_INFO}%\",\"tooltip\":\"Intel GPU\\nUsage: ${GPU_INFO}%\"}"
    else
        echo "{\"text\":\"N/A\",\"tooltip\":\"Intel GPU detected\\nUnable to read stats\"}"
    fi

# No GPU detected
else
    echo "{\"text\":\"No GPU\",\"tooltip\":\"No compatible GPU monitoring tool found\\n\\nInstall:\\n- nvidia-smi (NVIDIA)\\n- rocm-smi (AMD)\\n- intel-gpu-tools (Intel)\"}"
fi
