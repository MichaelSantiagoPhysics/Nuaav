WITH Customers as (

    SELECT *, 
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
        AND TRIM(COALESCE(customer_name, '')) <> ''
        AND TRIM(COALESCE(email, '')) <> '' 
        AND TRIM(COALESCE(segment, '')) <> ''
        
    ORDER BY customer_name
)
SELECT * EXCLUDE (num_duplicates) FROM Customers 
WHERE num_duplicates = 1
    AND email NOT LIKE '%@@%'

;


-- WITH Customers_a as (
--     select * from read_csv('/workspaces/Nuaav/client_a/Customer.csv')
-- )
-- ;


WITH  Customers_a AS    (
        SELECT * REPLACE(REPLACE(REPLACE(email, '@@', '@'), '..', '.') AS email ), 

            ROW_NUMBER() OVER (PARTITION BY customer_id, email ) as num_duplicates
        
         FROM  read_csv(
            '/workspaces/Nuaav/client_a/Customer.csv',
            skip = 1, 
            header = true, 
            null_padding = true
            )
        WHERE first_name IS  NOT NULL AND
            last_name IS NOT NULL AND 
            email IS NOT NULL
    )
SELECT * EXCLUDE (num_duplicates) FROM Customers_a
WHERE num_duplicates = 1
;


