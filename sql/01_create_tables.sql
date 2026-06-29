-- Customers ------------------------------------------------
-- CREATE TABLE Customers AS
--     WITH Customers_a as (

--         SELECT * REPLACE(REPLACE(REPLACE(email, '@@', '@'), '..', '.') AS email, REPLACE(is_active, '<-- invalid email', '') AS is_Active), 
--             ROW_NUMBER() OVER (PARTITION BY customer_ID, customer_name ORDER BY customer_name) AS num_duplicates

--         FROM read_csv(
--             '/workspaces/Nuaav/client_b/Customer.CSV',
--             header = true,
--             auto_detect = true,
--             strict_mode = false,
--             null_padding = true,
--             skip = 1
--         )
--         WHERE customer_id NOT LIKE '%END OF FILE%' 
--             AND customer_name IS NOT NULL
--             AND email IS NOT NULL
--             AND segment IS NOT NULL

--             AND TRIM(COALESCE(customer_id, '')) <> ''
            
--         ORDER BY customer_name
--     ),

--     Customers_b AS (
--             SELECT * REPLACE(REPLACE(REPLACE(email, '@@', '@'), '..', '.') AS email, REPLACE(is_active, '<-- invalid email', '') AS is_Active), 

--                 ROW_NUMBER() OVER (PARTITION BY customer_id, email ) as num_duplicates
            
--             FROM  read_csv(
--                 '/workspaces/Nuaav/client_a/Customer.csv',
--                 skip = 1, 
--                 header = true, 
--                 null_padding = true
--                 )
--             WHERE first_name IS  NOT NULL AND
--                 last_name IS NOT NULL AND 
--                 email IS NOT NULL AND
--                 TRIM(COALESCE(customer_id, '')) <> ''
--     )

--     SELECT cust_a.* EXCLUDE(num_duplicates), cust_b.* EXCLUDE(num_duplicates, email, first_name, last_name)
--         FROM Customers_a cust_a
--             LEFT JOIN Customers_b cust_b 
--                 ON UPPER(cust_b.email) = UPPER(cust_a.email)



--         WHERE cust_a.num_duplicates = 1
--         -- AND cust_b.num_duplicates = 1
--     ORDER BY cust_a.customer_id
-- ;



-- CREATE TABLE Orders_a AS
--     WITH Orders_a AS 
--         (   
--             SELECT *
--                 REPLACE(
--                     TRIM(
--                         REPLACE(
--                             REPLACE(
--                                 REPLACE (
--                                     REPLACE(
--                                         channel, '<-- duplicate customer', ''
--                                             ), 
--                                     '<-- missing date', ''
--                                         ),
--                                     '<-- invalid customer', ''
--                                     ),
--                                 '<-- duplicate', ''
--                                 )
--                     )AS channel 
                    
--                 ),

--                 ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, order_date ORDER BY order_id) AS num_duplicates

--                 FROM READ_CSV(
--                     '/workspaces/Nuaav/client_a/Orders.csv', 
--                     header=true,
--                     null_padding=true,
--                     skip=1 )

            
--         WHERE order_id NOT LIKE '%END OF FILE%' 
--     )

--     SELECT * EXCLUDE(num_duplicates)  FROM Orders_a
--         WHERE num_duplicates = 1
-- ORDER BY order_id
-- ;


-- CREATE TABLE Orders_b AS
--     WITH  Orders_b AS 
--                 ( 
--                     SELECT * 
--                         REPLACE( 
--                             TRIM(
--                                 REPLACE(
--                                     REPLACE(
--                                     REPLACE(
--                                         REPLACE(order_status, '<-- missing date', ''
--                                                 ),
--                                                 '<-- duplicate customer', ''
--                                             ), 
--                                             '<-- invalid customer', ''
--                                         ), 
--                                         '<-- duplicate', ''
--                                     )
--                                 ) AS order_status
--                             )
--                     ,
--                         ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, order_date ORDER BY order_id) AS num_duplicates
                        
--                     FROM READ_CSV(
--                             '/workspaces/Nuaav/client_b/Order.csv',
--                             header=true,
--                             null_padding=true,
--                             skip=1
--                         )
--                     WHERE order_id NOT LIKE '%END OF FILE%'
                    
--                 )
            
--     SELECT * EXCLUDE(num_duplicates) FROM Orders_b
--         WHERE num_duplicates = 1
--     ORDER BY order_id
-- ;



-- PRODUCTS _____________________________________________
-- CREATE TABLE Products_a AS
--     WITH Products_a AS (
--         SELECT * 
--             REPLACE(
--                     TRIM(REPLACE(REPLACE(is_active, '<-- negative price', ''),'<-- anomaly', '')) AS is_active, 
--                     ABS(unit_price) AS unit_price
                    
--                     )
--         , ROW_NUMBER() OVER (PARTITION BY product_name, category, unit_price, currency) AS num_duplicates FROM 

--             READ_CSV('/workspaces/Nuaav/client_a/Products.csv', 
--                     header=true,
--                     null_padding=true,
--                     skip=1)
--         )   
--     SELECT * FROM Products_a
--     WHERE num_duplicates = 1
--         AND sku NOT LIKE '%END OF FILE%'
--         AND num_duplicates = 1
--     ORDER BY SKU
-- ;


-- CREATE TABLE Products_b AS
--     WITH Products_b AS (
--         SELECT * 
--                     REPLACE(
--                             TRIM(sku) AS sku,   
--                             TRIM(product_name) AS product_name,
--                             TRIM(category) AS category,
--                             TRIM(currency)  AS currency, 

--                             ABS(unit_price) AS unit_price, 

--                             TRIM(REPLACE(is_active, '<-- anomaly', '')) AS is_Active
                            
--                             )
        
--         , ROW_NUMBER() OVER (PARTITION BY sku, product_name, category, currency ) AS num_duplicates FROM 

--             READ_CSV('/workspaces/Nuaav/client_b/Product.csv', 
--                     header=true,
--                     null_padding=true,
--                     skip=1)
--         )   
--     SELECT * FROM Products_b
--     WHERE num_duplicates = 1
--         AND sku NOT LIKE '%END OF FILE%'
--         -- AND num_duplicates = 1

--     ORDER BY sku 
--     ;


-- CREATE TABLE Payment AS

--     WITH Payment AS (
--         SELECT *
--             REPLACE(
--                     TRIM(REPLACE(REPLACE(status, '<-- negative amount', ''), '<-- negative', '')) AS status
--                     )
--             ,
--             ROW_NUMBER() OVER (PARTITION BY payment_id, order_id, payment_method) AS num_duplicates
--             FROM 
--                 READ_CSV('/workspaces/Nuaav/client_b/Payments.csv', 
--                 header = true,
--                 skip=1,
--                 null_padding=true)
--         )
--     SELECT * EXCLUDE(num_duplicates) FROM Payment 

--         WHERE payment_id NOT LIKE '%END OF FILE%'
--             AND num_duplicates = 1
--     ORDER BY payment_id

-- ;

-- INSTALL xml FROM community;
-- SELECT * FROM READ_XML('/workspaces/Nuaav/client_a/ClientA_Transactions_1.xml')