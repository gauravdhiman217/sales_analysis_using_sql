--Assignment 1 SQl 
-- first of all creating tables in database. here i am using MS SQL Server installed on my local machine.

--Sales Table
CREATE TABLE Assignment.dbo.Sales(
	CustomerId INT NULL,
	Order_Date	DATE,
	LocationName NVARCHAR(200),
	TransactionType INT,
	SKU NVARCHAR(50),
	NetSales FLOAT,
	Quantity INT,
	DiscountAmount FLOAT
)

--Customer Table

CREATE TABLE Assignment.dbo.Customers(
	CustomerId INT NULL,
	Profile NVARCHAR(200) NULL,
	State NVARCHAR(20),
	Has_Email INT,
	Latitude DECIMAL(8,6) NULL,
	Longitude DECIMAL(9,6) NULL
)

--Product Table

CREATE TABLE Assignment.dbo.Products(
	ProductGroup NVARCHAR(50),
	ProductType NVARCHAR(50),
	SKU NVARCHAR(50)
)

--Inserting SALES csv files into database

BULK INSERT 
	Assignment.dbo.Sales
FROM
	"C:\Users\HP\Desktop\STUDY MATTERIAL\Consumer Data Analyst Acadia - Assignment\Assigment 1 - Mandatory\Sales.csv"
WITH(
	FIRSTROW=2,
	FIELDTERMINATOR =',' , 
	ROWTERMINATOR = '\n'
);
--72586 ROWS SUCESSFULL INSERTED 

-- INSERTING PRODUCTS CSV FILE INTO PRODUCT TABLE

BULK INSERT 
	Assignment.dbo.Products
FROM
	"C:\Users\HP\Desktop\STUDY MATTERIAL\Consumer Data Analyst Acadia - Assignment\Assigment 1 - Mandatory\Products.csv"
WITH(
	FIRSTROW=2,
	FIELDTERMINATOR =',' , 
	ROWTERMINATOR = '\n'
);
-- 642 rows inserted sucessfully


--INSERTING CUSTOMERS CSV FILE INTO CUSTOMER TABLE
BULK INSERT 
	Assignment.dbo.Customers
FROM
	"C:\Users\HP\Desktop\STUDY MATTERIAL\Consumer Data Analyst Acadia - Assignment\Assigment 1 - Mandatory\Customers.csv"
WITH(
	FIRSTROW=2,
	FIELDTERMINATOR =',' , 
	ROWTERMINATOR = '\n'
);

-- 23283 rows inserted sucessfully

--EXPORING DATA BEFORE ANALYSIS

SELECT
	DISTINCT COUNT(*) 
FROM 
	Sales

SELECT
	DISTINCT COUNT(*) 
FROM 
	Products

SELECT
	DISTINCT COUNT(*) 
FROM 
	Customers

--72586 FOUND IN SALES UNIQUE RECORDS FOUND NO DUPLICATES FOUNDS 
--23283 FOUND IN CUSTOMERS UNIQUE RECORDS FOUND NO DUPLICATES FOUNDS 
--642 FOUND IN PRODUCTS UNIQUE RECORDS FOUND NO DUPLICATES FOUNDS 



--checking if any date before 2021 or after 2021
SELECT 
	*
FROM 
	Sales
WHERE 
	DATEPART(YEAR,Order_Date) > 2021 OR
	DATEPART(YEAR,Order_Date) <2021
ORDER BY 
	Order_Date
-- NO DATE BEFORE OR AFTER 2021
--TRANSACTION COLUMN LOOKING GOOD 
SELECT 
	Sales.TransactionType,COUNT(1)
FROM 
	Sales
GROUP BY 
	Sales.TransactionType
ORDER BY 
	Sales.TransactionType;


-- CHECKING IF THERE IS ANY VALUE LESS THAN ZERO IN NET SALES, QUANTITY AND DISCOUNT THAT SHOULD NOT BE LESS THAN ZERO 
SELECT
	Sales.NetSales,Sales.Quantity,Sales.DiscountAmount
FROM 
	Sales
WHERE
	Sales.NetSales <0 OR 
	Sales.Quantity <0 OR
	Sales.DiscountAmount <0;
-- NO VALUE LESS THAN ZERO FOUND 

SELECT 
	Customers.State 
FROM 
	Customers
WHERE 
	LEN(State)>2
