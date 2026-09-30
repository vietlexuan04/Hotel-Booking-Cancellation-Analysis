# Phân tích & Insights — Tiếng Việt

## 1. Bối cảnh và mục tiêu

Project phân tích dữ liệu booking khách sạn nhằm tìm hiểu hành vi đặt phòng và các đặc điểm liên quan đến **tỷ lệ hủy phòng (`is_canceled`)**.

Các nhóm yếu tố chính được phân tích gồm:

- Loại khách sạn
- Mùa vụ / tháng đến
- Lead time
- Distribution channel
- Market segment
- Quốc gia
- Deposit type
- Repeat guest
- ADR
- Thời lượng lưu trú

## 2. Tiền xử lý dữ liệu

Dataset ban đầu có **119,390 booking**.

Các bước xử lý chính:

- Kiểm tra missing values, duplicate và các booking bất thường.
- Có 4 giá trị NULL ở `children`, được thay thế bằng 0.
- `agent` và `company` có thể NULL do ý nghĩa nghiệp vụ nên không mặc định xem là lỗi dữ liệu.
- Loại booking có `adults = 0`, `children = 0`, `babies = 0`.
- Loại bản ghi có ADR âm.
- Loại duplicate dựa trên tập thuộc tính booking.
- Chuẩn hóa giá trị text `'NULL'` ở `agent` / `company` về NULL thực.
- Chuyển kiểu dữ liệu số phù hợp.
- Loại booking có tổng số đêm lưu trú bằng 0.
- Loại ADR > 1,000 như một ngưỡng outlier đã chọn trong quá trình kiểm tra.

Sau làm sạch, dữ liệu phân tích còn **86,637 booking**.

## 3. Tổng quan dữ liệu

| Chỉ số | Kết quả |
|---|---:|
| Booking sau làm sạch | 86,637 |
| Booking bị hủy | 23,985 |
| Tỷ lệ hủy | **27.68%** |
| ADR trung bình | **107.18** |
| ADR trung vị | **99.00** |
| ADR độ lệch chuẩn | 51.31 |
| Lead time trung bình | **80 ngày** |
| Lead time trung vị | **50 ngày** |
| Lead time P25 / P75 / P90 | 12 / 126 / 205 ngày |
| ADR P25 / P75 | 72.90 / 134.43 |
| Số đêm lưu trú trung bình | 3 đêm |
| Khoảng số đêm | 1–69 đêm |

### Diễn giải

Tỷ lệ hủy tổng thể ở mức **27.68%**, nghĩa là hơn một phần tư booking trong tập dữ liệu đã bị hủy.

Lead time có độ phân tán lớn: trung bình 80 ngày nhưng trung vị chỉ 50 ngày, trong khi P90 đạt 205 ngày. Điều này cho thấy một nhóm booking được tạo khá sớm kéo phân phối về phía phải.

ADR cũng có độ phân tán đáng kể: trung bình 107.18 cao hơn median 99, cho thấy các mức ADR cao kéo trung bình lên.

## 4. Tỷ lệ hủy theo loại khách sạn

| Hotel | Booking | Cancellation rate |
|---|---:|---:|
| City Hotel | 53,042 | **30.20%** |
| Resort Hotel | 33,595 | **23.71%** |

### Insight

City Hotel có tỷ lệ hủy cao hơn Resort Hotel khoảng **6.50 điểm phần trăm**.

Đây là khác biệt mang tính mô tả giữa hai loại khách sạn; dữ liệu hiện tại chưa đủ để kết luận nguyên nhân của khoảng cách này.

## 5. Tính mùa vụ

| Tháng | Booking | Cancellation rate | Avg ADR |
|---|---:|---:|---:|
| January | 4,638 | 22.29% | 70.88 |
| February | 6,030 | 23.30% | 75.52 |
| March | 7,438 | 24.55% | 81.69 |
| April | 7,870 | 30.53% | 104.10 |
| May | 8,296 | 29.41% | 111.95 |
| June | 7,721 | 30.45% | 120.41 |
| July | 9,988 | 31.99% | 136.46 |
| August | 11,194 | **32.36%** | **151.70** |
| September | 6,659 | 24.63% | 112.60 |
| October | 6,842 | 23.98% | 91.36 |
| November | 4,916 | **21.40%** | 73.81 |
| December | 5,045 | 27.27% | 82.83 |

### Insight

- **August** có cả booking volume cao nhất và cancellation rate cao nhất: 11,194 booking và 32.36% hủy.
- ADR trung bình cũng đạt đỉnh vào August ở mức 151.70.
- Cancellation rate thấp nhất vào November: 21.40%.
- Giai đoạn July–August nổi bật đồng thời về volume, ADR và cancellation rate.

