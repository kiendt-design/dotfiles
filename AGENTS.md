# Context & Purpose
- **Workspace:** Dotfiles & Environment Configurations.
- **Primary Goal:** Quản lý cấu hình (bash, git, tmux, MCP, CLI) để triển khai **nhanh và tự động** lên các môi trường remote (đặc biệt là GitHub Codespaces).
- **Core Mechanism:** Khi cấu hình thay đổi, code phải được commit và push lên `origin/main`. Sau đó trên Codespace sẽ gọi lệnh `dot-sync` (chạy `git pull` và `install.sh`) để đồng bộ.

# Agent Directives (MUST FOLLOW)
1. **Remote-First Deployment:** 
   - Đích đến cuối cùng của các script và cấu hình trong repo này là Linux/Ubuntu trên Codespaces, KHÔNG phải macOS cá nhân (trừ các alias shell dùng chung).
   - Tuyệt đối KHÔNG tự ý thực thi `./install.sh` trên môi trường hiện tại (macOS) trừ khi được yêu cầu rõ ràng, vì chứa lệnh `apt-get` của Linux.
2. **Auto Commit & Push:** 
   - Sau khi cập nhật thành công bất kỳ file cấu hình nào (.bash_aliases, install.sh...), agent MẶC ĐỊNH phải thực hiện `git add`, `git commit` và **`git push origin main`** ngay lập tức để Codespace có thể pull về.
3. **No Local Test Requirement:** 
   - Không cần thiết test các cài đặt package Linux trên macOS. Nếu cần test, yêu cầu User thực hiện test trực tiếp qua ssh/terminal của Codespace.
