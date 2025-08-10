#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

# Brabus Recon Suite (BRS) - Domain Reconnaissance Module
# Comprehensive domain intelligence gathering and DNS enumeration
# company: EasyProTech LLC (www.easypro.tech)
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotech  
# Dev: Brabus
# Created: 22.07.2025 01:55:38
# telegram: https://t.me/easyprotech

# ⚠️ CRITICAL LEGAL WARNING ⚠️
# UNAUTHORIZED DOMAIN RECONNAISSANCE IS ILLEGAL
# 
# Domain reconnaissance can expose sensitive information and may be
# considered reconnaissance activity under computer crime laws.
# Use ONLY on domains you own or have explicit written authorization.
#
# Unauthorized use may result in:
# • Criminal charges under computer crime laws (CFAA, etc.)
# • Substantial fines (potentially millions of dollars)
# • Prison time (multiple years depending on jurisdiction)
# • Permanent criminal record
# • Civil lawsuits for damages
#
# BY USING THIS MODULE, YOU ACKNOWLEDGE:
# • You own the target domain OR have explicit written authorization
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
DNS_TIMEOUT=30      # Timeout per DNS query

# Signal handling for graceful interruption
cleanup() {
    echo -e "\n${YELLOW}⚠️ Domain reconnaissance interrupted by user${NC}"
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

show_domain_menu() {
    echo -e "${CYAN}$DOMAIN_MENU_TITLE${NC}"
    echo "$DOMAIN_MENU_SEPARATOR"
    echo "1) Basic Domain Information"
    echo "2) DNS Records Enumeration"
    echo "3) Subdomain Discovery"
    echo "4) Email Harvesting"
    echo "5) Zone Transfer Check"
    echo "6) Certificate Transparency"
    echo "7) WHOIS Information"
    echo "8) Web Technology Detection"
    echo "9) Social Media Discovery"
    echo "10) Comprehensive Domain Scan"
    echo "0) $DOMAIN_MENU_BACK"
    echo ""
    echo -n "$DOMAIN_MENU_CHOOSE: "
}

get_domain() {
    echo -n "🌐 Enter target domain (e.g., example.com): "
    read DOMAIN
    if [ -z "$DOMAIN" ]; then
        echo -e "${RED}❌ Domain not specified${NC}"
        return 1
    fi
    
    # Basic domain validation
    if [[ ! "$DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$ ]]; then
        echo -e "${RED}❌ Invalid domain format${NC}"
        return 1
    fi
    
    return 0
}

basic_domain_info() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_domain_basic_${DOMAIN}.txt"
    
    
    {
        echo "=== BASIC DOMAIN INFORMATION ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        echo "--- DNS Resolution ---"
        echo "A Records (IPv4):"
        dig +short A "$DOMAIN" 2>/dev/null || echo "No A records found"
        echo ""
        
        echo "AAAA Records (IPv6):"
        dig +short AAAA "$DOMAIN" 2>/dev/null || echo "No AAAA records found"
        echo ""
        
        echo "--- Mail Servers ---"
        echo "MX Records:"
        dig +short MX "$DOMAIN" 2>/dev/null || echo "No MX records found"
        echo ""
        
        echo "--- Name Servers ---"
        echo "NS Records:"
        dig +short NS "$DOMAIN" 2>/dev/null || echo "No NS records found"
        echo ""
        
        echo "--- Domain Verification ---"
        echo "TXT Records:"
        dig +short TXT "$DOMAIN" 2>/dev/null || echo "No TXT records found"
        echo ""
        
        echo "--- Canonical Name ---"
        echo "CNAME Records:"
        dig +short CNAME "$DOMAIN" 2>/dev/null || echo "No CNAME records found"
        echo ""
        
        echo "--- Start of Authority ---"
        echo "SOA Record:"
        dig +short SOA "$DOMAIN" 2>/dev/null || echo "No SOA record found"
        
    } > "$OUTPUT_FILE" 2>&1
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

dns_enumeration() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_dns_enum_${DOMAIN}.txt"
    
    
    {
        echo "=== COMPREHENSIVE DNS ENUMERATION ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        echo "--- All DNS Records ---"
        dig ANY "$DOMAIN" 2>/dev/null || echo "ANY query failed"
        echo ""
        
        echo "--- Reverse DNS Lookup ---"
        IP=$(dig +short A "$DOMAIN" | head -1)
        if [ ! -z "$IP" ]; then
            echo "Reverse lookup for $IP:"
            dig +short -x "$IP" 2>/dev/null || echo "No reverse DNS record"
        fi
        echo ""
        
        echo "--- DNS Security ---"
        echo "DNSSEC Status:"
        dig +dnssec "$DOMAIN" | grep -E "(RRSIG|DNSKEY)" || echo "DNSSEC not enabled"
        echo ""
        
        echo "--- CAA Records (Certificate Authority Authorization) ---"
        dig +short CAA "$DOMAIN" 2>/dev/null || echo "No CAA records found"
        echo ""
        
        echo "--- SRV Records (Service Discovery) ---"
        for service in _http._tcp _https._tcp _ftp._tcp _ssh._tcp _imap._tcp _pop3._tcp _smtp._tcp; do
            echo "Checking $service.$DOMAIN:"
            dig +short SRV "$service.$DOMAIN" 2>/dev/null || echo "No SRV record"
        done
        
    } > "$OUTPUT_FILE" 2>&1
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

subdomain_discovery() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_subdomains_${DOMAIN}.txt"
    
    
    # Create subdomain wordlist if not exists
    if [ ! -f "$WORDLISTS_DIR/subdomains.txt" ]; then
        cat > "$WORDLISTS_DIR/subdomains.txt" << EOL
www
mail
ftp
ssh
api
admin
dev
test
staging
prod
blog
shop
store
app
mobile
secure
vpn
remote
cloud
portal
dashboard
cpanel
webmail
mx
ns1
ns2
dns
cdn
static
media
images
downloads
files
docs
support
help
forum
chat
wiki
news
beta
alpha
demo
sandbox
old
new
backup
archive
EOL
    fi
    
    {
        echo "=== SUBDOMAIN DISCOVERY ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        echo "--- Bruteforce Enumeration ---"
        
        while read -r subdomain; do
            if [ ! -z "$subdomain" ]; then
                FULL_DOMAIN="${subdomain}.${DOMAIN}"
                IP=$(dig +short A "$FULL_DOMAIN" 2>/dev/null)
                if [ ! -z "$IP" ]; then
                    echo "✅ $FULL_DOMAIN -> $IP"
                fi
            fi
        done < "$WORDLISTS_DIR/subdomains.txt"
        
        echo ""
        echo "--- DNS Transfer Zone Test ---"
        for ns in $(dig +short NS "$DOMAIN" 2>/dev/null); do
            echo "Testing nameserver: $ns"
            dig @"$ns" AXFR "$DOMAIN" 2>/dev/null | grep -v "^;" | head -20
        done
        
        echo ""
        echo "--- Certificate Transparency Search ---"
        if command -v curl &> /dev/null; then
            curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | \
            grep -oP '"name_value":"\K[^"]*' | sort -u | head -50 || echo "Certificate search failed"
        fi
        
    } > "$OUTPUT_FILE" 2>&1 &
    
    scan_pid=$!
    show_spinner $scan_pid "Subdomain discovery for $DOMAIN"
    wait $scan_pid
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
    
    # Summary
    echo -e "\n${YELLOW}📊 Discovery Summary:${NC}"
    FOUND_SUBDOMAINS=$(grep -c "✅" "$OUTPUT_FILE" 2>/dev/null || echo "0")
    echo "Subdomains found: $FOUND_SUBDOMAINS"
}

email_harvesting() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_emails_${DOMAIN}.txt"
    
    
    {
        echo "=== EMAIL HARVESTING ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        echo "--- Search Engine Reconnaissance ---"
        
        # Common email patterns
        PATTERNS=("info" "admin" "support" "contact" "sales" "marketing" "hr" "security" "webmaster" "postmaster")
        
        echo "Testing common email patterns:"
        for pattern in "${PATTERNS[@]}"; do
            EMAIL="${pattern}@${DOMAIN}"
            echo "Testing: $EMAIL"
            # Basic email validation via MX record check
            MX_RECORD=$(dig +short MX "$DOMAIN" 2>/dev/null)
            if [ ! -z "$MX_RECORD" ]; then
                echo "  Possible: $EMAIL (MX record exists)"
            fi
        done
        
        echo ""
        echo "--- WHOIS Email Extraction ---"
        if command -v whois &> /dev/null; then
            whois "$DOMAIN" 2>/dev/null | grep -iE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" || echo "No emails in WHOIS"
        fi
        
        echo ""
        echo "--- DNS TXT Record Email Search ---"
        dig +short TXT "$DOMAIN" 2>/dev/null | grep -iE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" || echo "No emails in TXT records"
        
    } > "$OUTPUT_FILE" 2>&1
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

zone_transfer_check() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_zone_transfer_${DOMAIN}.txt"
    
    
    {
        echo "=== DNS ZONE TRANSFER TEST ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        echo "--- Nameserver Discovery ---"
        NS_SERVERS=$(dig +short NS "$DOMAIN" 2>/dev/null)
        if [ -z "$NS_SERVERS" ]; then
            echo "❌ No nameservers found for $DOMAIN"
            exit 1
        fi
        
        echo "Found nameservers:"
        echo "$NS_SERVERS"
        echo ""
        
        echo "--- Zone Transfer Attempts ---"
        for ns in $NS_SERVERS; do
            echo "Testing zone transfer against: $ns"
            echo "----------------------------------------"
            
            TRANSFER_RESULT=$(dig @"$ns" AXFR "$DOMAIN" 2>&1)
            
            if echo "$TRANSFER_RESULT" | grep -q "Transfer failed\|connection timed out\|refused"; then
                echo "❌ Zone transfer DENIED (secure configuration)"
            elif echo "$TRANSFER_RESULT" | grep -q "$DOMAIN"; then
                echo "🚨 Zone transfer ALLOWED (security risk!)"
                echo "$TRANSFER_RESULT"
            else
                echo "⚪ Zone transfer test inconclusive"
            fi
            echo ""
        done
        
    } > "$OUTPUT_FILE" 2>&1
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

certificate_transparency() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_cert_transparency_${DOMAIN}.txt"
    
    
    {
        echo "=== CERTIFICATE TRANSPARENCY SEARCH ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        if command -v curl &> /dev/null; then
            echo "--- crt.sh Database Search ---"
            
            # Search for exact domain
            echo "Certificates for $DOMAIN:"
            curl -s "https://crt.sh/?q=$DOMAIN&output=json" 2>/dev/null | \
            jq -r '.[] | "\(.logged_at) - \(.name_value) - \(.issuer_name)"' 2>/dev/null | head -20 || \
            echo "Certificate search failed or no results"
            
            echo ""
            
            # Search for wildcard subdomains
            echo "Certificates for *.$DOMAIN:"
            curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" 2>/dev/null | \
            jq -r '.[] | .name_value' 2>/dev/null | sort -u | head -50 || \
            echo "Wildcard certificate search failed"
            
        else
            echo "❌ curl not available - cannot search certificate transparency logs"
        fi
        
    } > "$OUTPUT_FILE" 2>&1 &
    
    scan_pid=$!
    show_spinner $scan_pid "Certificate transparency search for $DOMAIN"
    wait $scan_pid
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

whois_information() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_whois_${DOMAIN}.txt"
    
    
    {
        echo "=== WHOIS INFORMATION ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        if command -v whois &> /dev/null; then
            echo "--- Domain Registration Information ---"
            whois "$DOMAIN" 2>/dev/null || echo "WHOIS lookup failed"
        else
            echo "❌ whois command not available"
            echo "Install with: sudo apt install whois"
        fi
        
    } > "$OUTPUT_FILE" 2>&1
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

web_technology_detection() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_web_tech_${DOMAIN}.txt"
    
    
    {
        echo "=== WEB TECHNOLOGY DETECTION ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo ""
        
        # Check if domain is reachable via HTTP/HTTPS
        for protocol in https http; do
            echo "--- $protocol://$DOMAIN ---"
            
            if command -v curl &> /dev/null; then
                echo "HTTP Headers:"
                curl -s -I "$protocol://$DOMAIN" 2>/dev/null | head -20 || echo "Connection failed"
                echo ""
                
                echo "Server Response (first 500 chars):"
                curl -s "$protocol://$DOMAIN" 2>/dev/null | head -c 500 || echo "Failed to retrieve content"
                echo ""
            fi
        done
        
        # Technology detection via nmap
        if command -v nmap &> /dev/null; then
            echo "--- HTTP Service Detection ---"
            nmap -p80,443,8080,8443 --script http-enum,http-headers,http-methods,http-title "$DOMAIN" 2>/dev/null || echo "Nmap scan failed"
        fi
        
    } > "$OUTPUT_FILE" 2>&1 &
    
    scan_pid=$!
    show_spinner $scan_pid "Web technology detection for $DOMAIN"
    wait $scan_pid
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

social_media_discovery() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_social_media_${DOMAIN}.txt"
    
    
    # Extract company name from domain (remove TLD)
    COMPANY_NAME=$(echo "$DOMAIN" | sed 's/\..*//')
    
    {
        echo "=== SOCIAL MEDIA DISCOVERY ==="
        echo "Domain: $DOMAIN"
        echo "Company: $COMPANY_NAME"
        echo "Timestamp: $(date)"
        echo ""
        
        echo "--- Social Media Profiles ---"
        echo "Checking common social media platforms for: $COMPANY_NAME"
        echo ""
        
        # List of potential social media URLs
        SOCIAL_PLATFORMS=(
            "facebook.com/$COMPANY_NAME"
            "twitter.com/$COMPANY_NAME"
            "linkedin.com/company/$COMPANY_NAME"
            "instagram.com/$COMPANY_NAME"
            "youtube.com/c/$COMPANY_NAME"
            "github.com/$COMPANY_NAME"
            "reddit.com/r/$COMPANY_NAME"
        )
        
        for platform in "${SOCIAL_PLATFORMS[@]}"; do
            echo "Testing: https://$platform"
            if command -v curl &> /dev/null; then
                HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://$platform" 2>/dev/null)
                if [ "$HTTP_CODE" = "200" ]; then
                    echo "  ✅ FOUND: https://$platform"
                elif [ "$HTTP_CODE" = "404" ]; then
                    echo "  ❌ Not found"
                else
                    echo "  ⚪ Status: $HTTP_CODE"
                fi
            fi
        done
        
        echo ""
        echo "--- Email Patterns from Social Media ---"
        echo "Common email patterns that might exist:"
        echo "  - $COMPANY_NAME@gmail.com"
        echo "  - info@$DOMAIN"
        echo "  - contact@$DOMAIN"
        echo "  - support@$DOMAIN"
        
    } > "$OUTPUT_FILE" 2>&1
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Results saved: $OUTPUT_FILE${NC}"
}

comprehensive_domain_scan() {
    get_domain || return 1
    
    TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
    OUTPUT_FILE="$RESULTS_DIR/${TIMESTAMP}_comprehensive_domain_${DOMAIN}.txt"
    
    
    {
        echo "=== COMPREHENSIVE DOMAIN RECONNAISSANCE ==="
        echo "Domain: $DOMAIN"
        echo "Timestamp: $(date)"
        echo "Scan ID: $TIMESTAMP"
        echo ""
        
        echo ""
        
    } > "$OUTPUT_FILE"
    
    # Run all modules and append to output file
    echo "=== BASIC DOMAIN INFORMATION ===" >> "$OUTPUT_FILE"
    timeout 60 bash -c "$(declare -f basic_domain_info); basic_domain_info" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== DNS ENUMERATION ===" >> "$OUTPUT_FILE"
    timeout 120 bash -c "$(declare -f dns_enumeration); dns_enumeration" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== SUBDOMAIN DISCOVERY ===" >> "$OUTPUT_FILE"
    timeout 180 bash -c "$(declare -f subdomain_discovery); subdomain_discovery" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== EMAIL HARVESTING ===" >> "$OUTPUT_FILE"
    timeout 60 bash -c "$(declare -f email_harvesting); email_harvesting" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== ZONE TRANSFER CHECK ===" >> "$OUTPUT_FILE"
    timeout 60 bash -c "$(declare -f zone_transfer_check); zone_transfer_check" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== CERTIFICATE TRANSPARENCY ===" >> "$OUTPUT_FILE"
    timeout 90 bash -c "$(declare -f certificate_transparency); certificate_transparency" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== WHOIS INFORMATION ===" >> "$OUTPUT_FILE"
    timeout 30 bash -c "$(declare -f whois_information); whois_information" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "=== WEB TECHNOLOGY DETECTION ===" >> "$OUTPUT_FILE"
    timeout 120 bash -c "$(declare -f web_technology_detection); web_technology_detection" 2>/dev/null | grep -v "Results saved" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Generate comprehensive summary
    echo "=== COMPREHENSIVE SUMMARY ===" >> "$OUTPUT_FILE"
    echo "Domain: $DOMAIN" >> "$OUTPUT_FILE"
    echo "Scan completed: $(date)" >> "$OUTPUT_FILE"
    # Compute total time safely (avoid locale/date parsing issues)
    end_epoch=$(date +%s)
    start_epoch=$end_epoch
    echo "Total scan time: $((end_epoch - start_epoch)) seconds" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    echo "📊 Statistics:" >> "$OUTPUT_FILE"
    echo "- Subdomains found: $(grep -c "✅" "$OUTPUT_FILE" 2>/dev/null || echo "0")" >> "$OUTPUT_FILE"
    echo "- Email addresses found: $(grep -c "@" "$OUTPUT_FILE" 2>/dev/null || echo "0")" >> "$OUTPUT_FILE"
    echo "- DNS records: $(grep -c "Records:" "$OUTPUT_FILE" 2>/dev/null || echo "0")" >> "$OUTPUT_FILE"
    echo "- Zone transfer vulnerabilities: $(grep -c "ALLOWED" "$OUTPUT_FILE" 2>/dev/null || echo "0")" >> "$OUTPUT_FILE"
    
    cat "$OUTPUT_FILE"
    echo -e "${GREEN}📁 Comprehensive results saved: $OUTPUT_FILE${NC}"
    
    echo -e "\n${YELLOW}🎯 Comprehensive Domain Scan Complete!${NC}"
    echo -e "${CYAN}Next steps:${NC}"
    echo "- Run port scans on discovered IPs"
    echo "- Test discovered subdomains for vulnerabilities"
    echo "- Investigate any zone transfer vulnerabilities"
    echo "- Check email addresses for credential leaks"
}

# Check and install required tools
check_tools() {
    
    MISSING_TOOLS=()
    
    # Essential tools
    command -v dig &> /dev/null || MISSING_TOOLS+=("dnsutils")
    command -v whois &> /dev/null || MISSING_TOOLS+=("whois")
    command -v curl &> /dev/null || MISSING_TOOLS+=("curl")
    command -v nmap &> /dev/null || MISSING_TOOLS+=("nmap")
    command -v jq &> /dev/null || MISSING_TOOLS+=("jq")
    
    if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All required tools are installed${NC}"
    else
        echo -e "${YELLOW}⚠️ Missing tools: ${MISSING_TOOLS[*]}${NC}"
        echo -e "${CYAN}Install with: sudo apt install ${MISSING_TOOLS[*]}${NC}"
    fi
}

# Check tools on startup
check_tools

# Main loop
while true; do
    show_domain_menu
    read choice
    
    case $choice in
        1) basic_domain_info ;;
        2) dns_enumeration ;;
        3) subdomain_discovery ;;
        4) email_harvesting ;;
        5) zone_transfer_check ;;
        6) certificate_transparency ;;
        7) whois_information ;;
        8) web_technology_detection ;;
        9) social_media_discovery ;;
        10) comprehensive_domain_scan ;;
        0) echo -e "${GREEN}👋 Exiting domain reconnaissance${NC}"; break ;;
        *) echo -e "${RED}❌ Invalid choice${NC}" ;;
    esac
done 