#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

# Brabus Recon Suite (BRS) - Main Control Script
# Professional Network Reconnaissance & Penetration Testing Toolkit
# company: EasyProTech LLC (www.easypro.tech)
# author: brabus
# version: 2.1
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotech

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# BRS version
BRS_VERSION="2.1"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR"
SCRIPTS_DIR="$BASE_DIR/scripts"
RESULTS_DIR="$BASE_DIR/results"
LANGUAGES_DIR="$BASE_DIR/languages"
CONFIG_DIR="$BASE_DIR/configs"
LANGUAGE_CONFIG="$CONFIG_DIR/language.conf"

# Load tool management module
if [ -f "$BASE_DIR/tools.sh" ]; then
    source "$BASE_DIR/tools.sh"
else
    echo -e "${RED}❌ Error: tools.sh module not found!${NC}"
    echo "Please ensure tools.sh is in the same directory as main.sh"
    exit 1
fi

# Ethics and Legal Agreement System
ETHICS_AGREEMENT_FILE="$CONFIG_DIR/ethics_agreement.conf"
FIRST_RUN_FLAG="$CONFIG_DIR/first_run.flag"

show_legal_warning() {
    clear
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    ⚠️  CRITICAL WARNING  ⚠️                    ║"
    echo "║              UNAUTHORIZED USE IS ILLEGAL                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}This toolkit contains powerful penetration testing tools that can${NC}"
    echo -e "${YELLOW}cause significant damage if misused. Unauthorized use may result in:${NC}"
    echo ""
    echo -e "${RED}• Criminal charges and prosecution under computer crime laws${NC}"
    echo -e "${RED}• Substantial fines (potentially millions of dollars)${NC}"
    echo -e "${RED}• Prison time (multiple years depending on jurisdiction)${NC}"
    echo -e "${RED}• Permanent criminal record affecting employment and travel${NC}"
    echo -e "${RED}• Civil lawsuits for damages and business disruption${NC}"
    echo ""
    echo -e "${GREEN}AUTHORIZED USE ONLY:${NC}"
    echo -e "${GREEN}• Your own networks and systems${NC}"
    echo -e "${GREEN}• With explicit written authorization from system owners${NC}"
    echo -e "${GREEN}• Within scope of authorized penetration testing contracts${NC}"
    echo -e "${GREEN}• As part of legitimate bug bounty programs${NC}"
    echo ""
    echo -e "${CYAN}For complete legal terms: see LEGAL.md${NC}"
    echo -e "${CYAN}For ethical guidelines: see ETHICS.md${NC}"
    echo ""
}

require_ethics_agreement() {
    if [ -f "$ETHICS_AGREEMENT_FILE" ]; then
        source "$ETHICS_AGREEMENT_FILE"
        if [ "$ETHICS_AGREED" = "true" ] && [ "$AGREEMENT_DATE" != "" ]; then
            # Check if agreement is recent (within 30 days)
            local current_date=$(date +%s)
            local agreement_epoch=$(date -d "$AGREEMENT_DATE" +%s 2>/dev/null || echo "0")
            local days_since=$(( (current_date - agreement_epoch) / 86400 ))
            
            if [ $days_since -gt 30 ]; then
                echo -e "${YELLOW}⚠️ Ethics agreement expired (30+ days old). Renewal required.${NC}"
                sleep 2
                get_ethics_agreement
            fi
            return 0
        fi
    fi
    
    get_ethics_agreement
}

get_ethics_agreement() {
    while true; do
        show_legal_warning
        echo -e "${YELLOW}$LEGAL_REQUIRED_DECLARATIONS${NC}"
        echo ""
        echo "$LEGAL_DECLARATION_INTRO"
        echo ""
        echo "$LEGAL_DECLARATION_OWNERSHIP"
        echo ""
        echo "$LEGAL_DECLARATION_UNDERSTAND"
        echo ""
        echo "$LEGAL_DECLARATION_RESPONSIBILITY"
        echo ""
        echo "$LEGAL_DECLARATION_LAWS"
        echo ""
        echo "$LEGAL_DECLARATION_REVOCATION"
        echo ""
        
        # Add Russian specific disclaimer for Russian language
        if [ "$CURRENT_LANGUAGE" = "ru" ]; then
            echo -e "${CYAN}$LEGAL_RUSSIAN_DISCLAIMER${NC}"
            echo ""
            echo "$LEGAL_RUSSIAN_USER_CONFIRMS"
            echo "$LEGAL_RUSSIAN_EDUCATIONAL_ONLY"
            echo "$LEGAL_RUSSIAN_UNDERSTANDS_LAW"
            echo "$LEGAL_RUSSIAN_FULL_RESPONSIBILITY"
            echo "$LEGAL_RUSSIAN_COMPLIANCE"
            echo ""
        fi
        
        echo -e "${RED}$LEGAL_CANNOT_DECLARE${NC}"
        echo ""
        echo -e "${CYAN}$LEGAL_SOLEMNLY_AGREE${NC}"
        echo ""
        echo -n "$LEGAL_TYPE_AGREE "
        read agreement
        
        # Support multiple language responses
        case "$agreement" in
            "I AGREE")
                # Save agreement locally and globally
                mkdir -p "$CONFIG_DIR"
                
                # Local project agreement
                cat > "$ETHICS_AGREEMENT_FILE" << EOF
