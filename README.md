# 🌍 Iran Crisis - Global Market Impact Analysis
> An end-to-end data analytics project tracking the geopolitical 
> impact of the Iran Crisis (April 1–8, 2026) across 6 global 
> market dimensions using Excel, SQL, Python, and Power BI.

---

## 📊 Dashboard Preview

[Crisis Overview]<img width="1365" height="763" alt="Crisis_Overview" src="https://github.com/user-attachments/assets/455a2c23-f27e-4ac8-84ed-332ddcc540fa" />

---

## 🔍 Project Overview

This project analyzes how a geopolitical crisis cascades across 
multiple financial markets simultaneously.

### Markets Analyzed
| Dimension | Key Finding |
|---|---|
| 🛢️ Crude Oil | WTI price rose +20.36% from pre-crisis to peak |
| ⛽ Fuel Prices | Canada/UK absorbed 12% shock vs UAE's 3.2% |
| 📈 Equities | Energy stocks +6.8% while Broad Market lost -2.7% |
| 🚢 Shipping | Strait of Hormuz freight rates spiked significantly |
| 📰 Sentiment | Media sentiment turned Negative by Day 7 |
| 💱 Currency | INR and PKR showed highest volatility |

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| **Excel** | Data cleaning, pivot tables, rough dashboard |
| **SQL (PostgreSQL)** | Schema design, 7 analytical queries, multi-table JOIN |
| **Python (pandas, seaborn)** | Date parsing, correlation analysis, charts |
| **Power BI** | 4-page interactive dashboard |

---

## 📁 Project Structure
iran-crisis-market-analysis/
├── data/raw/          → Original 6 CSV datasets
├── data/processed/    → Cleaned exports for Power BI
├── excel/             → Pivot tables and rough dashboard
├── sql/               → Schema creation and 7 queries
├── python/            → Jupyter notebook with analysis
├── powerbi/           → Final interactive dashboard
└── screenshots/       → Dashboard page screenshots

---

## 🔑 Key SQL Queries

### Energy vs Broad Market Divergence (CASE WHEN)
```sql
SELECT 
    date,
    ROUND(AVG(CASE WHEN sector = 'Energy' THEN percent_change END), 2) AS energy_avg_change,
    ROUND(AVG(CASE WHEN sector <> 'Energy' THEN percent_change END), 2) AS broad_market_avg_change,
    ROUND(
        AVG(CASE WHEN sector = 'Energy' THEN percent_change END)
        -
        AVG(CASE WHEN sector <> 'Energy' THEN percent_change END),
        2
    ) AS divergence_percent
FROM iran_war_global_crisis.stock_data
GROUP BY date
ORDER BY date ASC;

```

### Countries Exceeding Global Fuel Average (Subquery)
```sql
SELECT country,
	ROUND(AVG(fuel_price),2) AS global_average_fuel_price
FROM iran_war_global_crisis.global_fuel_prices
	GROUP BY country
	HAVING AVG(fuel_price) > ( SELECT AVG(fuel_price) FROM iran_war_global_crisis.global_fuel_prices
	)
	ORDER BY global_average_fuel_price DESC;
```

---

## 📈 Dashboard Pages

| Page | Focus | Key Visual |
|---|---|---|
| 1 - Crisis Overview | Oil price timeline + KPIs | Line chart with crisis phases |
| 2 - Market Impact | Stock sector divergence | Dual-line + bar chart |
| 3 - Global Fuel | Country-wise impact | World map
| 4 - Shipping & Sentiment | Trade + media | Combo chart |

---

## 💡 FinTech Business Relevance

> For a FinTech company processing cross-border payments, this 
> analysis directly informs:
> - **Currency hedging decisions** - INR/PKR exposure during crisis
> - **Regional risk scoring** - oil-importing vs oil-producing nations
> - **Market timing** - energy sector rotation signals

---

## 🚀 How To Run

### Python Notebook
```bash
pip install pandas numpy matplotlib seaborn
jupyter notebook python/Iran_Crisis_Analysis.ipynb
```

### SQL Queries
Load CSV files into PostgreSQL and run `sql/Analysis_Using_SQL.sql`

---

## 👤 Author
**Vaishali Parmar**  
Data Analytics Portfolio Project  
Tools: Excel · SQL · Python · Power BI
