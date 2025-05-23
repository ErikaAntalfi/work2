-- 1. Създайте подходяща база данни и схема към нея;

CREATE DATABASE TIGER_ORDERS;

CREATE OR REPLACE SCHEMA orders_schema;


-- 2. Създайте ФАЙЛ ФОРМАТ, подходящ за СТЕИДЖА


CREATE OR REPLACE FILE FORMAT TIGER_ORDERS.orders_schema.json_file_format
  TYPE = 'JSON'
  COMPRESSION = 'AUTO'
  ENABLE_OCTAL = FALSE
  ALLOW_DUPLICATE = FALSE
  STRIP_NULL_VALUES = FALSE;


-- 3. Създайте вътрешен СТЕИДЖ - добавете, коментар към стеиджа (проверете в документацията);
-- CREATE OR REPLACE STAGE TIGER_ORDERS.orders_schema.INTERNAL_STAG

CREATE OR REPLACE STAGE TIGER_ORDERS.orders_schema.ORDERS_DOCUMENTS
FILE_FORMAT = TIGER_ORDERS.orders_schema.json_file_format
COMMENT = 'Comment for json_file_format';


-- 4. Качете JSON файловете.


-- 5. Създайте подходящи таблици за суровите данни:
-- - raw_customers_json
-- - raw_orders_json

CREATE TABLE TIGER_ORDERS.PUBLIC.raw_orders_json(
    product_json VARIANT
)

CREATE TABLE TIGER_ORDERS.PUBLIC.raw_customer_json(
    customer_json VARIANT
)

-- 6. Създайте подходящи таблици за същинските данни:
-- - td_customers
-- - td_orders
-- - td_order_items


-- Клиенти
CREATE OR REPLACE TABLE td_customers (
    customer_id STRING PRIMARY KEY,
    name STRING,
    email STRING,
    registration_date DATE,
    address_street STRING,
    address_city STRING,
    address_zip_code STRING,
    loyalty_points NUMBER
);

-- Поръчки
CREATE OR REPLACE TABLE td_orders (
    order_id STRING PRIMARY KEY,
    customer_id STRING,
    order_date TIMESTAMP_TZ,
    total_amount NUMBER(10,2),
    shipping_method STRING,
    FOREIGN KEY (customer_id) REFERENCES td_customers(customer_id)
);

-- Продукти в поръчки
CREATE OR REPLACE TABLE td_order_items (
    order_id STRING,
    product_id STRING,
    name STRING,
    quantity NUMBER,
    price NUMBER(10,2),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES td_orders(order_id)
);


-- 7. Заредете данните от JSON файловете - в таблиците за сурови данни

COPY INTO TIGER_ORDERS.PUBLIC.raw_orders_json
    FROM @TIGER_ORDERS.ORDERS_SCHEMA.ORDERS_DOCUMENTS/orders_data.json
FILE_FORMAT = (
    FORMAT_NAME = 'tIGER_ORDERS.orders_schema.json_file_format'
)

SELECT*
FROM TIGER_ORDERS.PUBLIC.raw_orders_json

COPY INTO TIGER_ORDERS.PUBLIC.raw_customer_json
    FROM @TIGER_ORDERS.ORDERS_SCHEMA.ORDERS_DOCUMENTS/customers_data.json
FILE_FORMAT = (
    FORMAT_NAME = 'tIGER_ORDERS.orders_schema.json_file_format'
)


SELECT*
FROM TIGER_ORDERS.PUBLIC.raw_customer_json

-- 8. Извлечете данните от суровите таблици и ги разпределете в td_* таблиците

SELECT product_json['shipping_method']
FROM TIGER_ORDERS.PUBLIC.raw_orders_json



-- 9. Създайте таблица, която да съдържа агрегирана информация от броя на потребителите, които са се регистрирали до момента в системата.

-- 10. Създайте таблица, която да агрегира общото количество продадени продукти и тяхната цена.

-- 11. Изтриите СУРОВИТЕ таблици.