/* ============================================================
   SAO LƯU DỮ LIỆU GỐC
   ============================================================ */
SELECT *
INTO hotel_bookings_raw_backup
FROM hotel_bookings;

/* ============================================================
   KHÁM PHÁ DỮ LIỆU BAN ĐẦU
   ============================================================ */
-- 1.1 Tổng số dòng
SELECT COUNT(*) AS total_rows
FROM hotel_bookings; --119390

-- 1.2 Xem thử dữ liệu
SELECT TOP 10 *
FROM hotel_bookings;

-- 1.3 Kiểm tra cấu trúc bảng
EXEC sp_help 'hotel_bookings';



/* ============================================================
   KIỂM TRA DỮ LIỆU
   ============================================================ */
---------------------------------------------------------------
-- 2.1 Kiểm tra Missing Values
---------------------------------------------------------------
SELECT
SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS missing_children,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
SUM(CASE WHEN agent IS NULL THEN 1 ELSE 0 END) AS missing_agent,
SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS missing_company
FROM hotel_bookings;

---------------------------------------------------------------
-- 2.2 Kiểm tra Duplicate
---------------------------------------------------------------
SELECT *
FROM
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY
hotel,
is_canceled,
lead_time,
arrival_date_year,
arrival_date_month,
arrival_date_week_number,
arrival_date_day_of_month,
stays_in_weekend_nights,
stays_in_week_nights,
adults,
children,
babies,
meal,
country,
market_segment,
distribution_channel,
is_repeated_guest,
previous_cancellations,
previous_bookings_not_canceled,
reserved_room_type,
assigned_room_type,
booking_changes,
deposit_type,
agent,
company,
days_in_waiting_list,
customer_type,
adr,
required_car_parking_spaces,
total_of_special_requests,
reservation_status,
reservation_status_date

ORDER BY (SELECT NULL)
) rn
FROM hotel_bookings
)t
WHERE rn>1;

---------------------------------------------------------------
-- 2.3 Kiểm tra Booking không hợp lệ
---------------------------------------------------------------
SELECT *
FROM hotel_bookings
WHERE adults=0
AND children=0
AND babies=0;

---------------------------------------------------------------
-- 2.4 Kiểm tra ADR âm
---------------------------------------------------------------
SELECT *
FROM hotel_bookings
WHERE adr<0;

---------------------------------------------------------------
-- 2.5 Kiểm tra ADR quá lớn
---------------------------------------------------------------
SELECT *
FROM hotel_bookings
ORDER BY adr DESC;

---------------------------------------------------------------
-- 2.6 Kiểm tra Lead Time
---------------------------------------------------------------
SELECT
MIN(lead_time) AS min_lead,
MAX(lead_time) AS max_lead,
AVG(lead_time) AS avg_lead
FROM hotel_bookings;


---------------------------------------------------------------
-- 2.7 Kiểm tra Total Stay = 0
---------------------------------------------------------------
SELECT *
FROM hotel_bookings
WHERE stays_in_week_nights + stays_in_weekend_nights=0;


/* ============================================================
   LÀM SẠCH DỮ LIỆU
   ============================================================ */

---------------------------------------------------------------
-- 3.1 Children
---------------------------------------------------------------
/*
Có 4 giá trị NULL.
Do số lượng rất nhỏ và giá trị phổ biến nhất là 0,
thay thế NULL bằng 0.
*/

UPDATE hotel_bookings
SET children=0
WHERE children IS NULL;


---------------------------------------------------------------
-- 3.2 Country
---------------------------------------------------------------
/*
Giữ nguyên NULL để đảm bảo tính toàn vẹn của dữ liệu do không biết được chính xác quốc gia KH
*/

---------------------------------------------------------------
-- 3.3 Agent
---------------------------------------------------------------
/*
NULL ở agent nghĩa là khách đặt trực tiếp, là thông tin nghiệp vụ hợp lệ.
*/

---------------------------------------------------------------
-- 3.4 Company
---------------------------------------------------------------
/*
NULL nghĩa là booking cá nhân,
không phải dữ liệu lỗi.
*/


---------------------------------------------------------------
-- 3.5 Xóa booking không có khách
---------------------------------------------------------------
DELETE
FROM hotel_bookings
WHERE adults=0
AND children=0
AND babies=0;


---------------------------------------------------------------
-- 3.6 Xóa ADR âm
---------------------------------------------------------------
DELETE
FROM hotel_bookings
WHERE adr<0;

---------------------------------------------------------------
-- 3.7 Xóa Duplicate
---------------------------------------------------------------
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY

hotel,
is_canceled,
lead_time,
arrival_date_year,
arrival_date_month,
arrival_date_week_number,
arrival_date_day_of_month,
stays_in_weekend_nights,
stays_in_week_nights,
adults,
children,
babies,
meal,
country,
market_segment,
distribution_channel,
is_repeated_guest,
previous_cancellations,
previous_bookings_not_canceled,
reserved_room_type,
assigned_room_type,
booking_changes,
deposit_type,
agent,
company,
days_in_waiting_list,
customer_type,
adr,
required_car_parking_spaces,
total_of_special_requests,
reservation_status,
reservation_status_date

ORDER BY (SELECT NULL)
) rn

FROM hotel_bookings
)
DELETE
FROM duplicate_cte
WHERE rn>1;


/* ============================================================
   KIỂM TRA SAU KHI LÀM SẠCH
   ============================================================ */
---------------------------------------------------------------
-- 4.1 Kiểm tra số dòng còn lại
---------------------------------------------------------------
SELECT COUNT(*) AS total_rows_after_cleaning
FROM hotel_bookings


---------------------------------------------------------------
-- 4.2 Kiểm tra Missing Values
---------------------------------------------------------------
SELECT
SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS missing_children,
SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS missing_country,
SUM(CASE WHEN agent IS NULL THEN 1 ELSE 0 END) AS missing_agent,
SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS missing_company
FROM hotel_bookings;
--tất cả là 0

/* ============================================================
   XÓA TEXT 'NULL' Ở AGENT/COMPANY
   ============================================================ */
-- Kiểm tra trước
SELECT COUNT(*) AS agent_text_null   FROM hotel_bookings WHERE agent = 'NULL';
SELECT COUNT(*) AS company_text_null FROM hotel_bookings WHERE company = 'NULL';

-- Update về NULL thật
UPDATE hotel_bookings SET agent   = NULL WHERE agent = 'NULL';
UPDATE hotel_bookings SET company = NULL WHERE company = 'NULL';

-- Kiểm tra lại xem còn giá trị text bất thường nào khác không
SELECT DISTINCT agent   FROM hotel_bookings WHERE ISNUMERIC(agent) = 0   AND agent IS NOT NULL;
SELECT DISTINCT company FROM hotel_bookings WHERE ISNUMERIC(company) = 0 AND company IS NOT NULL; --không còn

/* ============================================================
   CONVERT LẠI ĐÚNG KIỂU DỮ LIỆU SỐ
   ============================================================ */
ALTER TABLE hotel_bookings ALTER COLUMN children tinyint;
ALTER TABLE hotel_bookings ALTER COLUMN agent smallint;
ALTER TABLE hotel_bookings ALTER COLUMN company smallint;



/* ============================================================
   XÓA CÁC TOTAL STAY = 0
   ============================================================ */
   -- Kiểm tra số dòng trước khi xóa
SELECT COUNT(*) AS total_stay_zero
FROM hotel_bookings
WHERE stays_in_week_nights + stays_in_weekend_nights = 0;

DELETE FROM hotel_bookings
WHERE stays_in_week_nights + stays_in_weekend_nights = 0;

/* ============================================================
   XÓA ADR OUTLIER QUÁ LỚN
   ============================================================ */
-- Xem trước outlier để chọn ngưỡng
SELECT TOP 20 * FROM hotel_bookings ORDER BY adr DESC;

-- Xóa outlier
DELETE FROM hotel_bookings
WHERE adr > 1000;


/* ============================================================
   KIỂM TRA DỮ LIỆU SAU KHI LÀM SẠCH
   ============================================================ */

SELECT COUNT(*) AS final_row_count FROM hotel_bookings;

SELECT
    SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS missing_children,
    SUM(CASE WHEN country  IS NULL THEN 1 ELSE 0 END) AS missing_country,
    SUM(CASE WHEN agent    IS NULL THEN 1 ELSE 0 END) AS missing_agent,
    SUM(CASE WHEN company  IS NULL THEN 1 ELSE 0 END) AS missing_company
FROM hotel_bookings;

-- Xác nhận không còn stay=0, không còn adr âm/quá lớn
SELECT COUNT(*) FROM hotel_bookings WHERE stays_in_week_nights + stays_in_weekend_nights = 0;
SELECT COUNT(*) FROM hotel_bookings WHERE adr < 0 OR adr > 1000;



/* ============================================================
   PHÂN TÍCH MÔ TẢ
   ============================================================ */

