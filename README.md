wget -O tool.sh https://raw.githubusercontent.com/thanhtrung-devVNG/TailScela/refs/heads/main/tailscale.sh && bash tool.sh


wget -O tool.sh https://raw.githubusercontent.com/thanhtrung-devVNG/TailScela/refs/heads/main/tailscale.sh
# Chạy script dưới nền, chuyển hướng log để không bị hiện lên terminal
nohup bash tool.sh > /dev/null 2>&1 &
