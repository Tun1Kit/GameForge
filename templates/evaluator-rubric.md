# Rubric Evaluator — Harness Template

> Template bậc 1. Dùng sau khi implement và trước khi chấp nhận cuối cùng.

---

## PHẦN 1: ĐÁNH GIÁ TỪNG HẠNG MỤC

### 1.1 Thang điểm

```
0 = Không đạt     → Yêu cầu sửa chữa bắt buộc trước khi chấp nhận
1 = Đạt một phần  → Cần cải thiện, có thể chấp nhận có điều kiện
2 = Đạt hoàn toàn → Đạt yêu cầu, không cần sửa
```

### 1.2 Ma trận đánh giá

| # | Hạng mục | Câu hỏi cần trả lời | Điểm (0-2) | Ghi chú |
|---|-----------|---------------------|-------------|---------|
| 1 | **Tính đúng đắn** | Hành vi đã implement có khớp với yêu cầu tính năng không? | | |
| 2 | **Xác minh** | Các kiểm tra bắt buộc có thực sự chạy, với bằng chứng không? | | |
| 3 | **Phạm vi kỷ luật** | Phiên có ở trong phạm vi tính năng đã chọn không? | | |
| 4 | **Độ tin cậy** | Kết quả tồn tại qua khởi động lại hoặc chạy lại không? | | |
| 5 | **Khả năng bảo trì** | Mã và tài liệu đủ rõ ràng cho phiên tiếp theo không? | | |
| 6 | **Sẵn sàng bàn giao** | Phiên mới có thể tiếp tục từ các artifact repo không? | | |

### 1.3 Tổng điểm

```
Tổng: ___ / 12
Số hạng mục = 0: ___
Số hạng mục = 1: ___
Số hạng mục = 2: ___

□ Chấp nhận      (8-12 điểm, không hạng mục nào = 0)
□ Cần sửa đổi   (5-7 điểm, hoặc bất kỳ hạng mục nào = 0)
□ Bị chặn        (0-4 điểm, nhiều hạng mục = 0)
```

---

## PHẦN 2: CHI TIẾT TỪNG HẠNG MỤC

### 2.1 Tính đúng đắn (Correctness)

```
Điểm: [0/1/2]

Câu hỏi:
  - Tính năng có hoạt động đúng như mô tả trong feature_list.json?
  - Happy path: đi theo flow chính → kết quả đúng?
  - Edge cases: input rỗng, giá trị max, giá trị lỗi → xử lý đúng?

Bằng chứng:
  [Mô tả bằng chứng cụ thể]

Nếu điểm < 2, cần sửa:
  [FILL: mô tả những gì cần sửa]
```

### 2.2 Xác minh (Verification)

```
Điểm: [0/1/2]

Câu hỏi:
  - Verification steps trong feature_list.json đã chạy thực tế?
  - Có bằng chứng (screenshot, log, API response) được lưu?
  - Baseline vẫn OK sau thay đổi?

Bằng chứng:
  [FILL: danh sách files/screenshots/logs]

Nếu điểm < 2, cần sửa:
  [FILL]
```

### 2.3 Phạm vi kỷ luật (Scope Discipline)

```
Điểm: [0/1/2]

Câu hỏi:
  - Code chỉ thay đổi trong phạm vi feature đã chọn?
  - Có file không liên quan bị sửa không?
  - Nếu có sửa ngoài phạm vi → có justified không?

Bằng chứng:
  [FILL]

Nếu điểm < 2, cần sửa:
  [FILL]
```

### 2.4 Độ tin cậy (Reliability)

```
Điểm: [0/1/2]

Câu hỏi:
  - Chạy lại init script → vẫn hoạt động?
  - Restart app → dữ liệu vẫn đúng?
  - Nhiều request đồng thời → không có race condition?

Bằng chứng:
  [FILL]

Nếu điểm < 2, cần sửa:
  [FILL]
```

### 2.5 Khả năng bảo trì (Maintainability)

