-- This example demonstrates the functionality of:

-- sp_InsertHousekeeping
-- fn_GetAvailableEmployee
-- sp_InsertHousekeepingServices
-- fn_GetDefaultHousekeepingServices
-- fn_GetFolioRoomType

USE FARMS_HORSE;
GO


-- Show housekeeping services

PRINT 'Showing that certain housekeeping services will be applied to all housekeeping jobs by default: ';
PRINT '';
SELECT ServiceTypeID, CAST(ServiceName AS CHAR(40)) ServiceName, ServiceCost, CAST(ServiceDescription AS CHAR(64)) ServiceDescription, IsDefaultService
FROM ServiceType
ORDER BY ServiceCost, IsDefaultService DESC;
PRINT '';


PRINT 'Showing that some room types have additional default housekeeping services: ';
PRINT '';
SELECT CONCAT(CAST(FARMS_RoomType.RTDescription AS CHAR(20)), ' ...') RoomTypeDescription, ServiceType.ServiceTypeID, 
	CAST(ServiceName AS CHAR(40)) ServiceName, ServiceCost, CAST(ServiceDescription AS CHAR(64)) ServiceDescription
FROM DefaultServiceType
INNER JOIN ServiceType ON (DefaultServiceType.ServiceTypeID = ServiceType.ServiceTypeID)
INNER JOIN HousekeepingRoomType ON (DefaultServiceType.HousekeepingRoomTypeID = HousekeepingRoomType.HousekeepingRoomTypeID)
INNER JOIN (SELECT RoomTypeID, RTDescription FROM OPENQUERY(LOCALSERVER, 'SELECT RoomTypeID, RTDescription FROM FARMS.dbo.RoomType')) AS FARMS_RoomType 
	ON (HousekeepingRoomType.RoomTypeID = FARMS_RoomType.RoomTypeID);
PRINT '';


-- Schedule Housekeeping

PRINT 'All folios that have Status = ''C'': ';
SELECT *
FROM OPENQUERY (LOCALSERVER, 'Select Folio.FolioID, Folio.RoomID, Room.HotelID FROM FARMS.dbo.Folio INNER JOIN FARMS.dbo.Room ON (Folio.RoomID = Room.RoomID) WHERE Status = ''C''');


PRINT 'All Folios that have had housekeeping scheduled: ';
SELECT Housekeeping.FolioID, Housekeeping.HousekeepingID, Housekeeping.EmployeeID, CAST(ServiceName AS CHAR(40)) ServiceName, ServiceCost FROM HousekeepingService
INNER JOIN Housekeeping ON (HousekeepingService.HousekeepingID = Housekeeping.HousekeepingID)
INNER JOIN ServiceType ON (HousekeepingService.ServiceTypeID = ServiceType.ServiceTypeID)
WHERE FolioID IN (
	SELECT FolioID FROM OPENQUERY (LOCALSERVER, 'Select FolioID FROM FARMS.dbo.Folio WHERE Status = ''C'''));


PRINT 'Run the stored procedure to schedule housekeeping: ';
EXEC sp_InsertHousekeeping;
PRINT '';


PRINT 'All Folios that have had housekeeping scheduled (should now match all folios with Status = ''C''): ';
SELECT Housekeeping.FolioID, Housekeeping.HousekeepingID, Housekeeping.EmployeeID, CAST(ServiceName AS CHAR(40)) ServiceName, ServiceCost FROM HousekeepingService
INNER JOIN Housekeeping ON (HousekeepingService.HousekeepingID = Housekeeping.HousekeepingID)
INNER JOIN ServiceType ON (HousekeepingService.ServiceTypeID = ServiceType.ServiceTypeID)
WHERE FolioID IN (
	SELECT FolioID FROM OPENQUERY (LOCALSERVER, 'Select FolioID FROM FARMS.dbo.Folio WHERE Status = ''C'''));


-- END OF DEMONSTRATION --


------------------------
-- sp_InsertHousekeeping
------------------------

--Inserts a row into Housekeeping when a Folio's status changes to 'C'.

--We can't set a trigger on FARMS so instead we'll execute sp_InsertHousekeeping periodically
--and create Housekeeping records for any checked-out Folios that still need housekeeping.

