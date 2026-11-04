# THINKFLUX · 实时思考光环

**THINKFLUX**（包名 `dsh-thinkflux`）—— 把 HALOFLUX 的光环引擎改造成 DeepSeek Harness 的**实时思考可视化**插件：模型每吐一段 `reasoning-delta`，光环面板就换成那段真实思考文字。

小西鱼的仓库，同时也是这个插件的源码与发行页。

## 仓库结构

| 路径 | 内容 |
|---|---|
| [`dsh-thinkflux-0.1.0/`](dsh-thinkflux-0.1.0/) | 插件源码（0.1.0），含 `src/`、`build.mjs`、安装脚本与自测 |
| [`dsh-thinkflux-0.1.0-win.zip`](dsh-thinkflux-0.1.0-win.zip) | Windows 发行包，解压后双击 `install.cmd` |
| [`dsh-thinkflux-0.1.0-win.zip.sha256`](dsh-thinkflux-0.1.0-win.zip.sha256) | 发行包校验值（SHA-256 与 zip 实测一致） |
| [`使用说明.md`](使用说明.md) | 使用说明 |
| [`GitHub使用指南.md`](GitHub使用指南.md) | 发布/协作相关的 GitHub 操作说明 |
| [`DISCLAIMER.md`](DISCLAIMER.md) | 免责声明 |

插件本身的原理、参数、安装与自测，看 [`dsh-thinkflux-0.1.0/README.md`](dsh-thinkflux-0.1.0/README.md)。

## 安装（Windows 一键）

1. 下载 `dsh-thinkflux-0.1.0-win.zip`，可用 `.sha256` 先校验；
2. 解压后双击 `install.cmd`（或跑 `install.ps1`）；
3. 脚本会把运行时文件装进 DSH profile 的 `node_modules\dsh-thinkflux`，写进依赖与 `dsh.profile.bundles`，改前备份 `package.json`，最后询问是否重启 DSH。

## 许可

本项目是 [HALOFLUX](https://github.com/Ryder191/haloflux) 的二次创作，沿用 **PolyForm Noncommercial 1.0.0**：可以阅读、修改、非商业使用与分发，**不可商用**；再分发须保留 `LICENSE` 与 `NOTICE`。

**这不是 OSI 开源许可。** 对外请描述为「source-available / 非商业许可」。

## Credits

- 原作：HALOFLUX by Ryder191 — <https://github.com/Ryder191/haloflux>
- DSH 移植基础：dsh-haloflux by Ke-wood
- 本项目：思考通道、`think` 面板、思考节奏与 HUD 改造
