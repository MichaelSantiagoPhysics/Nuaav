
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


WITH Orders_a AS 
    (   
        SELECT * ,

            ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, order_date ORDER BY order_id) AS num_duplicates

            FROM READ_CSV(
                '/workspaces/Nuaav/client_a/Orders.csv', 
                header=true,
                null_padding=true,
                skip=1 ), 
        
    SELECT Orders_b AS 
        (
            FROM READ_CSV(
                    '/workspaces/Nuaav/client_b/Order.csv',
                    header=true

                )
        )
    ) 
SELECT * FROM Orders_b
-- SELECT * EXCLUDE(num_duplicates) FROM Orders_a
-- WHERE order_id NOT LIKE '%END OF FILE%'
--     AND num_duplicates = 1
-- ORDER BY order_id ASC

;