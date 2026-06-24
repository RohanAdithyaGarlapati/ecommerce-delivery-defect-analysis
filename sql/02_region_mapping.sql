-- ============================================================
-- Helper: map Brazilian state (UF) -> macro region
-- Used by the delivery-performance queries to define routes
-- ============================================================
DROP TABLE IF EXISTS state_region;
CREATE TABLE state_region (uf CHAR(2) PRIMARY KEY, region VARCHAR(16));
INSERT INTO state_region (uf, region) VALUES
('SP','Southeast'),('RJ','Southeast'),('MG','Southeast'),('ES','Southeast'),
('RS','South'),('PR','South'),('SC','South'),
('BA','Northeast'),('PE','Northeast'),('CE','Northeast'),('MA','Northeast'),
('PB','Northeast'),('RN','Northeast'),('AL','Northeast'),('PI','Northeast'),
('DF','Central-West'),('GO','Central-West'),('MT','Central-West'),('MS','Central-West'),
('PA','North');
