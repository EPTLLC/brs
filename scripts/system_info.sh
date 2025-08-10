#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

# Brabus Recon Suite (BRS) - System Information Module
# System reconnaissance and configuration analysis script
# company: EasyProTech LLC (www.easypro.tech)
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotech
# author: brabus
# version: 2.0

# Load language file
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPTS_DIR")"
RESULTS_DIR="$PROJECT_DIR/results"

# Load language configuration safely
if [ -f "$PROJECT_DIR/configs/language.conf" ]; then
    # shellcheck disable=SC1090
    source "$PROJECT_DIR/configs/language.conf"
else
    CURRENT_LANGUAGE="en"
fi

# Load localization
if [ -f "$PROJECT_DIR/languages/${CURRENT_LANGUAGE}.sh" ]; then
    # shellcheck disable=SC1090
    source "$PROJECT_DIR/languages/${CURRENT_LANGUAGE}.sh"
else
    # shellcheck disable=SC1090
    source "$PROJECT_DIR/languages/en.sh"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Create results directory if it doesn't exist
mkdir -p "$RESULTS_DIR"

# Set trap for cleanup
cleanup() {
    echo -e "\n\n${RED}⚠️ Operation cancelled${NC}"
    exit 1
}
trap cleanup SIGINT

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

# Get status with color for terminal
get_status() {
    local status="$1"
    case "$status" in
        "active"|"running"|"enabled"|"up")
            echo -e "${GREEN}$SYSINFO_ACTIVE${NC}"
            ;;
        "inactive"|"stopped"|"disabled"|"down")
            echo -e "${RED}$SYSINFO_INACTIVE${NC}"
            ;;
        *)
            echo -e "${YELLOW}$SYSINFO_UNKNOWN${NC}"
            ;;
    esac
}

# Get status without color for files
get_status_plain() {
    local status="$1"
    case "$status" in
        "active"|"running"|"enabled"|"up")
            echo "$SYSINFO_ACTIVE"
            ;;
        "inactive"|"stopped"|"disabled"|"down")
            echo "$SYSINFO_INACTIVE"
            ;;
        *)
            echo "$SYSINFO_UNKNOWN"
            ;;
    esac
}

# Format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(( bytes / 1073741824 )) GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(( bytes / 1048576 )) MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(( bytes / 1024 )) KB"
    else
        echo "$bytes B"
    fi
}

show_menu() {
    echo -e "${PURPLE}$SYSINFO_TITLE${NC}"
    echo "$SYSINFO_SEPARATOR"
    echo "1) $SYSINFO_MENU_FULL"
    echo "2) $SYSINFO_MENU_SYSTEM"
    echo "3) $SYSINFO_MENU_HARDWARE"
    echo "4) $SYSINFO_MENU_NETWORK"
    echo "5) $SYSINFO_MENU_SECURITY"
    echo "6) $SYSINFO_MENU_SERVICES"
    echo "7) $SYSINFO_MENU_DEVICES"
    echo "0) $SETTINGS_BACK"
    echo -n "$MENU_CHOOSE_OPTION: "
}

