--Creation Script for FARMS_HORSE
--Created by:
--Natalie Mueller
--Marcell Romero
--10/30/2022

------------------------
-- Create database FARMS
------------------------

USE master;

GO

DROP DATABASE IF EXISTS FARMS;

GO

CREATE DATABASE FARMS
ON PRIMARY 
(
	NAME = 'FARMS',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\FARMS.mdf' ,
	SIZE = 4MB,
	FILEGROWTH = 500KB,
	MAXSIZE = 4MB
)
 LOG ON 
(
	NAME = 'FARMS_log',
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\FARMS_log.ldf' ,
	SIZE = 2MB,
	FILEGROWTH = 250KB,
	MAXSIZE = 2MB
);

GO


-------------------------------------------
-- Create tables with the specified columns
-------------------------------------------

USE FARMS;

CREATE TABLE Hotel
(
	HotelID					SMALLINT		NOT NULL, --HotelID is not an IDENTITY
	HotelName				VARCHAR(30)		NOT NULL,
	HotelAddress			VARCHAR(30)		NOT NULL,
	HotelCity				VARCHAR(20)		NOT NULL,
	HotelState				CHAR(2)			NULL,
	HotelCountry			VARCHAR(20)		NOT NULL,
	HotelPostalCode			CHAR(10)		NOT NULL,
	HotelStarRating			CHAR(1)			NULL,
	HotelPictureLink		VARCHAR(100)	NULL,
	TaxLocationID			SMALLINT		NOT NULL
);

CREATE TABLE Room
(
	RoomID					SMALLINT		NOT NULL	IDENTITY(1,1),
	RoomNumber				VARCHAR(5)		NOT NULL,
	RoomDescription			VARCHAR(200)	NOT NULL,
	RoomSmoking				BIT				NOT NULL,
	RoomBedConfiguration	CHAR(2)			NOT NULL,
	HotelID					SMALLINT		NOT NULL,
	RoomTypeID				SMALLINT		NOT NULL
);

CREATE TABLE RoomType
(
	RoomTypeID				SMALLINT		NOT NULL	IDENTITY(1,1),
	RTDescription			VARCHAR(200)	NOT NULL
);

CREATE TABLE RackRate
(
	RackRateID				SMALLINT		NOT NULL	IDENTITY(1,1),
	RoomTypeID				SMALLINT		NOT NULL,
	HotelID					SMALLINT		NOT NULL,
	RackRate				SMALLMONEY		NOT NULL,
	RackRateBegin			DATE			NOT NULL,
	RackRateEnd				DATE			NOT NULL,
	RackRateDescription		VARCHAR(200)	NOT NULL
);

CREATE TABLE Guest
(
	GuestID					SMALLINT		NOT NULL	IDENTITY(1500,1),
	GuestFirst				VARCHAR(20)		NOT NULL,
	GuestLast				VARCHAR(20)		NOT NULL,
	GuestAddress1			VARCHAR(30)		NOT NULL,
	GuestAddress2			VARCHAR(10)		NULL,
	GuestCity				VARCHAR(20)		NOT NULL,
	GuestState				CHAR(2)			NULL,
	GuestPostalCode			CHAR(10)		NOT NULL,
	GuestCountry			VARCHAR(20)		NOT NULL,
	GuestPhone				VARCHAR(20)		NOT NULL,
	GuestEmail				VARCHAR(30)		NULL,
	GuestComments			VARCHAR(200)	NULL
);

CREATE TABLE CreditCard
(
	CreditCardID			SMALLINT		NOT NULL	IDENTITY(1,1),
	GuestID					SMALLINT		NOT NULL,
	CCType					VARCHAR(5)		NOT NULL,
	CCNumber				VARCHAR(16)		NOT NULL,
	CCCompany				VARCHAR(40)		NULL,
	CCCardHolder			VARCHAR(40)		NOT NULL,
	CCExpiration			SMALLDATETIME	NOT NULL
);

CREATE TABLE Reservation
(
	ReservationID			SMALLINT		NOT NULL	IDENTITY(5000,1),
	ReservationDate			DATE			NOT NULL,
	ReservationStatus		CHAR(1)			NOT NULL,
	ReservationComments		VARCHAR(200)	NULL,
	CreditCardID			SMALLINT		NOT NULL
);

