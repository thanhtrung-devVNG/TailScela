#!/bin/bash

# 1. Yêu cầu nhập Key Tailscale
echo "=========================================================="
echo "   CÀI ĐẶT TAILSCALE KHÔNG CẦN ROOT (USERSPACE MODE)      "
echo "=========================================================="
read -p "Vui lòng dán Key Tailscale của bạn vào đây: " TAILSCALE_KEY

# Kiểm tra xem người dùng có nhập key hay không
if [ -z "$TAILSCALE_KEY" ]; then
    echo "❌ Lỗi: Bạn chưa nhập Key. Hủy bỏ cài đặt!"
    exit 1
fi

echo "🔄 Đang dọn dẹp các tiến trình và file socket cũ..."
pkill -f tailscaled 2>/dev/null
rm -f "$HOME/tailscaled.sock"
sleep 1

# 2. Tải bản nén Tailscale Binary nếu chưa có trong thư mục hiện tại
if [ ! -f "tailscale.tgz" ]; then
    echo "📥 Đang tải Tailscale Binary (bản ổn định)..."
    curl -L https://pkgs.tailscale.com/stable/tailscale_1.64.0_amd64.tgz -o tailscale.tgz
fi

# 3. Giải nén và di chuyển vào thư mục chứa file thực thi
echo "📦 Đang giải nén gói cài đặt..."
tar xzf tailscale.tgz
cd tailscale_* || { echo "❌ Lỗi: Không thể tìm thấy thư mục giải nén!"; exit 1; }

# 4. Tìm một cổng trống ngẫu nhiên từ 1024 đến 49151 để chạy SOCKS5 tránh bị trùng lịch
RANDOM_PORT=$(shuf -i 2000-65000 -n 1)
echo "🚀 Khởi chạy Tailscale Daemon dưới nền trên cổng ngẫu nhiên: $RANDOM_PORT..."

./tailscaled --tun=userspace-networking --socks5-server=localhost:$RANDOM_PORT --socket="$HOME/tailscaled.sock" > /dev/null 2>&1 &

# Chờ 3 giây để dịch vụ khởi động tạo file socket
sleep 3

# 5. Thực hiện đăng nhập bằng Key bạn vừa nhập
echo "🔐 Đang tiến hành kết nối máy ảo với hệ thống Tailscale..."
./tailscale --socket="$HOME/tailscaled.sock" up --authkey="$TAILSCALE_KEY" --reset

if [ $? -eq 0 ]; then
    echo "✅ CHÚC MỪNG: Máy ảo của bạn đã kết nối thành công với Tailscale!"
    echo "📌 Trạng thái hiện tại:"
    ./tailscale --socket="$HOME/tailscaled.sock" status
else
    echo "❌ Thất bại: Vui lòng kiểm tra lại Key hoặc kết nối mạng của máy ảo."
    exit 1
fi

# 6. Treo máy duy trì kết nối liên tục
echo "⏱️ Đang kích hoạt chế độ treo máy (Loop) để giữ kết nối không bị sập..."
while true; do sleep 3600; done
