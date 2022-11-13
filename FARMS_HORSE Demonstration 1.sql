-- This example demonstrates the functionality of:

-- sp_GetWeeklySchedule
-- fn_GetEmployeeWeeklySchedule

USE FARMS_HORSE;
GO


-- Show schedule generation using different hotels and dates

PRINT '';
PRINT 'Testing 2100, 2022/11/12';
PRINT '';
EXEC sp_GetWeeklySchedule
	@HotelID				= 2100, 
	@Date					= '2022/11/12';
PRINT '';

PRINT '';
PRINT 'Testing 2100, 2022/11/13';
PRINT '';
EXEC sp_GetWeeklySchedule
	@HotelID				= 2100, 
	@Date					= '2022/11/13';
PRINT '';

PRINT '';
PRINT 'Testing 2100, 2022/11/15';
PRINT '';
EXEC sp_GetWeeklySchedule
	@HotelID				= 2100, 
	@Date					= '2022/11/15';
PRINT '';

PRINT '';
PRINT 'Testing 2400, 2022/11/13';
PRINT '';
EXEC sp_GetWeeklySchedule
	@HotelID				= 2400, 
	@Date					= '2022/11/13';
PRINT '';
GO


-- END OF DEMONSTRATION --


-----------------------
-- sp_GetWeeklySchedule
-----------------------

--Generates a report that shows employee schedules for the specified HotelID and date.

