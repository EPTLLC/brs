#!/bin/bash

# Brabus Recon Suite (BRS) - Port Scanner Module
# Comprehensive port scanning and service enumeration
# company: EasyProTech LLC (www.easypro.tech)
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotechaifactory
# author: brabus
# version: 2.0

# ⚠️ LEGAL WARNING ⚠️
# UNAUTHORIZED SCANNING IS ILLEGAL
# 
# Port scanning can be considered reconnaissance activity under computer
# crime laws. Use ONLY on systems you own or have explicit written 
# authorization to test.
#
# Unauthorized use may result in legal consequences including criminal
# charges, fines, and civil liability.
#
# BY USING THIS MODULE, YOU ACKNOWLEDGE:
# • You own the target systems OR have explicit written authorization
# • You understand applicable laws in your jurisdiction
# • You accept FULL RESPONSIBILITY for your actions
#
# IF YOU CANNOT MAKE THESE DECLARATIONS, EXIT NOW (Ctrl+C)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
DEFAULT_TIMEOUT=300  # 5 minutes default timeout
HOST_TIMEOUT=30     # Timeout per host

# Signal handling for graceful interruption
cleanup() {
    echo -e "\n${YELLOW}⚠️ Scan interrupted by user${NC}"
    pkill -P $$ 2>/dev/null
    exit 130
}
trap cleanup SIGINT SIGTERM

