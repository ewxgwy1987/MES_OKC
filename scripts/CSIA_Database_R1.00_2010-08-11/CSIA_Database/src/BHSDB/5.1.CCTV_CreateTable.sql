-- ##########################################################################
-- Release#:    R1.0
-- Release On:  18 Jul 2009
-- Filename:    5.1.CCTV_CreateTable.sql
-- Description: SQL Scripts of creating MDS-CCTV interface related objects 
--              (table, trigger, foreign keys, etc.).
--
--    Tables to be created by this script file:
--    01. [CCTV_MDS_ACTIVATED_ALARMS] - the list of MDS current alarms.
--				Records in this table will be inserted by INSERT trigger of MDS 
--				table [MDS_DATA] whenever the new alarm is activated and logged 
--				by AlarmODBC.
--				Records in this table will be removed by INSERT trigger of table 
--				[CCTV_MDS_DEACTIVATED_ALARMS] whenever the current alarm is  
--				normalized and logged by AlarmODBC.
--				The INSERT trigger of [CCTV_MDS_ACTIVATED_ALARMS] table will copy 
--				new inserted alarm data into table [CCTV_MDS_OUTGOING_ALARMS].
--				CCTV Engine application keep polling table [CCTV_MDS_OUTGOING_ALARMS]
--				in 1 second interval. The new records in this table will be forwarded
--				to CCTV server via CCTV GW and then removed from this table.
--
--				To prevent the deactivated alarm remaining in this table due to 
--				certain reason, for example, MDS server hung and current alarm is
--				deactivated before MDS server is recovered, MDS shall synchronize 
--				the currents alarms between iFix and [CCTV_MDS_ACTIVATED_ALARMS]
--				table each time when MDS application is started. Two tasks need
--				to be performed by MDS at the startup time:
--				1) Remove all existing records from table [CCTV_MDS_ACTIVATED_ALARMS];
--				2) Insert all current alarms into table [CCTV_MDS_ACTIVATED_ALARMS].
--    02. [CCTV_MDS_DEACTIVATED_ALARMS] - 
--				whenever the current alarm is normalized, the associated alarm 
--				info will be logged into this table by INSERT trigger of MDS table
--				[MDS_DATA]. 
--
--				The INSERT trigger of table [CCTV_MDS_DEACTIVATED_ALARMS] will:
--				1) copy new inserted normalized alarm data into another table 
--				   [CCTV_MDS_OUTGOING_ALARMS] for forwarding it to CCTV server;
--				2) delete all normalized alarm records from [CCTV_MDS_ACTIVATED_ALARMS] 
--				   table.
--				3) delete all records from current table ([CCTV_MDS_DEACTIVATED_ALARMS]).
--    03. [CCTV_MDS_SPOT_COMMANDS] - 
--				whenever MDS needs send Spot Disply command to CCTV, it will write
--				the command data into this table for forwarding to CCTV server.
--				The INSERT trigger of this table will:
--				1) copy new inserted SPOT command data into another table 
--				   [CCTV_MDS_OUTGOING_ALARMS] for forwarding it to CCTV server;
--				2) delete all records from current table ([CCTV_MDS_SPOT_COMMANDS]).
--    04. [CCTV_MDS_OUTGOING_ALARMS] - Used to buffer the outgoing messages that
--				need to be forwarded to CCTV server by CCTV Engine via GW application.
--				The records in this table are inserted by the INSERT trigger of various 
--				tables upon the alarm is activated/deactivated, or spot display command 
--				is issued.
--				The records in this table are deleted immediately by CCTV Engine  
--				application upon data is sent out.
--    05. [CCTV_MDS_OUTGOING_ALARM_ACTIONS] - 
--				The list of available MDS actions that are associated to the outgoing
--				messages. There are following 3 valid actions:
--				1) ACTIVATED	- Alarm Activated message
--				2) DEACTIVATED	- Alarm Activated message
--				3) SPOT			- Alarm Activated message
--    06. [CCTV_STATUS_TYPES] - 
--				The list of available type of CCTV device status.
--				There are following 2 valid types
--				1) ALARM	- CCTV equipment fault
--				2) EVENT	- CCTV event
--    07. [CCTV_STATUS_CODES] - 
--				The list of available type of CCTV status/alarm codes.
--				There are following 5 valid types
--				1) NVRCPU 每 CCTV NVR CPU Usage Exceed Limit; 
--				2) NVRMEM 每 CCTV NVR Memory Usage Exceed Limit; 
--				3) NVRDSK 每 CCTV NVR out of Disk Space; 
--				4) NVRARC 每 CCTV NVR Archive Fail; 
--				5) CAMSGN 每 CCTV Camera Signal Lost (Connection Fail). 
--    08. [CCTV_STATUS] - The current alarms of CCTV devices.
--				whenever CCTV equipment fault or event is occurred and need displayed on 
--				MDS screen or logged into BHS database for reporting, CCTV server will
--				send CCTV Status message to CCTV Engine via GW. These data will be logged  
--				into this table by CCTV Engine. 
--				MDS keeps monitoring this table for any CCTV equipment status reports. 
--				Whenever the new record is inserted into this table and detected by MDS, 
--				MDS will turn on the CCTV Alarm (SIM) tag to notify the BHS user. Whenever
--				empty records in this table is detected by MDS, MDS will classified that 
--				all CCTV device alarms have been normalized, and therefore will turn off
--				the CCTV Alarm.
--				Records in this table will be deleted by the INSERT trigger of table 
--				[CCTV_DEACTIVATED_ALARMS] whenever the existing CCTV alarm is deactivated
--				in the CCTV system and sent to CCTV GW application.
--    09. [CCTV_DEACTIVATED_ALARMS] - 
--				whenever the current CCTV alarm is normalized in the CCTV system, the 
--				associated alarm info will be sent to CCTV Engine via GW application. Engine 
--				will then log them into this table.
--				The INSERT trigger of this table will:
--				1) delete all normalized CCTV alarm records from [CCTV_STATUS] table.
--				2) delete all records from current table ([CCTV_DEACTIVATED_ALARMS]).
--    10. [CCTV_DEVICE_TYPES] -
--              Used to store the list of CCTV device types.
--    11. [CCTV_EQUIPMENT_MAPPING] -
--				This table provides the mapping of the respective camera views 
--				(positions) to the BHS equipment being monitored on the CCTV system. 
--				The insert trigger on the [MDS_DATA] table will insert the alarm 
--				record(s) to the [CCTV_MDS_ACTIVATED_ALARMS] table & 
--				[CCTV_MDS_DEACTIVATED_ALARMS] table if:
--				1) the equipment is found on this mapping table;
--				2) alarm type [CCTV_USED] setting is true in the table [REPORT_FAULT].
--				If both conditions are matched, then INSERT trigger of [MDS_DATA] table
--				will retrieve the camera ID and view/position with the provided equipment 
--				subsystem and ID and insert them into table [CCTV_MDS_ACTIVATED_ALARMS] or
--				[CCTV_MDS_DEACTIVATED_ALARMS].
--    12. [CCTV_MDS_SENTDATALOGGING] - Historical data table, used to store all
--				outgoing activated, deactivated, and spot display commands sent to 
--				CCTV server.
--    13. [CCTV_RECEIVEDDATALOGGING] - Historical data table, used to store all
--				incoming CCTV events, activated and deactivated alarms.
--
--	  Upon MDS-CCTV server connection is opened (both CCTV GW and Engine is ready), 
--    CCTVEngine will perform following tasks:
--    1. clear all CCTV alarms stored in the database table [CCTV_STATUS];
--    2. clear all Outgoing MDS Alarm messages stored in the database table 
--       [CCTV_MDS_OUTGOING_ALARMS];
--    3. send all current MDS alarms stored in the database table 
--       [CCTV_MDS_ACTIVATED_ALARMS];
--
--    There are few alarms will be sent from CCTV server to MDS for notification BHS 
--    operators. There are few alarms amount them will not have the alarm normalized 
--    nortification sent by CCTV server to MDS. Hence, the auto alarm reset of these
--    CCTV alarms is needed. Otherwise, these CCTV alarms will be shown on MDS screen
--    permanently. 
--
--    Since MDS keeps monitoring the [CCTV_STATUS] table and generate CCTV alarm if
--    this table is not empty, reset of CCTV alarm is done by removing particular 
--    CCTV alarm, which [TIME_STAME] field value is older than the current time for 
--    per-set alarm auto reset timeout, from this table.
--
--    Foreign Keys to be created by this script:
--    01. [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]
--    02. [FK_CCTV_STATUS_TYPE]
--    03. [FK_CCTV_STATUS_CODE]
--    04. [FK_CCTV_DALARM_CODE]
--    05. [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]
--    06. [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]
--    07. [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]
--    08. [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]
--    09. [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]
--
--    Triggers to be created by this script:
--    01. [INSERT_CCTV_MDS_ACTIVATED_ALARMS] - 
--				Insert trigger of table [CCTV_MDS_ACTIVATED_ALARMS]
--				1. Insert MDS new alarm into table [CCTV_MDS_OUTGOING_ALARMS].
--    02. [INSERT_CCTV_MDS_DEACTIVATED_ALARMS] - 
--				Insert trigger of table [CCTV_MDS_DEACTIVATED_ALARMS]
--				1. copy new inserted normalized alarm data into another table 
--				   [CCTV_MDS_OUTGOING_ALARMS] for forwarding it to CCTV server;
--				2. delete all normalized alarm records from [CCTV_MDS_ACTIVATED_ALARMS] table.
--				3. delete all records from current table ([CCTV_MDS_DEACTIVATED_ALARMS]).
--    03. [INSERT_CCTV_MDS_SPOT_COMMANDS] - 
--				Insert trigger of table [CCTV_MDS_SPOT_COMMANDS]
--				1. copy new inserted normalized alarm data into another table 
--				   [CCTV_MDS_OUTGOING_ALARMS] for forwarding it to CCTV server;
--				2. delete all records from current table ([CCTV_MDS_SPOT_COMMANDS]).
--    04. [INSERT_CCTV_DEACTIVATED_ALARMS] - 
--				Insert trigger of table [CCTV_DEACTIVATED_ALARMS]
--				1. delete all normalized CCTV alarm records from [CCTV_STATUS] table;
--				2. delete all records from current table ([CCTV_DEACTIVATED_ALARMS]).
--
--

