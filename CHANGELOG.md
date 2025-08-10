# project: brabus recon suite (brs)  
# company: easyprotech llc (www.easypro.tech)  
# developer: brabus  
# created: 22.07.2025 03:10:45  
# repository: https://github.com/EPTLLC/brs
# contact: mail.easypro.tech@gmail.com
# telegram: https://t.me/easyprotech

# Changelog

All notable changes to Brabus Recon Suite (BRS) are documented in this file.

## [2.1.0] - 2025-08-11

### 🚀 New
- Quick Start: "Full Scan (auto)" at launch
  - Enter = full local host scan (System Info Full → Port Scanner Aggressive → Vulnerability Comprehensive)
  - IP/Domain = full remote target scan (Aggressive + Comprehensive, Domain Recon for domains)

### 🔧 Improvements
- i18n loading fixed across modules; unified `CURRENT_LANGUAGE="en"`
- Main menu uses localized labels for Domain Recon/Results
- Centralized tool management; removed inline `apt install` from modules
- Added required tools in checker: dig, whois, jq, tor, proxychains, hping3
- Network Discovery: fixed variable scoping, non-interactive `LOCAL_NET` support
- Domain Recon: fixed total time calculation in comprehensive scan
- Added `scripts/self_test.sh` smoke runner (non-invasive checks)

### 📝 Docs
- README updated for v2.1 and quick start flow
- KEY_VERIFICATION updated to current GPG key metadata
- Synced legal/release files with upstream

### 🐛 Fixes
- Help text corrected to point to Settings → Check Tools
- Ethics agreement log now records BRS v2.1

## [2.0.0] - 2025-07-22

### 🚀 Major Features Added
- **Domain Reconnaissance Module** - Complete domain analysis toolkit
  - Basic domain information gathering
  - Comprehensive DNS records enumeration
  - Advanced subdomain discovery techniques
  - Email harvesting from multiple sources
  - Zone transfer vulnerability testing
  - Certificate transparency log analysis
  - WHOIS information lookup
  - Web technology stack detection
  - Social media presence discovery
  - Comprehensive automated domain scanning

### ✨ Interface Improvements
- **Professional Menu Design** - Removed emojis from all menu items for business use
- **Clean Business Interface** - Enterprise-appropriate visual design
- **Consistent Formatting** - Standardized output across all modules
- **Professional Color Schemes** - Business-friendly color coding

### ⚡ Performance Enhancements
- **Unified Progress System** - Consistent spinner implementation across all modules
- **Live Timers** - Real-time operation duration tracking
- **Cancellation Support** - Proper Ctrl+C handling with cleanup
- **Professional Animation** - Unicode spinner indicators with status messages
- **Enhanced Error Handling** - Robust interrupt handling and resource cleanup

### 🔧 System Information Improvements
- **Enhanced Data Collection** - More comprehensive system analysis
- **Categorized Reporting** - Organized information by category
- **Timestamped Results** - All reports include timestamps
- **Progress Indicators** - Long operations now show professional progress
- **Better Formatting** - Improved readability and structure

### 🛠️ Technical Improvements
- **Code Optimization** - Removed redundant functions and improved performance
- **Better Resource Management** - Enhanced cleanup and signal handling
- **Improved Documentation** - Complete feature coverage and usage examples
- **Standardized Architecture** - Consistent code structure across modules

### 📝 Development Changes
- **Language Simplification** - Temporarily English-only for V2.0 development
- **Legacy Preservation** - V1.0 multi-language files preserved in project history
- **Enhanced Documentation** - Complete README.md rewrite for V2.0
- **Professional Standards** - Business-appropriate terminology and presentation

### 🔍 Scanning Improvements
- **Better Progress Tracking** - All scanning operations show live progress
- **Enhanced Result Formatting** - Professional output formatting
- **Improved Error Handling** - Better handling of network issues and timeouts
- **Optimized Performance** - Faster scanning with better resource usage

### 📊 Results Management
- **Improved File Naming** - Consistent timestamp-based naming convention
- **Better Organization** - Categorized result files
- **Enhanced Formatting** - Professional report formatting
- **Audit Trail Support** - Timestamped results for compliance

### 🐛 Bug Fixes
- **Menu Navigation** - Fixed input handling issues in all menus
- **Progress Indicators** - Removed old, inconsistent progress functions
- **Signal Handling** - Proper cleanup on interruption
- **Resource Management** - Fixed memory and file handle leaks
- **Error Messages** - Clearer, more professional error reporting

### 🔄 Removed Features
- **Emoji-heavy Interface** - Replaced with professional business design
- **Inconsistent Progress Bars** - Replaced with unified spinner system
- **Old Progress Functions** - Removed show_progress and show_collection functions
- **Redundant Code** - Eliminated duplicate functionality

### 📚 Documentation
- **Complete README.md Rewrite** - Professional documentation for V2.0
- **Feature Documentation** - Comprehensive coverage of all capabilities
- **Usage Examples** - Professional workflow examples
- **Technical Requirements** - Detailed system and dependency information

### 🏢 Business Information Updates
- **Repository Information** - Added GitHub repository links
- **Contact Details** - Updated contact information
- **Professional Branding** - EasyProTech LLC London, UK
- **Support Policy** - Clarified support and contribution policies

## [1.0.0] - 2024

### Initial Release
- Basic network discovery
- Port scanning capabilities
- Vulnerability assessment
- System information gathering
- Attack tools
- Multi-language support (7 languages)
- Foundation architecture

---

**Repository**: https://github.com/EPTLLC/brs  
**Company**: EasyProTech LLC, London, UK  
**Contact**: mail.easypro.tech@gmail.com  
**Telegram**: @easyprotech 

## **🎉 РЕЗУЛЬТАТ GIT ОПЕРАЦИЙ:**

### ✅ **ВЕРСИИ СОХРАНЕНЫ:**
- **main branch** - содержит **V1.0** с эмодзи и мультиязычностью
- **v2.0 branch** - содержит **V2.0** с профессиональным интерфейсом

### ✅ **ТЕГИ СОЗДАНЫ:**
- **v1.0** - первая версия (существовал ранее)
- **v2.0.0** - новая версия с полным описанием

### ✅ **ФАЙЛЫ ДОБАВЛЕНЫ:**
- **CHANGELOG.md** - полная история изменений
- **.gitignore** - профессиональная конфигурация
- **results/.gitkeep** - структура директорий

### ✅ **ГОТОВО К PUSH:**

Теперь нужно только **отправить на GitHub**:

```bash
<code_block_to_apply_from>
# Отправка основной ветки V2.0
git push origin v2.0

# Отправка тега
git push origin v2.0.0

# Убедиться что main остался нетронутым
git push origin main
```

### 🏆 **ИТОГ:**
- **V1.0 СОХРАНЁН** в ветке `main` 
- **V2.0 ГОТОВ** в ветке `v2.0`
- **Теги созданы** для обеих версий
- **История сохранена** полностью

**BRS V2.0** готов для [https://github.com/EPTLLC/brs](https://github.com/EPTLLC/brs)! 🚀 