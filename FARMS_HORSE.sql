--Creation Script for FARMS_HORSE
--Created by:
--Natalie Mueller
--Marcell Romero
--10/30/2022

--Check to see if the database already exists and delete if it does
USE master;

IF EXISTS (SELECT * FROM sysdatabases WHERE name='FARMS_HORSE')
DROP DATABASE FARMS_HORSE;

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
	ServiceDescription		varchar(256)		NULL
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

--Create the FARMS Tables
CREATE TABLE FARMS_Room
(
	RoomID					smallint			NOT NULL		IDENTITY(1,1),
	RoomNumber				varchar(5)			NOT NULL,
	RoomDescription			varchar(200)		NOT NULL,
	RoomSmoking				bit					NOT NULL,
	RoomBedConfiguration	char(2)				NOT NULL,
	HotelID					smallint			NOT NULL,
	RoomTypeID				smallint			NOT NULL
);

CREATE TABLE FARMS_Hotel
(
	HotelID					smallint			NOT NULL,
	HotelName				varchar(30)			NOT NULL,
	HotelAddress			varchar(30)			NOT NULL,
	HotelCity				varchar(20)			NOT NULL,
	HotelState				char(2)				NULL,
	HotelCountry			varchar(20)			NOT NULL,
	HotelPostalCode			char(10)			NOT NULL,
	HotelStarRating			char(1)				NULL,
	HotelPictureLink		varchar(100)		NULL,
	TaxLocationID			smallint			NOT NULL
);

CREATE TABLE FARMS_Folio
(
	FolioID					smallint			NOT NULL		IDENTITY(1,1),
	ReservationID			smallint			NOT NULL,
	GuestID					smallint			NOT NULL,
	RoomID					smallint			NOT NULL,
	QuotedRate				smallmoney			NOT NULL,
	CheckinDate				smalldatetime		NOT NULL,
	Nights					tinyint				NOT NULL,
	Status					char(1)				NOT NULL,
	Comments				varchar(200)		NULL,
	DiscountID				smallint			NOT NULL
);

