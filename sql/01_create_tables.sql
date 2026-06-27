-- WITH Customers as (

--     SELECT *, 
--         ROW_NUMBER() OVER (PARTITION BY customer_ID, customer_name ORDER BY customer_name) AS num_duplicates

--     FROM read_csv(
--         '/workspaces/Nuaav/client_b/Customer.CSV',
--         header = true,
--         auto_detect = true,
--         strict_mode = false,
--         null_padding = true,
--         skip = 1
--     )
--     WHERE customer_id NOT LIKE '%END OF FILE%' 
--         AND customer_name IS NOT NULL
--         AND email IS NOT NULL
--         AND segment IS NOT NULL

--         AND TRIM(COALESCE(customer_id, '')) <> ''
--         AND TRIM(COALESCE(customer_name, '')) <> ''
--         AND TRIM(COALESCE(email, '')) <> '' 
--         AND TRIM(COALESCE(segment, '')) <> ''
        
--     ORDER BY customer_name
-- )
-- SELECT * EXCLUDE (num_duplicates) FROM Customers 
-- WHERE num_duplicates = 1
--     AND email NOT LIKE '%@@%'
-- ;


-- -- Hay dos tablas de Customers

-- -- WITH Customers_a as (
-- --     select * from read_csv('/workspaces/Nuaav/client_a/Customer.csv')
-- -- )
-- -- ;


-- WITH  Customers_a AS    (
--         SELECT * REPLACE(REPLACE(REPLACE(email, '@@', '@'), '..', '.') AS email ), 

--             ROW_NUMBER() OVER (PARTITION BY customer_id, email ) as num_duplicates
        
--          FROM  read_csv(
--             '/workspaces/Nuaav/client_a/Customer.csv',
--             skip = 1, 
--             header = true, 
--             null_padding = true
--             )
--         WHERE first_name IS  NOT NULL AND
--             last_name IS NOT NULL AND 
--             email IS NOT NULL
--     )
-- SELECT * EXCLUDE (num_duplicates) FROM Customers_a
-- WHERE num_duplicates = 1
-- ;



WITH Customers_a as (

    SELECT * REPLACE(REPLACE(REPLACE(email, '@@', '@'), '..', '.') AS email, REPLACE(is_active, '<-- invalid email', '') AS is_Active), 
        ROW_NUMBER() OVER (PARTITION BY customer_ID, customer_name ORDER BY customer_name) AS num_duplicates

    FROM read_csv(
        '/workspaces/Nuaav/client_b/Customer.CSV',
        header = true,
        auto_detect = true,
        strict_mode = false,
        null_padding = true,
        skip = 1
    )
    WHERE customer_id NOT LIKE '%END OF FILE%' 
        AND customer_name IS NOT NULL
        AND email IS NOT NULL
        AND segment IS NOT NULL

        AND TRIM(COALESCE(customer_id, '')) <> ''
        
    ORDER BY customer_name
),

Customers_b AS (
        SELECT * REPLACE(REPLACE(REPLACE(email, '@@', '@'), '..', '.') AS email, REPLACE(is_active, '<-- invalid email', '') AS is_Active), 

            ROW_NUMBER() OVER (PARTITION BY customer_id, email ) as num_duplicates
        
         FROM  read_csv(
            '/workspaces/Nuaav/client_a/Customer.csv',
            skip = 1, 
            header = true, 
            null_padding = true
            )
        WHERE first_name IS  NOT NULL AND
            last_name IS NOT NULL AND 
            email IS NOT NULL AND
            TRIM(COALESCE(customer_id, '')) <> ''
)

SELECT cust_a.* EXCLUDE(num_duplicates), cust_b.* EXCLUDE(num_duplicates, email, first_name, last_name)
    FROM Customers_a cust_a
        LEFT JOIN Customers_b cust_b 
            ON UPPER(cust_b.email) = UPPER(cust_a.email)



    WHERE cust_a.num_duplicates = 1
    -- AND cust_b.num_duplicates = 1

;

-- SELECT * FROM READ_CSV('/workspaces/Nuaav/client_b/Customer.CSV');

-- SELECT * FROM READ_CSV('/workspaces/Nuaav/client_a/Customer.csv');

-- CUST-A-0005,Chris,Evans,cevans@example,PLATINUM,Web,true
-- C-CUST-5001,Chris Evans,cevans@example.com,VIP,true