---------------------------------------------------------------
-- 1. TỔNG QUAN CHUNG: SỐ LƯỢNG BOOKING, TỶ LỆ HỦY PHÒNG
---------------------------------------------------------------
SELECT
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS total_canceled,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings;


---------------------------------------------------------------
-- 2. THỐNG KÊ MÔ TẢ CHO ADR (giá phòng/đêm)
--    trung bình, trung vị, độ lệch chuẩn, min/max
---------------------------------------------------------------
SELECT
    AVG(adr) AS mean_adr,
    STDEV(adr) AS stddev_adr,
    MIN(adr) AS min_adr,
    MAX(adr) AS max_adr,
    (SELECT DISTINCT PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY adr) OVER()
     FROM hotel_bookings) AS median_adr
FROM hotel_bookings;


---------------------------------------------------------------
-- 3. THỐNG KÊ MÔ TẢ CHO LEAD_TIME (số ngày đặt trước)
---------------------------------------------------------------
SELECT
    AVG(lead_time) AS mean_lead_time,
    STDEV(lead_time) AS stddev_lead_time,
    MIN(lead_time) AS min_lead_time,
    MAX(lead_time) AS max_lead_time,
    (SELECT DISTINCT PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY lead_time) OVER()
     FROM hotel_bookings) AS median_lead_time
FROM hotel_bookings;


---------------------------------------------------------------
-- 4. PHÂN VỊ (PERCENTILE) CỦA LEAD_TIME VÀ ADR
---------------------------------------------------------------
SELECT DISTINCT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY lead_time) OVER() AS lead_time_p25,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY lead_time) OVER() AS lead_time_p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY lead_time) OVER() AS lead_time_p90,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY adr) OVER() AS adr_p25,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY adr) OVER() AS adr_p75
FROM hotel_bookings;


---------------------------------------------------------------
-- 5. TỶ LỆ HỦY PHÒNG THEO LOẠI KHÁCH SẠN
---------------------------------------------------------------
SELECT
    hotel,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY hotel
ORDER BY cancel_rate_pct DESC;


---------------------------------------------------------------
-- 6. TỶ LỆ HỦY PHÒNG THEO THÁNG (xu hướng mùa vụ)
---------------------------------------------------------------
SELECT
    arrival_date_month,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct,
    AVG(adr) AS avg_adr
FROM hotel_bookings
GROUP BY arrival_date_month
ORDER BY 
    CASE arrival_date_month
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
        WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
        WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
        WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END;


---------------------------------------------------------------
-- 7. TỶ LỆ HỦY PHÒNG THEO KÊNH PHÂN PHỐI
---------------------------------------------------------------
SELECT
    distribution_channel,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY distribution_channel
ORDER BY cancel_rate_pct DESC;


---------------------------------------------------------------
-- 8. TỶ LỆ HỦY PHÒNG THEO MARKET SEGMENT
---------------------------------------------------------------
SELECT
    market_segment,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct,
    AVG(lead_time) AS avg_lead_time
FROM hotel_bookings
GROUP BY market_segment
ORDER BY cancel_rate_pct DESC;


---------------------------------------------------------------
-- 9. TỶ LỆ HỦY PHÒNG THEO NHÓM LEAD_TIME
---------------------------------------------------------------
SELECT
    CASE 
        WHEN lead_time <= 7 THEN '0-7 ngày'
        WHEN lead_time <= 30 THEN '8-30 ngày'
        WHEN lead_time <= 90 THEN '31-90 ngày'
        WHEN lead_time <= 180 THEN '91-180 ngày'
        ELSE '180+ ngày'
    END AS lead_time_group,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY 
    CASE 
        WHEN lead_time <= 7 THEN '0-7 ngày'
        WHEN lead_time <= 30 THEN '8-30 ngày'
        WHEN lead_time <= 90 THEN '31-90 ngày'
        WHEN lead_time <= 180 THEN '91-180 ngày'
        ELSE '180+ ngày'
    END
ORDER BY MIN(lead_time);


---------------------------------------------------------------
-- 10. TOP 10 QUỐC GIA CÓ NHIỀU BOOKING NHẤT & TỶ LỆ HỦY
---------------------------------------------------------------
SELECT TOP 10
    country,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY country
ORDER BY total_bookings DESC;


---------------------------------------------------------------
-- 11. ẢNH HƯỞNG CỦA DEPOSIT_TYPE ĐẾN TỶ LỆ HỦY
--     (đặt cọc có giảm khả năng hủy phòng không?)
---------------------------------------------------------------
SELECT
    deposit_type,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY deposit_type
