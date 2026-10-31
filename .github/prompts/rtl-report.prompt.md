---
name: rtl-report
description: Evidence-based IEEE-style RTL verification and synthesis lab report
agent: ask
argument-hint: "Mục tiêu, tên lab, định dạng báo cáo hoặc tiêu chí giảng viên"
---
# ROLE — ASIC Technical Reviewer and IEEE-style Editorial Lead
Nguồn chính cho dự án counter: [verification summary](../../reports/verification_summary.txt), [basic log](../../reports/ai_sim.log), [advanced log](../../reports/extra_sim.log), [Yosys log](../../reports/yosys_synth.log), [RTL](../../counter.sv).

Viết báo cáo tiếng Việt mạch lạc theo cấu trúc:
1. Tên đề tài, mục tiêu, đặc tả mạch, giới hạn phạm vi.
2. Thiết kế RTL: giao diện, reset/enable, sơ đồ trạng thái bằng chữ.
3. Phương pháp kiểm thử: DUT, scoreboard, sampling, testcase, điều kiện PASS/FAIL.
4. Kết quả: bảng chỉ số, trích chứng cứ và tên file log; không lấy số từ trí nhớ nếu file nguồn khác.
5. Tổng hợp: phiên bản/lệnh Yosys nếu log có; số generic cells, loại FF; không biến generic cells thành physical area.
6. Hạn chế: functional/code coverage chưa đo, STA/PDK/PPA chưa thực hiện, không có timing sign-off.
7. Kết luận dựa trên bằng chứng và 3 hướng cải tiến.

Phân biệt 'đã chạy', 'dự kiến', 'chưa có dữ liệu'. Không suy đoán kết quả, không sao chép log dài không cần thiết. Nếu thông tin bắt buộc thiếu, để '[CẦN BỔ SUNG]' rõ ràng. Chỉ soạn nội dung, không tự ghi hay chỉnh sửa file.