-- ##########################################################################




USE [BHSDB]
GO

PRINT 'INFO: STEP 5.1 - Creat MDS-CCTV interface related tables.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Drop Existing Tables...'
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_ACTIVATED_ALARMS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_MDS_ACTIVATED_ALARMS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_DEACTIVATED_ALARMS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_MDS_DEACTIVATED_ALARMS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_SPOT_COMMANDS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_MDS_SPOT_COMMANDS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_OUTGOING_ALARMS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_STATUS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_DEACTIVATED_ALARMS]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_DEACTIVATED_ALARMS]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_EQUIPMENT_MAPPING]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_EQUIPMENT_MAPPING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_SENTDATALOGGING]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_MDS_SENTDATALOGGING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_RECEIVEDDATALOGGING]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_RECEIVEDDATALOGGING]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_STATUS_TYPES]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS_CODES]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_STATUS_CODES]	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_DEVICE_TYPES]') AND type in (N'U'))
	DROP TABLE [dbo].[CCTV_DEVICE_TYPES]

PRINT 'INFO: End of Drop Existing Tables.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Tables...'
GO


-- ****** Object:  Table [dbo].[CCTV_MDS_ACTIVATED_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_ACTIVATED_ALARMS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_MDS_ACTIVATED_ALARMS]...'
	DROP TABLE [dbo].[CCTV_MDS_ACTIVATED_ALARMS]
