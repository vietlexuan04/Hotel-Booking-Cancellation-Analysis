# Phân tích & Insights (Tiếng Việt)

> English version: [analysis_en.md](analysis_en.md)

## Mục lục

1. [Bối cảnh và mục tiêu](#1-bối-cảnh-và-mục-tiêu)
2. [Tiền xử lý dữ liệu](#2-tiền-xử-lý-dữ-liệu)
3. [Tổng quan dữ liệu](#3-tổng-quan-dữ-liệu)
4. [Theo loại khách sạn](#4-theo-loại-khách-sạn)
5. [Tính mùa vụ](#5-tính-mùa-vụ)
6. [Kênh phân phối](#6-kênh-phân-phối)
7. [Market segment](#7-market-segment)
8. [Lead time](#8-lead-time-và-tỷ-lệ-hủy)
9. [Quốc gia](#9-quốc-gia)
10. [Deposit type](#10-deposit-type)
11. [Repeat guest](#11-repeat-guest)
12. [Phân khúc rule-based](#12-phân-khúc-khách-hàng-rule-based)
13. [Market segment × lead time](#13-market-segment--lead-time)
14. [Tương quan](#14-tương-quan)
15. [Gợi ý](#15-gợi-ý-cần-kiểm-chứng)
16. [Hạn chế](#16-hạn-chế)
17. [Key takeaways](#17-key-takeaways)

---

## 1. Bối cảnh và mục tiêu

Phân tích dữ liệu booking khách sạn nhằm tìm hiểu hành vi đặt phòng và các đặc điểm gắn với **tỷ lệ hủy phòng (`is_canceled`)**.

Các yếu tố được xem xét: loại khách sạn, tháng đến, lead time, distribution channel, market segment, quốc gia, deposit type, repeat guest, ADR và thời lượng lưu trú.

> **Quy ước:** *cancellation rate* = số booking bị hủy / tổng số booking của nhóm. *ADR* = giá phòng trung bình mỗi đêm. *Lead time* = số ngày từ lúc đặt đến ngày đến.

## 2. Tiền xử lý dữ liệu

Dataset gốc có **119,390 booking** (ngày đến từ 2015 đến 2017).

| Bước | Xử lý | Số dòng loại | Còn lại |
|---|---|---:|---:|
| 0 | Dữ liệu gốc | – | 119,390 |
| 1 | Loại booking không có khách (`adults = children = babies = 0`) | 180 | 119,210 |
| 2 | Loại ADR âm | 1 | 119,209 |
| 3 | Loại bản ghi trùng lặp (giống nhau ở cả 32 cột) | 31,980 | 87,229 |
| 4 | Loại booking có tổng số đêm = 0 | 591 | 86,638 |
| 5 | Loại ADR > 1,000 (ngưỡng outlier chọn sau khi kiểm tra) | 1 | **86,637** |

Các xử lý khác:

- 4 giá trị thiếu ở `children` được thay bằng 0.
- `agent` và `company` có thể NULL do ý nghĩa nghiệp vụ (đặt trực tiếp, khách cá nhân) nên không coi là lỗi; chuỗi `'NULL'` được chuẩn hóa về NULL thật.
- Chuyển `children`, `agent`, `company` sang kiểu số.

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
| Lead time trung bình | **80.3 ngày** |
| Lead time trung vị | **50 ngày** |
| Lead time P25 / P75 / P90 | 12 / 126 / 205 ngày |
| ADR P25 / P75 | 72.90 / 134.43 |
| Số đêm lưu trú trung bình | 3.65 đêm |
| Khoảng số đêm | 1–69 đêm |

**Diễn giải**

- Hơn một phần tư booking (27.68%) đã bị hủy.
- Lead time phân tán mạnh: trung bình 80.3 ngày nhưng trung vị chỉ 50 ngày và P90 là 205 ngày. Phân phối lệch phải, có một nhóm booking đặt rất sớm.
- ADR trung bình (107.18) cao hơn trung vị (99), cho thấy các mức giá cao kéo trung bình lên.

## 4. Theo loại khách sạn

| Hotel | Booking | Cancellation rate | ADR trung bình |
|---|---:|---:|---:|
| City Hotel | 53,042 | **30.20%** | 111.66 |
| Resort Hotel | 33,595 | **23.71%** | 100.12 |

**Insight:** City Hotel có tỷ lệ hủy cao hơn Resort Hotel khoảng **6.50 điểm phần trăm** và ADR trung bình cũng cao hơn. Đây là khác biệt mô tả; dữ liệu chưa đủ để giải thích nguyên nhân.

## 5. Tính mùa vụ

| Tháng | Booking | Cancellation rate | ADR trung bình |
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

**Insight**

- **August** có số booking cao nhất (11,194), tỷ lệ hủy cao nhất (32.36%) và ADR cao nhất (151.70).
- November có tỷ lệ hủy thấp nhất (21.40%).
- Tháng 4–8 đều có tỷ lệ hủy quanh hoặc trên 29%, cao hơn rõ rệt so với các tháng đầu năm (22–25%). Mùa cao điểm vừa có nhiều booking vừa có tỷ lệ hủy cao hơn.

> **Lưu ý:** tháng 7 và 8 có dữ liệu của 3 năm (2015–2017), các tháng còn lại chỉ có 2 năm, nên **số booking** của hai tháng này bị thổi phồng một phần. Tỷ lệ hủy và ADR ít bị ảnh hưởng hơn.

## 6. Kênh phân phối

| Channel | Booking | Cancellation rate |
|---|---:|---:|
| TA/TO | 68,650 | **31.15%** |
| Direct | 12,803 | 14.98% |
| Corporate | 5,001 | 12.82% |
| GDS | 178 | 20.22% |
| Undefined | 5 | 80.00% |

**Insight:** TA/TO vừa chiếm volume rất lớn (khoảng 79% booking) vừa có tỷ lệ hủy 31.15%, cao hơn đáng kể so với Direct và Corporate. Nhóm `Undefined` chỉ có 5 booking nên không dùng để suy luận.

## 7. Market segment

| Market segment | Booking | Cancellation rate | Lead time trung bình |
|---|---:|---:|---:|
| Online TA | 51,285 | **35.55%** | 80 ngày |
| Groups | 4,891 | 27.21% | 148 ngày |
| Aviation | 222 | 19.82% | 4 ngày |
| Offline TA/TO | 13,748 | 14.95% | 106 ngày |
| Direct | 11,652 | 14.87% | 49 ngày |
| Corporate | 4,155 | 12.20% | 16 ngày |
| Complementary | 682 | 12.17% | 14 ngày |

*Không hiển thị nhóm `Undefined` (2 booking, 100% hủy) do quá nhỏ.*

**Insight**

- Online TA nổi bật: **35.55% tỷ lệ hủy trên 51,285 booking** (khoảng 59% tổng booking).
- Groups có lead time trung bình dài nhất (148 ngày); Corporate và Complementary đặt sát ngày hơn nhiều.

## 8. Lead time và tỷ lệ hủy

| Nhóm lead time | Booking | Cancellation rate |
|---|---:|---:|
| 0–7 ngày | 17,855 | **8.51%** |
| 8–30 ngày | 16,234 | 25.50% |
| 31–90 ngày | 22,633 | 32.14% |
| 91–180 ngày | 18,190 | 35.07% |
| 180+ ngày | 11,725 | **39.85%** |

**Insight quan trọng:** tỷ lệ hủy tăng đều từ **8.51%** (đặt trong 0–7 ngày) lên **39.85%** (đặt trước hơn 180 ngày), chênh hơn **31 điểm phần trăm**.

Hệ số tương quan Pearson giữa `lead_time` và `is_canceled` là **0.1835** (dương, yếu). Lead time **liên quan** đến việc hủy, nhưng không nên diễn giải là nguyên nhân trực tiếp.

## 9. Quốc gia

Top 10 quốc gia theo số booking:

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

**Insight:** PRT có volume lớn nhất và tỷ lệ hủy 36.37%. BRA (36.52%) và ITA (35.14%) cũng cao nhưng volume thấp hơn nhiều. Quốc gia hữu ích để drill-down, nhưng dữ liệu không giải thích nguyên nhân của chênh lệch.

## 10. Deposit type

| Deposit type | Booking | Cancellation rate |
|---|---:|---:|
| Non Refund | 1,037 | **94.70%** |
| No Deposit | 85,493 | 26.88% |
| Refundable | 107 | 24.30% |

**Insight:** Non Refund có tỷ lệ hủy rất cao (94.70%) nhưng chỉ 1,037 booking so với 85,493 booking No Deposit. Đây là **tín hiệu cần điều tra**, không phải bằng chứng deposit type là nguyên nhân trực tiếp.

## 11. Repeat guest

| Loại khách | Booking | Cancellation rate |
|---|---:|---:|
| Khách mới (non-repeat) | 83,493 | 28.42% |
| Khách quay lại (repeat) | 3,144 | **8.24%** |

**Insight:** khách quay lại có tỷ lệ hủy thấp hơn rõ rệt (**8.24% so với 28.42%**). Tuy nhiên nhóm này chỉ chiếm khoảng 3.6% tổng booking.

## 12. Phân khúc khách hàng rule-based

Phân khúc dùng hai ngưỡng tự chọn:

- Lead time ≤ 30 ngày: **Đặt gấp**; > 30 ngày: **Đặt sớm**
- ADR < 100: **Giá thấp**; ≥ 100: **Giá cao**

| Segment | Booking | Cancellation rate | ADR trung bình |
|---|---:|---:|---:|
| Đặt sớm – Giá cao | 27,125 | **39.56%** | 146.02 |
| Đặt sớm – Giá thấp | 25,423 | 29.88% | 72.74 |
| Đặt gấp – Giá cao | 15,084 | 21.29% | 149.41 |
| Đặt gấp – Giá thấp | 19,005 | **12.88%** | 64.31 |

**Insight:** "Đặt sớm – Giá cao" có tỷ lệ hủy cao nhất (39.56%), "Đặt gấp – Giá thấp" thấp nhất (12.88%). Trong cùng nhóm lead time, nhóm giá cao hủy nhiều hơn nhóm giá thấp.

> Đây là cách phân khúc theo ngưỡng do dự án định nghĩa (rule-based), **không phải** clustering tự động.

## 13. Market segment × lead time

| Market segment + lead time | Cancellation rate |
|---|---:|
| Online TA + 180+ ngày | **51.86%** |
| Online TA + 91–180 ngày | 43.52% |
| Online TA + 31–90 ngày | 39.16% |
| Online TA + 8–30 ngày | 31.30% |
| Online TA + 0–7 ngày | 8.87% |

**Insight quan trọng nhất:** rủi ro hủy không chỉ nằm ở một segment riêng lẻ mà tăng mạnh khi **Online TA kết hợp với lead time dài**. Online TA + 180+ ngày đạt **51.86%**, trong khi Online TA + 0–7 ngày chỉ 8.87%.

*(Chỉ xét các tổ hợp có từ 100 booking trở lên.)*

## 14. Tương quan

| Mối quan hệ | Hệ số Pearson |
|---|---:|
| Lead time vs cancellation | **0.1835** |
| Total nights vs cancellation | **0.0813** |

Cả hai đều dương nhưng yếu. Vì vậy kết quả được diễn đạt theo hướng "có liên quan", "tỷ lệ hủy cao hơn được ghi nhận", không dùng "gây ra".

## 15. Gợi ý (cần kiểm chứng)

Các gợi ý dưới đây xuất phát từ kết quả mô tả, cần kiểm chứng thêm trước khi áp dụng.

1. **Theo dõi booking lead time dài.** Nhóm 180+ ngày có tỷ lệ hủy 39.85%; có thể thử cơ chế nhắc nhở / xác nhận lại trước ngày đến.
2. **Theo dõi riêng Online TA.** Tỷ lệ hủy 35.55%, tăng lên 51.86% ở lead time 180+ ngày; dashboard có thể có KPI hoặc cảnh báo riêng cho tổ hợp này.
3. **Tận dụng khách quay lại.** Tỷ lệ hủy chỉ 8.24%; có thể phân tích thêm về loyalty / retention.
4. **Điều tra nhóm Non Refund.** 94.70% là tín hiệu bất thường; cần kiểm tra cơ cấu booking và cách ghi nhận trạng thái trước khi thay đổi chính sách.
5. **Chuẩn bị cho mùa cao điểm (tháng 7–8).** ADR và tỷ lệ hủy cùng cao; theo dõi đồng thời volume, ADR và cancellation.

## 16. Hạn chế

- Phân tích chủ yếu là mô tả và liên hệ; tương quan không chứng minh nhân quả.
- Dataset không có mã booking; bản ghi trùng (31,980 dòng) được xác định theo toàn bộ thuộc tính và có thể gồm một số booking thật giống hệt nhau.
- Tháng 7–8 có 3 năm dữ liệu, các tháng khác 2 năm, nên so sánh volume giữa các tháng bị lệch.
- Còn 1,052 booking có ADR = 0 (phần lớn thuộc segment Complementary), được giữ lại và kéo ADR trung bình xuống.
- Một số booking có `country` chưa xác định (giá trị `'NULL'` dạng text) vẫn được giữ lại.
- Phân khúc khách hàng là rule-based; ngưỡng ADR = 100 và lead time = 30 ngày do dự án chọn.
- Một số nhóm rất nhỏ (kênh Undefined, Non Refund, Refundable) không phù hợp để suy luận rộng.

## 17. Key takeaways

1. **Tỷ lệ hủy tổng thể là 27.68%.**
2. **Tỷ lệ hủy tăng mạnh theo lead time:** 8.51% → 39.85%.
3. **Online TA là nhóm rủi ro hủy lớn:** 35.55%, lên đến 51.86% ở lead time 180+ ngày.
4. **Tháng 8** có volume, ADR và tỷ lệ hủy cao nhất (lưu ý volume bị ảnh hưởng bởi số năm dữ liệu).
5. **Khách quay lại hủy ít hơn nhiều:** 8.24% so với 28.42%.
