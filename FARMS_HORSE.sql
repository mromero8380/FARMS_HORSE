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

--Creates the Room Table
CREATE TABLE Room
(
	RoomID					smallint			NOT NULL		IDENTITY(1,1),
	RoomStatus				char(1)				NOT NULL,
	EstimatedCleanTime		smallint			NOT NULL
);

--Creates the EmployeeShift Table
CREATE TABLE EmployeeShift
(
	EmployeeShiftID			smallint			NOT NULL		IDENTITY(1,1),
	EmployeeID				smallint			NOT NULL,
	ShiftStart				smalldatetime		NOT NULL,
	ShiftEnd				smalldatetime		NOT NULL,
	ShitStatus				char(1)				NOT NULL
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

--Creates the HousekeepingQueue Table
CREATE TABLE HousekeepingQueue
(
	HousekeepingQueueID		smallint			NOT NULL		IDENTITY(1,1),
	RoomID					smallint			NOT NULL,
	ServicePriority			tinyint				NOT NULL
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
	ReportDetailID			smallint			NOT NULL,
	RepairID				smallint			NOT NULL,
	RepairStatus			char(1)				NOT NULL,
	TimeCompleted			smalldatetime		NOT NULL,
	RepairNotes				varchar(128)		NULL
);

--Creates the RepairQueue Table
CREATE TABLE RepairQueue
(
	RepairQueueID			smallint			NOT NULL		IDENTITY(1,1),
	ReportDetailID			smallint			NOT NULL,
	RepairID				smallint			NOT NULL,
	RepairPriority			tinyint				NOT NULL
);

--Creates the Service Table
CREATE TABLE Service
(
	ServiceID				smallint			NOT NULL		IDENTITY(1,1),
	ServiceType				smallint			NOT NULL,
	ServiceCost				smallint			NOT NULL,
	ServiceDescription		varchar(128)		NULL
);

--Creates the ReportDetail Table
CREATE TABLE ReportDetail
(
	ReportDetailID			smallint			NOT NULL		IDENTITY(1,1),
	HousekeepingReportID	smallint			NOT NULL,
	ServiceID				smallint			NOT NULL,
	ServiceStatus			char(1)				NOT NULL,
	ServiceNotes			varchar(128)		NULL
);

--Creates the SupplyDetail Table
CREATE TABLE SupplyDetail
(
	SupplyDetailID			smallint			NOT NULL		IDENTITY(1,1),
	ReportDetailID			smallint			NULL,
	RepairDetailID			smallint			NULL,
	SupplyID				smallint			NOT NULL,
	QuantityUsed			tinyint				NOT NULL
);

--Creates the Supply
CREATE TABLE Supply
(
	SupplyID				smallint			NOT NULL		IDENTITY(1,1),
	SupplyName				varchar(32)			NOT NULL,
	SupplyDescription		varchar(128)		NULL
);

GO

--Altering the tables to add Primary Keys
ALTER TABLE Employee
	ADD CONSTRAINT PK_Employee
	PRIMARY KEY (EmployeeID);

ALTER TABLE Position
	ADD CONSTRAINT PK_Position
	PRIMARY KEY (PositionID);

ALTER TABLE Room
	ADD CONSTRAINT PK_Room
	PRIMARY KEY (RoomID);

ALTER TABLE EmployeeShift
	ADD CONSTRAINT PK_EmployeeShift
	PRIMARY KEY (EmployeeShiftID);

ALTER TABLE Repair
	ADD CONSTRAINT PK_Repair
	PRIMARY KEY (RepairID);

ALTER TABLE HousekeepingQueue
	ADD CONSTRAINT PK_HousekeepingQueue
	PRIMARY KEY (HousekeepingQueueID);

ALTER TABLE HousekeepingReport
	ADD CONSTRAINT PK_HousekeepingReport
	PRIMARY KEY (HousekeepingReportID)

ALTER TABLE RepairReport
	ADD CONSTRAINT PK_RepairReport
	PRIMARY KEY (RepairReportID);

ALTER TABLE RepairQueue
	ADD CONSTRAINT PK_RepairQueue
	PRIMARY KEY (RepairQueueID);

ALTER TABLE Service
	ADD CONSTRAINT PK_Service
	PRIMARY KEY (ServiceID);

ALTER TABLE ReportDetail
	ADD CONSTRAINT PK_ReportDetail
	PRIMARY KEY (ReportDetailID);

ALTER TABLE SupplyDetail
	ADD CONSTRAINT PK_SupplyDetail
	PRIMARY KEY(SupplyDetailID);

ALTER TABLE Supply
	ADD CONSTRAINT PK_Supply
	PRIMARY KEY(SupplyID);

GO

--Altering the tables to add Foreign Keys