GO
CREATE PROCEDURE sp_GetWeeklySchedule
(
	@HotelID					SMALLINT,
	@Date						SMALLDATETIME
)
AS
	DECLARE @Sunday					SMALLDATETIME;
	DECLARE @HotelName				VARCHAR(30);
	DECLARE @HotelAddress			VARCHAR(256);
	DECLARE @EmployeeName			VARCHAR(64);

	-- Set the schedule date to Sunday's date in the given week
	SET @Sunday = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @Date), @Date);
			
	SELECT	@HotelName				= HotelName,
			@HotelAddress			= HotelAddress
									+ CHAR(13) + CHAR(10) + HotelCity + ', ' + HotelState + ' ' + HotelPostalCode
									+ CHAR(13) + CHAR(10) +  HotelCountry
	FROM OPENQUERY (LOCALSERVER, 'Select * FROM FARMS.dbo.Hotel') AS FARMS_Hotel
	WHERE FARMS_Hotel.HotelID = @HotelID;

	-- Print the hotel information
	PRINT 'FARMS HORSE';
	PRINT '';

	PRINT 'Hotel #' + CAST(@HotelID AS VARCHAR(10));
	PRINT @HotelName;
	PRINT @HotelAddress;
	PRINT '';

	PRINT 'Weekly Housekeeping Schedule';
	PRINT FORMAT(@Sunday, 'MM/dd/yyyy');
	PRINT '';

	-- Print the names of the scheduled housekeepers
	DECLARE cursor_Housekeepers CURSOR
	FOR
		SELECT CONCAT(EmployeeLastName, ', ', EmployeeFirstName)
		FROM Employee
		WHERE PositionID = 1
		AND HotelID = @HotelID
		ORDER BY EmployeeLastName;

	OPEN cursor_Housekeepers;
	FETCH NEXT FROM cursor_Housekeepers INTO @EmployeeName;

	PRINT 'Scheduled Housekeepers';
	PRINT '----------------------';
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @EmployeeName;
			FETCH NEXT FROM cursor_Housekeepers INTO @EmployeeName;
		END

	CLOSE cursor_Housekeepers;
	DEALLOCATE cursor_Housekeepers;
	PRINT '';
	
	-- Print the names of the scheduled repairs
	DECLARE cursor_Repairs CURSOR
	FOR
		SELECT CONCAT(EmployeeLastName, ', ', EmployeeFirstName)
		FROM Employee
		WHERE PositionID = 2
		AND HotelID = @HotelID
		ORDER BY EmployeeLastName;

	OPEN cursor_Repairs;
	FETCH NEXT FROM cursor_Repairs INTO @EmployeeName;

	PRINT 'Scheduled Repairs';
	PRINT '-----------------';
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @EmployeeName;
			FETCH NEXT FROM cursor_Repairs INTO @EmployeeName;
		END

	CLOSE cursor_Repairs;
	DEALLOCATE cursor_Repairs;
	PRINT '';

	-- Print employee hourly schedule
	DECLARE @EmployeeID					SMALLINT;
	DECLARE @Position					VARCHAR(32);
	DECLARE @SundaySchedule				CHAR(19);
	DECLARE @MondaySchedule				CHAR(19);
	DECLARE @TuesdaySchedule			CHAR(19);
	DECLARE @WednesdaySchedule			CHAR(19);
	DECLARE @ThursdaySchedule			CHAR(19);
	DECLARE @FridaySchedule				CHAR(19);
	DECLARE @SaturdaySchedule			CHAR(19);

	DECLARE cursor_Schedule CURSOR
	FOR
		SELECT * FROM dbo.fn_GetEmployeeWeeklySchedule(@HotelID)
		ORDER BY EmployeeName;

	OPEN cursor_Schedule;
	FETCH NEXT FROM cursor_Schedule 
		INTO	@EmployeeID, 
				@Position, 
				@EmployeeName, 
				@SundaySchedule, 
				@MondaySchedule, 
				@TuesdaySchedule, 
				@WednesdaySchedule, 
				@ThursdaySchedule, 
				@FridaySchedule, 
				@SaturdaySchedule;

	PRINT CAST('Scheduled Hours' AS CHAR(44)) 
		
	PRINT CAST('ID' AS CHAR(7)) + CAST('Position' AS CHAR(14)) + CAST('Name' AS CHAR(23))
		+ CAST('Sunday' AS CHAR(22)) 
		+ CAST('Monday' AS CHAR(22))
		+ CAST('Tuesday' AS CHAR(22)) 
		+ CAST('Wednesday' AS CHAR(22)) 
		+ CAST('Thursday' AS CHAR(22)) 
		+ CAST('Friday' AS CHAR(22)) 
		+ CAST('Saturday' AS CHAR(22));
	PRINT '----   -----------   --------------------   '
		+ FORMAT(DATEADD(DAY, 0, @Sunday), 'MM/dd/yyyy') + '            '
		+ FORMAT(DATEADD(DAY, 1, @Sunday), 'MM/dd/yyyy') + '            '
		+ FORMAT(DATEADD(DAY, 2, @Sunday), 'MM/dd/yyyy') + '            '
		+ FORMAT(DATEADD(DAY, 3, @Sunday), 'MM/dd/yyyy') + '            '
		+ FORMAT(DATEADD(DAY, 4, @Sunday), 'MM/dd/yyyy') + '            '
		+ FORMAT(DATEADD(DAY, 5, @Sunday), 'MM/dd/yyyy') + '            '
		+ FORMAT(DATEADD(DAY, 6, @Sunday), 'MM/dd/yyyy') + '            ';
	WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT CAST(@EmployeeID AS CHAR(7))
				+ CAST(@Position AS CHAR(14))
				+ CAST(@EmployeeName AS CHAR(23))
				+ CAST(@SundaySchedule AS CHAR(22))
				+ CAST(@MondaySchedule AS CHAR(22))
				+ CAST(@TuesdaySchedule AS CHAR(22))
				+ CAST(@WednesdaySchedule AS CHAR(22))
				+ CAST(@ThursdaySchedule AS CHAR(22))
				+ CAST(@FridaySchedule AS CHAR(22))
				+ CAST(@SaturdaySchedule AS CHAR(22));
			
			FETCH NEXT FROM cursor_Schedule 
				INTO	@EmployeeID, 
						@Position, 
						@EmployeeName, 
						@SundaySchedule, 
						@MondaySchedule, 
						@TuesdaySchedule, 
						@WednesdaySchedule, 
						@ThursdaySchedule, 
						@FridaySchedule, 
						@SaturdaySchedule;
		END

	CLOSE cursor_Schedule;
	DEALLOCATE cursor_Schedule;
