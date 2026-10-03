# Hotel Booking Cancellation Analysis

> Dự án phân tích dữ liệu bằng **SQL Server + Power BI**: tìm hiểu những đặc điểm của booking gắn với tỷ lệ hủy phòng cao hơn (loại khách sạn, mùa vụ, lead time, kênh/phân khúc, quốc gia, deposit, khách quay lại).
>
> *A SQL Server + Power BI project exploring which booking characteristics are associated with higher cancellation rates.*

## Mục lục

- [Tổng quan](#tổng-quan)
- [Dữ liệu](#dữ-liệu)
- [Kết quả chính](#kết-quả-chính)
- [Quy trình xử lý dữ liệu](#quy-trình-xử-lý-dữ-liệu)
- [Phương pháp phân tích](#phương-pháp-phân-tích)
- [Dashboard](#dashboard)
- [Cấu trúc repository](#cấu-trúc-repository)
- [Cách chạy lại](#cách-chạy-lại)
- [Hạn chế](#hạn-chế)
- [Tác giả](#tác-giả)

## Tổng quan

Dự án là bài **Final Data Analytics Project**, sử dụng SQL Server cho làm sạch và phân tích, Power BI cho mô hình dữ liệu và dashboard.

**Các câu hỏi chính**

1. Bức tranh tổng thể về booking và tỷ lệ hủy là gì?
2. Tỷ lệ hủy khác nhau thế nào giữa City Hotel và Resort Hotel, giữa các tháng?
3. Lead time dài hơn có đi kèm tỷ lệ hủy cao hơn không?
4. Kênh phân phối và market segment nào có tỷ lệ hủy cao?
5. Deposit type và khách quay lại (repeat guest) liên quan thế nào đến việc hủy?
6. Các phân khúc khách hàng theo lead time và ADR có hành vi hủy khác nhau ra sao?

> Phân tích mang tính **mô tả và liên hệ (association)**, không kết luận quan hệ nhân quả.

## Dữ liệu

- **Nguồn:** bộ dữ liệu *Hotel Booking Demand* trên Kaggle (xem thêm bài báo gốc: Antonio, Almeida & Nunes, 2019, *Data in Brief*). Vui lòng xem điều khoản sử dụng tại trang gốc.
- **Phạm vi:** 119,390 booking, 32 cột, ngày đến từ năm 2015 đến 2017, gồm 2 loại khách sạn (City Hotel, Resort Hotel).
- **Sau làm sạch:** 86,637 booking.

## Kết quả chính

| Chỉ số | Kết quả |
|---|---:|
| Booking sau làm sạch | 86,637 |
| Booking bị hủy | 23,985 |
| **Tỷ lệ hủy tổng thể** | **27.68%** |
| ADR trung bình / trung vị | 107.18 / 99.00 |
| Lead time trung bình / trung vị | 80.3 / 50 ngày |
| Số đêm lưu trú trung bình | 3.65 đêm |
| Tháng có tỷ lệ hủy cao nhất | August: 32.36% |
| Market segment có tỷ lệ hủy cao nhất (volume lớn) | Online TA: 35.55% |
| Nhóm lead time có tỷ lệ hủy cao nhất | 180+ ngày: 39.85% (so với 8.51% ở nhóm 0–7 ngày) |
| Online TA + lead time 180+ ngày | 51.86% |
| Repeat guest / khách mới | 8.24% / 28.42% |

Chi tiết đầy đủ: [`docs/analysis_vi.md`](docs/analysis_vi.md) (tiếng Việt) · [`docs/analysis_en.md`](docs/analysis_en.md) (English).

## Quy trình xử lý dữ liệu

Toàn bộ thực hiện bằng SQL Server (xem [`sql/hotel_bookings_analysis.sql`](sql/hotel_bookings_analysis.sql)):

1. Sao lưu bảng gốc (`hotel_bookings_raw_backup`).
2. Kiểm tra số dòng, cấu trúc bảng, missing values, trùng lặp và booking bất thường.
3. Thay 4 giá trị thiếu ở `children` bằng 0.
4. Giữ NULL ở `agent` / `company` vì mang ý nghĩa nghiệp vụ (đặt trực tiếp / khách cá nhân).
5. Chuẩn hóa chuỗi `'NULL'` ở `agent` / `company` về NULL thật và đổi sang kiểu số.
6. Loại booking, loại trùng, loại 0 đêm và outlier ADR.
7. Tạo view cho Power BI: `vw_hotel_bookings`, `vw_date_dimension`.

| Bước | Số dòng loại bỏ | Còn lại |
|---|---:|---:|
| Dữ liệu gốc | – | 119,390 |
| Booking không có khách (`adults = children = babies = 0`) | 180 | 119,210 |
| ADR âm | 1 | 119,209 |
| Bản ghi trùng lặp (toàn bộ 32 cột giống nhau) | 31,980 | 87,229 |
| Tổng số đêm lưu trú = 0 | 591 | 86,638 |
| ADR > 1,000 (outlier) | 1 | **86,637** |

## Phương pháp phân tích

**Phân tích mô tả**

- Số booking, tỷ lệ hủy; trung bình, trung vị, độ lệch chuẩn, phân vị của ADR và lead time
- Tỷ lệ hủy theo: loại khách sạn, tháng, kênh phân phối, market segment, nhóm lead time, quốc gia, deposit type, repeat guest
- ADR và số booking theo loại khách sạn; số đêm lưu trú

**Phân tích nâng cao**

- Tương quan Pearson: `lead_time` vs `is_canceled` = **0.1835**; `total_nights` vs `is_canceled` = **0.0813** (đều dương, yếu)
- Phân khúc khách hàng **rule-based** theo lead time (≤ 30 / > 30 ngày) và ADR (< 100 / ≥ 100)
- Phân tích chéo market segment × nhóm lead time

> **Lưu ý:** phân khúc khách hàng là **rule-based** với ngưỡng tự chọn, **không phải** K-means hay thuật toán clustering khác.

## Dashboard

Dashboard Power BI (`powerbi/hotel_booking_dashboard.pbix`) là sản phẩm tương tác chính, kết nối tới hai SQL view ở trên.

<!-- Thêm ảnh chụp dashboard vào assets/dashboard/ rồi bỏ comment các dòng dưới -->
<!--
![Overview](assets/dashboard/overview.png)
![Cancellation drivers](assets/dashboard/cancellation_drivers.png)
![Customer segments](assets/dashboard/customer_segments.png)
-->

## Cấu trúc repository

```text
hotel-booking-cancellation-analysis/
├── README.md
├── data/
│   └── hotel_bookings.csv
├── sql/
│   └── hotel_bookings_analysis.sql
├── powerbi/
│   └── hotel_booking_dashboard.pbix
├── docs/
│   ├── analysis_vi.md
│   └── analysis_en.md
└── assets/
    └── dashboard/
```

## Cách chạy lại

1. Import `data/hotel_bookings.csv` vào SQL Server thành bảng `hotel_bookings`.
2. Chạy `sql/hotel_bookings_analysis.sql` theo thứ tự (sao lưu → làm sạch → phân tích → tạo view).
3. Mở file `.pbix` trong Power BI Desktop, trỏ nguồn dữ liệu tới `vw_hotel_bookings` và `vw_date_dimension`.

## Công cụ

- **SQL Server**: làm sạch, kiểm tra, tổng hợp và truy vấn phân tích
- **Power BI**: mô hình dữ liệu, DAX measures, dashboard
- **GitHub**: quản lý phiên bản và trình bày portfolio

## Hạn chế

- Chỉ xác định được mối liên hệ và xu hướng, không chứng minh nhân quả.
- Dataset không có mã booking, nên bản ghi trùng lặp được xác định theo toàn bộ thuộc tính; một số bản ghi giống hệt có thể là các booking thật và đã bị loại.
- Dữ liệu tháng 7–8 có 3 năm (2015–2017), các tháng khác chỉ 2 năm, nên so sánh **số lượng** booking giữa các tháng bị lệch (tỷ lệ hủy và ADR ít bị ảnh hưởng hơn).
- Phân khúc khách hàng phụ thuộc vào ngưỡng tự chọn.
- `Non Refund` có tỷ lệ hủy rất cao (94.70%) nhưng chỉ 1,037 booking; cần diễn giải cùng volume.
- Phân tích theo quốc gia chỉ mô tả, không giải thích nguyên nhân.

## Tác giả

**Lê Xuân Việt**
Data Analytics | SQL | Power BI
