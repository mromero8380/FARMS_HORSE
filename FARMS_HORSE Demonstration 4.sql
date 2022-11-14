-- This example demonstrates the functionality of:

-- tr_CheckHousekeepingCharges
-- sp_InsertHousekeepingBillingCharges
-- tr_CheckRepairCharges				
-- sp_InsertRepairBillingCharges	
-- tr_UpdateRoomAvailability

USE FARMS_HORSE;
GO


-- Show Housekeeping services with extra charges

SELECT * FROM Housekeeping;

PRINT '';
PRINT 'Setting housekeeping services in 1 and 2 as complete.';
PRINT '';

UPDATE HousekeepingService SET ServiceStatus = 'C'
WHERE HousekeepingID IN (1, 2);


PRINT '';
PRINT 'Add additional housekeeping services';
PRINT '';
INSERT INTO HousekeepingService (HousekeepingID, ServiceTypeID, ServiceStatus, ServiceNotes)
VALUES	(1, 6, 'C', 'Additional housekeeping'),
		(1, 13, 'C', 'Additional housekeeping'),
		(1, 29, 'C', 'Additional housekeeping'),
		(2, 6, 'C', 'Additional housekeeping'),
		(2, 10, 'C', 'Additional housekeeping'),
		(2, 25, 'C', 'Additional housekeeping'),
		(2, 26, 'C', 'Additional housekeeping');

PRINT '';
PRINT 'Showing additional charges';
PRINT '';
SELECT * FROM HousekeepingService
WHERE HousekeepingID IN (1,2);


PRINT '';
PRINT 'Showing current billing charges';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 1; --HousekeepingID 1
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 4; --HousekeepingID 2

PRINT '';
PRINT 'Update the Housekeeping Status and trigger tr_CheckHousekeepingCharges';
UPDATE Housekeeping SET HousekeepingStatus = 'C', TimeCompleted = GETDATE()
WHERE HousekeepingID = 1;

UPDATE Housekeeping SET HousekeepingStatus = 'C', TimeCompleted = GETDATE()
WHERE HousekeepingID = 2;

PRINT '';
PRINT 'Showing updated billing charges';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 1; --HousekeepingID 1
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 4; --HousekeepingID 2


-- Show repairs with extra charges

PRINT '';
PRINT 'Showing current Repair';
PRINT '';

SELECT * FROM Repair;

PRINT '';
PRINT 'Adding 3 new repairs on a single folio';
PRINT '';

INSERT INTO Repair
VALUES	(3006, 13, 10, 1, 'P', NULL, NULL);

INSERT INTO Repair
VALUES	(3006, 13, 10, 2, 'P', NULL, NULL);

INSERT INTO Repair
VALUES	(3006, 13, 10, 3, 'P', NULL, NULL);

PRINT '';
PRINT 'Showing current Repair';
PRINT '';

SELECT * FROM Repair;

PRINT '';
PRINT 'Showing current billing charges';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 10;

PRINT '';
PRINT 'Update the RepairStatus and trigger tr_CheckRepairCharges';

UPDATE Repair SET RepairStatus = 'C', TimeCompleted = GETDATE()
WHERE RepairID = 27

PRINT '';
PRINT 'Showing Updated Billing Charges';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 10;

PRINT '';
PRINT 'Update the RepairStatus and trigger tr_CheckRepairCharges';

UPDATE Repair SET RepairStatus = 'C', TimeCompleted = GETDATE()
WHERE RepairID = 28

PRINT '';
PRINT 'Showing Updated Billing Charges';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 10;

PRINT '';
PRINT 'Update the RepairStatus and trigger tr_CheckRepairCharges';

UPDATE Repair SET RepairStatus = 'C', TimeCompleted = GETDATE()
WHERE RepairID = 29

PRINT '';
PRINT 'Showing Updated Billing Charges';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Billing] WHERE FolioID = 10;


-- Show that a room becomes available for checkout after all pending repairs are completed

PRINT 'Show that Room #11 is unavailable for checkout: ';
PRINT '';
SELECT * FROM HousekeepingRoom
WHERE HousekeepingRoomID = 11;

PRINT 'Show outstanding repairs for Room # 11: ';
PRINT '';
SELECT * FROM Repair 
WHERE HousekeepingRoomID = 11;

PRINT 'When the repair is completed, the room will now be available for checkout: ';
UPDATE Repair
SET RepairStatus = 'C'
WHERE RepairID = 6

PRINT '';
SELECT * FROM HousekeepingRoom
WHERE HousekeepingRoomID = 11;


-- END OF DEMONSTRATION --


------------------------------
-- tr_CheckHousekeepingCharges
------------------------------