GO


-------------------------------
-- fn_GetEmployeeWeeklySchedule
-------------------------------

--Gets a table showing every employee's weekly schedule for the given date.

GO
CREATE FUNCTION fn_GetEmployeeWeeklySchedule
(
	@HotelID					SMALLINT
)
RETURNS @Schedule TABLE
(
	EmployeeID					SMALLINT,
	EmployeePosition			VARCHAR(11),
	EmployeeName				VARCHAR(25),
	SundaySchedule				CHAR(19),
	MondaySchedule				CHAR(19),
	TuesdaySchedule				CHAR(19),
	WednesdaySchedule			CHAR(19),
	ThursdaySchedule			CHAR(19),
	FridaySchedule				CHAR(19),
	SaturdaySchedule			CHAR(19)
)
AS
	BEGIN
		DECLARE @EmployeeID					SMALLINT;
		DECLARE @DayOfWeek					TINYINT;
		DECLARE @ShiftStart					TIME;
		DECLARE @ShiftEnd					TIME;

		INSERT INTO @Schedule
		SELECT EmployeeID, PositionName, CONCAT(EmployeeLastName, ', ', EmployeeFirstName), ' ', ' ', ' ', ' ', ' ', ' ', ' '
		FROM Employee
		INNER JOIN Position ON (Employee.PositionID = Position.PositionID)
		WHERE HotelID = @HotelID;

		-- Loop through the shifts of all the employees in the specified hotel
		DECLARE cursor_EmployeeWeeklyShift CURSOR
			FOR
				SELECT Employee.EmployeeID, DayOfWeek, ShiftStart, ShiftEnd
				FROM EmployeeWeeklyShift
				INNER JOIN Employee ON (EmployeeWeeklyShift.EmployeeID = Employee.EmployeeID)
				WHERE HotelID = @HotelID
				AND ShiftStatus = 'S'; -- Don't schedule employees on vacation

		OPEN cursor_EmployeeWeeklyShift;
		FETCH NEXT FROM cursor_EmployeeWeeklyShift INTO @EmployeeID, @DayOfWeek, @ShiftStart, @ShiftEnd;

		WHILE @@FETCH_STATUS = 0
			BEGIN
				UPDATE @Schedule SET
				SundaySchedule = CASE WHEN (@DayOfWeek = 1) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE SundaySchedule END,
				MondaySchedule = CASE WHEN (@DayOfWeek = 2) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE MondaySchedule END,
				TuesdaySchedule = CASE WHEN (@DayOfWeek = 3) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE TuesdaySchedule END,
				WednesdaySchedule = CASE WHEN (@DayOfWeek = 4) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE WednesdaySchedule END,
				ThursdaySchedule = CASE WHEN (@DayOfWeek = 5) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE ThursdaySchedule END,
				FridaySchedule = CASE WHEN (@DayOfWeek = 6) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE FridaySchedule END,
				SaturdaySchedule = CASE WHEN (@DayOfWeek = 7) THEN CONCAT(FORMAT(CAST(@ShiftStart AS DATETIME), 'hh:mm tt'), ' - ', FORMAT(CAST(@ShiftEnd AS DATETIME), 'hh:mm tt'))
					ELSE SaturdaySchedule END
				WHERE EmployeeID = @EmployeeID

				FETCH NEXT FROM cursor_EmployeeWeeklyShift INTO @EmployeeID, @DayOfWeek, @ShiftStart, @ShiftEnd;
			END
		CLOSE cursor_EmployeeWeeklyShift;
		DEALLOCATE cursor_EmployeeWeeklyShift;

		RETURN;
	END
GO