# Show spinner for long operations
show_spinner() {
    local pid=$1
    local message=$2
    local start_time=$(date +%s)
    local spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        local elapsed=$(($(date +%s) - start_time))
        local mins=$((elapsed / 60))
        local secs=$((elapsed % 60))
        printf "\r\033[K${CYAN}${spin_chars:$i:1} %s ${YELLOW}[%02d:%02d] ${RED}(Ctrl+C to cancel)${NC}" "$message" $mins $secs
        i=$(( (i+1) % ${#spin_chars} ))
        sleep 0.1
    done
    printf "\r\033[K"  # Clear line
}

# Language support
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
LANGUAGES_DIR="$BASE_DIR/languages"
CONFIG_DIR="$BASE_DIR/configs"
LANGUAGE_CONFIG="$CONFIG_DIR/language.conf"

# Load language configuration
if [ -f "$LANGUAGE_CONFIG" ]; then
    source "$LANGUAGE_CONFIG"
else
    CURRENT_LANGUAGE="ru"
fi

# Load language file
if [ -f "$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh" ]; then
    source "$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh"
else
    source "$LANGUAGES_DIR/en.sh"
fi

RESULTS_DIR="$BASE_DIR/results"
mkdir -p "$RESULTS_DIR"

show_menu() {
    echo -e "${PURPLE}$PORT_SCANNER_TITLE${NC}"
    echo "=================================="
    echo "1) $PORT_FAST_SCAN"
    echo "2) $PORT_FULL_SCAN"
    echo "3) $PORT_STEALTH_SCAN"
    echo "4) $PORT_UDP_SCAN"
    echo "5) $PORT_VERSION_SCAN"
    echo "6) $PORT_AGGRESSIVE_SCAN"
    echo "7) $PORT_TOR_SCAN"
    echo "8) $PORT_MASS_SCAN"
    echo "9) $PORT_SCAN_ALL_HOSTS"
    echo "0) $SETTINGS_BACK"
    echo -n "$MENU_CHOOSE_OPTION: "
}

get_target() {
    echo -n "$PORT_TARGET_PROMPT "
    read TARGET
    if [ -z "$TARGET" ]; then
        echo -e "${RED}$ATTACK_TARGET_NOT_SPECIFIED${NC}"
        return 1
    fi
    return 0
}

validate_target() {
    local target="$1"
    # Basic validation for IP address or range
    if [[ ! $target =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}(/[0-9]{1,2})?$ ]] && 
       [[ ! $target =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}$ ]]; then
        echo -e "${RED}$PORT_INVALID_TARGET${NC}"
        return 1
    fi
    return 0
}

fast_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_fast_scan_${TARGET//\//_}.txt"
    
    echo -e "${CYAN}$TIMEOUT_SCANNING_WITH ${HOST_TIMEOUT}s${NC}"
    
    timeout $HOST_TIMEOUT nmap -F --host-timeout 10s -T4 "$TARGET" > "$OUTPUT_FILE" 2>&1 &
    scan_pid=$!
    
    show_spinner $scan_pid "Fast scanning $TARGET"
    
    wait $scan_pid
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER ${HOST_TIMEOUT}s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    elif [ $exit_code -ne 0 ]; then
        echo -e "${RED}$TIMEOUT_SCAN_FAILED${NC}"
    else
        echo -e "${GREEN}$TIMEOUT_SCAN_COMPLETED${NC}"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

full_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_full_scan_${TARGET//\//_}.txt"
    
    echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH ${DEFAULT_TIMEOUT}s (5 minutes)${NC}"
    echo -e "${CYAN}This scans all 65535 ports - it may take several minutes${NC}"
    
    timeout $DEFAULT_TIMEOUT nmap -p- --host-timeout 20s -T4 "$TARGET" > "$OUTPUT_FILE" 2>&1 &
    scan_pid=$!
    
    show_spinner $scan_pid "Full port scanning $TARGET"
    
    wait $scan_pid
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER ${DEFAULT_TIMEOUT}s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
          elif [ $exit_code -ne 0 ]; then
          echo -e "${RED}$TIMEOUT_SCAN_FAILED${NC}"
      else
          echo -e "${GREEN}$TIMEOUT_SCAN_COMPLETED${NC}"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

stealth_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_stealth_scan_${TARGET//\//_}.txt"
    
    echo -e "${CYAN}$TIMEOUT_SCANNING_WITH ${DEFAULT_TIMEOUT}s (stealth mode)${NC}"
    
    timeout $DEFAULT_TIMEOUT nmap -sS --host-timeout 30s -T2 "$TARGET" > "$OUTPUT_FILE" 2>&1 &
    scan_pid=$!
    
    show_spinner $scan_pid "Stealth scanning $TARGET"
    
    wait $scan_pid
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER ${DEFAULT_TIMEOUT}s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    elif [ $exit_code -ne 0 ]; then
        echo -e "${RED}$TIMEOUT_SCAN_FAILED${NC}"
    else
        echo -e "${GREEN}$TIMEOUT_SCAN_COMPLETED${NC}"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

udp_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_udp_scan_${TARGET//\//_}.txt"
    
    sudo nmap -sU --top-ports 100 -T4 "$TARGET" | tee "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

version_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_version_scan_${TARGET//\//_}.txt"
    
    echo -e "${CYAN}$TIMEOUT_SCANNING_WITH ${DEFAULT_TIMEOUT}s${NC}"
    
    timeout $DEFAULT_TIMEOUT nmap -sV --host-timeout 15s -T4 "$TARGET" > "$OUTPUT_FILE" 2>&1 &
    scan_pid=$!
    
    show_spinner $scan_pid "Version scanning $TARGET"
    
    wait $scan_pid
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER ${DEFAULT_TIMEOUT}s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    elif [ $exit_code -ne 0 ]; then
        echo -e "${RED}$TIMEOUT_SCAN_FAILED${NC}"
    else
        echo -e "${GREEN}$TIMEOUT_SCAN_COMPLETED${NC}"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

aggressive_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_aggressive_scan_${TARGET//\//_}.txt"
    
    echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH ${DEFAULT_TIMEOUT}s${NC}"
    echo -e "${CYAN}Includes OS detection, version detection, script scanning, and traceroute${NC}"
    
    timeout $DEFAULT_TIMEOUT nmap -A --host-timeout 20s -T4 "$TARGET" > "$OUTPUT_FILE" 2>&1 &
    scan_pid=$!
    
    show_spinner $scan_pid "Aggressive scanning $TARGET"
    
    wait $scan_pid
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER ${DEFAULT_TIMEOUT}s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    elif [ $exit_code -ne 0 ]; then
        echo -e "${RED}$TIMEOUT_SCAN_FAILED${NC}"
    else
        echo -e "${GREEN}$TIMEOUT_SCAN_COMPLETED${NC}"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

tor_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_tor_scan_${TARGET//\//_}.txt"
    
    
    # Check if Tor is available
    if ! command -v tor &> /dev/null; then
        sudo apt install -y tor
    fi
    
    # Check if proxychains is available
    if ! command -v proxychains &> /dev/null; then
        sudo apt install -y proxychains
    fi
    
    sudo systemctl start tor
    sleep 5
    
    proxychains nmap -sT -T2 "$TARGET" | tee "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

mass_scan() {
    get_target || return 1
    validate_target "$TARGET" || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_mass_scan_${TARGET//\//_}.txt"
    
    
    # Check if masscan is available
    if ! command -v masscan &> /dev/null; then
        sudo apt install -y masscan
    fi
    
    echo -n "Scan rate (packets per second, default 1000): "
    read RATE
    RATE=${RATE:-1000}
    
    sudo masscan "$TARGET" -p1-65535 --rate="$RATE" | tee "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

scan_all_hosts() {
    
    # Find latest hosts file
    LATEST_HOSTS_FILE=$(ls -t "$RESULTS_DIR"/*_live_hosts.txt 2>/dev/null | head -1)
    
    if [ -z "$LATEST_HOSTS_FILE" ] || [ ! -f "$LATEST_HOSTS_FILE" ]; then
        echo -e "${RED}$PORT_NO_HOSTS_FILE${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Using hosts file: $LATEST_HOSTS_FILE${NC}"
    
    echo "Select scan type:"
    echo "1) Fast scan of all hosts"
    echo "2) Version detection on all hosts"
    echo "3) Aggressive scan on all hosts"
    read -r scan_type
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_bulk_port_scan.txt"
    
    {
        echo "=== BULK PORT SCAN REPORT ==="
        echo "Timestamp: $(date)"
        echo "Hosts file: $LATEST_HOSTS_FILE"
        echo "Scan type: $scan_type"
        echo ""
    } > "$OUTPUT_FILE"
    
    case $scan_type in
        1)
            while read -r host; do
                if [ ! -z "$host" ]; then
                    echo "--- Fast scan: $host ---" >> "$OUTPUT_FILE"
                    timeout 30 nmap -F --host-timeout 10s -T4 "$host" >> "$OUTPUT_FILE" 2>/dev/null
                    echo "" >> "$OUTPUT_FILE"
                fi
            done < "$LATEST_HOSTS_FILE"
            ;;
        2)
            while read -r host; do
                if [ ! -z "$host" ]; then
                    echo "--- Version scan: $host ---" >> "$OUTPUT_FILE"
                    timeout 60 nmap -sV --host-timeout 15s -T4 "$host" >> "$OUTPUT_FILE" 2>/dev/null || echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                fi
            done < "$LATEST_HOSTS_FILE"
            ;;
        3)
            while read -r host; do
                if [ ! -z "$host" ]; then
                    echo "--- Aggressive scan: $host ---" >> "$OUTPUT_FILE"
                    timeout 120 nmap -A --host-timeout 20s -T4 "$host" >> "$OUTPUT_FILE" 2>/dev/null || echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
                    echo "" >> "$OUTPUT_FILE"
                fi
            done < "$LATEST_HOSTS_FILE"
            ;;
    esac
    
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
    
    # Generate summary
    echo -e "\n${YELLOW}Scan Summary:${NC}"
    echo "Total hosts scanned: $(wc -l < "$LATEST_HOSTS_FILE")"
    echo "Open ports found: $(grep -c "open" "$OUTPUT_FILE" 2>/dev/null || echo "0")"
    echo "SSH services: $(grep -c "22/tcp.*ssh" "$OUTPUT_FILE" 2>/dev/null || echo "0")"
    echo "HTTP services: $(grep -c "80/tcp.*http" "$OUTPUT_FILE" 2>/dev/null || echo "0")"
    echo "HTTPS services: $(grep -c "443/tcp.*https" "$OUTPUT_FILE" 2>/dev/null || echo "0")"
}

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) fast_scan ;;
        2) full_scan ;;
        3) stealth_scan ;;
        4) udp_scan ;;
        5) version_scan ;;
        6) aggressive_scan ;;
        7) tor_scan ;;
        8) mass_scan ;;
        9) scan_all_hosts ;;
        0) echo -e "${GREEN}$ATTACK_GOODBYE${NC}"; break ;;
        *) echo -e "${RED}$ATTACK_INVALID_CHOICE${NC}" ;;
    esac
    

done