Điểm đáng chú ý là mùa cao điểm không chỉ tạo ra nhiều booking hơn mà còn đi kèm tỷ lệ hủy cao hơn trong tập dữ liệu.

## 6. Distribution channel

| Channel | Booking | Cancellation rate |
|---|---:|---:|
| TA/TO | 68,650 | **31.15%** |
| Direct | 12,803 | 14.98% |
| Corporate | 5,001 | 12.82% |
| GDS | 178 | 20.22% |
| Undefined | 5 | 80.00% |

### Insight

TA/TO vừa có volume rất lớn vừa có cancellation rate 31.15%, cao hơn đáng kể so với Direct và Corporate.

`Undefined` có tỷ lệ 80%, nhưng chỉ có 5 booking nên không nên dùng nhóm này để suy luận xu hướng chung.

## 7. Market segment

| Market segment | Booking | Cancellation rate | Avg lead time |
|---|---:|---:|---:|
| Online TA | 51,285 | **35.55%** | 80 ngày |
| Groups | 4,891 | 27.21% | 148 ngày |
| Aviation | 222 | 19.82% | 4 ngày |
| Offline TA/TO | 13,748 | 14.95% | 106 ngày |
| Direct | 11,652 | 14.87% | 49 ngày |
| Corporate | 4,155 | 12.20% | 16 ngày |
| Complementary | 682 | 12.17% | 14 ngày |

### Insight

Online TA là nhóm nổi bật: **35.55% cancellation rate trên 51,285 booking**.

Groups có lead time trung bình cao nhất trong các nhóm chính (148 ngày), trong khi Corporate và Complementary có lead time ngắn hơn đáng kể.

## 8. Lead time và cancellation

| Lead-time group | Booking | Cancellation rate |
|---|---:|---:|
| 0–7 ngày | 17,855 | **8.51%** |
| 8–30 ngày | 16,234 | 25.50% |
| 31–90 ngày | 22,633 | 32.14% |
| 91–180 ngày | 18,190 | 35.07% |
| 180+ ngày | 11,725 | **39.85%** |

### Insight quan trọng

Có một gradient rất rõ: cancellation rate tăng từ **8.51%** ở nhóm đặt trong 0–7 ngày lên **39.85%** ở nhóm đặt trước trên 180 ngày.

Khoảng cách giữa hai nhóm là hơn **31 điểm phần trăm**.

Correlation `lead_time` vs `is_canceled` = **0.1835**, cho thấy mối liên hệ tuyến tính dương nhưng yếu. Vì vậy, lead time có liên quan đến cancellation trong dữ liệu, nhưng không nên diễn giải rằng lead time tự nó gây ra cancellation.

## 9. Quốc gia

Top 10 quốc gia theo booking:

| Country | Booking | Cancellation rate |
|---|---:|---:|
| PRT | 26,863 | 36.37% |
| GBR | 10,400 | 19.07% |
| FRA | 8,813 | 19.64% |
| ESP | 7,228 | 25.75% |
| DEU | 5,385 | 19.55% |
| ITA | 3,056 | 35.14% |
| IRL | 3,014 | 22.16% |
| BEL | 2,078 | 19.73% |
| BRA | 1,988 | 36.52% |
| NLD | 1,908 | 18.34% |

### Insight

PRT có volume booking lớn nhất trong top 10 và cancellation rate 36.37%. BRA có cancellation rate 36.52% nhưng volume thấp hơn đáng kể.

Country là một dimension hữu ích để drill-down, nhưng dữ liệu này chỉ cho thấy sự khác biệt theo quốc gia, không giải thích nguyên nhân.

## 10. Deposit type

| Deposit type | Booking | Cancellation rate |
|---|---:|---:|
| Non Refund | 1,037 | **94.70%** |
| No Deposit | 85,493 | 26.88% |
| Refundable | 107 | 24.30% |

### Insight

Non Refund có cancellation rate rất cao, 94.70%. Tuy nhiên chỉ có 1,037 booking so với 85,493 booking của No Deposit.

Do đó nên coi đây là **tín hiệu cần điều tra**, không phải bằng chứng rằng deposit type là nguyên nhân trực tiếp của cancellation.

## 11. Repeat guest

| Guest type | Booking | Cancellation rate |
|---|---:|---:|
| New / non-repeat guest | 83,493 | 28.42% |
| Repeat guest | 3,144 | **8.24%** |

### Insight

Repeat guests có cancellation rate thấp hơn rõ rệt: **8.24% so với 28.42%** ở non-repeat guests.

