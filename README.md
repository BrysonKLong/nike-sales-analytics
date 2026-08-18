# Nike Sales Analytics

SQL and Power BI analysis of Nike retail sales data, focused on sales performance, profitability, regional trends, product lines, and sales channels.

## Project Overview

This project analyzes Nike sales data using SQL for data exploration and analysis and Power BI for interactive visualization.

The goal was to move beyond simply querying the data and identify trends that could support business decision-making.

## Tools & Technologies

- SQL / MySQL
- Power BI
- DAX
- Excel / CSV
- GitHub

## Analysis

The SQL analysis examined:

- Revenue and profit performance
- Sales by region
- Sales by product line
- Sales channel performance
- Monthly and yearly trends
- Discount patterns
- Units sold
- Customer demographics

Power BI was then used to build an interactive dashboard that allows the results to be explored by:

- Year
- Region
- Sales Channel
- Gender Category

## Key Business Insights

### Seasonal Online Profit Trends

Online sales showed recurring profit strength during the fall period, with November representing a notable profit peak across the available years of data. December also remained consistently strong.

Online sales also showed more frequent profit spikes than retail sales and became relatively more consistent as the fall period progressed.

One possible explanation is that seasonal promotional opportunities may have increased online purchasing activity. The online channel also had a higher average discount, which may have contributed to increased consumer activity during this period.

Because the dataset does not establish causation, further analysis would be needed to determine whether promotions, holidays, consumer behavior, or other external factors explain the pattern.

### Regional Performance

Profit varied across the six regions in the dataset, allowing regional performance to be compared through the Power BI dashboard.

### Product Line Performance

Training generated the highest total profit among the product lines, followed by Lifestyle and Basketball.

These differences can help identify which product categories are contributing most strongly to overall profitability.

## Power BI Dashboard

The interactive Power BI dashboard provides:

- KPI summaries for revenue, profit, units sold, and average discount
- Monthly profit trends
- Profit by region
- Profit by product line
- Interactive filtering by year, region, sales channel, and gender category

## Project Files

- `NikeSalesAnalysis.sql` — SQL analysis and queries
- `Nike_Sales_Analysis.pbix` — Power BI dashboard
- `Nike_Sales_Uncleaned.csv` — Original dataset used for analysis

## Limitations & Next Steps

The analysis identifies correlations and recurring patterns but does not establish the causes behind those patterns.

Potential next steps would include analyzing promotional events, holiday periods, pricing, product-level performance, and additional external factors to determine what is driving seasonal changes in sales and profitability.
