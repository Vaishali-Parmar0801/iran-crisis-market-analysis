CREATE SCHEMA iran_war_global_crisis;

CREATE TABLE iran_war_global_crisis.crude_oil(
	date DATE,
	WTI_Crude_USD_per_barrel NUMERIC(10,2),
	Brent_Crude_USD_per_barrel NUMERIC(10,2),
	OPEC_Basket_USD_per_barrel NUMERIC(10,2),
	Day_of_Week VARCHAR(20),
	Trading_Volume_Million_Barrels NUMERIC(10,2)
);

SELECT * FROM iran_war_global_crisis.crude_oil;

CREATE TABLE iran_war_global_crisis.global_fuel_prices (
    date DATE,
    country VARCHAR(50),
    fuel_price NUMERIC(10,2),
    currency VARCHAR(10),
    days_since_crisis_start INT,
    crisis_phase VARCHAR(50)
);

SELECT * FROM iran_war_global_crisis.global_fuel_prices;

CREATE TABLE iran_war_global_crisis.currency_data(
	Date DATE,
	Currency_Pair VARCHAR(50),
	Exchange_Rate NUMERIC(10,2),
	Daily_Change_Percent NUMERIC(10,2),
	Volatility_Index NUMERIC(10,2)
);

SELECT * FROM iran_war_global_crisis.currency_data;

CREATE TABLE iran_war_global_crisis.shipping_data(
	Date DATE,
	Shipping_Route VARCHAR(50),
	Daily_Vessels_Passed NUMERIC(10,2),
	Avg_Freight_Rate NUMERIC(10,2),
	Capacity_Utilization_Percent INT,
	Days_Delay_Average NUMERIC(10,2),
	Insurance_Premium_Increase_Percent INT
);

SELECT * FROM iran_war_global_crisis.shipping_data;

CREATE TABLE iran_war_global_crisis.stock_data(
	Date DATE,
	Stock_Symbol VARCHAR(50),
	Opening_Price NUMERIC(10,2),
	Closing_Price NUMERIC(10,2),
	Percent_Change NUMERIC(10,2),
	Trading_Volume INT,
	Sector VARCHAR(50)
);

SELECT * FROM iran_war_global_crisis.stock_data;

CREATE TABLE iran_war_global_crisis.sentiment_data(
	Date DATE,
	News_Source VARCHAR(50),
	Article_Mentions INT,
	Sentiment_Score NUMERIC(10,2),
	Sentiment_Label VARCHAR(50),
	Headline_Avg_Length INT,
	Shares_and_Engagement INT
);

SELECT * FROM iran_war_global_crisis.sentiment_data;

-- Q:1 Oil price average by crisis phase 

SELECT crisis_phase,
	ROUND(AVG(fuel_price),2) AS avg_fuel_price
FROM iran_war_global_crisis.global_fuel_prices
GROUP BY crisis_phase
ORDER BY avg_fuel_price DESC;

-- Q:2 Top 5 countries by fuel price % increase

SELECT country,
	ROUND((MAX(fuel_price)-MIN(fuel_price))/MIN(fuel_price)*100,2)
	AS fuel_price_increasing_percentage
FROM iran_war_global_crisis.global_fuel_prices
	WHERE currency = 'USD'
	GROUP BY country
	ORDER BY fuel_price_increasing_percentage DESC
	LIMIT 5;

-- Q:3 Daily energy vs broad market divergence

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

-- Q:4 Which shipping route had highest freight spike

SELECT shipping_route,
	ROUND((MAX(Avg_Freight_Rate)-MIN(Avg_Freight_Rate))/MIN(Avg_Freight_Rate)*100,2) 
	AS highest_freight_spike
FROM iran_war_global_crisis.shipping_data
	GROUP BY shipping_route
	ORDER BY highest_freight_spike DESC
	LIMIT 5;

-- Q:5 Correlation between sentiment score and article volume

SELECT date,
		ROUND(AVG(sentiment_score),2) AS avg_news_sentiment,
		SUM(Article_Mentions) AS Total_articles,
	CASE
		WHEN AVG(sentiment_score) > 0.1 THEN 'positive'
		WHEN AVG(sentiment_score) < 0 THEN 'Negative'
		ELSE 'neutral'
	END as sentiment_label
FROM iran_war_global_crisis.sentiment_data
	GROUP BY date
	ORDER BY date;

-- Q:6 Countries where fuel price exceeded global average

SELECT country,
	ROUND(AVG(fuel_price),2) AS global_average_fuel_price
FROM iran_war_global_crisis.global_fuel_prices
	GROUP BY country
	HAVING AVG(fuel_price) > ( SELECT AVG(fuel_price) FROM iran_war_global_crisis.global_fuel_prices
	)
	ORDER BY global_average_fuel_price DESC;
	
-- Full Crisis Summery ( Joined Metrics)

SELECT 
    co.date,
    co.WTI_Crude_USD_per_barrel,
    co.Brent_Crude_USD_per_barrel,
    
    fuel.avg_usd_fuel_price,
    
    curr.usd_index_rate,
    curr.avg_volatility,
    
    ship.avg_freight_rate,
    ship.avg_delay_days,
    
    stk.energy_avg_change,
    stk.market_avg_change,
    
    sent.avg_sentiment,
    sent.total_articles

FROM iran_war_global_crisis.crude_oil co

-- Fuel: average USD-only fuel price per day
LEFT JOIN (
    SELECT date, 
           ROUND(AVG(fuel_price),2) AS avg_usd_fuel_price
    FROM iran_war_global_crisis.global_fuel_prices
    WHERE currency = 'USD'
    GROUP BY date
) fuel ON co.date = fuel.date

-- Currency: USD Index rate per day
LEFT JOIN (
    SELECT date,
           ROUND(AVG(CASE WHEN currency_pair = 'USD_Index' 
                     THEN exchange_rate END),2) AS usd_index_rate,
           ROUND(AVG(volatility_index),2)        AS avg_volatility
    FROM iran_war_global_crisis.currency_data
    GROUP BY date
) curr ON co.date = curr.date

-- Shipping: average across all routes per day
LEFT JOIN (
    SELECT date,
           ROUND(AVG(avg_freight_rate),2)    AS avg_freight_rate,
           ROUND(AVG(days_delay_average),2)  AS avg_delay_days
    FROM iran_war_global_crisis.shipping_data
    GROUP BY date
) ship ON co.date = ship.date

-- Stocks: energy vs market divergence per day
LEFT JOIN (
    SELECT date,
           ROUND(AVG(CASE WHEN sector = 'Energy' 
                     THEN percent_change END),2) AS energy_avg_change,
           ROUND(AVG(CASE WHEN sector = 'Broad Market' 
                     THEN percent_change END),2) AS market_avg_change
    FROM iran_war_global_crisis.stock_data
    GROUP BY date
) stk ON co.date = stk.date

-- Sentiment: daily average per day
LEFT JOIN (
    SELECT date,
           ROUND(AVG(sentiment_score),2) AS avg_sentiment,
           SUM(article_mentions)          AS total_articles
    FROM iran_war_global_crisis.sentiment_data
    GROUP BY date
) sent ON co.date = sent.date

WHERE co.date >= '2026-04-01'
ORDER BY co.date;




