# 免责声明 / Disclaimer

本文件适用于 **dsh-thinkflux**（下称“本项目”）。下载、安装、使用、修改或再分发本项目，
即视为你已阅读并同意以下内容。不同意就不要用。

## 1. 非官方项目

本项目是社区二次创作，与 **DeepSeek**、**HALOFLUX** 作者 **Ryder191**、
**dsh-haloflux** 作者 **Ke-wood** 均无隶属、授权、合作或背书关系。
相关名称、商标、产品权益归各自所有者。本项目不代表任何官方立场。

## 2. 按“现状”提供，无担保

本项目按 **AS IS** 提供，不附带任何明示或默示担保，包括但不限于适销性、
特定用途适用性、无侵权、无中断、无错误。它可能：

- 随 DeepSeek Harness 升级而失效或行为改变；
- 在部分显卡/驱动/浏览器上掉帧、闪烁、渲染异常；
- 与其他插件或主题冲突；
- 因宿主 API 变化而读不到思考流。

是否可用、是否稳定，需要你自己在目标环境里验证。

## 3. 非商业许可

本项目沿用 **PolyForm Noncommercial 1.0.0**，仅允许非商业用途。
**它不是 OSI 开源许可**，不要对外描述为 MIT / Apache / “开源可商用”。
再分发必须保留 `LICENSE` 与 `NOTICE` 中的原作者署名；商业使用需另行获得授权，
而原作者并未提供商业授权。

## 4. 数据与隐私

- 插件只读取**当前 DSH 会话**的事件流（`reasoning-delta`、工具调用、用量等），
  不主动遍历其他会话；
- 思考文本只在内存中短暂保留，用于画面和左下思考面板，不写入插件自己的文件；
- 插件本身没有 `fetch` / WebSocket / 外部上报；
- **但 DSH 自身会持久化会话日志**，那部分由 DSH 管理，不在本项目控制范围内；
- 屏幕共享、录屏、直播、截图可能暴露模型的内部推理。是否展示、展示给谁，
  由使用者自行判断并承担后果。

## 5. 使用后果自负

因安装、配置、使用或无法使用本项目而导致的任何直接或间接损失——包括但不限于
数据丢失、会话中断、profile 损坏、插件冲突、账号或 API 费用、设备损伤、
合规风险、名誉损失——作者及贡献者不承担任何责任。

本项目会修改 DSH profile 的 `package.json` 和 `node_modules`。安装脚本虽会备份，
仍建议你先备份 profile，或先在测试 profile 里试。卸载不保证恢复你此前的所有自定义改动。

## 6. 合规使用

使用者应自行确保使用行为符合所在地法律、DeepSeek Harness 与模型供应商条款、
GitHub 条款及所在组织规定。不得将本项目用于违法、侵权、骚扰、欺骗、
规避安全机制或误导他人的用途。

尤其注意：**不要把可视化效果当成“AI 已验证 / 已思考正确”的证据**。
它展示的是模型输出的推理文本，不是事实核查，也不代表结论正确。

## 7. 第三方内容

光环构图、光束、数据面板语言、配色与音频等来自 **HALOFLUX**，版权归原作者；
本项目的改造部分（DSH 适配、思考通道、HUD）按同一非商业许可发布。
第三方组件与素材的许可见 `LICENSE`、`NOTICE` 及原仓库说明。

## 8. 变更

本免责声明可能随版本更新。以仓库中最新版本为准；继续使用即视为接受更新后的版本。

---

## English summary

**dsh-thinkflux** is an unofficial, community-made visualization plugin for
DeepSeek Harness. It is **not affiliated with or endorsed by** DeepSeek, Ryder191
(HALOFLUX), or Ke-wood (dsh-haloflux).

Provided **as is**, without warranty of any kind. It may break with DSH updates,
conflict with other plugins, or fail to render on some hardware. Use at your own risk.

Licensed under **PolyForm Noncommercial 1.0.0** — **not** an OSI open-source license.
Noncommercial use only; redistribution must keep `LICENSE` and `NOTICE`.
No commercial license is offered by the original author.

The plugin reads the **current session's** event stream and keeps reasoning text
in memory only. It makes no network requests. DSH itself persists session logs;
that is outside this project's control. You are responsible for not exposing
sensitive reasoning via screen sharing, recording, or streaming.

The authors accept **no liability** for data loss, broken profiles, costs,
damages, or compliance issues arising from use of this project. Do not present
the visualization as proof that an AI's output is correct or verified.
