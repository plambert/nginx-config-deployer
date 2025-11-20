#!/bin/bash

# ==============================================================================
# Nginx 설정 사전 테스트 스크립트 (v1.0 - 일반용)
#
# 기능:
# 1. Git 저장소에 있는 Nginx 설정 파일의 문법을 테스트합니다.
# 2. 실제 운영 중인 /etc/nginx 서비스에는 전혀 영향을 주지 않습니다.
# 3. 배포 스크립트를 실행하기 전, 변경 사항을 미리 검증하는 용도입니다.
# ==============================================================================

# =============================English Translation==============================
# Nginx Configuration Pre-Test Script (v1.0 - General)
#
# Function:
# 1. Tests the syntax of Nginx configuration files in a Git repository.
# 2. Does not affect the actual /etc/nginx service.
# 3. Pre-validates changes before running deployment scripts.
# ==============================================================================

set -e -o pipefail

# 스크립트는 반드시 sudo 권한으로 실행되어야 합니다. # (Korean)
# The script must be run with sudo privileges. (English Translation)
# (SSL 인증서 등 root 권한이 필요한 파일을 읽기 위함) # (Korean)
# (To read files that require root privileges, such as SSL certificates) # (English Translation)
if [ "$EUID" -ne 0 ]; then
  # echo "🚨 이 스크립트는 sudo 권한으로 실행해야 합니다." # (Korean)
  echo "🚨 The script must be run with sudo privileges." # (English Translation)
  # echo "   예: sudo ./test_nginx_config.sh" # (Korean)
  echo "   Run: sudo ./test_nginx_config.sh" # (English Translation)
  exit 1
fi

# --- 변수 설정 (!!! 사용 전 이 부분을 자신의 환경에 맞게 수정하세요 !!!) --- # (Korean)
# --- Setting variables (!!! Modify this part to suit your environment before use!!!) --- (English Translation)
# Git으로 관리하는 Nginx 설정 파일이 있는 로컬 디렉토리 경로 # (Korean)
# Path to the local directory containing the Nginx configuration file managed by Git # (English Translation)
CONFIG_SOURCE_DIR="/path/to/your/nginx-config-repo/"
# 테스트할 메인 설정 파일명 # (Korean)
# Main configuration file name to be tested # (English Translation)
NGINX_CONF_FILENAME="nginx.conf"
# 테스트 대상 파일의 전체 경로 # (Korean)
# Full path of the file to be tested # (English Translation)
CONFIG_SOURCE_PATH="${CONFIG_SOURCE_DIR}${NGINX_CONF_FILENAME}"

# ==============================================================================
# STEP 1: 설정 파일 존재 여부 확인
# ==============================================================================

# =============================English Translation==============================
# STEP 1: Check if the settings file exists
# ==============================================================================

# echo "🔎 STEP 1: 테스트할 설정 파일을 확인합니다..." # (Korean)
echo "🔎 STEP 1: Check the configuration file to test..." # (English Translation)
# echo "   - 대상 파일: ${CONFIG_SOURCE_PATH}" # (Korean)
echo "   - Target file: ${CONFIG_SOURCE_PATH}" # (English Translation)

if [ ! -f "${CONFIG_SOURCE_PATH}" ]; then
  # echo "❌ 테스트 대상 파일이 없습니다. 경로를 확인하세요." # (Korean)
  echo "❌ The test target file does not exist. Please check the path." # (English Translation)
  exit 1
fi

# ==============================================================================
# STEP 2: Nginx 설정 구문 사전 테스트
# ==============================================================================

# =============================English Translation==============================
# STEP 2: Pre-testing Nginx configuration syntax
# ==============================================================================

# echo "🧪 STEP 2: Nginx 설정 구문 사전 테스트를 실행합니다..." # (Korean)
echo "🧪 STEP 2: Run a pre-test of your Nginx configuration syntax..." # (English Translation)

# -t 옵션으로 테스트, -c 옵션으로 실제 서비스가 아닌 Git 저장소의 설정 파일 지정 # (Korean)
# -t option for testing, -c option for specifying configuration file in Git repository instead of actual service # (English Translation)
if ! nginx -t -c "${CONFIG_SOURCE_PATH}"; then
  # echo "❌ Nginx 설정 테스트 실패. Git 저장소의 파일을 수정하십시오." # (Korean)
  echo "❌ Nginx configuration test failed. Please fix the file in the Git repository." # (English Translation)
  exit 1
fi

# echo "✅✨ Git 저장소의 Nginx 설정이 유효합니다! 이제 배포를 진행할 수 있습니다." # (Korean)
echo "✅✨ The Nginx configuration in your Git repository is now valid! You can now deploy." # (English Translation)
