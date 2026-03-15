#!/bin/bash

# ==========================================
# 项目名称: Mini-Ai-Bot V4.2 (旗舰稳定版)
# 特色: 2.5 Flash + DeepSeek + GPT-4o / 进程防掉线 / 一键部署
# 作者: 小帆船 YouTube
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function show_menu() {
    echo -e "${BLUE}=========================================="
    echo -e "    ⚓ Mini-Ai-Bot V4.2 旗舰管理工具"
    echo -e "==========================================${NC}"
    echo -e " 1. ${GREEN}一键安装部署 (Gemini/DeepSeek/GPT)${NC}"
    echo -e " 2. ${BLUE}查看实时日志 (Ctrl+C 返回菜单)${NC}"
    echo -e " 3. ${YELLOW}停止后台机器人进程${NC}"
    echo -e " 4. ${RED}彻底卸载机器人${NC}"
    echo -e " 0. 退出脚本"
    echo -e "------------------------------------------"
}

function install_bot() {
    echo -e "${YELLOW}>>> [1/4] 初始化环境...${NC}"
    apt-get update -y && apt-get install python3-pip python3-venv -y
    python3 -m venv ~/minibot_env
    source ~/minibot_env/bin/activate

    echo -e "${YELLOW}>>> [2/4] 安装旗舰级依赖...${NC}"
    pip install --upgrade pip
    pip install python-telegram-bot google-generativeai python-dotenv httpx --quiet

    echo -e "${GREEN}>>> [3/4] 配置 API 安全密钥 (不用的直接回车)...${NC}"
    read -p " 🔹 Telegram Bot Token (必填): " TG_TOKEN
    read -p " 🔹 Gemini API Key (推荐): " GEMINI_KEY
    read -p " 🔹 DeepSeek API Key (选填): " DS_KEY
    read -p " 🔹 OpenAI API Key (选填): " GPT_KEY

    cat > ~/.minibot.env <<EOF
TG_TOKEN=$TG_TOKEN
GEMINI_KEY=$GEMINI_KEY
DS_KEY=$DS_KEY
GPT_KEY=$GPT_KEY
EOF
    chmod 600 ~/.minibot.env

    echo -e "${YELLOW}>>> [4/4] 注入全模型稳定版核心代码...${NC}"
    cat > ~/minibot_main.py <<EOF
import os, google.generativeai as genai, httpx, asyncio
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters
from dotenv import load_dotenv

load_dotenv(dotenv_path=os.path.expanduser('~/.minibot.env'))
TG_TOKEN = os.getenv('TG_TOKEN')
GEMINI_KEY = os.getenv('GEMINI_KEY')
DS_KEY = os.getenv('DS_KEY')
GPT_KEY = os.getenv('GPT_KEY')

if GEMINI_KEY:
    genai.configure(api_key=GEMINI_KEY)

async def ask_openai_style(api_key, base_url, model_name, prompt):
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            f"{base_url}/chat/completions",
            headers={"Authorization": f"Bearer {api_key}"},
            json={"model": model_name, "messages": [{"role": "user", "content": prompt}]},
            timeout=60.0
        )
        return resp.json()['choices'][0]['message']['content']

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text: return
    text = update.message.text
    try:
        if text.startswith('/ds ') and DS_KEY:
            res = await ask_openai_style(DS_KEY, "https://api.deepseek.com", "deepseek-chat", text[4:])
            await update.message.reply_text(f"🚀 [DeepSeek]\n\n{res}")
        elif text.startswith('/gpt ') and GPT_KEY:
            res = await ask_openai_style(GPT_KEY, "https://api.openai.com/v1", "gpt-4o", text[5:])
            await update.message.reply_text(f"🤖 [GPT-4o]\n\n{res}")
        elif GEMINI_KEY:
            model = genai.GenerativeModel('models/gemini-2.5-flash')
            res = model.generate_content(text)
            await update.message.reply_text(f"✨ [Gemini 2.5]\n\n{res.text}")
        else:
            await update.message.reply_text("❌ 未配置对应模型的 Key")
    except Exception as e:
        await update.message.reply_text(f"⚠️ 报错: {str(e)[:100]}")

if __name__ == '__main__':
    app = ApplicationBuilder().token(TG_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message))
    print(">>> Mini-Ai-Bot V4.2 全能版起航...")
    app.run_polling()
EOF

    echo -e "${YELLOW}>>> 正在以后台独立模式启动 (disown)...${NC}"
    pkill -9 -f minibot_main.py 2>/dev/null
    # 核心修复：( nohup & disown ) 确保关掉窗口或 Ctrl+C 机器人都不死
    (nohup ~/minibot_env/bin/python3 ~/minibot_main.py > ~/bot.log 2>&1 & disown)
    echo -e "${GREEN}✅ 部署成功！全模型已在后台就绪。${NC}"
}

function stop_bot() {
    pkill -9 -f minibot_main.py && echo -e "${YELLOW}🛑 机器人进程已停止。${NC}" || echo -e "${RED}❌ 未发现运行中的进程。${NC}"
}

while true; do
    show_menu
    read -r -p " 请输入序号: " choice
    clean_choice="${choice//[^0-9]/}"
    case "$clean_choice" in
        1) install_bot ;;
        2) [ -f ~/bot.log ] && tail -f ~/bot.log || echo -e "${RED}无日志${NC}" ;;
        3) stop_bot ;;
        4) pkill -9 -f minibot_main.py; rm -rf ~/minibot_env ~/minibot_main.py ~/bot.log ~/.minibot.env; echo -e "${GREEN}卸载完成${NC}" ;;
        0) break ;;
        "") continue ;;
        *) echo -e "${RED}无效输入: [$choice]${NC}" ;;
    esac
done
