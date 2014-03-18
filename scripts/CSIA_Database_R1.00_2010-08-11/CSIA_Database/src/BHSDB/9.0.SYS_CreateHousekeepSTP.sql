-- ##########################################################################
-- Release#:    R1.0
-- Release On:  15 Mar 2010
-- Filename:    9.0.SYS_CreateHousekeepSTP.sql
-- Description: SQL Scripts of creating DB housekeeping StoredProcedures.
--
--    Following StoredProcedures will be created:
--    01. [stp_DBHousekeeping] - The number of records in the following tables will be kept increasing 
--                            during the BHS production. Hence, the housekeeping task is required on 
--                            these tables:
--                            
--                            Type 1 working data tables. Data will be kept in the table for 14~30 days:
--                            [BAG_SORTING]
--                            [FLIGHT_PLAN_SORTING]
--                            [FLIGHT_PLAN_ALLOC]
--                            
--                            Type 2 working data tables. Data will be kept in the table for 3 days:
--                            [BAG_INFO]
--                            [MDSDATA]
--                            
--                            Historical data logging table. Data will be kept in the table for 30~365 days:
--                            [AUDIT_LOG]
--                            [BAGS]
--                            [BAG_ERROR_BSM]
--							  [BAGGAGE_MEASURE_ARRAY_MSG]
--							  [FALLBACK_TAG_INFO]
--                            [FLIGHT_PLANS]
--                            [FLIGHT_PLAN_ERROR]
--                            [GID_USED]
--                            [FUNCTION_ALLOC_GANTT]
--							  [ITEM_CUSTOMS_SCREENED]
--                            [ITEM_DEST_REQUEST]
--                            [ITEM_ENCODED]
--                            [ITEM_ENCODING_REQUEST]
--                            [ITEM_LOST]
--							  [ITEM_MINIMUM_SECURITY_LEVEL]
--                            [ITEM_PROCEEDED]
--                            [ITEM_READY]
--                            [ITEM_REDIRECT]
--                            [ITEM_REMOVED]
--                            [ITEM_SCANNED]
--                            [ITEM_SCREENED]
--                            [ITEM_SORTATION_EVENT]
--                            [ITEM_TRACKING]
--							  [MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]
--                            [MES_EVENT]
--                            [MDS_ALARMS]
--                            [MDS_LOGS]
--                            [MDS_MAINTENANCE_STATUS]
--							  [MDS_EVENTS]
--							  [MDS_BAG_COUNT]
--							  [MDS_AUDIT_LOGS]
--							  [MDS_HBS_DATA]
--                            
--                            There are two integer parameters need to be passed to StoredProcedure:
--                            @LifeTime_WT - the # of days that the records can be kept in the Working data tables;
--                            				 valid range (3days ~ 14days);
--                            @LifeTime_HT - the # of days that the records can be kept in the Historical data tables;
--                            				 valid range (14days ~ 365days);
--                            
--                            Note: Data in the table [MDSDATA] older than 1 day will be purged.
--                            
--
-- Histories:
--    R1.0 - Released on 15 Mar 2010.
--
-- Remarks:
--
-- ##########################################################################




PRINT 'INFO: STEP 9.0 - Create Stored Procedures for DB housekeeping.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
USE [BHSDB]
GO



