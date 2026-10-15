#!/usr/bin/env bash
# ============================================================
# NALIDE Cert Manager - 一键安装脚本
# 仓库: https://github.com/fengderenzhui-lab/nalide-cert-manager
# 用法: curl -sSO https://raw.githubusercontent.com/fengderenzhui-lab/nalide-cert-manager/main/install.sh && bash install.sh
# ============================================================
set -euo pipefail

REPO="fengderenzhui-lab/nalide-cert-manager"
BIN_NAME="nalide-cert-manager"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="${VERSION:-latest}"

# ---------- 颜色输出 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[NALIDE]${NC} $*"; }
warn()  { echo -e "${YELLOW}[NALIDE]${NC} $*"; }
error() { echo -e "${RED}[NALIDE]${NC} $*" >&2; }

# ---------- 平台检测 ----------
detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "darwin" ;;
    *)       error "不支持的操作系统: $(uname -s)，本工具面向 Linux / macOS 服务器"; exit 1 ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *)             error "不支持的 CPU 架构: $(uname -m)"; exit 1 ;;
  esac
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "缺少依赖命令: $1，请先安装（如 apt install $1 / yum install $1）"
    exit 1
  fi
}

# ---------- 下载 ----------
download_binary() {
  local os="$1" arch="$2" url="" asset=""
  # V1.0 附件名（含 iOS 上传前缀）
  case "${os}-${arch}" in
    linux-amd64) asset="prod_1a13ce8e338_76a6ae6bbc1d_nalide-cert-manager-linux-amd64" ;;
    linux-arm64) asset="prod_1a13ce8e33c_b65cff8e1c92_nalide-cert-manager-linux-arm64" ;;
    *) error "不支持的平台: ${os}/${arch}"; exit 1 ;;
  esac
  if [ "$VERSION" = "latest" ]; then
    url="https://github.com/${REPO}/releases/latest/download/${asset}"
  else
    url="https://github.com/${REPO}/releases/download/${VERSION}/${asset}"
  fi
  info "下载: ${url}"
  require_cmd curl
  curl -fSL --retry 3 -o "${BIN_NAME}" "${url}"
}

# ---------- 安装 ----------
install_binary() {
  local src="$1"
  if [ ! -w "${INSTALL_DIR}" ]; then
    warn "目标目录 ${INSTALL_DIR} 不可写，改用 sudo 安装"
    require_cmd sudo
    sudo install -m 0755 "${src}" "${INSTALL_DIR}/${BIN_NAME}"
    rm -f "${src}"
  else
    install -m 0755 "${src}" "${INSTALL_DIR}/${BIN_NAME}"
    rm -f "${src}"
  fi
}

# ---------- 主流程 ----------
main() {
  info "NALIDE Cert Manager 安装程序"
  info "仓库: https://github.com/${REPO}"

  local os arch
  os="$(detect_os)"
  arch="$(detect_arch)"
  info "平台: ${os}/${arch}"

  local tmpdir
  tmpdir="$(mktemp -d)"
  cd "${tmpdir}"
  trap 'rm -rf "${tmpdir}"' EXIT

  local asset=""
  case "${os}-${arch}" in
    linux-amd64) asset="prod_1a13ce8e338_76a6ae6bbc1d_nalide-cert-manager-linux-amd64" ;;
    linux-arm64) asset="prod_1a13ce8e33c_b65cff8e1c92_nalide-cert-manager-linux-arm64" ;;
  esac
  download_binary "${os}" "${arch}"
  install_binary "${asset}"

  info "安装完成: ${INSTALL_DIR}/${BIN_NAME}"
  echo ""
  info "启动服务: ${BIN_NAME}"
  echo "  首次启动会自动生成高强度随机密码并打印在终端，请妥善保存。"
  echo "  默认管理面板: http://127.0.0.1:8888"
  echo ""
  warn "生产环境使用前请阅读 README 与隐私政策，建议先用 Staging 环境调试。"
}

main "$@"
