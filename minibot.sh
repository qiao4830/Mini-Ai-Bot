#!/bin/bash

# ==========================================
# 项目名称: Mini-Ai-Bot V4.1 (实战稳定版)
# 特色: 锁定 Gemini 2.5 / 绝对路径修复 / 极简异步架构
# 适用: Debian/Ubuntu (针对 1G RAM VPS 深度优化)
# 作者: 小帆船 YouTube
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function show_menu() {
    echo -e "${BLUE}=========================================="
    echo -e "    ⚓ Mini-Ai-Bot V4.1 旗舰管理工具"
    echo -e "==========================================${NC}"
    echo -e " 1. ${GREEN}一键安装部署 (锁定 2.5 稳定逻辑)${NC}"
    echo -e " 2. ${BLUE}查看实时日志${NC}"
    echo -e " 3. ${YELLOW}停止后台机器人进程${NC}"
    echo -e " 4. ${RED}彻底卸载机器人${NC}"
    echo -e " 0. 退出脚本"
    echo -e "------------------------------------------"
    read -p " 请输入序号: " choice
}

function install_bot() {
    echo -e "${YELLOW}>>> [1/4] 初始化隔离环境...${NC}"
    apt-get update -y && apt-get install python3-pip python3-venv -y
    python3 -m venv ~/minibot_env
    source ~/minibot_env/bin/activate

    echo -e "${YELLOW}>>> [2/4] 安装核心依赖...${NC}"
    pip install --upgrade pip
    pip install python-telegram-bot google-generativeai python-dotenv --quiet

    echo -e "${GREEN}>>> [3/4] 配置 API 安全密钥...${NC}"
    read -p " 🔹 Telegram Bot Token (必填): " TG_TOKEN
    read -p " 🔹 Gemini API Key (必填): " GEMINI_KEY

    cat > ~/.minibot.env <<EOF
TG_TOKEN=$TG_TOKEN
GEMINI_KEY=$GEMINI_KEY
EOF
    chmod 600 ~/.minibot.env

    echo -e "${YELLOW}>>> [4/4] 注入验证成功的黄金代码...${NC}"
    cat > ~/minibot_main.py <<EOF
import os, google.generativeai as genai
from telegram import Update
from telegram.ext import ApplicationBuilder, ContextTypes, MessageHandler, filters
from dotenv import load_dotenv

# 加载配置
load_dotenv(dotenv_path=os.path.expanduser('~/.minibot.env'))
TG_TOKEN = os.getenv('TG_TOKEN')
GEMINI_KEY = os.getenv('GEMINI_KEY')

# 初始化
genai.configure(api_key=GEMINI_KEY)
# 锁定验证成功的模型路径
model = genai.GenerativeModel(model_name='models/gemini-2.5-flash')

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not update.message or not update.message.text: return
    try:
        # 使用上午验证成功的同步请求逻辑，最稳！
        response = model.generate_content(update.message.text)
        await update.message.reply_text(response.text)
        print(f">>> 成功回复: {update.message.text[:10]}...")
    except Exception as e:
        print(f"出错啦: {e}")
        # 报错时自动列出可用模型，方便调试
        try:
            available = [m.name for m in genai.list_models()]
            print(f">>> 当前可用列表: {available}")
        except: pass
        await update.message.reply_text(f"⚠️ 航线波动: {e}")

if __name__ == '__main__':
    if not TG_TOKEN: exit("Token Missing")
    print(">>> Mini-Ai-Bot V4.1 (Flagship) 起航...")
    app = ApplicationBuilder().token(TG_TOKEN).build()
    app.add_handler(MessageHandler(filters.TEXT & (~filters.COMMAND), handle_message))
    app.run_polling()
EOF

    echo -e "${YELLOW}>>> 正在后台启动...${NC}"
    pkill -9 -f minibot_main.py 2>/dev/null
    nohup ~/minibot_env/bin/python3 ~/minibot_main.py > ~/bot.log 2>&1 &
    echo -e "${GREEN}✅ 部署成功！快去 Telegram 测试吧。${NC}"
}

function stop_bot() {
    pkill -9 -f minibot_main.py && echo -e "${YELLOW}🛑 机器人已停止。${NC}" || echo -e "${RED}❌ 机器人未运行。${NC}"
}

function uninstall_bot() {
    read -p "确定卸载吗？(y/n): " confirm
    if [[ "\$confirm" == "y" || "\$confirm" == "Y" ]]; then
        pkill -9 -f minibot_main.py 2>/dev/null
        rm -rf ~/minibot_env ~/minibot_main.py ~/bot.log ~/.minibot.env
        echo -e "${GREEN}🗑️  环境已彻底清理。${NC}"
    fi
}

# 找到最后这段，替换成这个加强版
while true; do
    show_menu
    # 使用 -r 并清除首尾空格
    read -r choice
    # 过滤掉所有非数字字符，只留数字
    clean_choice=$(echo "$choice" | tr -cd '0-9')

    case "$clean_choice" in
        1) install_bot ;;
        2) [ -f ~/bot.log ] && tail -f ~/bot.log || echo -e "${RED}无日志${NC}" ;;
        3) stop_bot ;;
        4) uninstall_bot ;;
        0) break ;;
        *) echo -e "${RED}无效输入: '$choice'，请确保只输入数字并按回车${NC}" ;;
    esac
done
