USE FARMS_HORSE;
GO

-- This example demonstrates the functionality of:

-- sp_InsertBillingCharges
-- tr_UpdateRoomAvailability //TODO
-- tr_CheckHousekeepingCharges
-- tr_CheckRepairCharges //TODO
-- tr_CheckRoomReservations //TODO


-- Show Housekeeping and Repair services with extra charges

SELECT * FROM Housekeeping;

PRINT '';
PRINT 'Setting housekeeping jobs #1 and #2 as complete.';
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