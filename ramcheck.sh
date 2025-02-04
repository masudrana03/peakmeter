#!/bin/bash

# Detect Operating System
detect_os() {
    OS=$(uname -s)
    case "$OS" in
        Linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                OS_NAME=$NAME
            else
                OS_NAME="Unknown Linux"
            fi
            ;;
        Darwin*)
            OS_NAME="macOS"
            ;;
        *)
            OS_NAME="Unknown OS"
            ;;
    esac
    echo "Detected OS: $OS_NAME"
}

# Install memtester if not installed
install_memtester() {
    if ! command -v memtester &> /dev/null; then
        echo "memtester is not installed."
        case "$OS_NAME" in
            "Ubuntu"|"Debian"*)
                sudo apt update && sudo apt install -y memtester
                ;;
            "Fedora"|"CentOS"|"RHEL"*)
                sudo yum install -y memtester
                ;;
            "macOS")
                brew install memtester || echo "Please install Homebrew first."
                ;;
            *)
                echo "Unsupported OS for automatic installation. Install memtester manually."
                ;;
        esac
    else
        echo "memtester is already installed."
    fi
}

# Check RAM usage
check_ram_usage() {
    echo "===== RAM Usage ====="
    free -h || vm_stat  # vm_stat for macOS
    echo ""
}

# Check RAM details
check_ram_details() {
    echo "===== RAM Details ====="
    cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree" || sysctl hw.memsize  # macOS alternative
    echo ""
}

# Ask user to select test size
select_ram_test() {
    echo "Select RAM size to test:"
    echo "1) 256MB"
    echo "2) 512MB"
    echo "3) 1024MB (1GB)"
    echo "4) 2048MB (2GB)"
    echo "5) 4096MB (4GB)"
    echo "6) 16384MB (16GB)"
    echo "7) Custom size"
    echo "Press Enter to skip testing."

    read -p "Enter your choice (comma-separated for multiple): " choice </dev/tty

    if [[ -z "$choice" ]]; then
        # User left it blank, ask for manual input
        read -p "Enter RAM size to test (MB): " ram_size </dev/tty
        read -p "How many times to test? " test_count </dev/tty

        if [[ -z "$ram_size" || -z "$test_count" ]]; then
            echo "No valid input. Skipping RAM test."
            return
        fi

        sudo memtester "${ram_size}M" "$test_count"
        return
    fi

    # Predefined sizes
    sizes=(256 512 1024 2048 4096 16384)
    IFS=',' read -r -a selected_options <<< "$choice"

    for option in "${selected_options[@]}"; do
        if [[ "$option" =~ ^[1-6]$ ]]; then
            sudo memtester "${sizes[$((option-1))]}M" 1
        elif [[ "$option" == "7" ]]; then
            read -p "Enter custom RAM size (MB): " custom_size </dev/tty
            read -p "How many times to test? " custom_count </dev/tty

            if [[ -n "$custom_size" && -n "$custom_count" ]]; then
                sudo memtester "${custom_size}M" "$custom_count"
            fi
        else
            echo "Invalid choice: $option. Skipping..."
        fi
    done
}

# Main function
main() {
    detect_os
    install_memtester
    check_ram_usage
    check_ram_details
    select_ram_test
}

# Run the script
main