END
GO
PRINT 'INFO: Creating table [CCTV_MDS_ACTIVATED_ALARMS]...'
CREATE TABLE [dbo].[CCTV_MDS_ACTIVATED_ALARMS](
	[TIME_STAMP] [datetime] NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[EQUIPMENT_ID] [varchar](20) NOT NULL,
	[ALARM_TYPE] [varchar](10) NOT NULL,
	[ALARM_DESCRIPTION] [nvarchar](50) NOT NULL,
	[CCTV_DEVICE_TYPE] [varchar](4) NOT NULL,
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_CAMERA_POSITION_ID] [varchar](2) NOT NULL,
 CONSTRAINT [PK_CCTV_MDS_ACTIVATED_ALARMS] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM] ASC,
	[EQUIPMENT_ID] ASC,
	[ALARM_TYPE] ASC	
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[CCTV_MDS_DEACTIVATED_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_DEACTIVATED_ALARMS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_MDS_DEACTIVATED_ALARMS]...'
	DROP TABLE [dbo].[CCTV_MDS_DEACTIVATED_ALARMS]
END
GO
PRINT 'INFO: Creating table [CCTV_MDS_DEACTIVATED_ALARMS]...'
CREATE TABLE [dbo].[CCTV_MDS_DEACTIVATED_ALARMS](
	[TIME_STAMP] [datetime] NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[EQUIPMENT_ID] [varchar](20) NOT NULL,
	[ALARM_TYPE] [varchar](10) NOT NULL,
	[CCTV_DEVICE_TYPE] [varchar](4) NOT NULL,
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_CAMERA_POSITION_ID] [varchar](2) NOT NULL,
 CONSTRAINT [PK_CCTV_MDS_DEACTIVATED_ALARMS] PRIMARY KEY CLUSTERED 
