# Analysis & Insights (English)

> Bản tiếng Việt: [analysis_vi.md](analysis_vi.md)

## Contents

1. [Context and objective](#1-context-and-objective)
2. [Data preparation](#2-data-preparation)
3. [Dataset overview](#3-dataset-overview)
4. [Hotel type](#4-hotel-type)
5. [Seasonality](#5-seasonality)
6. [Distribution channel](#6-distribution-channel)
7. [Market segment](#7-market-segment)
8. [Lead time](#8-lead-time-and-cancellation)
9. [Country](#9-country)
10. [Deposit type](#10-deposit-type)
11. [Repeat guest](#11-repeat-guest)
12. [Rule-based segmentation](#12-rule-based-customer-segmentation)
13. [Market segment × lead time](#13-market-segment--lead-time)
14. [Correlation](#14-correlation)
15. [Recommendations](#15-recommendations-to-validate)
16. [Limitations](#16-limitations)
17. [Key takeaways](#17-key-takeaways)

---

## 1. Context and objective

This project analyzes hotel booking data to understand booking behavior and the characteristics associated with **booking cancellation (`is_canceled`)**.

Factors examined: hotel type, arrival month, lead time, distribution channel, market segment, country, deposit type, repeat-guest status, ADR and length of stay.

> **Definitions:** *cancellation rate* = cancelled bookings / total bookings in the group. *ADR* = average daily rate (price per night). *Lead time* = days between booking and arrival.

## 2. Data preparation

The original dataset contains **119,390 bookings** (arrival dates from 2015 to 2017).

| Step | Action | Rows removed | Remaining |
|---|---|---:|---:|
| 0 | Original data | – | 119,390 |
| 1 | Remove bookings with no guests (`adults = children = babies = 0`) | 180 | 119,210 |
| 2 | Remove negative ADR | 1 | 119,209 |
| 3 | Remove duplicate records (identical on all 32 columns) | 31,980 | 87,229 |
| 4 | Remove zero-night stays | 591 | 86,638 |
| 5 | Remove ADR > 1,000 (outlier threshold chosen during inspection) | 1 | **86,637** |

Other handling:

- 4 NULL values in `children` were replaced with 0.
- NULLs in `agent` / `company` carry business meaning (direct booking, individual guest) and are not treated as errors; text `'NULL'` values were converted to real NULLs.
- `children`, `agent` and `company` were converted to numeric types.

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
| Mean lead time | **80.3 days** |
| Median lead time | **50 days** |
| Lead time P25 / P75 / P90 | 12 / 126 / 205 days |
| ADR P25 / P75 | 72.90 / 134.43 |
| Average length of stay | 3.65 nights |
| Length-of-stay range | 1–69 nights |

**Interpretation**

- More than one in four bookings (27.68%) was cancelled.
- Lead time is highly dispersed: mean 80.3 days, median 50 days, P90 205 days. The distribution is right-skewed, with a meaningful group of very early bookings.
- Mean ADR (107.18) sits above the median (99), so higher ADR observations pull the average up.

## 4. Hotel type

| Hotel | Bookings | Cancellation rate | Avg ADR |
|---|---:|---:|---:|
| City Hotel | 53,042 | **30.20%** | 111.66 |
| Resort Hotel | 33,595 | **23.71%** | 100.12 |

**Insight:** City Hotel's cancellation rate is about **6.50 percentage points** higher than Resort Hotel's, and its average ADR is also higher. This is a descriptive difference; the data does not explain why.

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

**Insight**

- **August** has the highest booking count (11,194), the highest cancellation rate (32.36%) and the highest average ADR (151.70).
- November has the lowest cancellation rate (21.40%).
- April–August all sit around or above 29%, clearly higher than the early-year months (22–25%). The high season combines more bookings with higher cancellation rates.

> **Note:** July and August contain three years of data (2015–2017) while other months contain two, so the **booking counts** for these months are partly inflated. Cancellation rate and ADR are less affected.

## 6. Distribution channel

| Channel | Bookings | Cancellation rate |
|---|---:|---:|
| TA/TO | 68,650 | **31.15%** |
| Direct | 12,803 | 14.98% |
| Corporate | 5,001 | 12.82% |
| GDS | 178 | 20.22% |
| Undefined | 5 | 80.00% |

**Insight:** TA/TO combines very high volume (about 79% of bookings) with a 31.15% cancellation rate, well above Direct and Corporate. `Undefined` has only 5 bookings and should not be used for inference.

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

*The `Undefined` segment (2 bookings, 100% cancelled) is omitted because it is too small.*

**Insight**

- Online TA stands out: a **35.55% cancellation rate across 51,285 bookings** (about 59% of all bookings).
- Groups have the longest average lead time (148 days); Corporate and Complementary bookings are made much closer to arrival.

## 8. Lead time and cancellation

| Lead-time group | Bookings | Cancellation rate |
|---|---:|---:|
| 0–7 days | 17,855 | **8.51%** |
| 8–30 days | 16,234 | 25.50% |
| 31–90 days | 22,633 | 32.14% |
| 91–180 days | 18,190 | 35.07% |
| 180+ days | 11,725 | **39.85%** |

**Key insight:** cancellation rate rises steadily from **8.51%** (booked 0–7 days ahead) to **39.85%** (booked more than 180 days ahead), a gap of more than **31 percentage points**.

The Pearson correlation between `lead_time` and `is_canceled` is **0.1835** (positive but weak). Lead time is **associated with** cancellation, but should not be described as its direct cause.

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

**Insight:** PRT has the largest volume and a 36.37% cancellation rate. BRA (36.52%) and ITA (35.14%) are similarly high but with much lower volume. Country is useful for drill-down, but the data does not explain the causes of these differences.

## 10. Deposit type

| Deposit type | Bookings | Cancellation rate |
|---|---:|---:|
| Non Refund | 1,037 | **94.70%** |
| No Deposit | 85,493 | 26.88% |
| Refundable | 107 | 24.30% |

**Insight:** Non Refund shows a very high cancellation rate (94.70%), but only 1,037 bookings against 85,493 No Deposit bookings. Treat this as a **signal for further investigation**, not as evidence that deposit type causes cancellation.

## 11. Repeat guest

| Guest type | Bookings | Cancellation rate |
|---|---:|---:|
| New / non-repeat guest | 83,493 | 28.42% |
| Repeat guest | 3,144 | **8.24%** |

**Insight:** repeat guests cancel far less often (**8.24% vs 28.42%**), although they make up only about 3.6% of bookings.

## 12. Rule-based customer segmentation

The segmentation uses two manually selected thresholds:

- Lead time ≤ 30 days: **Last-minute**; > 30 days: **Early booking**
- ADR < 100: **Lower ADR**; ≥ 100: **Higher ADR**

| Segment | Bookings | Cancellation rate | Avg ADR |
|---|---:|---:|---:|
| Early booking – Higher ADR | 27,125 | **39.56%** | 146.02 |
| Early booking – Lower ADR | 25,423 | 29.88% | 72.74 |
| Last-minute – Higher ADR | 15,084 | 21.29% | 149.41 |
| Last-minute – Lower ADR | 19,005 | **12.88%** | 64.31 |

**Insight:** "Early booking – Higher ADR" has the highest cancellation rate (39.56%) and "Last-minute – Lower ADR" the lowest (12.88%). Within each lead-time group, the higher-ADR segment cancels more often.

> This is a project-defined, threshold-based segmentation, **not** an automatically learned clustering model.

## 13. Market segment × lead time

| Market segment + lead time | Cancellation rate |
|---|---:|
| Online TA + 180+ days | **51.86%** |
| Online TA + 91–180 days | 43.52% |
| Online TA + 31–90 days | 39.16% |
| Online TA + 8–30 days | 31.30% |
| Online TA + 0–7 days | 8.87% |

**Key insight:** cancellation risk is not only a segment-level pattern; it rises sharply when **Online TA is combined with long lead time**. Online TA + 180+ days reaches **51.86%**, versus 8.87% for Online TA + 0–7 days.

*(Only combinations with at least 100 bookings are considered.)*

## 14. Correlation

| Relationship | Pearson correlation |
|---|---:|
| Lead time vs cancellation | **0.1835** |
| Total nights vs cancellation | **0.0813** |

Both relationships are positive but weak. Results are therefore phrased as "associated with" or "a higher cancellation rate is observed", not "causes".

## 15. Recommendations (to validate)

The suggestions below follow from descriptive results and should be tested before being applied.

1. **Monitor long-lead-time bookings.** The 180+ day group has a 39.85% cancellation rate; reminder or reconfirmation workflows before arrival could be tested.
2. **Monitor Online TA separately.** Its cancellation rate is 35.55%, rising to 51.86% at 180+ days; the dashboard can carry a dedicated KPI or alert for this combination.
3. **Leverage repeat guests.** Their cancellation rate is only 8.24%; loyalty and retention patterns merit further analysis.
4. **Investigate the Non Refund segment.** The 94.70% rate is unusual; check booking mix and status-recording practices before any policy change.
5. **Prepare for peak season (July–August).** ADR and cancellation rate are both high; track volume, ADR and cancellations together.

## 16. Limitations

- The analysis is primarily descriptive and association-based; correlation does not establish causation.
- The dataset has no booking ID. Duplicates (31,980 rows) were identified on all attributes and may include some genuinely distinct, identical bookings.
- July and August have three years of data versus two for other months, which skews month-to-month volume comparisons.
- 1,052 bookings have ADR = 0 (mostly the Complementary segment); they were kept and pull average ADR down.
- Some bookings have an unknown `country` (text value `'NULL'`) and were retained.
- Customer segmentation is rule-based; ADR = 100 and lead time = 30 days are project-selected thresholds.
- Very small groups (Undefined channel, Non Refund, Refundable) are unsuitable for broad inference.

## 17. Key takeaways

1. **Overall cancellation rate is 27.68%.**
2. **Cancellation rises sharply with lead time:** 8.51% → 39.85%.
3. **Online TA is a major cancellation-risk segment:** 35.55%, reaching 51.86% at 180+ days.
4. **August** has the highest booking count, ADR and cancellation rate (volume is affected by uneven year coverage).
5. **Repeat guests cancel far less:** 8.24% vs 28.42%.
