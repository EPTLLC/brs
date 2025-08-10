#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech
# Brabus Recon Suite (BRS) - Tool Management Module
# version: 2.0

# Color definitions (if not already defined)
if [ -z "$RED" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m'
fi

# Show spinner for background operations with live timer and cancellation message  
show_spinner() {
    local pid=$1
    local message=$2
    local start_time=$(date +%s)
    local spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    
    echo -e "${CYAN}$message (Ctrl+C to cancel)${NC}"
    
    while kill -0 $pid 2>/dev/null; do
        local elapsed=$(($(date +%s) - start_time))
        local mins=$((elapsed / 60))
        local secs=$((elapsed % 60))
        
        printf "\r${CYAN}${spin_chars:$i:1} $message [%02d:%02d]${NC}" $mins $secs
        i=$(( (i + 1) % ${#spin_chars} ))
        sleep 0.1
    done
    
    local elapsed=$(($(date +%s) - start_time))
    local mins=$((elapsed / 60))
    local secs=$((elapsed % 60))
    printf "\r${GREEN}✅ $message completed [%02d:%02d]${NC}\n" $mins $secs
}

# Required tools list with alternative package names
REQUIRED_TOOLS=(
    "nmap:nmap - Network mapper"
    "masscan:masscan - Mass IP port scanner" 
    "hydra:hydra - Network logon cracker"
    "nikto:nikto - Web server scanner"
    "sqlmap:sqlmap - SQL injection tool"
    "john:john-the-ripper - Password cracker"
    "aircrack-ng:aircrack-ng - WiFi security auditing"
    "arp-scan:arp-scan - ARP scanner"
    "dirb:dirb - Web content scanner"
    "curl:curl - Command line HTTP client"
    "wget:wget - Network downloader"
    "dnsutils:dnsutils (dig) - DNS utilities"
    "whois:whois - Domain WHOIS lookup"
    "jq:jq - JSON processor"
    "tor:tor - The Onion Router"
    "proxychains:proxychains - Proxy chaining"
    "hping3:hping3 - TCP/IP packet generator"
)

# Optional tools (nice to have but not critical)
OPTIONAL_TOOLS=(
    "ettercap:ettercap-text-only - Network interceptor"
    "gobuster:gobuster - Directory bruteforcer"
    "hashcat:hashcat - Advanced password recovery"
    "metasploit-framework:msfconsole - Penetration testing framework"
    "wireshark:tshark - Network protocol analyzer"
    "lsb-release:lsb-release - System information"
    "lsusb:usbutils - USB device listing"
    "lspci:pciutils - PCI device listing"
    "iwconfig:wireless-tools - WiFi configuration tools"
    "bluetoothctl:bluez - Bluetooth control utility"
)

# Tool checking functions
check_tool() {
    local tool="$1"
    if command -v "$tool" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Package manager detection
detect_package_manager() {
    if command -v apt &> /dev/null && [ -f /etc/debian_version ]; then
        echo "apt"
    elif command -v dnf &> /dev/null && [ -f /etc/fedora-release ]; then
        echo "dnf"
    elif command -v yum &> /dev/null && [ -f /etc/redhat-release ]; then
        echo "yum"
    elif command -v pacman &> /dev/null && [ -f /etc/arch-release ]; then
        echo "pacman"
    elif command -v zypper &> /dev/null && [ -f /etc/SuSE-release ]; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Install single tool with progress
install_single_tool() {
    local tool=$1
    local pkg_manager=$2
    local current=$3
    local total=$4
    local start_time=$5
    
    # show_progress $current $total "Installing $tool..." $start_time # This line is removed as per the new_code
    
    case $pkg_manager in
        "apt")
            if timeout 300 sudo apt install -y "$tool" &>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        "dnf")
            if timeout 300 sudo dnf install -y "$tool" &>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        "yum")
            if timeout 300 sudo yum install -y "$tool" &>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        "pacman")
            if timeout 300 sudo pacman -S --noconfirm "$tool" &>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        "zypper")
            if timeout 300 sudo zypper install -y "$tool" &>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Install missing tools function
install_missing_tools() {
    local missing_tools=("$@")
    local pkg_manager=$(detect_package_manager)
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All tools are already installed!${NC}"
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}📦 MISSING TOOLS INSTALLATION${NC}"
    echo "================================"
    echo -e "${CYAN}Tools to install: ${missing_tools[*]}${NC}"
    echo -e "${CYAN}Package manager: ${YELLOW}$pkg_manager${NC}"
    
    if [ "$pkg_manager" = "unknown" ]; then
        echo -e "${RED}❌ Unknown package manager. Please install manually:${NC}"
        echo "${missing_tools[*]}"
        echo ""
        echo "Common installation commands:"
        echo "  Ubuntu/Debian: sudo apt install ${missing_tools[*]}"
        echo "  RHEL/CentOS:   sudo yum install ${missing_tools[*]}"
        echo "  Fedora:        sudo dnf install ${missing_tools[*]}"
        echo "  Arch Linux:    sudo pacman -S ${missing_tools[*]}"
        return 1
    fi
    
    echo ""
    echo -e "${YELLOW}⚠️ This will install missing penetration testing tools${NC}"
    echo -e "${YELLOW}⚠️ Make sure you have proper authorization to install these tools${NC}"
    echo ""
    echo -e "${CYAN}Would you like to install missing tools? (y/N):${NC}"
    read -r install_confirm
    
    if [[ ! "$install_confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled by user${NC}"
        return 1
    fi
    
    echo ""
    echo -e "${BLUE}🔧 Installing missing tools...${NC}"
    echo "================================"
    
    local failed_tools=()
    local installed_tools=()
    local start_time=$(date +%s)
    local total=${#missing_tools[@]}
    local current=0
    
    # Update package manager first
    echo -e "${CYAN}Updating package database...${NC}"
    case $pkg_manager in
        "apt")
            sudo apt update &>/dev/null &
            show_spinner $! "Updating package database"
            wait
            ;;
        "pacman")
            sudo pacman -Sy &>/dev/null &
            show_spinner $! "Updating package database"
            wait
            ;;
    esac
    echo -e "${GREEN}✅ Package database updated${NC}"
    echo ""
    
    # Install tools one by one with progress
    for tool in "${missing_tools[@]}"; do
        current=$((current + 1))
        
        if install_single_tool "$tool" "$pkg_manager" $current $total $start_time; then
            # show_progress $current $total "✅ $tool installed" $start_time # This line is removed as per the new_code
            echo ""
            installed_tools+=("$tool")
        else
            # show_progress $current $total "❌ $tool failed" $start_time # This line is removed as per the new_code
            echo ""
            failed_tools+=("$tool")
        fi
    done
    
    echo ""
    echo "================================"
    echo -e "${GREEN}✅ Installation completed: ${#installed_tools[@]}/${total} tools${NC}"
    
    if [ ${#installed_tools[@]} -gt 0 ]; then
        echo -e "${GREEN}Successfully installed:${NC}"
        for tool in "${installed_tools[@]}"; do
            echo "  ✅ $tool"
        done
    fi
    
    if [ ${#failed_tools[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}❌ Failed to install: ${#failed_tools[@]} tools${NC}"
        for tool in "${failed_tools[@]}"; do
            echo "  ❌ $tool"
        done
        echo ""
        echo -e "${YELLOW}📋 Manual installation suggestions:${NC}"
        for tool in "${failed_tools[@]}"; do
            case $tool in
                "ettercap")
                    echo "  $tool: Try 'ettercap-text-only' or 'ettercap-gtk'"
                    ;;
                "john")
                    echo "  $tool: Try 'john-the-ripper' or compile from source"
                    ;;
                "gobuster")
                    echo "  $tool: Download from https://github.com/OJ/gobuster/releases"
                    ;;
                "masscan")
                    echo "  $tool: May need to compile from source or use snap"
                    ;;
                "hashcat")
                    echo "  $tool: Available in most repositories or from hashcat.net"
                    ;;
                *)
                    echo "  $tool: Check if available in additional repositories"
                    ;;
            esac
        done
    fi
    
    # Final elapsed time
    local total_elapsed=$(($(date +%s) - start_time))
    local total_mins=$((total_elapsed / 60))
    local total_secs=$((total_elapsed % 60))
    echo ""
    echo -e "${CYAN}⏱️ Total installation time: ${total_mins}m ${total_secs}s${NC}"
    
    echo ""
    if [ ${#installed_tools[@]} -gt 0 ]; then
        echo -e "${BLUE}Re-checking tools...${NC}"
        echo ""
        check_all_tools
        return 0
    else
        echo -e "${YELLOW}No tools were installed. Please install manually.${NC}"
        return 1
    fi
}

# Main tool checking function
check_all_tools() {
    local missing_tools=()
    local available_tools=()
    local missing_optional=()
    local available_optional=()
    
    echo -e "${BLUE}🔧 Checking required tools...${NC}"
    echo "================================"
    
    for tool_info in "${REQUIRED_TOOLS[@]}"; do
        local tool_name="${tool_info%%:*}"
        local tool_desc="${tool_info#*:}"
        
        if check_tool "$tool_name"; then
            echo -e "${GREEN}✅ $tool_desc${NC}"
            available_tools+=("$tool_name")
        else
            echo -e "${RED}❌ $tool_desc${NC}"
            missing_tools+=("$tool_name")
        fi
    done
    
    echo ""
    echo -e "${BLUE}🔧 Checking optional tools...${NC}"
    echo "================================"
    
    for tool_info in "${OPTIONAL_TOOLS[@]}"; do
        local tool_name="${tool_info%%:*}"
        local tool_desc="${tool_info#*:}"
        
        if check_tool "$tool_name"; then
            echo -e "${GREEN}✅ $tool_desc${NC}"
            available_optional+=("$tool_name")
        else
            echo -e "${YELLOW}⚪ $tool_desc${NC}"
            missing_optional+=("$tool_name")
        fi
    done
    
    echo "================================"
    echo -e "${GREEN}Required tools available: ${#available_tools[@]}/${#REQUIRED_TOOLS[@]}${NC}"
    echo -e "${GREEN}Optional tools available: ${#available_optional[@]}/${#OPTIONAL_TOOLS[@]}${NC}"
    echo -e "${RED}Missing required tools: ${#missing_tools[@]}${NC}"
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠️ Some tools are missing and may limit functionality${NC}"
        echo ""
        echo -e "${CYAN}Options:${NC}"
        echo "1) Install missing tools automatically"
        echo "2) Continue with limited functionality"
        echo "3) Show manual installation commands"
        echo ""
        echo -n "Choose option (1/2/3): "
        read -r tool_choice
        
        case "$tool_choice" in
            1)
                install_missing_tools "${missing_tools[@]}"
                ;;
            2)
                echo -e "${YELLOW}Continuing with limited functionality...${NC}"
                ;;
            3)
                echo ""
                echo -e "${CYAN}Manual installation commands:${NC}"
                echo "================================"
                local pkg_manager=$(detect_package_manager)
                case $pkg_manager in
                    "apt")
                        echo "sudo apt update && sudo apt install -y ${missing_tools[*]}"
                        ;;
                    "dnf")
                        echo "sudo dnf install -y ${missing_tools[*]}"
                        ;;
                    "yum")
                        echo "sudo yum install -y ${missing_tools[*]}"
                        ;;
                    "pacman")
                        echo "sudo pacman -S ${missing_tools[*]}"
                        ;;
                    *)
                        echo "Ubuntu/Debian: sudo apt install ${missing_tools[*]}"
                        echo "RHEL/CentOS:   sudo yum install ${missing_tools[*]}"
                        echo "Fedora:        sudo dnf install ${missing_tools[*]}"
                        echo "Arch Linux:    sudo pacman -S ${missing_tools[*]}"
                        ;;
                esac
                echo ""
                echo -e "${YELLOW}Note: Some tools may require additional repositories${NC}"
                ;;
            *)
                echo -e "${YELLOW}Invalid choice, continuing with limited functionality...${NC}"
                ;;
        esac
        
        echo ""
        echo "Press Enter to continue..."
        read
    else
        echo -e "${GREEN}🎉 All required tools are available!${NC}"
    fi
    
    echo ""
}

