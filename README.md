# Cloud Analytics Pipeline for Supply Chain

## MGMT 59900 – Big Data Analytics in the Cloud

**Track:** Supply Chain
**Group:** Group 6
**Team:** George Wajda, Christine Kumiko Chiba, Alexandra Robinson

---

## 1. Project Overview

This project develops a cloud-native analytics pipeline on Amazon Web Services (AWS) to analyze operational performance using the DataCo Supply Chain dataset.

The project focuses on delivery performance, regional order patterns, profitability, and operational risk, particularly late deliveries. The goal is to provide supply chain, operations, finance, and analytics stakeholders with a centralized, queryable source of information rather than relying on disconnected or ad hoc reporting.

The pipeline follows a Bronze/Silver/Gold architecture:

**Raw Data → Amazon S3 → AWS Glue → Amazon Athena → Curated Parquet → Amazon Redshift Serverless → Gold Analytics Views → Amazon QuickSight**

The project demonstrates data ingestion, cloud storage, cataloging, transformation, warehouse loading, data validation, analytical querying, cost control, and dashboard development.

---

## 2. Business Problem

The supply chain organization needs better visibility into operational and financial performance.

The primary business questions addressed by this project are:

* How are deliveries performing across regions?
* Where is late-delivery risk concentrated?
* Which shipping modes are most effective?
* Which regions generate the greatest profitability?
* Which customer segments generate the most orders?
* How do order volume and profitability change over time?

The project creates a centralized cloud analytics pipeline that allows these questions to be answered using repeatable SQL queries and analytical views.

---

## 3. Stakeholders

| Stakeholder                          | Interest / Decision Supported                                             |
| ------------------------------------ | ------------------------------------------------------------------------- |
| Supply Chain / Operations Leadership | Delivery performance and late-delivery risk by region and shipping mode   |
| Finance / FP&A                       | Profitability by order, region, and shipping mode                         |
| Regional Operations                  | Regional order patterns and volume visibility                             |
| Analytics / Data Team                | A governed Gold-layer model for repeatable KPI reporting and dashboarding |

---

## 4. Dataset

The project uses the **DataCo Supply Chain dataset**.

The dataset contains order and shipment information that can be used to analyze delivery performance, profitability, customer segments, regions, and shipping modes.

### Key Fields

Important fields include:

* Order ID
* Customer ID
* Order date
* Shipping date
* Total items
* Total price
* Total profit
* Delivery status
* Late-delivery risk
* Region
* Shipping mode

### Data Source

**Source:** DataCo Supply Chain dataset

**Format:** CSV

**Curated format:** Parquet

**Primary analytical table:** `fact_orders`

**Grain:** One row per order/shipment record

---

## 5. AWS Architecture

The project was implemented using AWS services to create an end-to-end cloud analytics pipeline.

### Architecture Flow

```text
DataCo Supply Chain Dataset
            |
            v
     Amazon S3 - Bronze
        Raw CSV Data
            |
            v
    AWS Glue Data Catalog
            |
            v
       Amazon Athena
     CTAS Transformation
            |
            v
     Amazon S3 - Silver
      Curated Parquet
            |
            v
 Amazon Redshift Serverless
       Gold Analytics
            |
            v
     Amazon QuickSight
        Dashboard
```

### AWS Services Used

| AWS Service                | Purpose                                        |
| -------------------------- | ---------------------------------------------- |
| Amazon S3                  | Raw and curated data storage                   |
| AWS Glue                   | Schema inference and Data Catalog registration |
| Amazon Athena              | SQL querying and CTAS transformation           |
| Amazon Redshift Serverless | Gold-layer warehouse and analytical views      |
| Amazon QuickSight          | Dashboard and visualization                    |

---

## 6. Data Pipeline

### 6.1 Bronze – Raw Layer

The original DataCo CSV data was uploaded to Amazon S3.

The Bronze layer preserves the original source data before transformation.

### 6.2 Cataloging

AWS Glue was used to register the raw data and create catalog information that allowed the dataset to be queried through Amazon Athena.

### 6.3 Silver – Curated Layer

Amazon Athena CTAS was used to transform the raw CSV data into Parquet format.

Explicit `CAST()` operations were applied to address data-type issues and ensure that numeric and timestamp fields were stored in appropriate formats.

### 6.4 Gold – Analytics Layer

The curated data was loaded into Amazon Redshift Serverless.

Gold-layer analytical views support:

* Order summaries
* Regional analysis
* Shipping-mode analysis
* Time-series analysis
* Profitability analysis
* Delivery-performance analysis

---

## 7. Data Quality

Several data-quality issues were identified during implementation.

### Issues Identified

