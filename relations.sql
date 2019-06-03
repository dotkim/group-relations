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

PRINT 'Dropping tables';
--Drop tables-----------------------------  -----------------------------------------------------
IF OBJECT_ID('Link.ObjectRelations')        IS NOT NULL DROP TABLE Link.ObjectRelations;
IF OBJECT_ID('SubSystems.Objects')          IS NOT NULL DROP TABLE SubSystems.Objects;
IF OBJECT_ID('SubSystems.Sources')          IS NOT NULL DROP TABLE SubSystems.Sources;
IF OBJECT_ID('ActiveDirectory.GroupUsers')  IS NOT NULL DROP TABLE ActiveDirectory.GroupUsers;
IF OBJECT_ID('ActiveDirectory.Groups')      IS NOT NULL DROP TABLE ActiveDirectory.Groups;
IF OBJECT_ID('ActiveDirectory.Users')       IS NOT NULL DROP TABLE ActiveDirectory.Users;
-------------------------------------------------------------------------------------------------
PRINT 'Dropping schemas';
--Drop schemas------------------  -------------------------------------------
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