--When housekeeping is completed, checks to see if any housekeeping services have an extra 
--charge, and calls sp_InsertBillingCharges if so.

GO
CREATE TRIGGER tr_CheckHousekeepingCharges ON Housekeeping
AFTER UPDATE
AS
	-- Housekeeping was completed
	IF UPDATE(HousekeepingStatus) AND ((SELECT HousekeepingStatus FROM inserted) = 'C')
		BEGIN
			DECLARE @FolioID					SMALLINT;
			SELECT	@FolioID					= FolioID 
			FROM inserted;

			EXEC sp_InsertHousekeepingBillingCharges
				@FolioID					= @FolioID;
		END
GO


--------------------------------------
-- sp_InsertHousekeepingBillingCharges
--------------------------------------

--If a housekeeping service has an additional charge, insert new rows into Billing under 
--the given FolioID for all additional charges.

GO
CREATE PROCEDURE sp_InsertHousekeepingBillingCharges
(
	@FolioID					SMALLINT
)
AS
	-- Insert extra housekeeping charges
	INSERT INTO [FARMS].[dbo].[Billing] (FolioID, BillingCategoryID, BillingDescription, BillingAmount, BillingItemQty, BillingItemDate)
	SELECT Housekeeping.FolioID, 10, CAST(ServiceType.ServiceName AS CHAR(30)), ServiceType.ServiceCost, 1, ISNULL(Housekeeping.TimeCompleted, GETDATE())
	FROM HousekeepingService
	INNER JOIN Housekeeping ON (HousekeepingService.HousekeepingID = Housekeeping.HousekeepingID)
	INNER JOIN ServiceType ON (HousekeepingService.ServiceTypeID = ServiceType.ServiceTypeID)
	WHERE Housekeeping.FolioID = @FolioID
	AND ServiceType.ServiceCost > 0 --only charge for services that cost extra
GO


------------------------
-- tr_CheckRepairCharges
------------------------

--When repairs are completed, checks to see if they have an extra charge, and calls 
--sp_InsertBillingCharges if so.

GO
CREATE TRIGGER tr_CheckRepairCharges ON Repair
AFTER UPDATE
AS
	-- Repair was completed
	IF UPDATE(RepairStatus) AND ((SELECT RepairStatus FROM inserted) = 'C')
		BEGIN
			DECLARE @FolioID					SMALLINT;
			DECLARE @RepairID					SMALLINT;

			SELECT	@FolioID					= FolioID,
					@RepairID					= RepairID
			FROM inserted;

			EXEC sp_InsertRepairBillingCharges
				@FolioID					= @FolioID,
				@RepairID					= @RepairID;
		END
GO


--------------------------------
-- sp_InsertRepairBillingCharges
--------------------------------

--If a repair has an additional charge, insert a new row into Billing under the given 
--FolioID for that cost.

GO
CREATE PROCEDURE sp_InsertRepairBillingCharges
(
	@FolioID					SMALLINT,
	@RepairID					SMALLINT
)
AS
	-- Insert extra repairs charges
	INSERT INTO [FARMS].[dbo].[Billing] (FolioID, BillingCategoryID, BillingDescription, BillingAmount, BillingItemQty, BillingItemDate)
	SELECT Repair.FolioID, 11, CAST(RepairType.RepairName AS CHAR(30)), RepairType.RepairCost, 1, ISNULL(Repair.TimeCompleted, GETDATE())
	FROM Repair
	INNER JOIN RepairType ON (Repair.RepairTypeID = RepairType.RepairTypeID)
	WHERE Repair.FolioID = @FolioID
	AND Repair.RepairID = @RepairID
	AND RepairType.RepairCost > 0 --only charge for repairs that cost extra
GO


----------------------------
-- tr_UpdateRoomAvailability
----------------------------

--Checks to see if a room has any outstanding repairs, and if not, sets the room as available 
--for reservations.

GO
CREATE TRIGGER tr_UpdateRoomAvailability ON Repair
AFTER INSERT, UPDATE
AS
	DECLARE @RepairStatus char(1)
	DECLARE @HousekeepingRoomID smallint

	SELECT @RepairStatus = (SELECT RepairStatus FROM Inserted)
	SELECT @HousekeepingRoomID = (SELECT HousekeepingRoomID FROM Inserted)
		
	IF UPDATE(RepairStatus) AND @RepairStatus != 'P'
		IF NOT EXISTS 
		(
			SELECT HousekeepingRoomID
			FROM Repair 
			WHERE HousekeepingRoomID = @HousekeepingRoomID
			AND RepairStatus = 'P'
		)
		BEGIN
			UPDATE HousekeepingRoom
			SET RoomStatus = 'A'
			WHERE HousekeepingRoomID = @HousekeepingRoomID
		END
GO