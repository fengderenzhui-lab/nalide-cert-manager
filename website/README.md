# 官网源码

cert.nalide.com 的网站源码，可自由修改替换。

## 结构

- `index.html` — 首页（三语言：简体/繁体/英文）
- `privacy.html` — 隐私政策（三语言）
- `terms.html` — 用户协议（三语言）
- `robots.txt` / `sitemap.xml` / `llms.txt` — SEO 文件

## 自定义

直接改 HTML 即可。语言词典在各自页面的 `<script>` 底部 `i18n` 对象里，
加新语言只需加一组词条。样式是内联 `<style>`，无构建步骤。

## 部署

把文件传到任意静态托管即可。如需 `install.sh`，放在仓库根目录，
官网的安装命令会从 `raw.githubusercontent.com` 拉取。