CREATE TABLE Folio
(
	FolioID					SMALLINT		NOT NULL	IDENTITY(1,1),
	ReservationID			SMALLINT		NOT NULL,
	GuestID					SMALLINT		NOT NULL,
	RoomID					SMALLINT		NOT NULL,
	QuotedRate				SMALLMONEY		NOT NULL,
	CheckinDate				SMALLDATETIME	NOT NULL,
	Nights					TINYINT			NOT NULL,
	Status					CHAR(1)			NOT NULL,
	Comments				VARCHAR(200)	NULL,
	DiscountID				SMALLINT		NOT NULL,
);

CREATE TABLE Discount
(
	DiscountID				SMALLINT		NOT NULL	IDENTITY(1,1),
	DiscountDescription		VARCHAR(50)		NOT NULL,
	DiscountExpiration		DATE			NOT NULL,
	DiscountRules			VARCHAR(100)	NULL,
	DiscountPercent			DECIMAL(4,2)	NULL,
	DiscountAmount			SMALLMONEY		NULL
);

CREATE TABLE Billing
(
	FolioBillingID			SMALLINT		NOT NULL	IDENTITY(1,1),
	FolioID					SMALLINT		NOT NULL,
	BillingCategoryID		SMALLINT		NOT NULL,
	BillingDescription		CHAR(30)		NOT NULL,
	BillingAmount			SMALLMONEY		NOT NULL,
	BillingItemQty			TINYINT			NOT NULL,
	BillingItemDate			DATE			NOT NULL
);

CREATE TABLE Payment
(
	PaymentID				SMALLINT		NOT NULL	IDENTITY(8000,1),
	FolioID					SMALLINT		NOT NULL,
	PaymentDate				DATE			NOT NULL,
	PaymentAmount			SMALLMONEY		NOT NULL,
	PaymentComments			VARCHAR(200)	NULL
);

CREATE TABLE BillingCategory
(
	BillingCategoryID		SMALLINT		NOT NULL	IDENTITY(1,1),
	BillingCatDescription	VARCHAR(30)		NOT NULL,
	BillingCatTaxable		BIT				NOT NULL
);

CREATE TABLE TaxRate
(
	TaxLocationID			SMALLINT		NOT NULL	IDENTITY(1,1),
	TaxDescription			VARCHAR(30)		NOT NULL,
	RoomTaxRate				DECIMAL(6,4)	NOT NULL,
	SalesTaxRate			DECIMAL(6,4)	NOT NULL
);

GO


--------------------------------------
-- Add primary/foreign key constraints
--------------------------------------

ALTER TABLE TaxRate
	ADD CONSTRAINT PK_TaxLocationID
	PRIMARY KEY (TaxLocationID);

