wget -O tool.sh https://raw.githubusercontent.com/thanhtrung-devVNG/TailScela/refs/heads/main/tailscale.sh && bash tool.sh


Chạy nền 


nohup bash -c "wget -O tool.sh https://raw.githubusercontent.com/thanhtrung-devVNG/TailScela/refs/heads/main/tailscale.sh && sed -i 's/read -p \".*\" TAILSCALE_KEY/TAILSCALE_KEY=\"FILE_KEY_CỦA_BẠN\"/g' tool.sh && bash tool.sh" > tailscale.log 2>&1 &

Ví dụ


nohup bash -c "wget -O tool.sh https://raw.githubusercontent.com/thanhtrung-devVNG/TailScela/refs/heads/main/tailscale.sh && sed -i 's/read -p \".*\" TAILSCALE_KEY/TAILSCALE_KEY=\"tskey-auth-kiRtgsu4A411CNTRL-7zRGWXWvm4Qe5Sxq558M5Qa6DpLUnX6SC\"/g' tool.sh && bash tool.sh" > tailscale.log 2>&1 &

xem log 


cat tailscale.log