* Inconsistent date formats
* Numeric fields stored as strings
* Timestamp-with-time-zone compatibility issues
* Corrupted Parquet files from failed CTAS attempts
* Schema mismatches between Athena/Parquet and Redshift

### Quality Checks and Actions

| Quality Check    | What Was Checked                    | Result / Action                                        |
| ---------------- | ----------------------------------- | ------------------------------------------------------ |
| Data types       | Numeric and date fields             | Explicit `CAST()` operations were applied              |
| Date fields      | Order and shipping dates            | Converted to valid timestamp formats                   |
| Schema alignment | Athena/Parquet and Redshift schemas | Schemas were compared and aligned                      |
| Row counts       | Source and loaded data              | Validation queries were performed                      |
| Parquet files    | Curated output integrity            | Failed/corrupted files were removed                    |
| Query validation | Curated `fact_orders`               | Validation query confirmed fields were correctly typed |

These checks helped confirm that the curated dataset was suitable for downstream Redshift modeling and Gold-layer analytics.

---

## 8. Data Model

The project uses a layered Bronze/Silver/Gold warehouse model.

### Bronze

Original raw CSV data stored in Amazon S3.

### Silver

Curated Parquet data generated through Athena CTAS.

### Gold

Redshift analytical tables and views used for reporting and analytics.

### Key Tables and Views

| Layer      | Tables / Views                            |
| ---------- | ----------------------------------------- |
| Dimensions | `dim_customer`, `dim_product`, `dim_date` |
| Facts      | `fact_orders`, `fact_shipments`           |
| Gold Views | `gold.orders_summary`                     |
| Gold Views | `gold.orders_by_region`                   |
| Gold Views | `gold.orders_by_shipping_mode`            |
| Gold Views | `gold.orders_over_time`                   |

---

## 9. Query and Analytics Workflow

The primary analytics workflow is:

```text
Raw CSV
  ↓
S3 Bronze
  ↓
AWS Glue Catalog
  ↓
Athena CTAS
  ↓
S3 Silver Parquet
  ↓
Redshift COPY
  ↓
Gold Views
  ↓
Analytics / QuickSight
```

Athena was used for transformation and validation, while Redshift Serverless was used for downstream analytical queries and Gold-layer views.

Example validation query:

```sql
SELECT
    CAST(order_id AS INTEGER),
    CAST(customer_id AS INTEGER),
    CAST(total_items AS INTEGER),
    CAST(total_price AS DOUBLE PRECISION),
    CAST(total_profit AS DOUBLE PRECISION),
    CAST(late_delivery_risk AS INTEGER),
    TO_TIMESTAMP(order_date, 'MM/DD/YYYY HH24:MI'),
    TO_TIMESTAMP(shipping_date, 'MM/DD/YYYY HH24:MI')
FROM curated.fact_orders;
```

---

## 10. Implementation Evidence

The project includes evidence demonstrating the AWS pipeline that was built and tested.

Implementation evidence includes:

* Amazon S3 raw storage
* Amazon S3 curated Parquet files
* AWS Glue Data Catalog
* Athena queries
* Athena CTAS transformations
* Redshift data loading
* Data-type validation
* Schema validation
* Gold-layer analytical views
* QuickSight datasets and dashboard evidence

Screenshots and supporting SQL files are included in the repository.

---

## 11. Key Findings and Analytics Results

The analysis focuses on customer segments, delivery performance, shipping modes, regional profitability, and trends over time.

### 11.1 Customer Segment

**Finding:** Consumer customers represent the largest customer segment, accounting for approximately **51% of total orders**, compared with approximately **30% for Home Office** and **19% for Corporate** customers.

**Business implication:** Because Consumer customers represent the largest share of order volume, the company could prioritize consumer-focused marketing, retention, and promotional strategies.

### 11.2 Late-Delivery Risk by Region

**Finding:** Late-delivery risk is not evenly distributed across regions. For example, **Region X had an estimated late-delivery rate of 24%**, compared with approximately **15% across the other regions**.

**Business implication:** Regions with higher late-delivery rates should receive additional operational attention. Management could investigate transportation providers, fulfillment processes, inventory availability, or other regional factors contributing to delays.

### 11.3 Shipping-Mode Performance

**Finding:** Shipping modes differ in both order volume and delivery performance. For example, **Standard Class accounted for approximately 60% of orders but had a late-delivery rate of approximately 22%, compared with 12% for First Class**.

**Business implication:** Management should evaluate shipping modes based on both volume and reliability. A high-volume shipping method with a disproportionately high late-delivery rate may warrant additional investigation.

### 11.4 Regional Profitability