Chênh lệch này gợi ý rằng repeat-guest status là một biến hữu ích để theo dõi trong các phân tích cancellation risk tiếp theo.

## 12. Rule-based customer segmentation

Phân nhóm sử dụng hai ngưỡng:

- Lead time ≤ 30 ngày → Đặt gấp
- Lead time > 30 ngày → Đặt sớm
- ADR < 100 → Giá thấp
- ADR ≥ 100 → Giá cao

| Segment | Booking | Cancellation rate | Avg ADR |
|---|---:|---:|---:|
| Đặt sớm – Giá cao | 27,125 | **39.56%** | 146.02 |
| Đặt sớm – Giá thấp | 25,423 | 29.88% | 72.74 |
| Đặt gấp – Giá cao | 15,084 | 21.29% | 149.41 |
| Đặt gấp – Giá thấp | 19,005 | **12.88%** | 64.31 |

### Insight

Nhóm **Đặt sớm – Giá cao** có cancellation rate cao nhất, 39.56%, trong khi **Đặt gấp – Giá thấp** thấp nhất, 12.88%.

Đây là một cách phân khúc phục vụ mục tiêu phân tích, không phải clustering tự động.

## 13. Market segment × lead time

Một kết quả nổi bật là Online TA khi kết hợp với lead time dài:

| Market segment + lead time | Cancellation rate |
|---|---:|
| Online TA + 180+ ngày | **51.86%** |
| Online TA + 91–180 ngày | 43.52% |
| Online TA + 31–90 ngày | 39.16% |
| Online TA + 8–30 ngày | 31.30% |
| Online TA + 0–7 ngày | 8.87% |

### Insight quan trọng nhất

Rủi ro cancellation không chỉ nằm ở channel/market segment riêng lẻ mà tăng mạnh khi **Online TA kết hợp với lead time dài**.

Online TA + 180+ ngày có cancellation rate **51.86%**, cao hơn rất nhiều so với Online TA + 0–7 ngày ở mức 8.87%.

Đây là một dimension rất phù hợp để đưa lên dashboard dưới dạng heatmap.

## 14. Correlation và diễn giải

| Relationship | Correlation |
|---|---:|
| Lead time vs cancellation | **0.1835** |
| Total nights vs cancellation | **0.0813** |

Cả hai đều dương nhưng yếu. Vì vậy, project nên dùng ngôn ngữ như **“associated with”, “shows a positive relationship”, “higher cancellation rate is observed”** thay vì **“causes”**.

## 15. Business implications / Đề xuất

### 1. Tập trung kiểm soát booking có lead time dài

Nhóm 180+ ngày có cancellation rate 39.85%. Có thể ưu tiên theo dõi các booking này và thiết kế cơ chế reminder / reconfirmation trước ngày đến.

### 2. Theo dõi riêng Online TA

Online TA có 35.55% cancellation rate và đặc biệt cao ở lead time dài. Dashboard nên có KPI hoặc alert riêng cho nhóm này.

### 3. Tận dụng hành vi repeat guest

Repeat guests chỉ có 8.24% cancellation rate. Có thể phân tích thêm loyalty / retention và xem liệu các ưu đãi dành cho khách quay lại có giúp cải thiện booking quality hay không.

### 4. Điều tra nhóm Non Refund

94.70% cancellation rate là một tín hiệu bất thường cần kiểm tra sâu hơn về quy trình, cách ghi nhận trạng thái booking và đặc điểm của nhóm booking này trước khi đưa ra thay đổi chính sách.

### 5. Chuẩn bị cho mùa cao điểm

July–August vừa có ADR cao vừa có cancellation rate cao. Dashboard có thể được dùng để theo dõi volume, ADR và cancellation đồng thời trong mùa cao điểm.

## 16. Hạn chế của phân tích

- Phân tích hiện tại chủ yếu là descriptive và association analysis.
- Correlation không chứng minh quan hệ nhân quả.
- Customer segmentation là rule-based.
- Một số nhóm có volume rất nhỏ, ví dụ Undefined channel, nên không phù hợp để suy luận rộng.
- Ngưỡng ADR = 100 và lead time = 30 ngày là ngưỡng phân tích do project lựa chọn.

## 17. Tóm tắt 5 insight nên đưa lên slide

1. **Overall cancellation rate = 27.68%.**
2. **Cancellation rises sharply with lead time: 8.51% → 39.85%.**
3. **Online TA is a major cancellation-risk segment: 35.55%, and reaches 51.86% for 180+ day lead time.**
4. **August combines the highest booking volume, ADR and cancellation rate.**
5. **Repeat guests show a much lower cancellation rate: 8.24% vs 28.42%.**
