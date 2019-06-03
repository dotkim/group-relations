USE master;
PRINT 'Change DB to master';
GO

--Check if the database exists, if not then create it.
PRINT 'Checking DB';
IF NOT EXISTS (
  SELECT  database_id
  FROM    [master].[sys].[databases]
  WHERE   [name] = 'Relations'
) CREATE DATABASE Relations
GO

USE Relations;
GO

PRINT 'Dropping procedures';
--Drop Procedures-------------------------------  -----------------------------------------------
IF OBJECT_ID('ActiveDirectory.InsertUsers', 'P')  IS NOT NULL DROP PROCEDURE ActiveDirectory.InsertUsers;
IF OBJECT_ID('Auditing.ErrorLogging', 'P')	      IS NOT NULL DROP PROCEDURE Auditing.ErrorLogging;
IF OBJECT_ID('Auditing.ErrorHandling', 'P')       IS NOT NULL DROP PROCEDURE Auditing.ErrorHandling;
-------------------------------------------------------------------------------------------------
PRINT 'Dropping tables';
--Drop tables----------------------------------  ------------------------------------------------
IF OBJECT_ID('Auditing.CatchErrors', 'U')        IS NOT NULL DROP TABLE Auditing.CatchErrors;
IF OBJECT_ID('Link.ObjectRelations', 'U')        IS NOT NULL DROP TABLE Link.ObjectRelations;
IF OBJECT_ID('SubSystems.Objects', 'U')          IS NOT NULL DROP TABLE SubSystems.Objects;
IF OBJECT_ID('SubSystems.Sources', 'U')          IS NOT NULL DROP TABLE SubSystems.Sources;
IF OBJECT_ID('ActiveDirectory.GroupUsers', 'U')  IS NOT NULL DROP TABLE ActiveDirectory.GroupUsers;
IF OBJECT_ID('ActiveDirectory.Groups', 'U')      IS NOT NULL DROP TABLE ActiveDirectory.Groups;
IF OBJECT_ID('ActiveDirectory.Users', 'U')       IS NOT NULL DROP TABLE ActiveDirectory.Users;
-------------------------------------------------------------------------------------------------
PRINT 'Dropping schemas';
--Drop schemas------------------  -------------------------------------------
IF SCHEMA_ID('Auditing')          IS NOT NULL DROP SCHEMA Auditing;
IF SCHEMA_ID('Link')              IS NOT NULL DROP SCHEMA Link;
IF SCHEMA_ID('SubSystems')        IS NOT NULL DROP SCHEMA SubSystems;
IF SCHEMA_ID('ActiveDirectory')   IS NOT NULL DROP SCHEMA ActiveDirectory;
-------------------------------------------------------------------------------------------------
GO

--Begin creating db
CREATE SCHEMA ActiveDirectory;
GO

CREATE SCHEMA SubSystems;
GO

CREATE SCHEMA Link;
GO

CREATE SCHEMA Auditing;
GO

PRINT 'created schemas';

CREATE TABLE ActiveDirectory.Users(
  UserID    INT  IDENTITY(1,1),
  Username  NVARCHAR(100) NOT NULL,
  CONSTRAINT  PK_UserID
  PRIMARY KEY (UserID)
);
GO

CREATE TABLE ActiveDirectory.Groups(
  GroupID           INT IDENTITY(1,1),
  GroupName         NVARCHAR(200),
  CanonicalName     NVARCHAR(1000),
  DistinguishedName NVARCHAR(1000),
  CONSTRAINT  PK_GroupID
  PRIMARY KEY (GroupID)
);
GO

CREATE TABLE ActiveDirectory.GroupUsers(
  UserID  INT NOT NULL,
  GroupID INT NOT NULL,
  CONSTRAINT  PK_UserID_GroupID
  PRIMARY KEY (UserID, GroupID)
);
GO

CREATE TABLE SubSystems.Sources(
  SourceID    INT IDENTITY(1,1),
  SourceName  NVARCHAR(100),
  CONSTRAINT  PK_SourceID
  PRIMARY KEY (SourceID)
);

INSERT  SubSystems.Sources
VALUES  ('eadmin'), ('ace'), ('ivanti');
GO

CREATE TABLE SubSystems.Objects(
  ObjectID    INT IDENTITY(1,1),
  ObjectName  NVARCHAR(200),
  SourceID    INT NOT NULL,
  CONSTRAINT  PK_ObjectID
  PRIMARY KEY (ObjectID),
  CONSTRAINT  FK_SourceID_Sources
  FOREIGN KEY (SourceID)
  REFERENCES  SubSystems.Sources
);
GO

CREATE TABLE Link.ObjectRelations(
  ObjectID  INT NOT NULL,
  GroupID   INT NOT NULL,
  JsonData  NVARCHAR(2000),
  CONSTRAINT  PK_ObjectID_GroupID
  PRIMARY KEY (ObjectID, GroupID)
);
GO

--Create Error handling for stored procedures:
CREATE TABLE Auditing.CatchErrors
(
	OccurrenceID    INT	IDENTITY(1,1),
	ErrorDate		    DATETIME  NULL,
	ErrorNumber		  INT NULL,
	ErrorMsg		    NVARCHAR(4000)  NULL,
	ErrorSeverity	  INT NULL,
	ErrorState		  INT NULL,
	ErrorLine		    INT NULL,
	ErrorProcedure	NVARCHAR(128) NULL,
	ErrorXACTSTATE	SMALLINT  NULL,
	CONSTRAINT  PK_AuditErrors
	PRIMARY KEY (OccurrenceID)
);
GO

CREATE PROCEDURE Auditing.ErrorLogging
AS
	INSERT INTO Auditing.CatchErrors(
    ErrorDate,
    ErrorNumber,
    ErrorMsg,
    ErrorSeverity,
    ErrorState,
    ErrorLine,
    ErrorProcedure,
    ErrorXACTSTATE
  )
	VALUES (
		GETDATE(),
		ERROR_NUMBER(),
		ERROR_MESSAGE(),
		ERROR_SEVERITY(),
		ERROR_STATE(),
		ERROR_LINE(),
		ERROR_PROCEDURE(),
		XACT_STATE()
	);
GO

CREATE PROCEDURE Auditing.ErrorHandling
AS
	EXEC Auditing.ErrorLogging;		--Execute ErrorLogging, so we can log the error that triggered the catch block.
	IF @@TRANCOUNT <> 0				--Check transaction count, if there is a uncommited transaction do a ROLLBACK.
		BEGIN
			ROLLBACK TRANSACTION;
		END
	IF	XACT_STATE() = -1			--Check XACT_STATE in the case of uncommitable transactions -1 means the transaction is uncommitable.
		BEGIN
			ROLLBACK TRANSACTION;
		END
	IF	XACT_STATE() = 1			--Check XACT_STATE in the case of uncommitable transactions 1 means the transaction is commitable.
		BEGIN
			COMMIT TRANSACTION;
		END
GO


CREATE PROCEDURE ActiveDirectory.InsertUsers(
  @username NVARCHAR(100)
)
AS
BEGIN TRY
  SET XACT_ABORT ON;
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	  IF (@username IS NULL)
			BEGIN
				ROLLBACK TRANSACTION;
				THROW 1000, 'username cannot be NULL', 1;
			END
		BEGIN
			INSERT  ActiveDirectory.Users
			VALUES  (@username)
	    COMMIT TRANSACTION;
			RETURN 1;
		END
END TRY
BEGIN CATCH
	EXEC Auditing.ErrorHandling;
	RETURN 0;
END CATCH;
GO