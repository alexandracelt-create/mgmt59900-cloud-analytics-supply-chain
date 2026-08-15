# Data Quality and Validation

## Data Quality Issues Identified

During development of the AWS supply chain analytics pipeline, several data-quality and schema issues were identified:

* Inconsistent date formats in the raw source data
* Numeric fields stored as strings rather than numeric data types
* Athena compatibility issues with timestamp-with-time-zone fields
* Corrupted Parquet files resulting from failed CTAS attempts
* Schema differences between Athena/Parquet and Amazon Redshift

## Quality and Cleanup Actions

The team addressed these issues through the following steps:

1. Applied explicit `CAST()` operations during Athena CTAS transformations to enforce appropriate data types.
2. Converted order and shipping date fields to valid timestamp formats.
3. Removed corrupted or failed Parquet output from Amazon S3.
4. Verified schema alignment between Athena and Amazon Redshift before loading the curated data.
5. Ran validation queries against the curated `fact_orders` table.
6. Verified row counts and schema integrity after loading the data into Redshift.

## Validation

A validation query was used to confirm that key fields in `curated.fact_orders` could be correctly converted to the required numeric and timestamp data types.

The validation included:

* `order_id`
* `customer_id`
* `total_items`
* `total_price`
* `total_profit`
* `late_delivery_risk`
* `order_date`
* `shipping_date`

## Future Data Quality Improvements

Potential future improvements include:

* Adding automated data-quality checks
* Adding null-value validation for critical fields
* Adding duplicate-record checks
* Implementing automated schema validation
* Adding partitioning to the curated Parquet layer
* Automating pipeline monitoring and failure alerts

