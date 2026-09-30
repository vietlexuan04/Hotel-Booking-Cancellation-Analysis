# Analysis & Insights — English

## 1. Context and objective

This project analyzes hotel booking data to understand booking behavior and the characteristics associated with **booking cancellation (`is_canceled`)**.

The analysis focuses on:

- Hotel type
- Seasonality / arrival month
- Lead time
- Distribution channel
- Market segment
- Country
- Deposit type
- Repeat-guest status
- ADR
- Length of stay

## 2. Data preparation

The original dataset contains **119,390 bookings**.

Main preparation steps:

- Checked missing values, duplicates and invalid bookings.
- Replaced 4 NULL values in `children` with 0.
- Treated NULLs in `agent` / `company` as potentially valid business semantics rather than automatically classifying them as data errors.
- Removed bookings with `adults = 0`, `children = 0`, `babies = 0`.
- Removed negative ADR values.
- Removed duplicate records based on booking attributes.
- Converted text `'NULL'` values in `agent` / `company` to real NULLs.
- Corrected numeric data types.
- Removed zero-night stays.
- Removed ADR values above 1,000 as an outlier threshold selected during data inspection.

After cleaning, the analytical dataset contains **86,637 bookings**.

## 3. Dataset overview

| Metric | Result |
|---|---:|
| Bookings after cleaning | 86,637 |
| Cancelled bookings | 23,985 |
| Cancellation rate | **27.68%** |
| Mean ADR | **107.18** |
| Median ADR | **99.00** |
| ADR standard deviation | 51.31 |
| Mean lead time | **80 days** |
| Median lead time | **50 days** |
| Lead time P25 / P75 / P90 | 12 / 126 / 205 days |
| ADR P25 / P75 | 72.90 / 134.43 |
| Average length of stay | 3 nights |
| Length-of-stay range | 1–69 nights |

### Interpretation

The overall cancellation rate is **27.68%**, meaning more than one in four bookings in the analytical dataset were cancelled.

Lead time is highly dispersed: the mean is 80 days while the median is 50 days and P90 is 205 days. This indicates a right-skewed distribution with a meaningful group of early bookings.

ADR is also dispersed: the mean of 107.18 is above the median of 99, suggesting that higher ADR observations pull the average upward.

## 4. Cancellation by hotel type

| Hotel | Bookings | Cancellation rate |
|---|---:|---:|
| City Hotel | 53,042 | **30.20%** |
| Resort Hotel | 33,595 | **23.71%** |

### Insight

City Hotel has a cancellation rate approximately **6.50 percentage points** higher than Resort Hotel.

This is a descriptive difference between the two hotel types; the current analysis does not establish why the gap exists.

## 5. Seasonality

| Month | Bookings | Cancellation rate | Avg ADR |
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

- **August** has both the highest booking volume and the highest cancellation rate: 11,194 bookings and 32.36% cancellations.
- Average ADR also peaks in August at 151.70.
- November has the lowest cancellation rate at 21.40%.
- July–August stands out simultaneously in volume, ADR and cancellation rate.

The high-season period therefore combines stronger booking activity with higher observed cancellation rates in this dataset.

## 6. Distribution channel

| Channel | Bookings | Cancellation rate |
|---|---:|---:|
| TA/TO | 68,650 | **31.15%** |
| Direct | 12,803 | 14.98% |
| Corporate | 5,001 | 12.82% |
| GDS | 178 | 20.22% |
| Undefined | 5 | 80.00% |

### Insight

TA/TO combines very high volume with a 31.15% cancellation rate, materially above Direct and Corporate.

The `Undefined` category shows an 80% cancellation rate, but it contains only 5 bookings and should not be used for broad inference.

## 7. Market segment

| Market segment | Bookings | Cancellation rate | Avg lead time |
|---|---:|---:|---:|
| Online TA | 51,285 | **35.55%** | 80 days |
| Groups | 4,891 | 27.21% | 148 days |
| Aviation | 222 | 19.82% | 4 days |
| Offline TA/TO | 13,748 | 14.95% | 106 days |
| Direct | 11,652 | 14.87% | 49 days |
| Corporate | 4,155 | 12.20% | 16 days |
| Complementary | 682 | 12.17% | 14 days |

### Insight

Online TA is the most prominent high-volume segment, with a **35.55% cancellation rate across 51,285 bookings**.

Groups have the longest average lead time among the major segments at 148 days, while Corporate and Complementary bookings have substantially shorter lead times.

## 8. Lead time and cancellation

| Lead-time group | Bookings | Cancellation rate |
|---|---:|---:|
| 0–7 days | 17,855 | **8.51%** |
| 8–30 days | 16,234 | 25.50% |
| 31–90 days | 22,633 | 32.14% |
| 91–180 days | 18,190 | 35.07% |
| 180+ days | 11,725 | **39.85%** |

### Key insight

A clear gradient appears: cancellation rate increases from **8.51%** for bookings made 0–7 days before arrival to **39.85%** for bookings made more than 180 days in advance.

The gap between these groups is more than **31 percentage points**.

