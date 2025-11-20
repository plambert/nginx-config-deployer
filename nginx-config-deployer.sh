#!/usr/bin/env bash

# ==============================================================================
# Nginx 설정 배포 스크립트 (v2.1 - 일반용)
#
# 기능:
# 1. Git 저장소의 설정을 /etc/nginx로 동기화 (rsync)
# 2. 배포된 파일들의 소유권 및 권한을 표준에 맞게 재설정
# 3. Nginx 설정 문법 테스트
# 4. Nginx 서비스 무중단 재시작 (reload)
# ==============================================================================

# =============================English Translation==============================
# Nginx Configuration Deployment Script (v2.1 - General)
# Functions:
# 1. Synchronize Git repository settings to /etc/nginx (rsync)
# 2. Reset ownership and permissions of deployed files to standards
# 3. Test Nginx configuration syntax
# 4. Restart Nginx service without interruption (reload)
# ==============================================================================

set -e -o pipefail

# 스크립트는 반드시 sudo 권한으로 실행되어야 합니다. # (Korean)
# The script must be run with sudo privileges. # (English Translation)

if [ "$EUID" -ne 0 ]; then
  # echo "🚨 이 스크립트는 sudo 권한으로 실행해야 합니다." # (Korean)
  echo "🚨 The script must be run with sudo privileges." # (English Translation)
  # echo "   예: sudo ./backup_nginx_config.sh" # (Korean)
  echo "   run: sudo ./backup_nginx_config.sh" # (English Translation)
  exit 1
fi

# --- 변수 설정 (!!! 사용 전 이 부분을 자신의 환경에 맞게 수정하세요 !!!) --- # (Korean)
# --- Setting variables (!!! Modify this part to suit your environment before use!!!) --- # (English Translation)

# Git으로 관리하는 Nginx 설정 파일이 있는 로컬 디렉토리 경로 # (Korean)
# Path to the local directory containing the Nginx configuration file managed by Git # (English Translation)
CONFIG_SOURCE_PATH="/path/to/your/nginx-config-repo/"
# Nginx 실제 설정 경로 (대부분의 시스템에서 이 값은 수정할 필요 없음) # (Korean)
# Nginx actual configuration path (this value does not need to be modified on most systems) # (English Translation)
NGINX_TARGET_PATH="/etc/nginx/"
# Let's Encrypt 인증서 경로 (대부분의 시스템에서 이 값은 수정할 필요 없음) # (Korean)
# Let's Encrypt certificate path (this value does not need to be modified on most systems) # (English Translation)
LE_LIVE_PATH="/etc/letsencrypt/live/"
LE_ARCHIVE_PATH="/etc/letsencrypt/archive/"

# ==============================================================================
# STEP 1: 설정 파일 동기화
# ==============================================================================

# =============================English Translation==============================
# STEP 1: Synchronize settings files
# ==============================================================================

# echo "🚀 STEP 1: Nginx 설정 파일을 동기화합니다..." # (Korean)
echo "🚀 STEP 1: Synchronizing Nginx configuration files..." # (English Translation)
# echo "   - 원본: ${CONFIG_SOURCE_PATH}" # (Korean)
echo "   - Source: ${CONFIG_SOURCE_PATH}" # (English Translation)
# echo "   - 대상: ${NGINX_TARGET_PATH}" # (Korean)
echo "   - Target: ${NGINX_TARGET_PATH}" # (English Translation)

if ! rsync \
  -av \
  --delete \
  --exclude='.git/' \
  --exclude='.gitignore' \
  --exclude='deploy*.sh' \
  --exclude='backups/' \
  --exclude='sites-enabled/' \
  "${CONFIG_SOURCE_PATH}" \
  "${NGINX_TARGET_PATH}"; then
  # echo "❌ 동기화(rsync) 실패. 배포를 중단합니다." # (Korean)
  echo "❌ Synchronization (rsync) failed. Aborting deployment." # (English Translation)
  exit 1
fi

# ==============================================================================
# STEP 1.5: sites-enabled 심볼릭 링크 재설정
# ==============================================================================

# =============================English Translation==============================
# Step 1.5: Reset the sites-enabled symbolic link
# ==============================================================================

# echo "🔗 STEP 1.5: sites-enabled 심볼릭 링크를 재설정합니다..." # (Korean)
echo "🔗 STEP 1.5: Reset the sites-enabled symbolic link..." # (English Translation)

# 기존 sites-enabled 링크를 모두 제거 # (Korean)
# Remove all existing sites-enabled links # (English Translation)
find "${NGINX_TARGET_PATH}sites-enabled" -type l -delete

