-- ##########################################################################
-- Release#:    R1.0
-- Release On:  20 Aug 2009
-- Filename:    3.3.MDS_InsertINIDate.sql
-- Description: SQL Scripts of Inserting initial data into MDS related tables.
--    Tables in which the initial data need to be inserted:
--    01. [MDS_MAINTENANCE_STATUS]
--    02. [REPORT_FAULT_TYPES]
--    03. [REPORT_FAULT]
--    04. [MDS_BAG_COUNTERS]
--
-- Histories:
--				R1.0 - Released on 20 Aug 2009.
-- ##########################################################################


USE [BHSDB]
GO


PRINT 'INFO: STEP 3.3 - Insert initial data into MDS related tables.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Deleting Existing Initial Data...'
GO

/* ################################################################################################### */
/* STEP 1: Delect existing records */ 
DELETE FROM [dbo].[MDS_MAINTENANCE_STATUS]
DELETE FROM [dbo].[REPORT_FAULT]
DELETE FROM [dbo].[REPORT_FAULT_TYPES]
DELETE FROM [dbo].[MDS_BAG_COUNTERS]

PRINT 'INFO: End of Deleting Existing Initial Data.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Insert New Initial Data...'
GO


/* Insert data into table [MDS_MAINTENANCE_STATUS] */
PRINT 'INFO: Inserting initial records into table [MDS_MAINTENANCE_STATUS]...'
----TC1-GROUP
--INSERT INTO [dbo].[MDS_MAINTENANCE_STATUS] ([TIME_STAMP], [SUBSYSTEM], [EQUIP_ID], [PLC_ZONE], [CURRENT_VALUE], [TOTAL_VALUE], [UNIT],[IFIX_NODE]) 
--		VALUES (GETDATE(),'TC1','TC1-01','PLC0102','0','0','Hours',NULL)

GO



/* Insert data into table [REPORT_FAULT_TYPES] */
PRINT 'INFO: Inserting initial records into table [REPORT_FAULT_TYPES]...'
INSERT INTO [dbo].[REPORT_FAULT_TYPES] ([FAULT_TYPE],[DESCRIPTION]) VALUES ('ALARM', 'MDS ALARM')
INSERT INTO [dbo].[REPORT_FAULT_TYPES] ([FAULT_TYPE],[DESCRIPTION]) VALUES ('TEXT', 'MDS MESSAGE')
INSERT INTO [dbo].[REPORT_FAULT_TYPES] ([FAULT_TYPE],[DESCRIPTION]) VALUES ('EVENT', 'MDS EVENT')
INSERT INTO [dbo].[REPORT_FAULT_TYPES] ([FAULT_TYPE],[DESCRIPTION]) VALUES ('SYSTEM', 'iFIX System Message')
INSERT INTO [dbo].[REPORT_FAULT_TYPES] ([FAULT_TYPE],[DESCRIPTION]) VALUES ('OPERATOR', 'Code or Operator write to tag')