# BRS Ethics Agreement Record
ETHICS_AGREED="true"
AGREEMENT_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
AGREEMENT_IP="$(hostname -I | awk '{print $1}' 2>/dev/null || echo 'unknown')"
AGREEMENT_USER="$(whoami)"
AGREEMENT_HOSTNAME="$(hostname)"
AGREEMENT_LANGUAGE="$CURRENT_LANGUAGE"
EOF
                
                # Global user agreement record (permanent evidence)
                GLOBAL_AGREEMENT_FILE="$HOME/.brs_agreed"
                cat >> "$GLOBAL_AGREEMENT_FILE" << EOF
# Brabus Recon Suite (BRS) - Legal Agreement Record
# This file serves as permanent evidence of user consent
# $COMPANY_NAME | $COMPANY_WEBSITE

[AGREEMENT_$(date '+%Y%m%d_%H%M%S')]
DATE="$(date '+%Y-%m-%d %H:%M:%S %Z')"
USER="$(whoami)"
HOSTNAME="$(hostname)"
IP_ADDRESS="$(hostname -I | awk '{print $1}' 2>/dev/null || echo 'unknown')"
WORKING_DIR="$(pwd)"
            BRS_VERSION="$BRS_VERSION"
LANGUAGE="$CURRENT_LANGUAGE"
AGREEMENT_TYPE="FULL_ETHICS_CONSENT"
LEGAL_DECLARATION="I declare under penalty of perjury that I will use BRS only on networks and systems I own or have explicit written authorization to test"
INDEMNIFICATION="I agree to indemnify and hold harmless $COMPANY_NAME from any claims arising from my use of this software"
JURISDICTION="$COMPANY_JURISDICTION"
TIMESTAMP_EPOCH="$(date +%s)"

EOF
                chmod 600 "$GLOBAL_AGREEMENT_FILE" 2>/dev/null || true
                echo ""
                echo -e "${GREEN}$LEGAL_AGREEMENT_RECORDED${NC}"
                echo -e "${YELLOW}$LEGAL_LEGALLY_BINDING${NC}"
                sleep 3
                break
                ;;
            "EXIT")
                echo -e "${YELLOW}$LEGAL_EXITING${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}$LEGAL_INVALID_RESPONSE${NC}"
                ;;
        esac
    done
}