The Pearson correlation between `lead_time` and `is_canceled` is **0.1835**, indicating a weak positive linear relationship. Therefore, lead time should be described as being associated with cancellation rather than as a direct cause of cancellation.

## 9. Country

Top 10 countries by booking volume:

| Country | Bookings | Cancellation rate |
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

PRT has the highest booking volume among the top 10 countries and a 36.37% cancellation rate. BRA has a slightly higher cancellation rate at 36.52%, but with much lower volume.

Country is useful as a drill-down dimension, but the dataset does not explain the causes behind country-level differences.

## 10. Deposit type

| Deposit type | Bookings | Cancellation rate |
|---|---:|---:|
| Non Refund | 1,037 | **94.70%** |
| No Deposit | 85,493 | 26.88% |
| Refundable | 107 | 24.30% |

### Insight

Non Refund shows a very high cancellation rate of 94.70%, but the segment contains only 1,037 bookings compared with 85,493 No Deposit bookings.

This should be treated as a **signal for further investigation**, not as evidence that deposit type directly causes cancellation.

## 11. Repeat guest

| Guest type | Bookings | Cancellation rate |
|---|---:|---:|
| New / non-repeat guest | 83,493 | 28.42% |
| Repeat guest | 3,144 | **8.24%** |

### Insight

Repeat guests have a substantially lower cancellation rate: **8.24% versus 28.42%** for non-repeat guests.

This suggests that repeat-guest status is a useful dimension for future cancellation-risk and retention analysis.

## 12. Rule-based customer segmentation

The segmentation uses two manually selected thresholds:

- Lead time ≤ 30 days → Last-minute
- Lead time > 30 days → Early booking
- ADR < 100 → Lower ADR
- ADR ≥ 100 → Higher ADR

| Segment | Bookings | Cancellation rate | Avg ADR |
|---|---:|---:|---:|
| Early booking – Higher ADR | 27,125 | **39.56%** | 146.02 |
| Early booking – Lower ADR | 25,423 | 29.88% | 72.74 |
| Last-minute – Higher ADR | 15,084 | 21.29% | 149.41 |
| Last-minute – Lower ADR | 19,005 | **12.88%** | 64.31 |

### Insight

The **Early booking – Higher ADR** segment has the highest cancellation rate at 39.56%, while **Last-minute – Lower ADR** has the lowest at 12.88%.

This is a project-defined analytical segmentation, not an automatically learned clustering model.

## 13. Market segment × lead time

One of the strongest patterns appears when Online TA is combined with long lead time:

| Market segment + lead time | Cancellation rate |
|---|---:|
| Online TA + 180+ days | **51.86%** |
| Online TA + 91–180 days | 43.52% |
| Online TA + 31–90 days | 39.16% |
| Online TA + 8–30 days | 31.30% |
| Online TA + 0–7 days | 8.87% |

### Key insight

Cancellation risk is not only a channel/segment-level pattern; it becomes much more pronounced when **Online TA is combined with long lead time**.

Online TA + 180+ days reaches **51.86% cancellation**, compared with 8.87% for Online TA + 0–7 days.

This is an excellent dimension for a Power BI heatmap.

## 14. Correlation and interpretation

| Relationship | Correlation |
|---|---:|
| Lead time vs cancellation | **0.1835** |
| Total nights vs cancellation | **0.0813** |

Both relationships are positive but weak. The project should therefore use language such as **“associated with”, “shows a positive relationship” and “higher cancellation rate is observed”** rather than **“causes”**.

## 15. Business implications / recommendations

### 1. Monitor long-lead-time bookings

The 180+ day group has a 39.85% cancellation rate. This group can be prioritized for reminder or reconfirmation workflows before arrival.

### 2. Monitor Online TA separately

Online TA has a 35.55% cancellation rate and becomes particularly high at long lead times. The dashboard can include a dedicated KPI or alert for this combination.

### 3. Leverage repeat-guest behavior

Repeat guests have only an 8.24% cancellation rate. Further analysis can explore loyalty and retention patterns and whether repeat-guest programs are associated with more stable bookings.

### 4. Investigate the Non Refund segment

The 94.70% cancellation rate is an unusual signal. Before changing policy, the segment should be investigated for booking mix, operational processes and status-recording behavior.

### 5. Prepare for peak season

July–August combines higher ADR with higher cancellation rates. The dashboard can monitor booking volume, ADR and cancellation together during the peak period.

## 16. Limitations

- The analysis is primarily descriptive and association-based.
- Correlation does not establish causation.
- Customer segmentation is rule-based.
- Some categories have very small volumes, such as Undefined channel, making them unsuitable for broad inference.
- ADR = 100 and lead time = 30 days are project-selected analytical thresholds.

## 17. Five insights to put on the presentation

1. **Overall cancellation rate = 27.68%.**
2. **Cancellation rises sharply with lead time: 8.51% → 39.85%.**
3. **Online TA is a major cancellation-risk segment: 35.55%, reaching 51.86% at 180+ days.**
4. **August combines the highest booking volume, ADR and cancellation rate.**
5. **Repeat guests show a much lower cancellation rate: 8.24% vs 28.42%.**
