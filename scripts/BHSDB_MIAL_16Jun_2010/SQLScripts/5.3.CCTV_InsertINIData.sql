-- ##########################################################################
-- Release#:    R1.0
-- Release On:  20 Aug 2009
-- Filename:    5.3.CCTV_InsertINIData.sql
-- Description: SQL Scripts of Inserting initial data into MDS-CCTV interface related tables.
--
--    Initiate records will be inserted into following tables:
--    01. [CCTV_MDS_OUTGOING_ALARM_ACTIONS]
--    02. [CCTV_STATUS_TYPES]
--    03. [CCTV_DEVICE_TYPES]
--    04. [CCTV_EQUIPMENT_MAPPING]

--
-- Histories:
--				R1.0 - Released on 20 Aug 2009.
-- ##########################################################################


USE [BHSDB]
GO


PRINT 'INFO: STEP 5.3 - Insert initial data into MDS-CCTV interface related tables.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Deleting Existing Initial Data...'
GO

/* ################################################################################################### */
/* STEP 1: Delect existing records */ 
DELETE FROM [dbo].[CCTV_MDS_OUTGOING_ALARMS]
DELETE FROM [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS]
DELETE FROM [dbo].[CCTV_STATUS]
DELETE FROM [dbo].[CCTV_STATUS_TYPES]
DELETE FROM [dbo].[CCTV_MDS_ACTIVATED_ALARMS]
DELETE FROM [dbo].[CCTV_MDS_DEACTIVATED_ALARMS]
DELETE FROM [dbo].[CCTV_MDS_SPOT_COMMANDS]
DELETE FROM [dbo].[CCTV_DEVICE_TYPES]
DELETE FROM [dbo].[CCTV_STATUS_CODES]


PRINT 'INFO: End of Deleting Existing Initial Data.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Insert New Initial Data...'
GO


/* Insert data into table [CCTV_MDS_OUTGOING_ALARM_ACTIONS] */
PRINT 'INFO: Inserting initial records into table [CCTV_MDS_OUTGOING_ALARM_ACTIONS]...'
INSERT INTO [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS] ([ACTION],[DESCRIPTION]) VALUES ('ACTIVATED','Alarm Activated message')
INSERT INTO [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS] ([ACTION],[DESCRIPTION]) VALUES ('DEACTIVATED','Alarm Deactivated message')
INSERT INTO [dbo].[CCTV_MDS_OUTGOING_ALARM_ACTIONS] ([ACTION],[DESCRIPTION]) VALUES ('SPOT','MDS spot display command message')

GO
/* Insert data into table [CCTV_STATUS_TYPES] */
PRINT 'INFO: Inserting initial records into table [CCTV_STATUS_TYPES]...'
INSERT INTO [dbo].[CCTV_STATUS_TYPES] ([TYPE],[DESCRIPTION]) VALUES ('ALARM','CCTV equipment fault')
INSERT INTO [dbo].[CCTV_STATUS_TYPES] ([TYPE],[DESCRIPTION]) VALUES ('EVENT','CCTV event')

GO
/* Insert data into table [CCTV_STATUS_CODES] */
PRINT 'INFO: Inserting initial records into table [CCTV_STATUS_CODES]...'
INSERT INTO [dbo].[CCTV_STATUS_CODES] ([CODE],[IS_AUTO_RESET],[DESCRIPTION]) VALUES ('NVRCPU',0,'CCTV NVR CPU Usage Exceed Limit')
INSERT INTO [dbo].[CCTV_STATUS_CODES] ([CODE],[IS_AUTO_RESET],[DESCRIPTION]) VALUES ('NVRMEM',0,'CCTV NVR Memory Usage Exceed Limit')
INSERT INTO [dbo].[CCTV_STATUS_CODES] ([CODE],[IS_AUTO_RESET],[DESCRIPTION]) VALUES ('NVRDSK',1,'CCTV NVR out of Disk Space')
INSERT INTO [dbo].[CCTV_STATUS_CODES] ([CODE],[IS_AUTO_RESET],[DESCRIPTION]) VALUES ('NVRARC',1,'CCTV NVR Archive Fail')
INSERT INTO [dbo].[CCTV_STATUS_CODES] ([CODE],[IS_AUTO_RESET],[DESCRIPTION]) VALUES ('CAMSGN',0,'CCTV Camera Signal Lost (Connection Fail)')

GO
/* Insert data into table [CCTV_DEVICE_TYPES] */
PRINT 'INFO: Inserting initial records into table [CCTV_DEVICE_TYPES]...'
INSERT INTO [dbo].[CCTV_DEVICE_TYPES] ([TYPE],[DESCRIPTION]) VALUES ('CAM','CCTV camera')

GO
/* Insert data into table [CCTV_EQUIPMENT_MAPPING] */
PRINT 'INFO: Inserting initial records into table [CCTV_EQUIPMENT_MAPPING]...'
--INSERT INTO [dbo].[CCTV_EQUIPMENT_MAPPING] ([CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID],[CCTV_DEVICE_TYPE],[SUBSYSTEM],[EQUIPMENT_ID]) VALUES ('CCTV-B1','1','CAM','CT01','CT01-01')
--INSERT INTO [dbo].[CCTV_EQUIPMENT_MAPPING] ([CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID],[CCTV_DEVICE_TYPE],[SUBSYSTEM],[EQUIPMENT_ID]) VALUES ('CCTV-B1','2','CAM','CT01','CT01-02')

GO




PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: End of STEP 5.3'