GO
CREATE PROCEDURE sp_InsertHousekeeping
AS
	DECLARE @FolioID				SMALLINT;
	DECLARE @RoomID					SMALLINT;
	DECLARE @HotelID				SMALLINT;
	DECLARE @EmployeeID				SMALLINT;
	DECLARE @HousekeepingRoomID		SMALLINT;
	DECLARE @HousekeepingID			SMALLINT;

	-- Find all of the Folios with Status = 'C'
	DECLARE cursor_FolioCheckout CURSOR
	FOR
		SELECT FolioID, RoomID, HotelID
		FROM OPENQUERY (LOCALSERVER, 'Select Folio.FolioID, Folio.RoomID, Room.HotelID FROM FARMS.dbo.Folio INNER JOIN FARMS.dbo.Room ON (Folio.RoomID = Room.RoomID) WHERE Status = ''C''');

	OPEN cursor_FolioCheckout;
	FETCH NEXT FROM cursor_FolioCheckout INTO @FolioID, @RoomID, @HotelID;

	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Find all Folios that have no been scheduled for Housekeeping yet
			IF NOT EXISTS (SELECT 1 FROM Housekeeping WHERE FolioID = @FolioID)
				BEGIN
					SELECT @HousekeepingRoomID = HousekeepingRoomID FROM HousekeepingRoom WHERE RoomID = @RoomID;

					SELECT @EmployeeID = dbo.fn_GetAvailableEmployee(
						@HotelID, 
						1, 
						GETDATE(), 
						(SELECT EstimatedCleanTime 
							FROM HousekeepingRoomType 
							INNER JOIN HousekeepingRoom ON ( HousekeepingRoomType.HousekeepingRoomTypeID = HousekeepingRoom.HousekeepingRoomTypeID)
							WHERE HousekeepingRoomID = @HousekeepingRoomID)
					);
					
					INSERT INTO Housekeeping (EmployeeID, HousekeepingRoomID, FolioID, HousekeepingStatus)
					VALUES (@EmployeeID, @HousekeepingRoomID, @FolioID, 'P');

					EXEC sp_InsertHousekeepingServices 
						@HousekeepingID = @@IDENTITY;
				END
			FETCH NEXT FROM cursor_FolioCheckout INTO @FolioID, @RoomID, @HotelID;
		END

	CLOSE cursor_FolioCheckout;
	DEALLOCATE cursor_FolioCheckout;
GO


--------------------------
-- fn_GetAvailableEmployee
--------------------------

--Gets the EmployeeID of the next employee who's available for a housekeeping or repair job 
--that is estimated to take the given amount of time.

GO
CREATE FUNCTION fn_GetAvailableEmployee
(
	@HotelID						SMALLINT,
	@PositionID						SMALLINT,
	@Date							DATETIME,
	@EstimatedJobTime				TINYINT
)
RETURNS SMALLINT
AS
	BEGIN
		DECLARE @EmployeeID				SMALLINT;
		DECLARE @CurrentEmployeeID		SMALLINT;
		DECLARE @ShiftMinutes			SMALLINT; -- The total amount of minutes in an employee's shift
		DECLARE @ScheduledMinutes		SMALLINT; -- The sum of the estimated time of jobs assigned to an employee

		-- Loop through employees who have a scheduled shift today and get the total time of their shift in minutes
		DECLARE cursor_AvailableEmployees CURSOR
			FOR
				SELECT EmployeeWeeklyShift.EmployeeID, DATEDIFF(Minute, ShiftStart, ShiftEnd) AS ShiftMinutes
				FROM EmployeeWeeklyShift
				INNER JOIN Employee ON (EmployeeWeeklyShift.EmployeeID = Employee.EmployeeID)
				WHERE Employee.HotelID = @HotelID
				AND Employee.PositionID = @PositionID
				AND DayOfWeek = DATEPART(dw, @Date)
				AND ShiftStatus = 'S';

		OPEN cursor_AvailableEmployees;
		FETCH NEXT FROM cursor_AvailableEmployees INTO @CurrentEmployeeID, @ShiftMinutes;

		WHILE @@FETCH_STATUS = 0 AND @EmployeeID IS NULL
			BEGIN
				-- Get the sum of the estimated time of jobs assigned to an employee
				IF (@PositionID = 1) -- The employee is a housekeeper
					BEGIN
						SELECT @ScheduledMinutes = COALESCE(SUM(HousekeepingRoomType.EstimatedCleanTime), 0)
						FROM Housekeeping
						INNER JOIN HousekeepingRoom ON (Housekeeping.HousekeepingRoomID = HousekeepingRoom.HousekeepingRoomID)
						INNER JOIN HousekeepingRoomType ON (HousekeepingRoom.HousekeepingRoomTypeID = HousekeepingRoomType.HousekeepingRoomTypeID)
						WHERE Housekeeping.EmployeeID = @EmployeeID
						AND Housekeeping.HousekeepingStatus = 'P';
					END
				ELSE -- The employee is a repairperson
					BEGIN
						SELECT @ScheduledMinutes = COALESCE(SUM(RepairType.EstimatedRepairTime), 0)
						FROM Repair
						INNER JOIN RepairType ON (RepairType.RepairTypeID = Repair.RepairTypeID)
						WHERE Repair.EmployeeID = @EmployeeID
						AND Repair.RepairStatus = 'P';
					END

				-- The employee has time to clean this room
				IF (@ScheduledMinutes + @EstimatedJobTime <= @ShiftMinutes)
					BEGIN
						SET @EmployeeID = @CurrentEmployeeID;
					END

				FETCH NEXT FROM cursor_AvailableEmployees INTO @CurrentEmployeeID, @ShiftMinutes;
			END
		CLOSE cursor_AvailableEmployees;
		DEALLOCATE cursor_AvailableEmployees;

		RETURN @EmployeeID; -- NULL if there are no available employees
	END
