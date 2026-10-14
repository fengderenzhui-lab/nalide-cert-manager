<div align="center">

# NALIDE Cert Manager

**开源 ACME 证书申请与生命周期管理工具**

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Go](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go&logoColor=white)](https://go.dev)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)](https://github.com/fengderenzhui-lab/nalide-cert-manager)

单二进制 · 零依赖 · 服务器本地运行 · 私钥不出内网

[官网](https://cert.nalide.com) · [下载](https://github.com/fengderenzhui-lab/nalide-cert-manager/releases) · [问题反馈](https://github.com/fengderenzhui-lab/nalide-cert-manager/issues)

</div>

---

## 功能特性

| 功能 | 说明 |
|---|---|
| 一键安装 | 一条命令完成安装，自动配置 systemd 服务 |
| 多 CA 支持 | Let's Encrypt、ZeroSSL、Google Public CA、自定义 ACME 服务器 |
| 全类型证书 | 单域名、SAN 多域名、泛域名（DV） |
| 自动验证 | HTTP-01 自动验证，泛域名自动切换 DNS-01 |
| 自动续期 | 到期前自动续期，续期后自动重载服务 |
| 一键部署 | 自动部署到 Nginx / Caddy，支持强制 HTTPS |
| 邮件通知 | 证书到期、续期失败邮件提醒 |
| DNS 凭证管理 | 多 DNS 服务商 API 凭证统一管理，AES-256-GCM 加密存储 |
| REST API | Token 鉴权，证书全生命周期可编程管理 |
| 外部证书导入 | 已有商业证书可导入统一管理 |
| Web 面板 | 现代化管理界面，单用户登录，首次启动生成随机强密码 |

## 快速开始

### 一键安装（推荐）

```bash
curl -sSO https://raw.githubusercontent.com/fengderenzhui-lab/nalide-cert-manager/main/install.sh && bash install.sh
```

安装脚本会自动检测系统架构（amd64 / arm64），下载对应二进制文件，安装并启动 systemd 服务，最后打印面板地址、用户名和随机初始密码。

### 手动安装

从 [Releases](https://github.com/fengderenzhui-lab/nalide-cert-manager/releases) 下载对应架构的压缩包，解压后运行：

```bash
tar xzf nalide-cert-manager-linux-amd64.tar.gz
cd nalide-cert-manager
sudo ./install.sh
```

## 使用指南

### 申请证书

1. 打开 Web 面板，进入「申请证书」
2. 在文本框中输入域名，多个域名用空格分隔：
   ```
   example.com www.example.com
   ```
3. 泛域名（如 `*.example.com`）会自动使用 DNS-01 验证
4. 选择 CA，点击申请，等待验证完成

### DNS-01 验证

申请泛域名证书时，需要先配置 DNS 服务商的 API 凭证：

1. 进入「DNS 凭证管理」，添加你的 DNS 服务商凭证
2. 申请证书时选择对应的 DNS 凭证
3. 系统自动添加 TXT 记录完成验证，验证后自动清理

### 自动续期

- 证书到期前 30 天自动续期
- 续期成功后自动重新部署到 Nginx / Caddy
- 续期失败时发送邮件通知

### REST API

```bash
# 获取证书列表
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://your-server:8443/api/v1/certificates

# 申请证书
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"domains":["example.com","www.example.com"],"ca":"letsencrypt"}' \
  https://your-server:8443/api/v1/certificates
```

Token 在 Web 面板的「API 设置」中生成。

## 从源码构建

```bash
git clone https://github.com/fengderenzhui-lab/nalide-cert-manager.git
cd nalide-cert-manager
go build -o nalide-cert-manager ./cmd/server
```

要求 Go 1.21 及以上版本。

## 安全

- **私钥不出内网**：所有私钥的生成、存储、使用都在你的服务器本地完成
- **凭证加密存储**：DNS API 凭证使用 AES-256-GCM 加密
- **强密码机制**：首次启动生成高强度随机密码，建议首次登录后修改
- 发现安全问题？请通过 [Security Advisory](https://github.com/fengderenzhui-lab/nalide-cert-manager/security/advisories/new) 私下报告，请勿公开提交 Issue

## 路线图

- [ ] SSH 远程部署到多台服务器（V2）
- [ ] Webhook 通知（钉钉、飞书、企业微信）（V2）
- [ ] Docker 官方镜像
- [ ] 更多 DNS 服务商支持

## 参与贡献

欢迎提交 Issue 和 Pull Request。

## 界面自定义

Web 面板的界面可自由修改替换。前端为独立模块，你可以根据自己的品牌风格重写页面样式、调整布局、替换 Logo，改完重新构建即可生效，无需改动后端逻辑。

## 开源协议

本项目采用 [Apache-2.0](LICENSE) 协议开源。

---

<div align="center">

**NALIDE** · 构筑云原生基础设施生态

[nalide.com](https://nalide.com) · [cert.nalide.com](https://cert.nalide.com)

</div>