(
	[SUBSYSTEM] ASC,
	[EQUIPMENT_ID] ASC,
	[ALARM_TYPE] ASC	
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[CCTV_MDS_SPOT_COMMANDS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_SPOT_COMMANDS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_MDS_SPOT_COMMANDS]...'
	DROP TABLE [dbo].[CCTV_MDS_SPOT_COMMANDS]
END
GO
PRINT 'INFO: Creating table [CCTV_MDS_SPOT_COMMANDS]...'
CREATE TABLE [dbo].[CCTV_MDS_SPOT_COMMANDS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CCTV_DEVICE_TYPE] [varchar](4) NOT NULL,
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_CAMERA_POSITION_ID] [varchar](2) NOT NULL,
 CONSTRAINT [PK_CCTV_MDS_SPOT_COMMANDS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO




-- ****** Object:  Table [dbo].[CCTV_MDS_OUTGOING_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_OUTGOING_ALARMS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_MDS_OUTGOING_ALARMS]...'
	DROP TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS]
END
GO
PRINT 'INFO: Creating table [CCTV_MDS_OUTGOING_ALARMS]...'
CREATE TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ACTION] [varchar](11) NOT NULL,
	[TIME_STAMP] [datetime] NULL,
	[SUBSYSTEM] [varchar](10) NULL,
	[EQUIPMENT_ID] [varchar](20) NULL,
	[ALARM_TYPE] [varchar](10) NULL,
	[ALARM_DESCRIPTION] [nvarchar](50) NULL,
	[CCTV_DEVICE_TYPE] [varchar](4) NULL,
	[CCTV_DEVICE_ID] [varchar](4) NULL,
	[CCTV_CAMERA_POSITION_ID] [varchar](2) NULL,
 CONSTRAINT [PK_CCTV_MDS_OUTGOING_ALARMS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_MDS_OUTGOING_ALARM_ACTIONS]...'
	DROP TABLE [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS]
END
GO
PRINT 'INFO: Creating table [CCTV_MDS_OUTGOING_ALARM_ACTIONS]...'
CREATE TABLE [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS](
	[ACTION] [varchar](11) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_CCTV_MDS_OUTGOING_ALARM_ACTIONS] PRIMARY KEY CLUSTERED 
(
	[ACTION] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[CCTV_STATUS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_STATUS]...'
	DROP TABLE [dbo].[CCTV_STATUS]
END
GO
PRINT 'INFO: Creating table [CCTV_STATUS]...'
CREATE TABLE [dbo].[CCTV_STATUS](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NULL,
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_STATUS_TYPE] [varchar](6) NOT NULL,
	[CCTV_STATUS_CODE] [varchar](6) NOT NULL,
	[CCTV_STATUS_DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_CCTV_STATUS] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[CCTV_STATUS_TYPES]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_STATUS_TYPES]...'
	DROP TABLE [dbo].[CCTV_STATUS_TYPES]
END
GO
PRINT 'INFO: Creating table [CCTV_STATUS_TYPES]...'
CREATE TABLE [dbo].[CCTV_STATUS_TYPES](
	[TYPE] [varchar](6) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_CCTV_STATUS_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO



-- ****** Object:  Table [dbo].[CCTV_DEACTIVATED_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_DEACTIVATED_ALARMS]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_DEACTIVATED_ALARMS]...'
	DROP TABLE [dbo].[CCTV_DEACTIVATED_ALARMS]
END
GO
PRINT 'INFO: Creating table [CCTV_DEACTIVATED_ALARMS]...'
CREATE TABLE [dbo].[CCTV_DEACTIVATED_ALARMS](
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_STATUS_CODE] [varchar](6) NOT NULL,
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[CCTV_STATUS_CODES]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS_CODES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_STATUS_CODES]...'
	DROP TABLE [dbo].[CCTV_STATUS_CODES]
