# 📖 BRABUS RECON SUITE (BRS) - USAGE GUIDE
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:09:08 MSK
# This file was modified
# Telegram: https://t.me/easyprotech

---

## 🚨 CRITICAL LEGAL WARNING - READ FIRST

**⚠️ UNAUTHORIZED USE IS ILLEGAL AND MAY RESULT IN CRIMINAL PROSECUTION ⚠️**

**THIS IS A PENETRATION TESTING TOOLKIT FOR AUTHORIZED SECURITY TESTING ONLY**

By proceeding to use this software, you acknowledge and agree that you have read, understood, and will comply with all legal terms outlined in:
- **LEGAL.md** - Complete legal terms and conditions
- **ETHICS.md** - Ethical usage guidelines
- **DISCLAIMER.md** - Liability disclaimers

### Legal Consequences of Misuse:
- **Criminal charges** under computer crime laws (CFAA, etc.)
- **Substantial fines** (potentially millions of dollars)
- **Prison time** (multiple years depending on jurisdiction)
- **Permanent criminal record** affecting employment and travel
- **Civil lawsuits** for damages and business disruption

### Authorized Use ONLY:
- Your own networks and systems
- With explicit written authorization from system owners
- Within scope of authorized penetration testing contracts
- As part of legitimate bug bounty programs
- In controlled educational environments

**IF YOU CANNOT MAKE THESE DECLARATIONS, DO NOT USE THIS SOFTWARE.**

---

## 🚀 Quick Start

### Prerequisites
Before using BRS, ensure you have:
1. **Legal authorization** to test the target systems
2. **Root privileges** on your testing machine
3. **Written permission** from system owners (if not your own)
4. **Understanding of applicable laws** in your jurisdiction

### Initial Setup
```bash
# Clone the repository
git clone https://github.com/EasyProTech/brs.git
cd brs

# Make scripts executable
chmod +x main.sh
chmod +x scripts/*.sh

# Run BRS
./main.sh
```

### First Run Agreement
On first execution, BRS will require you to accept the ethics agreement by:
1. Reading the legal warnings
2. Making required declarations under penalty of perjury
3. Typing "I AGREE" to proceed or "EXIT" to quit

This agreement is **legally binding** and will be recorded with your system information.

---

## 🎯 Core Modules

### 1. 🌐 Network Discovery
**Purpose**: Discover live hosts in target networks
**Legal Warning**: Network scanning may constitute unauthorized reconnaissance

**Features**:
- Automatic network interface detection
- Ping sweep scanning with nmap
- ARP scanning for hidden devices
- Quick port scanning of discovered hosts
- Parallel scanning with safety limits

**Usage Example**:
```bash
./main.sh → 1) Network Discovery
# Select network from detected interfaces
# Or enter custom CIDR range (e.g., 192.168.1.0/24)
```

**Authorization Required**: Written permission to scan the target network

### 2. 🔍 Port Scanner
**Purpose**: Detailed port scanning and service detection
**Legal Warning**: Port scanning can be considered illegal reconnaissance

**Scanning Modes**:
- **Fast scan**: Top 1000 ports (quick reconnaissance)
- **Full scan**: All 65535 ports (comprehensive but slow)
- **Stealth scan**: SYN scanning to avoid detection
- **UDP scan**: UDP services detection
- **Version scan**: Service version identification
- **Aggressive scan**: OS detection + scripts + traceroute
- **Tor scan**: Anonymous scanning through Tor
- **Mass scan**: High-speed scanning with masscan

**Usage Example**:
```bash
./main.sh → 2) Port Scanner → 1) Fast scan
# Enter target IP or range
# Example: 192.168.1.100 or 192.168.1.1-100
```

**Authorization Required**: Explicit permission to scan target hosts

### 3. 🛡️ Vulnerability Scanner
**Purpose**: Security vulnerability assessment
**Legal Warning**: Vulnerability scanning may expose sensitive security information

**Assessment Types**:
- **NSE scripts**: Nmap vulnerability scripts
- **Nikto**: Web application vulnerabilities
- **SQLmap**: SQL injection testing
- **SMB vulnerabilities**: Including EternalBlue, MS08-067
- **Weak passwords**: SSH, FTP, Telnet brute force testing
- **Open shares**: SMB/NFS share enumeration
- **SSL/TLS**: Certificate and encryption vulnerabilities

**Usage Example**:
```bash
./main.sh → 3) Vulnerability Scanner → 1) NSE scripts
# Enter target IP address
# Example: 192.168.1.100
```

**Authorization Required**: Written authorization for vulnerability assessment

### 4. 🖥️ System Information
**Purpose**: Comprehensive system reconnaissance
**Legal Warning**: Information gathering may constitute unauthorized access

**Information Collected**:
- System details (OS, kernel, architecture)
- Hardware information (CPU, memory, storage)
- Network configuration (interfaces, routing)
- Security status (firewall, SSH, services)
- Running processes and services
- Connected devices (USB, PCI, Bluetooth)

**Usage Example**:
```bash
./main.sh → 4) System Information → 1) Full system report
```

**Authorization Required**: Permission to gather system information

