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
# 从 GitHub API 查找匹配平台的附件下载地址（兼容文件名带前缀的情况）
find_asset_url() {
  local os="$1" arch="$2" tag="$3" api_url
  if [ "$tag" = "latest" ]; then
    api_url="https://api.github.com/repos/${REPO}/releases/latest"
  else
    api_url="https://api.github.com/repos/${REPO}/releases/tags/${tag}"
  fi
  require_cmd curl
  # 找名字以 nalide-cert-manager-<os>-<arch> 结尾的附件
  curl -fsSL "$api_url" | grep -o ""browser_download_url": *"[^"]*nalide-cert-manager-${os}-${arch}[^"]*"" | head -1 | cut -d'"' -f4
}

download_binary() {
  local os="$1" arch="$2" url=""
  url="$(find_asset_url "$os" "$arch" "$VERSION")"
  if [ -z "$url" ]; then
    error "未找到 ${os}/${arch} 平台的安装包（版本: ${VERSION}）"
    exit 1
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
show_banner() {
  echo -e "${GREEN}"
  echo "  ███╗   ██╗ █████╗ ██╗     ██╗██████╗ ███████╗"
  echo "  ████╗  ██║██╔══██╗██║     ██║██╔══██╗██╔════╝"
  echo "  ██╔██╗ ██║███████║██║     ██║██║  ██║█████╗  "
  echo "  ██║╚██╗██║██╔══██║██║     ██║██║  ██║██╔══╝  "
  echo "  ██║ ╚████║██║  ██║███████╗██║██████╔╝███████╗"
  echo "  ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ ╚══════╝"
  echo -e "${NC}"
  echo -e "  ${GREEN}NALIDE Cert Manager${NC} - 开源 ACME 证书管理工具"
  echo -e "  ${YELLOW}由 NALIDE 团队开发维护${NC} | https://nalide.com"
  echo ""
}

main() {
  show_banner
  info "开始安装..."
  info "仓库: https://github.com/${REPO}"

  local os arch
  os="$(detect_os)"
  arch="$(detect_arch)"
  info "平台: ${os}/${arch}"

  local tmpdir
  tmpdir="$(mktemp -d)"
  cd "${tmpdir}"
  trap 'rm -rf "${tmpdir}"' EXIT

  download_binary "${os}" "${arch}"
  install_binary "${BIN_NAME}"

  if [ -x "${INSTALL_DIR}/${BIN_NAME}" ]; then
    info "安装完成: ${INSTALL_DIR}/${BIN_NAME}"
  else
    error "安装失败：二进制文件不可执行"
    exit 1
  fi
  echo ""
  info "启动服务: ${BIN_NAME}"
  echo "  首次启动会自动生成高强度随机密码并打印在终端，请妥善保存。"
  echo "  默认管理面板: http://127.0.0.1:8888"
  echo ""
  warn "生产环境使用前请阅读 README 与隐私政策，建议先用 Staging 环境调试。"
}

main "$@"
