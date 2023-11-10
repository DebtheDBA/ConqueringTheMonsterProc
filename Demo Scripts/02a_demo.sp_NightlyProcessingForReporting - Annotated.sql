SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
/******************************************************************************
* Auto Dealership Nightly Processing for Reporting
*
* Created by: Jess Beagle-Labrador
* Created on: 2006-10
*
* Updated by:
*    Sadie Boxer-Beagle
*    Sebastian Chihuahua-Terrier
******************************************************************************/

/* DGM Pass 1: 	
Proc starts with sp_*

	11. General Observation - how many tables are being dropped and recreated here? This seems like a very long query load that could benefit from being broken out.
		a. Need to ask questions like how often and when are these reports being run? 

	14. Final Observations - 
		SET NOCOUNT ON ???
*/

CREATE   PROCEDURE demo.sp_NightlyProcessingForReporting (
	@StartDate DATE,
	@EndDate DATE
)
AS
BEGIN

	/******************************************************************************
	* Refresh demo.NightlySalesStaging
	******************************************************************************/

	-----
	-- 2009-04: Jess
	-- Using new MERGE and CTE functionality to consolidate separate delete, 
	-- insert, and update statements to improve performance

/* DGM Pass 1: 	
	1. Takes information from sales history tables  and inserts new data into the NightlySalesStaging table joining on the SalesHistoryID
		a. Updates and Inserts only 
		b. Potential Performance issues:
			i. Uses MERGE and CTE
*/

	WITH SalesHistorySource_CTE (
		SalesHistoryID, CustomerID, SalesPersonID, InventoryID, TransactionDate,
		SellPrice, Customer_FirstName, Customer_LastName, Address, City,
		State, ZipCode, Customer_Email, Customer_PhoneNumber, FirstVisit, 
		RepeatCustomer, SalesPerson_FirstName, SalesPerson_LastName, SalesPerson_Email, SalesPerson_PhoneNumber,
		DateOfHire, Salary, CommissionRate, VIN, BaseModelID,
		PackageID, TrueCost, InvoicePrice, MSRP, DateReceived,
		MakeID, ModelID, ColorID, MakeName, ModelName,
		ClassificationID, ClassificationCode, ClassificationName, ColorName, ColorCode,
		PackageName, PackageCode, Description
	)
	AS (
		SELECT 
			SalesHistory.SalesHistoryID, SalesHistory.CustomerID, SalesHistory.SalesPersonID, SalesHistory.InventoryID, SalesHistory.TransactionDate, 
			SalesHistory.SellPrice, Customer.FirstName AS Customer_FirstName, Customer.LastName AS Customer_LastName, Customer.Address, Customer.City, 
			Customer.State, Customer.ZipCode, Customer.Email AS Customer_Email, Customer.PhoneNumber AS Customer_PhoneNumber, Customer.FirstVisit, 
			Customer.RepeatCustomer, SalesPerson.FirstName AS SalesPerson_FirstName, SalesPerson.LastName AS SalesPerson_LastName, SalesPerson.Email AS SalesPerson_Email, SalesPerson.PhoneNumber AS SalesPerson_PhoneNumber, 
			SalesPerson.DateOfHire, SalesPerson.Salary, SalesPerson.CommissionRate, Inventory.VIN, Inventory.BaseModelID, 
			Inventory.PackageID, Inventory.TrueCost, Inventory.InvoicePrice, Inventory.MSRP, Inventory.DateReceived, 
			BaseModel.MakeID, BaseModel.ModelID, BaseModel.ColorID, Make.MakeName, Model.ModelName, 
			Model.ClassificationID, Classification.ClassificationCode, Classification.ClassificationName, Color.ColorName, Color.ColorCode, 
			Package.PackageName, Package.PackageCode, Package.Description
		FROM dbo.SalesHistory
		INNER JOIN dbo.Customer
			ON SalesHistory.CustomerID = Customer.CustomerID
		INNER JOIN dbo.SalesPerson
			ON SalesHistory.SalesPersonID = SalesPerson.SalesPersonID
		INNER JOIN dbo.Inventory
			ON SalesHistory.InventoryID = Inventory.InventoryID
		INNER JOIN Vehicle.BaseModel
			ON Inventory.BaseModelID = BaseModel.BaseModelID
		INNER JOIN Vehicle.Make
			ON BaseModel.MakeID = Make.MakeID
		INNER JOIN Vehicle.Model
			ON BaseModel.ModelID = Model.ModelID
		INNER JOIN Vehicle.Classification
			ON Model.ClassificationID = Classification.ClassificationId
		INNER JOIN Vehicle.Color
			ON BaseModel.ColorID = Color.ColorID
		INNER JOIN Vehicle.Package
			ON Inventory.PackageID = Package.PackageID
		WHERE (
			SalesHistory.TransactionDate >= @StartDate
			AND SalesHistory.TransactionDate < @EndDate
		)
	)
	MERGE demo.NightlySalesStaging AS TARGET
	USING SalesHistorySource_CTE AS SOURCE
	ON (
		TARGET.SalesHistoryID = SOURCE.SalesHistoryID
	)
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (
			SalesHistoryID, CustomerID, SalesPersonID, InventoryID, TransactionDate,
			SellPrice, Customer_FirstName, Customer_LastName, Address, City,
			State, ZipCode, Customer_Email, Customer_PhoneNumber, FirstVisit, 
			RepeatCustomer, SalesPerson_FirstName, SalesPerson_LastName, SalesPerson_Email, SalesPerson_PhoneNumber,
			DateOfHire, Salary, CommissionRate, VIN, BaseModelID,
			PackageID, TrueCost, InvoicePrice, MSRP, DateReceived,
			MakeID, ModelID, ColorID, MakeName, ModelName,
			ClassificationID, ClassificationCode, ClassificationName, ColorName, ColorCode,
			PackageName, PackageCode, Description
		)
		VALUES (
			SalesHistoryID, CustomerID, SalesPersonID, InventoryID, TransactionDate,
			SellPrice, Customer_FirstName, Customer_LastName, Address, City,
			State, ZipCode, Customer_Email, Customer_PhoneNumber, FirstVisit, 
			RepeatCustomer, SalesPerson_FirstName, SalesPerson_LastName, SalesPerson_Email, SalesPerson_PhoneNumber,
			DateOfHire, Salary, CommissionRate, VIN, BaseModelID,
			PackageID, TrueCost, InvoicePrice, MSRP, DateReceived,
			MakeID, ModelID, ColorID, MakeName, ModelName,
			ClassificationID, ClassificationCode, ClassificationName, ColorName, ColorCode,
			PackageName, PackageCode, Description
		)
	WHEN MATCHED THEN UPDATE SET 
		SalesHistoryID = SOURCE.SalesHistoryID,
		CustomerID = SOURCE.CustomerID,
		SalesPersonID = SOURCE.SalesPersonID,
		InventoryID = SOURCE.InventoryID,
		TransactionDate = SOURCE.TransactionDate ,
		SellPrice = SOURCE.SellPrice,
		Customer_FirstName = SOURCE.Customer_FirstName,
		Customer_LastName = SOURCE.Customer_LastName,
		Address = SOURCE.Address,
		City = SOURCE.City ,
		State = SOURCE.State,
		ZipCode = SOURCE.ZipCode,
		Customer_Email = SOURCE.Customer_Email,
		Customer_PhoneNumber = SOURCE.Customer_PhoneNumber,
		FirstVisit = SOURCE.FirstVisit,
		RepeatCustomer = SOURCE.RepeatCustomer,
		SalesPerson_FirstName = SOURCE.SalesPerson_FirstName,
		SalesPerson_LastName = SOURCE.SalesPerson_LastName,
		SalesPerson_Email = SOURCE.SalesPerson_Email,
		SalesPerson_PhoneNumber = SOURCE.SalesPerson_PhoneNumber ,
		DateOfHire = SOURCE.DateOfHire,
		Salary = SOURCE.Salary,
		CommissionRate = SOURCE.CommissionRate,
		VIN = SOURCE.VIN,
		BaseModelID = SOURCE.BaseModelID ,
		PackageID = SOURCE.PackageID,
		TrueCost = SOURCE.TrueCost,
		InvoicePrice = SOURCE.InvoicePrice,
		MSRP = SOURCE.MSRP,
		DateReceived = SOURCE.DateReceived ,
		MakeID = SOURCE.MakeID,
		ModelID = SOURCE.ModelID,
		ColorID = SOURCE.ColorID,
		MakeName = SOURCE.MakeName,
		ModelName = SOURCE.ModelName ,
		ClassificationID = SOURCE.ClassificationID,
		ClassificationCode = SOURCE.ClassificationCode,
		ClassificationName = SOURCE.ClassificationName,
		ColorName = SOURCE.ColorName,
		ColorCode = SOURCE.ColorCode ,
		PackageName = SOURCE.PackageName,
		PackageCode = SOURCE.PackageCode,
		Description = SOURCE.Description;

	-- 2007-02: Jess
	-- Mandatory breadcrumb
	PRINT '-----'
	PRINT '-- load complete'


	/******************************************************************************
	* Populate Reporting Tables
	* 
	* 2006-10: Jess
	* Each SSRS report will read from a vw_rpt_[name] view that will be a 
	* SELECT * from the respective rpt_[name] table
	* 
	* IMPORTANT - All reports should only ever query demo.NightlySalesStaging
	******************************************************************************/