/* Insert data into table [REPORT_FAULT] */
PRINT 'INFO: Inserting initial records into table [REPORT_FAULT]...'
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ACEN' ,'Security Access Control Status' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_AFILE' ,'iFIX Alarm File Service' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_AODBC' ,'iFIX Alarm ODBC Service' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_APTR1' ,'iFIX Alarm Printer 1 Service' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ASUMM' ,'iFIX Alarm Summary Service' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ARAL' ,'Automatic Tag Reader Alarm' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ASIF' ,'ASI Module Fault' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_AUDI' ,'Security - User Log In/Out' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BCNT' ,'Bag Count Information' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BHS' ,'Baggage Handling System' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BJAM' ,'Bag Jam/Photo Eye Fault' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BOVD' ,'Bag Over Width' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BOVH' ,'Bag Over Height' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BOVL' ,'Bag Over Length' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BOVS' ,'Bag Over Size' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BOVW' ,'Bag Over Weight' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_BPRE' ,'Bag Present' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMEN' ,'Command - Enable/Disable' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMGN' ,'Command - General Command' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMHB' ,'Command - Heart Beat' , 'TEXT', 0, 0,0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMMR' ,'Command - Manual Run' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMOR' ,'Command - Override' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMPO' ,'Command - Position Control (Up/Down/Retract/Extend/...)' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMPU' ,'Command - Pusher Control (Push All, Push None/...)' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMRS' ,'Command - Maintenance Status Reset' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMXR' ,'Command - X-Ray Machine (Start/Stop/...)' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CMZO' ,'Command - Zone(Start/Stop/Fault Reset/...)' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CNET' ,'CNET Module Fault' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CNFT' ,'Motor Contactor Fault' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CPAL' ,'Control Panel Alarm' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_CVOR' ,'Override' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_DACT' ,'Check-In Desk In Service/Not In Service' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_DIRN' ,'Motor Direction' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ELCB' ,'ELCB Trip' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ENFT' ,'Encoder Sensor Fault' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ENUS' ,'Encoder Under Speed' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_EQMS' ,'Maintenance Limit Exceeded' , 'ALARM', 1, 1, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_EQSS' ,'Status - Equipment' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ESTP' ,'Emergency Stop' , 'ALARM', 0, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_FDTR' ,'Power Feeder Trip' , 'ALARM', 1, 1, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_FIRE' ,'Fire Alarm' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_FSAL' ,'Security Fail Safe Alarm' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_FULL' ,'Conveyor/Chute Full' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_GNAL' ,'General Alarm' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_GNSS' ,'Status - General' , 'TEXT', 0, 0, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_HBSG' ,'PLC Heart Beat Signal' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_ISOF' ,'Motor Isolator Off' , 'ALARM', 0, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_IVFT' ,'Motor Inverter Fault' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_LFAL' ,'Lifter Alarm' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_MBTR' ,'MCCB Trip' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_MSBJ' ,'Miss Bag Jam' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_MTOH' ,'Motor Over Heat' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_MTRN' ,'Motor Run' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_MTTR' ,'Motor Overload Trip' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_NDAL' ,'Network Device Alarm' , 'ALARM', 1, 1, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_NIPS' ,'Not In Position' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_OMSG' ,'Operator Message' , 'OPERATOR', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_OMSS' ,'Status - Operation Mode' , 'TEXT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_PHFL' ,'Three Phases Failure' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_PSET' ,'Setup - Parameter Settings Change' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_POSS' ,'Status - Position (Extend/Retract...)' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_REMD' ,'Reminder Message' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_SALM' ,'Security Alarm' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_SDAL' ,'Shutter Door Alarm' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_SNRD' ,'Motor Starter Not Ready' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_SNSS' ,'Status - Photo Eye On/Off' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_SSFT' ,'Soft Starter Fault' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_TVAL' ,'CCTV Alarms' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_TVEV' ,'CCTV Events' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_VLAL' ,'Vertilator Alarm' , 'ALARM', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_UNAV' ,'Equipment Unavailable' , 'EVENT', 0, 0, 0, current_timestamp,NULL);
INSERT INTO [dbo].[REPORT_FAULT] (FAULT_NAME, FAULT_DESCRIPTION, FAULT_TYPE, FAULT_USED, MDS_USED, CCTV_USED, TIME_STAMP, HELP_ID) VALUES ('AA_XMAL' ,'X-Ray Machine Alarm' , 'ALARM', 1, 1, 1, current_timestamp,NULL);
GO

/* Insert data into table [MDS_MDS_BAG_COUNTERS] */
PRINT 'INFO: Inserting initial records into table [MDS_BAG_COUNTERS]...'

--INSERT INTO [dbo].[MDS_BAG_COUNTERS] ([COUNTER_ID], [SUBSYSTEM], [LOCATION], [PLC_ZONE], [DESCRIPTION]) 
--		VALUES ('DIVP_TC1-15A','TC1','TC1-15A',NULL,'Passes Through Bags')


GO

PRINT 'INFO: End of Insert New Initial Data.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: End of STEP 3.3'
