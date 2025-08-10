#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

# Brabus Recon Suite (BRS) - Network Discovery Module
# Network reconnaissance and host enumeration script
# company: EasyProTech LLC (www.easypro.tech)
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotech
# author: brabus
# version: 2.0

# ⚠️ LEGAL WARNING ⚠️
# UNAUTHORIZED SCANNING IS ILLEGAL
# 
# Network discovery and reconnaissance may be considered illegal activity
# under computer crime laws. Use ONLY on networks you own or have explicit
# written authorization to scan.
#
# BY USING THIS MODULE, YOU ACKNOWLEDGE:
# • You own the target networks OR have explicit written authorization  
# • You understand applicable laws in your jurisdiction
# • You accept FULL RESPONSIBILITY for your actions
#
# IF YOU CANNOT MAKE THESE DECLARATIONS, EXIT NOW (Ctrl+C)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
    CURRENT_LANGUAGE="en"
fi

# Load language file
if [ -f "$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh" ]; then
    source "$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh"
else
    source "$LANGUAGES_DIR/en.sh"
fi

RESULTS_DIR="$BASE_DIR/results"
mkdir -p "$RESULTS_DIR"

# Configuration
MAX_PARALLEL_SCANS=10  # Maximum parallel nmap processes
MAX_SCAN_TIME=300      # Maximum scan time in seconds (5 minutes)
MAX_NETWORK_SIZE=24    # Minimum subnet size (max /24)

# Signal handling for graceful interruption
cleanup() {
    echo -e "\n${YELLOW}⚠️ Scan interrupted by user${NC}"
    pkill -P $$ 2>/dev/null
    exit 130
}
trap cleanup SIGINT SIGTERM

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

echo -e "${BLUE}$NET_TITLE${NC}"
echo "$NET_SEPARATOR"

# Check for required tools
check_tools() {
    local nmap_available=false
    local arp_scan_available=false
    
    if command -v nmap >/dev/null 2>&1; then
        nmap_available=true
    fi
    
    if command -v arp-scan >/dev/null 2>&1; then
        arp_scan_available=true
    fi
    
    if [ "$nmap_available" = false ] && [ "$arp_scan_available" = false ]; then
        echo -e "${RED}$NET_TOOLS_MISSING${NC}"
        echo -e "${YELLOW}$NET_TOOLS_INSTALL_HINT${NC}"
        echo -e "${YELLOW}$NET_NO_TOOLS_WARNING${NC}"
        return 1
    elif [ "$nmap_available" = false ] || [ "$arp_scan_available" = false ]; then
        echo -e "${YELLOW}$NET_NO_TOOLS_WARNING${NC}"
        missing_tools=""
        [ "$nmap_available" = false ] && missing_tools="nmap "
        [ "$arp_scan_available" = false ] && missing_tools="${missing_tools}arp-scan"
        echo -e "${YELLOW}Missing tools: $missing_tools${NC}"
    fi
    
    return 0
}

