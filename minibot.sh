#!/bin/bash

# ==========================================
# 项目名称: Mini-AI-Bot V4.1 (GitHub 旗舰版)
# 特色: 自动化编码修正 / 虚拟环境隔离 / 异步流式回复
# 作者: 小帆船 YouTube
# ==========================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 核心：解决 Windows 编辑导致的“无效输入”报错
function show_menu() {
    echo -e "${BLUE}=========================================="
    echo -e "    ⚓ Mini-AI-Bot V4.1 旗舰管理工具"
    echo -e "==========================================${NC}"
    echo -e " 1. ${GREEN}一键安装部署 (含 venv 隔离环境)${NC}"
    echo -e " 2. ${BLUE}查看实时运行日志 (滚动管理)${NC}"
    echo -e " 3. ${YELLOW}停止后台机器人进程${NC}"
    echo -e " 4. ${RED}彻底卸载机器人 (清空一切配置)${NC}"
    echo -e " 0. 退出脚本"
    echo -e "------------------------------------------"
    read -p " 请输入序号: " raw_choice
    # 过滤可能存在的回车符 \r
    choice=$(echo "$raw_choice" | tr -d '\r')
}

function install_bot() {
    echo -e "${YELLOW}>>> [1/4] 初始化 Python 虚拟环境...${NC}"
    apt-get update -y && apt-get install python3-pip python3-venv -y
    python3 -m venv ~/minibot_env
    source ~/minibot_env/bin/activate

    echo -e "${YELLOW}>>> [2/4] 安装旗舰级依赖 (含异步流处理)...${NC}"
    pip install --upgrade pip
    pip install python-telegram-bot google-generativeai httpx python-dotenv tenacity --quiet

    echo -e "${GREEN}>>> [3/4] 配置多模型 API 安全密钥...${NC}"
    read -p " 🔹 Telegram Bot Token (必填): " TG_TOKEN
    read -p " 🔹 Gemini API Key (选填): " GEMINI_KEY
    read -p " 🔹 DeepSeek API Key (选填): " DS_KEY
    read -p " 🔹 OpenAI API Key (选填): " GPT_KEY

    cat > ~/.minibot.env <<EOF
TG_TOKEN=$TG_TOKEN
GEMINI_KEY=$GEMINI_KEY
DS_KEY=$DS_KEY
GPT_KEY=$GPT_KEY
EOF
    chmod 600 ~/.minibot.env

    echo -e "${YELLOW}>>> [4/4] 正在注入 V4.1 旗舰核心代码...${NC}"
    # 直接下载或生成 Python 主程序
    cat > ~/minibot_main.py <<'EOF'
import os, asyncio, google.generativeai as genai, httpx, logging, json
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters
from dotenv import load_dotenv
from logging.handlers import RotatingFileHandler

# 🛡️ 日志滚动配置
log_path = os.path.expanduser('~/bot.log')
handler = RotatingFileHandler(log_path, maxBytes=1*1024*1024, backupCount=1)
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(message)s', handlers=[handler])

load_dotenv(dotenv_path=os.path.expanduser('~/.minibot.env'))
TG_TOKEN = os.getenv('TG_TOKEN')
GEMINI_KEY = os.getenv('GEMINI_KEY')
DS_KEY = os.getenv('DS_KEY')
GPT_KEY = os.getenv('GPT_KEY')

if GEMINI_KEY:
    genai.configure(api_key=GEMINI_KEY)

async def ask_openai_stream(api_key, base_url, model_name, prompt, placeholder):
    full_res = ""
    counter = 0
    async with httpx.AsyncClient() as client:
        try:
            async with client.stream(
                "POST", f"{base_url}/chat/completions",
                headers={"Authorization": f"Bearer {api_key}"},
                json={"model": model_name, "messages": [{"role": "user", "content": prompt}], "stream": True},
                timeout=60.0
            ) as response:
                async for line in response.aiter_lines():
                    if line.startswith("data: "):
                        data = line[6:]
                        if data == "[DONE]": break
                        try:
                            chunk = json.loads(data)['choices'][0]['delta'].get('content', '')
                            full_res += chunk
                            counter += 1
                            if counter % 8 == 0: 
                                await placeholder.edit_text(f"🚀 [{model_name} 传输中...]\n\n{full_res}")
                        except: pass
            await placeholder.edit_text(f"🚀 [{model_name}]\n\n{full_res}")
        except Exception as e:
            await placeholder.edit_text(f"⚠️ 接口响应异常: {e}")

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text: return
    user_text = update.message.text
    placeholder = await update.message.reply_text("🚢 Mini-AI 正在思考...")

    try:
        if user_text.startswith('/ds ') and DS_KEY:
            await ask_openai_stream(DS_KEY, "https://api.deepseek.com", "deepseek-chat", user_text[4:], placeholder)
        elif user_text.startswith('/gpt ') and GPT_KEY:
            await ask_openai_stream(GPT_KEY, "https://api.openai.com/v1", "gpt-4o", user_text[5:], placeholder)
        elif GEMINI_KEY:
            model = genai.GenerativeModel('models/gemini-2.0-flash')
            response = await model.generate_content_async(user_text, stream=True)
            full_res = ""
            count = 0
            async for chunk in response:
                full_res += chunk.text
                count += 1
                if count % 5 == 0:
                    try: await placeholder.edit_text(f"✨ [Gemini 流式中...]\n\n{full_res}")
                    except: pass
            await placeholder.edit_text(f"✨ [Gemini 2.0]\n\n{full_res}")
        else:
            await placeholder.edit_text("❌ 对应模型的 API Key 未配置。")
    except Exception as e:
        logging.error(f"Error: {e}")
        await placeholder.edit_text(f"⚠️ 航线波动: {str(e)[:100]}...")

if __name__ == '__main__':
    if not TG_TOKEN: exit("Error: TG_TOKEN missing")
    app = ApplicationBuilder().token(TG_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message))
    print(">>> Mini-AI-Bot V4.1 已成功起航...")
    app.run_polling()
EOF

    echo -e "${YELLOW}>>> 启动后台进程并启用日志滚动管理...${NC}"
    pkill -9 -f minibot_main.py 2>/dev/null
    nohup ~/minibot_env/bin/python3 ~/minibot_main.py > ~/bot.log 2>&1 &
    echo -e "${GREEN}✅ V4.1 旗舰版部署成功！${NC}"
}

function stop_bot() {
    pkill -9 -f minibot_main.py && echo -e "${YELLOW}🛑 机器人已停止。${NC}" || echo -e "${RED}❌ 机器人未运行。${NC}"
}

function uninstall_bot() {
    read -p "确定卸载吗？(y/n): " confirm
    confirm_clean=$(echo "$confirm" | tr -d '\r')
    if [[ "$confirm_clean" == "y" || "$confirm_clean" == "Y" ]]; then
        pkill -9 -f minibot_main.py 2>/dev/null
        rm -rf ~/minibot_env ~/minibot_main.py ~/bot.log ~/.minibot.env
        echo -e "${GREEN}🗑️  环境已彻底清理。${NC}"
    fi
}

# 脚本入口
while true; do
    show_menu
    case $choice in
        1) install_bot ;;
        2) [ -f ~/bot.log ] && tail -f ~/bot.log || echo -e "${RED}无日志${NC}" ;;
        3) stop_bot ;;
        4) uninstall_bot ;;
        0) break ;;
        *) echo -e "${RED}无效输入 '$choice'${NC}" ;;
    esac
done
