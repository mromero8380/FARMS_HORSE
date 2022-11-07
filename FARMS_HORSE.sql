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
	HousekeepingRoomID		smallint			NOT NULL,
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
	ServiceName				varchar(32)			NOT NULL,
	ServiceCost				smallmoney			NOT NULL,
	ServiceDescription		varchar(128)		NULL
);

--Creates the RepairType Table
CREATE TABLE RepairType
(
	RepairTypeID			smallint			NOT NULL		IDENTITY(1,1),
	RepairName				varchar(32)			NOT NULL,
	RepairCost				smallmoney			NOT NULL,
	RepairDescription		varchar(128)		NULL,
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

ALTER TABLE HousekeepingService
	ADD
	
	CONSTRAINT CK_HousekeepingService_ServiceStatus
	CHECK (ServiceStatus IN ('C', 'R', 'X')),

	CONSTRAINT DK_HousekeepingService_ServiceStatus
	DEFAULT 'C' FOR ServiceStatus;

ALTER TABLE Housekeeping
	ADD
	
	CONSTRAINT CK_Housekeeping_HousekeepingStatus
	CHECK (HousekeepingStatus IN ('P', 'C', 'X')),

	CONSTRAINT DK_Housekeeping_HousekeepingStatus
	DEFAULT 'P' FOR HousekeepingStatus;

ALTER TABLE Repair
	ADD
	
	CONSTRAINT CK_Repair_RepairStatus
	CHECK (RepairStatus IN ('P', 'C', 'X')),

	CONSTRAINT DK_Repair_RepairStatus
	DEFAULT 'P' FOR RepairStatus;

ALTER TABLE HousekeepingRoom
	ADD
	
	CONSTRAINT CK_HousekeepingRoom_RoomStatus
	CHECK (RoomStatus IN ('A', 'R')),

	CONSTRAINT DK_HousekeepingRoom_RoomStatus
	DEFAULT 'A' FOR RoomStatus;

GO

--Drops the database so it does not live on a local machine
USE master;

DROP DATABASE FARMS_HORSE;