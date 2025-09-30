SELECT TOP 5*
FROM [dbo].[products]

SELECT ProductStatus, COUNT(ProductStatus) AS StatusCount
FROM [dbo].[products]
GROUP BY ProductStatus
ORDER BY StatusCount DESC;

SELECT TOP 5*
FROM [dbo].[order_items]

SELECT*
FROM [dbo].[New_Order]

SELECT ExpectedDeliveryDate
FROM [dbo].[New_Order]
WHERE ISDATE(ExpectedDeliveryDate) = 0



SELECT ShippingCity, COUNT(ShippingCity) AS  CountSC
FROM [dbo].[New_Order]
GROUP BY ShippingCity
ORDER BY CountSC DESC

SELECT p.ProductId, p.ProductName, p.StockQuantity, p.ProductStatus, COUNT(oi.ProductId) AS CancelledOrderCount
FROM [dbo].[products] AS p
JOIN
     [dbo].[order_items] AS oi
ON 
     p.ProductId = oi.ProductId
JOIN 
     [dbo].[New_Order] AS o
ON 
     oi.OrderId = o.OrderId
WHERE
     o.orderStatus = 'Cancelled'
AND 
     o.ShippingCity IN ('Port Harcourt', 'Uyo', 'Calabar', 'Warri', 'Benin City')
AND 
     p.StockQuantity <=0
OR 
     p.ProductStatus IN ('Out of Stock', 'Discontinued')
--OR 
     --p.StockQuantity <10
GROUP BY 
        p.ProductId, p.ProductName, p.StockQuantity, p.ProductStatus
ORDER BY
        CancelledOrderCount DESC;



WITH PortHarcourtArea AS (
    SELECT 'Port Harcourt' AS City UNION ALL
    SELECT 'Warri' UNION ALL
    SELECT 'Benin City' UNION ALL
    SELECT 'Calabar' UNION ALL
    SELECT 'Uyo'
),
AllPHOrders AS (
    SELECT
        o.OrderId,
        o.CustomerId,
        o.OrderStatus,
        TRY_CAST(o.ExpectedDeliveryDate AS DATETIME) AS ExpectedDeliveryDate_Clean, -- Safely cast to DATETIME
        TRY_CAST(o.ActualDeliveryDate AS DATETIME) AS ActualDeliveryDate_Clean      -- Safely cast to DATETIME
    FROM
        [dbo].[New_Order] AS o
    WHERE
        o.ShippingCity IN (SELECT City FROM PortHarcourtArea)
),
RecentCustomers AS (
    SELECT
        CustomerID
    FROM
        [dbo].[customers]
    WHERE
        RegistrationDate > '2024-03-01'
),
RecentPHOrders AS (
    SELECT
        apo.*
    FROM
        AllPHOrders AS apo
    JOIN
        RecentCustomers AS rc ON apo.CustomerId = rc.CustomerID
)
SELECT
    'All Customers in PH Areas' AS CustomerCohort,
    COUNT(OrderId) AS TotalOrders,
    SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    CAST(SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS REAL) * 100.0 / COUNT(OrderId) AS CancellationRatePercentage,
    SUM(CASE WHEN ActualDeliveryDate_Clean IS NOT NULL AND ExpectedDeliveryDate_Clean IS NOT NULL AND ActualDeliveryDate_Clean > DATEADD(DAY, 3, ExpectedDeliveryDate_Clean) THEN 1 ELSE 0 END) AS SignificantlyDelayedOrders,
    CAST(SUM(CASE WHEN ActualDeliveryDate_Clean IS NOT NULL AND ExpectedDeliveryDate_Clean IS NOT NULL AND ActualDeliveryDate_Clean > DATEADD(DAY, 3, ExpectedDeliveryDate_Clean) THEN 1 ELSE 0 END) AS REAL) * 100.0 / COUNT(OrderId) AS DelayRatePercentage
FROM
    AllPHOrders
--GROUP BY
    --CustomerCohort 
UNION ALL
SELECT
    'Recent Customers in PH Areas' AS CustomerCohort,
    COUNT(OrderId) AS TotalOrders,
    SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledOrders,
    CAST(SUM(CASE WHEN OrderStatus = 'Cancelled' THEN 1 ELSE 0 END) AS REAL) * 100.0 / COUNT(OrderId) AS CancellationRatePercentage,
    SUM(CASE WHEN ActualDeliveryDate_Clean IS NOT NULL AND ExpectedDeliveryDate_Clean IS NOT NULL AND ActualDeliveryDate_Clean > DATEADD(DAY, 3, ExpectedDeliveryDate_Clean) THEN 1 ELSE 0 END) AS SignificantlyDelayedOrders,
    CAST(SUM(CASE WHEN ActualDeliveryDate_Clean IS NOT NULL AND ExpectedDeliveryDate_Clean IS NOT NULL AND ActualDeliveryDate_Clean > DATEADD(DAY, 3, ExpectedDeliveryDate_Clean) THEN 1 ELSE 0 END) AS REAL) * 100.0 / COUNT(OrderId) AS DelayRatePercentage
FROM
    RecentPHOrders
--GROUP BY
    --CustomerCohort;







     

