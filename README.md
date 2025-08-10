```
██████  ██████  ███████ 
██   ██ ██   ██ ██      
██████  ██████  ███████ 
██   ██ ██   ██      ██ 
██████  ██   ██ ███████ 
```

<sub>project: brabus recon suite (brs) | company: easyprotech llc (www.easypro.tech) | developer: brabus | created: 22.07.2025 03:06:28 | version: 2.1 | telegram: https://t.me/easyprotech</sub>

### License

![License](https://img.shields.io/badge/License-GPLv3%2FCommercial-blue.svg)

![GitHub stars](https://img.shields.io/github/stars/EPTLLC/brs?style=social) ![GitHub forks](https://img.shields.io/github/forks/EPTLLC/brs?style=social) ![GitHub watchers](https://img.shields.io/github/watchers/EPTLLC/brs?style=social)

![Platform](https://img.shields.io/badge/Platform-Linux-green.svg) ![Language](https://img.shields.io/badge/Language-Bash-orange.svg) ![Status](https://img.shields.io/badge/Status-Active-brightgreen.svg)

 Network Reconnaissance & Penetration Testing Toolkit

# Brabus Recon Suite (BRS) v2.1

**Professional Network Reconnaissance & Penetration Testing Toolkit**

**Company:** EasyProTech LLC (www.easypro.tech)  
**Developer:** Brabus  
**Created:** Mon 22 Jul 2025 03:06:28 MSK  
**Version:** 2.1  
**Updated:** Sun 11 Aug 2025 01:20:17 MSK  
**Telegram:** https://t.me/easyprotech

## Overview

Advanced suite of tools for network reconnaissance, domain analysis, vulnerability assessment and penetration testing with enhanced user experience and professional-grade interface.

> **Related Module:** [BRS-XSS](https://github.com/EPTLLC/brs-xss) — Next-Generation XSS Detection Suite. Standalone Python CLI for context-aware XSS scanning (HTML/JS context analysis, WAF detection/bypass heuristics, DOM analysis via Playwright, ML-ready scoring) with HTML/JSON/SARIF reports and easy integration into BRS results workflow.

## 🚀 What's New in v2.1

## 🚀 What's New in v2.1

- Quick Start: Full Scan (auto) at launch
  - Enter → full local scan (System Info → Port Scan Aggressive → Vulnerability Comprehensive)
  - IP/Domain → full remote scan (+ Domain Recon for domains)
- Centralized tool checks; removed inline installs from modules
- i18n loading unified (`CURRENT_LANGUAGE="en"`); localized menu labels
- Network Discovery: non-interactive `LOCAL_NET` support; stability fixes
- Domain Recon: robust total-time calculation in comprehensive mode

## What's New in v2.0

### Major Enhancements
- Domain Reconnaissance Module - Comprehensive domain analysis capabilities
- Professional Interface - Clean, emoji-free menus for serious professionals
- Advanced Progress Indicators - Live timers and cancellation support
- Enhanced System Information - Detailed hardware, network, and security reporting
- Improved Error Handling - Robust interrupt handling and cleanup procedures
- Streamlined Architecture - Optimized code structure and performance

### Core Improvements
- Unified Spinner System - Consistent progress indication across all modules
- Professional Menu Design - Removed emojis from menu items for business use
- Better Resource Management - Enhanced cleanup and signal handling
- Optimized Performance - Reduced redundancy and improved speed
- Enhanced Documentation - Complete feature coverage and usage examples

### Development Notes
- Language Support: English-only during v2.0 stabilization (`CURRENT_LANGUAGE="en"`)
- Legacy Compatibility: V1.0 language packs are excluded for now
- Future Roadmap: Multi-language support will be restored in future releases

## ⚠️ CRITICAL LEGAL WARNING

**⚠️ UNAUTHORIZED USE IS ILLEGAL AND MAY RESULT IN CRIMINAL PROSECUTION ⚠️**

**THIS IS A PENETRATION TESTING TOOLKIT FOR AUTHORIZED SECURITY TESTING ONLY**

Using this software to scan, probe, or attack networks, systems, or services that you do not own or have explicit written permission to test is **ILLEGAL** and may result in:

- **Criminal charges** and prosecution under computer crime laws
- **Substantial fines** (potentially millions of dollars)
- **Prison time** (multiple years depending on severity)
- **Permanent criminal record**
- **Civil lawsuits** for damages and legal costs

**AUTHORIZED USE ONLY:**
- Your own networks and systems
- With explicit written authorization from system owners
- Within scope of authorized penetration testing contracts
- As part of legitimate bug bounty programs
- In controlled educational environments

## Installation

```bash
git clone https://github.com/EasyProTech/brs.git && cd brs && ./main.sh
```

## Quick Start

```bash
# Clone or extract the project to any directory
cd brs
./main.sh
```

All paths are automatically resolved relative to the project location.

## Core Modules

### 1. Network Discovery
**Comprehensive local network reconnaissance**

Features:
- Automatic network interface detection
- Intelligent network range identification
- Multi-method host discovery (ping sweep, ARP scan)
- Fast port scanning of discovered hosts
- MAC address vendor identification
- Detailed network topology mapping
- Professional progress indicators with live timers

Improvements in v2.0:
- Enhanced host detection algorithms
- Better network interface handling
- Improved scan performance
- Professional progress visualization

### 2. Port Scanning
**Advanced port scanning capabilities**

Scanning Modes:
- Fast Scan - Top 1000 ports for quick reconnaissance
- Full Scan - Complete 65535 port range analysis
- Stealth SYN Scan - Covert reconnaissance techniques
- UDP Scanning - UDP service discovery
- Service Version Detection - Application fingerprinting
- Aggressive Scanning - OS detection and script scanning
- Tor Scanning - Anonymous scanning through Tor network
- Mass Scanning - High-speed scanning with masscan
- Batch Operations - Scan all discovered hosts automatically

v2.0 Enhancements:
- Unified progress indication system
- Better timeout handling
- Enhanced result formatting
- Professional interface design

### 3. Domain Reconnaissance
**Comprehensive domain intelligence gathering**

Core Capabilities:
- Basic Domain Information - DNS records and infrastructure analysis
- DNS Records Enumeration - Complete DNS record discovery (A, AAAA, MX, NS, TXT, etc.)
- Subdomain Discovery - Advanced subdomain enumeration techniques
- Email Harvesting - Email address discovery from various sources
- Zone Transfer Testing - DNS zone transfer vulnerability assessment
- Certificate Transparency - SSL certificate log analysis
- WHOIS Information - Domain registration and ownership data
- Web Technology Detection - Technology stack identification
- Social Media Discovery - Social media presence analysis
- Comprehensive Domain Scan - All-in-one domain assessment

Technical Features:
- Certificate transparency log integration
- Advanced subdomain discovery algorithms
- Email pattern recognition
- Technology fingerprinting
- Professional progress indicators

### 4. Vulnerability Assessment
**Professional security vulnerability detection**

Assessment Types:
- NSE Nmap Scripts - Advanced vulnerability detection scripts
- Web Vulnerability Scanning - Nikto-based web application testing
- SQL Injection Testing - SQLmap integration for database security
- SMB Vulnerability Scanning - Windows network service testing
- SSH Security Testing - SSH configuration and credential testing
- FTP Security Assessment - FTP service vulnerability analysis
- Telnet Security Testing - Legacy protocol security assessment
- Network Shares Discovery - SMB/NFS share enumeration
- SSL/TLS Analysis - Cryptographic protocol assessment
- Comprehensive Scanning - Automated multi-vector testing
- Automated Host Assessment - Batch vulnerability testing

v2.0 Improvements:
- Enhanced vulnerability detection algorithms
- Better result categorization
- Professional progress tracking
- Improved error handling

### 5. System Information
**Comprehensive system reconnaissance and analysis**

Information Categories:
- Full System Report - Complete system analysis with executive summary
- System Information - OS, kernel, architecture, hostname, uptime details
- Hardware Information - CPU, memory, storage analysis
- Network Configuration - Interface details, routing tables, active connections
- Security Status - Firewall status, user activity, authentication logs
- Running Services - Service status analysis and monitoring
- Connected Devices - USB, PCI, WiFi, Bluetooth device enumeration

v2.0 Features:
- Professional progress indicators for long operations
- Enhanced data collection algorithms
- Better categorization and formatting
- Timestamped result files
- Executive summary generation

### 6. Attack Tools
**Professional penetration testing capabilities**

**⚠️ AUTHORIZED TESTING ONLY!**

Attack Categories:
- Credential Attacks - SSH, FTP, HTTP, Telnet, RDP brute force
- Network Attacks - DoS attacks, ARP spoofing, MITM operations
- Web Application Attacks - Directory brute forcing, web-based attacks
- Wireless Attacks - WiFi security assessment and handshake capture
- Custom Wordlists - Flexible credential dictionary support

v2.0 Enhancements:
- Professional progress tracking
- Better attack success reporting
- Enhanced logging and documentation
- Improved safety measures

## Technical Requirements

### System Dependencies
- **nmap** - Network mapping and port scanning
- **masscan** - High-speed port scanning
- **hydra** - Network authentication cracking
- **nikto** - Web server vulnerability scanner
- **sqlmap** - SQL injection testing tool
- **dig** - DNS lookup utility
- **whois** - Domain registration lookup
- **curl** - HTTP/HTTPS client for web requests
- **jq** - JSON processing for API responses
- **john** - Password cracking utilities
- **ettercap** - Network security toolkit
- **aircrack-ng** - WiFi security auditing

### System Requirements
- Ubuntu 22.04+ or compatible Linux distribution
- Sudo privileges for advanced scanning techniques
- Minimum 4GB RAM for optimal performance
- 5GB free disk space for results and wordlists
- Network interfaces for wireless testing (optional)

## Results Management

All scan results are automatically saved with timestamps:

```
results/
├── 20250722-030628_network_scan.txt
├── 20250722-030645_domain_recon_example.com.txt
├── 20250722-030702_vuln_scan_192.168.1.100.txt
├── 20250722-030715_system_info.txt
└── 20250722-030730_port_scan_192.168.1.0-24.txt
```

File Naming Convention:
- `YYYYMMDD-HHMMSS_operation_target.txt`
- Automatic result categorization
- Timestamped for audit trails
- Professional formatting for reporting

## Configuration Management

### Language Configuration (V2.0 Development)
The system currently operates in **English-only mode** (config `CURRENT_LANGUAGE="en"`). Multi-language packs from v1.0 are excluded during v2.0 stabilization and may return later.

### Professional Interface Settings
- Consistent progress indication
- Professional color schemes
- Business-appropriate formatting
  
Note: During v2.0 development the console UI may include minimal emoji icons in status messages; the final business preset can disable them.

## Usage Examples

### Complete Network Assessment
```bash
./main.sh
# 1) Network Discovery -> Discover all network hosts
# 2) Port Scanning -> 9) Scan all discovered hosts
# 4) Vulnerability Search -> 11) Auto-scan all hosts
# 7) Results -> Review comprehensive findings
```

### Domain Intelligence Gathering
```bash
./main.sh
# 3) Domain Reconnaissance
# 10) Comprehensive Domain Scan
# Enter target domain: example.com
```

### System Analysis
```bash
./main.sh
# 5) System Information
# 1) Full System Report -> Complete system analysis
```

### Professional Vulnerability Assessment
```bash
./main.sh
# 4) Vulnerability Search
# 10) Comprehensive vulnerability scanning
# Review results in timestamped files
```

## Professional Workflow

### 1. Reconnaissance Phase
```bash
# Network discovery and mapping
./main.sh → 1) Network Discovery
# Domain intelligence gathering
./main.sh → 3) Domain Reconnaissance
```

### 2. Scanning Phase
```bash
# Comprehensive port analysis
./main.sh → 2) Port Scanning → 9) Scan all hosts
# System information gathering
./main.sh → 5) System Information → 1) Full Report
```

### 3. Assessment Phase
```bash
# Vulnerability identification
./main.sh → 4) Vulnerability Search → 10) Comprehensive
# Security configuration analysis
```

### 4. Testing Phase (Authorized Only)
```bash
# Controlled penetration testing
./main.sh → 6) Attack Tools → Select appropriate tests
```

### 5. Reporting Phase
```bash
# Results compilation and analysis
./main.sh → 7) Results → Review all findings
```

## Advanced Features

### Progress Indication System
- Live Timers - Real-time operation duration tracking
- Cancellation Support - Ctrl+C handling with proper cleanup
- Professional Animation - Unicode spinner indicators
- Operation Status - Clear completion messaging

### Professional Interface Design
- Clean Menus - Emoji-free, business-appropriate design
- Consistent Formatting - Standardized output across modules
- Color Coding - Professional color schemes for different message types
- Structured Output - Organized, readable result presentation

### Enhanced Error Handling
- Graceful Interruption - Proper signal handling
- Resource Cleanup - Automatic temporary file management
- Error Recovery - Robust handling of unexpected conditions
- Logging Integration - Comprehensive error documentation

## Troubleshooting

### Common Issues and Solutions

Permission Issues:
```bash
chmod +x main.sh scripts/*.sh
```

Missing Dependencies:
```bash
./main.sh → 8) Settings → 2) Check Tools
```

Network Access Issues:
- Verify network connectivity
- Check firewall settings
- Ensure proper interface configuration

Performance Issues:
- Increase system resources
- Reduce scanning parallelism
- Use targeted scanning instead of broad sweeps

## Documentation References

- [Nmap Documentation](https://nmap.org/docs.html)
- [Domain Reconnaissance Techniques](https://www.owasp.org/index.php/Information_Gathering)
- [Vulnerability Assessment Methodologies](https://www.sans.org/reading-room/whitepapers/testing/)
- [Professional Penetration Testing Standards](https://www.pentest-standard.org/)

## Version History

### v2.1 (Current)
- Quick Start Full Scan
- Centralized tooling & i18n fixes
- Stability improvements in discovery and recon

### v2.0
- Domain Reconnaissance Module - Complete domain analysis capabilities
- Professional Interface - Business-appropriate menu design
- Enhanced Progress System - Live timers and cancellation support
- Improved System Analysis - Comprehensive system information gathering
- Streamlined Development - English-only mode for development phase

### v1.0 (Legacy)
- Basic network reconnaissance
- Multi-language support (7 languages)
- Core vulnerability scanning
- Basic attack tools
- Foundation architecture

## Legal Disclaimer

**🚨 CRITICAL: READ CAREFULLY BEFORE USE**

**BY USING THIS SOFTWARE, YOU AGREE TO BE LEGALLY BOUND BY ALL TERMS.**

AUTHORIZED USE REQUIREMENTS:
- Explicit written authorization for target systems
- Professional penetration testing contracts
- Authorized security research activities
- Educational use in controlled environments
- Bug bounty programs within scope

STRICTLY PROHIBITED:
- Unauthorized network scanning or testing
- Attacks on systems without permission
- Malicious or illegal activities
- Violation of applicable laws and regulations

LEGAL CONSEQUENCES:
Unauthorized use may result in prosecution under computer crime laws worldwide, including substantial fines and imprisonment.

COMPLETE LIABILITY DISCLAIMER:
EasyProTech LLC provides this software "AS IS" with NO WARRANTY and accepts NO RESPONSIBILITY for misuse, damage, or legal consequences.

**YOU BEAR FULL RESPONSIBILITY FOR YOUR ACTIONS.**

## Support Policy

**No Support Provided**: This project is released as-is without support, consultation, or assistance.

**Community Contributions**: Development contributions are welcome but not obligated.

## License

DUAL LICENSE STRUCTURE

### GPLv3 License (Open Source)
- Educational, research, and open-source projects
- Copyleft compliance required

### Commercial License
- Commercial entities and proprietary projects
- Contact: @easyprotech (Telegram)

See LICENSE file for complete terms.

---

**Brabus Recon Suite v2.1** | **EasyProTech LLC** | **Lead Developer: brabus** | **@easyprotech**

*Professional Network Reconnaissance for Authorized Security Testing* 