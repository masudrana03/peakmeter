#!/bin/bash

# Function to check RAM usage
check_ram_usage() {
    echo "===== RAM Usage ====="
    free -h
    echo ""
}

# Function to check memory performance
check_ram_speed() {
    if ! command -v memtester &> /dev/null; then
        echo "memtester is not installed. Skipping RAM speed test."
        echo "Install it using: sudo apt install memtester (Debian/Ubuntu) or sudo yum install memtester (RHEL)"
        return
    fi
    
    echo "===== RAM Speed Test ====="
    sudo memtester 512M 1
}

# Function to check RAM details
check_ram_details() {
    echo "===== RAM Details ====="
    cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"
    echo ""
}

# Main function
main() {
    check_ram_usage
    check_ram_details
    check_ram_speed
}

# Run the script
main