/* DGM Pass 1: 	
	2. Drops table demo.rpt_SoldModels_by_Age
		a. DROPS TABLE!!!!
		b. Potential Performance issues:
			i. Effect on recompiles for the database since the stats are gone and have to be recreated

*/

	-----
	-- Sold Models by Age
	-- 2008-12: Jess

/* DGM Pass 1: 	
	2. Drops table demo.rpt_SoldModels_by_Age
		a. DROPS TABLE!!!!
		b. Potential Performance issues:
			i. Effect on recompiles for the database since the stats are gone and have to be recreated

*/
	DROP TABLE demo.rpt_Sold_Models_by_Age;
	
/* DGM Pass 1: 	
	3. Creates demo.rpt_Sold_Models_by_Age from a SELECT from demo.NightlySalesStaging
		a. Additional Research points:
			i. How big is this table?
			ii. What are the indexes on demo.NightlySalesStaging
				1) 5 indexes, 3 of them are variations of each other
			iii. There's a GROUP BY that includes converts of DateReceived for formatting purposes. Why formatting here?
		b. Potential Performance Issues:
			i. SELECT INTO to create a table. Any potential locking issues
			ii. What does this do for the performance of the SSRS report - the table is dropped and recreated? What if someone made the report view an indexed view

*/
	SELECT MakeName, ModelName, 
		CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE) AS MonthReceived,
		SUM(TrueCost) AS TotalTrueCost,
		SUM(MSRP) AS TotalMSRP,
		SUM(InvoicePrice) AS TotalInvoicePrice,
		SUM(SellPrice) AS TotalSoldPrice,
		COUNT(1) AS MyCount
	INTO demo.rpt_Sold_Models_by_Age
	FROM demo.NightlySalesStaging
	GROUP BY MakeName, ModelName, CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE)
	ORDER BY MakeName, ModelName, CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE);

	PRINT '-----'
	PRINT '-- rpt_Sold_Models_by_Age complete'

	-----
	-- Profit By Model
	-- 2008-10: Jess
	