**Finding:** Regional order volume does not necessarily correspond directly to profitability. For example, **Region X generated approximately $___ in total profit from ___ orders, while Region Y generated approximately $___ from ___ orders**.

**Business implication:** Management should evaluate regional profitability in addition to order volume when allocating resources or developing regional strategies. Differences in product mix, pricing, shipping costs, or customer behavior could contribute to variations in profitability.

### Overall Insight

Together, these findings demonstrate the value of a centralized cloud analytics pipeline. The Gold-layer model allows stakeholders to analyze order volume, delivery performance, customer segments, shipping modes, and profitability together rather than relying on disconnected reports.

---

## 12. Cost Estimate and Cost Control

### Cost Drivers

| Service             | Cost Driver                 | Cost-Control Approach                                    |
| ------------------- | --------------------------- | -------------------------------------------------------- |
| Amazon S3           | Storage volume and requests | Unused folders and failed outputs were deleted           |
| AWS Glue            | Catalog/crawler usage       | Used only for required cataloging and processing         |
| Amazon Athena       | Data scanned per query      | Queries were optimized to reduce unnecessary scans       |
| Redshift Serverless | RPU-hours                   | Auto-pause was enabled to avoid unnecessary idle compute |
| Amazon QuickSight   | Author/reader usage         | Dashboard usage was limited during development           |

### Cost-Control Actions

The team:

* Deleted unused S3 folders
* Removed failed and corrupted Parquet outputs
* Dropped unused Athena tables
* Removed unused Glue databases and jobs
* Deleted unused Glue crawlers
* Deleted unused QuickSight datasets and analyses
* Used Redshift Serverless auto-pause
* Optimized Athena queries to reduce unnecessary data scans

Because the project dataset is relatively small and unused resources were removed after testing, the project was designed to minimize ongoing AWS costs.

---

## 13. AWS vs. GCP Trade-Off

The project was implemented using AWS, but equivalent GCP services were considered.

| AWS                   | GCP Equivalent          |
| --------------------- | ----------------------- |
| Amazon S3             | Cloud Storage           |
| AWS Glue Data Catalog | BigQuery Data Catalog   |
| Amazon Athena         | BigQuery SQL / Dataproc |
| Amazon Redshift       | BigQuery                |
| Amazon QuickSight     | Looker Studio           |

### Trade-Off Discussion

The main practical trade-off encountered with AWS was the additional schema-management complexity between Athena/Parquet and Redshift.

The team encountered timestamp and schema compatibility issues that required explicit type casting and schema alignment before the curated data could be successfully loaded into Redshift.

A BigQuery-based architecture could simplify this workflow by combining query and warehouse functionality more directly.

However, AWS was selected because it aligned with the team's course experience and the AWS services used throughout the project labs.

---

## 14. Limitations and Risks

### Limitations

* The DataCo dataset is a public proxy rather than real company data.
* The dataset may not represent all real-world supply chain conditions.
* Partitioning of the curated Parquet data was identified as a potential improvement.
* Additional customer and product dimensions could further extend the analytical model.

### Risks

| Risk                  | Description                                                                              |
| --------------------- | ---------------------------------------------------------------------------------------- |
| Dataset limitations   | Public data may not represent current organizational conditions                          |
| Data quality          | Source data may contain inconsistent formats or values                                   |
| Dashboard integration | Gold views must remain aligned with dashboard requirements                               |
| Scalability           | The current architecture was tested using a relatively small dataset                     |
| Time constraints      | Additional analytical and dashboard improvements may require additional development time |

---

## 15. Future Improvements

Potential future improvements include:

* Implementing partitioned Parquet data
* Expanding customer and product dimensions
* Adding additional data-quality checks
* Automating pipeline execution
* Expanding the QuickSight dashboard
* Adding additional KPIs and alerts
* Incorporating more current or organization-specific supply chain data
* Adding automated monitoring for data-quality and pipeline failures

---

## 16. Repository Contents

The repository contains supporting materials for the project, including:

* Project documentation
* Architecture diagrams
* SQL scripts
* Implementation screenshots
* Data-quality documentation
* Analytics outputs
* Dashboard evidence

As additional project artifacts are finalized, they will be organized into the appropriate repository folders.

---

## 17. Generative AI Use

Generative AI was used during the project to assist with outlining and organizing the final project report. AI assistance was used to break the project requirements into sections and help structure the written documentation.

The project team reviewed the generated material and verified it against the work completed during the project. The team remained responsible for the final project content, technical implementation, analysis, and conclusions.

---

## 18. Team

**George Wajda**
**Christine Kumiko Chiba**
**Alexandra Robinson**

**Course:** MGMT 59900 – Big Data Analytics in the Cloud
**Track:** Supply Chain
**Group:** 6