ORDER BY cancel_rate_pct DESC;


---------------------------------------------------------------
-- 12. KHÁCH QUEN CÓ HỦY ÍT HƠN KHÁCH MỚI KHÔNG?
---------------------------------------------------------------
SELECT
    is_repeated_guest,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY is_repeated_guest;


---------------------------------------------------------------
-- 13. BOOKING THEO LOẠI KHÁCH SẠN
---------------------------------------------------------------
SELECT
hotel,
COUNT(*) bookings
FROM hotel_bookings
GROUP BY hotel

---------------------------------------------------------------
-- 14. ADR THEO LOẠI KHÁCH SẠN
---------------------------------------------------------------
SELECT
    hotel,
    AVG(adr) AS avg_adr,
    MIN(adr) AS min_adr,
    MAX(adr) AS max_adr
FROM hotel_bookings
GROUP BY hotel;

---------------------------------------------------------------
-- 15. THỐNG KÊ TỔNG SỐ ĐÊM Ở (TOTAL NIGHTS)
---------------------------------------------------------------
SELECT
    AVG(stays_in_week_nights + stays_in_weekend_nights) AS avg_total_nights,
    MIN(stays_in_week_nights + stays_in_weekend_nights) AS min_total_nights,
    MAX(stays_in_week_nights + stays_in_weekend_nights) AS max_total_nights
FROM hotel_bookings;



/* ============================================================
   PHÂN TÍCH NÂNG CAO
   ============================================================ */

---------------------------------------------------------------
-- 1. PHÂN TÍCH TƯƠNG QUAN: LEAD_TIME vs IS_CANCELED
---------------------------------------------------------------
SELECT
    (COUNT(*) * SUM(CAST(lead_time AS FLOAT) * CAST(is_canceled AS FLOAT)) 
        - SUM(CAST(lead_time AS FLOAT)) * SUM(CAST(is_canceled AS FLOAT)))
    /
    (SQRT(COUNT(*) * SUM(POWER(CAST(lead_time AS FLOAT),2)) - POWER(SUM(CAST(lead_time AS FLOAT)),2))
     * SQRT(COUNT(*) * SUM(POWER(CAST(is_canceled AS FLOAT),2)) - POWER(SUM(CAST(is_canceled AS FLOAT)),2)))
    AS correlation_leadtime_canceled
FROM hotel_bookings;
--kết quả: 0.1835

---------------------------------------------------------------
-- 2. TƯƠNG QUAN ĐƠN GIẢN: TOTAL_NIGHTS vs IS_CANCELED
---------------------------------------------------------------
SELECT
    (COUNT(*) * SUM(CAST(stays_in_week_nights+stays_in_weekend_nights AS FLOAT) * CAST(is_canceled AS FLOAT)) 
        - SUM(CAST(stays_in_week_nights+stays_in_weekend_nights AS FLOAT)) * SUM(CAST(is_canceled AS FLOAT)))
    /
    (SQRT(COUNT(*) * SUM(POWER(CAST(stays_in_week_nights+stays_in_weekend_nights AS FLOAT),2)) 
        - POWER(SUM(CAST(stays_in_week_nights+stays_in_weekend_nights AS FLOAT)),2))
     * SQRT(COUNT(*) * SUM(POWER(CAST(is_canceled AS FLOAT),2)) - POWER(SUM(CAST(is_canceled AS FLOAT)),2)))
    AS correlation_totalnights_canceled
FROM hotel_bookings;
--kết quả:0.0813

---------------------------------------------------------------
-- 3. PHÂN CỤM KHÁCH HÀNG
---------------------------------------------------------------
SELECT
    CASE 
        WHEN lead_time <= 30 AND adr < 100 THEN 'Đặt gấp - Giá thấp'
        WHEN lead_time <= 30 AND adr >= 100 THEN 'Đặt gấp - Giá cao'
        WHEN lead_time > 30 AND adr < 100 THEN 'Đặt sớm - Giá thấp'
        ELSE 'Đặt sớm - Giá cao'
    END AS customer_segment,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct,
    AVG(adr) AS avg_adr
FROM hotel_bookings
GROUP BY 
    CASE 
        WHEN lead_time <= 30 AND adr < 100 THEN 'Đặt gấp - Giá thấp'
        WHEN lead_time <= 30 AND adr >= 100 THEN 'Đặt gấp - Giá cao'
        WHEN lead_time > 30 AND adr < 100 THEN 'Đặt sớm - Giá thấp'
        ELSE 'Đặt sớm - Giá cao'
    END
