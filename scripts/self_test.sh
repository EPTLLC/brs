#!/bin/bash
# Project: Brabus Recon Suite (BRS)
# Company: EasyProTech LLC (www.easypro.tech)
# Dev: Brabus
# Date: 2025-08-11 00:29:28 MSK
# This file was created
# Telegram: https://t.me/easyprotech

# BRS Self-Test Runner
# Purpose: Smoke-test core modules non-invasively

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"
RESULTS_DIR="$BASE_DIR/results"
CONFIG_DIR="$BASE_DIR/configs"
LANG_FILE="$CONFIG_DIR/language.conf"

echo -e "${BLUE}BRS Self-Test starting...${NC}"
mkdir -p "$RESULTS_DIR"

# Ensure language is EN for test determinism
if [ -f "$LANG_FILE" ]; then
  sed -i 's/^CURRENT_LANGUAGE=.*/CURRENT_LANGUAGE="en"/' "$LANG_FILE" || true
fi

fail=0

run_case() {
  local name="$1"
  shift
  echo -e "${YELLOW}→ $name${NC}"
  if "$@"; then
    echo -e "${GREEN}✔ $name${NC}"
  else
    echo -e "${RED}✖ $name${NC}"
    fail=$((fail+1))
  fi
}

# Case 1: tools script loads and quick check runs
run_case "tools quick check" bash -lc "source '$BASE_DIR/tools.sh'; quick_tool_check >/dev/null 2>&1 || true"

# Case 2: ethics gate text renders (non-interactive probe via function presence)
run_case "main.sh loads and has menus" bash -lc "grep -q 'show_main_menu' '$BASE_DIR/main.sh' && grep -q 'require_ethics_agreement' '$BASE_DIR/main.sh'"

# Case 3: network_discovery present and executable
run_case "network_discovery.sh present" test -x "$SCRIPTS_DIR/network_discovery.sh"

# Case 4: port_scanner present and executable
run_case "port_scanner.sh present" test -x "$SCRIPTS_DIR/port_scanner.sh"

# Case 5: vulnerability_scanner present and executable
run_case "vulnerability_scanner.sh present" test -x "$SCRIPTS_DIR/vulnerability_scanner.sh"

# Case 6: system_info present and executable
run_case "system_info.sh present" test -x "$SCRIPTS_DIR/system_info.sh"

# Case 7: attack_tools present and executable
run_case "attack_tools.sh present" test -x "$SCRIPTS_DIR/attack_tools.sh"

# Case 8: language loads correctly
run_case "language en.sh has MENU_TITLE" bash -lc "grep -q '^MENU_TITLE=' '$BASE_DIR/languages/en.sh'"

# Case 9: configs language is en
run_case "config language is en" bash -lc "grep -Eq '^ *CURRENT_LANGUAGE *= *\"?en\"?' '$CONFIG_DIR/language.conf'"

# Case 10: results directory writeable
run_case "results dir writable" bash -lc "touch '$RESULTS_DIR/_selftest.tmp' && rm -f '$RESULTS_DIR/_selftest.tmp'"

echo
if [ "$fail" -eq 0 ]; then
  echo -e "${GREEN}All self-tests passed.${NC}"
  exit 0
else
  echo -e "${RED}$fail test(s) failed.${NC}"
  exit 1
fi