full_system_report() {
    echo -e "${BLUE}$SYSINFO_TITLE${NC}"
    echo "$SYSINFO_SEPARATOR"

    # Create timestamped results file
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_system_info.txt"

    echo -e "${CYAN}$SYSINFO_COLLECTING${NC}"

    # Start time for duration calculation
    start_time=$(date +%s)

    # Collect all information in background with spinner
    {
        echo "=== $SYSINFO_TITLE ==="
        echo "$SYSINFO_SEPARATOR"
        echo "📅 $SYSINFO_TIMESTAMP: $(date)"
        echo "🔧 $SYSINFO_GENERATED_BY: Brabus Recon Suite (BRS)"
        echo ""
        
        # Section 1: System Information  
        echo "=== $SYSINFO_SYSTEM ==="
        echo "$SYSINFO_OS $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")"
        echo "$SYSINFO_KERNEL $(uname -r)"
        echo "$SYSINFO_ARCHITECTURE $(uname -m)"
        echo "$SYSINFO_HOSTNAME $(hostname)"
        echo "$SYSINFO_UPTIME $(uptime -p 2>/dev/null || uptime)"
        echo "$SYSINFO_LOAD_AVERAGE $(cat /proc/loadavg | cut -d' ' -f1-3)"
        echo "$SYSINFO_USERS_LOGGED $(who | wc -l)"
        echo ""
        
        # Section 2: Hardware Information
        echo "=== $SYSINFO_HARDWARE ==="
        
        # CPU Information
        if [ -f /proc/cpuinfo ]; then
            cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')
            cpu_cores=$(grep -c "processor" /proc/cpuinfo)
            echo "$SYSINFO_CPU_MODEL $cpu_model"
            echo "$SYSINFO_CPU_CORES $cpu_cores"
        fi
        
        # CPU Usage
        if command -v top >/dev/null 2>&1; then
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
            echo "$SYSINFO_CPU_USAGE $cpu_usage"
        fi
        
        # Memory Information
        if [ -f /proc/meminfo ]; then
            mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
            mem_free=$(grep MemAvailable /proc/meminfo | awk '{print $2}' || grep MemFree /proc/meminfo | awk '{print $2}')
            mem_used=$((mem_total - mem_free))
            
            echo "$SYSINFO_MEMORY_TOTAL $(format_bytes $((mem_total * 1024)))"
            echo "$SYSINFO_MEMORY_USED $(format_bytes $((mem_used * 1024)))"
            echo "$SYSINFO_MEMORY_FREE $(format_bytes $((mem_free * 1024)))"
        fi
        
        # Disk Usage
        echo "$SYSINFO_DISK_USAGE"
        df -h | grep -vE '^Filesystem|tmpfs|cdrom|udev' | awk '{print "  " $6 ": " $3 "/" $2 " (" $5 " used)"}'
        echo ""

        # Section 3: Network Configuration
        echo "=== $SYSINFO_NETWORK ==="
        
        # Network Interfaces
        echo "$SYSINFO_INTERFACES"
        if command -v ip >/dev/null 2>&1; then
            ip addr show | grep -E "^[0-9]+:" | awk '{print "  " $2}' | sed 's/:$//'
            echo ""
            ip addr show | grep -E "inet " | awk '{print "  " $NF ": " $2}'
        else
            ifconfig -a | grep -E "^[a-zA-Z]" | awk '{print "  " $1}'
        fi
        
        # Active Connections (limited)
        echo ""
        echo "$SYSINFO_ACTIVE_CONNECTIONS"
        netstat -tuln 2>/dev/null | grep LISTEN | head -10 | awk '{print "  " $1 " " $4}' || \
        ss -tuln 2>/dev/null | grep LISTEN | head -10 | awk '{print "  " $1 " " $5}'
        echo ""

        # Section 4: Security Status
        echo "=== $SYSINFO_SECURITY ==="
        
        # Firewall Status
        if command -v ufw >/dev/null 2>&1; then
            ufw_status=$(ufw status | head -1 | awk '{print $2}')
            echo "$SYSINFO_FIREWALL $(get_status_plain "$ufw_status")"
        elif command -v firewall-cmd >/dev/null 2>&1; then
            firewall_status=$(systemctl is-active firewalld 2>/dev/null || echo "inactive")
            echo "$SYSINFO_FIREWALL $(get_status_plain "$firewall_status")"
        elif command -v iptables >/dev/null 2>&1; then
            iptables_rules=$(iptables -L | wc -l)
            if [ "$iptables_rules" -gt 8 ]; then
                echo "$SYSINFO_FIREWALL $(get_status_plain "active")"
            else
                echo "$SYSINFO_FIREWALL $(get_status_plain "inactive")"
            fi
        else
            echo "$SYSINFO_FIREWALL $(get_status_plain "unknown")"
        fi
        
        # SSH Status
        ssh_status=$(systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || echo "inactive")
        echo "$SYSINFO_SSH_STATUS $(get_status_plain "$ssh_status")"
        
        # Fail2ban Status
        if command -v fail2ban-client >/dev/null 2>&1; then
            fail2ban_status=$(systemctl is-active fail2ban 2>/dev/null || echo "inactive")
            echo "$SYSINFO_FAIL2BAN_STATUS $(get_status_plain "$fail2ban_status")"
        else
            echo "$SYSINFO_FAIL2BAN_STATUS Not installed"
        fi
        
        # Docker Containers (if Docker is available)
        if command -v docker >/dev/null 2>&1; then
            docker_containers=$(docker ps -q 2>/dev/null | wc -l)
            echo "$SYSINFO_DOCKER_CONTAINERS $docker_containers active"
        fi
        
        # CPU Governor
        if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
            cpu_governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "Not available")
            echo "$SYSINFO_CPU_GOVERNOR $cpu_governor"
        fi
        
        # Listening Ports with PID/Service info
        echo ""
        echo "$SYSINFO_LISTENING_PORTS"
        if command -v netstat >/dev/null 2>&1; then
            netstat -tulpen 2>/dev/null | grep LISTEN | head -10 | awk '{print "  " $1 " " $4 " " $9}' | while read line; do
                echo "  $line"
            done
        else
            ss -tulpen 2>/dev/null | grep LISTEN | head -10 | awk '{print "  " $1 " " $5}' | while read line; do
                echo "  $line"
            done
        fi
        
        # Last Logins
        echo ""
        echo "$SYSINFO_LAST_LOGINS"
        if command -v last >/dev/null 2>&1; then
            last -n 5 2>/dev/null | head -5 | while read line; do
                echo "  $line"
            done
        fi
        
        # SELinux Status (if available)
        if command -v getenforce >/dev/null 2>&1; then
            selinux_status=$(getenforce 2>/dev/null || echo "Disabled")
            echo "$SYSINFO_SELINUX $selinux_status"
        fi
        echo ""

        # Section 5: Running Services
        echo "=== $SYSINFO_SERVICES ==="
        
        # Critical Services
        echo "$SYSINFO_CRITICAL_SERVICES"
        critical_services=("ssh" "sshd" "systemd" "NetworkManager" "network" "cron" "rsyslog")
        for service in "${critical_services[@]}"; do
            if systemctl list-units --type=service | grep -q "$service"; then
                status=$(systemctl is-active "$service" 2>/dev/null || echo "inactive")
                echo "  $service: $(get_status_plain "$status")"
            fi
        done
        
        # Failed Services
        echo ""
        echo "$SYSINFO_SYSTEMD_FAILED"
        failed_services=$(systemctl list-units --failed --no-pager --no-legend 2>/dev/null | wc -l)
        if [ "$failed_services" -gt 0 ]; then
            systemctl list-units --failed --no-pager --no-legend 2>/dev/null | head -5 | awk '{print "  " $1 ": " $4}'
        else
            echo "  No failed services"
        fi
        echo ""

        # Section 6: Connected Devices
        echo "=== $SYSINFO_PERIPHERALS ==="
        
        # USB Devices
        echo "$SYSINFO_USB_DEVICES"
        if command -v lsusb >/dev/null 2>&1; then
            lsusb | head -10 | sed 's/^/  /'
        else
            echo "  lsusb not available"
        fi
        
        # PCI Devices (network/wireless)
        echo ""
        echo "$SYSINFO_PCI_DEVICES"
        if command -v lspci >/dev/null 2>&1; then
            lspci | grep -i "network\|wireless\|ethernet" | head -5 | sed 's/^/  /'
        else
            echo "  lspci not available"
        fi
        
        # WiFi Status
        echo ""
        if command -v iwconfig >/dev/null 2>&1; then
            wifi_interfaces=$(iwconfig 2>/dev/null | grep -c "IEEE 802.11")
            if [ "$wifi_interfaces" -gt 0 ]; then
                echo "$SYSINFO_WIFI_STATUS $(get_status_plain "active") ($wifi_interfaces interfaces)"
            else
                echo "$SYSINFO_WIFI_STATUS $(get_status_plain "inactive")"
            fi
        else
            echo "$SYSINFO_WIFI_STATUS Not available"
        fi
        
        # Bluetooth Status
        if command -v bluetoothctl >/dev/null 2>&1; then
            bluetooth_status=$(systemctl is-active bluetooth 2>/dev/null || echo "inactive")
            echo "$SYSINFO_BLUETOOTH $(get_status_plain "$bluetooth_status")"
        else
            echo "$SYSINFO_BLUETOOTH Not available"
        fi
        echo ""
        
    } > "$OUTPUT_FILE" 2>&1 &
    
    scan_pid=$!
    show_spinner $scan_pid "Collecting comprehensive system information"
    wait $scan_pid

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"

    # Calculate execution time
    end_time=$(date +%s)
    total_time=$((end_time - start_time))
    total_mins=$((total_time / 60))
    total_secs=$((total_time % 60))
    echo -e "${CYAN}⏱️ Total execution time: ${total_mins}m ${total_secs}s${NC}"

    # Display summary
    echo -e "\n${YELLOW}📋 System Summary:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Show key information
    os_info=$(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
    kernel_info=$(uname -r)
    uptime_info=$(uptime -p 2>/dev/null || uptime | cut -d',' -f1)
    hostname_info=$(hostname)

    echo -e "${CYAN}🖥️  System:${NC} $os_info"
    echo -e "${CYAN}⚙️  Kernel:${NC} $kernel_info"
    echo -e "${CYAN}🏠 Hostname:${NC} $hostname_info"
    echo -e "${CYAN}⏱️  Uptime:${NC} $uptime_info"

    # Memory info
    if [ -f /proc/meminfo ]; then
        mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        mem_free=$(grep MemAvailable /proc/meminfo | awk '{print $2}' || grep MemFree /proc/meminfo | awk '{print $2}')
        mem_used=$((mem_total - mem_free))
        mem_percent=$((mem_used * 100 / mem_total))
        echo -e "${CYAN}💾 Memory:${NC} $(format_bytes $((mem_used * 1024)))/$(format_bytes $((mem_total * 1024))) (${mem_percent}%)"
    fi

    # Disk usage
    echo -e "${CYAN}💿 Disk:${NC}"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom|udev' | head -3 | awk '{print "   " $6 ": " $5 " used (" $3 "/" $2 ")"}'

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

system_only_report() {
    echo -e "${BLUE}$SYSINFO_SYSTEM${NC}"
    echo "$SYSINFO_SEPARATOR"

    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_system_only.txt"

    {
        echo "=== $SYSINFO_SYSTEM ==="
        echo "Timestamp: $(date)"
        echo ""
        
        echo "$SYSINFO_OS $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")"
        echo "$SYSINFO_KERNEL $(uname -r)"
        echo "$SYSINFO_ARCHITECTURE $(uname -m)"
        echo "$SYSINFO_HOSTNAME $(hostname)"
        echo "$SYSINFO_UPTIME $(uptime -p 2>/dev/null || uptime)"
    } > "$OUTPUT_FILE" 2>&1

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

hardware_only_report() {
    echo -e "${BLUE}$SYSINFO_HARDWARE${NC}"
    echo "$SYSINFO_SEPARATOR"

    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_hardware_only.txt"

    {
        echo "=== $SYSINFO_HARDWARE ==="
        echo "Timestamp: $(date)"
        echo ""
        
        echo "$SYSINFO_CPU"
        cat /proc/cpuinfo | grep "model name" | head -1 | cut -d':' -f2 | sed 's/^ *//'
        echo ""
        echo "$SYSINFO_MEMORY"
        free -h | grep -E "(Mem|Swap)"
        echo ""
        echo "$SYSINFO_STORAGE"
        df -h / 2>/dev/null || echo "Storage information unavailable"
    } > "$OUTPUT_FILE" 2>&1

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

network_only_report() {
    echo -e "${BLUE}$SYSINFO_NETWORK${NC}"
    echo "$SYSINFO_SEPARATOR"

    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_network_only.txt"

    {
        echo "=== $SYSINFO_NETWORK ==="
        echo "Timestamp: $(date)"
        echo ""
        
        echo "$SYSINFO_INTERFACES"
        ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Network interfaces information unavailable"
        echo ""
        echo "$SYSINFO_ROUTING"
        ip route show 2>/dev/null || route -n 2>/dev/null || echo "Routing table unavailable"
    } > "$OUTPUT_FILE" 2>&1

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

security_only_report() {
    echo -e "${BLUE}$SYSINFO_SECURITY${NC}"
    echo "$SYSINFO_SEPARATOR"

    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_security_only.txt"

    {
        echo "=== $SYSINFO_SECURITY ==="
        echo "Timestamp: $(date)"
        echo ""
        
        echo "$SYSINFO_FIREWALL"
        ufw status 2>/dev/null || iptables -L 2>/dev/null | head -10 || echo "Firewall status unavailable"
        echo ""
        echo "$SYSINFO_USERS"
        w 2>/dev/null || who 2>/dev/null || echo "User information unavailable"
        echo ""
        echo "$SYSINFO_AUTH_LOG"
        tail -5 /var/log/auth.log 2>/dev/null || tail -5 /var/log/secure 2>/dev/null || echo "Authentication logs unavailable"
    } > "$OUTPUT_FILE" 2>&1

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

services_only_report() {
    echo -e "${BLUE}$SYSINFO_SERVICES${NC}"
    echo "$SYSINFO_SEPARATOR"

    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_services_only.txt"

    {
        echo "=== $SYSINFO_SERVICES ==="
        echo "Timestamp: $(date)"
        echo ""
        
        echo "🔍 Critical Services Status:"
        for service in ssh apache2 nginx mysql postgresql docker; do
            if systemctl is-active --quiet $service 2>/dev/null; then
                echo "✅ $service: Running"
            else
                echo "❌ $service: Not running"
            fi
        done
        echo ""
        echo "🏃 Running Services:"
        systemctl list-units --type=service --state=running --no-pager --no-legend | head -10 2>/dev/null || echo "Services information unavailable"
    } > "$OUTPUT_FILE" 2>&1 &

    scan_pid=$!
    show_spinner $scan_pid "Analyzing running services"
    wait $scan_pid

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

devices_only_report() {
    echo -e "${BLUE}$SYSINFO_PERIPHERALS${NC}"
    echo "$SYSINFO_SEPARATOR"

    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_devices_only.txt"

    echo -e "${CYAN}Scanning connected devices...${NC}"

    {
        echo "=== $SYSINFO_PERIPHERALS ==="
        echo "Timestamp: $(date)"
        echo ""
        
        # USB Devices
        echo "$SYSINFO_USB_DEVICES"
        if command -v lsusb >/dev/null 2>&1; then
            lsusb | head -15 | sed 's/^/  /'
        else
            echo "  lsusb not available"
        fi
        
        # PCI Devices
        echo ""
        echo "$SYSINFO_PCI_DEVICES"
        if command -v lspci >/dev/null 2>&1; then
            lspci | grep -i "network\|wireless\|ethernet\|audio\|vga\|display" | head -10 | sed 's/^/  /'
        else
            echo "  lspci not available"
        fi
        
        # WiFi Status
        echo ""
        if command -v iwconfig >/dev/null 2>&1; then
            wifi_interfaces=$(iwconfig 2>/dev/null | grep -c "IEEE 802.11")
            if [ "$wifi_interfaces" -gt 0 ]; then
                echo "$SYSINFO_WIFI_STATUS $(get_status_plain "active") ($wifi_interfaces interfaces)"
                iwconfig 2>/dev/null | grep -A 5 "IEEE 802.11" | head -10
            else
                echo "$SYSINFO_WIFI_STATUS $(get_status_plain "inactive")"
            fi
        else
            echo "$SYSINFO_WIFI_STATUS Not available"
        fi
        
        # Bluetooth Status
        if command -v bluetoothctl >/dev/null 2>&1; then
            bluetooth_status=$(systemctl is-active bluetooth 2>/dev/null || echo "inactive")
            echo "$SYSINFO_BLUETOOTH $(get_status_plain "$bluetooth_status")"
        else
            echo "$SYSINFO_BLUETOOTH Not available"
        fi
        
        # Block Devices
        echo ""
        echo "Storage Devices:"
        if command -v lsblk >/dev/null 2>&1; then
            lsblk | head -15
        else
            echo "  lsblk not available"
        fi
        
    } > "$OUTPUT_FILE" 2>&1 &

    scan_pid=$!
    show_spinner $scan_pid "Scanning connected devices"
    wait $scan_pid

    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) full_system_report ;;
        2) system_only_report ;;
        3) hardware_only_report ;;
        4) network_only_report ;;
        5) security_only_report ;;
        6) services_only_report ;;
        7) devices_only_report ;;
        0) echo -e "${GREEN}$COMMON_DONE${NC}"; break ;;
        *) echo -e "${RED}$MENU_INVALID_CHOICE${NC}" ;;
    esac
    
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read
done 