-- THERE IS TWO ROWS IN STATE JP-11 AND JP-13 WHICH NEED TO BE DISSCUSSED WITH CLIENT AND GET MORE CLEARIFICATION FOR NOW I WILL LEAVE IT AS IT IS 

--COUNTING PRODUCTS THERE RESPECTED GROUP
SELECT 
	COUNT(DISTINCT A.ProductGroup) as ProdcutsGroup,
	COUNT(DISTINCT B.ProductType) as ProdcutsType,
	COUNT(DISTINCT C.SKU) as SKU

FROM 
	Products A 
JOIN
	Products B
ON 
	A.SKU=B.SKU
JOIN 
	Products C
ON 
	A.SKU=C.SKU;


--UPDATING PROFILE NULL VALUE INTO UNKNOWN SO IT WILL BECOME EASY TO UNDERSTAND 
UPDATE
	Customers
SET		
	Profile = 'UNKNOWN'
WHERE 
	Customers.Profile IS NULL

-- AS OF ALL SEEMS TO BE GOOD LETS MOVE TOWARD OUR FIRST ASSIGNMENT PROBLEM 

--1.	Member vs Non Member Sales, and Sales Contribution Monthly and Quarterly



-- OVERALL SALES BY MEMBERS VS NON MEMBERS 
WITH 
	CTC AS 
	(SELECT 
		CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' 
		ELSE 'MEMBER'
		END AS MEMBER_CHECK,
		Sales.Order_Date,
		CASE WHEN Sales.TransactionType NOT IN (4,6) THEN  Sales.NetSales ELSE -1*Sales.NetSales END AS NETSALES
	FROM 
		Sales 

		)
SELECT 
	CTC.MEMBER_CHECK,
	ROUND(SUM(CTC.NetSales),2) AS NET_SALES
FROM 
	CTC
GROUP BY 
	CTC.MEMBER_CHECK
;



--SALE BY MEMBERS VS NON MEMBERS MONTH WISE 
WITH 
	CTC AS 
	(SELECT 
		CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' 
		ELSE 'MEMBER'
		END AS MEMBER_CHECK,
		CASE WHEN Sales.TransactionType NOT IN (4,6) THEN  Sales.NetSales ELSE -1*Sales.NetSales END AS NETSALES,
		Sales.Order_Date
	FROM 
		Sales 
		)
SELECT 
	CTC.MEMBER_CHECK,
	DATEPART(MM, CTC.Order_Date) AS MONTH ,
	ROUND(SUM(CTC.NetSales),2) AS NET_SALES
FROM 
	CTC
GROUP BY 
	CTC.MEMBER_CHECK,
	DATEPART(MONTH, CTC.Order_Date)
ORDER BY 
	DATEPART(MONTH, CTC.Order_Date),
	CTC.MEMBER_CHECK
;



--SALES BY MEMBERS VS NON MEMEBERS QUATER WISE 
WITH 
	CTC AS 
	(SELECT 
		CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' 
		ELSE 'MEMBER'
		END AS MEMBER_CHECK,
		CASE WHEN Sales.TransactionType NOT IN (4,6) THEN  Sales.NetSales ELSE -1*Sales.NetSales END AS NETSALES,
		Sales.Order_Date
	FROM 
		Sales 
		)
SELECT 
	CTC.MEMBER_CHECK,
	DATEPART(QQ, CTC.Order_Date) AS QUATERS ,
	ROUND(SUM(CTC.NetSales),2) AS NET_SALES
FROM 
	CTC
GROUP BY 
	CTC.MEMBER_CHECK,
	DATEPART(QQ, CTC.Order_Date)
ORDER BY 
	DATEPART(QQ, CTC.Order_Date),
	CTC.MEMBER_CHECK
;



--SALE BY MEMBERS VS NON MEMBERS MONTHLY AND QUATERLY IN SAME TABLE
WITH 
	CTC AS 
	(SELECT 
		CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' 
		ELSE 'MEMBER'
		END AS MEMBER_CHECK,
		CASE WHEN Sales.TransactionType NOT IN (4,6) THEN  Sales.NetSales ELSE -1*Sales.NetSales END AS NETSALES,
		Sales.Order_Date
	FROM 
		Sales 
		)
SELECT 
	CTC.MEMBER_CHECK,
	DATEPART(MM, CTC.Order_Date) AS MONTH ,
	DATEPART(QQ, CTC.Order_Date) AS QUATERS ,
	ROUND(SUM(CTC.NetSales),2) AS NET_SALES
FROM 
	CTC
