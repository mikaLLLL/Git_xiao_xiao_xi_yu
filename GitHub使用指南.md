# GitHub 使用指南

> 以 **dsh-thinkflux** 的发布为例，从零讲清 GitHub 的账号、仓库、推送、Release、
> 协作、CI、许可证和日常维护。  
> 适用环境：Windows 10/11 + PowerShell；其他系统命令基本一致。  
> 本机当前 PATH 里没有 `git`，所以从安装开始写。

---

## 目录

0. [十个概念先搞懂](#0-十个概念先搞懂)
1. [先想清楚三件事](#1-先想清楚三件事)
2. [账号与安全](#2-账号与安全)
3. [安装 Git](#3-安装-git)
4. [第一次配置](#4-第一次配置)
5. [创建远程仓库](#5-创建远程仓库)
6. [把项目推上去](#6-把项目推上去)
7. [仓库里该放什么](#7-仓库里该放什么)
8. [README 怎么写](#8-readme-怎么写)
9. [许可证与免责声明](#9-许可证与免责声明)
10. [Release：正式发版](#10-release正式发版)
11. [仓库设置](#11-仓库设置)
12. [日常 Git 工作流](#12-日常-git-工作流)
13. [协作：Fork、Issue、PR](#13-协作forkissuepr)
14. [GitHub Actions CI](#14-github-actions-ci)
15. [GitHub Pages（可选）](#15-github-pages可选)
16. [安全与隐私](#16-安全与隐私)
17. [国内网络与代理](#17-国内网络与代理)
18. [推广与长期维护](#18-推广与长期维护)
19. [常见错误速查](#19-常见错误速查)
20. [发版前 Checklist](#20-发版前-checklist)
21. [命令速查表](#21-命令速查表)
22. [附录：本项目目录与链接](#22-附录本项目目录与链接)

---

## 0. 十个概念先搞懂

GitHub 不难，难在第一次看到一堆名词。先用一句话记住：

| 概念 | 一句话 | 在本项目里 |
|---|---|---|
| Repository（仓库） | 一个带版本历史的项目文件夹 | `dsh-thinkflux` |
| Commit（提交） | 一次快照 + 说明 | 「加了思考流面板」 |
| Branch（分支） | 平行开发线 | `main`、`feat/thinking-rate` |
| Remote（远端） | 托管在 GitHub 的那份 | `origin` |
| Clone（克隆） | 把远端整个下载到本地 | `git clone <url>` |
| Fork（复刻） | 在别人仓库名下复制一份到自己账号 | 别人改你的插件 |
| Issue（议题） | 问题、需求、讨论帖 | bug 报告 |
| Pull Request（PR） | 「我这有个改动，请你合并」 | 贡献代码 |
| Release（发布） | 某个版本的正式快照 + 附件 | zip + 校验和 |
| Actions（自动化） | 推送后自动跑测试/打包 | CI |

再加两个会反复遇到的：

- **Pages**：把仓库里的静态文件托管成网站（可选演示页）；
- **Tag**：给某个 commit 起固定名字，`v0.1.0` 就是 tag。

### 0.1 GitHub 页面地图

登录后，仓库顶部那排标签就是全部入口：

| 标签 | 用途 | 你会用到吗 |
|---|---|---|
| Code | 文件列表、README、clone 地址 | 每天 |
| Issues | 问题追踪 | 发布后 |
| Pull requests | 代码合并 | 协作时 |
| Actions | CI 运行记录 | 配了 CI 后 |
| Projects | 看板 | 可选 |
| Wiki | 独立文档 | 不需要，文档放仓库 |
| Security | 漏洞报告、依赖告警 | 建议开 |
| Insights | 流量、克隆、贡献统计 | 偶尔看 |
| Settings | 仓库名、分支保护、Pages、 Secrets | 配置时 |

个人账号的设置在最右上角头像 → Settings；仓库设置是仓库页里的 Settings，别搞混。

---

## 1. 先想清楚三件事

### 1.1 仓库名

建议：`dsh-thinkflux`。

- 全小写、用连字符，别用空格和中文；
- 和 `package.json` 的 `name` 一致；
- 不要叫 `test`、`my-project`，以后改名的成本比想象中高（旧链接、clone 地址、Release 都会断）。

仓库描述（About）控制在 350 字符内，写清楚「是什么、给谁用、非官方」：

```text
Unofficial DeepSeek Harness plugin that turns live reasoning-delta streams into a real-time AI-thinking ring visualization. Noncommercial.
```

### 1.2 许可

本项目沿用 **PolyForm Noncommercial 1.0.0**：

- 可以公开源码、允许他人修改和非商业使用；
- **不能商用**；
- 再分发必须保留 `LICENSE` 和 `NOTICE`；
- 它**不是 OSI 开源许可**，GitHub 的 License 识别器可能显示 `Other`，这是正常的。

不要为了「看起来像开源」改成 MIT/Apache。那属于重新授权，你没有这个权利。

### 1.3 发布形态

推荐：

- **仓库**：源码 + `client.js` + 安装脚本 + 文档；
- **Release 附件**：`dsh-thinkflux-0.1.0-win.zip` + `.sha256`；
- **不把 zip 提交进 Git**：二进制文件会让仓库越来越重，Release 才是放构建产物的地方。

---

## 2. 账号与安全

### 2.1 注册

1. 打开 https://github.com/signup；
2. 邮箱、密码、用户名；
3. 用户名会出现在 URL 里（`github.com/你的名字/dsh-thinkflux`），想好再定；
4. 完成邮箱验证。

### 2.2 开启 2FA

Settings → Password and authentication → Two-factor authentication。

推荐用 TOTP（Microsoft Authenticator / 1Password / Aegis），保存恢复码。
GitHub 对贡献者强制 2FA 的范围在扩大，早开早省事。

### 2.3 三种认证方式

| 方式 | 用途 | 建议 |
|---|---|---|
| HTTPS + PAT | 临时、脚本 | 细粒度 token，设置过期时间 |
| SSH key | 日常 push/pull | 一次配置，长期使用 |
| `gh` CLI | 建仓库、Release、Issue | 可选，但很省事 |

**不要**把 token 写进 remote URL、脚本、README 或聊天记录。GitHub 的 secret scanning
会拦，拦不住的部分会被人扫。

---

## 3. 安装 Git

### 3.1 winget（推荐）

```powershell
winget install --id Git.Git -e --source winget
```

装完**关掉并重开** PowerShell，然后：

```powershell
git --version
```

### 3.2 安装包

https://git-scm.com/download/win

选项保持默认即可，注意：

- `Adjusting your PATH environment` 选 “Git from the command line and also from 3rd-party software”；
- 换行符选 “Checkout as-is, commit Unix-style line endings” 或默认；
- 终端选 Windows Terminal / PowerShell。

### 3.3 可选：GitHub CLI

```powershell
winget install --id GitHub.cli -e --source winget
gh --version
gh auth login
```

`gh auth login` 选 HTTPS + 浏览器登录，按提示授权。

---

## 4. 第一次配置

```powershell
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
git config --global init.defaultBranch main
git config --global core.quotepath false
git config --global core.autocrlf false
git config --global pull.rebase false
```

说明：

- `user.email` 最好和 GitHub 账号邮箱一致，否则提交不会关联到你的头像；
- `core.quotepath false` 让中文文件名正常显示，不再出现 `\346\226\207`；
- `core.autocrlf false` 避免 Windows 自动改行尾；换行统一交给 `.gitattributes`；
- `pull.rebase false` 先保持简单，团队要求 rebase 再改。

检查：

```powershell
git config --global --list
```

### 4.1 SSH key（推荐）

```powershell
ssh-keygen -t ed25519 -C "你的邮箱"
```

一路回车，默认保存在 `C:\Users\<你>\.ssh\id_ed25519`。

启动 ssh-agent 并添加（服务操作需要管理员 PowerShell）：

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

复制公钥：

```powershell
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard
```

GitHub → Settings → SSH and GPG keys → New SSH key → 粘贴 → Add。

测试：

```powershell
ssh -T git@github.com
```

看到 `Hi <username>! You've successfully authenticated` 就通了。

> 22 端口被墙时，在 `C:\Users\<你>\.ssh\config` 写：
>
> ```text
> Host github.com
>   HostName ssh.github.com
>   Port 443
>   User git
> ```
>
> 再 `ssh -T git@github.com`。

---

## 5. 创建远程仓库

### 5.1 网页创建

https://github.com/new

- Repository name：`dsh-thinkflux`
- Description：上面的英文描述
- Public
- **不要**勾 “Add a README file”
- **不要**勾 “Add .gitignore”
- **不要**选 License

为什么都不勾？你本地已经有这些文件，先勾会在远端产生一个初始提交，第一次 push 容易冲突。
空仓库最省事。

### 5.2 gh CLI 创建

```powershell
gh repo create dsh-thinkflux --public --description "Unofficial DeepSeek Harness thinking visualization" --source . --remote origin --push
```

前提：当前目录已经 `git init` 且有提交。没有提交会失败，先看下一节。

---

## 6. 把项目推上去

### 6.1 准备一个干净的发布目录

不要直接把 `D:\dsh-workspace\dist\dsh-thinkflux-0.1.0` 当仓库根目录用也可以，
但建议复制一份，避免把临时文件、预览图、备份带进去：

```powershell
$src = 'D:\dsh-workspace\dist\dsh-thinkflux-0.1.0'
$dst = 'D:\dsh-workspace\release\dsh-thinkflux'
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item "$src\*" $dst -Recurse -Force
cd $dst
```

### 6.2 初始化并提交

```powershell
git init
git add .
git status
```

**先看 `git status`**，确认没有：

- `node_modules/`
- `*.zip`
- `.tmp/`
- `*.bak-*`
- 预览截图（除非你故意要放进 `docs/`）
- 任何 token、密码、内网地址

确认后：

```powershell
git commit -m "feat: initial release v0.1.0"
git branch -M main
```

### 6.3 关联远端并推送

HTTPS：

```powershell
git remote add origin https://github.com/<你的用户名>/dsh-thinkflux.git
git push -u origin main
```

SSH：

```powershell
git remote add origin git@github.com:<你的用户名>/dsh-thinkflux.git
git push -u origin main
```

第一次 HTTPS push 会弹浏览器授权，或要求 PAT。用 Git Credential Manager 存起来，
下次不用再输。

### 6.4 如果 push 被拒

常见原因：

```text
! [rejected] main -> main (fetch first)
```

说明远端有你没有的提交（多半是创建仓库时勾了 README）。

```powershell
git pull origin main --rebase
git push -u origin main
```

不要上来就 `git push -f`。`main` 上 force push 会覆盖别人的提交。

---

## 7. 仓库里该放什么

### 7.1 本项目的推荐结构

```text
dsh-thinkflux/
├─ .github/
│  ├─ ISSUE_TEMPLATE/
│  │  ├─ bug.yml
│  │  └─ feature.yml
│  ├─ pull_request_template.md
│  └─ workflows/ci.yml
├─ locale/
│  ├─ en.json
│  └─ zh.json
├─ src/
│  ├─ engine.js
│  ├─ hud.js
│  ├─ live.js
│  ├─ mount.js
│  ├─ settings.js
│  └─ state.js
├─ tools/
│  ├─ preview.html
│  ├─ test-client.mjs
│  └─ test-thinking.mjs
├─ .gitattributes
├─ .gitignore
├─ build.mjs
├─ client.js
├─ cordis.patch.yml
├─ DISCLAIMER.md
├─ icon.svg
├─ index.js
├─ install.cmd
├─ install.ps1
├─ LICENSE
├─ NOTICE
├─ package.json
├─ README.md
├─ uninstall.cmd
├─ uninstall.ps1
└─ 使用说明.md
```

说明：

- `client.js` 是构建产物，但**要提交**：普通用户不装 Node，直接拿它运行；
- `src/` 是源码，改完跑 `node build.mjs` 重新生成 `client.js`；
- `tools/preview.html` 可以提交，方便别人不装 DSH 也能看引擎；
- `使用说明.md` 用中文文件名没问题，GitHub 能正常显示；
- zip 不放仓库，放 Release。

### 7.2 `.gitignore`

```gitignore
node_modules/
dist/
.tmp/
*.zip
*.log
*.bak-*
.removed-*
tools/*.png
tools/*.jpg
.DS_Store
Thumbs.db
```

注意：`.gitignore` 只对**未跟踪**文件生效。已经提交过的文件要先：

```powershell
git rm -r --cached node_modules
git commit -m "chore: stop tracking node_modules"
```

### 7.3 `.gitattributes`

统一换行，避免 Windows/Linux 协作时整文件 diff：

```gitattributes
* text=auto

*.js    text eol=lf
*.mjs   text eol=lf
*.json  text eol=lf
*.md    text eol=lf
*.yml   text eol=lf
*.yaml  text eol=lf
*.html  text eol=lf
*.css   text eol=lf

*.ps1   text eol=crlf
*.cmd   text eol=crlf
*.bat   text eol=crlf

*.zip   binary
*.png   binary
*.jpg   binary
*.gif   binary
```

`.ps1` 还有一件比换行更重要的事：**UTF-8 BOM**。Windows PowerShell 5.1 会把无 BOM 的
UTF-8 当 ANSI，中文直接乱码/解析失败。保存脚本时确认前三字节是 `EF BB BF`。

---

## 8. README 怎么写

README 是仓库的门面。GitHub 上 80% 的访客只看三屏：标题、截图、安装命令。

### 8.1 推荐结构

1. 一句话是什么 + 一张图/GIF；
2. 它解决什么问题（和原版区别）；
3. 安装（一键 / 手工）；
4. 第一次使用（30 秒看懂）；
5. 配置与快捷键；
6. 数据从哪来（技术可信度）；
7. 已知限制；
8. 免责声明 + 许可；
9. Credits。

### 8.2 标题下的信息密度

```markdown
# dsh-thinkflux — 实时 AI 思考可视化

把 HALOFLUX 的光环引擎改造成 DeepSeek Harness 的思考监视器：
模型每吐出一段 `reasoning-delta`，环带面板就换成真实思考文字。

![preview](docs/preview.png)

> 非官方项目 · PolyForm Noncommercial · 仅限非商业使用
```

图片建议：

- 宽 1200–1600px；
- PNG 压到 1MB 以内，或转 WebP；
- GIF 控制在 5–10MB，别放 50MB 的录屏；
- 放在 `docs/` 下用相对路径，GitHub 直接渲染。

### 8.3 徽章（可选）

```markdown
![platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![license](https://img.shields.io/badge/license-PolyForm%20Noncommercial-orange)
![DSH](https://img.shields.io/badge/DSH-0.2.1--rc.2-blue)
```

不要放「build passing」徽章，除非你真的配了 CI 并且它现在是绿的。

### 8.4 安装命令要能复制

````markdown
```powershell
.\install.ps1 -ProfilePath "D:\dsh\profiles\desktop" -NoRestart
```
````

给出「双击 `install.cmd`」和「命令行指定 profile」两条路径，覆盖小白和进阶用户。

---

## 9. 许可证与免责声明

### 9.1 文件

- `LICENSE`：完整的 PolyForm Noncommercial 1.0.0 原文；
- `NOTICE`：原作者署名、第三方素材来源；
- `DISCLAIMER.md`：免责、隐私、非官方声明；
- README 顶部和末尾各放一次链接。

### 9.2 GitHub 会怎么显示

GitHub 的 license 识别器只认常见许可证。PolyForm 可能显示：

```text
View license
Other
```

这不影响法律效力，但你要在 README 里写清楚：

> This is **not** an OSI-approved open-source license. It is source-available and
> noncommercial only.

别写「open source」，别选 MIT。商用询问统一回复：原作者未提供商业授权。

### 9.3 免责声明要覆盖什么

- 非官方、无隶属、无背书；
- 按“现状”提供，无担保；
- 可能损坏 profile、丢数据、崩溃；
- 只读当前会话，但 DSH 自己会持久化日志；
- 不联网，但录屏/直播可能暴露推理；
- 不承担费用、合规、名誉损失；
- 不得用于违法、误导、规避安全机制；
- 不要把可视化当成「AI 已验证」的证据。

---

## 10. Release：正式发版

### 10.1 版本号

用语义化版本 `MAJOR.MINOR.PATCH`：

- `0.1.0`：首个可用版本；
- `0.1.1`：修 bug；
- `0.2.0`：加功能，可能不兼容；
- `1.0.0`：接口稳定。

`package.json` 的 `version` 和 Git tag 保持一致：`v0.1.0`。

### 10.2 打 tag 并推送

```powershell
git tag -a v0.1.0 -m "dsh-thinkflux v0.1.0"
git push origin v0.1.0
```

### 10.3 创建 Release

网页：仓库 → Releases → Draft a new release

- Choose a tag：`v0.1.0`
- Release title：`v0.1.0 — 首个公开版本`
- Describe this release：写变更、安装、校验和
- Attach binaries：`dsh-thinkflux-0.1.0-win.zip`、`.sha256`

Release notes 模板：

```markdown
## 新增

- 实时 `reasoning-delta` 驱动环带文字
- 左下思考流面板
- 三档数据模式（纯动画 / 混合 / 只看思考）
- 一键安装与卸载脚本

## 安装

1. 下载 `dsh-thinkflux-0.1.0-win.zip`
2. 解压，双击 `install.cmd`
3. 重启 DeepSeek Harness

## 校验

SHA256: `BDB639F4...`

## 已知限制

- 需要宿主下发 reasoning
- 环上中文为 3.5px 微字，阅读请看左下思考面板

**License:** PolyForm Noncommercial 1.0.0（非 OSI 开源，仅限非商业）
```

### 10.4 校验和

```powershell
Get-FileHash .\dsh-thinkflux-0.1.0-win.zip -Algorithm SHA256
```

写入 `.sha256`：

```text
BDB639F4008442F452C5BECB2099D10C2C00E16722BD4E1F2A2FF73556889ACB  dsh-thinkflux-0.1.0-win.zip
```

用户下载后核对：

```powershell
(Get-FileHash .\dsh-thinkflux-0.1.0-win.zip -Algorithm SHA256).Hash
Get-Content .\dsh-thinkflux-0.1.0-win.zip.sha256
```

### 10.5 gh CLI 发版

```powershell
gh release create v0.1.0 `
  .\dsh-thinkflux-0.1.0-win.zip `
  .\dsh-thinkflux-0.1.0-win.zip.sha256 `
  --title "v0.1.0 — 首个公开版本" `
  --notes-file .\RELEASE_NOTES.md
```

### 10.6 发版原则

- 一个版本一个 tag，不移动已发布的 tag；
- 附件名带版本号，别叫 `latest.zip`；
- 发布后自己下载一遍，按 README 从零装一次；
- 出问题发 `0.1.1`，不要悄悄替换附件（校验和会对不上）。

---

## 11. 仓库设置

### 11.1 About

仓库首页右上角齿轮 → Edit repository details：

- Description：一句话；
- Website：可填 DSH 官网或演示页；
- Topics：`deepseek-harness`、`dsh-plugin`、`ai-visualization`、`reasoning`、
  `canvas`、`haloflux`、`windows`、`noncommercial`。

Topics 会影响搜索和推荐，别堆无关热词。

### 11.2 Social preview

Settings → General → Social preview → Upload image。

尺寸 1280×640，放标题 + 光环截图 + `dsh-thinkflux`。分享到群/推特时显示的就是它。

### 11.3 Issues

Settings → General → Features：

- Issues：开；
- Discussions：建议开，问答和展示分开；
- Sponsorships：不需要；
- Projects：不需要；
- Wiki：不需要（文档放仓库）。

### 11.4 分支保护

Settings → Branches → Add branch protection rule：

- Branch name pattern：`main`
- Require a pull request before merging（自己一个人开发可关）
- Require status checks to pass（配了 CI 再开）
- Do not allow force pushes

个人项目不必过度流程化，但 `main` 禁止 force push 是底线。

### 11.5 Issue 模板

`.github/ISSUE_TEMPLATE/bug.yml`：

```yaml
name: Bug report
description: 安装、渲染或数据链路出问题时用这个
title: "[bug] "
labels: ["bug"]
body:
  - type: markdown
    attributes:
      value: |
        请先确认：已经重启 DSH；`设置 → THINKFLUX` 存在；不是模型不下发 reasoning。
  - type: input
    id: dsh-version
    attributes:
      label: DSH 版本
      placeholder: 0.2.1-rc.2
    validations:
      required: true
  - type: input
    id: os
    attributes:
      label: 系统
      placeholder: Windows 11 23H2
    validations:
      required: true
  - type: textarea
    id: what
    attributes:
      label: 现象
      description: 做了什么、看到什么、期望什么
    validations:
      required: true
  - type: textarea
    id: logs
    attributes:
      label: 日志/截图
      description: 控制台报错、profile package.json、截图
  - type: checkboxes
    id: checks
    attributes:
      label: 自查
      options:
        - label: 我已阅读使用说明
          required: true
        - label: 我已尝试重启 DSH
          required: true
```

`.github/pull_request_template.md`：

```markdown
## 改了什么

## 为什么

## 怎么验证

- [ ] `node --check client.js`
- [ ] `node tools/test-thinking.mjs`
- [ ] `node tools/test-client.mjs`
- [ ] 在 DSH 里实际安装/重启验证

## 截图（如有 UI 变化）
```

### 11.6 SECURITY.md

```markdown
# Security Policy

## 报告漏洞

请不要公开开 Issue。发邮件到 <你的邮箱>，或在 GitHub 上使用
Security → Report a vulnerability。

## 范围

- 插件读取会话事件、渲染 Canvas、修改 profile 配置；
- 不收集遥测，不发起网络请求；
- 请勿在报告里附带真实会话内容、token 或个人信息。
```

---

## 12. 日常 Git 工作流

### 12.1 每天开始

```powershell
cd D:\dsh-workspace\release\dsh-thinkflux
git status
git pull --ff-only
```

### 12.2 改功能用分支

```powershell
git switch -c feat/thinking-rate
# 改代码
node build.mjs
node --check client.js
git add .
git commit -m "feat: smooth thinking rate decay"
git push -u origin feat/thinking-rate
```

然后在 GitHub 开 PR。哪怕是个人项目，分支 + PR 也能留下「为什么改」的记录。

### 12.3 提交信息

推荐 Conventional Commits：

```text
feat: 新功能
fix: 修 bug
docs: 文档
style: 格式（不改逻辑）
refactor: 重构
perf: 性能
test: 测试
chore: 构建/工具
```

例子：

```text
feat: drive ring text from reasoning-delta
fix: keep thought tail across SSE frames
docs: add GitHub publishing guide
```

不要写 `update`、`fix bug`、`111`。三个月后你自己也看不懂。

### 12.4 合并与清理

PR 合并后：

```powershell
git switch main
git pull --ff-only
git branch -d feat/thinking-rate
git push origin --delete feat/thinking-rate
```

### 12.5 撤销

| 场景 | 命令 |
|---|---|
| 改了没暂存 | `git restore <file>` |
| 暂存了没提交 | `git restore --staged <file>` |
| 最近一次提交没 push | `git reset --soft HEAD~1` |
| 已 push 的提交 | `git revert <sha>` |
| 改错分支还没提交 | `git switch -c rescue` |
| 想看历史 | `git log --oneline --graph --decorate -20` |

`git reset --hard` 会丢工作区改动，用之前先 `git stash` 或确认不要了。

### 12.6 冲突

```powershell
git pull --rebase
# 打开冲突文件，搜索 <<<<<<<
# 改成你想要的内容，删掉标记
git add <file>
git rebase --continue
```

冲突不是灾难，是 Git 在问你「这两段都改了，留哪个」。

---

## 13. 协作：Fork、Issue、PR

### 13.1 别人怎么贡献

1. Fork 你的仓库；
2. clone 自己的 fork；
3. 建分支、改、push；
4. 向上游开 Pull Request；
5. 你 review、跑 CI、merge。

### 13.2 你作为维护者

- 每个 Issue 至少回一句，哪怕「收到，周末看」；
- 用标签分类：`bug`、`enhancement`、`question`、`duplicate`、`wontfix`、`good first issue`；
- 不完整的报告用模板追问：DSH 版本、系统、复现步骤、日志；
- 合并前本地跑一遍测试，不要只看 CI 绿；
- 不相关的 PR 可以关，但说清楚原因。

### 13.3 PR review 看什么

- 有没有把 `node_modules`、zip、日志带进来；
- 有没有改 `LICENSE`/`NOTICE` 的署名；
- 有没有引入网络请求或遥测（本项目承诺没有）；
- `client.js` 是否和 `src/` 同步（改了 src 没重新 build 是最常见的坑）；
- 中文/英文文档是否都更新；
- Windows 脚本是否仍是 UTF-8 BOM。

---

## 14. GitHub Actions CI

### 14.1 最小可用

`.github/workflows/ci.yml`：

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "22"
      - name: Syntax check
        run: node --check client.js
      - name: Thinking channel tests
        run: node tools/test-thinking.mjs
      - name: Client registration tests
        run: node tools/test-client.mjs
      - name: Build is reproducible
        run: |
          node build.mjs
          git diff --exit-code client.js
```

最后一步很重要：如果改了 `src/` 但忘了重新生成 `client.js`，CI 会失败。

### 14.2 加 Windows 矩阵（可选）

安装脚本是 PowerShell，最好在 Windows 上验一次：

```yaml
  installer:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Parse PowerShell scripts
        shell: pwsh
        run: |
          $files = 'install.ps1','uninstall.ps1'
          foreach ($f in $files) {
            $null = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $f), [ref]$null, [ref]$null)
            if ($LASTEXITCODE -ne 0) { exit 1 }
          }
```

### 14.3 Release 自动化（进阶）

用 tag 触发，打包并上传：

```yaml
name: Release

on:
  push:
    tags: ["v*"]

permissions:
  contents: write

jobs:
  release:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build zip
        shell: pwsh
        run: |
          git archive --format=zip --output "dsh-thinkflux-${{ github.ref_name }}-win.zip" HEAD
          Get-FileHash "dsh-thinkflux-${{ github.ref_name }}-win.zip" -Algorithm SHA256 |
            ForEach-Object { "$($_.Hash)  $($_.Path | Split-Path -Leaf)" } |
            Set-Content "dsh-thinkflux-${{ github.ref_name }}-win.zip.sha256"
      - uses: softprops/action-gh-release@v2
        with:
          files: |
            dsh-thinkflux-*-win.zip
            dsh-thinkflux-*-win.zip.sha256
```

注意：

- 第三方 action 要固定大版本，敏感项目可固定 commit SHA；
- `git archive` 只打**已提交**的文件，构建产物 `client.js` 必须先提交，否则 zip 里没有；
- 更稳妥的做法是本地打包、手动上传，CI 只做测试。

### 14.4 看 CI 失败

Actions 标签页 → 点进 run → 展开红色步骤。

常见：

- `node: command not found`：没 `setup-node`；
- `git diff --exit-code` 失败：`client.js` 没重新 build；
- 测试路径大小写：Linux 区分大小写，Windows 不区分；
- 权限：`permissions: contents: read` 下不能创建 Release。

---

## 15. GitHub Pages（可选）

本项目不是 Web 应用，但可以把 `tools/preview.html` 做成在线演示：

1. 复制 `tools/preview.html` 到 `docs/index.html`；
2. 页面里标注「Mock data / 演示用，非真实会话」；
3. Settings → Pages → Build and deployment → Deploy from a branch；
4. Branch 选 `main`，目录选 `/docs`；
5. 等 1–2 分钟，访问 `https://<user>.github.io/dsh-thinkflux/`。

注意：

- Pages 是公开静态托管，**不要把真实会话日志、截图里的隐私信息放进去**；
- 演示页用假数据，别让人误以为插件在网页里就能读 DSH 会话；
- Pages 也受仓库许可约束，非商业。

---

## 16. 安全与隐私

### 16.1 不要提交

- PAT、SSH 私钥、`.env`；
- 真实会话日志、reasoning 原文、用户隐私；
- 内网地址、公司域名、本机绝对路径（安装脚本里尤其）；
- 带签名的安装包、证书。

### 16.2 如果已经提交了密钥

1. **立刻撤销**：GitHub → Settings → Developer settings → 删除 token；
2. 换新 token；
3. 清理历史：

```powershell
pip install git-filter-repo
git filter-repo --path path/to/secret --invert-paths
git push --force-with-lease
```

4. 通知所有 fork 的维护者（他们那边的历史还在）。

改历史有风险，动手前备份仓库。

### 16.3 供应链

- 本项目没有运行时 npm 依赖，攻击面小；
- 构建只用 Node 标准库；
- CI 里的第三方 action 尽量少；
- 发布附件带 SHA256；
- 不要求用户关闭杀毒软件；
- 安装脚本只改一个 profile 的 `package.json` 和 `node_modules`，不写系统目录。

### 16.4 隐私表述要诚实

README 里写「不联网」之前，确认代码里真的没有 `fetch`/`WebSocket`/`XMLHttpRequest`。
本项目已核查：`src/*.js` 无网络调用。但 DSH 自己会持久化会话，这一句也要写清楚，
否则用户会以为「不联网 = 不留痕」。

---

## 17. 国内网络与代理

### 17.1 Git 代理

```powershell
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890
```

取消：

```powershell
git config --global --unset http.proxy
git config --global --unset https.proxy
```

端口按你的代理软件改。

### 17.2 SSH 走 443

见 4.1 的 `~/.ssh/config`。

### 17.3 只对 GitHub 走代理

```powershell
git config --global http.https://github.com.proxy http://127.0.0.1:7890
```

### 17.4 不要做的事

- 不要把 token 放进代理 URL；
- 不要用来历不明的「加速镜像」push 私有仓库；
- 不要把 `http.sslVerify` 设成 `false` 图省事。

---

## 18. 推广与长期维护

### 18.1 发布后

- 在 DSH 社区/群里发一条，附截图和 Release 链接；
- 写一句「非官方、非商业、需要宿主下发 reasoning」，降低误期待；
- 不要刷 star、不要群发垃圾私信；
- 可以提交到 awesome-dsh 类列表（如果有），先读对方的收录规则。

### 18.2 Issue 分类

| 标签 | 含义 |
|---|---|
| `bug` | 可复现的错误 |
| `enhancement` | 新功能 |
| `question` | 使用问题 |
| `documentation` | 文档 |
| `duplicate` | 重复 |
| `wontfix` | 不做，说明原因 |
| `good first issue` | 适合新人 |

### 18.3 版本节奏

- 小修：随时发 `0.1.x`；
- 新功能：攒一批发 `0.x.0`；
- 破坏性改动：在 Release notes 里写「不兼容」，给迁移说明；
- DSH 大版本升级：先开 issue 记录兼容性，再发适配版。

### 18.4 CHANGELOG

Keep a Changelog 格式：

```markdown
# Changelog

## [0.1.0] - 2026-11-02

### Added
- 实时 reasoning-delta 环带文字
- 左下思考流面板
- 三档数据模式
- 一键安装/卸载脚本

### Fixed
- 修正 thinkingChars 在会话切换时的残留
```

### 18.5 弃用

不要删旧版本 Release。用户可能锁在旧 DSH 上。新版本不兼容时，在 README 写清楚
「0.2.x 需要 DSH ≥ x.y」，旧版继续可下载。

---

## 19. 常见错误速查

| 报错/现象 | 原因 | 处理 |
|---|---|---|
| `git: 无法将“git”项识别为...` | 没装或 PATH 没生效 | 重装 Git，重开终端 |
| `fatal: not a git repository` | 不在仓库目录 | `cd` 到有 `.git` 的目录 |
| `remote origin already exists` | 已配过远端 | `git remote set-url origin <url>` |
| `Updates were rejected` | 远端有新提交 | `git pull --rebase` 再 push |
| `Permission denied (publickey)` | SSH key 没加/没启动 agent | `ssh -T git@github.com` 排查 |
| `Support for password authentication was removed` | 用了账号密码 | 改用 PAT 或 SSH |
| `GH013 ... push protection` | 提交里含密钥 | 删除密钥、撤销、清理历史 |
| `file is 123.00 MB; exceeds GitHub's limit` | 单文件 >100MB | 移出仓库或用 LFS |
| `LF will be replaced by CRLF` | 换行配置冲突 | 配 `.gitattributes` |
| 中文文件名显示成 `\346\226\207` | quotepath | `git config --global core.quotepath false` |
| PowerShell 脚本中文乱码/解析失败 | 无 BOM 的 UTF-8 | 保存为 UTF-8 with BOM |
| `detached HEAD` | checkout 到某个 commit | `git switch -c <新分支>` |
| `refusing to merge unrelated histories` | 两个独立历史 | 确认后 `--allow-unrelated-histories` |
| 提交了 `node_modules` | 没先加 `.gitignore` | `git rm -r --cached node_modules` |
| 提交了 zip | 同上 | `git rm --cached *.zip`，附件放 Release |
| GitHub 显示 license 为 Other | PolyForm 不被识别 | 正常，README 写清楚 |
| Actions 里 `git diff --exit-code` 失败 | `client.js` 没重新 build | 本地 `node build.mjs` 再提交 |
| Pages 404 | 分支/目录选错，或没 index.html | 检查 Pages 设置和文件路径 |
| clone 很慢 | 仓库历史里有大文件 | `git clone --depth 1` 临时用，长期要清历史 |

---

## 20. 发版前 Checklist

发布 `dsh-thinkflux` 前逐项打勾：

### 代码

- [ ] `node build.mjs` 已跑，`client.js` 与 `src/` 同步
- [ ] `node --check client.js` 通过
- [ ] `node tools/test-thinking.mjs` 通过
- [ ] `node tools/test-client.mjs` 通过
- [ ] 在真实 DSH 里装一次、重启、看到思考流
- [ ] 在假 profile 里跑 install / uninstall
- [ ] `install.ps1` / `uninstall.ps1` 仍是 UTF-8 BOM
- [ ] `-ProfilePath` 指错目录会报错，不会误装默认 profile

### 仓库

- [ ] 没有 `node_modules`、`*.zip`、`.tmp`、日志、备份
- [ ] 没有 token、内网地址、真实会话内容
- [ ] `README.md` 的安装命令能直接复制
- [ ] `使用说明.md`、`DISCLAIMER.md` 链接有效
- [ ] `LICENSE`、`NOTICE` 完整，署名没删
- [ ] `package.json` 版本号 = tag
- [ ] `.gitignore`、`.gitattributes` 生效
- [ ] Issue 模板、PR 模板存在
- [ ] CI 绿

### Release

- [ ] tag `v0.1.0` 已推
- [ ] zip 附件 + `.sha256` 都已上传
- [ ] Release notes 写了安装、变更、限制、许可
- [ ] 自己从 Release 下载并装一遍
- [ ] About、Topics、Social preview 配好

---

## 21. 命令速查表

### 仓库

```powershell
git init
git clone <url>
git status
git remote -v
git remote add origin <url>
git remote set-url origin <url>
```

### 提交

```powershell
git add .
git add <file>
git commit -m "feat: ..."
git commit --amend
git log --oneline --graph --decorate -20
git show <sha>
git diff
git diff --staged
```

### 分支

```powershell
git branch
git switch -c feat/xxx
git switch main
git branch -d feat/xxx
git push -u origin feat/xxx
git push origin --delete feat/xxx
```

### 同步

```powershell
git pull --ff-only
git pull --rebase
git fetch --all --prune
git push
```

### 撤销

```powershell
git restore <file>
git restore --staged <file>
git reset --soft HEAD~1
git revert <sha>
git stash
git stash pop
```

### 标签与发布

```powershell
git tag -a v0.1.0 -m "v0.1.0"
git push origin v0.1.0
gh release create v0.1.0 .\dsh-thinkflux-0.1.0-win.zip .\dsh-thinkflux-0.1.0-win.zip.sha256 --title "v0.1.0" --notes-file RELEASE_NOTES.md
```

### 排查

```powershell
git config --global --list
git ls-files
git count-objects -vH
git check-ignore -v <file>
ssh -T git@github.com
gh auth status
```

---

## 22. 附录：本项目目录与链接

### 22.1 本地路径

| 内容 | 路径 |
|---|---|
| 发布候选目录 | `D:\dsh-workspace\dist\dsh-thinkflux-0.1.0` |
| 安装包 | `D:\dsh-workspace\dist\dsh-thinkflux-0.1.0-win.zip` |
| 校验和 | `D:\dsh-workspace\dist\dsh-thinkflux-0.1.0-win.zip.sha256` |
| 工作区源码 | `D:\dsh-workspace\dsh-thinkflux` |
| 使用说明 | `使用说明.md` |
| 免责声明 | `DISCLAIMER.md` |

### 22.2 关键文件

- `client.js`：打包后的客户端，DSH 启动时加载；
- `src/live.js`：会话事件 → 思考词流；
- `src/engine.js`：光环渲染、思考节奏；
- `src/hud.js`：KPI、思考流、工具面板；
- `src/mount.js`：注册 `shell.overlay` / `settings.section`；
- `install.ps1`：复制、改 profile、可选重启；
- `tools/test-thinking.mjs`：思考通道回归测试；
- `tools/test-client.mjs`：bundle 注册与 locale 测试。

### 22.3 参考链接

- GitHub Docs：https://docs.github.com
- Git 官方文档：https://git-scm.com/doc
- GitHub Skills：https://skills.github.com
- Conventional Commits：https://www.conventionalcommits.org
- Keep a Changelog：https://keepachangelog.com
- Semantic Versioning：https://semver.org
- PolyForm Noncommercial：https://polyformproject.org/licenses/noncommercial/1.0.0
- HALOFLUX：https://github.com/Ryder191/haloflux

---

## 最后三句

1. **先备份，再折腾。** 改 profile、改历史、force push 之前都留一份。
2. **能复现再开 Issue。** 版本、系统、步骤、日志，四样齐全，别人才能帮你。
3. **别把「能跑」当「稳定」。** 发版前从 Release 下载、从零装一遍，比任何自测都真实。
