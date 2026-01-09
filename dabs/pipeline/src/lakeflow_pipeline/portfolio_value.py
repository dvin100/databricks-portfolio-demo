from pyspark import pipelines as dp
from pyspark.sql import functions as F
import os

# Try to get from spark.conf first, fallback to environment variables or defaults
catalog = spark.conf.get("catalog", os.environ.get("CATALOG", "demo"))
schema = spark.conf.get("schema", os.environ.get("SCHEMA", "portfolio"))

@dp.table(name="portfolio_value", comment="Joining the ticker and company_stocks tables to calculate the portfolio value.")
def portfolio_value():
    # Read from ticker table
    ticker_df = dp.read("ticker")
    
    # Read company_stocks table
    company_stocks_df = spark.table(f"{catalog}.{schema}.company_stocks")
    
    # Perform left join and calculate portfolio value
    return (
        ticker_df.alias("t")
        .join(company_stocks_df.alias("c"), "ticker", "left")
        .select(
            F.col("t.date"),
            F.col("t.ticker"),
            F.col("t.close"),
            F.col("c.company"),
            F.col("c.market"),
            F.round(F.col("c.stock_amount") * F.col("t.close"), 2).alias("total_value")
        )
        .where(F.col("date") > "2024-01-01")
    )