# sites-available의 모든 .conf 파일 중 유효한 파일에 대해 심볼릭 링크 생성 # (Korean)
# Create symbolic links for all valid .conf files in sites-available. # (English Translation)
for conf_file in "${NGINX_TARGET_PATH}sites-available"/*.conf; do
  filename=$(basename "$conf_file")
  # 파일이 실제로 존재하는 경우에만 링크 생성
  # Create links only if the file actually exists
  if [ -f "$conf_file" ]; then
    # echo "   - 링크 생성: ${filename}" # (Korean)
    echo " - Create link: ${filename}" # (English Translation)
    ln -sf "${conf_file}" "${NGINX_TARGET_PATH}sites-enabled/${filename}"
  fi
done

# ==============================================================================
# STEP 2: 파일 소유권 및 권한 재설정 (가장 중요!)
# ==============================================================================

# =============================English Translation==============================
# Step 1.5: Reset file ownership and permissions (most important!)
# ==============================================================================

# echo "🛡️ STEP 2: 파일 소유권 및 권한을 재설정합니다..." # (Korean)
echo "🛡️ STEP 2: Reset file ownership and permissions (most important!)" # (English Translation)
# 1. 전체 Nginx 설정 디렉토리 소유권을 root:root로 변경 # (Korean)
# 1. Change ownership of the entire Nginx configuration directory to root:root. # (English Translation)
if ! chown -R root:root "${NGINX_TARGET_PATH}"; then
  # echo "❌ 소유권 변경 실패. 배포를 중단합니다." # (Korean)
  echo "❌ Ownership change failed. Aborting deployment." # (English Translation)
  exit 1
fi

# 2. 일반 파일 및 디렉토리 권한 설정 # (Korean)
# 2. Setting general file and directory permissions # (English Translation)
find "${NGINX_TARGET_PATH}" -type d -exec chmod 755 {} +
find "${NGINX_TARGET_PATH}" -type f -exec chmod 644 {} +

# 3. Let's Encrypt 인증서 관련 권한 재설정 (보안 핵심) # (Korean)
# 3. Resetting Let's Encrypt Certificate Permissions (Security Essentials) # (English Translation)
if [ -d "${LE_LIVE_PATH}" ]; then
  # echo "   - Let's Encrypt 인증서 권한을 확인 및 재설정합니다..." # (Korean)
  echo "   - Verify and reset Let's Encrypt certificate authority..." # (English Translation)
  chown -R root:root "${LE_LIVE_PATH}"
  chown -R root:root "${LE_ARCHIVE_PATH}"

  find "${LE_LIVE_PATH}" -type d -exec chmod 755 {} +
  find "${LE_LIVE_PATH}" -type f -exec chmod 644 {} +
  # 개인키(privkey.pem)는 root만 읽을 수 있도록 더욱 엄격하게 설정 # (Korean)
  # The private key (privkey.pem) is set to be readable only by root. # (English Translation)
  find "${LE_LIVE_PATH}" -name "privkey.pem" -exec chmod 600 {} +
fi

# ==============================================================================
# STEP 3: Nginx 설정 구문 테스트
# ==============================================================================

# =============================English Translation==============================
# STEP 3: Testing Nginx Configuration Syntax
# ==============================================================================

# echo "🧪 STEP 3: Nginx 설정 구문 테스트를 실행합니다..." # (Korean)
echo "🧪 STEP 3: Run the Nginx configuration syntax test..." # (English Translation)

if ! nginx -t; then
  echo "❌ Nginx 설정 테스트 실패. 오류를 수정하고 다시 시도하세요."
  exit 1
fi

# ==============================================================================
# STEP 4: Nginx 서비스 재시작
# ==============================================================================

# =============================English Translation==============================
# STEP 4: Restart the Nginx service
# ==============================================================================

# echo "🔄 STEP 4: Nginx 서비스를 재시작(reload)합니다..." # (Korean)
echo "🔄 STEP 4: Reload the Nginx service..." # (English Translation)

if ! systemctl reload nginx; then
  # echo "❌ Nginx 서비스 재시작 실패. 로그를 확인하세요." # (Korean)
  echo "❌ Failed to restart Nginx service. Check the logs." # (English Translation)
  exit 1
fi

# echo "✅✨ Nginx 설정이 성공적으로 배포 및 적용되었습니다!" # (Korean)
echo "✅✨ Nginx configuration successfully deployed and applied!" # (English Translation)
