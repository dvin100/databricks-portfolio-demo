from pyspark import pipelines as dp

catalog = spark.conf.get("catalog")
schema = spark.conf.get("schema")

@dp.table(name="ticker", comment="Raw ticker data streamed in from CSV files.")
def ticker_raw():
    return (
        spark.readStream
        .format("cloudFiles")
        .option("cloudFiles.format", "csv")
        .option("multiLine", "true")
        .option("header", "true")
        .load(f"/Volumes/{catalog}/{schema}/artifacts/ticker/*.csv")
    )