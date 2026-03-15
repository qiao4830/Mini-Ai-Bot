# Mini-Ai-Bot
Mini-AI-Bot 🤖 专为 1G 内存 VPS 优化的轻量级多模型 Telegram 机器人。Optimized for low-end VPS, supports Gemini 2.5, DeepSeek &amp; GPT-4o.
# ⚓ Mini-AI-Bot V4.1 (Flagship Edition)

![License](https://img.shields.io/badge/license-MIT-blue)
![Python](https://img.shields.io/badge/python-3.8%2B-green)
![RAM](https://img.shields.io/badge/RAM-1G%20Optimized-orange)

**Mini-AI-Bot** 是一款专为 **1G 内存** 甚至更低配 VPS 深度优化的多模态 AI Telegram 机器人。它抛弃了臃肿的中间件，采用原生 Python 异步架构，实现了极低资源占用与极速流式响应。

---

## ✨ 核心亮点 (V4.1)

- **🚀 全链路流式回复**：无论是 Gemini、DeepSeek 还是 GPT-4o，全部支持打字机般的流式输出。
- **📦 venv 虚拟环境**：自动创建独立运行空间，不污染系统环境，安装/卸载均“零残留”。
- **🛡️ 智能日志滚动**：内置日志管理，满 1MB 自动覆盖，物理隔离“日志塞爆硬盘”的风险。
- **🔒 密钥安全隔离**：API Key 存放在隐藏的 `.env` 文件中，确保源码分享时的安全性。
- **⚡ 异步并发优化**：专为低内存 VPS 调优，多用户同时对话不卡顿、不爆内存。

## 🛠️ 一键起航 (极速部署)

在你的 VPS 终端执行以下命令（请将链接中的 `你的用户名` 替换为实际名称）：

```bash
wget -N [https://raw.githubusercontent.com/你的用户名/Mini-AI-Bot/main/minibot.sh](https://raw.githubusercontent.com/你的用户名/Mini-AI-Bot/main/minibot.sh) && bash minibot.sh