ORDER BY cancel_rate_pct DESC;


---------------------------------------------------------------
-- 4. KẾT HỢP LEAD_TIME_GROUP (đã có) và MARKET_SEGMENT
---------------------------------------------------------------
SELECT
    market_segment,
    CASE 
        WHEN lead_time <= 7 THEN '0-7 ngày'
        WHEN lead_time <= 30 THEN '8-30 ngày'
        WHEN lead_time <= 90 THEN '31-90 ngày'
        WHEN lead_time <= 180 THEN '91-180 ngày'
        ELSE '180+ ngày'
    END AS lead_time_group,
    COUNT(*) AS total_bookings,
    SUM(CAST(is_canceled AS INT)) AS canceled_bookings,
    CAST(SUM(CAST(is_canceled AS INT)) AS FLOAT) / COUNT(*) * 100 AS cancel_rate_pct
FROM hotel_bookings
GROUP BY 
    market_segment,
    CASE 
        WHEN lead_time <= 7 THEN '0-7 ngày'
        WHEN lead_time <= 30 THEN '8-30 ngày'
        WHEN lead_time <= 90 THEN '31-90 ngày'
        WHEN lead_time <= 180 THEN '91-180 ngày'
        ELSE '180+ ngày'
    END
HAVING COUNT(*) >= 100  -- lọc bỏ nhóm quá nhỏ, tránh tỷ lệ % bị nhiễu
ORDER BY cancel_rate_pct DESC;




/* ============================================================
   TẠO VIEW CHO POWER BI
   ============================================================ */
CREATE VIEW vw_hotel_bookings AS
SELECT
    hotel,
    CAST(is_canceled AS INT) AS is_canceled,     -- đổi bit sang int
    lead_time,
    arrival_date_year,
    arrival_date_month,
    arrival_date_week_number,
    arrival_date_day_of_month,
    -- Tạo cột ngày thực tế để Power BI dùng Time Intelligence / slicer theo ngày
    TRY_CONVERT(date, 
        CONCAT(arrival_date_year, '-', arrival_date_month, '-', arrival_date_day_of_month)
    ) AS arrival_date,
    stays_in_weekend_nights,
    stays_in_week_nights,
    (stays_in_weekend_nights + stays_in_week_nights)   AS total_nights,
    adults,
    children,
    babies,
    (adults + children + babies)                       AS total_guests,
    meal,
    country,
    market_segment,
    distribution_channel,
    is_repeated_guest,
    previous_cancellations,
    previous_bookings_not_canceled,
    reserved_room_type,
    assigned_room_type,
    booking_changes,
    deposit_type,
    agent,
    company,
    days_in_waiting_list,
    customer_type,
    adr,
    required_car_parking_spaces,
    total_of_special_requests,
    reservation_status,
    reservation_status_date,
    -- Nhóm lead time (đã dùng nhiều lần trong phân tích)
    CASE 
        WHEN lead_time <= 7 THEN '0-7 ngày'
        WHEN lead_time <= 30 THEN '8-30 ngày'
        WHEN lead_time <= 90 THEN '31-90 ngày'
        WHEN lead_time <= 180 THEN '91-180 ngày'
        ELSE '180+ ngày'
    END AS lead_time_group,
    -- Phân cụm khách hàng rule-based
    CASE 
        WHEN lead_time <= 30 AND adr < 100 THEN 'Đặt gấp - Giá thấp'
        WHEN lead_time <= 30 AND adr >= 100 THEN 'Đặt gấp - Giá cao'
        WHEN lead_time > 30 AND adr < 100 THEN 'Đặt sớm - Giá thấp'
        ELSE 'Đặt sớm - Giá cao'
    END AS customer_segment
FROM hotel_bookings;


--Kiểm tra lại view vừa tạo
SELECT TOP 20 * FROM vw_hotel_bookings;
SELECT COUNT(*) FROM vw_hotel_bookings; --86637


--Tạo Date Table cho Power BI
CREATE VIEW vw_date_dimension AS
SELECT DISTINCT
    arrival_date,
    YEAR(arrival_date)                     AS year,
    MONTH(arrival_date)                    AS month_number,
    DATENAME(MONTH, arrival_date)          AS month_name,
    DATEPART(QUARTER, arrival_date)        AS quarter,
    DATENAME(WEEKDAY, arrival_date)        AS day_name
FROM vw_hotel_bookings
WHERE arrival_date IS NOT NULL;