#!/bin/bash

# ==========================================
#    ⚓ Mini-AI-Bot V4.1 旗舰管理工具
# ==========================================

# 解决输入无效的核心修复：强制使用标准输入读取
read_input() {
    local prompt="$1"
    read -p "$prompt" input
    echo "$input" | tr -d '\r' # 强行过滤掉 Windows 的回车符
}

show_menu() {
    clear
    echo "=========================================="
    echo "    ⚓ Mini-AI-Bot V4.1 旗舰管理工具"
    echo "=========================================="
    echo " 1. 一键安装部署 (含 venv 隔离环境)"
    echo " 2. 查看实时运行日志 (滚动管理)"
    echo " 3. 停止后台机器人进程"
    echo " 4. 彻底卸载机器人 (清空一切配置)"
    echo " 0. 退出脚本"
    echo "------------------------------------------"
}

while true; do
    show_menu
    choice=$(read_input " 请输入序号: ")

    case $choice in
        1)
            echo "🚀 正在启动一键安装部署..."
            # 这里写你的安装逻辑，比如安装依赖和启动 py
            python3 -m venv venv
            source venv/bin/activate
            pip install google-genai telethon psutil
            nohup python3 minibot.py > minibot.log 2>&1 &
            echo "✅ 机器人已在后台起飞！"
            sleep 2
            ;;
        2)
            echo "显示日志 (按 Ctrl+C 退出):"
            tail -f minibot.log
            ;;
        3)
            pkill -f minibot.py
            echo "🛑 机器人进程已停止。"
            sleep 2
            ;;
        4)
            rm -rf venv minibot.log minibot_session*
            echo "🗑️ 已彻底清理环境。"
            sleep 2
            ;;
        0)
            exit 0
            ;;
        *)
            echo "⚠️  无效输入 '$choice'，请重新选择！"
            sleep 1
            ;;
    esac
done