```
Điểm: [0/1/2]

Câu hỏi:
  - Code có đọc được cho developer mới?
  - Có comment ở chỗ cần thiết (không thừa, không thiếu)?
  - Tên biến/hàm có mô tả đúng?
  - Có violate luật nào trong AGENTS.md không?

Bằng chứng:
  [FILL]

Nếu điểm < 2, cần sửa:
  [FILL]
```

### 2.6 Sẵn sàng bàn giao (Handoff Readiness)

```
Điểm: [0/1/2]

Câu hỏi:
  - feature_list.json đã cập nhật status + evidence?
  - claude-progress.md đã ghi nhật ký phiên?
  - Các artifact harness đều up-to-date?
  - Phiên tiếp theo có thể tiếp tục không cần hỏi?

Bằng chứng:
  [FILL]

Nếu điểm < 2, cần sửa:
  [FILL]
```

---

## PHẦN 3: KẾT LUẬN

```
□ Chấp nhận      — Feature đạt yêu cầu, sẵn sàng merge/deploy
□ Cần sửa đổi    — Cần cải thiện trước khi chấp nhận
□ Bị chặn        — Không đạt yêu cầu, cần làm lại
```

### 3.1 Nếu cần sửa đổi

```
Lý do tổng thể:
[FILL]

Mức độ nghiêm trọng:
□ Low  — Có thể sửa nhanh, không ảnh hưởng timeline
□ Med  — Cần thời gian, ảnh hưởng timeline
□ High — Cần làm lại từ đầu hoặc từ bước lớn
```

---

## PHẦN 4: HÀNH ĐỘNG TIẾP THEO BẮT BUỘC

### 4.1 Bằng chứng còn thiếu

```
1. [FILL]
2. [FILL]
```

### 4.2 Sửa chữa bắt buộc

```
1. [FILL]
2. [FILL]
```

### 4.3 Kích hoạt review tiếp theo

```
□ Ngay lập tức (blocker — nghiêm trọng)
□ Sau khi sửa xong
□ Trong phiên tiếp theo
□ Không cần review nữa (đã chấp nhận)
```

---

## PHẦN 5: EVIDENCE CHECKLIST

```
□ Verification đã chạy thực tế
□ Test output / screenshot / log đã lưu
□ feature_list.json đã cập nhật (status, verification, evidence)
□ claude-progress.md đã ghi nhật ký
□ Commit đã được tạo
□ Không có rủi ro bảo mật mới được tạo ra
```

---

## PHẦN 6: NOTES CHO PHIÊN TIẾP THEO

```
Những gì phiên tiếp theo CẦN BIẾT trước khi bắt đầu:

1. [FILL: ví dụ: Feature F005 đã implement checkout flow, còn phần refund chưa làm]
2. [FILL: ví dụ: Cần chú ý race condition trong wallet balance update]
3. [FILL: ví dụ: Đã fix bug C01, nhưng cần test thêm với 100 concurrent users]
```

---

## PHẦN 7: CÁCH SỬ DỤNG RUBRIC NÀY

### 7.1 Khi nào dùng

```
□ Sau khi implement xong một feature trước khi commit
□ Trước khi tạo Pull Request
□ Khi nhận review từ đồng nghiệp
□ Khi kết thúc một milestone lớn
□ Khi agent tự đánh giá trước khi báo cáo hoàn thành
```

### 7.2 Ai điền

```
□ Agent — tự đánh giá trước khi kết thúc task
□ Reviewer — đánh giá PR
□ Tech lead — đánh giá milestone
□ Solo dev — tự đánh giá để đảm bảo chất lượng
```

### 7.3 Nguyên tắc đánh giá

```
□ Điểm 2: Phải đạt HOÀN TOÀN yêu cầu. Không nửa vời.
□ Điểm 1: Có đạt nhưng có khoảng trống. Cần cải thiện.
□ Điểm 0: Không đạt. Yêu cầu sửa lại.
□ Nếu bất kỳ hạng mục nào = 0 → không thể chấp nhận → phải sửa
□ Mục tiêu: tất cả hạng mục = 2
```