GROUP BY 
	CTC.MEMBER_CHECK,
	DATEPART(MONTH, CTC.Order_Date),
	DATEPART(QQ, CTC.Order_Date)

ORDER BY 
	DATEPART(MONTH, CTC.Order_Date),
	CTC.MEMBER_CHECK;





--2.	Profile wise Quarterly Sales, Quantity, Discount, Avg Sales/Customer, Avg Spend/Visit, Avg Price/Product and Avg Discount/Customer


--EXTRACTING SALES AND VISITS WITH CTC TABLE 
WITH 
CTC AS 
	(
	SELECT 
		Sales.CustomerId,
		SUM(CASE WHEN Sales.TransactionType=4 OR Sales.TransactionType=6 THEN -1* Sales.NetSales ELSE 1* Sales.NetSales END) AS TOTAL_SPEND,
		 (CASE WHEN SALES.TransactionType IN (1,2,3,5) THEN (COUNT(DISTINCT Sales.Order_Date)) ELSE 0 END) AS NO_VISIT
	FROM 
		Sales
	GROUP BY 
		Sales.CustomerId,
		TransactionType
	HAVING 
		SUM(CASE WHEN Sales.TransactionType=4 OR Sales.TransactionType=6 THEN -1* Sales.NetSales ELSE 1* Sales.NetSales END)>0 AND
		(CASE WHEN SALES.TransactionType IN (1,2,3,5) THEN (COUNT(DISTINCT Sales.Order_Date)) ELSE 0 END)>0)

SELECT 
	A.Profile,
	SUM(CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.Quantity ELSE +1*B.Quantity END) AS QUANTITY,

	DATEPART(QQ,B.Order_Date)AS QUATERS,

	ROUND(
		SUM(CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.DiscountAmount ELSE +1*B.DiscountAmount END),2) AS DISCOUNT,


	ROUND( 
		SUM(CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.NetSales ELSE +1*B.NetSales END)/SUM(CASE WHEN B.TransactionType = 4 OR B.TransactionType=6 THEN 0 ELSE 1 END),2) AS AVG_SALE_PER_MEMBER ,


	ROUND(
		(AVG((CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.NetSales ELSE +1*B.NetSales END)/CTC.NO_VISIT)),2) AS AVG_SPEND_VISIT,

-->> MISTAKE COUNT OF PRODUCT MUST BE THERE
	ROUND(
		SUM(CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.NetSales ELSE +1*B.NetSales END)/
			COUNT(CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.Quantity ELSE +1*B.Quantity END),2) AS AVG_PRICE_PRODUCT,

	ROUND(
		(SUM(CASE WHEN B.TransactionType =4 OR B.TransactionType = 6 THEN -1*B.DiscountAmount ELSE +1*B.DiscountAmount END)/COUNT(DISTINCT B.CustomerId)),2) AS AVG_DIS_CUSTOMER

FROM 
	Customers A
JOIN 
	Sales B
ON 
	A.CustomerId = B.CustomerId
INNER JOIN 
	CTC
ON 
	A.CustomerId=CTC.CustomerId
-->> AFTER ADDED
JOIN 
	Products P
ON 
	P.SKU=B.SKU
GROUP BY 
	A.Profile,
	DATEPART(QQ,B.Order_Date)
ORDER BY
	DATEPART(QQ,B.Order_Date),
	A.Profile;




--3.	Location wise Quarterly Sales and Customers Contribution


