             -------------- Modifying Data --------------------------

/* Create a New Table */

CREATE TABLE sales.promotions ( 
promosion_id INT PRIMARY KEY IDENTITY (1,1),
promosion_name VARCHAR (255) NOT NULL,
discount NUMERIC (3,2) DEFAULT 0, 
start_date DATE NOT NULL,
expired_date DATE NOT NULL );


/* Delete all Rows in Table */

TRUNCATE TABLE sales.addresses

/* Delete Table */
DROP TABLE sales.promotions


/* Basic Insert */

INSERT INTO sales.promotions (promosion_name,discount,start_date,expired_date)
VALUES ('2018 Summer Promotion',0.15,'20180601','20180901')

/* To capture inserted values from multiple columns, you specify the columns in the output */
INSERT INTO sales.promotions (promosion_name,discount,start_date,expired_date)
OUTPUT INSERTED.promosion_id,
INSERTED.promosion_name,
INSERTED.discount,
INSERTED.start_date,
INSERTED.expired_date
VALUES ('2018 Summer Promotion',0.15,'20180601','20180901')


/*To insert explicit value for the identity column, you must execute the following statement first*/
/*in some situations, you may want to insert a value into the identity column such as data migration*/
/* add custom id (4) */

SET IDENTITY_INSERT sales.promotions ON
INSERT INTO sales.promotions (promosion_name,discount,start_date,expired_date)
OUTPUT INSERTED.promosion_id
VALUES (4,'2018 Summer Promotion',0.15,'20180601','20180901')
SET IDENTITY_INSERT sales.promotions OFF


/* Inserting multiple rows example*/
INSERT INTO 
	sales.promotions ( promosion_name, discount, start_date, expired_date)

OUTPUT inserted.promosion_id
VALUES
	('2020 Summer Promotion',0.25,'20200601','20200901'),
	('2020 Fall Promotion',0.10,'20201001','20201101'),
	('2020 Winter Promotion', 0.25,'20201201','20210101');

/* Inserting multiple rows and returning the inserted id list example*/

INSERT INTO 
	sales.promotions ( promosion_name, discount, start_date, expired_date)

OUTPUT inserted.promosion_id
VALUES
	('2020 Summer Promotion',0.25,'20200601','20200901'),
	('2020 Fall Promotion',0.10,'20201001','20201101'),
	('2020 Winter Promotion', 0.25,'20201201','20210101');

/* INSERT INTO SELECT*/
/* Insert all rows from another table example*/
INSERT INTO sales.addresses (street, city, state, zip_code) 
SELECT
    street,
    city,
    state,
    zip_code
FROM
    sales.customers
ORDER BY
    first_name,
    last_name;

/* Insert some rows from another table */
INSERT INTO 
    sales.addresses (street, city, state, zip_code) 
SELECT
    street,
    city,
    state,
    zip_code
FROM
    sales.stores
WHERE
    city IN ('Santa Cruz', 'Baldwin')


/* Insert the top N of rows*/

INSERT TOP (10) 
INTO sales.addresses (street, city, state, zip_code) 
SELECT
    street,
    city,
    state,
    zip_code
FROM
    sales.customers
ORDER BY
    first_name,
    last_name;

/* SQL Server UPDATE*/
/* Update a single column (updated_at) in all rows */
UPDATE sales.taxes
SET updated_at = GETDATE();


/* Update multiple columns */
/* increases the max local tax rate by 2% and the average local tax rate by 1% for the states that have the max local tax rate 1%.*/

UPDATE sales.taxes
SET max_local_tax_rate += 0.02,
    avg_local_tax_rate += 0.01
WHERE
    max_local_tax_rate = 0.01

