# THINKFLUX · 实时思考光环

把 [HALOFLUX](https://github.com/Ryder191/haloflux) 的光环引擎改造成 **DeepSeek Harness 的思考监视器**：
模型每吐出一段 `reasoning-delta`，环带上的面板就换成那段真实思考文字；环的闪动、光束脉冲和镜头
节奏也由思考流驱动，而不是音乐节拍或随机数。

> 这是 HALOFLUX 的二次创作。原作的构图、光束、数据面板语言与配色仍按
> **PolyForm Noncommercial 1.0.0** 授权，仅限非商业使用；再分发必须保留
> `LICENSE` 与 `NOTICE`。DSH 适配、思考通道与 HUD 为本项目新增。
>
> **注意：PolyForm Noncommercial 不是 OSI 开源许可。** 你可以公开源码、修改和非商业使用，
> 但不能商用；对外描述请用「source-available / 非商业许可」，别写「MIT/Apache 开源」。

---

## 一、和原版 dsh-haloflux 的区别

| | dsh-haloflux | dsh-thinkflux |
|---|---|---|
| 文字来源 | 回答文本 `text-delta` | **思考文本 `reasoning-delta`** |
| 环上刷新时机 | 音乐节拍 / 随机数 | **思考增量到达时** |
| KPI | 词元 / tok/s | **思考字数 / 字每秒** |
| 可读层 | 底部词元流 | **思考流面板 + 事件流 + 工具调度** |
| 默认档位 | 混合 30% | **只看思考（`dataMode=2`）** |

回答文本仍保留在 `recentText` 里作为兜底，但默认不再上海环。

## 二、数据链路

```text
DSH session eventSource
  ├─ transient  assistant/live-chunk
  │    ├─ reasoning-delta {index,text} ──► emitThought()
  │    │      ├─ 按标点/每 10 字切短语 ─► thoughtQueue ─► 引擎 pullThoughts()
  │    │      ├─ 原文尾部 240 字 ───────► recentThoughtText ─► HUD 思考面板
  │    │      └─ 字符速率（2s 滑窗）────► thinkingRate
  │    ├─ text-delta  ──► 回答词元通道（兜底，默认不上海环）
  │    └─ tool-call-delta / usage / finish
  └─ durable  turn/step、tool/call、tool/result、assistant/message
```

关键点：

1. **思考与回答分开计数**。`reasoning-delta` 进 `thoughtQueue` / `thinkingChars`，
   `text-delta` 进 `tokenQueue` / `totalTokens`，互不污染 tok/s。
2. **不重复计数**。durable `assistant/message` 是流式帧的结算，不会再次计入；
   只有实时 append 的 transient 帧才增加思考字数。
3. **有兜底**。如果宿主只给结算后的 reasoning block、不给流式 delta，
   `assistant/message` 里的 reasoning 会在 `thinkingChars === 0` 时补一次展示（不计速率）。
4. **刷新有节流**。思考增量先累积，引擎每 110ms 最多批量失效 3 块面板，
   避免每个 token 都重绘导致掉帧。

## 三、界面

- **光环**：默认 `dataMode=2`，环带面板只画 `THINK / STEP / TURN` 与真实思考片段；
  新的思考到达时批量换字、闪光，工具调用/step 切换触发脉冲。
- **思考面板**（左下、事件流上方）：实时滚动最近 320 字，带闪烁光标；这是主要可读层，
  环上的 3.5px 文字是氛围层。
- **KPI 条**：`THINKING / THINK 字数 / 字每秒 / 上下文 / STEP / TOOLS`。
- **事件流 + 工具调度**：turn/step、用户消息、工具调用与结果。
- 快捷键：`C` 参数控制台，`H` HUD 开关，`Esc` 关闭控制台。

## 四、参数

- `dataMode`：`0` 纯动画（原版合成样例）、`1` 混合、`2` 只看思考（默认）。
- 思考相关没有新增滑杆，刷新频率由 `dataFlicker` 间接控制。
- 其余 79 个视觉参数与 dsh-haloflux 相同，设置页在 **设置 → THINKFLUX**。

## 五、安装

### Windows 一键安装（普通用户）

下载 release zip，解压后双击 `install.cmd`。它会：

1. 自动找 `DSH_PROFILE_DIR` / `DSH_HOME\profiles\desktop` / `~\.dsh\profiles\desktop`；
2. 把运行时文件复制到 `<profile>\node_modules\dsh-thinkflux`；
3. 把 `dsh-thinkflux` 写进 profile 的依赖和 `dsh.profile.bundles`，改前自动备份 `package.json`；
4. 校验 JSON，然后询问是否重启 DSH。

命令行用法：

```powershell
.\install.ps1                      # 自动检测 profile，询问是否重启
.\install.ps1 -NoRestart           # 只安装
.\install.ps1 -ProfilePath "D:\dsh\profiles\desktop" -Restart
.\uninstall.ps1                    # 卸载（同样会备份 package.json）
```

> 脚本改的是 profile 的 `package.json` 与 `node_modules`，属于持久化配置；卸载不会删除备份。
> 如果 DSH 版本自带 `plugin_manager`，优先用它。

### 用 plugin_manager（DSH 自带工具）

```powershell
# 构建单文件 client.js
node build.mjs
node --check client.js

plugin_manager install_bundle target=D:\path\to\dsh-thinkflux
```

### 手工安装

1. 把本包复制到 `<profile>/node_modules/dsh-thinkflux`；
2. 在 profile 的 `package.json` 依赖里加 `"dsh-thinkflux": "file:./node_modules/dsh-thinkflux"`；
3. 把 `"dsh-thinkflux"` 加进 `dsh.profile.bundles`；
4. 重启 DSH（客户端 bundle 在宿主启动时组装）。

卸载：从 `dsh.profile.bundles` 和依赖里移除，删除 `node_modules/dsh-thinkflux`，重启。


## 六、自测

```powershell
node tools/test-thinking.mjs   # 思考通道：切词、速率、防重复计数、finish 冲刷
```

`tools/preview.html` 是一个不依赖 DSH 的引擎预览：用模拟思考流驱动光环，
浏览器直接打开即可看构图与刷新节奏。

## 七、已知限制

- 中文在环带上以 3.5px 微字渲染，只适合远看纹理；要读内容看左下思考面板。
- 思考流是否可见取决于宿主是否下发 `reasoning-delta`。若模型/供应商不返回 reasoning，
  面板会退到回答文本或保持空态。
- 许可为非商业；不得用于商业产品。

## 八、Credits

- 原作：**HALOFLUX** by Ryder191 — https://github.com/Ryder191/haloflux
- DSH 移植基础：**dsh-haloflux** by Ke-wood
- 本项目：思考通道、`think` 面板、思考节奏与 HUD 改造