END
GO
PRINT 'INFO: Creating table [CCTV_STATUS_CODES]...'
CREATE TABLE [dbo].[CCTV_STATUS_CODES](
	[CODE] [varchar](6) NOT NULL,
	[IS_AUTO_RESET] bit NOT NULL CONSTRAINT DF_CCTV_STATUS_CODES_IS_AUTO_RESET DEFAULT 0,
	[DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_CCTV_STATUS_CODES] PRIMARY KEY CLUSTERED 
(
	[CODE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO





-- ****** Object:  Table [dbo].[CCTV_EQUIPMENT_MAPPING]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_EQUIPMENT_MAPPING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_EQUIPMENT_MAPPING]...'
	DROP TABLE [dbo].[CCTV_EQUIPMENT_MAPPING]
END
GO
PRINT 'INFO: Creating table [CCTV_EQUIPMENT_MAPPING]...'
CREATE TABLE [dbo].[CCTV_EQUIPMENT_MAPPING](
	[CCTV_DEVICE_CODE] [varchar](20) NOT NULL,
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_CAMERA_POSITION_ID] [varchar](2) NOT NULL,
	[CCTV_DEVICE_TYPE] [varchar](4) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[EQUIPMENT_ID] [varchar](20) NOT NULL,
 CONSTRAINT [PK_CCTV_EQUIPMENT_MAPPING] PRIMARY KEY CLUSTERED 
(
	[CCTV_DEVICE_ID] ASC,
	[SUBSYSTEM] ASC,
	[EQUIPMENT_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[CCTV_DEVICE_TYPES]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_DEVICE_TYPES]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_DEVICE_TYPES]...'
	DROP TABLE [dbo].[CCTV_DEVICE_TYPES]
END
GO
PRINT 'INFO: Creating table [CCTV_DEVICE_TYPES]...'
CREATE TABLE [dbo].[CCTV_DEVICE_TYPES](
	[TYPE] [varchar](4) NOT NULL,
	[DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_CCTV_DEVICE_TYPES] PRIMARY KEY CLUSTERED 
(
	[TYPE] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO

-- ****** Object:  Table [dbo].[CCTV_MDS_SENT_DATA_LOGGING]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_SENT_DATA_LOGGING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_MDS_SENT_DATA_LOGGING]...'
	DROP TABLE [dbo].[CCTV_MDS_SENT_DATA_LOGGING]
END
GO
PRINT 'INFO: Creating table [CCTV_MDS_SENT_DATA_LOGGING]...'
CREATE TABLE [dbo].[CCTV_MDS_SENT_DATA_LOGGING](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SENDER] [varchar](8) NOT NULL,
	[RECEIVER] [varchar](8) NOT NULL,
	[ACTION] [varchar](11) NOT NULL,
	[TIME_STAMP] [datetime] NULL,
	[SUBSYSTEM] [varchar](10) NULL,
	[EQUIPMENT_ID] [varchar](20) NULL,
	[ALARM_TYPE] [varchar](10) NULL,
	[ALARM_DESCRIPTION] [nvarchar](50) NULL,
	[CCTV_DEVICE_TYPE] [varchar](4) NULL,
	[CCTV_DEVICE_ID] [varchar](4) NULL,
	[CCTV_CAMERA_POSITION_ID] [varchar](2) NULL,
 CONSTRAINT [PK_CCTV_MDS_SENT_DATA_LOGGING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO


-- ****** Object:  Table [dbo].[CCTV_RECEIVED_DATA_LOGGING]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CCTV_RECEIVED_DATA_LOGGING]') AND type in (N'U'))
BEGIN
	PRINT 'INFO: Deleting existing table [CCTV_RECEIVED_DATA_LOGGING]...'
	DROP TABLE [dbo].[CCTV_RECEIVED_DATA_LOGGING]
END
GO
PRINT 'INFO: Creating table [CCTV_RECEIVED_DATA_LOGGING]...'
CREATE TABLE [dbo].[CCTV_RECEIVED_DATA_LOGGING](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[SENDER] [varchar](8) NOT NULL,
	[RECEIVER] [varchar](8) NOT NULL,
	[ACTION] [varchar](11) NOT NULL,
	[TIME_STAMP] [datetime] NULL,
	[CCTV_DEVICE_ID] [varchar](4) NOT NULL,
	[CCTV_STATUS_TYPE] [varchar](6) NULL,
	[CCTV_STATUS_CODE] [varchar](6) NULL,
	[CCTV_STATUS_DESCRIPTION] [nvarchar](50) NULL,
 CONSTRAINT [PK_CCTV_RECEIVED_DATA_LOGGING] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO






PRINT 'INFO: End of Creating New Table.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Views...'
GO






PRINT 'INFO: End of Creating New Views.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Foreign Keys...'
GO



-- ****** Object:  ForeignKey [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_OUTGOING_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]...'
	ALTER TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS] DROP CONSTRAINT [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]...'
ALTER TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS] WITH CHECK ADD CONSTRAINT [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS] FOREIGN KEY([ACTION])
REFERENCES [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS] ([ACTION])
GO
ALTER TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS] CHECK CONSTRAINT [FK_CCTV_MDS_OUTGOING_ALARM_ACTIONS]
GO

-- ****** Object:  ForeignKey [FK_CCTV_STATUS_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_STATUS_TYPE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_STATUS_TYPE]...'
	ALTER TABLE [dbo].[CCTV_STATUS] DROP CONSTRAINT [FK_CCTV_STATUS_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_STATUS_TYPE]...'
ALTER TABLE [dbo].[CCTV_STATUS] WITH CHECK ADD CONSTRAINT [FK_CCTV_STATUS_TYPE] FOREIGN KEY([CCTV_STATUS_TYPE])
REFERENCES [dbo].[CCTV_STATUS_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[CCTV_STATUS] CHECK CONSTRAINT [FK_CCTV_STATUS_TYPE]
GO

-- ****** Object:  ForeignKey [FK_CCTV_STATUS_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_STATUS_CODE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_STATUS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_STATUS_CODE]...'
	ALTER TABLE [dbo].[CCTV_STATUS] DROP CONSTRAINT [FK_CCTV_STATUS_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_STATUS_CODE]...'
ALTER TABLE [dbo].[CCTV_STATUS] WITH CHECK ADD CONSTRAINT [FK_CCTV_STATUS_CODE] FOREIGN KEY([CCTV_STATUS_CODE])
REFERENCES [dbo].[CCTV_STATUS_CODES] ([CODE])
GO
ALTER TABLE [dbo].[CCTV_STATUS] CHECK CONSTRAINT [FK_CCTV_STATUS_CODE]
GO


-- ****** Object:  ForeignKey [FK_CCTV_DALARM_CODE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_DALARM_CODE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_DEACTIVATED_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_DALARM_CODE]...'
	ALTER TABLE [dbo].[CCTV_DEACTIVATED_ALARMS] DROP CONSTRAINT [FK_CCTV_DALARM_CODE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_DALARM_CODE]...'
ALTER TABLE [dbo].[CCTV_DEACTIVATED_ALARMS] WITH CHECK ADD CONSTRAINT [FK_CCTV_DALARM_CODE] FOREIGN KEY([CCTV_STATUS_CODE])
REFERENCES [dbo].[CCTV_STATUS_CODES] ([CODE])
GO
ALTER TABLE [dbo].[CCTV_DEACTIVATED_ALARMS] CHECK CONSTRAINT [FK_CCTV_DALARM_CODE]
GO



-- ****** Object:  ForeignKey [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_OUTGOING_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]...'
	ALTER TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS] DROP CONSTRAINT [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]...'
ALTER TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS] WITH CHECK ADD 
		CONSTRAINT [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE] FOREIGN KEY([CCTV_DEVICE_TYPE])
