SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE demo.[sp_SearchAllSoldInventory] (
	@MakeName VARCHAR(50) = NULL,	-- = 'Toyota',
	@ModelName VARCHAR(50) = NULL,	-- = 'RAV4',
	@ColorName VARCHAR(50) = NULL,	-- = 'Black',
	@PackageName VARCHAR(50) = NULL,	-- = 'Special Edition',
	@InvoicePriceMin MONEY = NULL,	-- = 20000,
	@InvoicePriceMax MONEY = NULL,	-- = 50000,
	@MSRPMin money = NULL,	-- = 20000,
	@MSRPMax money = NULL,	-- = 55000,
	@SellPriceMin money = NULL,	-- = 20000,
	@SellPriceMax money = NULL,	-- = 60000,
	@DateReceivedMin date = NULL,	-- = '2020-01-01',
	@DateReceivedMax date = NULL,	-- = '2021-12-01',
	@TransactionDateMin DATETIME = NULL,	-- = '2021-01-01',
	@TransactionDateMax DATETIME = NULL	-- = '2023-01-01'
)
AS
BEGIN
	SELECT
		Inventory.VIN,
		Make.MakeName,
		Model.ModelName,
		Color.ColorName,
		Package.PackageName,
		Inventory.InvoicePrice,
		Inventory.MSRP,
		SalesHistory.SellPrice,
		Inventory.DateReceived,
		SalesHistory.TransactionDate,
		Inventory.InventoryID,
		SalesHistory.SalesHistoryID
	FROM dbo.Inventory
	INNER JOIN Vehicle.BaseModel
		ON Inventory.BaseModelID = BaseModel.BaseModelID
	INNER JOIN Vehicle.Make
		ON BaseModel.MakeID = Make.MakeID
	INNER JOIN Vehicle.Model
		ON BaseModel.ModelID = Model.ModelID
	INNER JOIN Vehicle.Color
		ON BaseModel.ColorID = Color.ColorID
	INNER JOIN Vehicle.Package
		ON Inventory.PackageID = Package.PackageID    
	INNER JOIN dbo.SalesHistory
		ON SalesHistory.InventoryID = Inventory.InventoryID
	WHERE (
		Make.MakeName = @MakeName
		OR @MakeName IS NULL
	)
	AND (
		Model.ModelName = @ModelName
		OR @ModelName IS NULL
	)
	AND (
		Color.ColorName = @ColorName
		OR @ColorName IS NULL
	)
	AND (
		Package.PackageName = @PackageName
		OR @PackageName IS NULL
	)
	AND (
		Inventory.InvoicePrice BETWEEN COALESCE(@InvoicePriceMin, 1) AND COALESCE(@InvoicePriceMax, 999999)
	)
	AND (
		Inventory.MSRP BETWEEN COALESCE(@MSRPMin, 1) AND COALESCE(@MSRPMax, 999999)
	)
	AND (
		SalesHistory.SellPrice BETWEEN COALESCE(@SellPriceMin, 1) AND COALESCE(@SellPriceMax, 999999)
	)
	AND (
		SalesHistory.SellPrice BETWEEN COALESCE(@SellPriceMin, 1) AND COALESCE(@SellPriceMax, 999999)
	)
	AND (
		Inventory.DateReceived BETWEEN COALESCE(@DateReceivedMin, '1900-01-01') AND COALESCE(@DateReceivedMax, '2050-01-01')
	)
	AND (
		SalesHistory.TransactionDate BETWEEN COALESCE(@TransactionDateMin, '1900-01-01') AND COALESCE(@TransactionDateMax, '2050-01-01')
	);
END
GO