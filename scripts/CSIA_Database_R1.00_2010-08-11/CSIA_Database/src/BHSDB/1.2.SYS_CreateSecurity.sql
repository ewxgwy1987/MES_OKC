-- ##########################################################################
-- Description: SQL Scripts of creating BHS Solution Database Security Accounts.
-- Release#:    R2.0
-- Release On:  23 Dec 2008
-- Filename:    1.2.SYS_CreateSecurity.sql
-- Histories:
--				R1.0 - Released on 21 Nov 2007.
--				R2.0 - Released on 09 Sep 2008.
-- ##########################################################################


USE [BHSDB]
GO

PRINT 'INFO: STEP 1.2 - Creat BHS Solution Database Security Accounts.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO

/****** Object:  User [sacdbuser]    Script Date: 10/09/2007 08:13:42 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'sacdbuser')
BEGIN
	PRINT 'INFO: Deleting existing USER [sacdbuser]...'
	DROP USER [sacdbuser]
END
GO


/****** Object:  User [mdsdbuser]    Script Date: 10/09/2007 08:13:42 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'mdsdbuser')
BEGIN
	PRINT 'INFO: Deleting existing USER [mdsdbuser]...'
	DROP USER [mdsdbuser]
END
GO


/****** Object:  User [reportuser]    Script Date: 10/09/2007 08:13:42 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'reportuser')
BEGIN
	PRINT 'INFO: Deleting existing USER [reportuser]...'
	DROP USER [reportuser]
END
GO

/****** Object:  Role [BHS]    Script Date: 10/09/2007 08:13:42 ******/
IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'BHS' AND type = 'R')
BEGIN
	PRINT 'INFO: Deleting existing ROLE [BHS]...'
	DROP ROLE [BHS]
END
GO

USE [master]
GO

/****** Object:  Login [sacdbuser]    Script Date: 10/09/2007 08:13:43 ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'sacdbuser')
BEGIN
	PRINT 'INFO: Deleting existing LOGIN [sacdbuser]...'
	DROP LOGIN [sacdbuser]
END
GO


/****** Object:  Login [mdsdbuser]    Script Date: 10/09/2007 08:13:43 ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'mdsdbuser')
BEGIN
	PRINT 'INFO: Deleting existing LOGIN [mdsdbuser]...'
	DROP LOGIN [mdsdbuser]
END
GO


/****** Object:  Login [reportuser]    Script Date: 10/09/2007 08:13:43 ******/
IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'reportuser')
BEGIN
	PRINT 'INFO: Deleting existing LOGIN [reportuser]...'
	DROP LOGIN [reportuser]
END
GO


USE [master]
GO

/****** Object:  Login [sacdbuser]    Script Date: 10/09/2007 08:13:43 ******/
PRINT 'INFO: Creating LOGIN [sacdbuser]...'
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'sacdbuser')
CREATE LOGIN [sacdbuser] WITH PASSWORD=N'sac@interr0l1er', DEFAULT_DATABASE=[BHSDB], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER LOGIN [sacdbuser] ENABLE
GO


/****** Object:  Login [mdsdbuser]    Script Date: 10/09/2007 08:13:43 ******/
PRINT 'INFO: Creating LOGIN [mdsdbuser]...'
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'mdsdbuser')
CREATE LOGIN [mdsdbuser] WITH PASSWORD=N'mds@interr0l1er', DEFAULT_DATABASE=[BHSDB], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER LOGIN [mdsdbuser] ENABLE
GO


/****** Object:  Login [reportuser]    Script Date: 10/09/2007 08:13:43 ******/
PRINT 'INFO: Creating LOGIN [reportuser]...'
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'reportuser')
CREATE LOGIN [reportuser] WITH PASSWORD=N'report@interr0l1er', DEFAULT_DATABASE=[BHSDB], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER LOGIN [reportuser] ENABLE
GO


USE [BHSDB]
GO

/****** Object:  Role [BHS]    Script Date: 10/09/2007 08:13:42 ******/
PRINT 'INFO: Creating ROLE [BHS]...'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'BHS' AND type = 'R')
CREATE ROLE [BHS]
GO

GRANT CONTROL TO [BHS]
GO
GRANT BACKUP DATABASE TO [BHS]
GO
GRANT BACKUP LOG TO [BHS]
GO
GRANT CREATE FUNCTION TO [BHS]
GO
GRANT CREATE MESSAGE TYPE TO [BHS]
GO
GRANT CREATE PROCEDURE TO [BHS]
GO
GRANT CREATE QUEUE TO [BHS]
GO
GRANT CREATE TABLE TO [BHS]
GO
GRANT CREATE TYPE TO [BHS]
GO
GRANT CREATE VIEW TO [BHS]
GO
GRANT CREATE XML SCHEMA COLLECTION TO [BHS]
GO
GRANT DELETE TO [BHS]
GO
GRANT EXECUTE TO [BHS]
GO
GRANT INSERT TO [BHS]
GO
GRANT REFERENCES TO [BHS]
GO
GRANT SELECT TO [BHS]
GO
GRANT UPDATE TO [BHS]
GO
GRANT VIEW DATABASE STATE TO [BHS]
GO

/****** Object:  User [sacdbuser]    Script Date: 10/09/2007 08:13:42 ******/
PRINT 'INFO: Creating USER [sacdbuser]...'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'sacdbuser')
CREATE USER [sacdbuser] FOR LOGIN [sacdbuser] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sys.sp_addrolemember @rolename=N'BHS', @membername=N'sacdbuser'
GO


/****** Object:  User [mdsdbuser]    Script Date: 10/09/2007 08:13:42 ******/
PRINT 'INFO: Creating USER [mdsdbuser]...'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'mdsdbuser')
CREATE USER [mdsdbuser] FOR LOGIN [mdsdbuser] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sys.sp_addrolemember @rolename=N'BHS', @membername=N'mdsdbuser'
GO


/****** Object:  User [reportuser]    Script Date: 10/09/2007 08:13:42 ******/
PRINT 'INFO: Creating USER [reportuser]...'
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'reportuser')
CREATE USER [reportuser] FOR LOGIN [reportuser] WITH DEFAULT_SCHEMA=[dbo]
GO
EXEC sys.sp_addrolemember @rolename=N'BHS', @membername=N'reportuser'
GO




PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: End of STEP 1.2'
GO