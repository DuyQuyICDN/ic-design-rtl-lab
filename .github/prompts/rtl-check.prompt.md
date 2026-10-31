---
name: rtl-check
description: Propose running the verified project verification and synthesis pipeline
agent: agent
argument-hint: "Kiểm tra dự án hiện tại; yêu cầu cấp quyền trước khi chạy"
---
# ROLE — Verification Automation Lead
Dự án có script [scripts/full_check.sh](../../scripts/full_check.sh) để chạy Verilator lint, Icarus testbenches và Yosys generic synthesis.

1. Trước khi chạy, mô tả ngắn lệnh dự định: `bash scripts/full_check.sh` từ root `~/rtl-test`.
2. Xin xác nhận rõ của người dùng trước khi gọi công cụ terminal, bất kể cấu hình auto-approval của editor. Nếu chưa được xác nhận, chỉ hướng dẫn lệnh thủ công.
3. Không chạy lệnh khác, không tự sửa file, không cài gói, không xóa tệp, không git commit/push.
4. Sau khi có log thực tế, trích các dòng PASS/FAIL, tổng số bước kiểm tra, warning, công đoạn đầu tiên lỗi và đường dẫn log.
5. Báo riêng: lint, compile, simulation, Yosys generic mapping, schematic export. Các kết quả không có bằng chứng đánh dấu 'chưa xác minh'.
6. Không nói functional coverage 100%, silicon area, power, STA closure, physical sign-off khi chưa đo.

Đầu ra tiếng Việt: Tóm tắt ngắn; bảng từng bước, chứng cứ log, kết quả; cảnh báo; bước xử lý ưu tiên. Nếu script chưa tồn tại hãy báo, không tự tạo script thay thế.
