#!/bin/bash

# ==========================================
# 项目名称: Mini-Ai-Bot V4.4 (旗舰实战版)
# 项目特色: 2.5 Flash / 多模型切换 / 永不下线守护
# 作者: 小帆船 YouTube (@cnxiaofanchuan)
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function show_menu() {
    clear
    echo -e "${BLUE}=========================================="
    echo -e "    ⚓ Mini-Ai-Bot V4.4 旗舰管理工具"
    echo -e "==========================================${NC}"
    echo -e " 1. ${GREEN}一键安装部署 (Gemini/DeepSeek/GPT)${NC}"
    echo -e " 2. ${BLUE}查看实时日志 (Ctrl+C 返回菜单)${NC}"
    echo -e " 3. ${YELLOW}停止后台机器人进程${NC}"
    echo -e " 4. ${RED}彻底卸载机器人${NC}"
    echo -e " 0. 退出脚本"
    echo -e "------------------------------------------"
}

function install_bot() {
    echo -e "${YELLOW}>>> [1/4] 初始化 Python 环境...${NC}"
    apt-get update -y && apt-get install python3-pip python3-venv -y
    python3 -m venv ~/minibot_env
    source ~/minibot_env/bin/activate

    echo -e "${YELLOW}>>> [2/4] 安装核心依赖库...${NC}"
    pip install --upgrade pip
    pip install python-telegram-bot google-generativeai python-dotenv httpx --quiet

    echo -e "${GREEN}>>> [3/4] 配置 API 安全密钥...${NC}"
    read -p " 🔹 Telegram Token (必填): " TG_TOKEN
    read -p " 🔹 Gemini Key (推荐): " GEMINI_KEY
    read -p " 🔹 DeepSeek Key (选填): " DS_KEY
    read -p " 🔹 OpenAI Key (选填): " GPT_KEY

    cat > ~/.minibot.env <<EOF
TG_TOKEN=$TG_TOKEN
GEMINI_KEY=$GEMINI_KEY
DS_KEY=$DS_KEY
GPT_KEY=$GPT_KEY
EOF
    chmod 600 ~/.minibot.env

    echo -e "${YELLOW}>>> [4/4] 注入全能加固版 Python 核心...${NC}"
    cat > ~/minibot_main.py <<EOF
import os, google.generativeai as genai, httpx, asyncio
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters
from dotenv import load_dotenv

# 加载配置
load_dotenv(dotenv_path=os.path.expanduser('~/.minibot.env'))
TG_TOKEN = os.getenv('TG_TOKEN')
GEMINI_KEY = os.getenv('GEMINI_KEY')
DS_KEY = os.getenv('DS_KEY')
GPT_KEY = os.getenv('GPT_KEY')

if GEMINI_KEY:
    genai.configure(api_key=GEMINI_KEY)

async def ask_openai_style(api_key, base_url, model_name, prompt):
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.post(
                f"{base_url}/chat/completions",
                headers={"Authorization": f"Bearer {api_key}"},
                json={"model": model_name, "messages": [{"role": "user", "content": prompt}]},
                timeout=60.0
            )
            data = resp.json()
            if 'choices' in data:
                return data['choices'][0]['message']['content']
            elif 'error' in data:
                return f"❌ API报错: {data['error'].get('message', '检查余额或Key')}"
            return f"❓ 接口异常: {data}"
        except Exception as e:
            return f"📡 网络故障: {e}"

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text: return
    text = update.message.text
    cmd_lower = text.lower()
    
    try:
        # DeepSeek 识别 (兼容 /ds /ds+内容)
        if cmd_lower.startswith('/ds'):
            prompt = text[3:].strip()
            if not prompt: prompt = "你好"
            if not DS_KEY: return await update.message.reply_text("未配置 DeepSeek Key")
            res = await ask_openai_style(DS_KEY, "https://api.deepseek.com", "deepseek-chat", prompt)
            return await update.message.reply_text(f"🚀 [DeepSeek]\n\n{res}")

        # GPT 识别 (兼容 /gpt /gpt+内容)
        if cmd_lower.startswith('/gpt'):
            prompt = text[4:].strip()
            if not prompt: prompt = "你好"
            if not GPT_KEY: return await update.message.reply_text("未配置 OpenAI Key")
            res = await ask_openai_style(GPT_KEY, "https://api.openai.com/v1", "gpt-4o", prompt)
            return await update.message.reply_text(f"🤖 [GPT-4o]\n\n{res}")

        # 默认使用 Gemini 2.5 Flash
        if GEMINI_KEY:
            model = genai.GenerativeModel('models/gemini-2.5-flash')
            res = model.generate_content(text)
            await update.message.reply_text(f"✨ [Gemini 2.5]\n\n{res.text}")
        else:
            await update.message.reply_text("❌ 未配置 Gemini Key，请使用指令切换模型")
    except Exception as e:
        await update.message.reply_text(f"⚠️ 系统异常: {str(e)[:100]}")

if __name__ == '__main__':
    print(">>> Mini-Ai-Bot V4.4 监听中...")
    app = ApplicationBuilder().token(TG_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message))
    app.run_polling()
EOF

    echo -e "${YELLOW}>>> 启动会话隔离守护模式 (setsid)...${NC}"
    pkill -9 -f minibot_main.py 2>/dev/null
    # 使用 setsid 确保机器人彻底脱离当前 Shell 会话
    setsid ~/minibot_env/bin/python3 ~/minibot_main.py > ~/bot.log 2>&1 &
    sleep 2
    echo -e "${GREEN}✅ 部署成功！您可以退出终端，机器人将持续运行。${NC}"
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

function stop_bot() {
    pkill -9 -f minibot_main.py && echo -e "${YELLOW}🛑 机器人进程已停止。${NC}" || echo -e "${RED}❌ 未发现运行中的进程。${NC}"
    read -n 1 -s -r -p "按任意键返回主菜单..."
}

while true; do
    show_menu
    read -r -p " 请输入序号: " choice
    # 清理输入，只留数字
    clean_choice="${choice//[^0-9]/}"
    case "$clean_choice" in
        1) install_bot ;;
        2) 
            if [ -f ~/bot.log ]; then
                echo -e "${YELLOW}>>> 正在进入日志监控 (按 Ctrl+C 退出并返回菜单)...${NC}"
                tail -f ~/bot.log
            else
                echo -e "${RED}❌ 无日志文件，请先运行安装！${NC}"
                read -n 1 -s -r -p "按任意键返回..."
            fi
            ;;
        3) stop_bot ;;
        4) 
            pkill -9 -f minibot_main.py 2>/dev/null
            rm -rf ~/minibot_env ~/minibot_main.py ~/bot.log ~/.minibot.env
            echo -e "${GREEN}🗑️  卸载完成，环境已清理。${NC}"
            read -n 1 -s -r -p "按任意键返回..."
            ;;
        0) break ;;
        "") continue ;;
        *) echo -e "${RED}❌ 无效输入: [$choice]${NC}"; sleep 1 ;;
    esac
done
