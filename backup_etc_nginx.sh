#!/bin/bash

# ==============================================================================
# Nginx 설정 자동 백업 스크립트 (v1.0 - 일반용)
#
# 기능:
# 1. /etc/nginx 디렉토리 전체를 타임스탬프가 찍힌 .tar.gz 압축 파일로 백업
# 2. 지정된 기간이 지난 오래된 백업 파일은 자동으로 삭제
# ==============================================================================

# =============================English Translation==============================
# Nginx Configuration Automated Backup Script (v1.0 - General)
#
# Features:
# 1. Back up the entire /etc/nginx directory as a timestamped .tar.gz compressed file.
# 2. Automatically delete old backup files after a specified period.
# ==============================================================================

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

# 백업을 저장할 디렉토리 경로 # (Korean)
# Directory path to save backups # (English Translation)
BACKUP_DIR="/path/to/your/backup/location/"
# 백업 대상 디렉토리 (대부분의 시스템에서 이 값은 수정할 필요 없음) # (Korean)
# Backup source directory (this value does not need to be modified on most systems) # (English Translation)
NGINX_CONFIG_PATH="/etc/nginx"
# 백업 보관 기간 (일 단위, 예: 7일이 지난 파일은 삭제) # (Korean)
# Backup retention period (in days, e.g. files older than 7 days are deleted) # (English Translation)
RETENTION_DAYS=7

# ==============================================================================
# STEP 1: 백업 디렉토리 확인 및 생성
# ==============================================================================

# =============================English Translation==============================
# STEP 1: Verify and create backup directory
# ==============================================================================

# echo "📂 STEP 1: 백업 디렉토리를 확인합니다..." # (Korean)
echo "📂 STEP 1: Check the backup directory..."
# echo "   - 경로: ${BACKUP_DIR}" # (Korean)
echo "   - Directory: ${BACKUP_DIR}" # (English Translation)

if ! mkdir -p "${BACKUP_DIR}"; then
  # echo "❌ 백업 디렉토리 생성 실패. 경로와 권한을 확인하세요." # (Korean)
  echo "❌ Failed to create backup directory. Check the path and permissions." # (English Translation)
  exit 1
fi

# ==============================================================================
# STEP 2: Nginx 설정 백업 실행
# ==============================================================================

# =============================English Translation==============================
# STEP 2: Run a backup of your Nginx configuration
# ==============================================================================
# 날짜 및 시간 형식 지정 (예: nginx_backup_20250826_183000.tar.gz) # (Korean)
# Specify date and time format (e.g. nginx_backup_20250826_183000.tar.gz) # (English Translation)
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="nginx_backup_${DATE}.tar.gz"
BACKUP_FILE_PATH="${BACKUP_DIR}/${BACKUP_FILENAME}"

# echo "🚀 STEP 2: Nginx 설정 백업을 시작합니다..." # (Korean)
echo "🚀 STEP 2: Starting to back up Nginx configuration..." # (English Translation)
# echo "   - 원본: ${NGINX_CONFIG_PATH}" # (Korean)
echo "   - Source: ${NGINX_CONFIG_PATH}" # (English Translation)
# echo "   - 대상 파일: ${BACKUP_FILE_PATH}" # (Korean)
echo "   - Target file: ${BACKUP_FILE_PATH}" # (English Translation)

# tar 명령어로 디렉토리를 하나의 압축 파일로 백업 # (Korean)
# Back up a directory into a single compressed file using the tar command # (English Translation)
# c: 새로운 아카이브 생성, z: gzip으로 압축, f: 파일명 지정, p: 권한 보존 # (Korean)
# c: create new archive, z: compress with gzip, f: specify file name, p: preserve permissions # (English Translation)
if ! tar -czpf "${BACKUP_FILE_PATH}" -C "$(dirname "${NGINX_CONFIG_PATH}")" "$(basename "${NGINX_CONFIG_PATH}")"; then
  # echo "❌ Nginx 설정 백업 실패!" # (Korean)
  echo "❌ Nginx configuration backup failed!" # (English Translation)
  exit 1
fi

# echo "   - 백업 파일 생성 완료!" # (Korean)
echo "   - Backup file creation complete!" # (English Translation)

# ==============================================================================
# STEP 3: 오래된 백업 파일 정리
# ==============================================================================

# =============================English Translation==============================
# STEP 3: Clean up old backup files
# ==============================================================================
# echo "🧹 STEP 3: 오래된 백업 파일(${RETENTION_DAYS}일 경과)을 정리합니다..." # (Korean)
echo "🧹 STEP 3: Cleaning up old backup files (older than ${RETENTION_DAYS} days)..." # (English Translation)

# find 명령어로 지정된 기간이 지난 백업 파일 검색 후 삭제 # (Korean)
# Search for and delete backup files that have passed the specified period using the find command. # (English Translation)
# find "${BACKUP_DIR}" -type f -name "nginx_backup_*.tar.gz" -mtime +${RETENTION_DAYS} -exec echo "   - 삭제: {}" \; -exec rm {} \; # (Korean)
find "${BACKUP_DIR}" -type f -name "nginx_backup_*.tar.gz" -mtime +${RETENTION_DAYS} -exec echo "   - Delete: {}" \; -exec rm {} \; # (English Translation)

# echo "✅✨ Nginx 설정 백업이 성공적으로 완료되었습니다!" # (Korean)
echo "✅✨ Nginx configuration backup completed successfully!" # (English Translation)