SELECT 
	Sales.LocationName,
	DATEPART(QQ,Sales.Order_Date) AS QUATER,
	ROUND(SUM(Sales.NetSales),2) AS QUATERLY_SALES,
	(CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' ELSE 'MEMBER' END  ) AS CUSTOMER_CHECK,
	COUNT(CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' ELSE 'MEMBER' END) AS COUNT_OF_CUSTOMERS
FROM 
	Sales
WHERE 
	Sales.TransactionType NOT IN (4,6)
GROUP BY 
	Sales.LocationName,
	DATEPART(QQ,Sales.Order_Date),
	(CASE WHEN Sales.CustomerId IS NULL THEN 'NON_MEMBER' ELSE 'MEMBER' END  )
ORDER BY 
	DATEPART(QQ,Sales.Order_Date),
	Sales.LocationName,
	CUSTOMER_CHECK;


--4.	Top performing Product Groups across multiple Quarters by Sales


SELECT QUATERS,TOP_PRODUCT_GROUP,TOP_SALE FROM (
	SELECT B.*, ROW_NUMBER()OVER(PARTITION BY QUATERS ORDER BY TOP_SALE DESC) AS RN FROM
		(
		SELECT A.*, MAX(SALES) OVER(PARTITION BY SKU,TOP_PRODUCT_GROUP ,QUATERS ) AS TOP_SALE 
		FROM(
				SELECT 
					DATEPART(QQ,Sales.Order_Date)AS QUATERS,
					Sales.SKU,Products.ProductGroup AS TOP_PRODUCT_GROUP,
					(CASE WHEN Sales.TransactionType NOT IN (4,6) THEN 1* Sales.NetSales ELSE -1*Sales.NetSales END) AS SALES
				FROM 
				Sales JOIN Products ON Products.SKU=Sales.SKU)A
			)B
		)C
	WHERE RN=1
	ORDER BY QUATERS

--5.	Top 5 Product Types in the year by # of Customers shopped
--QUESTION NOT CLEARLY DISCRIBED SO I CONCERED IT AS TOP 5 PRODUCT TYPE IN THE YEAR BY PERCENTAGE OF CUSTOMERS SHOPPED



SELECT TOP 5 Products.ProductType,SUM(CASE WHEN Sales.TransactionType NOT IN (4,6) THEN 1* Sales.NetSales ELSE -1*Sales.NetSales END) as total_sales,
		COUNT(*) AS 'NO OF CUSTOMERS',
		CONCAT((COUNT(*))*100/(SELECT (COUNT(*)) FROM Sales WHERE Sales.TransactionType IN (1,2,3,5)),'%' ) AS PERCENT_OF_CUSTOMERS
FROM Sales
JOIN 
Products
on Products.SKU=Sales.SKU
group by ProductType,Sales.TransactionType
order by 
[NO OF CUSTOMERS] DESC
--HERE PG8 GROUP HAS MORE SALES BUT PG1 IS PURCHASED BY MORE CUSTOMERS AND SO ON.


		
--6.	% Multimers (Customers who came more than once); and average Repurchase Gap between First and Last Transaction

--UNABLE TO DIFFENTATE THOSE CUSTOMERS WHO DON'T HAVE CUSTOMER ID SO WE ONLY CONSIDER CUSTOMERS WITH CUSTOMERID
	
SELECT 
	CONCAT(COUNT(A.REVISIT_CUSTOMERS)*100/(SELECT COUNT(Customers.CustomerId) FROM Customers),'%')AS PERCENT_OF_CUST_REVISIT,	
	AVG(DIFF_DAYS) AS [AVG REVISIT DAYS]

FROM (
	SELECT 
		Sales.CustomerId AS REVISIT_CUSTOMERS,
		(CASE WHEN Sales.TransactionType NOT IN (4,6) THEN COUNT(DISTINCT Sales.Order_Date) ELSE 0 END) AS 'VISIT COUNT',
		Sales.TransactionType,
		DATEDIFF(DD ,MIN(Sales.Order_Date),MAX(Sales.Order_Date)) AS DIFF_DAYS
	FROM 
		Sales
	WHERE 
		CustomerId IS NOT NULL AND TransactionType NOT IN(4,6)

	GROUP BY 
		CustomerId,
		TransactionType
	HAVING 
		COUNT(DISTINCT Sales.Order_Date)>1)A
;

--7.	Month wise Performance of the brand



SELECT 
	DATEPART(MONTH,Sales.Order_Date) AS MONTHS,
	ROUND(SUM(CASE WHEN Sales.TransactionType IN (4,6) THEN -1* Sales.NetSales ELSE 1*SALES.NetSales END),2) AS SALES_EXC_RETURN,
	ROUND(
	(SUM(CASE WHEN Sales.TransactionType IN (4,6) THEN -1* Sales.NetSales ELSE 1*SALES.NetSales END)-
	LAG(SUM(CASE WHEN Sales.TransactionType IN (4,6) THEN -1*SALES.NETSALES ELSE 1* SALES.NETSALES END)) OVER (ORDER BY DATEPART(MONTH,Sales.Order_Date))
	)/
	LAG(SUM(CASE WHEN Sales.TransactionType IN (4,6) THEN -1*SALES.NETSALES ELSE 1* SALES.NETSALES END)) OVER (ORDER BY DATEPART(MONTH,Sales.Order_Date))*100,2
	) AS '% CHANGE IN SALES'
FROM 
	Sales
GROUP BY 
	DATEPART(MONTH,Sales.Order_Date)

