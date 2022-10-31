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

--Creates the Service Table
CREATE TABLE Service
(
	ServiceID				smallint			NOT NULL		IDENTITY(1,1),
	ServiceType				smallint			NOT NULL,
	ServiceCost				smallint			NOT NULL,
	ServiceDescription		varchar(128)		NULL
);

--Creates the EmployeeShift Table
CREATE TABLE EmployeeShift
(
	EmployeeShiftID			smallint			NOT NULL		IDENTITY(1,1),
	EmployeeID				smallint			NOT NULL,
	ShiftStart				smalldatetime		NOT NULL,
	ShiftEnd				smalldatetime		NOT NULL,
	ShiftStatus				char(1)				NOT NULL
);

--Creates the Repair Table
CREATE TABLE Repair
(
	RepairID				smallint			NOT NULL		IDENTITY(1,1),
	RepairType				smallint			NOT NULL,
	RepairCost				smallint			NOT NULL,
	RepairDescription		varchar(128)		NULL,
	EstimatedRepairTime		smallint			NOT NULL
);

--Creates the HousekeepingDetail Table
CREATE TABLE HousekeepingDetail
(
	HousekeepingDetailID	smallint			NOT NULL		IDENTITY(1,1),
	HousekeepingReportID	smallint			NOT NULL,
	ServiceID				smallint			NOT NULL,
	ServiceStatus			char(1)				NOT NULL,
	ServiceNotes			varchar(128)		NULL
);

--Creates the HousekeepingReport Table
CREATE TABLE HousekeepingReport
(
	HousekeepingReportID	smallint			NOT NULL		IDENTITY(1,1),
	EmployeeShiftID			smallint			NOT NULL,
	RoomID					smallint			NOT NULL,
	ReportStatus			char(1)				NOT NULL,
	TimeCompleted			smalldatetime		NOT NULL
);

--Creates the RepairReport Table
CREATE TABLE RepairReport
(
	RepairReportID			smallint			NOT NULL		IDENTITY(1,1),
	EmployeeShiftID			smallint			NOT NULL,
	RoomID					smallint			NOT NULL,
	RepairID				smallint			NOT NULL,
	RepairStatus			char(1)				NOT NULL,
	TimeCompleted			smalldatetime		NOT NULL,
	RepairNotes				varchar(128)		NULL
);

--Creates the HousekeepingQueue Table
CREATE TABLE HousekeepingQueue
(
	HousekeepingQueueID		smallint			NOT NULL		IDENTITY(1,1),
	RoomID					smallint			NOT NULL,
	ServicePriority			tinyint				NOT NULL
);

--Creates the Room Table
CREATE TABLE Room
(
	RoomID					smallint			NOT NULL,
	RoomStatus				char(1)				NOT NULL,
	EstimatedCleanTime		smallint			NOT NULL
);

--Creates the FARMS_Room Table
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

--Creates the RepairQueue Table
CREATE TABLE RepairQueue
(
	RepairQueueID			smallint			NOT NULL		IDENTITY(1,1),
	RoomID					smallint			NOT NULL,
	RepairID				smallint			NOT NULL,
	RepairPriority			tinyint				NOT NULL
);

GO

--Altering the tables to add Primary Keys
ALTER TABLE Employee
	ADD CONSTRAINT PK_Employee
	PRIMARY KEY (EmployeeID);

ALTER TABLE Position
	ADD CONSTRAINT PK_Position
	PRIMARY KEY (PositionID);

ALTER TABLE Service
	ADD CONSTRAINT PK_Service
	PRIMARY KEY (ServiceID);

ALTER TABLE EmployeeShift
	ADD CONSTRAINT PK_EmployeeShift
	PRIMARY KEY (EmployeeShiftID);

ALTER TABLE Repair
	ADD CONSTRAINT PK_Repair
	PRIMARY KEY (RepairID);

ALTER TABLE HousekeepingDetail
	ADD CONSTRAINT PK_HousekeepingDetail
	PRIMARY KEY (HousekeepingDetailID);

ALTER TABLE HousekeepingReport
	ADD CONSTRAINT PK_HousekeepingReport
	PRIMARY KEY (HousekeepingReportID)

ALTER TABLE RepairReport
	ADD CONSTRAINT PK_RepairReport
	PRIMARY KEY (RepairReportID);

ALTER TABLE HousekeepingQueue
	ADD CONSTRAINT PK_HousekeepingQueue
	PRIMARY KEY (HousekeepingQueueID);

