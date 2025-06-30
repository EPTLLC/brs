#!/bin/bash

# Brabus Recon Suite (BRS) - Main Control Script
# Network reconnaissance and penetration testing toolkit
# Company: EasyProTech LLC (www.easypro.tech)
# Author: brabus
# Version: 1.0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

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
    echo "║               EasyProTech LLC | brabus v1.0                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${CYAN}🌍 LANGUAGE SELECTION / ВЫБОР ЯЗЫКА${NC}"
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
    echo -n "Select language / Выберите язык: "
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
    echo "║               EasyProTech LLC | brabus v1.0                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_main_menu() {
    echo -e "${CYAN}$MENU_TITLE${NC}"
    echo "$MENU_SEPARATOR"
    echo "1) $MENU_NETWORK_DISCOVERY"
    echo "2) $MENU_PORT_SCANNER"
    echo "3) $MENU_VULNERABILITY_SCANNER"
    echo "4) $MENU_SYSINFO"
    echo "5) $MENU_ATTACK_TOOLS"
    echo "6) 📊 Results"
    echo "7) $MENU_SETTINGS"
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
                read
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
                read
                ;;
            2) 
                check_all_tools
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                read
                ;;
            3) 
                show_help
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                read
                ;;
            0) return ;;
            *) 
                echo -e "${RED}$MENU_INVALID_CHOICE${NC}"
                echo -e "${BLUE}$MENU_PRESS_ENTER${NC}"
                read
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
        read
        return
    fi
    
    echo -e "${CYAN}Latest results:${NC}"
    ls -lt "$RESULTS_DIR" | head -11
    echo -e "\n${BLUE}$MENU_PRESS_ENTER${NC}"
    read
}

cleanup_results() {
    echo -e "${YELLOW}🧹 $MENU_CLEANUP? (y/N): ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$RESULTS_DIR"/*
        echo -e "${GREEN}✅ Cleanup completed successfully${NC}"
    fi
    echo -e "\n${BLUE}$MENU_PRESS_ENTER${NC}"
    read
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
    echo "Tool requirements check available in option 10"
}

# Create necessary directories
mkdir -p "$SCRIPTS_DIR" "$RESULTS_DIR" "$CONFIG_DIR"

# Set execute permissions for scripts
chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null
chmod +x "$BASE_DIR/tools.sh" 2>/dev/null

# Quick tool check on startup (without user interaction)
quick_tool_check

# Main program loop
show_banner

while true; do
    show_main_menu
    read choice
    
    case $choice in
        1) run_network_discovery ;;
        2) run_port_scanner ;;
        3) run_vulnerability_scanner ;;
        4) run_system_info ;;
        5) run_attack_tools ;;
        6) show_results_menu ;;
        7) show_settings_menu ;;
        0) 
            echo -e "${GREEN}👋 $COMMON_DONE!${NC}"
            exit 0 
            ;;
        *) echo -e "${RED}$MENU_INVALID_CHOICE${NC}" ;;
    esac
    
    echo -e "\n${BLUE}$MENU_PRESS_ENTER${NC}"
    read
done