REFERENCES [dbo].[CCTV_DEVICE_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[CCTV_MDS_OUTGOING_ALARMS] CHECK CONSTRAINT [FK_CCTV_MDS_OUTGOING_ALARM_CCTV_DEV_TYPE]
GO

-- ****** Object:  ForeignKey [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_ACTIVATED_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]...'
	ALTER TABLE [dbo].[CCTV_MDS_ACTIVATED_ALARMS] DROP CONSTRAINT [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]...'
ALTER TABLE [dbo].[CCTV_MDS_ACTIVATED_ALARMS] WITH CHECK ADD 
		CONSTRAINT [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE] FOREIGN KEY([CCTV_DEVICE_TYPE])
REFERENCES [dbo].[CCTV_DEVICE_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[CCTV_MDS_ACTIVATED_ALARMS] CHECK CONSTRAINT [FK_CCTV_MDS_ACTIVATED_ALARMS_CCTV_DEV_TYPE]
GO

-- ****** Object:  ForeignKey [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_DEACTIVATED_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]...'
	ALTER TABLE [dbo].[CCTV_MDS_DEACTIVATED_ALARMS] DROP CONSTRAINT [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]...'
ALTER TABLE [dbo].[CCTV_MDS_DEACTIVATED_ALARMS] WITH CHECK ADD 
		CONSTRAINT [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE] FOREIGN KEY([CCTV_DEVICE_TYPE])
REFERENCES [dbo].[CCTV_DEVICE_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[CCTV_MDS_DEACTIVATED_ALARMS] CHECK CONSTRAINT [FK_CCTV_MDS_DEACTIVATED_ALARMS_CCTV_DEV_TYPE]
GO

-- ****** Object:  ForeignKey [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_MDS_SPOT_COMMANDS]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]...'
	ALTER TABLE [dbo].[CCTV_MDS_SPOT_COMMANDS] DROP CONSTRAINT [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]...'
ALTER TABLE [dbo].[CCTV_MDS_SPOT_COMMANDS] WITH CHECK ADD 
		CONSTRAINT [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE] FOREIGN KEY([CCTV_DEVICE_TYPE])
REFERENCES [dbo].[CCTV_DEVICE_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[CCTV_MDS_SPOT_COMMANDS] CHECK CONSTRAINT [FK_CCTV_MDS_SPOT_COMMANDS_CCTV_DEV_TYPE]
GO


-- ****** Object:  ForeignKey [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]    Script Date: 10/08/2007 13:18:35 ******
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]') 
	AND parent_object_id = OBJECT_ID(N'[dbo].[CCTV_EQUIPMENT_MAPPING]'))
BEGIN
	PRINT 'INFO: Deleting existing ForeignKey [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]...'
	ALTER TABLE [dbo].[CCTV_EQUIPMENT_MAPPING] DROP CONSTRAINT [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]
END
PRINT 'INFO: Creating ForeignKey [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]...'
ALTER TABLE [dbo].[CCTV_EQUIPMENT_MAPPING]  WITH CHECK ADD  CONSTRAINT [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE] FOREIGN KEY([CCTV_DEVICE_TYPE])
REFERENCES [dbo].[CCTV_DEVICE_TYPES] ([TYPE])
GO
ALTER TABLE [dbo].[CCTV_EQUIPMENT_MAPPING] CHECK CONSTRAINT [FK_CCTV_EQUIPMENT_MAPPING_CCTV_DEV_TYPE]
GO




PRINT 'INFO: End of Creating New Foreign Keys.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Triggers...'
GO




-- ****** Object:  Trigger [INSERT_CCTV_MDS_ACTIVATED_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_CCTV_MDS_ACTIVATED_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_CCTV_MDS_ACTIVATED_ALARMS]...'
	DROP TRIGGER [INSERT_CCTV_MDS_ACTIVATED_ALARMS]
END
PRINT 'INFO: Creating trigger [INSERT_CCTV_MDS_ACTIVATED_ALARMS]...'
GO
CREATE TRIGGER [INSERT_CCTV_MDS_ACTIVATED_ALARMS] ON [dbo].[CCTV_MDS_ACTIVATED_ALARMS]
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[CCTV_MDS_OUTGOING_ALARMS] (
				[ACTION],[TIME_STAMP],[SUBSYSTEM],[EQUIPMENT_ID],[ALARM_TYPE],
				[ALARM_DESCRIPTION],[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID])
		SELECT 'ACTIVATED',[TIME_STAMP],[SUBSYSTEM],[EQUIPMENT_ID],[ALARM_TYPE],
				[ALARM_DESCRIPTION],[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID]
		FROM INSERTED;
END
GO


-- ****** Object:  Trigger [INSERT_CCTV_MDS_DEACTIVATED_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_CCTV_MDS_DEACTIVATED_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_CCTV_MDS_DEACTIVATED_ALARMS]...'
	DROP TRIGGER [INSERT_CCTV_MDS_DEACTIVATED_ALARMS]
END
PRINT 'INFO: Creating trigger [INSERT_CCTV_MDS_DEACTIVATED_ALARMS]...'
GO
CREATE TRIGGER [INSERT_CCTV_MDS_DEACTIVATED_ALARMS] ON [dbo].[CCTV_MDS_DEACTIVATED_ALARMS]
AFTER INSERT
AS
BEGIN
    DECLARE @subSys [varchar](10), @equpID [varchar](20), @almType [varchar](10);
	SELECT @subSys = [SUBSYSTEM],@equpID = [EQUIPMENT_ID],@almType = [ALARM_TYPE]
	FROM INSERTED;

	-- 1. copy new inserted normalized alarm data into another table 
	--    [CCTV_MDS_OUTGOING_ALARMS] for forwarding it to CCTV server;
	INSERT INTO [dbo].[CCTV_MDS_OUTGOING_ALARMS] (
				[ACTION],[TIME_STAMP],[SUBSYSTEM],[EQUIPMENT_ID],[ALARM_TYPE],
				[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID])
		SELECT 'DEACTIVATED',[TIME_STAMP],[SUBSYSTEM],[EQUIPMENT_ID],[ALARM_TYPE],
				[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID]
		FROM INSERTED;
		
	-- 2) delete all normalized alarm records from [CCTV_MDS_ACTIVATED_ALARMS] table.
	DELETE FROM [dbo].[CCTV_MDS_ACTIVATED_ALARMS]
		WHERE [SUBSYSTEM]=@subSys AND [EQUIPMENT_ID]=@equpID AND [ALARM_TYPE]=@almType;
	
	-- 3) delete all records from current table ([CCTV_MDS_DEACTIVATED_ALARMS]).
	DELETE FROM [dbo].[CCTV_MDS_DEACTIVATED_ALARMS]
		WHERE [SUBSYSTEM]=@subSys AND [EQUIPMENT_ID]=@equpID AND [ALARM_TYPE]=@almType;