### 5. ⚔️ Attack Tools
**Purpose**: Active penetration testing
**Legal Warning**: THESE ARE ACTIVE ATTACK TOOLS - EXTREMELY DANGEROUS IF MISUSED

**Attack Categories**:

#### Brute Force Attacks:
- **SSH brute force**: Dictionary attacks against SSH
- **FTP brute force**: Password attacks against FTP
- **HTTP brute force**: Basic authentication attacks
- **Telnet brute force**: Telnet service attacks
- **RDP brute force**: Remote Desktop attacks

#### Network Attacks:
- **DoS attacks**: TCP SYN flood attacks
- **ARP spoofing**: Man-in-the-middle positioning
- **MITM attacks**: Traffic interception via ettercap

#### WiFi Attacks:
- **Handshake capture**: WPA/WPA2 handshake collection
- **Deauth attacks**: Wireless deauthentication

#### Other Tools:
- **Directory enumeration**: Web directory/file discovery
- **Wordlist generation**: Custom password dictionaries
- **Malicious file generation**: Payload creation

**Usage Example**:
```bash
./main.sh → 5) Attack Tools → 1) SSH brute force
# WARNING PROMPTS WILL APPEAR
# Enter target IP address
# Select attack mode
```

**Authorization Required**: EXPLICIT WRITTEN AUTHORIZATION FOR ACTIVE ATTACKS

---

## 📊 Results Management

### Viewing Results
```bash
./main.sh → 6) Results → 1) View Results
```

### Result Files
All results are timestamped and saved in `results/`:
- `YYYYMMDD-HHMMSS_live_hosts.txt` - Discovered hosts
- `YYYYMMDD-HHMMSS_network_scan.txt` - Network scan results
- `YYYYMMDD-HHMMSS_port_scan_TARGET.txt` - Port scan results
- `YYYYMMDD-HHMMSS_vuln_scan_TARGET.txt` - Vulnerability scan results
- `YYYYMMDD-HHMMSS_attack_TARGET.txt` - Attack results

### Cleanup
```bash
./main.sh → 6) Results → 2) Cleanup Results
```

---

## 🔧 Configuration

### Language Settings
```bash
./main.sh → 8) Settings → 1) Language
```
Current mode: English-only (v2.0 stabilization).

### Tool Dependencies
```bash
./main.sh → 8) Settings → 2) Check Tools
```
Automatically checks and can install missing tools

### Required Tools
- **nmap** - Network mapping and port scanning
- **masscan** - High-speed port scanning
- **hydra** - Network authentication cracking
- **nikto** - Web vulnerability scanning
- **sqlmap** - SQL injection testing
- **john** - Password cracking
- **aircrack-ng** - WiFi security auditing
- **arp-scan** - ARP network scanning

---

## ⚠️ Safety Guidelines

### Before Testing:
1. **Verify ownership** or obtain written authorization
2. **Review scope** and limitations with system owners
3. **Plan incident response** for unexpected issues
4. **Backup critical data** before aggressive testing
5. **Notify stakeholders** of testing schedules

### During Testing:
1. **Stay within scope** - never exceed authorized boundaries
2. **Monitor impact** - ensure no business disruption
3. **Document activities** - keep detailed logs
4. **Stop immediately** if authorization is revoked
5. **Report critical findings** promptly

### After Testing:
1. **Secure data** - protect any collected information
2. **Report results** through proper channels
3. **Recommend remediation** for discovered vulnerabilities
4. **Follow up** on implemented fixes
5. **Dispose of data** according to agreements

---

## 🚨 Emergency Procedures

### If Something Goes Wrong:
1. **Stop all attacks immediately** (Ctrl+C)
2. **Document the incident** with timestamps
3. **Notify system owners** immediately
4. **Preserve logs** for investigation
5. **Implement containment** measures if needed

### If You Discover Critical Vulnerabilities:
1. **Stop testing** that specific vulnerability
2. **Document findings** securely
3. **Notify system owners** privately
4. **Provide remediation guidance**
5. **Retest after fixes** are implemented

---

## 📞 Support and Reporting

### Technical Issues:
This is open-source software provided as-is. The authors do not provide technical support.

### Legal Questions:
Consult with qualified legal counsel familiar with cybersecurity law in your jurisdiction.

### Misuse Reporting:
If you become aware of misuse of this software, report it to:
- Local law enforcement agencies
- Relevant cybersecurity authorities (CISA, NCSC, etc.)
- Software maintainers (where appropriate)

---

## ⚖️ Legal Compliance Checklist

Before using BRS, ensure you have:

- [ ] **Written authorization** from system owners
- [ ] **Defined scope** and limitations
- [ ] **Legal review** of your intended activities
- [ ] **Incident response plan** in place
- [ ] **Data handling procedures** established
- [ ] **Compliance verification** with local laws
- [ ] **Stakeholder notification** completed
- [ ] **Ethics agreement** accepted in BRS

**Remember: When in doubt, don't. The legal and reputational risks of unauthorized use far outweigh any potential benefits.**

---

*This document should be reviewed regularly and updated as laws and best practices evolve. Always consult with legal professionals when planning security testing activities.*

**EasyProTech LLC | Brabus Recon Suite v1.0** 