-- ****** Object:  StoredProcedure [dbo].[stp_DBHousekeeping]    Script Date: 10/11/2007 13:18:36 ******
/******************************************************************************************************
The number of records in the following tables will be kept increasing during the BHS production. Hence,
the housekeeping task is required on these tables:
-- Type 1 working data tables. Data will be kept in the table for 14~30 days:
[BAG_SORTING]
[FLIGHT_PLAN_SORTING]
[FLIGHT_PLAN_ALLOC]

-- Type 2 working data tables. Data will be kept in the table for 3 days:
[BAG_INFO]
[MDSDATA]

-- Historical data logging table. Data will be kept in the table for 30~365 days:
[AUDIT_LOG]
[BAGS]
[BAG_ERROR_BSM]
[BAGGAGE_MEASURE_ARRAY_MSG]
[FALLBACK_TAG_INFO]
[FLIGHT_PLANS]
[FLIGHT_PLAN_ERROR]
[GID_USED]
[FUNCTION_ALLOC_GANTT]
[ITEM_CUSTOMS_SCREENED]
[ITEM_DEST_REQUEST]
[ITEM_ENCODED]
[ITEM_ENCODING_REQUEST]
[ITEM_LOST]
[ITEM_MINIMUM_SECURITY_LEVEL]
[ITEM_PROCEEDED]
[ITEM_READY]
[ITEM_REDIRECT]
[ITEM_REMOVED]
[ITEM_SCANNED]
[ITEM_SCREENED]
[ITEM_SORTATION_EVENT]
[ITEM_TRACKING]
[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]
[MES_EVENT]
[MDS_ALARMS]
[MDS_LOGS]
[MDS_BAG_COUNT]
[MDS_EVENTS]
[MDS_AUDIT_LOGS]
[MDS_HBS_DATA]


There are two integer parameters need to be passed to StoredProcedure:
@LifeTime_WT -	the # of days that the records can be kept in the Working data tables;
				valid range (3days ~ 14days);
@LifeTime_HT -	the # of days that the records can be kept in the Historical data tables;
				valid range (14days ~ 365days);

Note: Data in the table [MDSDATA] older than 1 day will be purged.
******************************************************************************************************/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_DBHousekeeping]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_DBHousekeeping]...'
	DROP PROCEDURE [dbo].[stp_DBHousekeeping]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_DBHousekeeping]...'
GO
CREATE PROCEDURE [dbo].[stp_DBHousekeeping] 
	@LifeTime_WT [int],
	@LifeTime_HT [int]