/* DGM Pass 1: 	
	4. Repeats similar process for demo.rpt_Profit_By_Model where it drops the table then recreates it using SELECT INTO
		a. The use of count(1) is a little different. I'm used to seeing Count(some not null column) but thinking through logic, this should work. Confirm there's no errors. Possibly learn something new
		b. Potential Performance Issues: see above
		c. Full stored proc observation:
			i. Performance issues of the views that read these. 
			ii. No error handling
			iii. For these patterns of dropping the table and recreating them, what does this mean for the data types on the new table that's created. Does that create problems for the SSRS view?


*/
	DROP TABLE demo.rpt_Profit_By_Model;

	SELECT MakeName, ModelName, 
		SUM(SellPrice) - SUM(TrueCost) AS TotalProfit,
		(SUM(SellPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
		COUNT(1) AS SoldCount
	INTO demo.rpt_Profit_By_Model
	FROM demo.NightlySalesStaging
	GROUP BY MakeName, ModelName
	ORDER BY MakeName, ModelName;

	PRINT '-----'
	PRINT '-- rpt_Profit_By_Model complete'

	-----
	-- Average Profit by Vehicle Classification Type
	-- 2008-10: Jess
	--

/* DGM Pass 1: 	
	5. Similar pattern for demo.rpt_Avg_Profit_Classification_Type - Drops the table then recreates with SELECT INTO
		a. Different - select TOP 0 to create the table
		b. Then creates a cursor to insert into the new table by classification code from Vehicle.Classification
		c. Potential Performance implications:
			i. Vehicle.Classifiction only has a PK on the ID field, not on the code. ClassificationCode may not be unique.
			ii. Why a cursor?

*/
	-- For each Vehicle Classification Type, must calculate 
	-- average profit
	DROP TABLE demo.rpt_Avg_Profit_Classification_Type

	/*
	* 2013-05: Sadie - Changed to use neat trick to create an empty table!  Don't need a CREATE TABLE anymore!
	*/
	select top 0
		classificationcode,
		month(transactiondate) as month, 
		year(transactiondate) as year,
		avg(datediff(day, datereceived, transactiondate)) as avg_vehicle_age
	into demo.rpt_avg_profit_classification_type
	from demo.nightlysalesstaging
	group by classificationcode, month(transactiondate), year(transactiondate)
	order by classificationcode, year(transactiondate), month(transactiondate);

	DECLARE @ClassificationCode NCHAR(50);

	DECLARE rsExe CURSOR FOR 
		SELECT ClassificationCode
		FROM Vehicle.Classification;

	OPEN rsExe;

	FETCH NEXT 
		FROM rsExe INTO @ClassificationCode;

	WHILE @@FETCH_STATUS = 0
		BEGIN
	
		INSERT INTO demo.rpt_Avg_Profit_Classification_Type
		SELECT 
			ClassificationCode,
			MONTH(TransactionDate) AS Month, 
			YEAR(TransactionDate) AS Year,
			SUM(demo.udf_CalculateNetProfit(VIN)) AS TotalNetProfit
		FROM demo.NightlySalesStaging
		WHERE ClassificationCode = @ClassificationCode
		GROUP BY ClassificationCode, MONTH(TransactionDate), YEAR(TransactionDate)
		ORDER BY ClassificationCode, YEAR(TransactionDate), MONTH(TransactionDate);

		FETCH NEXT 
 			FROM rsExe INTO @ClassificationCode;
		END  
	CLOSE rsExe;
	DEALLOCATE rsExe;

	PRINT '-----'
	PRINT '-- rpt_Avg_Profit_Classification_Type complete'


	/*
	* 2014-04: Sadie 
	-- For each Vehicle Classification Type, must calculate 
	* average number of days vehicle remained unsold
	* Reusing code Jess wrote
	*/
/* DGM Pass 1: 	
	6. Similar pattern for demo.rpt_Avg_Vehicle_Age_Classification_Type with drop table then recreate.
		a. Note the comment - Sadie likes this technique. Did she make all of these changes to use this???
		b. Second cursor that has the same problem as Avg_Profit_Classification. Same problems as previously mentioned
		c. Potential Improvement
			i. If these need to be done by cursor, could they be done at the same time rather than two separate cursors?

*/
	DROP TABLE demo.rpt_Avg_Vehicle_Age_Classification_Type

	/*
	* 2013-05: Sadie - Changed to use neat trick to create an empty table! Don't need a CREATE TABLE anymore!
	*/
	select top 0
		classificationcode,
		month(transactiondate) as month, 
		year(transactiondate) as year,
		avg(datediff(day, datereceived, transactiondate)) as avg_vehicle_age
	into demo.rpt_avg_vehicle_age_classification_type
	from demo.nightlysalesstaging
	group by classificationcode, month(transactiondate), year(transactiondate)
	order by classificationcode, year(transactiondate), month(transactiondate);

	DECLARE @ClassificationCode2 NCHAR(50);

	DECLARE rsExe CURSOR FOR 
		SELECT ClassificationCode
		FROM Vehicle.Classification;

	OPEN rsExe;

	FETCH NEXT 
		FROM rsExe INTO @ClassificationCode2;

	WHILE @@FETCH_STATUS = 0
		BEGIN
	
		INSERT INTO demo.rpt_Avg_Vehicle_Age_Classification_Type
		SELECT 
			ClassificationCode,
			MONTH(TransactionDate) AS Month, 
			YEAR(TransactionDate) AS Year,
			AVG(DATEDIFF(day, DateReceived, TransactionDate)) AS Avg_Vehicle_Age
		FROM demo.NightlySalesStaging
		WHERE ClassificationCode = @ClassificationCode2
		GROUP BY ClassificationCode, MONTH(TransactionDate), YEAR(TransactionDate)
		ORDER BY ClassificationCode, YEAR(TransactionDate), MONTH(TransactionDate);

		FETCH NEXT 
 			FROM rsExe INTO @ClassificationCode2;
		END  
	CLOSE rsExe;
	DEALLOCATE rsExe;

	PRINT '-----'
	PRINT '-- rpt_Avg_Vehicle_Age_Classification_Type complete'


/* 04-03-2015 - Sebastian Chihuahua-Terrier - for each sales person, must calculate sales summary data per month */

/* DGM Pass 1: 	
	7. Same pattern for demo.rpt_salessummarypermonth
		a. NOTE - different developer (Sebastian), naming convention
		b. NOLOCKS!!!! :( 
		c. Uses a temp table to hold data from sales person and sales history
			i. Still uses SELECT INTO *smh*
		d. Joins the temp table toa view to do a SELECT INTO the report table.
			i. Temp table doesn't have any indexes
			ii. View doesn't have a schema name so SQL Prompt is no help
				1) Confirmed it's in the dbo schema. 
				2) It selects from a single view, dbo.vw_AllSoldInventory, which is also made up of views. NOTE - go do the research on this one
		e. Potential Performance implicatons:
			i. Nested views - how deep
			ii. Joined to a temp table with no indexes - are we missing indexes that would be helpful 
			iii. How much data are we talking about here?
			iv. Why are there nolocks? Have there been locking issues in the past? Do we have any info on this?
			v. CASTS in the group by…

*/

drop table demo.rpt_salessummarypermonth

select t1.salespersonid
	, t1.firstname
	, t1.lastname
	, t1.commissionrate
	, t2.saleshistoryid
into #tmp_salesperson
from dbo.salesperson as t1 with (nolock)
join dbo.saleshistory as t2 with (nolock) on t1.salespersonid = t2.salespersonid
where t2.transactiondate between @startdate and @enddate

select t1.firstname
	, t1.lastname
	, cast(cast(year(t2.transactiondate) as varchar(4)) + '-' + cast(month(t2.transactiondate) as varchar(2)) + '-01' as date) as monthyearsold
	, count(1) as numofsales
	, sum(sellprice) as totaldollarssold
	, avg(sellprice) as avgsaleprice
	, t1.salespersonid
into demo.rpt_salessummarypermonth
from #tmp_salesperson as t1
join vw_allsoldinventory_detail as t2 with (nolock) on t1.saleshistoryid = t2.saleshistoryid
where t2.transactiondate between @startdate and @enddate
group by t1.salespersonid
	, t1.firstname
	, t1.lastname
	, cast(cast(year(t2.transactiondate) as varchar(4)) + '-' + cast(month(t2.transactiondate) as varchar(2)) + '-01' as date)


print '-----'
print '-- rpt_salessummarypermonth complete'

	/*
	* 2018-09 - Sadie
	* For each sales person, calculate their average net profit per year
	* Will reuse Sebastian's #tmp_SalesPerson table
	*/

/* DGM Pass 1: 	
	8. Same pattern as #7 for demo.rpt_salesperson_avg_netprofit
		a. Sadie following Sebastian's pattern and reusing his temp table.
		b. NOTE for second pass - confirm how she's using this temp table compared to how Sebastian used it
Same comments as above

DGM Pass 2:
	* This has inline scalar UDF that calls back to demo.nightlysalesstaging. Do we need the UDF or can it be replaced with a function?

*/

	drop table demo.rpt_salesperson_avg_netprofit

	select 
		sp.firstname,
		sp.lastname,
		cast( 
			cast(year(nss.transactiondate) as varchar(4)) + '-' 
				+ cast(month(nss.transactiondate) as varchar(2)) + '-01' 
			as date
		) as monthyear,
		avg(demo.udf_calculatenetprofit(nss.vin)) as totalnetprofit
	into demo.rpt_salesperson_avg_netprofit
	from #tmp_salesperson sp
	inner join demo.nightlysalesstaging nss
		on sp.salespersonid = nss.salespersonid
		and sp.saleshistoryid = nss.saleshistoryid
	group by
		sp.firstname,
		sp.lastname,
		cast( 
			cast(year(nss.transactiondate) as varchar(4)) + '-' 
				+ cast(month(nss.transactiondate) as varchar(2)) + '-01' 
			as date
		)

	print '-----'
	print '-- rpt_salesperson_avg_netprofit complete'


/* 03-04-2017 - Sebastian Chihuahua-Terrier - update sales person commissions per year, cross referencing vw_salesperson_annualnumofsales */

/* DGM Pass 1: 	
	9. Same pattern as #7
		a. Back to Sebastian
		b. Nice hidden comment there about no coffee….
		c. Don't like the comment about wanting to use a UDF for the calcaluation
		d. Joins to a view calling a view calling a view …. with NOLOCK
			i. NOTE - need to look into these views of views


*/

drop table demo.rpt_salesperson_annualcommission

select nss.salesperson_firstname
	, nss.salesperson_lastname
	, annualnumofsales.yearsold
	,
	/* Sebastian Chihuahua-Terrier: need to wrap the commission calculation into a new udf for reuse later */
	sum(case when (nss.sellprice - nss.invoiceprice) > 0 then (nss.sellprice - nss.invoiceprice) * nss.commissionrate when (nss.sellprice - nss.invoiceprice) <= 0 then 0 /* Sebastian Chihuahua-Terrier: no profit? no commission! no coffee either! */
			end) as commission
	, annualnumofsales.annualnumofsales
into demo.rpt_salesperson_annualcommission
from demo.nightlysalesstaging as nss
join dbo.vw_salesperson_annualnumofsales as annualnumofsales with (nolock) on nss.salespersonid = annualnumofsales.salespersonid and year(nss.transactiondate) = annualnumofsales.yearsold
group by nss.salesperson_firstname
	, nss.salesperson_lastname
	, annualnumofsales.yearsold
	, annualnumofsales.annualnumofsales

print '-----'
print '-- rpt_salesperson_annualcommission complete'

	/*
	* 2018-01: Sadie 
	*/
	
/* DGM Pass 1: 	
	10. Drop table demo.rpt_regioncustomer sales. Setting up for similar pattern
		a. Back to Sadie
		b. Uses multiple CTEs
			i. First gets cutsomerid, region and state from nightly staging. 
				1) This feels like it could be hidden elsewhere. Is it? Should it be? 
				2) CASE WHEN to define the region individually. Hard to read 
			ii. Second uses correlated inline subqueries that all relate back to demo.nightlysalesstaging
		c. Full SELECT uses t2.* - list out columns!
		d. Full SELECT also has a join back to demo.nightlysalesstaging. This means multiple references to the same table. CTEs aren't materialised.
		e. Potential performance issues - 
			i. Uses multiple CTEs
			ii. The correlated inline subqueries may be able to be replaced with windowed functions
			iii. Look into how demo.nightlysalesstaging is really used for this query and see if it can be simplified through the entire statement


*/
	drop table demo.rpt_regioncustomersales

	;

	with customer_regions_cte
	as (
		select distinct customerid,
			case 
				when state = 'ak' then 'region 1' when state = 'al' then 'region 1' when state = 'az' then 'region 1' when state = 'ca' then 'region 1'
				when state = 'co' then 'region 1' when state = 'ct' then 'region 1' when state = 'de' then 'region 1' when state = 'fl' then 'region 1'
				when state = 'ga' then 'region 1' when state = 'hi' then 'region 1' when state = 'ia' then 'region 1' 
				when state = 'id' then 'region 2' when state = 'il' then 'region 2' when state = 'in' then 'region 2' when state = 'ks' then 'region 2'
				when state = 'ky' then 'region 2' when state = 'la' then 'region 2' 
				when state = 'ma' then 'region 3' when state = 'md' then 'region 3' when state = 'me' then 'region 3' when state = 'mi' then 'region 3'
				when state = 'mn' then 'region 3' when state = 'mo' then 'region 3' when state = 'ms' then 'region 3' when state = 'nd' then 'region 3'
				when state = 'nh' then 'region 4' when state = 'nm' then 'region 4' when state = 'ny' then 'region 4' when state = 'oh' then 'region 4'
				when state = 'ok' then 'region 4' when state = 'or' then 'region 4' when state = 'pa' then 'region 4' when state = 'ri' then 'region 4'
				when state = 'sc' then 'region 4' when state = 'sd' then 'region 4'
				when state = 'tn' then 'region 5' when state = 'tx' then 'region 5' when state = 'ut' then 'region 5' when state = 'va' then 'region 5'
				when state = 'vt' then 'region 5' when state = 'wa' then 'region 5' when state = 'wi' then 'region 5' when state = 'wv' then 'region 5'
				when state = 'wy' then 'region 5' 
				end as region,
			state
		from demo.nightlysalesstaging nss
		),
	customer_purchase_summary_cte
	as (
		select customerid,
			case 
				when exists (
						select 1
						from demo.nightlysalesstaging t2
						where t1.customerid = t2.customerid
						having count(1) > 1
						)
					then 'multiple purchases'
				when exists (
						select 1
						from demo.nightlysalesstaging t3
						where t1.customerid = t3.customerid
						having count(1) = 1
						)
					then 'single purchase'
				when exists (
						select 1
						from demo.nightlysalesstaging t4
						where t1.customerid = t4.customerid
						having count(1) = 0
						)
					then 'zero purchases'
				else 'error'
				end as purchases
		from demo.nightlysalesstaging t1
		where t1.transactiondate between @startdate and @enddate
		)

	select 
		t1.region, t1.state,
		t2.*,
		t3.customer_firstname,
		t3.customer_lastname
	into demo.rpt_regioncustomersales
	from customer_regions_cte t1
	join customer_purchase_summary_cte t2
		on t1.customerid = t2.customerid
	join demo.nightlysalesstaging t3
		on t1.customerid = t3.customerid
			and t2.customerid = t3.customerid
	where t3.transactiondate between @startdate and @enddate

	print '-----'
	print '-- rpt_regioncustomersales complete'



/* 04-08-2018 - Sebastian Chihuahua-Terrier - stuff that hasn't sold */

/* DGM Pass 1: 	
	12. Demo.rpt_unsoldinventory - drop table and then recreate
		a. Using a temp table. TOP 0 for creating the temp table
		b. Inserts into the temp table from a stored procedure: demo.sp_searchallsoldinventory
		c. Uses the returned data (with a SELECT *) into the demo.rpt_unsoldinventory
			i. Since we're creating the table here, we do know all of the columns but we still shouldn't use SELECT *
		d. Potential bug:
			i. Not seeing any aliases being used. This could be a potential bug since SQL Server may use the wrong InventoryID for the NOT IN clause when insert into demo.rpt_unsoldinventory. 
		e. Potential Performance Implications for all of these:
			i. Using TOP 0 instead of the WHERE clause. When thinking about the logical order of operations, Top is the last thing done. This means the entire query is being executed with all of the data BEFORE it finally realizes it doesn't need data. While we shouldn’t be doing it this way - just create all of your temp tables at the beginning (which should be the best way to do this - if it hasn't changed on me - confirm this somewhere), if you do need to, use WHERE 1 = 0 so no data is returned from the start.
			ii. It's extra true for this particular statement since it's all of the same tables that are being used in the following stored proc, demo.sp_searchallsoldinventory
			iii. The stored procedure looks to be a catch-all proc. Need to confirm the performance of that proc
			
*/

drop table demo.rpt_unsoldinventory

select top 0 inventory.vin
	, make.makename
	, model.modelname
	, color.colorname
	, package.packagename
	, inventory.invoiceprice
	, inventory.msrp
	, saleshistory.sellprice
	, inventory.datereceived
	, saleshistory.transactiondate
	, inventory.inventoryid
	, saleshistory.saleshistoryid
into #tmpsoldinventory
from dbo.inventory
inner join vehicle.basemodel on inventory.basemodelid = basemodel.basemodelid
inner join vehicle.make on basemodel.makeid = make.makeid
inner join vehicle.model on basemodel.modelid = model.modelid
inner join vehicle.color on basemodel.colorid = color.colorid
inner join vehicle.package on inventory.packageid = package.packageid
inner join dbo.saleshistory on saleshistory.inventoryid = inventory.inventoryid

insert into #tmpsoldinventory
exec demo.sp_searchallsoldinventory @transactiondatemin = @startdate
	, @transactiondatemax = @enddate

select *
	, @startdate as startdate
	, @enddate as enddate
into demo.rpt_unsoldinventory
from dbo.inventory
where inventoryid not in (
		select inventoryid
		from #tmpsoldinventory
		) and datereceived between @startdate and @enddate

print '-----'
print '-- rpt_unsoldinventory complete'


END
GO