#!/bin/bash

# Hỏi nhập Key
echo "=========================================================="
echo "   CÀI ĐẶT TAILSCALE KHÔNG CẦN ROOT (USERSPACE MODE)      "
echo "=========================================================="
read -p "Vui lòng dán Key Tailscale của bạn vào đây: " TAILSCALE_KEY

if [ -z "$TAILSCALE_KEY" ]; then
    echo "❌ Lỗi: Bạn chưa nhập Key."
    exit 1
fi

# Dọn dẹp tiến trình cũ của user hiện tại
pkill -f tailscaled 2>/dev/null
rm -f "$HOME/tailscaled.sock"
sleep 1

# Tải bản binary về thư mục HOME (nơi chắc chắn có quyền)
cd $HOME
if [ ! -f "tailscale.tgz" ]; then
    echo "📥 Đang tải Tailscale Binary..."
    curl -L https://pkgs.tailscale.com/stable/tailscale_1.64.0_amd64.tgz -o tailscale.tgz
fi

# Giải nén
tar xzf tailscale.tgz
cd tailscale_* || exit 1

# Chọn cổng ngẫu nhiên và chạy daemon vào socket ở thư mục HOME
RANDOM_PORT=$(shuf -i 2000-65000 -n 1)
./tailscaled --tun=userspace-networking --socks5-server=localhost:$RANDOM_PORT --socket="$HOME/tailscaled.sock" > /dev/null 2>&1 &

sleep 3

# Tiến hành up với key vừa nhập
./tailscale --socket="$HOME/tailscaled.sock" up --authkey="$TAILSCALE_KEY" --reset

if [ $? -eq 0 ]; then
    echo "✅ Kết nối thành công với Tailscale!"
    ./tailscale --socket="$HOME/tailscaled.sock" status
else
    echo "❌ Thất bại, vui lòng kiểm tra lại Key."
    exit 1
fi

# Treo máy giữ kết nối
while true; do sleep 3600; done
