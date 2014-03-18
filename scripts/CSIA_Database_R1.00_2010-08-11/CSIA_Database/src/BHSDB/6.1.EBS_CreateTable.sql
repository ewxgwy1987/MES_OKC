-- ##########################################################################
-- Release#:    R1.0
-- Release On:  03 Aug 2010
-- Filename:    6.1.EBS_Update.sql
-- Description: SQL Scripts of creating SQL Server Agent schedule jobs.
--
--    Schedule jobs to be created by this script:
--    01. [ITEM_INVENTORY] - Add ITEM_INVENTORY table.
--    02. [ITEM_INVENTORY_AUDIT] - Add ITEM_INVENTORY_AUDIT table.
--    03. [ITEM_INVENTORY_AUDIT_HEADER] - Add ITEM_INVENTORY_AUDIT_HEADER table.
--    04. [ITEM_INVENTORY_STORAGE] - Add ITEM_INVENTORY_STORAGE table.
--    05. [EBS_EVENT] - Add EBS_EVENT table.
--
--
-- Histories:
--    R1.0 - Released on ?.
-- Remarks:
-- ##########################################################################




PRINT 'INFO: STEP 6.1 - Update EBS tables and require tables.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
USE [BHSDB]
GO
/****** Object:  Table [dbo].[ITEM_INVENTORY]    Script Date: 08/11/2010 16:53:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_INVENTORY]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_INVENTORY]...'
	DROP TABLE [dbo].[ITEM_INVENTORY]
END
GO
PRINT 'INFO: Creating table [MDS_AUDIT_LOGS]...'
CREATE TABLE [dbo].[ITEM_INVENTORY](
	[COMPARTMENT_ID] [varchar](10) NOT NULL DEFAULT (''),
	[LICENSE_PLATE] [varchar](10) NOT NULL DEFAULT (''),
	[AIRLINE] [varchar](3) NOT NULL DEFAULT (''),
	[FLIGHT_NUMBER] [varchar](5) NOT NULL DEFAULT (''),
	[STD] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[RETRIEVAL_TIME] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[RUSH_TIME] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[TIME_STAMP] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[STATION_NAME] [varchar](20) NOT NULL DEFAULT (''),
	[RETRIEVED_TIME] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[RETRIEVED] [bit] NOT NULL DEFAULT ((0))
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

USE [BHSDB]
GO
/****** Object:  Table [dbo].[ITEM_INVENTORY_AUDIT]    Script Date: 08/11/2010 16:58:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_INVENTORY_AUDIT]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_INVENTORY_AUDIT]...'
	DROP TABLE [dbo].[ITEM_INVENTORY_AUDIT]
END
GO
PRINT 'INFO: Creating table [ITEM_INVENTORY_AUDIT]...'
CREATE TABLE [dbo].[ITEM_INVENTORY_AUDIT](
	[BATCH_ID] [int] NOT NULL DEFAULT ((0)),
	[COMPARTMENT_ID] [varchar](10) NOT NULL DEFAULT (''),
	[LICENSE_PLATE] [varchar](10) NOT NULL DEFAULT (''),
	[AIRLINE] [varchar](3) NOT NULL DEFAULT (''),
	[FLIGHT_NUMBER] [varchar](5) NOT NULL DEFAULT (''),
	[STD] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[TIME_STAMP] [datetime] NOT NULL DEFAULT ('01-Jan-1900')
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

USE [BHSDB]
GO
/****** Object:  Table [dbo].[ITEM_INVENTORY_AUDIT_HEADER]    Script Date: 08/11/2010 17:00:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_INVENTORY_AUDIT_HEADER]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_INVENTORY_AUDIT_HEADER]...'
	DROP TABLE [dbo].[ITEM_INVENTORY_AUDIT_HEADER]
END
GO
PRINT 'INFO: Creating table [ITEM_INVENTORY_AUDIT_HEADER]...'
CREATE TABLE [dbo].[ITEM_INVENTORY_AUDIT_HEADER](
	[BATCH_ID] [int] IDENTITY(1,1) NOT NULL,
	[AUDIT_DATE] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[STATION_NAME] [varchar](20) NOT NULL DEFAULT (''),
	[UPDATE_INVENTORY] [datetime] NOT NULL DEFAULT ('01-Jan-1900')
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

USE [BHSDB]
GO
/****** Object:  Table [dbo].[ITEM_INVENTORY_STORAGE]    Script Date: 08/11/2010 17:01:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ITEM_INVENTORY_STORAGE]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [ITEM_INVENTORY_STORAGE]...'
	DROP TABLE [dbo].[ITEM_INVENTORY_STORAGE]
END
GO
PRINT 'INFO: Creating table [ITEM_INVENTORY_STORAGE]...'
CREATE TABLE [dbo].[ITEM_INVENTORY_STORAGE](
	[RACK_ID] [varchar](10) NOT NULL DEFAULT (''),
	[SHELF_ID] [varchar](10) NOT NULL DEFAULT (''),
	[COMPARTMENT_ID] [varchar](10) NOT NULL DEFAULT ('')
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

USE [BHSDB]
GO

/****** Object:  Table [dbo].[EBS_EVENT]    Script Date: 08/11/2010 17:06:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EBS_EVENT]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [EBS_EVENT]...'
	DROP TABLE [dbo].[EBS_EVENT]
END
GO
PRINT 'INFO: Creating table [EBS_EVENT]...'
CREATE TABLE [dbo].[EBS_EVENT](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[COMPARTMENT_ID] [varchar](10) NOT NULL DEFAULT (''),
	[LICENSE_PLATE] [varchar](10) NOT NULL DEFAULT (''),
	[TIME_STAMP] [datetime] NOT NULL DEFAULT ('01-Jan-1900'),
	[ACTION] [varchar](10) NOT NULL DEFAULT (''),
	[ACTION_DESC] [varchar](25) NOT NULL DEFAULT (''),
	[STATION_NAME] [varchar](16) NOT NULL DEFAULT ('')
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO