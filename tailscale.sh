#!/bin/bash

# 1. Hỏi nhập Key
echo "=========================================================="
echo "   CÀI ĐẶT TAILSCALE KHÔNG CẦN ROOT (USERSPACE MODE)      "
echo "=========================================================="
read -p "Vui lòng dán Key Tailscale của bạn vào đây: " TAILSCALE_KEY

if [ -z "$TAILSCALE_KEY" ]; then
    echo "❌ Lỗi: Bạn chưa nhập Key."
    exit 1
fi

# 2. Dọn dẹp các tiến trình cũ của user hiện tại (không dùng sudo)
pkill -f tailscaled 2>/dev/null
rm -f "$HOME/tailscaled.sock"
sleep 1

# 3. Chuyển về thư mục HOME (nơi user thường có 100% quyền ghi/đọc)
cd "$HOME" || exit 1

# 4. Tải và giải nén bản Binary trực tiếp tại thư mục HOME
if [ ! -f "tailscale.tgz" ]; then
    echo "📥 Đang tải Tailscale Binary..."
    curl -L https://pkgs.tailscale.com/stable/tailscale_1.64.0_amd64.tgz -o tailscale.tgz
fi

tar xzf tailscale.tgz
cd tailscale_* || exit 1

# 5. Khởi chạy daemon bằng quyền USER
# Dùng cổng ngẫu nhiên và ép ghi socket vào thư mục HOME để không chạm vào hệ thống
RANDOM_PORT=$(shuf -i 2000-65000 -n 1)
echo "🚀 Khởi chạy Tailscale Daemon dưới nền..."
./tailscaled --tun=userspace-networking --socks5-server=localhost:$RANDOM_PORT --socket="$HOME/tailscaled.sock" > /dev/null 2>&1 &

# Chờ 3 giây để khởi động xong socket
sleep 3

# 6. Đăng nhập bằng Key thông qua file socket ở thư mục HOME
echo "🔐 Đang tiến hành kết nối..."
./tailscale --socket="$HOME/tailscaled.sock" up --authkey="$TAILSCALE_KEY" --reset

if [ $? -eq 0 ]; then
    echo "✅ Kết nối thành công với Tailscale!"
    ./tailscale --socket="$HOME/tailscaled.sock" status
else
    echo "❌ Thất bại, vui lòng kiểm tra lại Key."
    exit 1
fi

# 7. Treo máy giữ kết nối
while true; do sleep 3600; done