ALTER TABLE Hotel
	ADD CONSTRAINT PK_HotelID
	PRIMARY KEY (HotelID),
	
	CONSTRAINT FK_Hotel_TaxLocationID
	FOREIGN KEY (TaxLocationID) REFERENCES TaxRate (TaxLocationID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE RoomType
	ADD CONSTRAINT PK_RoomTypeID
	PRIMARY KEY (RoomTypeID);

ALTER TABLE Room
	ADD CONSTRAINT PK_RoomID
	PRIMARY KEY (RoomID),
	
	CONSTRAINT FK_Room_HotelID
	FOREIGN KEY (HotelID) REFERENCES Hotel (HotelID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT FK_Room_RoomTypeID
	FOREIGN KEY (RoomTypeID) REFERENCES RoomType (RoomTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE RackRate
	ADD CONSTRAINT PK_RackRateID
	PRIMARY KEY (RackRateID),
	
	CONSTRAINT FK_RackRate_HotelID
	FOREIGN KEY (HotelID) REFERENCES Hotel (HotelID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT FK_RackRate_RoomTypeID
	FOREIGN KEY (RoomTypeID) REFERENCES RoomType (RoomTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Guest
	ADD CONSTRAINT PK_GuestID
	PRIMARY KEY (GuestID);

ALTER TABLE CreditCard
	ADD CONSTRAINT PK_CreditCardID
	PRIMARY KEY (CreditCardID),
	
	CONSTRAINT FK_CreditCard_GuestID
	FOREIGN KEY (GuestID) REFERENCES Guest (GuestID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Reservation
	ADD CONSTRAINT PK_ReservationID
	PRIMARY KEY (ReservationID),
	
	CONSTRAINT FK_Reservation_CreditCardID
	FOREIGN KEY (CreditCardID) REFERENCES CreditCard (CreditCardID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Discount
	ADD CONSTRAINT PK_DiscountID
	PRIMARY KEY (DiscountID);

ALTER TABLE Folio
	ADD CONSTRAINT PK_FolioID
	PRIMARY KEY (FolioID),
	
	CONSTRAINT FK_Folio_ReservationID
	FOREIGN KEY (ReservationID) REFERENCES Reservation (ReservationID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT FK_Folio_RoomID
	FOREIGN KEY (RoomID) REFERENCES Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT FK_Folio_DiscountID
	FOREIGN KEY (DiscountID) REFERENCES Discount (DiscountID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE BillingCategory
	ADD CONSTRAINT PK_BillingCategoryID
	PRIMARY KEY (BillingCategoryID);

ALTER TABLE Billing
	ADD CONSTRAINT PK_FolioBillingID
	PRIMARY KEY (FolioBillingID),
	
	CONSTRAINT FK_Billing_FolioID
	FOREIGN KEY (FolioID) REFERENCES Folio (FolioID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	
	CONSTRAINT FK_Billing_BillingCategoryID
	FOREIGN KEY (BillingCategoryID) REFERENCES BillingCategory (BillingCategoryID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Payment
	ADD CONSTRAINT PK_PaymentID
	PRIMARY KEY (PaymentID),
	
	CONSTRAINT FK_Payment_FolioID
	FOREIGN KEY (FolioID) REFERENCES Folio (FolioID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;


-------------------------------------------
-- Add check constraints and default values
-------------------------------------------

ALTER TABLE Room
	ADD
	CONSTRAINT CHK_RoomBedConfiguration
	CHECK (RoomBedConfiguration IN ('K', 'Q', 'F', '2Q', '2K', '2F'));

ALTER TABLE Reservation
	ADD
	CONSTRAINT CHK_ReservationStatus
	CHECK (ReservationStatus IN ('R', 'A', 'C', 'X'));

ALTER TABLE Folio
	ADD
	CONSTRAINT CHK_Status
	CHECK (Status IN ('R', 'A', 'C', 'X'));

ALTER TABLE Folio
	ADD
	CONSTRAINT CHK_DiscountID
	DEFAULT '1' FOR DiscountID;

GO


---------------------------------------
-- Bulk insert data from external files
---------------------------------------

BULK INSERT TaxRate FROM 'C:\Stage\TaxRate.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT RoomType FROM 'C:\Stage\RoomType.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Discount FROM 'C:\Stage\Discount.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT BillingCategory FROM 'C:\Stage\BillingCategory.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Guest FROM 'C:\Stage\Guest.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Hotel FROM 'C:\Stage\Hotel.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Room FROM 'C:\Stage\Room.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT RackRate FROM 'C:\Stage\RackRate.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT CreditCard FROM 'C:\Stage\CreditCard.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Reservation FROM 'C:\Stage\Reservation.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Folio FROM 'C:\Stage\Folio.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Payment FROM 'C:\Stage\Payment.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Billing FROM 'C:\Stage\Billing.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);

GO


------------------------------
-- Create database FARMS_HORSE
------------------------------

--Check to see if the database already exists and delete if it does
USE master;
GO

DROP DATABASE IF EXISTS FARMS_HORSE;
GO

--Creates the FARMS_HORSE database with specifications
CREATE DATABASE FARMS_HORSE

ON PRIMARY

(
NAME = 'FARMS_HORSE',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\FARMS_HORSE.mdf',
SIZE = 4MB, 
MAXSIZE = 4MB,
FILEGROWTH = 12%
)

--Creates the loggings with specifications
LOG ON

(
NAME = 'FARMS_HORSE_Log',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\FARMS_HORSE.ldf',
SIZE = 4MB,
MAXSIZE = 4MB,
FILEGROWTH = 12%
);

GO

--Switching to FARMS_HORSE database to add the tables
USE FARMS_HORSE;
GO

--Creates the Employee Table
CREATE TABLE Employee
(
	EmployeeID				smallint			NOT NULL		IDENTITY(3000,1),
	PositionID				smallint			NOT NULL,
	HotelID					smallint			NOT NULL,
	EmployeeFirstName		varchar(32)			NOT NULL,
	EmployeeLastName		varchar(32)			NOT NULL,
	EmployeeAddress1		varchar(128)		NOT NULL,
	EmployeeAddress2		varchar(32)			NULL,
	EmployeeCity			varchar(32)			NOT NULL,
	EmployeeState			char(2)				NOT NULL,
	EmployeeZipCode			varchar(10)			NOT NULL
);

--Creates the Position Table
CREATE TABLE Position
(
	PositionID				smallint			NOT NULL		IDENTITY(1,1),
	PositionName			varchar(32)			NOT NULL,
	PositionDescription		varchar(128)		NULL
);

--Creates the EmployeeShift Table
CREATE TABLE EmployeeWeeklyShift
(
	EmployeeWeeklyShiftID			smallint			NOT NULL		IDENTITY(1,1),
	EmployeeID				smallint			NOT NULL,
	DayOfWeek				tinyint				NOT NULL,
	ShiftStart				time				NOT NULL,
	ShiftEnd				time				NOT NULL,
	ShiftStatus				char(1)				NOT NULL
);

--Creates the HousekeepingReport Table
CREATE TABLE Housekeeping
(
	HousekeepingID			smallint			NOT NULL		IDENTITY(1,1),
	EmployeeID				smallint			NOT NULL,
	HousekeepingRoomID		smallint			NOT NULL,
	FolioID					smallint			NOT NULL,
	HousekeepingStatus		char(1)				NOT NULL,
	TimeCompleted			smalldatetime		NULL
);

--Creates the Room Table
CREATE TABLE HousekeepingRoom
(
	HousekeepingRoomID		smallint			NOT NULL		IDENTITY(1,1),
	RoomID					smallint			NOT NULL,
	HousekeepingRoomTypeID	smallint			NOT NULL,
	RoomStatus				char(1)				NOT NULL
);

--Creates the Repair Table
CREATE TABLE Repair
(
	RepairID				smallint			NOT NULL		IDENTITY(1,1),
	EmployeeID				smallint			NOT NULL,
	HousekeepingRoomID		smallint			NOT NULL,
	FolioID					smallint			NOT NULL,
	RepairTypeID			smallint			NOT NULL,
	RepairStatus			char(1)				NOT NULL,
	TimeCompleted			smalldatetime		NULL,
	RepairNotes				varchar(128)		NULL
);

--Creates the HousekeepingRoomType Table
CREATE TABLE HousekeepingRoomType
(
	HousekeepingRoomTypeID	smallint			NOT NULL		IDENTITY(1,1),
	RoomTypeID				smallint			NOT NULL,
	EstimatedCleanTime		tinyint				NOT NULL
);

--Creates the HousekeepingService Table
CREATE TABLE HousekeepingService
(
	HousekeepingServiceID	smallint			NOT NULL		IDENTITY(1,1),
	HousekeepingID			smallint			NOT NULL,
	ServiceTypeID			smallint			NOT NULL,
	ServiceStatus			char(1)				NOT NULL,
	ServiceNotes			varchar(128)		NULL
)

--Creates the ServiceType Table
CREATE TABLE ServiceType
(
	ServiceTypeID			smallint			NOT NULL		IDENTITY(1,1),
	ServiceName				varchar(128)		NOT NULL,
	ServiceCost				smallmoney			NOT NULL,
	ServiceDescription		varchar(256)		NULL,
	IsDefaultService		bit					NOT NULL
);

--Creates the DefaultServiceType table
CREATE TABLE DefaultServiceType
(
	DefaultServiceTypeID	smallint			NOT NULL		IDENTITY(1,1),
	ServiceTypeID			smallint			NOT NULL,
	HousekeepingRoomTypeID	smallint			NOT NULL
);

--Creates the RepairType Table
CREATE TABLE RepairType
(
	RepairTypeID			smallint			NOT NULL		IDENTITY(1,1),
	RepairName				varchar(128)			NOT NULL,
	RepairCost				smallmoney			NOT NULL,
	RepairDescription		varchar(256)		NULL,
	EstimatedRepairTime		smallint			NOT NULL
);

GO

--Altering the tables to add Primary Keys
ALTER TABLE Employee
	ADD CONSTRAINT PK_Employee
	PRIMARY KEY (EmployeeID);

ALTER TABLE Position
	ADD CONSTRAINT PK_Position
	PRIMARY KEY (PositionID);

ALTER TABLE EmployeeWeeklyShift
	ADD CONSTRAINT PK_EmployeeWeeklyShift
	PRIMARY KEY (EmployeeWeeklyShiftID)

ALTER TABLE Housekeeping
	ADD CONSTRAINT PK_Housekeeping
	PRIMARY KEY (HousekeepingID)

ALTER TABLE HousekeepingRoom
	ADD CONSTRAINT PK_HousekeepingRoom
	PRIMARY KEY (HousekeepingRoomID)

ALTER TABLE Repair
	ADD CONSTRAINT PK_Repair
	PRIMARY KEY (RepairID)

ALTER TABLE HousekeepingRoomType
	ADD CONSTRAINT PK_HousekeepingRoomType
	PRIMARY KEY (HousekeepingRoomTypeID)

ALTER TABLE HousekeepingService
	ADD CONSTRAINT PK_HousekeepingService
	PRIMARY KEY (HousekeepingServiceID)

ALTER TABLE ServiceType
	ADD CONSTRAINT PK_ServiceType
	PRIMARY KEY (ServiceTypeID)

ALTER TABLE RepairType
	ADD CONSTRAINT PK_RepairType
	PRIMARY KEY (RepairTypeID)

GO

--Altering the tables to add Foreign Keys
ALTER TABLE Employee
	ADD 
	
	CONSTRAINT FK_Employee_PositionID
	FOREIGN KEY (PositionID) REFERENCES Position (PositionID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE EmployeeWeeklyShift
	ADD CONSTRAINT FK_EmployeeWeeklyShift_EmployeeID
	FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Housekeeping
	ADD 
	
	CONSTRAINT FK_Housekeeping_EmployeeID
	FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_Housekeeping_HousekeepingRoomID
	FOREIGN KEY (HousekeepingRoomID) REFERENCES HousekeepingRoom (HousekeepingRoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingRoom
	ADD

	CONSTRAINT FK_HousekeepingRoom_HousekeepingRoomTypeID
	FOREIGN KEY (HousekeepingRoomTypeID) REFERENCES HousekeepingRoomType (HousekeepingRoomTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Repair
	ADD

	CONSTRAINT FK_Repair_EmployeeID
	FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_Repair_HousekeepingRoomID
	FOREIGN KEY (HousekeepingRoomID) REFERENCES HousekeepingRoom (HousekeepingRoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_Repair_RepairTypeID
	FOREIGN KEY (RepairTypeID) REFERENCES RepairType (RepairTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingService
	ADD 
	
	CONSTRAINT FK_HousekeepingService_HousekeepingID
	FOREIGN KEY (HousekeepingID) REFERENCES Housekeeping (HousekeepingID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_HousekeepingService_ServiceTypeID
	FOREIGN KEY (ServiceTypeID) REFERENCES ServiceType (ServiceTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

GO

--Adding Constraints for the tables
ALTER TABLE EmployeeWeeklyShift
	ADD
	
	CONSTRAINT CK_EmployeeWeeklyShift_ShiftStatus
	CHECK (ShiftStatus IN ('S', 'C')),

	CONSTRAINT DK_EmployeeWeeklyShift_ShiftStatus
	DEFAULT 'S' FOR ShiftStatus;

ALTER TABLE HousekeepingRoom
	ADD
	
	CONSTRAINT CK_HousekeepingRoom_RoomStatus
	CHECK (RoomStatus IN ('A', 'R')),

	CONSTRAINT DK_HousekeepingRoom_RoomStatus
	DEFAULT 'A' FOR RoomStatus;

ALTER TABLE Housekeeping
	ADD
	
	CONSTRAINT CK_Housekeeping_HousekeepingStatus
	CHECK (HousekeepingStatus IN ('P', 'C', 'R', 'X')),

	CONSTRAINT DK_Housekeeping_HousekeepingStatus
	DEFAULT 'P' FOR HousekeepingStatus;

ALTER TABLE HousekeepingService
	ADD
	
	CONSTRAINT CK_HousekeepingService_ServiceStatus
	CHECK (ServiceStatus IN ('C', 'R', 'X')),

	CONSTRAINT DK_HousekeepingService_ServiceStatus
	DEFAULT 'C' FOR ServiceStatus;

ALTER TABLE Repair
	ADD
	
	CONSTRAINT CK_Repair_RepairStatus
	CHECK (RepairStatus IN ('P', 'C', 'X')),

	CONSTRAINT DK_Repair_RepairStatus
	DEFAULT 'P' FOR RepairStatus;



GO

--Adding Data for the Database with Bulk Insert
BULK INSERT Position FROM 'C:\Stage\Horse\Position.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Employee FROM 'C:\Stage\Horse\Employee.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT EmployeeWeeklyShift FROM 'C:\Stage\Horse\EmployeeWeeklyShift.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT HousekeepingRoomType FROM 'C:\Stage\Horse\HousekeepingRoomType.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT HousekeepingRoom FROM 'C:\Stage\Horse\HousekeepingRoom.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT ServiceType FROM 'C:\Stage\Horse\ServiceType.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT RepairType FROM 'C:\Stage\Horse\RepairType.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT DefaultServiceType FROM 'C:\Stage\Horse\DefaultServiceType.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Housekeeping FROM 'C:\Stage\Horse\Housekeeping.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);

GO


------------------------------------
-- Test cross-database functionality
------------------------------------
USE FARMS_HORSE;
GO

SELECT *
FROM OPENQUERY (LOCALSERVER, 'Select * FROM FARMS.dbo.Guest') AS FARMS_Guest;


---------------------------------------------------------------------------------------------
--                                        FUNCTIONS                                        --
---------------------------------------------------------------------------------------------

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

-- TEST
SELECT dbo.fn_GetAvailableEmployee(2100, 1, GETDATE(), 30); -- 3008 on friday
SELECT dbo.fn_GetAvailableEmployee(2200, 2, GETDATE(), 30); -- null on friday


------------------------------------
-- fn_GetDefaultHousekeepingServices
------------------------------------

--Gets a table with the default Housekeeping Services for a given RoomTypeID.


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

-- TEST
SELECT dbo.fn_GetFolioRoomType(1); -- 8
SELECT dbo.fn_GetFolioRoomType(2); -- 2
SELECT dbo.fn_GetFolioRoomType(3); -- 2


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

-- TEST
SELECT dbo.fn_GetAvailableRoom(5); -- 3

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
	EmployeeFirstName			VARCHAR(32),
	EmployeeLastName			VARCHAR(32),
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
		SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ' ', ' ', ' ', ' ', ' ', ' ', ' '
		FROM Employee
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

-- TEST
SELECT * FROM dbo.fn_GetEmployeeWeeklySchedule(2100)
ORDER BY EmployeeLastName;

SELECT * FROM dbo.fn_GetEmployeeWeeklySchedule(2200)
ORDER BY EmployeeLastName;

SELECT * FROM dbo.fn_GetEmployeeWeeklySchedule(2300)
ORDER BY EmployeeLastName;


---------------------------------------------------------------------------------------------
--                                    STORED PROCEDURES                                    --
---------------------------------------------------------------------------------------------

--------------------------------
-- sp_InsertHousekeepingServices
--------------------------------

--Inserts default housekeeping services for a housekeeping record based on the room type.


--------------------------
-- sp_InsertBillingCharges
--------------------------

--If a housekeeping service or repair has an additional charge, insert a new row into Billing 
--under the given FolioID for that cost.


-----------------------
-- sp_GetWeeklySchedule
-----------------------

--Generates a report that shows employee schedules for the specified HotelID and date.


---------------------------------------------------------------------------------------------
--                                        TRIGGERS                                         --
---------------------------------------------------------------------------------------------

------------------------
-- tr_InsertHousekeeping
------------------------

--Inserts a row into Housekeeping when a Folio's status changes to 'C'.


-------------------------------
-- tr_CheckHousekeepingEmployee
-------------------------------

--Checks to see if the given EmployeeID is a Housekeeper. Rejects the change if the
--EmployeePositionID doesn't match.


-------------------------
-- tr_CheckRepairEmployee
-------------------------

--Checks to see if the given EmployeeID is a Repairperson. Rejects the change if the 
--EmployeePositionID doesn't match.


----------------------------
-- tr_UpdateRoomAvailability
----------------------------

--Checks to see if a room has any outstanding repairs, and if not, sets the room as available 
--for reservations.


------------------------------
-- tr_CheckHousekeepingCharges
------------------------------

--When housekeeping is completed, checks to see if any housekeeping services have an extra 
--charge, and calls sp_InsertBillingCharges if so.


------------------------
-- tr_CheckRepairCharges
------------------------

--When repairs are completed, checks to see if they have an extra charge, and calls 
--sp_InsertBillingCharges if so.


---------------------------
-- tr_CheckRoomAvailability
---------------------------

--When a new reservation is created, checks to see if the specified RoomID is available. If 
--it's not, shows an error that the specified room is not available for reservations.


---------------------------
-- tr_CheckRoomReservations
---------------------------

--When a RoomStatus is set to 'R', checks to see if there are any upcoming Folios for that 
--room during the repair duration, and if so calls fn_GetAvailableRoom to assign a new RoomID.