GO


--------------------------------
-- sp_InsertHousekeepingServices
--------------------------------

--Inserts default housekeeping services for a housekeeping record based on the room type.

GO
CREATE PROCEDURE sp_InsertHousekeepingServices
(
	@HousekeepingID				SMALLINT
)
AS
	DECLARE @FolioID				SMALLINT;

	SELECT @FolioID					= FolioID 
	FROM Housekeeping WHERE HousekeepingID = @HousekeepingID;

	INSERT INTO HousekeepingService (HousekeepingID, ServiceTypeID, ServiceStatus)
	(SELECT @HousekeepingID, DefaultServices.ServiceTypeID, DefaultServices.ServiceStatus
	FROM fn_GetDefaultHousekeepingServices(@FolioID) AS DefaultServices);
GO


------------------------------------
-- fn_GetDefaultHousekeepingServices
------------------------------------

--Gets a table with the default Housekeeping Services for a given RoomTypeID.

GO
CREATE FUNCTION fn_GetDefaultHousekeepingServices
(
	@FolioID					SMALLINT
)
RETURNS @DefaultServices TABLE
(
	ServiceTypeID				SMALLINT,
	ServiceStatus				CHAR(1)
)
AS
	BEGIN
		DECLARE @RoomTypeID					SMALLINT;
		SELECT @RoomTypeID = dbo.fn_GetFolioRoomType(@FolioID);

		INSERT INTO @DefaultServices(ServiceTypeID, ServiceStatus)
		(SELECT ServiceTypeID, 'P'
		FROM ServiceType
		WHERE ServiceType.IsDefaultService = 1);

		INSERT INTO @DefaultServices (ServiceTypeID, ServiceStatus)
		(SELECT ServiceType.ServiceTypeID, 'P'
		FROM DefaultServiceType
		INNER JOIN ServiceType ON (DefaultServiceType.ServiceTypeID = ServiceType.ServiceTypeID)
		INNER JOIN HousekeepingRoomType ON (DefaultServiceType.HousekeepingRoomTypeID = HousekeepingRoomType.HousekeepingRoomTypeID)
		WHERE HousekeepingRoomType.RoomTypeID = @RoomTypeID
		AND ServiceType.IsDefaultService = 0);

		RETURN;
	END
GO


----------------------
-- fn_GetFolioRoomType
----------------------

--Gets a RoomTypeID from a given FolioID.

GO
CREATE FUNCTION fn_GetFolioRoomType
(
	@FolioID					SMALLINT
)
RETURNS SMALLINT
AS
	BEGIN
		DECLARE @RoomTypeID					SMALLINT;
		DECLARE @Query						TABLE(
			FolioID								SMALLINT,
			RoomTypeID							SMALLINT
		);

		INSERT INTO @Query SELECT * 
		FROM OPENQUERY(LOCALSERVER, 'Select Folio.FolioID, Room.RoomTypeID FROM FARMS.dbo.Folio INNER JOIN FARMS.dbo.Room ON (Folio.RoomID = Room.RoomID);');

		SELECT @RoomTypeID = RoomTypeID FROM @Query WHERE FolioID = @FolioID;

		RETURN @RoomTypeID;
	END
GO