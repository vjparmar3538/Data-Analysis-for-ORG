/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.
use orders;
SELECT 
    OnC.CUSTOMER_ID,
    CONCAT(
        (CASE WHEN OnC.CUSTOMER_GENDER = 'M' THEN 'Mr. ' ELSE 'Ms. ' END),
        CONCAT(" ", UPPER(OnC.CUSTOMER_FNAME), " ", UPPER(OnC.CUSTOMER_LNAME))
    ) AS Name_Cust,
    OnC.CUSTOMER_EMAIL,
    YEAR(OnC.CUSTOMER_CREATION_DATE) AS Cus_Creation_Year,
    CASE 
        WHEN YEAR(OnC.CUSTOMER_CREATION_DATE) < 2005 THEN 'A' 
        WHEN YEAR(OnC.CUSTOMER_CREATION_DATE) < 2011 THEN 'B' 
        ELSE 'C' 
    END AS Category 
FROM 
    ONLINE_CUSTOMER OnC;



/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.

SELECT 
    P.Product_Id,
    P.Product_DESC,
    P.Product_Quantity_Avail,
    P.Product_Price,
    (P.Product_Price * P.Product_Quantity_Avail) AS Inventory_Value,
    CASE 
        WHEN P.Product_Price > 20000 THEN P.Product_Price * 0.8 
        WHEN P.Product_Price > 10000 THEN P.Product_Price * 0.85 
        ELSE P.Product_Price * 0.9 
    END AS New_Price 
FROM 
    Product P 
WHERE 
    P.Product_Id NOT IN (SELECT OI.Product_Id FROM ORDER_ITEMS OI) 
ORDER BY 
    Inventory_Value DESC;


/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.

SELECT 
    PC.PRODUCT_CLASS_CODE,
    PC.PRODUCT_CLASS_DESC,
    COUNT(P.PRODUCT_ID) AS COUNT_PRODUCT_TYPES,
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE 
FROM 
    PRODUCT_CLASS PC 
INNER JOIN 
    PRODUCT P ON PC.PRODUCT_CLASS_CODE = P.PRODUCT_CLASS_CODE 
GROUP BY 
    PC.PRODUCT_CLASS_CODE, 
    PC.PRODUCT_CLASS_DESC 
HAVING 
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) > 100000 
ORDER BY 
    INVENTORY_VALUE DESC;



/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.

SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
    OC.CUSTOMER_EMAIL,
    OC.CUSTOMER_PHONE,
    A.COUNTRY
FROM 
    ONLINE_CUSTOMER OC
JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    OC.CUSTOMER_ID IN (
        SELECT 
            OH.CUSTOMER_ID
        FROM 
            ORDER_HEADER OH
        WHERE 
            OH.ORDER_STATUS = 'CANCELLED'
        GROUP BY 
            OH.CUSTOMER_ID
        HAVING 
            COUNT(*) = (
                SELECT 
                    COUNT(*)
                FROM 
                    ORDER_HEADER OH2
                WHERE 
                    OH2.CUSTOMER_ID = OH.CUSTOMER_ID
            )
    );



/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  

SELECT 
    SP.SHIPPER_NAME,
    A.CITY,
    COUNT(DISTINCT OC.CUSTOMER_ID) AS NO_CUSTOMER_CATERED_TO,
    COUNT(OC.CUSTOMER_ID) AS NO_CONSIGNMENTS_CATERED
FROM 
    SHIPPER SP
INNER JOIN 
    ORDER_HEADER OH ON OH.SHIPPER_ID = SP.SHIPPER_ID
INNER JOIN 
    ONLINE_CUSTOMER OC ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
INNER JOIN 
    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    SP.SHIPPER_NAME IN ('DHL')
GROUP BY 
    SP.SHIPPER_NAME, A.CITY
ORDER BY 
    SP.SHIPPER_NAME;


/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.

SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    SUM(oi.product_quantity) AS quantity_sold,
    CASE 
        WHEN pc.product_class_desc IN ('Electronics', 'Computer') THEN
            CASE 
                WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.1 * SUM(oi.product_quantity) THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.5 * SUM(oi.product_quantity) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN pc.product_class_desc IN ('Mobiles', 'Watches') THEN
            CASE 
                WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.2 * SUM(oi.product_quantity) THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.6 * SUM(oi.product_quantity) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE 
                WHEN SUM(oi.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.3 * SUM(oi.product_quantity) THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.7 * SUM(oi.product_quantity) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS inventory_status
FROM 
    PRODUCT p
JOIN 
    PRODUCT_CLASS pc ON p.product_class_code = pc.product_class_code
LEFT JOIN 
    ORDER_ITEMS oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_id, p.product_desc, p.product_quantity_avail, pc.product_class_desc;




/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.

SELECT 
    ORDER_ID,
    VOLUME
FROM 
    (
    SELECT 
        OI.ORDER_ID,
        SUM(P.LEN * P.WIDTH * P.HEIGHT * OI.PRODUCT_QUANTITY) AS VOLUME
    FROM 
        ORDER_ITEMS OI
    INNER JOIN 
        PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
    GROUP BY 
        OI.ORDER_ID
    ) AS TAB
HAVING 
    TAB.VOLUME <= (
        SELECT 
            LEN * WIDTH * HEIGHT AS CARTON_VOL
        FROM 
            CARTON
        WHERE 
            CARTON_ID = 10
    )
ORDER BY 
    VOLUME DESC
LIMIT 1;



/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.

SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULLNAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOT_QTY,
    SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS VALUE
FROM 
    ONLINE_CUSTOMER OC
INNER JOIN 
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
INNER JOIN 
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID
INNER JOIN 
    PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE 
    OH.PAYMENT_MODE = 'CASH'
    AND OH.ORDER_STATUS = 'SHIPPED'
    AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
    OC.CUSTOMER_ID, FULLNAME;



/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 5 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.

SELECT 
    S.PRODUCT_ID,
    S.PRODUCT_DESC,
    S.TOT_QTY 
FROM 
    (
        SELECT 
            OI.PRODUCT_ID,
            P.PRODUCT_DESC,
            SUM(OI.PRODUCT_QUANTITY) AS TOT_QTY 
        FROM 
            ORDER_ITEMS OI 
        INNER JOIN 
            PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID 
        WHERE 
            OI.ORDER_ID IN 
            (
                SELECT 
                    OI.ORDER_ID 
                FROM 
                    ORDER_ITEMS OI 
                JOIN 
                    ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID 
                JOIN 
                    ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID 
                JOIN 
                    ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID 
                WHERE 
                    OI.PRODUCT_ID = 201 
                    AND OH.ORDER_STATUS = 'SHIPPED' 
                    AND A.CITY NOT IN ('BANGALORE', 'NEW DELHI')
            ) 
            AND P.PRODUCT_ID != 201 
        GROUP BY 
            OI.PRODUCT_ID, P.PRODUCT_DESC
    ) S 
ORDER BY 
    S.TOT_QTY DESC;



/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.

SELECT 
    OH.ORDER_ID,
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULLNAME,
    SUM(OI.PRODUCT_QUANTITY) AS TOT_QTY 
FROM 
    ONLINE_CUSTOMER OC 
INNER JOIN 
    ORDER_HEADER OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID 
INNER JOIN 
    ORDER_ITEMS OI ON OH.ORDER_ID = OI.ORDER_ID 
INNER JOIN 
    ADDRESS A ON A.ADDRESS_ID = OC.ADDRESS_ID 
WHERE 
    MOD(OH.ORDER_ID, 2) = 0 
    AND OH.ORDER_STATUS = 'SHIPPED' 
    AND A.PINCODE NOT LIKE '5%' 
GROUP BY 
    OH.ORDER_ID, OC.CUSTOMER_ID, FULLNAME;