# Language system functions
get_available_languages() {
    local langs=()
    if [ -d "$LANGUAGES_DIR" ]; then
        for lang_file in "$LANGUAGES_DIR"/*.sh; do
            if [ -f "$lang_file" ]; then
                local lang_code=$(basename "$lang_file" .sh)
                langs+=("$lang_code")
            fi
        done
    fi
    echo "${langs[@]}"
}

load_language_config() {
    if [ -f "$LANGUAGE_CONFIG" ]; then
        source "$LANGUAGE_CONFIG"
    else
        # Default to English if config not found
        CURRENT_LANGUAGE="en"
        AUTO_DETECT_LANGUAGE="false"
        AVAILABLE_LANGUAGES=$(get_available_languages)
    fi
}

load_language() {
    local lang_file="$LANGUAGES_DIR/$CURRENT_LANGUAGE.sh"
    if [ -f "$lang_file" ]; then
        source "$lang_file"
    else
        echo "Warning: Language file $lang_file not found, using English"
        CURRENT_LANGUAGE="en"
        source "$LANGUAGES_DIR/en.sh"
    fi
}

save_language_config() {
    mkdir -p "$CONFIG_DIR"
    cat > "$LANGUAGE_CONFIG" << EOF
# Brabus Recon Suite (BRS) Language Configuration
# Supported languages: $(get_available_languages)

# Current language
CURRENT_LANGUAGE="$CURRENT_LANGUAGE"

# Language auto-detection based on system locale
AUTO_DETECT_LANGUAGE="$AUTO_DETECT_LANGUAGE"

# Available languages (space-separated)
AVAILABLE_LANGUAGES="$AVAILABLE_LANGUAGES"

# Language files directory
LANGUAGES_DIR="languages"
EOF
}

show_language_selection() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 BRABUS RECON SUITE (BRS)                     ║"
    echo "║            Network Reconnaissance & Pentesting               ║"
    echo "║               EasyProTech LLC | brabus v2.1                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}$LANG_SELECTION_HEADER${NC}"
    echo "=========================================="
    echo ""
    
    local langs=($(get_available_languages))
    local i=1
    
    for lang in "${langs[@]}"; do
        if [ -f "$LANGUAGES_DIR/$lang.sh" ]; then
            # Temporarily load language to get name
            local temp_lang_name=""
            source "$LANGUAGES_DIR/$lang.sh"
            echo "$i) $LANG_NAME ($LANG_CODE)"
            i=$((i+1))
        fi
    done
    
    echo ""
        echo "$LANG_SELECTION_PROMPT ($LANG_AGREEMENT_DISPLAY / $LANG_EXIT_DISPLAY):"
        echo -n "> "
    read choice
    
    local langs_array=($(get_available_languages))
    local selected_index=$((choice - 1))
    
    if [ $selected_index -ge 0 ] && [ $selected_index -lt ${#langs_array[@]} ]; then
        CURRENT_LANGUAGE="${langs_array[$selected_index]}"
        save_language_config
        load_language
        echo -e "${GREEN}✅ Language changed to: $LANG_NAME${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ Invalid choice, using English${NC}"
        CURRENT_LANGUAGE="en"
        load_language
        return 1
    fi
}

change_language() {
    echo -e "${CYAN}🌍 LANGUAGE SELECTION${NC}"
    echo "========================="
    echo "Current: $LANG_NAME ($LANG_CODE)"
    echo ""
    echo "Available languages:"
    
    local langs=($(get_available_languages))
    local i=1
    
    for lang in "${langs[@]}"; do
        if [ -f "$LANGUAGES_DIR/$lang.sh" ]; then
            # Temporarily load language to get name
            local temp_current_lang="$CURRENT_LANGUAGE"
            source "$LANGUAGES_DIR/$lang.sh"
            echo "$i) $LANG_NAME ($LANG_CODE)"
            # Restore current language
            CURRENT_LANGUAGE="$temp_current_lang"
            load_language
            i=$((i+1))
        fi
    done
    
    echo "0) Back"
    echo ""
    echo -n "Choose option: "
    read choice
    
    if [ "$choice" = "0" ]; then
        return
    fi
    
    local langs_array=($(get_available_languages))
    local selected_index=$((choice - 1))
    
    if [ $selected_index -ge 0 ] && [ $selected_index -lt ${#langs_array[@]} ]; then
        CURRENT_LANGUAGE="${langs_array[$selected_index]}"
        save_language_config
        load_language
        echo -e "${GREEN}✅ Language changed successfully!${NC}"
        echo "Please note: Interface will update immediately"
        echo ""
    else
        echo -e "${RED}❌ Invalid choice${NC}"
    fi
}

# Initialize language system
load_language_config
AVAILABLE_LANGUAGES=$(get_available_languages)

# Show language selection on first run or if no valid language is set
if [ ! -f "$LANGUAGE_CONFIG" ] || [ -z "$CURRENT_LANGUAGE" ]; then
    show_language_selection
else
    load_language
fi

show_banner() {
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                 BRABUS RECON SUITE (BRS)                     ║"
    echo "║            Network Reconnaissance & Pentesting               ║"
    echo "║               EasyProTech LLC | brabus v2.1                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_start_choice() {
    echo -e "${CYAN}QUICK START${NC}"
    echo "===================="
    echo "1) Full Scan (auto)"
    echo "2) Classic Menu"
    echo "0) $MENU_EXIT"
    echo ""
    echo -n "$MENU_CHOOSE_OPTION: "
}

run_full_scan_wizard() {
    echo -e "${PURPLE}FULL SCAN WIZARD${NC}"
    echo "====================="
    echo "- Press Enter to scan this machine"
    echo "- Or enter IP/Domain to scan a remote target"
    echo -n "> "
    read FS_TARGET

    # Resolve local target
    if [ -z "$FS_TARGET" ]; then
        LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
        [ -z "$LOCAL_IP" ] && LOCAL_IP="127.0.0.1"
        FS_TARGET="$LOCAL_IP"
        echo -e "${CYAN}Target: local ($FS_TARGET)${NC}"
        # 1) System Information - Full
        printf "1\n\n0\n" | "$SCRIPTS_DIR/system_info.sh"
        # 2) Port Scanning - Aggressive (-A)
        printf "6\n$FS_TARGET\n0\n" | "$SCRIPTS_DIR/port_scanner.sh"
        # 3) Vulnerability Scanner - Comprehensive (force continue when unreachable)
        printf "10\n$FS_TARGET\ny\n0\n" | "$SCRIPTS_DIR/vulnerability_scanner.sh"
        echo -e "${GREEN}Full scan complete. Reports saved in: $RESULTS_DIR${NC}"
        return
    fi

    # If looks like a domain, run domain reconnaissance as well
    if echo "$FS_TARGET" | grep -Eq '^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)+$'; then
        printf "10\n$FS_TARGET\n0\n" | "$SCRIPTS_DIR/domain_recon.sh"
    fi

    # Port Scanning (Aggressive) on provided target
    printf "6\n$FS_TARGET\n0\n" | "$SCRIPTS_DIR/port_scanner.sh"
    # Vulnerability Scanner (Comprehensive)
    printf "10\n$FS_TARGET\ny\n0\n" | "$SCRIPTS_DIR/vulnerability_scanner.sh"
    echo -e "${GREEN}Full scan complete. Reports saved in: $RESULTS_DIR${NC}"
}

show_main_menu() {
    echo -e "${CYAN}$MENU_TITLE${NC}"
    echo "$MENU_SEPARATOR"
    echo "1) $MENU_NETWORK_DISCOVERY"
    echo "2) $MENU_PORT_SCANNER"
    echo "3) $MENU_DOMAIN_RECON"
    echo "4) $MENU_VULNERABILITY_SCANNER"
    echo "5) $MENU_SYSINFO"
    echo "6) $MENU_ATTACK_TOOLS"
    echo "7) $MENU_VIEW_RESULTS"
    echo "8) $MENU_SETTINGS"
    echo "0) $MENU_EXIT"
    echo ""
    echo -n "$MENU_CHOOSE_OPTION: "
}

run_network_discovery() {
    if [ -f "$SCRIPTS_DIR/network_discovery.sh" ]; then
        chmod +x "$SCRIPTS_DIR/network_discovery.sh"
        "$SCRIPTS_DIR/network_discovery.sh"
    else
        echo -e "${RED}❌ $ERROR_TOOL_NOT_FOUND: network_discovery.sh${NC}"
    fi
}

run_port_scanner() {
    if [ -f "$SCRIPTS_DIR/port_scanner.sh" ]; then
        chmod +x "$SCRIPTS_DIR/port_scanner.sh"
        "$SCRIPTS_DIR/port_scanner.sh"
    else
        echo -e "${RED}❌ $ERROR_TOOL_NOT_FOUND: port_scanner.sh${NC}"
    fi
}

run_domain_recon() {
    if [ -f "$SCRIPTS_DIR/domain_recon.sh" ]; then
        chmod +x "$SCRIPTS_DIR/domain_recon.sh"
        "$SCRIPTS_DIR/domain_recon.sh"
    else
        echo -e "${RED}❌ $ERROR_TOOL_NOT_FOUND: domain_recon.sh${NC}"
    fi
}

run_vulnerability_scanner() {
    if [ -f "$SCRIPTS_DIR/vulnerability_scanner.sh" ]; then
        chmod +x "$SCRIPTS_DIR/vulnerability_scanner.sh"
        "$SCRIPTS_DIR/vulnerability_scanner.sh"
    else
        echo -e "${RED}❌ $ERROR_TOOL_NOT_FOUND: vulnerability_scanner.sh${NC}"
    fi
}

run_system_info() {
    if [ -f "$SCRIPTS_DIR/system_info.sh" ]; then
        chmod +x "$SCRIPTS_DIR/system_info.sh"
        "$SCRIPTS_DIR/system_info.sh"
    else
        echo -e "${RED}❌ $ERROR_TOOL_NOT_FOUND: system_info.sh${NC}"
    fi
}

run_attack_tools() {
    if [ -f "$SCRIPTS_DIR/attack_tools.sh" ]; then
        chmod +x "$SCRIPTS_DIR/attack_tools.sh"
        "$SCRIPTS_DIR/attack_tools.sh"
    else
        echo -e "${RED}❌ $ERROR_TOOL_NOT_FOUND: attack_tools.sh${NC}"
    fi
}

show_results_menu() {
    while true; do
        echo -e "${CYAN}📊 RESULTS MENU${NC}"
        echo "====================="
        echo "1) $MENU_VIEW_RESULTS"
        echo "2) $MENU_CLEANUP"
        echo "0) $SETTINGS_BACK"
        echo ""
        echo -n "$MENU_CHOOSE_OPTION: "
        
        read choice
        case $choice in
            1) view_results ;;
            2) cleanup_results ;;
            0) return ;;
            *) 
                echo -e "${RED}$MENU_INVALID_CHOICE${NC}"
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                ;;
        esac
    done
}

show_settings_menu() {
    while true; do
        echo -e "${CYAN}$SETTINGS_TITLE${NC}"
        echo "$SETTINGS_SEPARATOR"
        echo "1) $SETTINGS_LANGUAGE"
        echo "2) $SETTINGS_TOOLS"
        echo "3) $SETTINGS_HELP"
        echo "0) $SETTINGS_BACK"
        echo ""
        echo -n "$MENU_CHOOSE_OPTION: "
        
        read choice
        case $choice in
            1) 
                change_language
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                ;;
            2) 
                check_all_tools
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                ;;
            3) 
                show_help
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                ;;
            0) return ;;
            *) 
                echo -e "${RED}$MENU_INVALID_CHOICE${NC}"
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                ;;
        esac
    done
}

view_results() {
    echo -e "${BLUE}$RESULTS_TITLE${NC}"
    echo "============================="
    
    if [ ! -d "$RESULTS_DIR" ] || [ -z "$(ls -A "$RESULTS_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}📂 $NO_RESULTS${NC}"
        echo -e "\n${BLUE}$MENU_PRESS_ENTER${NC}"
        return
    fi
    
    echo -e "${CYAN}Latest results:${NC}"
    ls -lt "$RESULTS_DIR" | head -11
    echo -e "\n${BLUE}$MENU_PRESS_ENTER${NC}"
}

cleanup_results() {
    echo -e "${YELLOW}🧹 $MENU_CLEANUP? (y/N): ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$RESULTS_DIR"/*
        echo -e "${GREEN}✅ Cleanup completed successfully${NC}"
    fi
    echo -e "\n${BLUE}$MENU_PRESS_ENTER${NC}"
}

show_help() {
    echo -e "${BLUE}$HELP_TITLE${NC}"
    echo "=========="
    echo "1. $MENU_NETWORK_DISCOVERY - Network host discovery"
    echo "2. $MENU_PORT_SCANNER - Port scanning modes"
    echo "3. $MENU_VULNERABILITY_SCANNER - Vulnerability assessment"
    echo "4. $MENU_SYSINFO - System reconnaissance and configuration analysis"
    echo "5. $MENU_ATTACK_TOOLS - ⚠️ Authorized testing only"
    echo ""
    echo "Results saved to: $RESULTS_DIR"
    echo ""
    echo "Tool requirements check available in Settings → Check Tools"
}

# Create necessary directories
mkdir -p "$SCRIPTS_DIR" "$RESULTS_DIR" "$CONFIG_DIR"

# Set execute permissions for scripts
chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null
chmod +x "$BASE_DIR/tools.sh" 2>/dev/null

# Quick tool check on startup (without user interaction)
quick_tool_check

# Check ethics agreement before starting
require_ethics_agreement

# Start: Quick choice then classic menu
show_banner
show_start_choice
read start_choice
case $start_choice in
    1)
        run_full_scan_wizard
        ;;
    0)
        echo -e "${GREEN}👋 $COMMON_DONE!${NC}"; exit 0 ;;
    *) : ;; # fallthrough to classic menu
esac

while true; do
    show_main_menu
    read choice
    case $choice in
        1) run_network_discovery ;;
        2) run_port_scanner ;;
        3) run_domain_recon ;;
        4) run_vulnerability_scanner ;;
        5) run_system_info ;;
        6) run_attack_tools ;;
        7) show_results_menu ;;
        8) show_settings_menu ;;
        0) echo -e "${GREEN}👋 $COMMON_DONE!${NC}"; exit 0 ;;
        *) echo -e "${RED}$MENU_INVALID_CHOICE${NC}" ;;
    esac
done