# Quick check without user interaction (for startup)
quick_tool_check() {
    local missing_count=0
    local available_count=0
    local optional_available=0
    
    # Check required tools
    for tool_info in "${REQUIRED_TOOLS[@]}"; do
        local tool_name="${tool_info%%:*}"
        
        if check_tool "$tool_name"; then
            available_count=$((available_count + 1))
        else
            missing_count=$((missing_count + 1))
        fi
    done
    
    # Check optional tools
    for tool_info in "${OPTIONAL_TOOLS[@]}"; do
        local tool_name="${tool_info%%:*}"
        
        if check_tool "$tool_name"; then
            optional_available=$((optional_available + 1))
        fi
    done
    
    if [ $missing_count -gt 0 ]; then
        echo -e "${YELLOW}⚠️ $missing_count required tools missing (available: $available_count/${#REQUIRED_TOOLS[@]})${NC}"
        echo -e "${CYAN}Use option 9 to check and install missing tools${NC}"
    else
        echo -e "${GREEN}✅ All ${#REQUIRED_TOOLS[@]} required tools available${NC}"
    fi
    
    if [ $optional_available -gt 0 ]; then
        echo -e "${CYAN}ℹ️ Optional tools available: $optional_available/${#OPTIONAL_TOOLS[@]}${NC}"
    fi
    
    echo ""
}

# Export functions for use in other scripts
export -f check_tool
export -f detect_package_manager
export -f install_missing_tools
export -f check_all_tools
export -f quick_tool_check 