# Validate network format and size
validate_network() {
    local network="$1"
    
    # Check for CIDR format (x.x.x.x/xx)
    if [[ ! $network =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
        return 1
    fi
    
    # Extract IP and subnet
    local ip="${network%/*}"
    local subnet="${network#*/}"
    
    # Validate IP octets (0-255)
    IFS='.' read -ra ADDR <<< "$ip"
    for octet in "${ADDR[@]}"; do
        if [ "$octet" -lt 0 ] || [ "$octet" -gt 255 ] 2>/dev/null; then
            return 1
        fi
    done
    
    # Validate subnet (0-32)
    if [ "$subnet" -lt 0 ] || [ "$subnet" -gt 32 ] 2>/dev/null; then
        return 1
    fi
    
    # Check network size limit
    if [ "$subnet" -lt "$MAX_NETWORK_SIZE" ]; then
        local hosts_count=$((2**(32-subnet)-2))
        echo -e "${RED}⚠️ Network too large: $hosts_count hosts (max recommended: $((2**(32-MAX_NETWORK_SIZE)-2)))${NC}"
        echo -e "${YELLOW}This could take hours to scan. Consider using a smaller network (/$MAX_NETWORK_SIZE or larger)${NC}"
        echo -e "${CYAN}Continue anyway? (y/N):${NC}"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Calculate estimated hosts in network
calculate_hosts() {
    local network="$1"
    local subnet="${network#*/}"
    echo $((2**(32-subnet)-2))
}

# Get all available networks with detailed information
get_available_networks() {
    # Find all networks via ip route, filter only standard networks
    ip route | grep -E '192\.168\.|10\.|172\.' | grep -v 'default' | grep -v 'tun' | grep -v 'via' | grep 'proto kernel' | \
    while read line; do
        local network=$(echo "$line" | awk '{print $1}')
        local interface=$(echo "$line" | awk '{print $3}')
        local subnet="${network#*/}"
        local hosts=$((2**(32-subnet)-2))
        
        # Skip invalid networks
        if [[ $network =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
            echo "$network|$interface|$hosts"
        fi
    done
}

# Interactive network selection
select_network() {
    echo -e "${BLUE}$NET_SCANNING_INTERFACES${NC}"
    
    # Get available networks
    local networks_info=$(get_available_networks)
    
    if [ -z "$networks_info" ]; then
        echo -e "${RED}❌ $ERROR_NETWORK_UNREACHABLE${NC}"
        echo -e "${YELLOW}$NET_ENTER_CUSTOM${NC}"
        echo -n "> "
        read LOCAL_NET
        return
    fi
    
    echo -e "\n${YELLOW}$NET_AVAILABLE_NETWORKS${NC}"
    echo "════════════════════════════════════════"
    
    local counter=1
    local networks_array=()
    
    # Display available networks
    while IFS='|' read -r network interface hosts; do
        networks_array+=("$network")
        printf "${GREEN}%2d)${NC} %-18s ${CYAN}%-8s${NC} ${YELLOW}(%s hosts)${NC}\n" \
               "$counter" "$network" "$interface" "$hosts"
        ((counter++))
    done <<< "$networks_info"
    
    # Add custom option
    echo -e "${GREEN}$counter)${NC} $NET_CUSTOM_OPTION"
    
    # Add back option
    echo -e "${GREEN}0)${NC} $SETTINGS_BACK"
    
    echo "════════════════════════════════════════"
    echo -n "$NET_SELECT_NETWORK "
    read -r choice
    
    # Validate choice
    if [[ "$choice" =~ ^[0-9]+$ ]]; then
        if [ "$choice" -eq 0 ]; then
            # Return to main menu
            echo -e "${YELLOW}Operation cancelled${NC}"
            exit 0
        elif [ "$choice" -ge 1 ] && [ "$choice" -le "$counter" ]; then
            if [ "$choice" -eq "$counter" ]; then
                # Custom network input
                echo -e "${CYAN}$NET_ENTER_CUSTOM${NC}"
                echo -n "> "
                read LOCAL_NET
                # Check if user wants to cancel custom input
                if [ -z "$LOCAL_NET" ]; then
                    echo -e "${YELLOW}Operation cancelled${NC}"
                    exit 0
                fi
            else
                # Select from available networks
                LOCAL_NET="${networks_array[$((choice-1))]}"
                echo -e "${CYAN}✅ Selected: $LOCAL_NET${NC}"
            fi
        else
            echo -e "${RED}$NET_INVALID_CHOICE${NC}"
            LOCAL_NET="${networks_array[0]}"
        fi
    else
        echo -e "${RED}$NET_INVALID_CHOICE${NC}"
        LOCAL_NET="${networks_array[0]}"
    fi
}

# Check tools availability
if ! check_tools; then
    exit 1
fi

# Allow non-interactive selection via environment variable
if [ -n "${LOCAL_NET:-}" ]; then
    echo -e "${BLUE}$NET_VALIDATING_NETWORK${NC}"
    if ! validate_network "$LOCAL_NET"; then
        echo -e "${RED}$ERROR_INVALID_NETWORK${NC}"
        exit 1
    fi
else
    # Interactive network selection
    select_network
fi

# Validate selected network
if [ -z "${LOCAL_NET:-}" ]; then
    echo -e "${BLUE}$NET_VALIDATING_NETWORK${NC}"
    if ! validate_network "$LOCAL_NET"; then
        echo -e "${RED}$ERROR_INVALID_NETWORK${NC}"
        exit 1
    fi
fi

# Check network size
ESTIMATED_HOSTS=$(calculate_hosts "$LOCAL_NET")
echo -e "\n${GREEN}$NET_SELECTED_NETWORK $LOCAL_NET${NC}"
echo -e "${CYAN}Estimated hosts to scan: $ESTIMATED_HOSTS${NC}"
echo -e "${CYAN}Maximum scan time: ${MAX_SCAN_TIME}s${NC}"

if [ "$ESTIMATED_HOSTS" -gt 1000 ]; then
    echo -e "${YELLOW}⚠️ Large network detected. This may take several minutes.${NC}"
    echo -e "${CYAN}Continue? (y/N):${NC}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Scan cancelled by user${NC}"
        exit 0
    fi
fi

# Create timestamped results files
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
LIVE_HOSTS_FILE="$RESULTS_DIR/${TIMESTAMP}_live_hosts.txt"
SCAN_RESULTS_FILE="$RESULTS_DIR/${TIMESTAMP}_network_scan.txt"
ARP_RESULTS_FILE="$RESULTS_DIR/${TIMESTAMP}_arp_scan.txt"

echo -e "\n${BLUE}$NET_SEARCHING_HOSTS${NC}"

# Ping sweep to discover live hosts (if nmap available) with timeout
if command -v nmap >/dev/null 2>&1; then
    echo -e "${CYAN}$TIMEOUT_RUNNING_WITH ${MAX_SCAN_TIME}s${NC}"
    
    # Run nmap with timeout in background
    timeout $MAX_SCAN_TIME nmap -sn --host-timeout 10s -T4 $LOCAL_NET 2>/dev/null | grep "Nmap scan report" | awk '{print $NF}' > "$LIVE_HOSTS_FILE" &
    nmap_pid=$!
    
    # Show spinner while nmap runs
    show_spinner $nmap_pid "Ping sweep scanning..."
    
    # Wait for nmap to complete or timeout
    wait $nmap_pid 2>/dev/null
    nmap_exit_code=$?
    
    if [ $nmap_exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER ${MAX_SCAN_TIME}s${NC}"
    elif [ $nmap_exit_code -ne 0 ]; then
        echo -e "${RED}$TIMEOUT_SCAN_FAILED${NC}"
        touch "$LIVE_HOSTS_FILE"
    else
        echo -e "${GREEN}$TIMEOUT_SCAN_COMPLETED${NC}"
    fi
else
    touch "$LIVE_HOSTS_FILE"
fi

# ARP scanning for additional host discovery
echo -e "\n${BLUE}$NET_ARP_SCANNING${NC}"

# Use arp-scan if available for detailed MAC info
if command -v arp-scan >/dev/null 2>&1; then
    echo "=== ARP SCAN RESULTS ===" > "$ARP_RESULTS_FILE"
    echo "Timestamp: $(date)" >> "$ARP_RESULTS_FILE"
    echo "Network: $LOCAL_NET" >> "$ARP_RESULTS_FILE"
    echo "" >> "$ARP_RESULTS_FILE"
    
    echo -e "${CYAN}$TIMEOUT_RUNNING_WITH 60s${NC}"
    
    # Run arp-scan with timeout
    timeout 60 sudo arp-scan -l 2>/dev/null >> "$ARP_RESULTS_FILE" &
    arp_pid=$!
    
    show_spinner $arp_pid "ARP scanning..."
    
    wait $arp_pid 2>/dev/null
    arp_exit_code=$?
    
    if [ $arp_exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 60s${NC}"
    elif [ $arp_exit_code -ne 0 ]; then
        echo -e "${YELLOW}⚠️ ARP scan completed with warnings${NC}"
    else
        echo -e "${GREEN}✅ ARP scan completed${NC}"
    fi
    
    # Extract IPs from ARP scan
    grep -E "192\.168\.|10\.|172\." "$ARP_RESULTS_FILE" 2>/dev/null | awk '{print $1}' >> "$LIVE_HOSTS_FILE" 2>/dev/null || true
fi

# Remove duplicates and filter only IP addresses
sort "$LIVE_HOSTS_FILE" 2>/dev/null | uniq | grep -v "^$" | grep -E "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$" > "$LIVE_HOSTS_FILE.tmp" 2>/dev/null || true
mv "$LIVE_HOSTS_FILE.tmp" "$LIVE_HOSTS_FILE" 2>/dev/null || touch "$LIVE_HOSTS_FILE"

HOSTS_COUNT=$(wc -l < "$LIVE_HOSTS_FILE" 2>/dev/null || echo "0")
echo -e "\n${GREEN}$NET_HOSTS_FOUND: $HOSTS_COUNT${NC}"

if [ "$HOSTS_COUNT" -eq 0 ]; then
    echo -e "${RED}$NO_RESULTS${NC}"
    echo -e "${YELLOW}Tips:${NC}"
    echo "- Try a different network range"
    echo "- Check network connectivity"
    echo "- Ensure nmap/arp-scan are installed"
    exit 1
fi

echo -e "\n${YELLOW}$NET_LIVE_HOSTS${NC}"
cat "$LIVE_HOSTS_FILE" | head -20

# Quick port scanning for each discovered host with parallel limit and timeout
if command -v nmap >/dev/null 2>&1 && [ "$HOSTS_COUNT" -gt 0 ]; then
    echo -e "\n${BLUE}$NET_PORT_SCANNING${NC}"
    echo -e "${YELLOW}Parallel limit: $MAX_PARALLEL_SCANS, Timeout per host: 30s${NC}"
    
    {
        echo "=== NETWORK RECONNAISSANCE REPORT ==="
        echo "Timestamp: $(date)"
        echo "Network: $LOCAL_NET"
        echo "Hosts discovered: $HOSTS_COUNT"
        echo "Parallel scan limit: $MAX_PARALLEL_SCANS"
        echo ""
        echo "=== SCAN RESULTS ==="
    } > "$SCAN_RESULTS_FILE"

    # Function for parallel scanning with timeout
    scan_host() {
        local host="$1"
        local temp_file="/tmp/nmap_${host//\./_}_$$"
        
        echo "--- $host ---" > "$temp_file"
        # Fast scan with timeout
        timeout 30 nmap -F --host-timeout 10s -T4 "$host" >> "$temp_file" 2>/dev/null || echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$temp_file"
        echo "" >> "$temp_file"
        
        # Append to main results file (with lock to avoid conflicts)
        (
            flock -x 200
            cat "$temp_file" >> "$SCAN_RESULTS_FILE"
        ) 200>/tmp/nmap_lock
        
        rm -f "$temp_file"
    }

    # Launch parallel scans with progress
    job_count=0
    current_host=0
    total_hosts=$HOSTS_COUNT
    start_time=$(date +%s)
    
    while read -r host; do
        if [ ! -z "$host" ]; then
            current_host=$((current_host + 1))
                         # Scanning in background - no additional UI needed
            
            # Launch background scan
            scan_host "$host" &
            
            # Increment job counter
            ((job_count++))
            
            # If we've reached the limit, wait for jobs to finish
            if [ $job_count -ge $MAX_PARALLEL_SCANS ]; then
                wait
                job_count=0
            fi
        fi
    done < "$LIVE_HOSTS_FILE"
    
    # Wait for remaining jobs
    wait
    
         echo ""
fi

echo -e "\n${GREEN}$NET_SCAN_COMPLETE${NC}"
echo -e "${BLUE}$NET_RESULTS_SAVED${NC}"
echo "  $NET_LIVE_HOSTS_FILE: $LIVE_HOSTS_FILE"
if [ -f "$SCAN_RESULTS_FILE" ]; then
    echo "  $NET_SCAN_RESULTS_FILE: $SCAN_RESULTS_FILE"
fi
if [ -f "$ARP_RESULTS_FILE" ]; then
    echo "  ARP Results: $ARP_RESULTS_FILE"
fi

# Display detailed report if arp-scan was used
if [ -f "$ARP_RESULTS_FILE" ] && [ -s "$ARP_RESULTS_FILE" ]; then
    echo -e "\n${YELLOW}$NET_DETAILED_REPORT${NC}"
    echo -e "${BLUE}$NET_ARP_TABLE${NC}"
    
    # Show ARP table with formatting
    grep -E "192\.168\.|10\.|172\." "$ARP_RESULTS_FILE" 2>/dev/null | while read -r line; do
        ip=$(echo "$line" | awk '{print $1}')
        mac=$(echo "$line" | awk '{print $2}')
        vendor=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; printf "\n"}' | sed 's/[[:space:]]*$//')
        
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "  ${GREEN}$ip${NC} - ${YELLOW}$mac${NC} - ${BLUE}$vendor${NC}"
        fi
    done
fi

# Display reconnaissance summary
if command -v nmap >/dev/null 2>&1 && [ -f "$SCAN_RESULTS_FILE" ]; then
    echo -e "\n${YELLOW}$NET_STATISTICS${NC}"
    echo "$NET_TOTAL_HOSTS: $HOSTS_COUNT"
    echo "$NET_OPEN_PORTS: $(grep -c "open" "$SCAN_RESULTS_FILE" 2>/dev/null || echo "0")"
    echo "$NET_SSH_SERVERS: $(grep -c "22/tcp.*ssh" "$SCAN_RESULTS_FILE" 2>/dev/null || echo "0")"
    echo "$NET_HTTP_SERVERS: $(grep -c "80/tcp.*http" "$SCAN_RESULTS_FILE" 2>/dev/null || echo "0")"
    echo "$NET_HTTPS_SERVERS: $(grep -c "443/tcp.*https" "$SCAN_RESULTS_FILE" 2>/dev/null || echo "0")"

    echo -e "\n${BLUE}$NET_NEXT_STEPS${NC}"
    echo "  $NET_PORT_SCANNER_HINT"
    echo "  $NET_VULN_SCANNER_HINT"
fi

# Calculate total execution time
total_time=$(($(date +%s) - start_time))
total_mins=$((total_time / 60))
total_secs=$((total_time % 60))
echo -e "\n${CYAN}⏱️ Total execution time: ${total_mins}m ${total_secs}s${NC}"