END
GO



-- ****** Object:  Trigger [INSERT_CCTV_MDS_SPOT_COMMANDS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_CCTV_MDS_SPOT_COMMANDS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_CCTV_MDS_SPOT_COMMANDS]...'
	DROP TRIGGER [INSERT_CCTV_MDS_SPOT_COMMANDS]
END
PRINT 'INFO: Creating trigger [INSERT_CCTV_MDS_SPOT_COMMANDS]...'
GO
CREATE TRIGGER [INSERT_CCTV_MDS_SPOT_COMMANDS] ON [dbo].[CCTV_MDS_SPOT_COMMANDS]
AFTER INSERT
AS
BEGIN
    DECLARE @cctvDevType [varchar](4), @cctvDevID [varchar](4), @cctvPosID [varchar](2);
	SELECT @cctvDevType = [CCTV_DEVICE_TYPE],@cctvDevID = [CCTV_DEVICE_ID],
			@cctvPosID = [CCTV_CAMERA_POSITION_ID]
		FROM INSERTED;

	-- 1. copy new inserted normalized alarm data into another table 
	--    [CCTV_MDS_OUTGOING_ALARMS] for forwarding it to CCTV server;
	INSERT INTO [dbo].[CCTV_MDS_OUTGOING_ALARMS] (
				[ACTION],[TIME_STAMP],
				[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID])
		SELECT 'SPOT',GETDATE(),
				[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID]
		FROM INSERTED;
		
	-- 2) delete all records from current table ([CCTV_MDS_SPOT_COMMANDS]).
	DELETE FROM [dbo].[CCTV_MDS_SPOT_COMMANDS]
		WHERE [CCTV_DEVICE_TYPE]=@cctvDevType AND 
				[CCTV_DEVICE_ID]=@cctvDevID AND 
				[CCTV_CAMERA_POSITION_ID]=@cctvPosID;