ALTER TABLE Room
	ADD CONSTRAINT PK_Room
	PRIMARY KEY (RoomID);

ALTER TABLE FARMS_Room
	ADD CONSTRAINT PK_FARMS_Room
	PRIMARY KEY (RoomID);

ALTER TABLE RepairQueue
	ADD CONSTRAINT PK_RepairQueue
	PRIMARY KEY (RepairQueueID);

GO

--Altering the tables to add Foreign Keys
ALTER TABLE Employee
	ADD CONSTRAINT FK_Employee_PositionID
	FOREIGN KEY (PositionID) REFERENCES Position (PositionID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE EmployeeShift
	ADD CONSTRAINT FK_EmployeeShift_EmployeeID
	FOREIGN KEY (EmployeeID) REFERENCES Employee (EmployeeID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingDetail
	ADD

	CONSTRAINT FK_HousekeepingDetail_HousekeepingReportID
	FOREIGN KEY (HousekeepingReportID) REFERENCES HousekeepingReport (HousekeepingReportID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_HousekeepingDetail_ServiceID
	FOREIGN KEY (ServiceID) REFERENCES Service (ServiceID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingReport
	ADD 
	
	CONSTRAINT FK_HousekeepingReport_EmployeeShiftID
	FOREIGN KEY (EmployeeShiftID) REFERENCES EmployeeShift (EmployeeShiftID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_HousekeepingReport_RoomID
	FOREIGN KEY (RoomID) REFERENCES Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE RepairReport
	ADD

	CONSTRAINT FK_RepairReport_EmployeeShiftID
	FOREIGN KEY (EmployeeShiftID) REFERENCES EmployeeShift (EmployeeShiftID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_RepairReport_RoomID
	FOREIGN KEY (RoomID) REFERENCES Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_RepairReport_RepairID
	FOREIGN KEY (RepairID) REFERENCES Repair (RepairID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE HousekeepingQueue
	ADD CONSTRAINT FK_HousekeepingQueue_RoomID
	FOREIGN KEY (RoomID) REFERENCES Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE Room
	ADD CONSTRAINT FK_Room_FARMSRoomID
	FOREIGN KEY (RoomID) REFERENCES FARMS_Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

ALTER TABLE RepairQueue
	ADD

	CONSTRAINT FK_RepairQueue_RoomID
	FOREIGN KEY (RoomID) REFERENCES Room (RoomID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,

	CONSTRAINT FK_RepairQueue_RepairID
	FOREIGN KEY (RepairID) REFERENCES Repair (RepairID)
	ON UPDATE CASCADE
	ON DELETE CASCADE;

GO

--Adding Constraints for the tables
ALTER TABLE EmployeeShift
	ADD
	
	CONSTRAINT CK_EmployeeShift_ShiftStatus
	CHECK (ShiftStatus IN ('S', 'C')),

	CONSTRAINT DK_EmployeeShift_ShiftStatus
	DEFAULT 'S' FOR ShiftStatus;

ALTER TABLE HousekeepingDetail
	ADD
	
	CONSTRAINT CK_HousekeepingDetail_ServiceStatus
	CHECK (ServiceStatus IN ('C', 'R', 'X')),

	CONSTRAINT DK_HousekeepingDetail_ServiceStatus
	DEFAULT 'C' FOR ServiceStatus;

ALTER TABLE HousekeepingReport
	ADD
	
	CONSTRAINT CK_HousekeepingReport_ReportStatus
	CHECK (ReportStatus IN ('P', 'C', 'X')),

	CONSTRAINT DK_HousekeepingReport_ReportStatus
	DEFAULT 'P' FOR ReportStatus;

ALTER TABLE RepairReport
	ADD
	
	CONSTRAINT CK_RepairReport_RepairStatus
	CHECK (RepairStatus IN ('P', 'C', 'X')),

	CONSTRAINT DK_RepairReport_RepairStatus
	DEFAULT 'P' FOR RepairStatus;

ALTER TABLE Room
	ADD
	
	CONSTRAINT CK_Room_RoomStatus
	CHECK (RoomStatus IN ('A', 'R')),

	CONSTRAINT DK_Room_RoomStatus
	DEFAULT 'A' FOR RoomStatus;

GO

--Drops the database so it does not live on a local machine
USE master;

DROP DATABASE FARMS_HORSE;