CREATE TABLE FARMS_RoomType
(
	RoomTypeID				smallint			NOT NULL		IDENTITY(1,1),
	RTDescription			varchar(200)		NOT NULL
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

--FARMS Priamry Keys
ALTER TABLE FARMS_Room
	ADD CONSTRAINT PK_Room
	PRIMARY KEY (RoomID)

ALTER TABLE FARMS_Hotel
	ADD CONSTRAINT PK_Hotel
	PRIMARY KEY (HotelID)

ALTER TABLE FARMS_Folio
	ADD CONSTRAINT PK_Folio
	PRIMARY KEY (FolioID)

ALTER TABLE FARMS_RoomType
	ADD CONSTRAINT PK_RoomType
	PRIMARY KEY (RoomTypeID)

GO

--Altering the tables to add Foreign Keys
ALTER TABLE Employee
	ADD 
	
	CONSTRAINT FK_Employee_PositionID
	FOREIGN KEY (PositionID) REFERENCES Position (PositionID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_Employee_HotelID
	FOREIGN KEY (HotelID) REFERENCES FARMS_Hotel (HotelID)
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
	ON DELETE CASCADE,

	CONSTRAINT FK_Housekeeping_FolioID
	FOREIGN KEY (FolioID) REFERENCES FARMS_Folio (FolioID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingRoom
	ADD

	CONSTRAINT FK_HousekeepingRoom_RoomID
	FOREIGN KEY (RoomID) REFERENCES FARMS_Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

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

	CONSTRAINT FK_Repair_FolioID
	FOREIGN KEY (FolioID) REFERENCES FARMS_Folio (FolioID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_Repair_RepairTypeID
	FOREIGN KEY (RepairTypeID) REFERENCES RepairType (RepairTypeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingRoomType
	ADD

	CONSTRAINT FK_HousekeepingRoomType_RoomTypeID
	FOREIGN KEY (RoomTypeID) REFERENCES FARMS_RoomType (RoomTypeID)
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

BULK INSERT FARMS_RoomType FROM 'C:\Stage\RoomType.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT FARMS_Hotel FROM 'C:\Stage\Hotel.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT FARMS_Room FROM 'C:\Stage\Room.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT FARMS_Folio FROM 'C:\Stage\Folio.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
BULK INSERT Employee FROM 'C:\Stage\Horse\Employee.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);

GO

--Adding Data for the Database with Regular Inserts
INSERT INTO Position(PositionName, PositionDescription)
VALUES
('Housekeeper', 'Cleans hotel rooms'),
('Repairs', 'Fixes problems with hotel rooms');

INSERT INTO HousekeepingRoomType (RoomTypeID, EstimatedCleanTime)
(SELECT DISTINCT RoomTypeID, 30 FROM FARMS_Room);

INSERT INTO HousekeepingRoom (RoomID, HousekeepingRoomTypeID, RoomStatus)
(SELECT RoomID, RoomTypeID, 'A' FROM FARMS_Room);

INSERT INTO ServiceType (ServiceName, ServiceCost, ServiceDescription)
VALUES
('Vacuum Carpets', 0, 'Vacuum the carpets'),
('Change and clean bedding', 0, 'Replace with clean bedding and wash used bedding'),
('Clean bathroom floor', 0, 'Clean/disinfect and dry floor'),
('Clean toilet', 0, 'Clean the bowl, top, and around'),
('Restock toiletries (complementary)', 0, 'Soap, shampoo, conditioner, body wash, and lotion'),
('Restock toiletries', 5, 'Soap, shampoo, conditioner, body wash, and lotion'),
('Clean shower/bath', 0, 'Scrub walls and floor'),
('Clean sink', 0, 'Clean in and around sink'),
('Change shower mat', 0, 'Replace with clean mat and wash used mat'),
('Replace damaged/missing shower mat', 15, 'Replace with clean mat if damaged or missing'),
('Clean mirror', 0, 'Wipe and don''t leave streaks'),
('Clean vents', 0, 'Wipe and disinfect'),
('Clean fridge', 0, 'Clean inside and outside and throw trash out'),
('Clean minibar', 0, 'Dispose of trash and wipe down'),
('Reset room temperature', 0, 'Temperature room comfortable upon arrival'),
('Check room HVAC', 0, 'All systems are in working comdition'),
('Room lock functional', 0, 'Locks and doesn''t stick'),
('Clean/test telephone', 0, 'Disinfect and test calling room service'),
('Clean/test TV', 0, 'Disinfect and test channels/volume/power'),
('Clean TV remote', 0, 'Disinfect and test channels/volume/power, check batteries'),
('Electrical outlets functional', 0, 'Test ALL outlets'),
('Clean windows', 0, 'Clean and don''t leave streaks'),
('Clean outdoor furniture', 0, 'Spray and wipe off'),
('Clean curtains', 0, 'Clean stains, replace with clean curtains and wash if needed'),
('Replace damaged/missing clothes hangers', 15, 'Ensure each room has at least 3 hangers'),
('Replace damaged/missing hair dryer', 40.50, 'Check functionality before replacing'),
('Replace damaged/missing TV remote', 35, 'Check functionality before replacing'),
('Restock minibar water (complementary)', 0, 'Restock 4 water bottles'),
('Restock minibar water', 10, 'Restock 4 water bottles'),
('Restock minibar wine (complementary)', 0, 'Restock 1 wine bottle'),
('Restock minibar wine', 40, 'Restock 1 wine bottle'),
('Replace damaged/missing bedding', 55, 'Clean twice for stains before charging for replacement.'),
('Replace damaged/missing pillows', 20, 'Clean twice for stains before charging for replacement.'),
('Replace damaged/missing curtains', 100, 'Clean twice for stains before charging for replacement.');

INSERT INTO RepairType(RepairName, RepairCost, RepairDescription, EstimatedRepairTime)
VALUES
('Repair toilet flush valve', 30, 'Fix or replace flush valve', 15),
('Replace toilet', 150, 'Remove and replace whole toilet assembly', 120),
('Replace mirror', 60, 'Replace broken mirror', 15),
('Repair/replace showerhead', 30, 'Replace or repair showerhead', 15),
('Repair bathroom floor', 50, 'Repair damaged/broken floor tile', 120),
('Repair door lock', 0, 'Repair broken door lock', 30),
('Replace door', 80, 'Replace damaged front door', 60),
('Repair TV', 0, 'Repair TV electrical issue', 60),
('Replace TV', 200, 'Replace damaged TV', 15),
('Replace nightstand', 30, 'Damaged nightstand replacement', 60),
('Replace double bed', 100, 'Double size bed replacement', 30),
('Replace queen bed', 235, 'Queen size bed replacement', 30),
('Replace king bed', 375, 'King size bed replacement', 30),
('Repair wall damage', 40, 'Replace drywall and paint', 90);

BULK INSERT Housekeeping FROM 'C:\Stage\Horse\Housekeeping.txt' WITH (FIELDTERMINATOR = '|', FIRSTROW = 1);