END
GO



-- ****** Object:  Trigger [INSERT_CCTV_DEACTIVATED_ALARMS]    Script Date: 01/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[INSERT_CCTV_DEACTIVATED_ALARMS]'))
BEGIN
	PRINT 'INFO: Deleting existing trigger [INSERT_CCTV_DEACTIVATED_ALARMS]...'
	DROP TRIGGER [INSERT_CCTV_DEACTIVATED_ALARMS]
END
PRINT 'INFO: Creating trigger [INSERT_CCTV_DEACTIVATED_ALARMS]...'
GO
CREATE TRIGGER [INSERT_CCTV_DEACTIVATED_ALARMS] ON [dbo].[CCTV_DEACTIVATED_ALARMS]
AFTER INSERT
AS
BEGIN
    DECLARE @cctvDevID [varchar](4);
    DECLARE @cctvStatusCode [varchar](6);
	SELECT @cctvDevID = [CCTV_DEVICE_ID], @cctvStatusCode = [CCTV_STATUS_CODE] FROM INSERTED;

	-- 1) delete all normalized CCTV alarm records from [CCTV_STATUS] table;
	DELETE FROM [dbo].[CCTV_STATUS] WHERE [CCTV_DEVICE_ID]=@cctvDevID AND [CCTV_STATUS_CODE]=@cctvStatusCode;
		
	-- 2) delete all records from current table ([CCTV_DEACTIVATED_ALARMS]).
	DELETE FROM [dbo].[CCTV_DEACTIVATED_ALARMS] WHERE [CCTV_DEVICE_ID]=@cctvDevID AND [CCTV_STATUS_CODE]=@cctvStatusCode;
END
GO



PRINT 'INFO: End of Creating New Triggers.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: End of STEP 5.1'
GO
