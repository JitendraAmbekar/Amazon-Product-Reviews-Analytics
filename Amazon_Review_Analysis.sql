-- =============================*********=========================================================================

-- PROJECT: Amazon Product Reviews End-to-End Analytics
-- DESCRIPTION: Database setup, pipeline tracking, and Exploratory Data Analysis (EDA)

-- =============================*********=========================================================================



-- 1. DATABASE INITIALIZATION
-- Creating a dedicated database environment for handling retail analytics data.

CREATE DATABASE IF NOT EXISTS amazon_analytics_db;
USE amazon_analytics_db;


-- 2. SCHEMA DEFINITION: AMAZON SALES TABLE
-- Setting up the raw ingestion table for transaction logs. 
-- Note: Staged with VARCHAR for data integrity during bulk load, to be transformed later.

DROP TABLE IF EXISTS amazon_sales;

CREATE TABLE amazon_sales (
    OrderID VARCHAR(100),
    OrderDate VARCHAR(100),
    CustomerID VARCHAR(100),
    CustomerName VARCHAR(255),
    ProductID VARCHAR(100),
    ProductName VARCHAR(255),
    Category VARCHAR(100),
    Brand VARCHAR(100),
    Quantity VARCHAR(50),
    UnitPrice VARCHAR(50),
    Discount VARCHAR(50),
    Tax VARCHAR(50),
    ShippingCost VARCHAR(50),
    TotalAmount VARCHAR(50),
    PaymentMethod VARCHAR(100),
    OrderStatus VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    SellerID VARCHAR(100)
);


-- 3. DATA BULK INGESTION (ETL PIPELINE)
-- Truncating potential stale records and performing high-speed bulk ingestion from MySQL Secure Folder.
TRUNCATE TABLE amazon_sales;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Amazon.csv'
INTO TABLE amazon_sales 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- 4. SCHEMA DEFINITION: AMAZON REVIEWS TABLE
-- This schema stores text-heavy customer feedback and structural identifiers for text mining.

DROP TABLE IF EXISTS amazon_reviews;
CREATE TABLE amazon_reviews (
    `Reviewer Name` TEXT,
    `Profile Link` VARCHAR(255),
    Country VARCHAR(50),
    `Review Count` VARCHAR(50),
    `Review Date` VARCHAR(100),
    Rating VARCHAR(100),
    `Review Title` TEXT,
    `Review Text` TEXT,   
    `Date of Experience` VARCHAR(100)
);

-- Verification query to validate total successful row insertion
SELECT COUNT(*) AS verified_total_reviews FROM amazon_reviews;


-- ============================*****===============================================

-- EXPLORATORY DATA ANALYSIS (EDA) & CORE INSIGHT QUERIES

-- ============================*****=============================================

-- QUERY 1: EXECUTIVE KPIs
-- Aggregates the absolute volume of customer responses and calculates the baseline satisfaction matrix.

SELECT 
    COUNT(*) AS total_reviews, 
    ROUND(AVG(CAST(Rating AS DECIMAL(10,2))), 2) AS average_rating 
FROM amazon_reviews;


-- QUERY 2: GEOGRAPHIC CUSTOMER DISTRIBUTION
-- Segments customer feedback volumes by global regions to identify key target demographics.

SELECT 
    Country, 
    COUNT(*) AS review_count 
FROM amazon_reviews 
GROUP BY Country 
ORDER BY review_count DESC 
LIMIT 10;


-- QUERY 3: RATING PATTERN & SENTIMENT DISTRIBUTION PERCENTAGES
-- Calculates the exact market share of each rating group to assess satisfaction levels.

SELECT 
    Rating, 
    COUNT(*) AS absolute_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM amazon_reviews), 2) AS contribution_percentage
FROM amazon_reviews
GROUP BY Rating
ORDER BY Rating DESC;


-- QUERY 4: TEXT DENSITY & ENGAGEMENT ANALYSIS (Top 5 Reviews)
-- Analyzes the structural length of customer feedback to capture deep-dive qualitative insights.

SELECT 
    `Reviewer Name`, 
    `Review Title`, 
    LENGTH(`Review Text`) AS review_character_length 
FROM amazon_reviews 
ORDER BY LENGTH(`Review Text`) DESC 
LIMIT 5;


-- QUERY 5: TOP ENGAGED CONTRIBUTORS 
-- Profiles users writing frequent reviews to analyze community engagement metrics.

SELECT 
    `Reviewer Name`, 
    COUNT(*) AS total_written_reviews
FROM amazon_reviews 
GROUP BY `Reviewer Name`
ORDER BY total_written_reviews DESC 
LIMIT 5;