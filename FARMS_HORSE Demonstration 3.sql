-- This example demonstrates the functionality of:

-- tr_CheckHousekeepingEmployee
-- tr_CheckRepairEmployee
-- tr_CheckRoomReservations
-- sp_UpdateFolioRoom
-- fn_GetAvailableRoom

USE FARMS_HORSE;
GO


-- Attempt to schedule the wrong type of employee to housekeeping and repairs

PRINT '';
PRINT 'Show housekeeping schedule: ';
PRINT '';
SELECT * FROM Housekeeping;

PRINT 'Show employees at Hotel 2300: ';
PRINT '';
SELECT * FROM Employee
WHERE HotelID = 2300
ORDER BY PositionID;

PRINT 'Attempt to set a repairperson to a housekeeping job: ';
PRINT '';
UPDATE Housekeeping
SET EmployeeID = 3023
WHERE HousekeepingID = 1;
GO

PRINT '';
SELECT * FROM Housekeeping;

PRINT 'Attempt to insert a new Repair for a Housekeeper: ';
PRINT '';
INSERT INTO Repair(EmployeeID, HousekeepingRoomID, FolioID, RepairTypeID, RepairStatus)
VALUES (3013, 15, 1, 1, 'P');
GO

PRINT '';
SELECT * FROM Repair
WHERE EmployeeID = 3013;


-- Reschedule reservations when a room becomes unavailable due to repairs

PRINT '';
PRINT 'Set room 7 as unavailable due to repairs and update reservations accordingly';
INSERT INTO [FARMS].[dbo].[Folio]
VALUES (5019, 1505, 7, 351.00, GETDATE(), 3, 'R', NULL, 1);

PRINT '';
PRINT 'Look at the upcoming reservation: ';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Folio]
WHERE Status = 'R';

PRINT 'Find other rooms with the same type: ';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Room]
WHERE RoomTypeID = 4;

PRINT 'If this room becomes unavailable, reservations should switch over to RoomID = 6';
UPDATE HousekeepingRoom
SET RoomStatus = 'R'
WHERE RoomID = 7;

PRINT '';
PRINT 'Look at the updated reservation: ';
PRINT '';
SELECT * FROM [FARMS].[dbo].[Folio]
WHERE Status = 'R';


-- END OF DEMONSTRATION --


-------------------------------
-- tr_CheckHousekeepingEmployee
-------------------------------

--Checks to see if the given EmployeeID is a Housekeeper. Rejects the change if the
--EmployeePositionID doesn't match.

GO
CREATE TRIGGER tr_CheckHousekeepingEmployee ON Housekeeping
AFTER INSERT, UPDATE
AS
	BEGIN
		
		DECLARE @EmployeeID smallint

		SET @EmployeeID = (SELECT EmployeeID FROM Inserted)

		IF ((SELECT PositionID FROM Employee WHERE EmployeeID = @EmployeeID) != 1)
		BEGIN
			RAISERROR ('EmployeeID is not a Housekeeper, please choose an employee that is a houskeeper.', 16, 1)
			ROLLBACK
		END

	END

GO


-------------------------
-- tr_CheckRepairEmployee
-------------------------

--Checks to see if the given EmployeeID is a Repairperson. Rejects the change if the 
--EmployeePositionID doesn't match.

GO
CREATE TRIGGER tr_CheckRepairEmployee ON Repair
AFTER INSERT, UPDATE
AS
	BEGIN
		DECLARE @EmployeeID smallint

		SET @EmployeeID = (SELECT EmployeeID FROM Inserted)

		IF ((SELECT PositionID FROM Employee WHERE EmployeeID = @EmployeeID) != 2)
		BEGIN
			RAISERROR ('EmployeeID is not a Repairs, please choose an employee that is a Repairs.', 16, 1)
			ROLLBACK
		END
	END

GO


---------------------------
-- tr_CheckRoomReservations
---------------------------

--When a RoomStatus is set to 'R', checks to see if there are any upcoming Folios for that 
--room during the repair duration, and if so calls fn_GetAvailableRoom to assign a new RoomID.

GO
CREATE TRIGGER tr_CheckRoomReservations ON HousekeepingRoom
AFTER UPDATE
AS
	-- Room is under repairs
	IF UPDATE(RoomStatus)
		BEGIN
			DECLARE @FolioID					SMALLINT;
			DECLARE @RoomID						SMALLINT;

			SELECT	@RoomID						= RoomID
			FROM inserted;

			-- Find all upcoming reservations (today or tomorrow) for this room number
			DECLARE cursor_RoomReservations CURSOR
			FOR
				SELECT FolioID
				FROM [FARMS].[dbo].[Folio]
				WHERE RoomID = @RoomID
				AND CheckinDate > FORMAT(GETDATE(), 'MM/dd/yyyy')
				AND CheckinDate < FORMAT(DATEADD(DAY, 2, GETDATE()), 'MM/dd/yyyy')
				AND Status = 'R';

			OPEN cursor_RoomReservations;
			FETCH NEXT FROM cursor_RoomReservations INTO @FolioID;

			WHILE @@FETCH_STATUS = 0
				BEGIN
					EXEC sp_UpdateFolioRoom
						@FolioID					= @FolioID;
					
					FETCH NEXT FROM cursor_RoomReservations INTO @FolioID;
				END
			CLOSE cursor_RoomReservations;
			DEALLOCATE cursor_RoomReservations;
		END
GO


---------------------
-- sp_UpdateFolioRoom
---------------------

--Updates the RoomID in a reservation when the current Room is no longer available.

GO
CREATE PROCEDURE sp_UpdateFolioRoom
(
	@FolioID						SMALLINT
)
AS
	DECLARE @RoomID						SMALLINT;
	DECLARE @NewRoomID					SMALLINT;

	SELECT	@RoomID						= RoomID 
	FROM [FARMS].[dbo].[Folio]
	WHERE FolioID = @FolioID;

	SELECT @NewRoomID					= dbo.fn_GetAvailableRoom(@RoomID);

	UPDATE [FARMS].[dbo].[Folio]
	SET RoomID = @NewRoomID
	WHERE FolioID = @FolioID;
GO


----------------------
-- fn_GetAvailableRoom
----------------------

--Gets the RoomID of an available room at the same hotel on the specified date.

GO
CREATE FUNCTION fn_GetAvailableRoom
(
	@UnavailableRoomID					SMALLINT
)
RETURNS SMALLINT
AS
	BEGIN
		DECLARE @RoomID						SMALLINT;
		DECLARE @HotelID					SMALLINT;
		DECLARE @RoomTypeID					SMALLINT;

		DECLARE @Query						TABLE(
			RoomID						SMALLINT,
			HotelID						SMALLINT,
			RoomTypeID					SMALLINT
		);

		INSERT INTO @Query SELECT * 
		FROM OPENQUERY(LOCALSERVER, 'Select RoomID, HotelID, RoomTypeID FROM FARMS.dbo.Room');

		-- Get the room type and hotel of the unavailable room
		SELECT	@HotelID				= HotelID, 
				@RoomTypeID				= RoomTypeID 
		FROM @Query WHERE RoomID = @UnavailableRoomID;

		-- Select the first available room with the same room type in the same hotel
		SELECT TOP(1) @RoomID = Query.RoomID
		FROM @Query AS Query
		INNER JOIN HousekeepingRoom ON (Query.RoomID = HousekeepingRoom.RoomID)
		WHERE Query.HotelID = @HotelID
		AND Query.RoomTypeID = @RoomTypeID
		AND HousekeepingRoom.RoomStatus = 'A';

		RETURN @RoomID;
	END
GO