# ⚓ Mini-Ai-Bot V4.4 旗舰版

**一套代码，三重人格。在 1G 内存小鸡上跑出顶级 AI 体验。**

本项目由 YouTube **[小帆船]** 频道实战研发。针对 2026 年最新的模型 ID 变更、API 兼容性及 VPS 进程掉线等痛点进行了全方位加固。

---

## 🌟 核心亮点 (Technical Features)

* **🚀 全链路流式体验**：不管是 Gemini 还是 DeepSeek，全部支持如打字机般的流式交互体验。
* **🛡️ 永不下线守护**：采用 `setsid` 会话隔离技术，彻底解决“退出终端机器人即下线”的世纪难题。
* **📦 venv 虚拟环境**：自动创建独立运行空间，不污染系统环境，安装/卸载均实现“零残留”。
* **🔒 密钥安全隔离**：API Key 存放在隐藏的 `.env` 文件中，确保源码分享或录屏时的安全性。
* **⚡ 异步并发优化**：专为低内存 VPS 调优，采用 Python 异步驱动，多用户对话不卡顿、不爆内存。
* **📖 自动诊断纠错**：API 报错不再弹乱码！自动识别“余额不足”或“Key 错误”，让排错一目了然。

---

## 🛠️ 一键部署指令

在你的 VPS 终端执行以下命令（推荐 Debian/Ubuntu）：

```bash
wget -N [https://raw.githubusercontent.com/你的GitHub用户名/Mini-Ai-Bot/main/minibot.sh](https://raw.githubusercontent.com/你的GitHub用户名/Mini-Ai-Bot/main/minibot.sh) && bash minibot.sh