AS
BEGIN
	-- The minimum last 14 days data can be stored in the working data table 1
	IF @LifeTime_WT < 14 
	BEGIN
		SET @LifeTime_WT = 14
	END

	IF @LifeTime_WT > 30 
	BEGIN
		SET @LifeTime_WT = 30
	END

	-- The minimum last 30 days data can be stored in the historical data table
	IF @LifeTime_HT < 30 
	BEGIN
		SET @LifeTime_HT = 30
	END

	IF @LifeTime_HT > 365 
	BEGIN
		SET @LifeTime_HT = 365
	END

	-- Purge Type 1 working data tables. Data will be kept in the table for 14~30 days:
	PRINT 'INFO: ' + CAST(GETDATE() AS char)
	PRINT 'INFO: Purge records older than ' + LTRIM(STR(@LifeTime_WT)) + ' days from working data tables'

	PRINT 'INFO: Purging working data table [BAG_SORTING]...'
	DELETE FROM [dbo].[BAG_SORTING] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_WT), GETDATE())
	PRINT 'INFO: Purging working data table [FLIGHT_PLAN_SORTING]...'
	DELETE FROM [dbo].[FLIGHT_PLAN_SORTING] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_WT), GETDATE())
	PRINT 'INFO: Purging working data table [FLIGHT_PLAN_ALLOC]...'
	DELETE FROM [dbo].[FLIGHT_PLAN_ALLOC] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_WT), GETDATE())

	-- Purge Type 2 working data tables. Data will be kept in the table for 3 days:
	PRINT 'INFO: Purging working data table [BAG_INFO]...'
	DELETE FROM [dbo].[BAG_INFO] WHERE [TIME_STAMP] < DATEADD(day, -3, GETDATE())
	PRINT 'INFO: Purging working data table [MDS_DATA]...'
	DELETE FROM [dbo].[MDS_DATA] WHERE [ALM_NATIVETIMEIN] < DATEADD(day, -3, GETDATE())

	-- Purge Historical data logging table. Data will be kept in the table for 30~365 days:
	PRINT 'INFO: Purge records older than ' + LTRIM(STR(@LifeTime_HT)) + ' days from historical data tables'

	PRINT 'INFO: Purging historical data table [AUDIT_LOG]...'
	DELETE FROM [dbo].[AUDIT_LOG] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [BAGS]...'
	DELETE FROM [dbo].[BAGS] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [BAG_ERROR_BSM]...'
	DELETE FROM [dbo].[BAG_ERROR_BSM] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [BAGGAGE_MEASURE_ARRAY_MSG]...'
	DELETE FROM [dbo].[BAGGAGE_MEASURE_ARRAY_MSG] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())	
	PRINT 'INFO: Purging historical data table [FALLBACK_TAG_INFO]...'
	DELETE FROM [dbo].[FALLBACK_TAG_INFO] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())		
	PRINT 'INFO: Purging historical data table [FLIGHT_PLANS]...'
	DELETE FROM [dbo].[FLIGHT_PLANS] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [FLIGHT_PLAN_ERROR]...'
	DELETE FROM [dbo].[FLIGHT_PLAN_ERROR] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [GID_USED]...'
	DELETE FROM [dbo].[GID_USED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [FUNCTION_ALLOC_GANTT]...'
	DELETE FROM [dbo].[FUNCTION_ALLOC_GANTT] 
		WHERE ([TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())) AND ([IS_CLOSED] = 1)

	PRINT 'INFO: Purging historical data table [ITEM_CUSTOMS_SCREENED]...'
	DELETE FROM [dbo].[ITEM_CUSTOMS_SCREENED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_DEST_REQUEST]...'
	DELETE FROM [dbo].[ITEM_DEST_REQUEST] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_ENCODED]...'
	DELETE FROM [dbo].[ITEM_ENCODED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())	
	PRINT 'INFO: Purging historical data table [ITEM_ENCODING_REQUEST]...'
	DELETE FROM [dbo].[ITEM_ENCODING_REQUEST] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_LOST]...'
	DELETE FROM [dbo].[ITEM_LOST] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_MINIMUM_SECURITY_LEVEL]...'
	DELETE FROM [dbo].[ITEM_MINIMUM_SECURITY_LEVEL] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())	
	PRINT 'INFO: Purging historical data table [ITEM_PROCEEDED]...'
	DELETE FROM [dbo].[ITEM_PROCEEDED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_READY]...'
	DELETE FROM [dbo].[ITEM_READY] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_REDIRECT]...'
	DELETE FROM [dbo].[ITEM_REDIRECT] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_REMOVED]...'
	DELETE FROM [dbo].[ITEM_REMOVED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_SCANNED]...'
	DELETE FROM [dbo].[ITEM_SCANNED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_SCREENED]...'
	DELETE FROM [dbo].[ITEM_SCREENED] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_SORTATION_EVENT]...'
	DELETE FROM [dbo].[ITEM_SORTATION_EVENT] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [ITEM_TRACKING]...'
	DELETE FROM [dbo].[ITEM_TRACKING] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST]...'
	DELETE FROM [dbo].[MAKEUP_CAROUSEL_CHUTE_MAPPING_LIST] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	
	PRINT 'INFO: Purging historical data table [MES_EVENT]...'
	DELETE FROM [dbo].[MES_EVENT] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MDS_ALARMS]...'
	DELETE FROM [dbo].[MDS_ALARMS] WHERE [ALM_NATIVETIMEIN] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MDS_LOGS]...'
	DELETE FROM [dbo].[MDS_LOGS] WHERE [ALM_NATIVETIMEIN] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MDS_EVENTS]...'
	DELETE FROM [dbo].[MDS_EVENTS] WHERE [ALM_NATIVETIMEIN] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MDS_BAG_COUNT]...'
	DELETE FROM [dbo].[MDS_BAG_COUNT] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MDS_AUDIT_LOGS]...'
	DELETE FROM [dbo].[MDS_AUDIT_LOGS] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	PRINT 'INFO: Purging historical data table [MDS_HBS_DATA]...'
	DELETE FROM [dbo].[MDS_HBS_DATA] WHERE [TIME_STAMP] < DATEADD(day, -(@LifeTime_HT), GETDATE())
	
END
GO






PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: End of STEP 9.0'
GO