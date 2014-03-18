-- ##########################################################################
-- Release#:    R1.00
-- Release On:  18 May 2009
-- Filename:    Step2.2.SAC_CreateSTP.sql
-- Description: SQL Scripts of creating StoredProcedures.
--    StoredProcedures to be created by this script:
--    01. [stp_SAC_GIDUSED] - Invoked by SortEngine service application upon GID Used message is received.
--                            1. Insert new or update existing GID info of received GID# into 
--                               working data table [BAG_INFO] for further sortation control;
--                            2. Insert new record into historical data table [GID_USED] for reporting;
--    02. [stp_SAC_ITEMSCREENED]
--    03. [stp_SAC_ITEMSCANNED] - Invoked by SortEngine service application upon Item Scanned message is received.
--                            1. Insert new record into historical data table [ITEM_SCANNED] for reporting;
--                            2. Insert new or update existing GID info of received GID# into 
--                               working data table [BAG_INFO] for further sortation control;
--                            3. The Recirculation count may be increased and updated into table [BAG_INFO];
--                            4. The value of Recirculation count, L1, 2, & 3 HBS result will 
--                               also be returned by this StoredProcedure.
--    04. [stp_SAC_ITEMSORTATIONEVENT]
--    05. [stp_SAC_ITEMPROCEEDED] - Invoked by SortEngine service application upon Item Proceeded message is received.
--                            1. Insert new record into historical data table [ITEM_PROCEEDED] for reporting;
--    06. [stp_SAC_ITEMLOST] - Invoked by SortEngine service application upon Item Lost message is received.
--                            1. Insert new record into historical data table [ITEM_LOST] for reporting;
--    07. [stp_SAC_ITEMREMOVED] - Invoked by SortEngine service application upon Item Lost message is received.
--                            1. Insert new record into historical data table [ITEM_REMOVED] for reporting;
--    08. [stp_SAC_ITEMREDIRECT] - Invoked by SortEngine service application upon sending IRD message to PLC.
--                            1. Insert new record into historical data table [ITEM_REDIRECT] for reporting;
--    09. [stp_SAC_DESTINATIONREQUEST] - Invoked by SortEngine service application upon Item Destination 
--                               Request message is received.
--                            1. Insert new record into historical data table [ITEM_SCANNED] for reporting;
--                            2. Insert new or update existing GID info of received GID# into 
--                               working data table [BAG_INFO] for further sortation control;
--                            3. The value of L1, 2, & 3 HBS result will also be returned by this StoredProcedure.
--    10. [stp_SAC_ITEMENCODINGREQUEST] - Invoked by SortEngine service application upon Item Manual Encoding 
--                               Request message is received.
--                            1. Insert new record into historical data table [ITEM_ENCODING_REQUEST] for reporting;
--                            2. Insert new or update existing GID info of received GID# into 
--                               working data table [BAG_INFO] for further sortation control;
--                            3. The value of L1, 2, & 3 HBS result will also be returned by this StoredProcedure.
--    11. [stp_SAC_GETSACPUBLICPARAMETERS]
--    12. [stp_SAC_GETROUTINGTABLE]
--    13. [stp_SAC_GETFUNCALLOCATION]
--    14. [stp_SAC_GETFLIGHTALLOCOFLP]
--    15. [stp_SAC_GETFLIGHTALLOCOFFLT]
--    16. [stp_SAC_GETFLIGHTALLOCATION]
--    17. [stp_SAC_LPVALIDATION] - Check whether the BSM of both specific license plate numbers have been 
--                            received or not.
--                            Please be noted that there may be multiple records of single license plate# 
--                            in the [BAG_SORTING] table due to the multiple BSMs of the same bag were 
--                            received from BSI.
--    18. [stp_SAC_GETAIRLINEALLOCATION]
--    19. [stp_SAC_GETFALLBACKTAGDISCHARGE]
--    20. [stp_SAC_ALLOCATIONLISTSBYDATE]
--    21. [stp_SAC_ALLOCATIONLISTSBYMONTH]
--    22. [stp_SAC_CHANGEDISCHARGEOFOPENALLOC]
--    23. [stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]
--    24. [stp_SAC_MANUALCLOSEFLIGHTALLOC]
--    25. [stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]
--    26. [stp_SAC_UPDATELOCALSTATIONALIVESTATUS]
--    27. [stp_SAC_CHUTEAVAILABLECHECK]
--    28. [stp_SAC_ITEMTRACKING] - Invoked by SortEngine service application upon Item Tracking Information message is received.
--                            1. Insert new record into historical data table [ITEM_TRACKING] for reporting;
--    29. [stp_SAC_CHUTESTATUSREPLY] - Invoked by SortEngine service application upon Chute Status Reply message is received.
--                            1. Insert new record into data table [DESTINATIONS] for reporting;
--    30. [stp_SAC_BAGMONITORING]
--    31. [stp_SAC_FLIGHTMONITORING]
--    32. [stp_SAC_FIDSBISTIMESTAMPMonitor]
--	  33. [stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED] - Use for FISENGN to insert data when received DFCU.
--	  34. [stp_FIS_ERRORMESSAGE] - Use for FISENGN to insert error data when received DFCU, DFDL.
--	  35. [stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED] - Use for FISENGN to insert error data when received DFDL.
--	  36. [stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED] - Use for FISENGN to insert historical data when send FADL to FIS.
--	  37. [stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY] - Use for FISENGN to insert historical data when send FARL to FIS.
--	  38. [stp_FIS_DEPARTUREFUNCTIONALLOCATIONDELETED] - Use for FISENGN to insert historical data when send FUDL to FIS.
--	  39. [stp_FIS_DEPARTUREFUNCTIONALLOCATIONREPLY] - Use for FISENGN to insert historical data when send FURL to FIS.
--	  40. [stp_FIS_GETBHSFISOUTGOINGALLOCATIONS] - Use for FISENGN to get data when send FARL/FADL/FURL/FUDL to FIS.
--	  41. [stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY] - Use for FISENGN to get data when send FARL to FIS.
--	  42. [stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY] - Use for FISENGN to get data when send FURL to FIS.
--	  43. [stp_UPDATECHANGEDCONNECTIONMONITORING] - Use for update the connection status into [APP_LIVE_MONITORING].
--	  44. [stp_BSI_ERRORMESSAGE] - Use for BSIENGN to insert error data when received error BSM.
--	  45. [stp_BSI_INSERTBSM] - Use for BSIENGN to insert BSM data when received BSM.
--	  46. [stp_BSI_MULTIPLEBSMCOUNT] - Use for BSIENGN to count how many same BSM with when received BSM.
--	  47. [stp_BSI_GETBPMDATA] - Use for BSIENGN to collect all related information for contruct BPM.
--	  48. [stp_BSI_ENCAPSULATEDBPM] - Use for BSIENGN to log contructed BPM which send to gateway.
--	  49. [stp_BSI_BSMRAWDATA] - Use for BSIENGN to log raw data for BSM which received from gateway.
--	  50. [stp_FIS_RAWDATA] - Use for FISENGN to log raw data for FIS which received from gateway.
--
--    Functions to be created by this script:
--    01. [SAC_HOURMINUTECOMPARATOR]
--    02. [SAC_HOURMINUTEDIFF]
--    03. [SAC_HOURMINUTEMASTER]
--    04. [SAC_OFFSETOPERATOR]
--    05. [SAC_ADDMINUTESTOOFFSET]
--    06. [SAC_MINUTECONVERTER]
--    07. [SAC_OFFSETOPERATOR]
--    08. [SAC_SUBSTRACTMINUTESTOOFFSET]
--   
--
-- Histories:
--    R1.0 - Released on 21 Nov 2007.
--    R1.1 - Released on 11 Dec 2007.
--           * Additional StoredProcedure [stp_RPT_TIMEDISTRIBUTION] is added;
--           * The housekeeping StoredProcedure is updated to purge [MDSDATA]
--             table data older than 1 day.
--           * The housekeeping StoredProcedure is updated to purge [MDS_LOGS]
--             table data older than configurable days.
--           * StoredProcedure [stp_MDS_TOPEQUIPMENT] and [stp_MDS_TOPFAULT] 
--             was upgraded;
--    R1.1.1 - Released on 28 Apr 2008.
--           * Rectify to the Additional StoredProcedure [stp_RPT_TIMEDISTRIBUTION] 
--			   which has some error when run the script by adding "'" to the script
--			   which has "'".
--    R2.0   - Release on 05 Nov 2008.
--           * Add in new StoredProcedures
-- Remarks:
-- ##########################################################################


PRINT 'INFO: STEP5 - Create BHS Solution Database Stored Procedures for Sortation'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
USE [BHSDB]
GO

-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GIDUSED]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GIDUSED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GIDUSED]...'
	DROP PROCEDURE [dbo].[stp_SAC_GIDUSED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GIDUSED]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GIDUSED] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@BagType [varchar](2),
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No = (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @Location, @Origin, GETDATE())
		END
	ELSE
		BEGIN
			UPDATE [BAG_INFO]
			SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END

	-- Step 2: Insert GID Used bag event into event table [GID_USED].
	INSERT INTO [GID_USED] 
		([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [BAG_TYPE]) 
	VALUES 
		(GETDATE(), @GID, @SubSystem, @Location, @BagType)
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMSCREENED]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMSCREENED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMSCREENED]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMSCREENED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMSCREENED]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMSCREENED] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@XrayID [varchar](10), 
	@LicensePlate [varchar](10),
	@Level [varchar](1), 
	@Result [varchar](1),
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert Item Screened bag event into event table [ITEM_SCREENED].
	INSERT INTO [ITEM_SCREENED] 
			([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [XRAY_ID],
			 [LICENSE_PLATE], [SCREEN_LEVEL], [RESULT_TYPE]) 
	VALUES 
			(GETDATE(), @GID, @SubSystem, @Location, @XrayID, @LicensePlate, @Level, @Result)

	-- Step 2: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
	BEGIN
		IF @Level = '1'
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [HBS1_RESULT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Result, @Location, @Origin, GETDATE())
		ELSE IF @Level = '2'
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [HBS2_RESULT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Result, @Location, @Origin, GETDATE())
		ELSE IF @Level = '3'
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [HBS3_RESULT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Result, @Location, @Origin, GETDATE())
		ELSE IF @Level = '4'
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [HBS4_RESULT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Result, @Location, @Origin, GETDATE())
		ELSE IF @Level = '5'
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [HBS5_RESULT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Result, @Location, @Origin, GETDATE())
	END
	ELSE
	BEGIN
		IF @Level = '1'
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate, [HBS1_RESULT]=@Result, 
				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
		ELSE IF @Level = '2'
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate, [HBS2_RESULT]=@Result, 
				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
		ELSE IF @Level = '3'
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate, [HBS3_RESULT]=@Result, 
				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
		ELSE IF @Level = '4'
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate, [HBS4_RESULT]=@Result, 
				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
		ELSE IF @Level = '5'
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate, [HBS5_RESULT]=@Result, 
				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
	END
END
GO



-- =============================================
-- Author:		<Author,,Xu Jian>
-- Create date: <Create Date,,30 Dec 2005>
-- Description:	<Description,,Item Scanned Bag Event Handling>
--				Item current recirculation count value will be returned by 
--				parameter @Recirculates.
--				This stored procedure will be used by Item Scanned telegram 
--				handling process in SortEngine.
-- =============================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMSCANNED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMSCANNED]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMSCANNED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMSCANNED]...'
GO
CREATE PROCEDURE [stp_SAC_ITEMSCANNED] 
	@GID [varchar](10), 
	@SubSystem [varchar](10), 
	@Location [varchar](20), 
	@LicensePlate1 [varchar](10), 
	@LicensePlate2 [varchar](10),
	@ScannerID [varchar](4), 
	@Status [varchar](2),
	@Origin [varchar](10),
	@RecirculationLimit [int],
	@Recirculates [int] = 0 OUTPUT, -- return number of times item has been recirculated.
	@NeedIncrease [varchar](3), -- YES or NOT: recirculating counter needs to be increased by 1; NOT: No need increase
	@HBS1 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@HBS2 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@HBS3 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@Head1 [int],
	@Head2 [int],
	@Head3 [int],
	@Head4 [int],
	@Head5 [int],
	@Head6 [int],
	@Head7 [int],
	@Head8 [int],
	@Head9 [int],
	@Head10 [int],
	@Head11 [int],
	@Head12 [int],
	@Head13 [int],
	@Head14 [int],
	@Head15 [int],
	@Head16 [int],
	@Head17 [int],
	@Head18 [int],
	@Head19 [int],
	@Head20 [int],
	@Destination [varchar](20)
AS
BEGIN
	-- Step 1: Insert Item Screened bag event into event table [ITEM_SCREENED].
	INSERT INTO [ITEM_SCANNED] 
		   ([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [LICENSE_PLATE1], [LICENSE_PLATE2], [SCANNER_ID], [STATUS_TYPE],
			[HEAD01], [HEAD02], [HEAD03], [HEAD04], [HEAD05], [HEAD06], [HEAD07], [HEAD08], [HEAD09], [HEAD10], 
			[HEAD11], [HEAD12], [HEAD13], [HEAD14], [HEAD15], [HEAD16], [HEAD17], [HEAD18], [HEAD19], [HEAD20],[DESTINATION]) 
	VALUES  (GETDATE(), @GID, @SubSystem, @Location, @LicensePlate1, @LicensePlate2, @ScannerID, @Status, 
		   @Head1, @Head2, @Head3, @Head4, @Head5, @Head6, @Head7, @Head8, @Head9, @Head10,
		   @Head11, @Head12, @Head13, @Head14, @Head15, @Head16, @Head17, @Head18, @Head19, @Head20,@Destination)

	-- Step 2: Insert or Update new ISC info into sortation working table [BAG_INFO].
	DECLARE	@ExistGID [varchar](10)
	DECLARE	@NewCount int
	-- [GID] is the primary key, only single record per GID will be stored in this table
	-- If both @ExistGID & @NewCount are NULL, it represents that there is no any record
	-- of this GID# in [BAG_INFO] table. 
	-- If @ExistGID is not NULL, but @NewCount still can be NULL (if record was inserted 
	-- by other bag event.
	SELECT @ExistGID=[GID], @NewCount=[RECYLE_COUNT], 
			@HBS1 = [HBS1_RESULT], @HBS2 = [HBS2_RESULT], @HBS3 = [HBS3_RESULT]
	FROM [BAG_INFO] WHERE ([GID]=@GID)

	IF @ExistGID IS NULL -- No record of this GID in the [BAG_INFO] table
	BEGIN
		IF @Status = '00' -- Good read, Single tag is dectected
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [RECYLE_COUNT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate1, NULL, 0, @Location, @Origin, GETDATE())
		END
		ELSE IF @Status = '02' -- Good read, multiple tags were dectected
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [RECYLE_COUNT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate1, @LicensePlate2, 0, @Location, @Origin, GETDATE())
		END
		ELSE -- 01 - No read, no any tag dectected; 03- Index Error; 04 - no Answer; 05 - Scanner Failure
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [RECYLE_COUNT], 
				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, NULL, NULL, 0, @Location, @Origin, GETDATE())
		END

		SET @Recirculates = 0
		RETURN 0
	END
	ELSE
	BEGIN
		DECLARE @Reset [int]
		
		IF @NeedIncrease = 'YES'
		BEGIN
			SET @Recirculates = ISNULL(@NewCount,0) + 1
		END
		ELSE
		BEGIN
			SET @Recirculates = ISNULL(@NewCount,0)
		END

		-- If item recirculation times reach the limit, it will be redirected
		-- to overflow discharge (e.g. MES). But it could be returned on to 
		-- sorter after manual handling. So the recirculation counter needs to 
		-- be reset after item was redirected to overflow discharge.
		IF @Recirculates > @RecirculationLimit
			SET @Reset = 0
		ELSE
			SET @Reset = @Recirculates		
		
		IF @Status = '00' -- Good read, Single tag dectected
		BEGIN
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate1, [LICENSE_PLATE2]=NULL, 
				[RECYLE_COUNT]=@Reset, [LAST_LOCATION]=@Location, 
				[CREATED_BY]=@Origin, [TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END
		ELSE IF @Status = '02' -- Good read, Multiple tag dectected
		BEGIN
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=@LicensePlate1, [LICENSE_PLATE2]=@LicensePlate2,
				[RECYLE_COUNT]=@Reset, [LAST_LOCATION]=@Location, 
				[CREATED_BY]=@Origin, [TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END
		ELSE -- 01 - No read, no any tag dectected; 03 - Index Error; 04 - No Answer; 05 - Scanner Failure
		BEGIN
			UPDATE [BAG_INFO]
			SET [LICENSE_PLATE1]=NULL, [LICENSE_PLATE2]=NULL, 
				[RECYLE_COUNT]=@Reset, [LAST_LOCATION]=@Location, 
				[CREATED_BY]=@Origin, [TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END		
	END
END
GO
-- =============================================





-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMSCANNED]    Script Date: 10/08/2007 13:18:36 ******
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMSCANNED]') AND type in (N'P', N'PC'))
--BEGIN
--	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMSCANNED]...'
--	DROP PROCEDURE [dbo].[stp_SAC_ITEMSCANNED]
--END
--GO
--PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMSCANNED]...'
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMSCANNED]') AND type in (N'P', N'PC'))
--BEGIN
--EXEC dbo.sp_executesql @statement = N'
--CREATE PROCEDURE [dbo].[stp_SAC_ITEMSCANNED] 
--	@GID [varchar](10), 
--	@SubSystem [varchar](10), 
--	@Location [varchar](20), 
--	@LicensePlate1 [varchar](10), 
--	@LicensePlate2 [varchar](10),
--	@ScannerID [varchar](4), 
--	@Status [varchar](2),
--	@Origin [varchar](10)
--AS
--BEGIN
--	-- Step 1: Insert Item Screened bag event into event table [ITEM_SCREENED].
--	INSERT INTO [ITEM_SCANNED] 
--			([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [LICENSE_PLATE1], 
--			 [LICENSE_PLATE2], [SCANNER_ID], [STATUS_TYPE]) 
--	VALUES (GETDATE(), @GID, @SubSystem, @Location, @LicensePlate1, 
--			 @LicensePlate2, @ScannerID, @Status)

--	-- Step 2: Insert or Update new ISC info into sortation working table [BAG_INFO].
--	DECLARE	@ExistGID [varchar](10)
--	-- [GID] is the primary key, only single record per GID will be in this table
--	-- If @ExistGID is NULL, it represents that there is no any record
--	-- of this GID in [BAG_INFO] table. 
--	SELECT @ExistGID=[GID] FROM [BAG_INFO] WHERE ([GID]=@GID)

--	IF @ExistGID IS NULL -- No record of this GID in the [BAG_INFO] table 
--	BEGIN
--		IF @Status = ''01'' -- Good read, Single tag was dectected.
--		BEGIN
--			INSERT INTO [BAG_INFO] 
--				([GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [RECYLE_COUNT], 
--				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
--			VALUES 
--				(@GID, @LicensePlate1, NULL, NULL, @Location, @Origin, GETDATE())
--		END
--		ELSE IF @Status = ''02'' -- Good read, Multiple tags were dectected.
--		BEGIN
--			INSERT INTO [BAG_INFO] 
--				([GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [RECYLE_COUNT], 
--				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
--			VALUES 
--				(@GID, @LicensePlate1, @LicensePlate2, NULL, @Location, @Origin, GETDATE())
--		END
--		ELSE -- 03 - No read, no any tag dectected; 04 - Scanner Failure.
--		BEGIN
--			INSERT INTO [BAG_INFO] 
--				([GID], [LICENSE_PLATE1], [LICENSE_PLATE2], [RECYLE_COUNT], 
--				 [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
--			VALUES 
--				(@GID, NULL, NULL, NULL, @Location, @Origin, GETDATE())
--		END
--	END
--	ELSE  -- There has been the record of this GID in the [BAG_INFO] table 
--	BEGIN
--		IF @Status = ''01'' -- Good read, Single tag dectected 
--		BEGIN
--			UPDATE [BAG_INFO]
--			SET [LICENSE_PLATE1]=@LicensePlate1, [LICENSE_PLATE2]=NULL, 
--				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
--				[TIME_STAMP]= GETDATE()
--			WHERE [GID]=@GID
--		END
--		ELSE IF @Status = ''02'' -- Good read, Single tag dectected 
--		BEGIN
--			UPDATE [BAG_INFO]
--			SET [LICENSE_PLATE1]=@LicensePlate1, [LICENSE_PLATE2]=@LicensePlate2,
--				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
--				[TIME_STAMP]= GETDATE()
--			WHERE [GID]=@GID
--		END
--		ELSE -- 03 - No read, no any tag dectected; 04 - Scanner Failure 
--		BEGIN
--			UPDATE [BAG_INFO]
--			SET [LICENSE_PLATE1]=NULL, [LICENSE_PLATE2]=NULL, 
--				[LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
--				[TIME_STAMP]= GETDATE()
--			WHERE [GID]=@GID
--		END		
--	END

--	RETURN 0
--END
--' 
--END
--GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMSORTATIONEVENT]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMSORTATIONEVENT]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMSORTATIONEVENT]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMSORTATIONEVENT]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMSORTATIONEVENT]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMSORTATIONEVENT] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@Destination [varchar](20), 
	@LicensePlate [varchar](10), 
	@SortationType [varchar](2),
	@Recirculates [int] = 0 OUTPUT, -- return number of times item has been recirculated.
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Location, @Origin, GETDATE())
		END
	ELSE
		BEGIN
			UPDATE [BAG_INFO]
			SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
		END

	-- Step 2: Insert Item Sortation Event bag event into event table [ITEM_SORTATION].
	INSERT INTO [ITEM_SORTATION_EVENT] 
		([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [SORT_DESTINATION], 
			[LICENSE_PLATE], [SORT_EVENT_TYPE]) 
	VALUES 
		(GETDATE(), @GID, @SubSystem, @Location, @Destination, @LicensePlate, 
			@SortationType)
			
	-- Step 3: Get the Current Recirculation number from [BAG_INFO].
	SELECT @Recirculates=[RECYLE_COUNT] FROM [BAG_INFO] WHERE ([GID]=@GID)
	
	-- Step 4: Update the [DESTINATIONS] table for unavailable of Destination, all the destinations are unavailable for ISE telegram
	UPDATE [DESTINATIONS] SET [IS_AVAILABLE] = 0 WHERE DESTINATION = @Destination	

END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMPROCEEDED]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMPROCEEDED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMPROCEEDED]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMPROCEEDED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMPROCEEDED]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMPROCEEDED] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@ProceededDest [varchar](20), 
	@LicensePlate [varchar](10), 
	@ProceededType [varchar](2),
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Location, @Origin, GETDATE())
		END
	ELSE
		BEGIN
			UPDATE [BAG_INFO]
			SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE() 
			WHERE [GID]=@GID
		END

	-- Step 2: Insert Item Lost bag event into event table [ITEM_PROCEEDED].
	INSERT INTO [ITEM_PROCEEDED] 
		([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [LICENSE_PLATE],
			[PROCEED_LOCATION], [PROCEED_TYPE]) 
	VALUES 
		(GETDATE(), @GID, @SubSystem, @Location, @LicensePlate, 
			@ProceededDest, @ProceededType)
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMLOST]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMLOST]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMLOST]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMLOST]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMLOST]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMLOST] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@LicensePlate [varchar](10),
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Location, @Origin, GETDATE())
		END
	ELSE
		BEGIN
			UPDATE [BAG_INFO]
			SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END

	-- Step 2: Insert Item Lost bag event into event table [ITEM_LOST].
	INSERT INTO [ITEM_LOST] 
		([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [LICENSE_PLATE]) 
	VALUES 
		(GETDATE(), @GID, @SubSystem, @Location, @LicensePlate)
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMREMOVED]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMREMOVED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMREMOVED]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMREMOVED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMREMOVED]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMREMOVED] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@LicensePlate [varchar](10),
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert Item Lost bag event into event table [ITEM_REMOVED].
	INSERT INTO [ITEM_REMOVED] 
		([TIME_STAMP], [GID], [LICENSE_PLATE], [SUBSYSTEM], [LOCATION]) 
	VALUES 
		(GETDATE(), @GID, @LicensePlate, @SubSystem, @Location)

	-- Step 2: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Location, @Origin, GETDATE())
		END
	ELSE
		BEGIN
			UPDATE [BAG_INFO]
			SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END

END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMREDIRECT]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMREDIRECT]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMREDIRECT]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMREDIRECT]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMREDIRECT]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMREDIRECT] 
	@GID [varchar](10), 
	@SubSystem1 [varchar](10), 
	@Location1 [varchar](20), 
	@SubSystem2 [varchar](10), 
	@Location2 [varchar](20), 
	@SubSystem3 [varchar](10), 
	@Location3 [varchar](20), 
	@LicensePlate [varchar](10),
	@Reason [varchar](2)
AS
BEGIN
	-- Step 1: Insert Item Redirect bag event into event table [ITEM_REDIRECT].
	INSERT INTO [ITEM_REDIRECT] 
		([TIME_STAMP], [GID], [SUBSYSTEM1], [LOCATION1], 
			[SUBSYSTEM2], [LOCATION2], [SUBSYSTEM3], [LOCATION3],
			[LICENSE_PLATE], [REASON]) 
	VALUES 
		(GETDATE(), @GID, @SubSystem1, @Location1, @SubSystem2, @Location2, 
			@SubSystem3, @Location3, @LicensePlate, @Reason)
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_DESTINATIONREQUEST]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_DESTINATIONREQUEST]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_DESTINATIONREQUEST]...'
	DROP PROCEDURE [dbo].[stp_SAC_DESTINATIONREQUEST]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_DESTINATIONREQUEST]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_DESTINATIONREQUEST] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@LicensePlate [varchar](10),
	@Origin [varchar](10),
	@HBS1 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@HBS2 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@HBS3 [varchar](1) OUTPUT -- return Level 1 HBS result.
AS
BEGIN
	-- Step 1: Insert Item Lost bag event into event table [ITEM_DEST_REQUEST].
	INSERT INTO [ITEM_DEST_REQUEST] 
		([TIME_STAMP], [GID], [LICENSE_PLATE], [SUBSYSTEM], [LOCATION]) 
	VALUES (GETDATE(), @GID, @LicensePlate, @SubSystem, @Location);

	-- Step 2: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@ExistGID [varchar](10);
	SELECT @ExistGID=[GID], @HBS1 = [HBS1_RESULT], @HBS2 = [HBS2_RESULT], @HBS3 = [HBS3_RESULT]
		FROM [BAG_INFO] WHERE ([GID]=@GID);

	IF @ExistGID IS NULL -- No record of this GID in the [BAG_INFO] table
	BEGIN
		INSERT INTO [BAG_INFO] 
			([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
		VALUES 
			(@GID, @LicensePlate, @Location, @Origin, GETDATE());
	END
	ELSE
	BEGIN
		UPDATE [BAG_INFO]
		SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
			[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE() 
		WHERE [GID]=@GID;
	END
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMENCODINGREQUEST]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMENCODINGREQUEST]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMENCODINGREQUEST]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMENCODINGREQUEST]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMENCODINGREQUEST]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMENCODINGREQUEST] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@LicensePlate [varchar](10),
	@Airline [varchar](3),
	@FlightNumber [varchar](5),
	@SDO [varchar](10),
	@Destination [varchar](20),
	@EncodingType [varchar] (2),
	@Origin [varchar](10),
	@HBS1 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@HBS2 [varchar](1) OUTPUT, -- return Level 1 HBS result.
	@HBS3 [varchar](1) OUTPUT -- return Level 1 HBS result.
AS
BEGIN
	-- Step 1: Insert Item Encoding Request table [ITEM_ENCODING_REQUEST].
	INSERT INTO [ITEM_ENCODING_REQUEST] ([TIME_STAMP], [GID], 
			[SUBSYSTEM], [LOCATION], [LICENSE_PLATE], 
			[AIRLINE], [FLIGHT_NUMBER], [SDO], [DESTINATION], [ENCODING_TYPE]) 
	VALUES (GETDATE(), @GID, @SubSystem, @Location, @LicensePlate, 
			@Airline, @FlightNumber, @SDO, @Destination, @EncodingType);

	-- Step 2: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@ExistGID [varchar](10);
	SELECT @ExistGID=[GID], @HBS1 = [HBS1_RESULT], @HBS2 = [HBS2_RESULT], @HBS3 = [HBS3_RESULT]
		FROM [BAG_INFO] WHERE ([GID]=@GID);

	IF @ExistGID IS NULL -- No record of this GID in the [BAG_INFO] table
	BEGIN
		INSERT INTO [BAG_INFO] 
			([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
		VALUES 
			(@GID, @LicensePlate, @Location, @Origin, GETDATE());
	END
	ELSE
	BEGIN
		UPDATE [BAG_INFO]
		SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
			[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE() 
		WHERE [GID]=@GID;
	END
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETSACPUBLICPARAMETERS]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETSACPUBLICPARAMETERS]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETSACPUBLICPARAMETERS]...'
	DROP PROCEDURE [dbo].[stp_SAC_GETSACPUBLICPARAMETERS]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETSACPUBLICPARAMETERS]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETSACPUBLICPARAMETERS]
AS 
BEGIN
	SELECT 
		[SYS_KEY], [SYS_VALUE]
	FROM 
		[SYS_CONFIG]
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETROUTINGTABLE]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETROUTINGTABLE]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETROUTINGTABLE]...'
	DROP PROCEDURE [dbo].[stp_SAC_GETROUTINGTABLE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETROUTINGTABLE]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETROUTINGTABLE]
AS 
BEGIN
	SELECT 
		[SUBSYSTEM], [LOCATION], [COST]
	FROM 
		[ROUTING_TABLE]
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETFUNCALLOCATION]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETFUNCALLOCATION]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETFUNCALLOCATION]...'
	DROP PROCEDURE [dbo].[stp_SAC_GETFUNCALLOCATION]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETFUNCALLOCATION]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETFUNCALLOCATION]
	@Type [varchar](4),
	@Exception [varchar](10),
	@NeedException bit,
	@Result [int] = 0 OUTPUT
	-- @Result = 0   - Function type is valid. Its allocated destination query result  
	--                 will be returned by this StoredProcedure too;
	-- @Result = -1  - Unknown Function type. No allocated destination query result is 
	--                 returned by this StoredProcedure.
AS 
BEGIN
	DECLARE @Group [varchar](5);

	SELECT @Group=[GROUP] FROM [FUNCTION_TYPES] WHERE [TYPE]=@Type;
	
	IF @Group IS NULL
	BEGIN
		SET @Result = -1;
		RETURN 0;
	END

	IF @Group = 'GANTT'
	BEGIN
		-- Group 1 function type, its allocation data is in the table [FUNCTION_ALLOC_GANTT]
		-- Allocation of Group 1 function types has close time, hence, only allocated 
		-- destinations of un-closed allocation will be returned.
		IF @NeedException = 1
		BEGIN
			SELECT a.[RESOURCE], b.[SUBSYSTEM] 
			FROM [FUNCTION_ALLOC_GANTT] AS a 
				LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
			WHERE (a.[FUNCTION_TYPE] = @Type) AND (a.[IS_CLOSED] = 0) AND (a.EXCEPTION = @Exception);
		END
		ELSE
		BEGIN
			SELECT a.[RESOURCE], b.[SUBSYSTEM] 
			FROM [FUNCTION_ALLOC_GANTT] AS a 
				LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
			WHERE (a.[FUNCTION_TYPE] = @Type) AND (a.[IS_CLOSED] = 0);
		END
		
		SET @Result = 0;
	END
	ELSE
	BEGIN
		-- Group 2 function type, its allocation data is in the table [FUNCTION_ALLOC_LIST]
		-- Allocation of Group 2 function types is permanent setting. Hence, the allocation 
		-- of it will not be closed forever.
		IF @Group = 'LIST'
		BEGIN
			SELECT a.[RESOURCE], b.[SUBSYSTEM] 
			FROM [FUNCTION_ALLOC_LIST] AS a 
				LEFT OUTER JOIN [DESTINATIONS] AS b ON (a.[RESOURCE] = b.[DESTINATION])
			WHERE a.[FUNCTION_TYPE] = @Type;
			
			SET @Result = 0;
		END
	END
	
	RETURN 0;
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETFLIGHTALLOCOFLP]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETFLIGHTALLOCOFLP]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETFLIGHTALLOCOFLP]...'
	DROP PROCEDURE [dbo].[stp_SAC_GETFLIGHTALLOCOFLP]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETFLIGHTALLOCOFLP]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETFLIGHTALLOCOFLP]
	@LicensePlate [varchar](10),
	@BSM_TravelClass [varchar](1) OUTPUT,
	@BSM_Exception [varchar](10) OUTPUT,
	@FLT_HighRisk [varchar](1) OUTPUT,
	@FLT_Exception [varchar](10) OUTPUT,
	@Status [int] = 0 OUTPUT
	-- @Status = 1 (No BSM of specific LP# is in the [BAG_SORTING] table, it is No BSM (NBSM) item)
	-- @Status = 2 (More than one BSMs of specific LP# are in the [BAG_SORTING] table, it is multiple
	--              BSM (MBSM) item)
	-- @Status = 3 (Single BSM of specific LP# is in the [BAG_SORTING] table, but the flight included 
	--				in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
	--				[AIRLINE],[FLIGHT_NUMBER],[SDO] three fields will be returned caller
	--				via returned recordset.
	-- @Status = 4 (Flight is Slave filght, but its master flight info can not be found in the
	--				[FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
	--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
	--				five fields will be returned caller via returned recordset.
	-- @Status = 5 (Flight is Master flight and its flight info can be found in the 
	--              [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
	--				(no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is treated 
	--              as No Allocation Flight.
	--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO] four fields will be returned caller
	--				via returned recordset.
	-- @Status = 6 (Flight is Slave flight, its master flight is valid flight (flight 
	--				info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
	--				no any allocation was created (no allocation recoreds in the table 
	--				[FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
	--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO], [MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
	--				six fields will be returned caller via returned recordset.
	-- @Status = 7 (Flight is Master flight. Its flight info can be found in the 
	--              [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
	--				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
	--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
	--              [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],[ERLY_OPEN_OFFSET],
	--              [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
	--              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
	--				21 fields will be returned to caller via returned recordset.
	-- @Status = 8 (Flight is Slave flight. its master flight is valid flight 
	--				(flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
	--              And its master flight allocation has been created 
	--				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
	--				[AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
	--              [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
	--              [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
	--              [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
	--              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
	--				23 fields will be returned to caller via returned recordset.
AS 
BEGIN
	DECLARE	@No int;
	SET @No = (SELECT Count([LICENSE_PLATE]) FROM [BAG_SORTING] WHERE [LICENSE_PLATE] = @LicensePlate);

	IF @No = 0 
	BEGIN
		-- No BSM of specific LP# is in the [BAG_SORTING] table, it is No BSM (NBSM) item, 
		-- return @Status value 1
		SET @Status = 1;
		RETURN 0;
	END
	ELSE IF @No > 1
	BEGIN
		-- More than one BSMs of specific LP# are in the [BAG_SORTING] table, it is multiple
	    -- BSM (MBSM) item, return @Status value 2. 
		SET @Status = 2;
		RETURN 0;
	END
	
	IF @No = 1
	BEGIN
		-- Single flight was found for the LP, it is normal item. 
		DECLARE	@BSM_Airline [varchar](3);
		DECLARE	@BSM_FlightNumber [varchar](5);
		DECLARE	@BSM_SDO [datetime];
		DECLARE	@Airline [varchar](3);
		DECLARE	@FlightNumber [varchar](5);
		DECLARE	@SDO [datetime];
		DECLARE	@STO [varchar](4);
		DECLARE	@MasterAirline [varchar](3);
		DECLARE	@MasterFlightNumber [varchar](5);
		DECLARE	@FLT_SortDest1 [varchar](10);
		DECLARE	@FLT_SortDest2 [varchar](10);

		-- Use single query for following tasks:
		-- 1. Return [TRAVEL_CLASS], [BAG_EXCEPTION] data from [BAG_SORTING] table;
		-- 2. Verify whether flight is unknow - If @Airline, @FlightNumber and @SDO values are NULL, it
		--    represents that no flight info is received and stored in the table [FLIGHT_PLAN_SORTING].
		--    Hence, the bag the Unknown Flight Bag.
		-- 3. Verify flight is master or slave flight - If @MasterAirline and @MasterFlightNumber is 
		--    not NULL, it represents the flight is slave flight;
		-- 4. Verify flight is High Risk flight or not;
		-- 5. Return flight exception data, sorting destination given by FIS.
		SELECT  @BSM_TravelClass = a.[TRAVEL_CLASS],
				@BSM_Exception = a.[BAG_EXCEPTION], 
				@BSM_Airline = a.[AIRLINE], 
				@BSM_FlightNumber = a.[FLIGHT_NUMBER],
				@BSM_SDO = a.[SDO], 
				@Airline = b.[AIRLINE], --Here must assign with table [LICENSE_PLATE] value, not table [BAG_SORTING]
				@FlightNumber = b.[FLIGHT_NUMBER], --Here must assign with table [LICENSE_PLATE] value, not table [BAG_SORTING]
				@SDO = b.[SDO], --Here must assign with table [LICENSE_PLATE] value, not table [BAG_SORTING]
				@STO = b.[STO], --Here must assign with table [LICENSE_PLATE] value, not table [BAG_SORTING]
				@MasterAirline = b.[MASTER_AIRLINE], 
				@MasterFlightNumber = b.[MASTER_FLIGHT_NUMBER],
				@FLT_HighRisk = b.[HIGH_RISK],
				@FLT_Exception = b.[FI_EXCEPTION],
				@FLT_SortDest1 = b.[SORTING_DEST1],
				@FLT_SortDest2 = b.[SORTING_DEST2]		
		FROM [BAG_SORTING] AS a
			LEFT OUTER JOIN [FLIGHT_PLAN_SORTING] AS b 
				ON (a.[AIRLINE] = b.[AIRLINE]) AND 
					(a.[FLIGHT_NUMBER] = b.[FLIGHT_NUMBER]) AND
					(a.[SDO] = b.[SDO])
		WHERE (a.[LICENSE_PLATE] = @LicensePlate);

		-- 2. Verify whether flight is unknow - If @Airline, @FlightNumber and @SDO values are NULL, it
		--    represents that no flight info is received and stored in the table [FLIGHT_PLAN_SORTING].
		--    Hence, the bag the Unknown Flight Bag.
		IF (@Airline IS NULL) AND (@FlightNumber IS NULL) AND (@SDO IS NULL)
		BEGIN
			-- @Status = 3 (Single BSM of specific LP# is in the [BAG_SORTING] table, but the flight included 
			--				in the BSM can not be found in the [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
			--				[AIRLINE],[FLIGHT_NUMBER],[SDO] three fields will be returned caller
			--				via returned recordset.
			SET @Status = 3;
			SELECT @BSM_Airline AS [AIRLINE], @BSM_FlightNumber AS [FLIGHT_NUMBER], @BSM_SDO AS [SDO];
			RETURN 0;
		END
		
		-- Verify flight is master or slave flight. If it is slave flight, then
		-- use its master flight for sortation.
		IF LEN(LTRIM(RTRIM(@MasterAirline)))=0 --Convert "No NULL" and space only string field value to NULL
			SET @MasterAirline=NULL;
		IF LEN(LTRIM(RTRIM(@MasterFlightNumber)))=0
			SET @MasterFlightNumber=NULL;

		IF NOT (@MasterAirline IS NULL) AND NOT (@MasterFlightNumber IS NULL) -- Flight is Slave Flight
		BEGIN
			SET @Airline = NULL;
			SET @FlightNumber = NULL;
			
			SELECT 	@Airline = [AIRLINE], 
					@FlightNumber = [FLIGHT_NUMBER], 
					@STO = [STO],
					@FLT_HighRisk = [HIGH_RISK],
					@FLT_Exception = [FI_EXCEPTION],
					@FLT_SortDest1 = [SORTING_DEST1],
					@FLT_SortDest2 = [SORTING_DEST2]		
			FROM [FLIGHT_PLAN_SORTING] 
			WHERE   ([AIRLINE] = @MasterAirline) AND 
					([FLIGHT_NUMBER] = @MasterFlightNumber) AND 
					([SDO] = @SDO);		
		
			IF (@Airline IS NULL) AND (@FlightNumber IS NULL)
			BEGIN
				-- @Status = 4 (Flight is Slave filght, but its master flight can not be found in the
				--				[FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
				--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
				--				five fields will be returned caller via returned recordset.
				SET @Status = 4;
				SELECT @BSM_Airline AS [AIRLINE], @BSM_FlightNumber AS [FLIGHT_NUMBER], 
						@BSM_SDO AS [SDO],@MasterAirline AS [MASTER_AIRLINE], 
						@MasterFlightNumber AS [MASTER_FLIGHT_NUMBER];
				RETURN 0;
			END
		END

		DECLARE	@No1 int;
		SET @No1 = (SELECT Count(*) FROM [FLIGHT_PLAN_ALLOC] 
						WHERE ([AIRLINE] = @Airline) AND ([FLIGHT_NUMBER] = @FlightNumber) AND
								([SDO] = @SDO));
		IF @No1 = 0 
		BEGIN
			IF (@MasterAirline IS NULL) AND (@MasterFlightNumber IS NULL) -- Flight is Master Flight
			BEGIN
				-- @Status = 5 (Flight is Master flight and its flight info can be found in the 
				--              [FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
				--				(no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is 
				--              treated as No Allocation Flight.
				--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO] four fields will be returned caller
				--				via returned recordset.
				SET @Status = 5;
				SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], @SDO AS [SDO], @STO AS [STO];
				RETURN 0;
			END
			ELSE -- Flight is Slave Flight
			BEGIN  
				-- @Status = 6 (Flight is Slave flight, its master flight is valid flight (flight 
				--				info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
				--				no any allocation was created (no allocation recoreds in the table 
				--				[FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
				--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO], [MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
				--				six fields will be returned caller via returned recordset.
				SET @Status = 6;
				SELECT @BSM_Airline AS [AIRLINE], @BSM_FlightNumber AS [FLIGHT_NUMBER], 
						@BSM_SDO AS [SDO], @STO AS [STO], @MasterAirline AS [MASTER_AIRLINE], 
						@MasterFlightNumber AS [MASTER_FLIGHT_NUMBER];
				RETURN 0;
			END			
		END
		ELSE -- @No1 > 0 
		BEGIN
			DECLARE	@EarlyOpenOffset [varchar](5);
			SELECT @EarlyOpenOffset=[SYS_VALUE] FROM [SYS_CONFIG] WHERE ([SYS_KEY] = 'ERLY_OPEN_OFFSET');

			-- If flight has allocations were created, then continue followings.
			IF (@MasterAirline IS NULL) AND (@MasterFlightNumber IS NULL) -- Flight is Master Flight
			BEGIN
				-- @Status = 7 (Flight is Master flight. Its flight info can be found in the 
				--              [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
				--				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
				--				[AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
				--              [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
				--              [ERLY_OPEN_OFFSET],[RUSH_DURATION],
				--              [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
				--              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
				--				21 fields will be returned to caller via returned recordset.
				SET @Status = 7;

				SELECT  a.[AIRLINE], a.[FLIGHT_NUMBER], 
						a.[SDO], a.[STO], a.[EDO], a.[ETO], a.[IDO], a.[ITO], a.[ADO], a.[ATO],	
						@EarlyOpenOffset AS [ERLY_OPEN_OFFSET], 				
						a.[ALLOC_OPEN_OFFSET], a.[ALLOC_OPEN_RELATED], 
						a.[ALLOC_CLOSE_OFFSET], a.[ALLOC_CLOSE_RELATED], 
						a.[RUSH_DURATION], a.[IS_MANUAL_CLOSE], a.[IS_CLOSED], a.[TRAVEL_CLASS], 
						a.[RESOURCE], b.[SUBSYSTEM]
					FROM [FLIGHT_PLAN_ALLOC] AS a
						LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
					WHERE (a.[AIRLINE] = @Airline) AND (a.[FLIGHT_NUMBER] = @FlightNumber) AND 
						(a.[SDO] = @SDO) ORDER BY TIME_STAMP;
				RETURN 0;
			END
			ELSE
			BEGIN
				-- @Status = 8 (Flight is Slave flight. its master flight is valid flight 
				--				(flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
				--              And its master flight allocation has been created 
				--				(has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
				--				[AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
				--              [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
				--              [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
				--              [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
				--              [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
				--				23 fields will be returned to caller via returned recordset.
				SET @Status = 8;

				SELECT  @BSM_Airline AS [AIRLINE], @BSM_FlightNumber AS [FLIGHT_NUMBER], 
						@MasterAirline AS [MASTER_AIRLINE], @MasterFlightNumber AS [MASTER_FLIGHT_NUMBER],
						@BSM_SDO AS [SDO], a.[STO], a.[EDO], a.[ETO], a.[IDO], a.[ITO], a.[ADO], a.[ATO],						 
						@EarlyOpenOffset AS [ERLY_OPEN_OFFSET],
						a.[ALLOC_OPEN_OFFSET], a.[ALLOC_OPEN_RELATED], 
						a.[ALLOC_CLOSE_OFFSET], a.[ALLOC_CLOSE_RELATED], 
						a.[RUSH_DURATION], a.[IS_MANUAL_CLOSE], a.[IS_CLOSED], a.[TRAVEL_CLASS], 
						a.[RESOURCE], b.[SUBSYSTEM]
					FROM [FLIGHT_PLAN_ALLOC] AS a
						LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
					WHERE (a.[AIRLINE] = @Airline) AND (a.[FLIGHT_NUMBER] = @FlightNumber) AND 
						(a.[SDO] = @SDO) ORDER BY TIME_STAMP;
					
				RETURN 0;
			END
		END
	END
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETFLIGHTALLOCOFFLT]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETFLIGHTALLOCOFFLT]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETFLIGHTALLOCOFFLT]...'
	DROP PROCEDURE [dbo].[stp_SAC_GETFLIGHTALLOCOFFLT]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETFLIGHTALLOCOFFLT]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETFLIGHTALLOCOFFLT]
	@Airline [varchar](3),
	@FlightNumber [varchar](5),
	@SDO [datetime],
	@FLT_HighRisk [varchar](1) OUTPUT,
	@FLT_Exception [varchar](10) OUTPUT,
	@Status [int] = 0 OUTPUT
	-- @Status = 1 Reserved
	-- @Status = 2 Reserved
	-- @Status = 3 Flight can not be found in [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
	--			   No recordset will be returned.
	-- @Status = 4 Flight is Slave filght, but its master flight info can not be found in the
	--			   [FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
	--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
	--			   five fields will be returned caller via returned recordset.
	-- @Status = 5 Flight is Master flight and its flight info can be found in the 
	--             FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
	--			   (no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is treated 
	--             as No Allocation Flight.
	--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO] four fields will be returned caller
	--			   via returned recordset.
	-- @Status = 6 Flight is Slave flight, its master flight is valid flight (flight 
	--			   info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
	--			   no any allocation was created (no allocation recoreds in the table 
	--			   [FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
	--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO], [MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
	--			   six fields will be returned caller via returned recordset.
	-- @Status = 7 Flight is Master flight. Its flight info can be found in the 
	--             [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
	--			   (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
	--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
	--             [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],[ERLY_OPEN_OFFSET],
	--             [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
	--             [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
	--			   21 fields will be returned to caller via returned recordset.
	-- @Status = 8 Flight is Slave flight. its master flight is valid flight 
	--			   (flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
	--             And its master flight allocation has been created 
	--			   (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
	--			   [AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
	--             [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
	--             [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
	--             [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
	--             [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
	--			   23 fields will be returned to caller via returned recordset.
AS 
BEGIN
	-- Single flight was found for the LP, it is normal item. 
	DECLARE	@FLT_Airline [varchar](3);
	DECLARE	@FLT_FlightNumber [varchar](5);
	DECLARE	@FLT_STO [varchar](4);
	DECLARE	@FLT_MasterAirline [varchar](3);
	DECLARE	@FLT_MasterFlightNumber [varchar](5);
	DECLARE	@FLT_SortDest1 [varchar](10);
	DECLARE	@FLT_SortDest2 [varchar](10);

	-- Use single query for following tasks:
	-- 1. Verify whether flight is unknow - If @Airline, @FlightNumber and @SDO values are NULL, it
	--    represents that no flight info is received and stored in the table [FLIGHT_PLAN_SORTING].
	--    Hence, the bag the Unknown Flight Bag.
	-- 2. Verify flight is master or slave flight - If @MasterAirline and @MasterFlightNumber is 
	--    not NULL, it represents the flight is slave flight;
	-- 3. Verify flight is High Risk flight or not;
	-- 4. Return flight exception data, sorting destination given by FIS.
	SELECT  @FLT_Airline = [AIRLINE], 
			@FLT_FlightNumber = [FLIGHT_NUMBER],
			@FLT_STO = [STO], 
			@FLT_MasterAirline = [MASTER_AIRLINE], 
			@FLT_MasterFlightNumber = [MASTER_FLIGHT_NUMBER],
			@FLT_HighRisk = [HIGH_RISK],
			@FLT_Exception = [FI_EXCEPTION],
			@FLT_SortDest1 = [SORTING_DEST1],
			@FLT_SortDest2 = [SORTING_DEST2]		
	FROM [FLIGHT_PLAN_SORTING]  
	WHERE ([AIRLINE] = @Airline) AND ([FLIGHT_NUMBER] = @FlightNumber) AND ([SDO] = @SDO)

	-- 2. Verify whether flight is unknow - If @FLT_Airline, @FLT_FlightNumber values 
	--    are NULL, it represents that no flight info is received and stored in the table 
	--    [FLIGHT_PLAN_SORTING]. Hence, the bag the Unknown Flight Bag.
	IF (@FLT_Airline IS NULL) AND (@FLT_FlightNumber IS NULL) 
	BEGIN
		-- @Status = 3 Flight can not be found in [FLIGHT_PLAN_SORTING] table, it is Unknown flight.
		-- No recordset will be returned.
		SET @Status = 3;
		RETURN 0;
	END
	
	-- Verify flight is master or slave flight. If it is slave flight, then
	-- use its master flight for sortation.
	IF LEN(LTRIM(RTRIM(@FLT_MasterAirline)))=0 --Convert "No NULL" and space only string field value to NULL
		SET @FLT_MasterAirline=NULL;
	IF LEN(LTRIM(RTRIM(@FLT_MasterFlightNumber)))=0
		SET @FLT_MasterFlightNumber=NULL;

	IF NOT (@FLT_MasterAirline IS NULL) AND NOT (@FLT_MasterFlightNumber IS NULL) -- Flight is Slave Flight
	BEGIN
		SET @FLT_Airline = NULL;
		SET @FLT_FlightNumber = NULL;
		
		SELECT 	@FLT_Airline = [AIRLINE], 
				@FLT_FlightNumber = [FLIGHT_NUMBER], 
				@FLT_STO = [STO],
				@FLT_HighRisk = [HIGH_RISK],
				@FLT_Exception = [FI_EXCEPTION],
				@FLT_SortDest1 = [SORTING_DEST1],
				@FLT_SortDest2 = [SORTING_DEST2]		
		FROM [FLIGHT_PLAN_SORTING] 
		WHERE   ([AIRLINE] = @FLT_MasterAirline) AND 
				([FLIGHT_NUMBER] = @FLT_MasterFlightNumber) AND 
				([SDO] = @SDO);		
	
		IF (@FLT_Airline IS NULL) AND (@FLT_FlightNumber IS NULL)
		BEGIN
			-- @Status = 4 Flight is Slave filght, but its master flight info can not be found in the
			--			   [FLIGHT_PLAN_SORTING] table, it is treated as Unknown flight.
			--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
			--			   five fields will be returned caller via returned recordset.
			SET @Status = 4;
			SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], @SDO AS [SDO], 
					@FLT_MasterAirline AS [MASTER_AIRLINE], @FLT_MasterFlightNumber AS [MASTER_FLIGHT_NUMBER];
			RETURN 0;
		END
	END

	DECLARE	@No1 int;
	SET @No1 = (SELECT Count(*) FROM [FLIGHT_PLAN_ALLOC] 
					WHERE ([AIRLINE] = @FLT_Airline) AND ([FLIGHT_NUMBER] = @FLT_FlightNumber) AND
							([SDO] = @SDO));
	IF @No1 = 0 
	BEGIN
		IF (@FLT_MasterAirline IS NULL) AND (@FLT_MasterFlightNumber IS NULL) -- Flight is Master Flight
		BEGIN
			-- @Status = 5 Flight is Master flight and its flight info can be found in the 
			--             FLIGHT_PLAN_SORTING] table. But it has no any allocation was created 
			--			   (no allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). It is treated 
			--             as No Allocation Flight.
			--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO] four fields will be returned caller
			--			   via returned recordset.
			SET @Status = 5;
			SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], 
					@SDO AS [SDO], @FLT_STO AS [STO];
			RETURN 0;
		END
		ELSE -- Flight is Slave Flight
		BEGIN  
			-- @Status = 6 Flight is Slave flight, its master flight is valid flight (flight 
			--			   info can be found in the [FLIGHT_PLAN_SORTING] table). But it has 
			--			   no any allocation was created (no allocation recoreds in the table 
			--			   [FLIGHT_PLAN_ALLOC]). It is treated as No Allocation Flight.
			--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO], [MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
			--			   six fields will be returned caller via returned recordset.
			SET @Status = 6;
			SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], 
					@SDO AS [SDO], @FLT_STO AS [STO], @FLT_MasterAirline AS [MASTER_AIRLINE], 
					@FLT_MasterFlightNumber AS [MASTER_FLIGHT_NUMBER];
			RETURN 0;
		END			
	END
	ELSE -- @No1 > 0 
	BEGIN
		DECLARE	@EarlyOpenOffset [varchar](5);
		SELECT @EarlyOpenOffset=[SYS_VALUE] FROM [SYS_CONFIG] WHERE ([SYS_KEY] = 'ERLY_OPEN_OFFSET');

		-- If flight has allocations were created, then continue followings.
		IF (@FLT_MasterAirline IS NULL) AND (@FLT_MasterFlightNumber IS NULL) -- Flight is Master Flight
		BEGIN
			-- @Status = 7 Flight is Master flight. Its flight info can be found in the 
			--             [FLIGHT_PLAN_SORTING] table. And its allocation has been created 
			--			   (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
			--			   [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[IDO],[ITO],
			--             [ADO],[ATO],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],[ERLY_OPEN_OFFSET],
			--             [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
			--             [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
			--			   21 fields will be returned to caller via returned recordset.
			SET @Status = 7;

			SELECT  a.[AIRLINE], a.[FLIGHT_NUMBER], 
					a.[SDO], a.[STO], a.[EDO], a.[ETO], a.[IDO], a.[ITO], a.[ADO], a.[ATO],	
					@EarlyOpenOffset AS [ERLY_OPEN_OFFSET], 				
					a.[ALLOC_OPEN_OFFSET], a.[ALLOC_OPEN_RELATED], 
					a.[ALLOC_CLOSE_OFFSET], a.[ALLOC_CLOSE_RELATED], 
					a.[RUSH_DURATION], a.[IS_MANUAL_CLOSE], a.[IS_CLOSED], a.[TRAVEL_CLASS], 
					a.[RESOURCE], b.[SUBSYSTEM]
				FROM [FLIGHT_PLAN_ALLOC] AS a
					LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
				WHERE (a.[AIRLINE] = @Airline) AND (a.[FLIGHT_NUMBER] = @FlightNumber) AND 
					(a.[SDO] = @SDO);
				
			RETURN 0;
		END
		ELSE
		BEGIN
			-- @Status = 8 Flight is Slave flight. its master flight is valid flight 
			--			   (flight info can be found in the [FLIGHT_PLAN_SORTING] table). 
			--             And its master flight allocation has been created 
			--			   (has allocation recoreds in the table [FLIGHT_PLAN_ALLOC]). 
			--			   [AIRLINE],[FLIGHT_NUMBER],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
			--             [SDO],[STO],[EDO],[ETO],[IDO],[ITO],[ADO],[ATO],
			--             [ERLY_OPEN_OFFSET],[ALLOC_OPEN_OFFSET],[ALLOC_OPEN_RELATED],
			--             [ALLOC_CLOSE_OFFSET],[ALLOC_CLOSE_RELATED],[RUSH_DURATION],
			--             [IS_MANUAL_CLOSED],[IS_CLOSED],[TRAVEL_CLASS],[RESOURCE],[SUBSYSTEM]
			--			   23 fields will be returned to caller via returned recordset.
			SET @Status = 8;

			SELECT  @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], 
					@FLT_MasterAirline AS [MASTER_AIRLINE], @FLT_MasterFlightNumber AS [MASTER_FLIGHT_NUMBER],
					@SDO AS [SDO], a.[STO], a.[EDO], a.[ETO], a.[IDO], a.[ITO], a.[ADO], a.[ATO],						 
					@EarlyOpenOffset AS [ERLY_OPEN_OFFSET],
					a.[ALLOC_OPEN_OFFSET], a.[ALLOC_OPEN_RELATED], 
					a.[ALLOC_CLOSE_OFFSET], a.[ALLOC_CLOSE_RELATED], 
					a.[RUSH_DURATION], a.[IS_MANUAL_CLOSE], a.[IS_CLOSED], a.[TRAVEL_CLASS], 
					a.[RESOURCE], b.[SUBSYSTEM]
				FROM [FLIGHT_PLAN_ALLOC] AS a
					LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
				WHERE (a.[AIRLINE] = @FLT_Airline) AND (a.[FLIGHT_NUMBER] = @FLT_FlightNumber) AND 
					(a.[SDO] = @SDO);
				
			RETURN 0;
		END
	END
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETFLIGHTALLOCATION]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETFLIGHTALLOCATION]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETFLIGHTALLOCATION]...'
	DROP PROCEDURE [dbo].[stp_SAC_GETFLIGHTALLOCATION]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETFLIGHTALLOCATION]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_GETFLIGHTALLOCATION]
	@LicensePlate [varchar](10),
	@Status [int] = 0 OUTPUT
	-- @Status = 1 (No flight was found in [BAG] table for given LP, it is No BSM (NBSM) item)
	-- @Status = 2 (More than one flight was found in [BAG] table for given LP, it is multiple BSM (BMLP) item)
	-- @Status = 3 (Single flight was found in [BAG] table for given LP, but this flight
	--				can not be found in the [FLIGHT_PLANS] table, it is Unknown flight.
	--				[AIRLINE],[FLIGHT_NUMBER],[ADO] three fields will be returned caller
	--				via returned recordset.
	-- @Status = 4 (Flight is Slave filght, but its master flight can not be found in the
	--				[FLIGHT_PLANS] table, it is Unknown flight.
	--				[AIRLINE],[FLIGHT_NUMBER],[ADO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
	--				five fields will be returned caller via returned recordset.
	-- @Status = 5 (Flight is Master flight and can be found in the [FLIGHT_PLANS] table, 
	--				but no allocated destination of it can be found from table 
	--				[FLIGHT_PLAN_ALLOC]. It is No Allocation Flight.)
	--				[AIRLINE],[FLIGHT_NUMBER],[ADO] three fields will be returned caller
	--				via returned recordset.
	-- @Status = 6 (Flight is Slave flight, it''s master flight can also be found from 
	--				[FLIGHT_PLANS] table, but no allocated destination of its Master flight 
	--				was found in the [FLIGHT_PLAN_ALLOC] table. It is No Allocation Flight item.
	--				[AIRLINE],[FLIGHT_NUMBER],[ADO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER]
	--				five fields will be returned caller via returned recordset.
	-- @Status = 7 (Item is normal bag. It flight is Master flight which allocated destination
	--				can be found from [FLIGHT_PLAN_ALLOC] table.
	--				[AIRLINE],[FLIGHT_NUMBER],[ADO],[LOCATION],[SUBSYSTEM],[SCHEME_TYPE]
	--				six fields will be returned to caller via returned recordset.
	-- @Status = 8 (Item is normal bag. It flight is Slave flight and its Master flight can be
	--				found from [FLIGHT_PLANS] table. And the allocated destination of Master 
	--				flight can be found from [FLIGHT_PLAN_ALLOC] table.
	--				[AIRLINE],[FLIGHT_NUMBER],[ADO],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],
	--				[LOCATION],[SUBSYSTEM],[SCHEME_TYPE] eight fields will be returned to 
	--				caller via returned recordset.
AS 
BEGIN
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_SORTING] WHERE [LICENSE_PLATE] = @LicensePlate)

	IF @No = 0 
	BEGIN
		-- No flight was found for the LP, it is No BSM (NBSM) item, return 1
		SET @Status = 1
		RETURN 0
	END
	ELSE IF @No > 1
	BEGIN
		-- More than one flight was found for the LP, it is multiple BSM (BMLP) 
		-- item, return 2. In the implementation of Panama Tocumen Airport BHS
		-- project, there is no multiple BSM scenario will be happen. It because 
		-- that once receive the secondary BSM of the same license plate, BHS 
		-- will update the previous one, instead of add the new record.
		SET @Status = 2
		RETURN 0
	END
	ELSE IF @No = 1
	BEGIN
		-- Single flight was found for the LP, it is normal item. 
		DECLARE	@Airline [varchar](3)
		DECLARE	@FlightNumber [varchar](5)
		DECLARE	@SDO [datetime]
		DECLARE	@Master_Airline [varchar](3)
		DECLARE	@Master_FlightNumber [varchar](5)

		-- Get the flight and its master flight info of given LP item.
		SELECT @Airline = a.[AIRLINE], 
				@FlightNumber = a.[FLIGHT_NUMBER], 
				@SDO = a.[SDO], 
				@Master_Airline = b.[MASTER_AIRLINE], 
				@Master_FlightNumber = b.[MASTER_FLIGHT_NUMBER]
		FROM [BAG_SORTING] AS a
			LEFT OUTER JOIN [FLIGHT_PLAN_SORTING] AS b 
			ON (a.[AIRLINE] = b.[AIRLINE]) AND 
				(a.[FLIGHT_NUMBER] = b.[FLIGHT_NUMBER]) AND
				(a.[SDO] = b.[SDO])
		WHERE (a.[LICENSE_PLATE] = @LicensePlate)

		-- Verify flight is master or slave flight. If it is slave flight, then
		-- use its master flight should be used for sortation.
		IF (@Master_Airline IS NULL) AND (@Master_FlightNumber IS NULL) -- Flight is Master Flight
		BEGIN
			DECLARE	@No1 int
			SET @No1 =  (SELECT Count(*) FROM [FLIGHT_PLAN_SORTING] 
						 WHERE ([AIRLINE] = @Airline) AND 
							   ([FLIGHT_NUMBER] = @FlightNumber) AND ([SDO] = @SDO))
			IF @No1 = 0 
			BEGIN
				-- Flight can not be found in the [FLIGHT_PLANS] table, it is Unknown flight item
				SET @Status = 3
				SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], @SDO AS [SDO]
				RETURN 0
			END
		END
		ELSE  -- Flight is Slave Flight
		BEGIN
			DECLARE	@No2 int
			SET @No2 =  (SELECT Count(*) FROM [FLIGHT_PLAN_SORTING] 
						 WHERE ([AIRLINE] = @Master_Airline) AND 
							   ([FLIGHT_NUMBER] = @Master_FlightNumber) AND ([SDO] = @SDO))
			IF @No2 = 0 
			BEGIN
				-- Flight is Slave filght, its master flight can not be found in the 
				-- [FLIGHT_PLANS] table, it is Unknown flight
				SET @Status = 4
				SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], 
						@SDO AS [SDO], @Master_Airline AS [MASTER_AIRLINE], 
						@Master_FlightNumber AS [MASTER_FLIGHT_NUMBER]
				RETURN 0
			END
		END

		-- If Flight was found in the [FLIGHT_PLANS] table, then continue followings.
		DECLARE	@No3 int
		IF (@Master_Airline IS NULL) AND (@Master_FlightNumber IS NULL) -- Flight is Master Flight
		BEGIN
			SET @No3 =  (SELECT Count(*) FROM [FLIGHT_PLAN_ALLOC] 
						 WHERE ([AIRLINE] = @Airline) AND 
							   ([FLIGHT_NUMBER] = @FlightNumber) AND 
							   ([SDO] = @SDO))
			IF @No3 = 0 
			BEGIN
				-- Flight is Master flight, but no allocated destination of it was found 
				-- in [FLIGHT_PLAN_ALLOC] table. It is No Allocation Flight item.
				SET @Status = 5
				SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], @SDO AS [SDO]
				RETURN 0
			END
		END
		ELSE  -- Flight is Slave Flight
		BEGIN
			SET @No3 =  (SELECT Count(*) FROM [FLIGHT_PLAN_ALLOC] 
						 WHERE ([AIRLINE] = @Master_Airline) AND 
							   ([FLIGHT_NUMBER] = @Master_FlightNumber) AND 
							   ([SDO] = @SDO))
			IF @No3 = 0 
			BEGIN
				-- Flight is Slave flight, but no allocated destination of its Master flight 
				-- was found in [FLIGHT_PLAN_ALLOC] table. It is No Allocation Flight item.
				SET @Status = 6
				SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], 
						@SDO AS [SDO], @Master_Airline AS [MASTER_AIRLINE], 
						@Master_FlightNumber AS [MASTER_FLIGHT_NUMBER]
				RETURN 0
			END
		END

		-- If Flight was found in the [FLIGHT_PLANS] table, and it has been allocated with 
		-- destination in [FLIGHT_PLAN_ALLOC] table, then continue followings.
		IF @No3 > 0 
		BEGIN
			IF (@Master_Airline IS NULL) AND (@Master_FlightNumber IS NULL) -- Flight is Master Flight
			BEGIN
				-- Item is normal bag which flight was allocated with destination. And its 
				-- flight is Master flight.
				SET @Status = 7

				SELECT a.[AIRLINE], a.[FLIGHT_NUMBER], a.[SDO], a.[RESOURCE], 
						b.[SUBSYSTEM], a.[SCHEME_TYPE] 
				FROM [FLIGHT_PLAN_ALLOC] AS a
					LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
				WHERE (a.[AIRLINE] = @Airline) AND 
					(a.[FLIGHT_NUMBER] = @FlightNumber) AND (a.[SDO] = @SDO)
				RETURN 0
			END
			ELSE
			BEGIN
				-- Item is normal bag and its flight is Slave flight, which master flight
				-- was allocated with destination. 
				SET @Status = 8

				SELECT @Airline AS [AIRLINE], @FlightNumber AS [FLIGHT_NUMBER], 
						@SDO AS [SDO], @Master_Airline AS [MASTER_AIRLINE], 
						@Master_FlightNumber AS [MASTER_FLIGHT_NUMBER], 
						a.[RESOURCE], b.[SUBSYSTEM], a.[SCHEME_TYPE] 
				FROM [FLIGHT_PLAN_ALLOC] AS a
					LEFT OUTER JOIN [ALLOC_RESOURCES] AS b ON (a.[RESOURCE] = b.[RESOURCE])
				WHERE (a.[AIRLINE] = @Master_Airline) AND 
					(a.[FLIGHT_NUMBER] = @Master_FlightNumber) AND (a.[SDO] = @SDO)
				RETURN 0
			END
		END
	END
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_LPVALIDATION]    Script Date: 10/08/2007 13:18:36 ******
-- Check whether the BSM of both specific license plate numbers have been received or not.
-- Please be noted that there may be multiple records of single license plate# in the [BAG_SORTING]
-- table due to the multiple BSMs of the same bag were received from BSI.
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_LPVALIDATION]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_LPVALIDATION]...'
	DROP PROCEDURE [dbo].[stp_SAC_LPVALIDATION]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_LPVALIDATION]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_LPVALIDATION] 
	@LicensePlate1 [varchar](10),
	@LicensePlate2 [varchar](10),
	@ValidLP [varchar](10) OUTPUT,
	@Result [int] = 0 OUTPUT
	-- @Status = 0 (No any BSM was received for both specific License Plate numbers)
	-- @Status = 1 (Only one of two specific License Plate numbers has the BSM be received)
	-- @Status = 2 (Both specific License Plate numbers have the BSM be received)
AS
BEGIN
	DECLARE @LP1 [varchar] (10)
	DECLARE @LP2 [varchar] (10)
	
	SELECT @LP1 = [LICENSE_PLATE] FROM [BAG_SORTING] WHERE [LICENSE_PLATE] = @LicensePlate1
	SELECT @LP2 = [LICENSE_PLATE] FROM [BAG_SORTING] WHERE [LICENSE_PLATE] = @LicensePlate2

	IF (@LP1 IS NULL) AND (@LP2 IS NULL) 
	BEGIN
		SET @Result = 0
		SET @ValidLP = NULL
		RETURN 0
	END
	
	IF NOT (@LP1 IS NULL) AND (@LP2 IS NULL) 
	BEGIN
		SET @Result = 1
		SET @ValidLP = @LicensePlate1
		RETURN 0
	END

	IF (@LP1 IS NULL) AND NOT (@LP2 IS NULL) 
	BEGIN
		SET @Result = 1
		SET @ValidLP = @LicensePlate2
		RETURN 0
	END

	IF NOT (@LP1 IS NULL) AND NOT (@LP2 IS NULL) 
	BEGIN
		SET @Result = 2
		SET @ValidLP = NULL
		RETURN 0
	END
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETAIRLINEALLOCATION]    Script Date: 12/08/2008 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETAIRLINEALLOCATION]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETAIRLINEALLOCATION].'
	DROP PROCEDURE [dbo].[stp_SAC_GETAIRLINEALLOCATION]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETAIRLINEALLOCATION].'
GO
CREATE PROCEDURE [stp_SAC_GETAIRLINEALLOCATION]
	@AirlineCode [varchar](4)
AS 
BEGIN
	DECLARE @TEMPTABLE TABLE ([DESTINATION] VARCHAR(10), [SUBSYSTEM] VARCHAR(10), [PRIORITY] INT)
	DECLARE @COUNT INT
	DECLARE @COUNT1 INT
	SET @COUNT = (SELECT COUNT(a.[DESTINATION]) FROM [AIRLINES] AS a
					LEFT OUTER JOIN [DESTINATIONS] AS b ON (a.[DESTINATION] = b.[DESTINATION])
				WHERE a.[TICKETING_CODE] = @AirlineCode)
	SET @COUNT1 = (SELECT COUNT(a.[DESTINATION1]) FROM [AIRLINES] AS a
				LEFT OUTER JOIN [DESTINATIONS] AS b ON (a.[DESTINATION1] = b.[DESTINATION])
			WHERE a.[TICKETING_CODE] = @AirlineCode)
			
	IF @COUNT > 0
	BEGIN
		INSERT INTO @TEMPTABLE
		SELECT a.[DESTINATION], b.[SUBSYSTEM], 1
			FROM [AIRLINES] AS a
				LEFT OUTER JOIN [DESTINATIONS] AS b ON (a.[DESTINATION] = b.[DESTINATION])
			WHERE a.[TICKETING_CODE] = @AirlineCode
	END
	
	IF @COUNT1 > 0
	BEGIN
		INSERT INTO @TEMPTABLE
		SELECT a.[DESTINATION1],b.[SUBSYSTEM], 2
			FROM [AIRLINES] AS a
				LEFT OUTER JOIN [DESTINATIONS] AS b ON (a.[DESTINATION1] = b.[DESTINATION])
			WHERE a.[TICKETING_CODE] = @AirlineCode
	END
	
	SELECT [DESTINATION], [SUBSYSTEM] FROM @TEMPTABLE order by PRIORITY

END
GO 




-- ****** Object:  StoredProcedure [dbo].[stp_SAC_GETFALLBACKTAGDISCHARGE]    Script Date: 12/08/2008 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_GETFALLBACKTAGDISCHARGE]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_GETFALLBACKTAGDISCHARGE].'
	DROP PROCEDURE [dbo].[stp_SAC_GETFALLBACKTAGDISCHARGE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_GETFALLBACKTAGDISCHARGE].'
GO
CREATE PROCEDURE [stp_SAC_GETFALLBACKTAGDISCHARGE]
	@FALLBACK_ID [varchar](2)
AS 
BEGIN
	SELECT 
		a.[DESTINATION], b.[SUBSYSTEM]
	FROM 
		[FALLBACK_MAPPING] AS a
		LEFT OUTER JOIN [DESTINATIONS] AS b
		ON (a.[DESTINATION] = b.[DESTINATION])
	WHERE a.[ID] = @FALLBACK_ID	
END
GO 




-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ALLOCATIONLISTSBYDATE]    Script Date: 12/08/2008 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ALLOCATIONLISTSBYDATE]') 
		AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ALLOCATIONLISTSBYDATE].'
	DROP PROCEDURE [dbo].[stp_SAC_ALLOCATIONLISTSBYDATE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ALLOCATIONLISTSBYDATE].'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ALLOCATIONLISTSBYDATE]
	@AllocDate datetime,
	@Created_By varchar(15),
	@result varchar(10) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	begin try
	DECLARE cur_flights SCROLL CURSOR
	FOR SELECT DISTINCT FLIGHT_NUMBER,AIRLINE FROM BHSDB.DBO.FLIGHT_PLAN_ALLOC
	WHERE SDO=@AllocDate AND CREATED_BY=@Created_By
	OPEN cur_flights
		SET @result=CAST(@@CURSOR_ROWS AS varchar(10))
	CLOSE cur_flights
	DEALLOCATE cur_flights
	end try
	begin catch
		Set @result='0'
	end catch
	RETURN @result
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ALLOCATIONLISTSBYMONTH]    Script Date: 12/08/2008 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ALLOCATIONLISTSBYMONTH]') 
		AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ALLOCATIONLISTSBYMONTH].'
	DROP PROCEDURE [dbo].[stp_SAC_ALLOCATIONLISTSBYMONTH]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ALLOCATIONLISTSBYMONTH].'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ALLOCATIONLISTSBYMONTH]
	@Year varchar(4),
	@Month varchar(2),
	@DaysInMonth int,
	@Created_By varchar(15),
	@ResultByMonth varchar(350) output
AS
Begin
	SET NOCOUNT ON;
	Declare @i int
	Declare @Alloc_Date datetime 
	Declare @result varchar(10)
	Set @ResultByMonth=''
	Set @i=1
	While(@i<=@DaysInMonth)
		Begin
			Set @Alloc_Date=Convert(datetime,@Year+'-'+@Month+'-'+Convert(varchar(2),@i))
			--Execute stp_SAC_ALLOCATIONLISTSBYDATE
			Exec stp_SAC_ALLOCATIONLISTSBYDATE @Alloc_Date,@Created_By,@result output
			Set @ResultByMonth=	@ResultByMonth + @result	
			if(@i<>@DaysInMonth)
			Begin
				Set @ResultByMonth=@ResultByMonth+'@'
			End
			--increase loopcount
			Set @i=@i+1
		End
--		Select @ResultByMonth
End
GO
/*
use [BHSDB]
declare @ResultByMonth varchar(350)
exec stp_SAC_ALLOCATIONLISTSBYMONTH '2008','9',30,'Manual',@ResultByMonth output
print @ResultByMonth
go
*/


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC]    Script Date: 12/08/2008 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC]') 
		AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_CHANGEDISCHARGEOFOPENALLOC].'
	DROP PROCEDURE [dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_CHANGEDISCHARGEOFOPENALLOC].'
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC]
	@AirLine varchar(3),
	@FlightNo varchar(5),
	@SDO datetime,
	@OStart datetime,
	@OEnd datetime,
	@OResource varchar(10),
	@NResource varchar(10)
AS
BEGIN
	Set NOCOUNT ON;
	Declare @Now datetime
	Declare @STODT datetime
	Declare @OCloseOffset varchar(5)
	Declare @OOpenOffset varchar(5)
	Declare @NCloseOffset varchar(5)
	Declare @NOpenOffset varchar(5)
	Declare @MyDay int
	Declare @MyHour int
	Declare @MyMinute bigint
	Declare @STO varchar(4)
	Declare @IS_Manual bit
	Declare @Close_Related varchar(4)
	Declare @Close_Do datetime
	Declare @ExcOffset varchar(4)
	--Default
	Set @OCloseOffset=''
	Set @OOpenOffset=''
	Set @NCloseOffset=''
	Set @NOpenOffset=''
	Set @MyDay=0
	Set @MyHour=0
	Set @MyMinute=0
	Set @STO=''
	Set @IS_Manual=0
	
	Set @Now=DATEADD(ss,-DATEPART(ss,GETDATE()),GETDATE()) --get now

	--Close Related	
	SELECT @Close_Related=ALLOC_CLOSE_RELATED FROM FLIGHT_PLAN_ALLOC 
		WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
	--STD
	IF(RTRIM(LTRIM(@Close_Related))='STD')
		Begin
			SELECT @Close_Do=SDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=STO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ETD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
		Begin
			SELECT  @Close_Do=EDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ETO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ITD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
		Begin
			SELECT  @Close_Do=IDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ITO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ATD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
		Begin
			SELECT @Close_Do=ADO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ATO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--Set STO
	Set @STODT=CONVERT(datetime, CONVERT(nvarchar(30),@Close_Do, 111)+' '+ SUBSTRING(@STO,1,2)+':'+SUBSTRING(@STO,3,2)+':00')

		Set @MyMinute=DATEDIFF(mi,@Now,@OEnd)
		Set @MyHour=@MyMinute / 60
		Set @MyMinute=@MyMinute - (@MyHour * 60)

	--Get New Close Offset
	IF(SUBSTRING(@OCloseOffset,1,1)='-')
		Begin
			Set @NCloseOffset= [dbo].[SAC_HOURMINUTEMASTER](@OCloseOffset,@MyDay,@MyHour,@MyMinute,'+')
			--Update Original One
			UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@NCloseOffset,TIME_STAMP=GETDATE()
			WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
		End
	ELSE
		Begin
			Print 'Reached to closed time ++ changed status'
			--To do code here update statement for original one	
			--Special Effect 
				IF(LEN(DATEPART(hh,@Now))=1)
					Begin
						Set @NCloseOffset = '0' + CONVERT(varchar(1), DATEPART(hh,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset = CONVERT(varchar(2), DATEPART(hh,@Now))
					End
				IF(LEN(DATEPART(mi,@Now))=1)
					Begin
						Set @NCloseOffset =@NCloseOffset+ '0' + CONVERT(varchar(1),DATEPART(mi,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset =@NCloseOffset+  CONVERT(varchar(2),DATEPART(mi,@Now))
					End
			--Special Effect 
			IF(@Now>=@STODT)
				Begin		

					Set @MyMinute=DATEDIFF(mi,@STODT,@Now)
					Set @MyHour=@MyMinute / 60
					Set @MyMinute=@MyMinute - (@MyHour * 60)
					--Hour
					IF(@MyHour>0)
						Begin
							IF(LEN(@MyHour)=1)
								Begin
									Set @NCloseOffset='0'+CONVERT(varchar(1),@MyHour)
								End			
							ELSE
								Begin
									Set @NCloseOffset=CONVERT(varchar(2),@MyHour)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset='00'
						End
					--Minute
					IF(@MyMinute>0)
						Begin
							IF(LEN(@MyMinute)=1)
								Begin
									Set @NCloseOffset=@NCloseOffset+ '0'+CONVERT(varchar(1),@MyMinute)
								End			
							ELSE
								Begin
									Set @NCloseOffset=@NCloseOffset+CONVERT(varchar(2),@MyMinute)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset=@NCloseOffset+'00'
						End

					-- Set @NCloseOffset =''0''+CONVERT(varchar(2),@MyHour)+CONVERT(varchar(2),@MyMinute) --Max -9959
					UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@NCloseOffset,TIME_STAMP=GETDATE()
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
					--print @MyHour
				End
			ELSE
				Begin
					Set @NCloseOffset ='-'+ [dbo].[SAC_HOURMINUTEDIFF](@STO,@NCloseOffset) --Error have to consider +/- matter(only working - matter)
					UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@NCloseOffset,TIME_STAMP=GETDATE()
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
				End
		End
	--Get New Open Offset
	--Day,Hour,Min
--		Set @MyDay=datediff(dd,@OStart,@Now)
--		Set @MyHour=DATEDIFF(hh,@OStart,@Now)
--		Set @MyMinute=DATEDIFF(mi,@OStart,@Now)-(@MyHour * 60)
--	--Day,Hour,Min
--	if(@Now>=@STODT)
--	Begin
	Set @NOpenOffset= @NCloseOffset
--	End
--	else
--	Begin
--		Set @NOpenOffset= [dbo].[SAC_HOURMINUTEMASTER](@OOpenOffset,@MyDay,@MyHour,@MyMinute,'-')
--	End
	--Insert new one at new allocation
	INSERT INTO dbo.FLIGHT_PLAN_ALLOC
		(AIRLINE,FLIGHT_NUMBER,SDO,STO,RESOURCE,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
		TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSET,EARLY_OPEN_ENABLED,
		ALLOC_OPEN_OFFSET,ALLOC_OPEN_RELATED,ALLOC_CLOSE_OFFSET,ALLOC_CLOSE_RELATED,
		RUSH_DURATION,SCHEME_TYPE,CREATED_BY,TIME_STAMP,HOUR,IS_MANUAL_CLOSE,IS_CLOSED)
		SELECT AIRLINE,FLIGHT_NUMBER,SDO,STO,@NResource,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
			TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSet,EARLY_OPEN_ENABLED,
			@NOpenOffset,@Close_Related,@OCloseOffset,ALLOC_CLOSE_RELATED,
			RUSH_DURATION,SCHEME_TYPE,CREATED_BY,GETDATE(),HOUR,@IS_Manual,IS_CLOSED
		FROM dbo.FLIGHT_PLAN_ALLOC
		WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
	--Delete , if Open_offset=Closeoffset in a same location.
	DELETE FROM FLIGHT_PLAN_ALLOC WHERE ALLOC_OPEN_OFFSET=ALLOC_CLOSE_OFFSET AND 
	AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
End
GO
/*
exec [dbo].[stp_SAC_CHANGEDISCHARGEOFOPENALLOC] 'SQ', '138', '10-Oct-08', '10-Oct-08 9:30AM', '10-Oct-08 12:30PM', 'TTS', 'CPC'
go 
select * from flight_plan_alloc
*/










SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]...'
	DROP PROCEDURE [dbo].[stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET]
	@Is_Manual_Close bit
AS
Begin
	Declare @AirLine varchar(3)
	Declare @FLIGHT_NUMBER varchar(5)
	Declare @RESOURCE varchar(10)
	Declare @Now datetime
	Declare @RushNow datetime	
	Declare @STODT datetime
	Declare @STO varchar(4)
	Declare @SDO datetime
	Declare @CloseOffset varchar(5)
	Declare @DefaultCloseOffset varchar(4)
	Declare @RushOffset varchar(5)
	Declare @ETime varchar(4)
	Declare @ResultCloseOffset varchar(5)
	Declare @MyDay int
	Declare @MyHour int
	Declare @MyMinute bigint
	Declare @DiffOffset varchar(4)
	Declare @Close_Do datetime
	Declare @Close_Related varchar(4)
	Declare @Close_To varchar(4)
	--Default
	Set @STO=''
	Set @CloseOffset=''
	Set @Close_Related='STD'
		

	Set @Now=dateadd(ss,-datepart(ss,GetDate()),GetDate()) --get now without seconds
	SELECT @DefaultCloseOffset=SUBSTRING(SYS_VALUE,2,4) FROM SYS_CONFIG WHERE SYS_KEY='ALLOC_CLOSE_OFFSET'
	Declare CHKAuto CURSOR FOR
	SELECT SDO,STO,ALLOC_CLOSE_OFFSET,RUSH_DURATION,AIRLINE,FLIGHT_NUMBER,[RESOURCE] FROM dbo.FLIGHT_PLAN_ALLOC
	WHERE IS_MANUAL_CLOSE=@Is_Manual_Close AND IS_CLOSED=0
	OPEN CHKAuto;	
	FETCH CHKAuto INTO @SDO,@STO,@CloseOffset,@RushOffset,@AirLine,@FLIGHT_NUMBER,@RESOURCE
	WHILE @@Fetch_Status = 0
		Begin
			
			--Close Related	
				Set @Close_Do=@SDO
				SELECT @Close_Related=ALLOC_CLOSE_RELATED FROM FLIGHT_PLAN_ALLOC 
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FLIGHT_NUMBER And SDO=@SDO And RESOURCE=@RESOURCE
				--STD
				IF(RTRIM(LTRIM(@Close_Related))='STD')
					Begin
						SELECT @Close_Do=SDO,@Close_To=STO
						FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FLIGHT_NUMBER And SDO=@SDO And RESOURCE=@RESOURCE
					End
				--ETD
				ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
					Begin
						SELECT @Close_Do=EDO,@Close_To=ETO
						FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FLIGHT_NUMBER And SDO=@SDO And RESOURCE=@RESOURCE
					End
				--ITD
				ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
					Begin
						SELECT @Close_Do=IDO,@Close_To=ITO
						FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FLIGHT_NUMBER And SDO=@SDO And RESOURCE=@RESOURCE
					End
				--ATD
				ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
					Begin
						SELECT @Close_Do=ADO,@Close_To=ATO
						FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FLIGHT_NUMBER And SDO=@SDO And RESOURCE=@RESOURCE
					End
			--Close Related	

			--Set @ETime=[dbo].[SAC_OFFSETOPERATOR](@STO,@CloseOffset)			
			Set @ETime=[dbo].[SAC_OFFSETOPERATOR](@Close_To,@DefaultCloseOffset)				
			--Set @STODT=Convert(datetime, Convert(nvarchar(30),@SDO, 111)+' '+ SUBSTRING(@ETime,1,2)+':'+SUBSTRING(@ETime,3,2)+':00')
			Set @STODT=DateAdd(mi,[dbo].[SAC_MINUTECONVERTER](@ETime), Convert(datetime, Convert(nvarchar(30),@Close_Do, 111)))
			Set @RushNow=@Now
			if((@STODT<=DateAdd(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow)) AND ([dbo].[SAC_MINUTECONVERTER](@CloseOffset)<5760))
			Begin
				--Set @MyDay=datediff(dd,@STODT,DateAdd(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow))
				Set @MyHour=floor(datediff(hh,@STODT,DateAdd(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow)))
				Set @MyMinute=datediff(mi,@STODT,DateAdd(mi,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+50, @RushNow))-(@MyHour * 60) -- -((@MyDay * 1440)+(@MyHour * 60))
				--Set @MyHour=@MyHour + (@MyDay * 24)
				--print @MyDay
				--print @MyHour
				--print @MyMinute
				
				if(@MyHour>=96)
					Begin
						Set @DiffOffset='9600'
						Set @ResultCloseOffset=@DiffOffset
						UPDATE dbo.FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@ResultCloseOffset
						WHERE SDO=@SDO AND IS_MANUAL_CLOSE=@Is_Manual_Close AND AIRLINE=@AirLine AND FLIGHT_NUMBER=@FLIGHT_NUMBER AND
						RESOURCE=@RESOURCE AND IS_CLOSED=1
					End
				else
					Begin
							--Hour
							if(@MyHour>0)
								Begin
									if(len(@MyHour)=1)
										Begin
											Set @DiffOffset='0'+Convert(varchar(1),@MyHour)
										End	
									else
										Begin
											Set @DiffOffset=Convert(varchar(2),@MyHour)
										End
								End
							else
								Begin
									Set @DiffOffset='00'
								End
							--Minute
							if(@MyMinute>0)
								Begin
									if(len(@MyMinute)=1)
										Begin
											Set @DiffOffset=@DiffOffset+'0'+Convert(varchar(1),@MyMinute)
										End	
									else
										Begin
											Set @DiffOffset=@DiffOffset+Convert(varchar(2),@MyMinute)
										End
								End
							else
								Begin
									Set @DiffOffset=@DiffOffset+'00'
								End
						Set @ResultCloseOffset=@DiffOffset
						UPDATE dbo.FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSET=@ResultCloseOffset
						WHERE SDO=@SDO AND IS_MANUAL_CLOSE=@Is_Manual_Close AND AIRLINE=@AirLine AND FLIGHT_NUMBER=@FLIGHT_NUMBER AND
						RESOURCE=@RESOURCE AND IS_CLOSED=0
					End
				--Set @ResultCloseOffset=dbo.SAC_ADDMINUTESTOOFFSET(@CloseOffset,@DiffOffset)
				--Set @ResultCloseOffset=dbo.SAC_ADDMINUTESTOOFFSET(@CloseOffset,[dbo].[SAC_MINUTECONVERTER](@RushOffset)+20)
				--Set @ResultCloseOffset=dbo.SAC_ADDMINUTESTOOFFSET(@DefaultCloseOffset,@DiffOffset)
			End
			FETCH CHKAuto INTO @SDO,@STO,@CloseOffset,@RushOffset,@AirLine,@FLIGHT_NUMBER,@RESOURCE		End
	CLOSE CHKAuto;
	DEALLOCATE CHKAuto;
End
GO
/*
use [BHSDB]
go
exec [dbo].[stp_SAC_AUTOINCREASEMANUALCLOSEFLIGHTOFFSET] 1
go
delete from flight_plan_alloc
SELECT * FROM SYS_CONFIG
print [dbo].[SAC_MINUTECONVERTER](('-0030'))
*/



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_MANUALCLOSEFLIGHTALLOC]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_MANUALCLOSEFLIGHTALLOC]...'
	DROP PROCEDURE [dbo].[stp_SAC_MANUALCLOSEFLIGHTALLOC]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_MANUALCLOSEFLIGHTALLOC]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_MANUALCLOSEFLIGHTALLOC]
	@AirLine varchar(3),
	@Flight_Number varchar(5),
	@SDO datetime,
	@Resource varchar(10),
	@EndTime datetime	
AS
Begin
	SET NOCOUNT ON;
	Declare @MyMinute bigint
	Declare @Now datetime
	Declare @RushDuration varchar(4)
	Declare @ResultOffset varchar(5)
	Declare @CloseOffset varchar(5)
	Set @Now=dateadd(ss,-datepart(ss,GetDate()),GetDate()) --get now without seconds
	
	print @MyMinute
	
	--Get Rush Minutes
	SELECT @RushDuration=[RUSH_DURATION], @CloseOffset=[ALLOC_CLOSE_OFFSET] 
		FROM [FLIGHT_PLAN_ALLOC]
		WHERE AIRLINE= @AirLine AND FLIGHT_NUMBER=@Flight_Number AND SDO=@SDO AND [RESOURCE]=@Resource
	
	Set @MyMinute=datediff(mi,@Now,@EndTime)
	--Get Now
	Set @ResultOffset=[dbo].[SAC_SUBSTRACTMINUTESTOOFFSET](@CloseOffset,@MyMinute)
	print @ResultOffset
--	print @ResultOffset
	Set @ResultOffset = [dbo].[SAC_ADDMINUTESTOOFFSET](@ResultOffset,[dbo].[SAC_MINUTECONVERTER](@RushDuration))
--	print @CloseOffset
--	print [dbo].[SAC_MINUTECONVERTER](@@RushDuration)+@MyMinute
	UPDATE dbo.FLIGHT_PLAN_ALLOC SET ALLOC_CLOSE_OFFSET=@ResultOffset,IS_CLOSED=1
	WHERE AIRLINE= @AirLine AND FLIGHT_NUMBER=@Flight_Number
	AND SDO=@SDO AND RESOURCE=@Resource 
--	print @ResultOffset
End
GO
/*
select * from flight_plan_alloc where SDO='2008-10-14' and airline='SQ' and Flight_Number='103' and resource='HSD'
exec [dbo].[stp_SAC_MANUALCLOSEFLIGHTALLOC] 'SQ','103','2008-10-14','HSD','2008-10-15 11:00AM'
go
*/





SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]...'
	DROP PROCEDURE [dbo].[stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC]
	@AirLine varchar(3),
	@FlightNo varchar(5),
	@SDO datetime,
	@OStart datetime,
	@OEnd datetime,
	@OResource varchar(10),
	@NResource varchar(10)
AS
BEGIN
	Set NOCOUNT ON;
	Declare @Now datetime
	Declare @STODT datetime
	Declare @OCloseOffset varchar(5)
	Declare @OOpenOffset varchar(5)
	Declare @NCloseOffset varchar(5)
	Declare @NOpenOffset varchar(5)
	Declare @MyDay int
	Declare @MyHour int
	Declare @MyMinute bigint
	Declare @STO varchar(4)
	Declare @IS_Manual bit
	Declare @Close_Related varchar(4)
	Declare @Close_Do datetime
	Declare @ExcOffset varchar(4)
	--Default
	Set @OCloseOffset=''
	Set @OOpenOffset=''
	Set @NCloseOffset=''
	Set @NOpenOffset=''
	Set @MyDay=0
	Set @MyHour=0
	Set @MyMinute=0
	Set @STO=''
	Set @IS_Manual=0
	
	Set @Now=DATEADD(ss,-DATEPART(ss,GETDATE()),GETDATE()) --get now

	--Close Related	
	SELECT @Close_Related=ALLOC_CLOSE_RELATED FROM FLIGHT_PLAN_ALLOC 
		WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
	--STD
	IF(RTRIM(LTRIM(@Close_Related))='STD')
		Begin
			SELECT @Close_Do=SDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=STO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ETD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ETD')
		Begin
			SELECT  @Close_Do=EDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ETO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ITD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ITD')
		Begin
			SELECT  @Close_Do=IDO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ITO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--ATD
	ELSE IF(RTRIM(LTRIM(@Close_Related))='ATD')
		Begin
			SELECT @Close_Do=ADO,@OOpenOffset=ALLOC_OPEN_OFFSET,@OCloseOffset=ALLOC_CLOSE_OFFSET,@STO=ATO,@IS_Manual=IS_MANUAL_CLOSE 
			FROM FLIGHT_PLAN_ALLOC WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
		End
	--Set STO
	Set @STODT=CONVERT(datetime, CONVERT(nvarchar(30),@Close_Do, 111)+' '+ SUBSTRING(@STO,1,2)+':'+SUBSTRING(@STO,3,2)+':00')

		Set @MyMinute=DATEDIFF(mi,@Now,@OEnd)
		Set @MyHour=@MyMinute / 60
		Set @MyMinute=@MyMinute - (@MyHour * 60)

	--Get New Close Offset
	IF(SUBSTRING(@OCloseOffset,1,1)='-')
		Begin
			Set @NCloseOffset= [dbo].[SAC_HOURMINUTEMASTER](@OCloseOffset,@MyDay,@MyHour,@MyMinute,'+')
			--Update Original One
			UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSet=@NCloseOffset,IS_CLOSED=1,TIME_STAMP=GETDATE()
			WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
		End
	ELSE
		Begin
			Print 'Reached to closed time ++ changed status'
			--To do code here update statement for original one	
			--Special Effect 
				IF(LEN(DATEPART(hh,@Now))=1)
					Begin
						Set @NCloseOffset = '0' + CONVERT(varchar(1), DATEPART(hh,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset = CONVERT(varchar(2), DATEPART(hh,@Now))
					End
				IF(LEN(DATEPART(mi,@Now))=1)
					Begin
						Set @NCloseOffset =@NCloseOffset+ '0' + CONVERT(varchar(1),DATEPART(mi,@Now))
					End
				ELSE
					Begin
						Set @NCloseOffset =@NCloseOffset+  CONVERT(varchar(2),DATEPART(mi,@Now))
					End
			--Special Effect 
			IF(@Now>=@STODT)
				Begin		

					Set @MyMinute=DATEDIFF(mi,@STODT,@Now)
					Set @MyHour=@MyMinute / 60
					Set @MyMinute=@MyMinute - (@MyHour * 60)
					--Hour
					IF(@MyHour>0)
						Begin
							IF(LEN(@MyHour)=1)
								Begin
									Set @NCloseOffset='0'+CONVERT(varchar(1),@MyHour)
								End			
							ELSE
								Begin
									Set @NCloseOffset=CONVERT(varchar(2),@MyHour)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset='00'
						End
					--Minute
					IF(@MyMinute>0)
						Begin
							IF(LEN(@MyMinute)=1)
								Begin
									Set @NCloseOffset=@NCloseOffset+ '0'+CONVERT(varchar(1),@MyMinute)
								End			
							ELSE
								Begin
									Set @NCloseOffset=@NCloseOffset+CONVERT(varchar(2),@MyMinute)
								End		
						End
					ELSE
						Begin
							Set @NCloseOffset=@NCloseOffset+'00'
						End

					-- Set @NCloseOffset =''0''+CONVERT(varchar(2),@MyHour)+CONVERT(varchar(2),@MyMinute) --Max -9959
					UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSet=@NCloseOffset,IS_CLOSED=1,TIME_STAMP=GETDATE()
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource	
					--print @MyHour
				End
			ELSE
				Begin
					Set @NCloseOffset ='-'+ [dbo].[SAC_HOURMINUTEDIFF](@STO,@NCloseOffset) --Error have to consider +/- matter(only working - matter)
					UPDATE FLIGHT_PLAN_ALLOC Set ALLOC_CLOSE_OFFSet=@NCloseOffset,IS_CLOSED=1,TIME_STAMP=GetDate()
					WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
				End
		End
	--Get New Open Offset
	--Day,Hour,Min
--		Set @MyDay=datediff(dd,@OStart,@Now)
--		Set @MyHour=DATEDIFF(hh,@OStart,@Now)
--		Set @MyMinute=DATEDIFF(mi,@OStart,@Now)-(@MyHour * 60)
--	--Day,Hour,Min
--	if(@Now>=@STODT)
--	Begin
	Set @NOpenOffset= @NCloseOffset
--	End
--	else
--	Begin
--		Set @NOpenOffset= [dbo].[SAC_HOURMINUTEMASTER](@OOpenOffset,@MyDay,@MyHour,@MyMinute,'-')
--	End
	--Insert new one at new allocation
	INSERT INTO dbo.FLIGHT_PLAN_ALLOC
		(AIRLINE,FLIGHT_NUMBER,SDO,STO,RESOURCE,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
		TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSET,EARLY_OPEN_ENABLED,
		ALLOC_OPEN_OFFSET,ALLOC_OPEN_RELATED,ALLOC_CLOSE_OFFSET,ALLOC_CLOSE_RELATED,
		RUSH_DURATION,SCHEME_TYPE,CREATED_BY,TIME_STAMP,HOUR,IS_MANUAL_CLOSE,IS_CLOSED)
		SELECT AIRLINE,FLIGHT_NUMBER,SDO,STO,@NResource,WEEKDAY,EDO,ETO,ADO,ATO,IDO,ITO,
			TRAVEL_CLASS,HIGH_RISK,HBS_LEVEL_REQUIRED,EARLY_OPEN_OFFSet,EARLY_OPEN_ENABLED,
			@NOpenOffset,@Close_Related,@OCloseOffset,ALLOC_CLOSE_RELATED,
			RUSH_DURATION,SCHEME_TYPE,CREATED_BY,GetDate(),HOUR,1,0
		FROM dbo.FLIGHT_PLAN_ALLOC
		WHERE AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource 
	--Delete , if Open_offset=Closeoffset in a same location.
	DELETE FROM FLIGHT_PLAN_ALLOC WHERE ALLOC_OPEN_OFFSET=ALLOC_CLOSE_OFFSET AND 
	AIRLINE=@AirLine And FLIGHT_NUMBER=@FlightNo And SDO=@SDO And RESOURCE=@OResource
End
GO
/*
exec [dbo].[stp_SAC_CHANGEDISCHARGEOFMANUALCLOSEALLOC] 'SQ', '104', '15-Oct-08', '15-Oct-08 9:30PM', '16-Oct-08 2:04AM', 'CPC', 'CT01'
go 
select * from flight_plan_alloc
*/



/* ****** Object:  StoredProcedure [dbo].[stp_SAC_UPDATELOCALSTATIONALIVESTATUS]     Script Date: 10/08/2007 13:18:36 *******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_UPDATELOCALSTATIONALIVESTATUS]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_UPDATELOCALSTATIONALIVESTATUS]...'
	DROP PROCEDURE [dbo].[stp_SAC_UPDATELOCALSTATIONALIVESTATUS]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_UPDATELOCALSTATIONALIVESTATUS] ...'
GO
CREATE PROCEDURE [dbo].stp_SAC_UPDATELOCALSTATIONALIVESTATUS 
	@SERVER [varchar](30) 
AS
BEGIN
	--Verify whether this server already exist in database record or not
	DECLARE @COUNT INT 
	SET @COUNT = (SELECT COUNT(*) FROM [APP_LIVE_MONITORING] WHERE APP_CODE = @SERVER)
	
	--If do not have any record in database, insert new record into database
	IF @COUNT = 0
	BEGIN
		INSERT INTO [dbo].[APP_LIVE_MONITORING] ([APP_CODE],[TIME_STAMP],[LIVE_STATUS_TYPE],[DESCRIPTION]) 
			VALUES 
		(@SERVER, GETDATE(), 'UP', 
		@SERVER + ' connection status. UP:Connected, DOWN:Disconnected. Updated by server in 1 mins interval.')
	END
	ELSE --Else update the record to the existing record
	BEGIN
		UPDATE [BHSDB].[dbo].[APP_LIVE_MONITORING]
		   SET [TIME_STAMP] = GETDATE(), [LIVE_STATUS_TYPE] = 'UP' WHERE APP_CODE = @SERVER
	END
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_CHUTEAVAILABLECHECK]    Script Date: 29/01/2009 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_CHUTEAVAILABLECHECK]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_CHUTEAVAILABLECHECK]...'
	DROP PROCEDURE [dbo].[stp_SAC_CHUTEAVAILABLECHECK]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_CHUTEAVAILABLECHECK]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHUTEAVAILABLECHECK]
	@SubSystem varchar(10),
	@Destination varchar(20),
	@IsAvailable bit OUTPUT
AS
Begin
	--DECLARE @DesIsAvailable BIT
	SET @IsAvailable = (SELECT IS_AVAILABLE FROM dbo.DESTINATIONS WHERE DESTINATION = @Destination)	
End
GO



-- ****** Object:  StoredProcedure [dbo].[stp_SAC_ITEMTRACKING]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_ITEMTRACKING]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_ITEMTRACKING]...'
	DROP PROCEDURE [dbo].[stp_SAC_ITEMTRACKING]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_ITEMTRACKING]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_ITEMTRACKING] 
	@GID [varchar](10), 
	@SubSystem [varchar](10),
	@Location [varchar](20), 
	@LicensePlate [varchar](10),
	@TimeStamp [varchar](18),
	@Origin [varchar](10)
AS
BEGIN
	-- Step 1: Insert or Update new GID info into sortation working table [BAG_INFO].
	DECLARE	@No int
	SET @No =  (SELECT Count(*) FROM [BAG_INFO] WHERE [GID]=@GID)
	IF @No = 0
		BEGIN
			INSERT INTO [BAG_INFO] 
				([GID], [LICENSE_PLATE1], [LAST_LOCATION], [CREATED_BY], [TIME_STAMP]) 
			VALUES 
				(@GID, @LicensePlate, @Location, @Origin, GETDATE())
		END
	ELSE
		BEGIN
			UPDATE [BAG_INFO]
			SET [LAST_LOCATION]=@Location, [CREATED_BY]=@Origin, 
				[LICENSE_PLATE1]=@LicensePlate, [TIME_STAMP]= GETDATE()
			WHERE [GID]=@GID
		END

	-- Step 2: Insert Item Tracking Information event into event table [ITEM_TRACKING].
	INSERT INTO [ITEM_TRACKING]
		([TIME_STAMP], [GID], [SUBSYSTEM], [LOCATION], [LICENSE_PLATE],[PLC_TIMESTAMP]) 
	VALUES 
		(GETDATE(), @GID, @SubSystem, @Location, @LicensePlate,@TimeStamp)
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_CHUTESTATUSREPLY]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_CHUTESTATUSREPLY]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_CHUTESTATUSREPLY]...'
	DROP PROCEDURE [dbo].[stp_SAC_CHUTESTATUSREPLY]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_CHUTESTATUSREPLY]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_CHUTESTATUSREPLY] 
	@SubSystem [varchar](10),
	@Location [varchar](10), 
	@Status [varchar](2),
	@Origin [varchar](10)
AS
BEGIN
	DECLARE @VALUE bit
	
	-- Step 1: Update the new Status of the Chute.
	-- Only the @Status values '01' is available AND '02'so set the @Value to 1. 
	IF @Status = '01'
	BEGIN
		SET @VALUE = 1
	END
	ELSE
	BEGIN
		SET @VALUE = 0
	END

	UPDATE [DESTINATIONS] SET [IS_AVAILABLE] = @VALUE WHERE DESTINATION = @Location	
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_BAGMONITORING]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_BAGMONITORING]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_BAGMONITORING]...'
	DROP PROCEDURE [dbo].stp_SAC_BAGMONITORING
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_BAGMONITORING]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_BAGMONITORING]
	@hour int,
	@totalTelegram int OUTPUT,
	@correctTelegram bigint OUTPUT,
	@errorTelegram bigint OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	Declare @timeStamp datetime;
	Declare @resCount int;
	Declare @now datetime;

	BEGIN Try
	
		Set @now = GETDATE();
		
		IF @hour = 1
		    Set @timeStamp = DATEADD(hh, -1 , @now);
		ELSE IF @hour = 24
			Set @timeStamp = DATEADD(DD, -1 , @now);
    	ELSE IF @hour = 48
			Set @timeStamp = DATEADD(DD, -2 , @now);
		ELSE IF @hour = 72
			Set @timeStamp = DATEADD(DD, -3 , @now);
		ELSE IF @hour = 96
			Set @timeStamp = DATEADD(DD, -4 , @now);
		ELSE IF @hour = 120
			Set @timeStamp = DATEADD(DD, -5 , @now);
		ELSE IF @hour = 144
			Set @timeStamp = DATEADD(DD, -6 , @now);
		ELSE IF @hour = 168
			Set @timeStamp = DATEADD(DD, -7 , @now);
		
		SELECT @totalTelegram = COUNT(*) FROM [BAGS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now));
		
	    SELECT @correctTelegram = COUNT(*) FROM [BAGS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now) 
	    AND (ERROR_INDICATOR='0'));
	    
	    SELECT @errorTelegram = COUNT(*) FROM [BAGS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now) AND (ERROR_INDICATOR='1'));
		
		
	END Try
	BEGIN Catch
	
		Set @totalTelegram = 0;
		Set @correctTelegram = 0;
		Set @errorTelegram = 0;
		
	END Catch
END


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_FLIGHTMONITORING]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_FLIGHTMONITORING]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_FLIGHTMONITORING]...'
	DROP PROCEDURE [dbo].stp_SAC_FLIGHTMONITORING
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_FLIGHTMONITORING]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_FLIGHTMONITORING]
	@hour int,
	@totalTelegram int OUTPUT,
	@correctTelegram bigint OUTPUT,
	@errorTelegram bigint OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	Declare @timeStamp datetime;
	Declare @resCount int;
	Declare @now datetime;
	
	BEGIN Try
	
		Set @now = GETDATE();
		
		IF @hour = 1
		    Set @timeStamp = DATEADD(hh, -1 , @now);
		ELSE IF @hour = 24
			Set @timeStamp = DATEADD(DD, -1 , @now);
    	ELSE IF @hour = 48
			Set @timeStamp = DATEADD(DD, -2 , @now);
		ELSE IF @hour = 72
			Set @timeStamp = DATEADD(DD, -3 , @now);
		ELSE IF @hour = 96
			Set @timeStamp = DATEADD(DD, -4 , @now);
		ELSE IF @hour = 120
			Set @timeStamp = DATEADD(DD, -5 , @now);
		ELSE IF @hour = 144
			Set @timeStamp = DATEADD(DD, -6 , @now);
		ELSE IF @hour = 168
			Set @timeStamp = DATEADD(DD, -7 , @now);

			
		SELECT @totalTelegram = COUNT(*) FROM [FLIGHT_PLANS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now));
		
		SELECT @correctTelegram = COUNT(*) FROM [FLIGHT_PLANS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now)
		 AND (ERROR_INDICATOR='0'));
		
		SELECT @errorTelegram = COUNT(*) FROM [FLIGHT_PLANS] WHERE ((TIME_STAMP >= @timeStamp) AND (TIME_STAMP < @now)
		 AND (ERROR_INDICATOR='1'));
			
	END Try
	BEGIN Catch
	
		Set @totalTelegram = 0;
		Set @correctTelegram = 0;
		Set @errorTelegram = 0;
		
	END Catch
END


-- ****** Object:  StoredProcedure [dbo].[stp_SAC_FIDSBISTIMESTAMPMonitor]    Script Date: 10/08/2007 13:18:36 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_SAC_FIDSBISTIMESTAMPMonitor]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_SAC_FIDSBISTIMESTAMPMonitor]...'
	DROP PROCEDURE [dbo].[stp_SAC_FIDSBISTIMESTAMPMonitor]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_SAC_FIDSBISTIMESTAMPMonitor]...'
GO
CREATE PROCEDURE [dbo].[stp_SAC_FIDSBISTIMESTAMPMonitor]
	@Type varchar(4),
	@totalTimeStamp datetime OUTPUT,
	@correctTimeStamp datetime OUTPUT,
	@errorTimeStamp datetime OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN Try
	
		IF @Type = 'FIDS'
		BEGIN
			SELECT @totalTimeStamp = MAX(TIME_STAMP) FROM [FLIGHT_PLANS];
			SELECT @correctTimeStamp = MAX(TIME_STAMP) FROM [FLIGHT_PLAN_SORTING] --WHERE CREATED_BY='FIDS';
			SELECT @errorTimeStamp = MAX(TIME_STAMP) FROM [FLIGHT_PLAN_ERROR];
		END 
		ELSE IF @Type = 'BIS'
		BEGIN
			SELECT @totalTimeStamp = MAX(TIME_STAMP) FROM [BAGS];
			SELECT @correctTimeStamp = MAX(TIME_STAMP) FROM [BAG_SORTING] --WHERE CREATED_BY='BIS';
			SELECT @errorTimeStamp = MAX(TIME_STAMP) FROM [BAG_ERROR_BSM];
		END 
			
	END Try
	BEGIN Catch
	
		Set @totalTimeStamp = null;
		Set @correctTimeStamp = null;
		Set @errorTimeStamp = null;
		
	END Catch
END




GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED]    Script Date: 01/26/2010 15:25:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED]...'
	DROP PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONCREATEDUPDATED] 
	@Airline [varchar](3), 
	@FlightNumber [varchar](5),
	@FlightNumberSuffix [varchar](3), 
	@SDO [varchar](8),
	@Handler [varchar](20),	
	@STO [varchar](14),
	@ETO [varchar](14),
	@ITO [varchar](14),
	@ATO [varchar](14),
	@OffBlockTime [varchar](14),
	@FinalDest [varchar](3),
	@Dest1 [varchar](3),
	@Dest2 [varchar](3),
	@Dest3 [varchar](3),
	@Dest4 [varchar](3),
	@Dest5 [varchar](3),	
	@Cancellation [varchar](1),
	@AircaftType [varchar](4),
	@AircraftConfig [varchar](12),
	@Version [varchar](12),
	@Terminal [varchar](5),
	@CheckInArea [varchar](10),
	@CheckInStatus [varchar](10),
	@RemarkCode [varchar](10),	
	@Pier [varchar](5),	
	@Gate [varchar](5),	
	@ParkingStand [varchar](5),
	@Nature [varchar](15),
	@SortingDest [varchar](10),
	@GeneralPurpose [varchar](40),
	@Exception [varchar](10),
	@MasterAirline [varchar](3),	
	@MasterFlightNumber [varchar](5),
	@MasterFlightNumberSuffix [varchar](3),
	@MasterSDO [varchar](8),
	@ID BIGINT
AS
BEGIN


	DECLARE @DATE_SDO DATETIME = CONVERT (varchar(8),@SDO,112)
	
	DECLARE @HOUR_STO VARCHAR(2) = SUBSTRING(@STO,9,2)
	DECLARE @MINS_STO VARCHAR(2) = SUBSTRING(@STO,11,2)
	DECLARE @SECS_STO VARCHAR(2) = SUBSTRING(@STO,13,2)	
	DECLARE @TIME_STO VARCHAR(14) = @HOUR_STO + ':' + @MINS_STO + ':' + @SECS_STO
	DECLARE @DATE_STO DATETIME = CONVERT (varchar(8),@STO,112)
	
	DECLARE @HOUR_ETO VARCHAR(2) = SUBSTRING(@ETO,9,2)
	DECLARE @MINS_ETO VARCHAR(2) = SUBSTRING(@ETO,11,2)
	DECLARE @SECS_ETO VARCHAR(2) = SUBSTRING(@ETO,13,2)	
	DECLARE @TIME_ETO VARCHAR(14) = @HOUR_STO + ':' + @MINS_STO + ':' + @SECS_STO
	DECLARE @DATE_ETO DATETIME = CONVERT (varchar(8),@ETO,112)
	
	DECLARE @HOUR_ATO VARCHAR(2) = SUBSTRING(@ATO,9,2)
	DECLARE @MINS_ATO VARCHAR(2) = SUBSTRING(@ATO,11,2)
	DECLARE @SECS_ATO VARCHAR(2) = SUBSTRING(@ATO,13,2)	
	DECLARE @TIME_ATO VARCHAR(14) = @HOUR_ATO + ':' + @MINS_ATO + ':' + @SECS_ATO
	DECLARE @DATE_ATO DATETIME = CONVERT (varchar(8),@ATO,112)
	
	DECLARE @HOUR_ITO VARCHAR(2) = SUBSTRING(@ITO,9,2)
	DECLARE @MINS_ITO VARCHAR(2) = SUBSTRING(@ITO,11,2)
	DECLARE @SECS_ITO VARCHAR(2) = SUBSTRING(@ITO,13,2)	
	DECLARE @TIME_ITO VARCHAR(14) = @HOUR_ITO + ':' + @MINS_ITO + ':' + @SECS_ITO
	DECLARE @DATE_ITO DATETIME = CONVERT (varchar(8),@ITO,112)
	
	SET DATEFIRST 1
	DECLARE @WEEKDAY CHAR(1) = (SELECT CAST(DATEPART(weekday, (@DATE_STO + CONVERT (varchar(8),@TIME_STO,108))) AS CHAR(1)))
	
	--DECLARE @SDO_DATETIME datetime = (@DATE_STO + CONVERT (varchar(8),@TIME_STO,108))
	
	DECLARE @HIGH_RISK CHAR(1)
	IF @Exception ='RISK'
	BEGIN
		SET @HIGH_RISK = 'Y'
	END
	ELSE
	BEGIN
		SET @HIGH_RISK = 'N'
	END	
				
	DECLARE @COUNT INT = (SELECT COUNT(*) FROM FLIGHT_PLAN_SORTING 
							WHERE AIRLINE = @Airline AND FLIGHT_NUMBER = @FlightNumber AND 
							SDO  = @DATE_SDO AND STO = (@HOUR_STO + @MINS_STO))		
							
	IF @COUNT = 0
	BEGIN
		INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_SORTING]
				   ([TIME_STAMP], [DATA_ID], [AIRLINE], [FLIGHT_NUMBER], [FLIGHT_NUMBER_SUFFIX], [HANDLER],
				   [SDO], [STO], [EDO], [ETO], [ADO], [ATO], [IDO], [ITO],
				   [BLOCK_OFF_TIME], [FINAL_DEST], [DEST1], [DEST2], [DEST3], [DEST4], [DEST5],
				   [CANCELLED], [AIRCRAFT_TYPE], [HANDLER_SPECIFIC_DESC], [AIRCRAFT_VERSION], [TERMINAL],
				   [CHECKIN_AREA], [CHECKIN_STATUS], [PUBLIC_REMARK_CODE], [PIER], [GATE], [PARKING_STAND],
				   [NATURE], [SORTING_DEST1], [GENERAL_PURPOSE], [FI_EXCEPTION], [MASTER_AIRLINE],
				   [MASTER_FLIGHT_NUMBER], [MASTER_FLIGHT_NUMBER_SUFFIX], [MASTER_SDO], 
				   [WEEKDAY], [HIGH_RISK], [CREATED_BY], [IS_ALLOCATED])
			 VALUES
				   (GETDATE(), @ID, @Airline, @FlightNumber, @FlightNumberSuffix, @Handler,
				   @DATE_SDO,  @HOUR_STO + @MINS_STO, @DATE_ETO, @HOUR_ETO + @MINS_ETO, @DATE_ATO, @HOUR_ATO + @MINS_ATO, @DATE_ITO, @HOUR_ITO + @MINS_ITO,
				   @OffBlockTime, @FinalDest, @Dest1, @Dest2, @Dest3, @Dest4, @Dest5,
				   @Cancellation, @AircaftType, @AircraftConfig, @Version, @Terminal,
				   @CheckInArea, @CheckInStatus, @RemarkCode, @Pier, @Gate, @ParkingStand,
				   @Nature, @SortingDest, @GeneralPurpose, @Exception,
				   @MasterAirline, @MasterFlightNumber, @MasterFlightNumberSuffix, @MasterSDO,
				   @WEEKDAY, @HIGH_RISK, 'FIS', 0)	
	END	
	ELSE
	BEGIN
		UPDATE [BHSDB].[dbo].[FLIGHT_PLAN_SORTING]
			 SET [TIME_STAMP] = GETDATE(), [DATA_ID] = @ID, [AIRLINE] = @Airline, [FLIGHT_NUMBER] = @FlightNumber,
			 [FLIGHT_NUMBER_SUFFIX] = @FlightNumberSuffix, [HANDLER] = @Handler, [SDO] = @DATE_SDO,
			  [STO] = @HOUR_STO + @MINS_STO, [EDO] = @DATE_ETO, [ETO] = @HOUR_ETO + @MINS_ETO, 
			  [ADO] = @DATE_ATO, [ATO] = @HOUR_ATO + @MINS_ATO, [IDO] = @DATE_ITO, [ITO] = @HOUR_ITO + @MINS_ITO,
			  [BLOCK_OFF_TIME] = @OffBlockTime, [FINAL_DEST] = @FinalDest, [DEST1] = @Dest1, [DEST2] = @Dest2,
			  [DEST3] = @Dest3, [DEST4] = @Dest4, [DEST5] = @Dest5, [CANCELLED] = @Cancellation, [AIRCRAFT_TYPE] = @AircaftType,
			  [HANDLER_SPECIFIC_DESC] = @AircraftConfig, [AIRCRAFT_VERSION] = @Version, [TERMINAL] = @Terminal,
			  [CHECKIN_AREA] = @CheckInArea, [CHECKIN_STATUS] = @CheckInStatus, [PUBLIC_REMARK_CODE] = @RemarkCode,
			  [PIER] = @Pier, [GATE] = @Gate, [PARKING_STAND] = @ParkingStand, [NATURE] = @Nature,
			  [SORTING_DEST1] = @SortingDest, [GENERAL_PURPOSE] = @GeneralPurpose, [FI_EXCEPTION] = @Exception,
			  [MASTER_AIRLINE] = @MasterAirline, [MASTER_FLIGHT_NUMBER] = @MasterFlightNumber,
			  [MASTER_FLIGHT_NUMBER_SUFFIX] = @MasterFlightNumberSuffix, [MASTER_SDO] = @MasterSDO,
			  [WEEKDAY] = @WEEKDAY, [HIGH_RISK] = @HIGH_RISK, [CREATED_BY] = 'FIS'
		 WHERE AIRLINE = @Airline AND FLIGHT_NUMBER = @FlightNumber AND SDO = @DATE_SDO;
	END					

	DECLARE @EARLY_OPEN_OFFSET varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ERLY_OPEN_OFFSET')
	DECLARE @EARLY_OPEN_ENABLED varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ERLY_OPEN_ENABLED')
	DECLARE @ALLOC_OPEN_OFFSET varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_OPEN_OFFSET')
	DECLARE @ALLOC_OPEN_RELATED varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_OPEN_RELATED')
	DECLARE @ALLOC_CLOSE_OFFSET varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_CLOSE_OFFSET')
	DECLARE @ALLOC_CLOSE_RELATED varchar(15) = (SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'ALLOC_CLOSE_RELATED')
	DECLARE @RUSH_DURATION varchar(15) = ('00'+(SELECT [SYS_VALUE]  FROM [BHSDB].[dbo].[SYS_CONFIG] WHERE [SYS_KEY] = 'RUSH_DURATION'))


	IF @Pier != NULL OR @Pier != ''
	BEGIN
		DECLARE @COUNT_PIER int = (SELECT COUNT(*) FROM [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC] 
								WHERE [AIRLINE] = @Airline AND [FLIGHT_NUMBER] = @FlightNumber AND [SDO] = @DATE_SDO)
		--print 'Number of record = ' + cast(@COUNT as varchar(10))
		IF @COUNT_PIER = 0
		BEGIN
		INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC]
				   ([AIRLINE], [FLIGHT_NUMBER], [SDO], 
				   [STO], [RESOURCE], [WEEKDAY],
				   [EDO], [ETO], 
				   [ADO], [ATO], 
				   [IDO], [ITO], 
				   [EARLY_OPEN_OFFSET], [EARLY_OPEN_ENABLED], [ALLOC_OPEN_OFFSET], [ALLOC_OPEN_RELATED],
				   [ALLOC_CLOSE_OFFSET], [ALLOC_CLOSE_RELATED], [RUSH_DURATION], [CREATED_BY], [TIME_STAMP])
			 VALUES
					(@Airline, @FlightNumber, @DATE_SDO,
					(@HOUR_STO + @MINS_STO), @Pier, @WEEKDAY,
					(@DATE_ETO ), (@HOUR_ETO + @MINS_ETO),
					(@DATE_ATO ), (@HOUR_ATO + @MINS_ATO), 
					(@DATE_ITO ), (@HOUR_ITO + @MINS_ITO), 
					@EARLY_OPEN_OFFSET, @EARLY_OPEN_ENABLED, @ALLOC_OPEN_OFFSET, @ALLOC_OPEN_RELATED, 
					@ALLOC_CLOSE_OFFSET, @ALLOC_CLOSE_RELATED, @RUSH_DURATION, 'FIS', GETDATE()) 
		END	
		ELSE
		BEGIN
			UPDATE [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC]
			   SET [STO] = (@HOUR_STO + @MINS_STO), [RESOURCE] = @Pier, [WEEKDAY] = @WEEKDAY
				  , [EDO] = @DATE_ETO, [ETO] = (@HOUR_ETO + @MINS_ETO), [ADO] = @DATE_ATO
				  , [ATO] = (@HOUR_ATO + @MINS_ATO), [IDO] = @DATE_ITO, [ITO] = (@HOUR_ITO + @MINS_ITO)
				  , [CREATED_BY] = 'FIS', [TIME_STAMP] = GETDATE()
			 WHERE [AIRLINE] = @Airline AND [FLIGHT_NUMBER] = @FlightNumber AND [SDO] = @DATE_SDO
		END					 
     END
END


GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_ERRORMESSAGE]    Script Date: 01/26/2010 15:27:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_ERRORMESSAGE]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_ERRORMESSAGE]...'
	DROP PROCEDURE [dbo].[stp_FIS_ERRORMESSAGE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_ERRORMESSAGE]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_ERRORMESSAGE] 
	@Description [varchar](200),
	@ID bigint,
	@Indicator [char] (1)
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_ERROR]
			   ([DATA_ID], [TIME_STAMP], [DESCRIPTION])
		 VALUES
			   (@ID, GETDATE(), @Description)
           
	UPDATE [BHSDB].[dbo].[FLIGHT_PLANS]
	   SET [ERROR_INDICATOR] = @Indicator
	 WHERE ID = @ID;           

END


GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED]    Script Date: 01/26/2010 15:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED]...'
	DROP PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTINFORMATIONDELETED] 
	@Airline [varchar](3), 
	@FlightNumber [varchar](5),
	@FlightNumberSuffix [varchar](3), 
	@SDO [varchar](8)
AS
BEGIN							
	DELETE FROM [FLIGHT_PLAN_SORTING] WHERE 
		AIRLINE = @Airline AND FLIGHT_NUMBER = @FlightNumber AND SDO = CONVERT (varchar(8),@SDO,112);
END



GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED]    Script Date: 01/26/2010 15:30:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED]...'
	DROP PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONDELETED]
	@Airline [varchar](3), 
	@FlightNumber [varchar](5),
	@SDO [varchar](8), 
	@SortingDest [varchar](10)
AS		
BEGIN
	INSERT INTO [BHSDB].[dbo].[DEPARTURE_FLIGHT_ALLOC_DELETED]
			   ([TIME_STAMP], [AIRLINE], [FLIGHT_NUMBER], [SDO], [RESOURCE])
		 VALUES
			   (GETDATE(), @Airline, @FlightNumber, @SDO, @SortingDest)
END	  



GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY]    Script Date: 01/26/2010 15:32:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY]...'
	DROP PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_DEPARTUREFLIGHTALLOCATIONREPLY] 
	@Airline [varchar](3), 
	@FlightNumber [varchar](5),
	@SDO [varchar](8), 
	@SortingDest [varchar](10),	
	@AllocState [varchar](10), 
	@AllocOpenTime [varchar](14),	
	@AllocCloseTime [varchar](14), 
	@TravelClass [varchar](1)
AS		
BEGIN
	INSERT INTO [BHSDB].[dbo].[DEPARTURE_FLIGHT_ALLOC_REPLY]
			   ([TIME_STAMP], [AIRLINE], [FLIGHT_NUMBER], [SDO], [RESOURCE], [STATE], [OPEN_TIME], 
			   [CLOSE_TIME], [TRAVEL_CLASS])
		 VALUES
			   (GETDATE(), @Airline, @FlightNumber, @SDO, @SortingDest, @AllocState, @AllocOpenTime,
			   @AllocCloseTime, @TravelClass)
END	 



GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONDELETED]    Script Date: 01/26/2010 15:33:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONDELETED]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_DEPARTUREFUNCTIONTALLOCATIONDELETED]...'
	DROP PROCEDURE [dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONDELETED]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_DEPARTUREFUNCTIONTALLOCATIONDELETED]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONDELETED]
	@FunctionType [varchar](4), 
	@FunctionData [varchar](5),
	@SortingDest [varchar](10)
AS		
BEGIN
	INSERT INTO [BHSDB].[dbo].[DEPARTURE_FUNCTION_ALLOC_DELETED]
			   ([TIME_STAMP], [FUNCTION_TYPE], [FUNCTION_DATA], [RESOURCE])
		 VALUES
			   (GETDATE(), @FunctionType, @FunctionData, @SortingDest)
END	 



GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONREPLY]    Script Date: 01/26/2010 15:34:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONREPLY]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_DEPARTUREFUNCTIONTALLOCATIONREPLY]...'
	DROP PROCEDURE [dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONREPLY]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_DEPARTUREFUNCTIONTALLOCATIONREPLY]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_DEPARTUREFUNCTIONTALLOCATIONREPLY] 
	@FunctionType [varchar](4), 
	@FunctionData [varchar](5),
	@SortingDest [varchar](10)
AS		
BEGIN
	INSERT INTO [BHSDB].[dbo].[DEPARTURE_FUNCTION_ALLOC_REPLY]
			   ([TIME_STAMP], [FUNCTION_TYPE], [FUNCTION_DATA], [RESOURCE])
		 VALUES
			   (GETDATE(), @FunctionType, @FunctionData, @SortingDest)
END	



GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_GETBHSFISOUTGOINGALLOCATIONS]    Script Date: 01/26/2010 15:35:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_GETBHSFISOUTGOINGALLOCATIONS]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_GETBHSFISOUTGOINGALLOCATIONS]...'
	DROP PROCEDURE [dbo].[stp_FIS_GETBHSFISOUTGOINGALLOCATIONS]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_GETBHSFISOUTGOINGALLOCATIONS]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_GETBHSFISOUTGOINGALLOCATIONS] 
AS
BEGIN
	DECLARE @TEMP TABLE (ID int, ALLOC_TYPE varchar(10), ACTION varchar(10), AIRLINE varchar(3), FLIGHT_NUMBER varchar(5),
					SDO varchar(8), RESOURCE varchar(10), ALLOC_STATE varchar(10), OPEN_TIME varchar(14), CLOSE_TIME varchar(14),
					TRAVEL_CLASS varchar(1), FUNCTION_TYPE varchar(4), FUNCTION_DATA varchar(5), FUNCTION_IS_CLOSED bit)
	
	INSERT INTO @TEMP 
	SELECT ID, ALLOC_TYPE, ACTION, AIRLINE, FLIGHT_NUMBER, CAST( CONVERT (varchar(8),SDO,112) AS VARCHAR(8)) AS SDO, RESOURCE, STATE AS ALLOC_STATE, 
		 CAST( CONVERT (varchar(8),OPEN_TIME,112) AS VARCHAR(8)) + SUBSTRING(CAST(CONVERT (varchar(8),OPEN_TIME,108) AS VARCHAR(8)),1,2)
			+ SUBSTRING(CAST(CONVERT (varchar(8),OPEN_TIME,108) AS VARCHAR(8)),4,2) + SUBSTRING(CAST(CONVERT (varchar(8),OPEN_TIME,108) AS VARCHAR(8)),7,2)
		AS OPEN_TIME, 
		CAST( CONVERT (varchar(8),CLOSE_TIME,112) AS VARCHAR(8)) + SUBSTRING(CAST(CONVERT (varchar(8),CLOSE_TIME,108) AS VARCHAR(8)),1,2)
			+ SUBSTRING(CAST(CONVERT (varchar(8),CLOSE_TIME,108) AS VARCHAR(8)),4,2) + SUBSTRING(CAST(CONVERT (varchar(8),CLOSE_TIME,108) AS VARCHAR(8)),7,2)
		AS CLOSE_TIME, TRAVEL_CLASS, FUNCTION_TYPE, FUNCTION_DATA, FUNCTION_IS_CLOSED
		FROM dbo.BHS_FIS_OUTGOING_ALLOCATIONS 
	
		
	DELETE FROM BHS_FIS_OUTGOING_ALLOCATIONS WHERE ID IN (SELECT ID FROM @TEMP)
	
	SELECT ALLOC_TYPE, ACTION, AIRLINE, FLIGHT_NUMBER, SDO, RESOURCE, ALLOC_STATE, OPEN_TIME, CLOSE_TIME,
					TRAVEL_CLASS, FUNCTION_TYPE, FUNCTION_DATA, FUNCTION_IS_CLOSED FROM @TEMP
END	



GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY]    Script Date: 01/26/2010 15:36:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY]...'
	DROP PROCEDURE [dbo].[stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_GETDEPARTUREFLIGHTALLOCATIONREPLY] 
AS
BEGIN

SELECT AIRLINE, FLIGHT_NUMBER, SDO, RESOURCE,  
	CASE WHEN GETDATE() < (DATEADD(MINUTE, EARLY_OFFSET,OPEN_TIME))
				THEN 'TOOEARLY'
		 WHEN GETDATE() >= (DATEADD(MINUTE, EARLY_OFFSET,OPEN_TIME)) AND GETDATE() < OPEN_TIME
				THEN 'EBS'
		 WHEN GETDATE() >= OPEN_TIME AND GETDATE() < DATEADD(MINUTE,-1*RUSH_DURATION,CLOSE_TIME)
				THEN 'OPEN'
		 WHEN GETDATE() >= DATEADD(MINUTE,-1*RUSH_DURATION,CLOSE_TIME)  AND GETDATE() < CLOSE_TIME 
				THEN 'RUSH'
		 WHEN GETDATE() > CLOSE_TIME 
				THEN 'LATE'
	END AS ALLOC_STATE,
	 CAST( CONVERT (varchar(8),OPEN_TIME,112) AS VARCHAR(8)) + SUBSTRING(CAST(CONVERT (varchar(8),OPEN_TIME,108) AS VARCHAR(8)),1,2)
		+ SUBSTRING(CAST(CONVERT (varchar(8),OPEN_TIME,108) AS VARCHAR(8)),4,2) + SUBSTRING(CAST(CONVERT (varchar(8),OPEN_TIME,108) AS VARCHAR(8)),7,2)
	AS OPEN_TIME, 
	 CAST( CONVERT (varchar(8),CLOSE_TIME,112) AS VARCHAR(8)) + SUBSTRING(CAST(CONVERT (varchar(8),CLOSE_TIME,108) AS VARCHAR(8)),1,2)
		+ SUBSTRING(CAST(CONVERT (varchar(8),CLOSE_TIME,108) AS VARCHAR(8)),4,2) + SUBSTRING(CAST(CONVERT (varchar(8),CLOSE_TIME,108) AS VARCHAR(8)),7,2)
	AS CLOSE_TIME, TRAVEL_CLASS  FROM 
	(SELECT [AIRLINE],
		  [FLIGHT_NUMBER],
		  CAST( CONVERT (varchar(8),SDO,112) AS VARCHAR(8)) AS SDO,
		  [RESOURCE],
		  CASE WHEN LEN(ALLOC_OPEN_OFFSET) = 4 
					THEN	(CAST(SUBSTRING(ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,3,2) AS INT))
				 WHEN LEN(ALLOC_OPEN_OFFSET) = 5 
					THEN ((CAST(SUBSTRING(ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
		  END AS OPEN_OFFSET,
		  CASE WHEN ALLOC_OPEN_RELATED = 'STD' 
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_OPEN_OFFSET) = 4 
									THEN	(CAST(SUBSTRING(ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_OPEN_OFFSET) = 5 
									THEN ((CAST(SUBSTRING(ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,SDO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(STO,1,2) + ':' + SUBSTRING(STO,3,2)  ,108) AS TIME))				
					))
				WHEN ALLOC_OPEN_RELATED = 'ETD'
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_OPEN_OFFSET) = 4 
									THEN	(CAST(SUBSTRING(ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_OPEN_OFFSET) = 5 
									THEN ((CAST(SUBSTRING(ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,EDO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(ETO,1,2) + ':' + SUBSTRING(ETO,3,2)  ,108) AS TIME))
					)) 
				WHEN ALLOC_OPEN_RELATED = 'ATD'
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_OPEN_OFFSET) = 4 
									THEN	(CAST(SUBSTRING(ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_OPEN_OFFSET) = 5 
									THEN ((CAST(SUBSTRING(ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,ADO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(ATO,1,2) + ':' + SUBSTRING(ATO,3,2)  ,108) AS TIME))
					)) 
				WHEN ALLOC_OPEN_RELATED = 'ITD'
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_OPEN_OFFSET) = 4 
									THEN	(CAST(SUBSTRING(ALLOC_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_OPEN_OFFSET) = 5 
									THEN ((CAST(SUBSTRING(ALLOC_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_OPEN_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,IDO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(ITO,1,2) + ':' + SUBSTRING(ITO,3,2)  ,108) AS TIME))
					)) 				
		  END AS OPEN_TIME,
		  CASE WHEN LEN(ALLOC_CLOSE_OFFSET) = 4
					THEN (CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,3,2) AS INT))
				 WHEN LEN(ALLOC_CLOSE_OFFSET) = 5
					THEN ((CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
		  END AS CLOSE_OFFSET,				
		  CASE WHEN ALLOC_CLOSE_RELATED = 'STD' 
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_CLOSE_OFFSET) = 4
									THEN (CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_CLOSE_OFFSET) = 5
									THEN ((CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,SDO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(STO,1,2) + ':' + SUBSTRING(STO,3,2)  ,108) AS TIME))				
					))
				WHEN ALLOC_CLOSE_RELATED = 'ETD'
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_CLOSE_OFFSET) = 4
									THEN (CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_CLOSE_OFFSET) = 5
									THEN ((CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,EDO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(ETO,1,2) + ':' + SUBSTRING(ETO,3,2)  ,108) AS TIME))
					)) 
				WHEN ALLOC_CLOSE_RELATED = 'ATD'
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_CLOSE_OFFSET) = 4
									THEN (CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_CLOSE_OFFSET) = 5
									THEN ((CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,ADO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(ATO,1,2) + ':' + SUBSTRING(ATO,3,2)  ,108) AS TIME))
					)) 
				WHEN ALLOC_CLOSE_RELATED = 'ITD'
					THEN (DATEADD(MINUTE,
							CASE WHEN LEN(ALLOC_CLOSE_OFFSET) = 4
									THEN (CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,3,2) AS INT))
								 WHEN LEN(ALLOC_CLOSE_OFFSET) = 5
									THEN ((CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(ALLOC_CLOSE_OFFSET,4,2) AS INT))*-1)
							END,
							(CAST((CONVERT(DATE,IDO, 111)) AS DATETIME) +
								CAST (CONVERT(VARCHAR(5), SUBSTRING(ITO,1,2) + ':' + SUBSTRING(ITO,3,2)  ,108) AS TIME))
					)) 				
		  END AS CLOSE_TIME,
		  [TRAVEL_CLASS],
		  (CAST((SUBSTRING(RUSH_DURATION,1,2)*60 + SUBSTRING(RUSH_DURATION,3,2)) AS INT)) AS RUSH_DURATION,
		  CASE WHEN LEN(EARLY_OPEN_OFFSET) = 4
					THEN (CAST(SUBSTRING(EARLY_OPEN_OFFSET,1,2) AS INT)*60 + CAST(SUBSTRING(EARLY_OPEN_OFFSET,3,2) AS INT))
			   WHEN LEN(EARLY_OPEN_OFFSET) = 5
					THEN ((CAST(SUBSTRING(EARLY_OPEN_OFFSET,2,2) AS INT)*60 + CAST(SUBSTRING(EARLY_OPEN_OFFSET,4,2) AS INT))*-1)
		  END AS EARLY_OFFSET
	  FROM [BHSDB].[dbo].[FLIGHT_PLAN_ALLOC] ) AS TEMP_TABLE 
	  WHERE SDO = CAST( CONVERT (varchar(8),GETDATE(),112) AS VARCHAR(8))
	  ORDER BY AIRLINE, FLIGHT_NUMBER
END	  


GO
/****** Object:  StoredProcedure [dbo].[stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY]...'
	DROP PROCEDURE [dbo].[stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_GETDEPARTUREFUNCTIONTALLOCATIONREPLY] 
AS		
BEGIN
	SELECT FUNCTION_TYPE, '' AS FUNCTION_DATA, RESOURCE FROM dbo.FUNCTION_ALLOC_LIST
	UNION
	SELECT FUNCTION_TYPE, EXCEPTION AS FUNCTION_DATA, RESOURCE FROM FUNCTION_ALLOC_GANTT WHERE IS_CLOSED = 0
	ORDER BY FUNCTION_TYPE
END	

GO
/****** Object:  StoredProcedure [dbo].[stp_UPDATECHANGEDCONNECTIONMONITORING]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_UPDATECHANGEDCONNECTIONMONITORING]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_UPDATECHANGEDCONNECTIONMONITORING]...'
	DROP PROCEDURE [dbo].[stp_UPDATECHANGEDCONNECTIONMONITORING]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_UPDATECHANGEDCONNECTIONMONITORING]...'
GO
CREATE PROCEDURE [dbo].[stp_UPDATECHANGEDCONNECTIONMONITORING] 
	@Status [varchar](5), 
	@AppCode [varchar](30)
AS		
BEGIN
	UPDATE [BHSDB].[dbo].[APP_LIVE_MONITORING]
		  SET [TIME_STAMP] = GETDATE(), [LIVE_STATUS_TYPE] = @Status
	 WHERE APP_CODE = @AppCode 
END	


GO
/****** Object:  StoredProcedure [dbo].[stp_BSI_ERRORMESSAGE]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_BSI_ERRORMESSAGE]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_BSI_ERRORMESSAGE]...'
	DROP PROCEDURE [dbo].[stp_BSI_ERRORMESSAGE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_BSI_ERRORMESSAGE]...'
GO
CREATE PROCEDURE [dbo].[stp_BSI_ERRORMESSAGE]
	@ID bigint, 
	@Description [varchar](200),
	@Indicator [char] (1)
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[BAG_ERROR_BSM]
			   ([DATA_ID], [TIME_STAMP], [DESCRIPTION])
		 VALUES
			   (@ID, GETDATE(), @Description)
			   
	UPDATE [BHSDB].[dbo].[BAGS]
	   SET [ERROR_INDICATOR] = @Indicator
	 WHERE ID = @ID;

END


GO
/****** Object:  StoredProcedure [dbo].[stp_BSI_INSERTBSM]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_BSI_INSERTBSM]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_BSI_INSERTBSM]...'
	DROP PROCEDURE [dbo].[stp_BSI_INSERTBSM]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_BSI_INSERTBSM]...'
GO
CREATE PROCEDURE [dbo].[stp_BSI_INSERTBSM] 
	@ID bigint,
	@ACTION [varchar](10), 
	@DICTIONARY_VERSION int, 
	@SOURCE_INDICATOR [varchar](2), 
	@AIRPORT_CODE [varchar](5),	
	@LICENSE_PLATE [varchar](10), 
	@AIRLINE [varchar](3), 
	@FLIGHT_NUMBER [varchar](5),
	@SDO [varchar](5),  
	@DESTINATION [varchar](5), 
	@TRAVEL_CLASS [varchar](1),
	@INBOUND_AIRLINE [varchar](3), 
	@INBOUND_FLIGHT_NUMBER [varchar](5),
	@INBOUND_SDO [varchar](5),  
	@INBOUND_AIRPORT_CODE [varchar](5),
	@INBOUND_TRAVEL_CLASS [varchar](1), 
	@ONWARD_AIRLINE [varchar](3),
	@ONWARD_FLIGHT_NUMBER [varchar](5), 
	@ONWARD_SDO [varchar](5), 
	@ONWARD_AIRPORT_CODE [varchar](5), 
	@ONWARD_TRAVEL_CLASS [varchar](1),
	@NO_PASSENGER_SAME_SURNAME int,	
	@SURNAME [nvarchar](30),
	@GIVEN_NAME [nvarchar](30), 
	@OTHERS_NAME [nvarchar](30),
	@BAG_EXCEPTION [varchar](10),
	@CHECK_IN_COUNTER [varchar](10),
	@CHECK_IN_COUNTER_DESCRIPTION [varchar](20),
	@CHECK_IN_DATE [varchar](5),
	@CHECK_IN_TIME [varchar](7),
	@CHECK_IN_CARRIAGE_MEDIUM [varchar](5),
	@CHECK_IN_TRANSPORT_ID [varchar](20),
	@TAG_PRINTER_ID [varchar](10),
	@RECONCILIATION_LOAD_AUTHORITY [varchar](1),
	@RECONCILIATION_SEAT_NUMBER [varchar](5),
	@RECONCILIATION_PASSENGER_STATUS [varchar](1),
	@RECONCILIATION_SEQUENCE_NUMBER [varchar](3),
	@RECONCILIATION_SECURITY_NUMBER [varchar](3),
	@RECONCILIATION_PASSENGER_PROFILES_STATUS [varchar](1),
	@RECONCILIATION_TRANSPORT_AUTHORITY [varchar](1),
	@RECONCILIATION_BAG_TAG_STATUS [varchar](1),
	@HANDLING_TERMINAL [varchar](10),
	@HANDLING_BAR [varchar](10),
	@HANDLING_GATE [varchar](10),
	@WEIGHT_INDICATOR [varchar](1),
	@WEIGHT_CHECKED_BAG_NUMBER int,
	@CHECKED_WEIGHT int,
	@UNCHECKED_WEIGHT int,
	@WEIGHT_UNIT [varchar](2),
	@WEIGHT_LENGTH int,
	@WEIGHT_WIDTH int,
	@WEIGHT_HEIGHT int,
	@WEIGHT_BAG_TYPE_CODE [varchar](10),
	@GROUND_TRANSPORT_EARLIEST_DELIVERY [varchar](9),
	@GROUND_TRANSPORT_LATEST_DELIVERY [varchar](9),
	@GROUND_TRANSPORT_DESCRIPTION [varchar](200),
	@FREQUENT_TRAVELLER_ID_NUMBER [varchar](25),
	@FREQUENT_TRAVELLER_TIER_ID [varchar](25),
	@CORPORATE_NAME [varchar](20),
	@AUTOMATED_PNR_ADDRESS [varchar](20),
	@MESSAGE_PRINTER_ID [varchar](10),
	@INTERNAL_AIRLINE_DATA [varchar](60),
	@SECURITY_SCREENING_INSTRUCTION [varchar](3),
	@SECURITY_SCREENING_RESULT [varchar](3),
	@SECURITY_SCREENING_RESULT_REASON [varchar](1),
	@SECURITY_SCREENING_RESULT_METHOD [varchar](5),
	@SECURITY_SCREENING_AUTOGRAPH [varchar](10),
	@SECURITY_SCREENING_FREE_TEXT [varchar](40),	
	@MULTIPLE_BSM_ACTION [varchar](2),
	@MULTIPLE_BSM_ACTION_NOTHING [varchar](2),
	@MULTIPLE_BSM_ACTION_INSERT [varchar](2),
	@MULTIPLE_BSM_ACTION_UPDATE [varchar](2)		
AS
BEGIN
	DECLARE @CREATED_BY VARCHAR(15)= 'BSI';
	DECLARE @TIME_STAMP DATETIME = GETDATE();
	DECLARE @CURRENT datetime = (CONVERT(varchar(24),GETDATE(),106));

	DECLARE @SDODate datetime;
	DECLARE @InboundSDODate datetime;
	DECLARE @OnwardSDODate datetime;
	
	IF LTRIM(@SDO) <> ''
	BEGIN
		SET @SDODate = (CONVERT(varchar(24),@SDO + CONVERT(varchar(4),GETDATE(),20),106));
		IF @CURRENT > @SDODate
		BEGIN
			SET @SDODate =  (CONVERT(varchar(6),@SDODate,106) +  CONVERT(varchar(4),DATEADD(YEAR,1,GETDATE()),20));
		END		
	END
	
	IF LTRIM(@INBOUND_SDO) <> ''
	BEGIN
		SET @InboundSDODate = (CONVERT(varchar(24),@INBOUND_SDO + CONVERT(varchar(4),GETDATE(),20),106));
		IF @CURRENT > @InboundSDODate
		BEGIN
			SET @InboundSDODate =  (CONVERT(varchar(6),@InboundSDODate,106) +  CONVERT(varchar(4),DATEADD(YEAR,1,GETDATE()),20));
		END
	END

	IF LTRIM(@ONWARD_SDO) <> ''
	BEGIN 
		SET @OnwardSDODate = (CONVERT(varchar(24),@ONWARD_SDO + CONVERT(varchar(4),GETDATE(),20),106));
		IF @CURRENT > @OnwardSDODate
		BEGIN
			SET @OnwardSDODate =  (CONVERT(varchar(6),@OnwardSDODate,106) +  CONVERT(varchar(4),DATEADD(YEAR,1,GETDATE()),20));
		END
	END

	--INSERT INTO [BHSDB].[dbo].[BAGS]
	--		   ([ACTION], [TIME_STAMP], [DICTIONARY_VERSION], [SOURCE_INDICATOR], [AIRPORT_CODE], [LICENSE_PLATE],
	--		   [AIRLINE], [FLIGHT_NUMBER], [SDO], [DESTINATION], [TRAVEL_CLASS], [INBOUND_AIRLINE], [INBOUND_FLIGHT_NUMBER],
	--		   [INBOUND_SDO], [INBOUND_AIRPORT_CODE], [INBOUND_TRAVEL_CLASS], [ONWARD_AIRLINE], [ONWARD_FLIGHT_NUMBER],
	--		   [ONWARD_SDO], [ONWARD_AIRPORT_CODE], [ONWARD_TRAVEL_CLASS], [NO_PASSENGER_SAME_SURNAME], [SURNAME],
	--		   [GIVEN_NAME], [OTHERS_NAME], [BAG_EXCEPTION], [CREATED_BY])
	--	 VALUES
	--		   (@ACTION, @TIME_STAMP, @DICTIONARY_VERSION, @SOURCE_INDICATOR, @AIRPORT_CODE, @LICENSE_PLATE, 
	--		   @AIRLINE, @FLIGHT_NUMBER, @SDODate, @DESTINATION, @TRAVEL_CLASS, @INBOUND_AIRLINE, @INBOUND_FLIGHT_NUMBER,
	--		   @InboundSDODate, @INBOUND_AIRPORT_CODE, @INBOUND_TRAVEL_CLASS, @ONWARD_AIRLINE, @ONWARD_FLIGHT_NUMBER, 
	--		   @OnwardSDODate, @ONWARD_AIRPORT_CODE, @ONWARD_TRAVEL_CLASS, @NO_PASSENGER_SAME_SURNAME , @SURNAME, 
	--		   @GIVEN_NAME, @OTHERS_NAME, @BAG_EXCEPTION, @CREATED_BY);
    
    
    IF @ACTION = 'NEW' 
    BEGIN    
		IF @MULTIPLE_BSM_ACTION = @MULTIPLE_BSM_ACTION_NOTHING OR  @MULTIPLE_BSM_ACTION = @MULTIPLE_BSM_ACTION_INSERT
		BEGIN
			INSERT INTO [BAG_SORTING] (
					DATA_ID, TIME_STAMP, LICENSE_PLATE, AIRLINE, FLIGHT_NUMBER, SDO, DESTINATION,
					NO_PASSENGER_SAME_SURNAME, SURNAME, GIVEN_NAME, OTHERS_NAME,
					TRAVEL_CLASS, SOURCE, CREATED_BY, INBOUND_AIRLINE,
					INBOUND_FLIGHT_NUMBER, BAG_EXCEPTION) 
				VALUES ( 
					@ID, @TIME_STAMP,@LICENSE_PLATE,@AIRLINE,@FLIGHT_NUMBER,@SDODate, @DESTINATION,
					@NO_PASSENGER_SAME_SURNAME, @SURNAME, @GIVEN_NAME, @OTHERS_NAME,
					@TRAVEL_CLASS, @SOURCE_INDICATOR, @CREATED_BY, @INBOUND_AIRLINE,
					@INBOUND_FLIGHT_NUMBER,	@BAG_EXCEPTION);
		END
		ELSE IF @MULTIPLE_BSM_ACTION = @MULTIPLE_BSM_ACTION_UPDATE
		BEGIN
			UPDATE [BAG_SORTING] SET 
				DATA_ID = @ID, TIME_STAMP = @TIME_STAMP, AIRLINE = @AIRLINE, FLIGHT_NUMBER = @FLIGHT_NUMBER, 
				DESTINATION = @DESTINATION, NO_PASSENGER_SAME_SURNAME = @NO_PASSENGER_SAME_SURNAME,
				SURNAME = @SURNAME, GIVEN_NAME = @GIVEN_NAME, OTHERS_NAME = @OTHERS_NAME,
				TRAVEL_CLASS = @TRAVEL_CLASS, SOURCE = @SOURCE_INDICATOR, CREATED_BY = @CREATED_BY,
				INBOUND_AIRLINE = @INBOUND_AIRLINE,	INBOUND_FLIGHT_NUMBER = @INBOUND_FLIGHT_NUMBER,
				BAG_EXCEPTION = @BAG_EXCEPTION
			WHERE 
				LICENSE_PLATE = @LICENSE_PLATE AND SDO = @SDODate;		
		END
	END
	

	IF @ACTION = 'UPD'
	BEGIN
		UPDATE [BAG_SORTING] SET 
			DATA_ID = @ID, TIME_STAMP = @TIME_STAMP, DESTINATION = @DESTINATION, NO_PASSENGER_SAME_SURNAME = @NO_PASSENGER_SAME_SURNAME,
			SURNAME = @SURNAME, GIVEN_NAME = @GIVEN_NAME, OTHERS_NAME = @OTHERS_NAME,
			TRAVEL_CLASS = @TRAVEL_CLASS, SOURCE = @SOURCE_INDICATOR, CREATED_BY = @CREATED_BY,
			INBOUND_AIRLINE = @INBOUND_AIRLINE,	INBOUND_FLIGHT_NUMBER = @INBOUND_FLIGHT_NUMBER,
			BAG_EXCEPTION = @BAG_EXCEPTION
		WHERE 
			LICENSE_PLATE = @LICENSE_PLATE AND AIRLINE = @AIRLINE AND 
			FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDODate;
	END
	
	IF @ACTION = 'DEL'
	BEGIN
		DELETE FROM [BAG_SORTING] WHERE 
			LICENSE_PLATE = @LICENSE_PLATE AND AIRLINE = @AIRLINE AND 
			FLIGHT_NUMBER = @FLIGHT_NUMBER AND SDO = @SDODate;
	END
END
GO



GO
/****** Object:  StoredProcedure [dbo].[stp_BSI_MULTIPLEBSMCOUNT]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_BSI_MULTIPLEBSMCOUNT]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_BSI_MULTIPLEBSMCOUNT]...'
	DROP PROCEDURE [dbo].[stp_BSI_MULTIPLEBSMCOUNT]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_BSI_MULTIPLEBSMCOUNT]...'
GO
CREATE PROCEDURE [dbo].[stp_BSI_MULTIPLEBSMCOUNT] 
	@LICENSE_PLATE [varchar](10), 
	@AIRLINE [varchar](3), 
	@FLIGHT_NUMBER [varchar](5),
	@SDO [varchar](5),  
	@COUNT INT OUTPUT
AS
BEGIN
	DECLARE @CURRENT datetime = (CONVERT(varchar(24),GETDATE(),106));

	DECLARE @SDODate datetime;
	
	IF LTRIM(@SDO) <> ''
	BEGIN
		SET @SDODate = (CONVERT(varchar(24),@SDO + CONVERT(varchar(4),GETDATE(),20),106));
		IF @CURRENT > @SDODate
		BEGIN
			SET @SDODate =  (CONVERT(varchar(6),@SDODate,106) +  CONVERT(varchar(4),DATEADD(YEAR,1,GETDATE()),20));
		END		
	END
	
	SELECT @COUNT = COUNT(*) FROM [BAG_SORTING] WHERE LICENSE_PLATE = @LICENSE_PLATE AND SDO = @SDODate;

END
GO


GO
/****** Object:  StoredProcedure [dbo].[stp_BSI_GETBPMDATA]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_BSI_GETBPMDATA]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_BSI_GETBPMDATA]...'
	DROP PROCEDURE [dbo].[stp_BSI_GETBPMDATA]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_BSI_GETBPMDATA]...'
GO
CREATE PROCEDURE [dbo].[stp_BSI_GETBPMDATA]
	@ISISC bit,
	@LICENSE_PLATE1 [varchar](10), 
	@LICENSE_PLATE2 [varchar](10),  
	@LICENSE_PLATE [varchar](10) OUTPUT, 
	@AIRLINE [varchar](3) OUTPUT, 
	@FLIGHT_NUMBER [varchar](5) OUTPUT,
	@SDO datetime OUTPUT,  
	@DESTINATION [varchar](5) OUTPUT, 
	@TRAVEL_CLASS [varchar](1) OUTPUT,
	@NO_PASSENGER_SAME_SURNAME int OUTPUT,	
	@SURNAME [nvarchar](30) OUTPUT,
	@GIVEN_NAME [nvarchar](30) OUTPUT, 
	@OTHERS_NAME [nvarchar](30)OUTPUT,
	@SCANNNER_ID [varchar](4) OUTPUT,	
	@SCANNNER_LOCATION [varchar](20) OUTPUT
AS
BEGIN	
	-- Step 1: Find which LP should be use.
	DECLARE @COUNT_LP1 INT
	DECLARE @COUNT_LP2 INT
	
	IF @LICENSE_PLATE2 = '' 
	BEGIN
		SET @LICENSE_PLATE = @LICENSE_PLATE1;
	END
	ELSE
	BEGIN
		SET @COUNT_LP1 = (SELECT COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE1);
		SET @COUNT_LP2 = (SELECT COUNT(*) FROM BAG_SORTING WHERE LICENSE_PLATE = @LICENSE_PLATE2);
		
		IF (@COUNT_LP1 > 0) AND (@COUNT_LP2 > 0) 
		BEGIN
			SET @LICENSE_PLATE = @LICENSE_PLATE1;
		END
		ELSE IF  (@COUNT_LP1 > 0)
		BEGIN
			SET @LICENSE_PLATE = @LICENSE_PLATE1;
		END	
		ELSE IF  (@COUNT_LP2 > 0)
		BEGIN
			SET @LICENSE_PLATE = @LICENSE_PLATE2;
		END			
	END
	
	-- Step 2: Look for the BPM Data
	DECLARE @COUNT INT = 0;
	DECLARE @CURRENT_TIMESTAMP DATETIME;

	SELECT @COUNT = COUNT(*)
	  FROM [BHSDB].[dbo].[BAG_SORTING] WHERE LICENSE_PLATE = @LICENSE_PLATE

	SELECT @CURRENT_TIMESTAMP = MAX(TIME_STAMP)
	  FROM [BHSDB].[dbo].[BAG_SORTING] WHERE LICENSE_PLATE = @LICENSE_PLATE

	IF (@COUNT > 1)
	BEGIN
		SELECT @AIRLINE = [AIRLINE],
			  @FLIGHT_NUMBER = [FLIGHT_NUMBER],
			  @SDO = [SDO],
			  @DESTINATION = [DESTINATION],
			  @TRAVEL_CLASS = [TRAVEL_CLASS],
			  @NO_PASSENGER_SAME_SURNAME = [NO_PASSENGER_SAME_SURNAME],
			  @SURNAME = [SURNAME],
			  @GIVEN_NAME = [GIVEN_NAME],
			  @OTHERS_NAME = [OTHERS_NAME]
		  FROM [BHSDB].[dbo].[BAG_SORTING] WHERE TIME_STAMP = @CURRENT_TIMESTAMP AND LICENSE_PLATE = @LICENSE_PLATE

	END
	ELSE
	BEGIN
		SELECT @AIRLINE = [AIRLINE],
			  @FLIGHT_NUMBER = [FLIGHT_NUMBER],
			  @SDO = [SDO],
			  @DESTINATION = [DESTINATION],
			  @TRAVEL_CLASS = [TRAVEL_CLASS],
			  @NO_PASSENGER_SAME_SURNAME = [NO_PASSENGER_SAME_SURNAME],
			  @SURNAME = [SURNAME],
			  @GIVEN_NAME = [GIVEN_NAME],
			  @OTHERS_NAME = [OTHERS_NAME]
		  FROM [BHSDB].[dbo].[BAG_SORTING] WHERE LICENSE_PLATE = @LICENSE_PLATE
	END
	
	-- Step 3: For IPR
	IF (@ISISC = 0)
	BEGIN
		DECLARE @RECORD_COUNT INT = (SELECT COUNT(*) FROM ITEM_SCANNED 
										WHERE LICENSE_PLATE1 = @LICENSE_PLATE OR LICENSE_PLATE2 = @LICENSE_PLATE);
										
		DECLARE @CURRENT_RECORD_TIMESTAMP DATETIME = (SELECT MAX(TIME_STAMP) FROM ITEM_SCANNED 
										WHERE LICENSE_PLATE1 = @LICENSE_PLATE OR LICENSE_PLATE2 = @LICENSE_PLATE);
		
		IF (@RECORD_COUNT > 1)
		BEGIN
			SELECT @SCANNNER_ID = SCANNER_ID, @SCANNNER_LOCATION = LOCATION FROM ITEM_SCANNED 
				WHERE LICENSE_PLATE1 = @LICENSE_PLATE OR LICENSE_PLATE2 = @LICENSE_PLATE AND TIME_STAMP = @CURRENT_RECORD_TIMESTAMP;		
		END
		ELSE
		BEGIN
			SELECT @SCANNNER_ID = SCANNER_ID, @SCANNNER_LOCATION = LOCATION FROM ITEM_SCANNED 
				WHERE LICENSE_PLATE1 = @LICENSE_PLATE OR LICENSE_PLATE2 = @LICENSE_PLATE;
		END
	
	END
END
GO





/****** Object:  StoredProcedure [dbo].[stp_BSI_ENCAPSULATEDBPM]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_BSI_ENCAPSULATEDBPM]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_BSI_ENCAPSULATEDBPM]...'
	DROP PROCEDURE [dbo].[stp_BSI_ENCAPSULATEDBPM]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_BSI_ENCAPSULATEDBPM]...'
GO
CREATE PROCEDURE [dbo].[stp_BSI_ENCAPSULATEDBPM]
	@BPM [varchar](5000)
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[ENCAPSULATED_BPM]
			   ([TIME_STAMP], [BPM])
		 VALUES
			   (GETDATE(), @BPM);
END
GO



/****** Object:  StoredProcedure [dbo].[stp_BSI_BSMRAWDATA]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_BSI_BSMRAWDATA]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_BSI_BSMRAWDATA]...'
	DROP PROCEDURE [dbo].[stp_BSI_BSMRAWDATA]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_BSI_BSMRAWDATA]...'
GO
CREATE PROCEDURE [dbo].[stp_BSI_BSMRAWDATA]
	@RawData [varchar](5000),
	@ID bigint OUTPUT,
	@Indicator [char] (1)
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[BAGS]
			   ([TIME_STAMP], [RAW_DATA], [ERROR_INDICATOR])
		 VALUES
			   (GETDATE(),@RawData, @Indicator);
			   
	DECLARE @TIME_STAMP DATETIME = (SELECT MAX(TIME_STAMP) FROM BAGS)
	SELECT @ID = ID FROM BAGS WHERE TIME_STAMP = @TIME_STAMP;	
	
END
GO


/****** Object:  StoredProcedure [dbo].[stp_FIS_RAWDATA]    Script Date: 01/26/2010 15:37:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_FIS_RAWDATA]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_FIS_RAWDATA]...'
	DROP PROCEDURE [dbo].[stp_FIS_RAWDATA]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_FIS_RAWDATA]...'
GO
CREATE PROCEDURE [dbo].[stp_FIS_RAWDATA]
	@RawData [varchar](5000),
	@ID bigint OUTPUT,
	@Indicator [char] (1)
AS
BEGIN
	INSERT INTO [BHSDB].[dbo].[FLIGHT_PLANS]
			   ([TIME_STAMP], [RAW_DATA], [ERROR_INDICATOR])
		 VALUES
			   (GETDATE(),@RawData, @Indicator);
			   
	DECLARE @TIME_STAMP DATETIME = (SELECT MAX(TIME_STAMP) FROM FLIGHT_PLANS)
	SELECT @ID = ID FROM FLIGHT_PLANS WHERE TIME_STAMP = @TIME_STAMP;	
	
END
GO


-- ****** Object:  UserDefinedFunction [dbo].[SAC_HOURMINUTECOMPARATOR]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_HOURMINUTECOMPARATOR]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_HOURMINUTECOMPARATOR].'
	DROP FUNCTION [dbo].[SAC_HOURMINUTECOMPARATOR]
END
GO
PRINT 'INFO: Creating Function [SAC_HOURMINUTECOMPARATOR].'
GO
CREATE FUNCTION [dbo].[SAC_HOURMINUTECOMPARATOR](@Source varchar(5),@Destination varchar(5))
RETURNS varchar(1)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnStatus varchar(1)
	DECLARE @SOperator varchar(1)
	DECLARE @DOperator varchar(1)
	DECLARE @Sminute bigint
	DECLARE @Dminute bigint
	--Offset Value
	IF(len(@Source)=5) --(-0000)
	Begin
		Set @Sminute=convert(int,substring(@Source,4,2)) + (convert(int,substring(@Source,2,2)) * 60)
		Set @SOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Sminute=convert(int,substring(@Source,3,2)) + (convert(int,substring(@Source,1,2)) * 60)
		Set @SOperator=''
	End	
	IF(len(@Destination)=5) --(-0000)
	Begin
		Set @Dminute=convert(int,substring(@Destination,4,2)) + (convert(int,substring(@Destination,2,2)) * 60)
		Set @DOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Dminute=convert(int,substring(@Destination,3,2)) + (convert(int,substring(@Destination,1,2)) * 60)
		Set @DOperator=''
	End	
	if(@Sminute>@Dminute) 
	begin
		Set @returnStatus =1  --(+)
	end
	else
	begin
		Set @returnStatus =0  --(-)
	end
	RETURN @returnStatus
END
GO




-- ****** Object:  UserDefinedFunction [dbo].[SAC_HOURMINUTEDIFF]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_HOURMINUTEDIFF]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_HOURMINUTEDIFF].'
	DROP FUNCTION [dbo].[SAC_HOURMINUTEDIFF]
END
GO
PRINT 'INFO: Creating Function [SAC_HOURMINUTEDIFF].'
GO
CREATE FUNCTION [dbo].[SAC_HOURMINUTEDIFF](@Source varchar(5),@Destination varchar(5))
RETURNS varchar(4)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnStatus varchar(4)
	DECLARE @SOperator varchar(1)
	DECLARE @DOperator varchar(1)
	DECLARE @Sminute int
	DECLARE @Dminute int
	DECLARE @Hour int
	DECLARE @Minute int
	--Offset Value
	IF(len(@Source)=5) --(-0000)
	Begin
		Set @Sminute=convert(int,substring(@Source,4,2)) + (convert(int,substring(@Source,2,2)) * 60)
		Set @SOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Sminute=convert(int,substring(@Source,3,2)) + (convert(int,substring(@Source,1,2)) * 60)
		Set @SOperator=''
	End	
	IF(len(@Destination)=5) --(-0000)
	Begin
		Set @Dminute=convert(int,substring(@Destination,4,2)) + (convert(int,substring(@Destination,2,2)) * 60)
		Set @DOperator='-'
	End	
	ELSE --(0000)
	Begin
		Set @Dminute=convert(int,substring(@Destination,3,2)) + (convert(int,substring(@Destination,1,2)) * 60)
		Set @DOperator='' 
	End	
--		if(@Sminute>@Dminute)
--			begin
			Set @Minute=@Sminute - @Dminute 
--			end
--		else
--			begin
--				Set @Minute=@Dminute - @Sminute
--			end
	
	Set @Hour=@Minute / 60
	Set @Minute = @Minute - (@Hour * 60)
	--Hour
	if(@Hour>0)
	Begin
		if(len(@Hour)=1)
			begin
				Set @returnStatus= '0'+convert(varchar(1), @Hour)
			end
		else
			begin
				Set @returnStatus= convert(varchar(2),@Hour)
			end
	End
	else
		Begin
			Set @returnStatus='00'
		End
	--Minute
	if(@Minute>0)
		Begin
			if(len(@Minute)=1)
				begin
					Set @returnStatus=@returnStatus+ '0'+convert(varchar(1),@Minute)
				end
			else
				begin
					Set @returnStatus=@returnStatus+ convert(varchar(2),@Minute)
				end
		End	
	else
		Begin
			Set @returnStatus=@returnStatus+'00'
		End
	
	RETURN @returnStatus
END
GO



-- ****** Object:  UserDefinedFunction [dbo].[SAC_HOURMINUTEMASTER]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_HOURMINUTEMASTER]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_HOURMINUTEMASTER].'
	DROP FUNCTION [dbo].[SAC_HOURMINUTEMASTER]
END
GO
PRINT 'INFO: Creating Function [SAC_HOURMINUTEMASTER].'
GO
CREATE FUNCTION [dbo].[SAC_HOURMINUTEMASTER](@Offset varchar(5),@Day int,@Hour int,@Minute int,@Operation varchar(1))
RETURNS varchar(5)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @returnStatus varchar(5)
	DECLARE @OHour int
	DECLARE @OMinute bigint
	DECLARE @NMinute bigint
	DECLARE @Operator varchar(1)
	SET @NMinute=(@Day * 1440) + (@Hour * 60) + @Minute
	--Offset Value
	IF(len(@Offset)=5) --(-0000)
	Begin
		Set @OMinute=convert(int,substring(@Offset,4,2)) + (convert(int,substring(@Offset,2,2)) * 60)
		Set @Operator='-'
	End	
	ELSE --(0000)
	Begin
		Set @OMinute=convert(int,substring(@Offset,3,2)) + (convert(int,substring(@Offset,1,2)) * 60)
		Set @Operator=''
	End	
	--Operation
	IF(@Operation = '+')
	Begin
		Set @OMinute = @OMinute + @NMinute
		IF(@OMinute>59)
		Begin
			Set @OHour = @OMinute / 60
			Set @OMinute = @OMinute - (@OHour * 60)
		End
		ELSE
		Begin
			Set @OHour=0
		End
	End		
	ELSE
	Begin
		Set @OMinute = @OMinute - @NMinute
		IF(@OMinute>59)
		Begin
			Set @OHour = @OMinute / 60
			Set @OMinute = @OMinute - (@OHour * 60)
		End
		ELSE
		Begin
			Set @OHour=0
		End
	End		
	--Formating (-0000 or 0000)
	--Hour
	if(@OHour>0)
		Begin
			IF(len(@OHour)=1)
				Begin
					Set @returnStatus='0' + convert(varchar(1),@OHour)
				End
			ELSE
				Begin
					Set @returnStatus= convert(varchar(2),@OHour)
				End 
	End		
	else
		Begin
			Set @returnStatus='00'
		End
	--Minute
	if(@OMinute>0)
		Begin
			IF(len(@OMinute)=1)
				Begin
					Set @returnStatus=@returnStatus + '0' + convert(varchar(1),@OMinute)
				End
			ELSE
				Begin
					Set @returnStatus= @returnStatus + convert(varchar(2),@OMinute)
				End 		
		End
	else
		Begin
			Set @returnStatus=@returnStatus+'00'
		End	
	
	Set @returnStatus = @Operator + @returnStatus
	-- Return the result of the function
	RETURN @returnStatus
END
GO



-- ****** Object:  UserDefinedFunction [dbo].[SAC_OFFSETOPERATOR]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_OFFSETOPERATOR]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_OFFSETOPERATOR].'
	DROP FUNCTION [dbo].[SAC_OFFSETOPERATOR]
END
GO
PRINT 'INFO: Creating Function [SAC_OFFSETOPERATOR].'
GO
CREATE FUNCTION [dbo].[SAC_OFFSETOPERATOR](@Source varchar(4),@Destination varchar(5)) --@Source=''0945'',@Destination=''-0020'' || ''0020''
RETURNS varchar(4)
AS
Begin
	Declare @sHour int
	Declare @sMinute int
	Declare @dHour int
	Declare @dMinute int
	Declare @liveHour int
	Declare @liveMinute int
	Declare @totaldMinute int
	Declare @totalsMinute int
	Declare @totalbMinute int
	Declare @dOperator varchar(1)
	Declare @result varchar(4)
	--Default
	Set @sHour=0
	Set @sMinute=0
	Set @dHour=0
	Set @dMinute=0
	Set @liveHour=0
	Set @liveMinute=0
	Set @totaldMinute=0
	Set @totalsMinute=0
	Set @totalbMinute=0
	Set @dOperator='' --default +
	Set @result=''		

	--Source
	Set @sHour=Convert(int,substring(@Source,1,2))
	Set @sMinute=Convert(int,substring(@Source,3,2))
	--Destination
	if(len(@Destination)=4)
	Begin
		Set @dHour=Convert(int,substring(@Destination,1,2))
		Set @dMinute=Convert(int,substring(@Destination,3,2))
	--+ Normal
		Set @liveHour=@sHour+@dHour
		Set @liveMinute=@sMinute+@dMinute
	End
	Else
	Begin
		Set @dOperator='-'
		Set @dHour=Convert(int,substring(@Destination,2,2))
		Set @dMinute=Convert(int,substring(@Destination,4,2))
		Set @totaldMinute=(@dHour * 60)+@dMinute
		Set @totalsMinute=(@sHour * 60)+@sMinute
		Set @totalbMinute=@totalsMinute-@totaldMinute
		Set @liveHour=@totalbMinute / 60
		Set @liveMinute=@totalbMinute - (@liveHour * 60)
	End
	if(len(@liveHour)= 1)
	Begin
		Set @result='0' + Convert(varchar(1),@liveHour)
	End
	else
	Begin
		Set @result= Convert(varchar(2),@liveHour)
	End
	if(len(@liveMinute)= 1)
	Begin
		Set @result=@result + '0' + Convert(varchar(1),@liveMinute)
	End
	else
	Begin
		Set @result= @result + Convert(varchar(2),@liveMinute)
	End
	RETURN @result  --(HHMM)-->STO
END
GO




-- ****** Object:  UserDefinedFunction [dbo].[SAC_ADDMINUTESTOOFFSET]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_ADDMINUTESTOOFFSET]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_ADDMINUTESTOOFFSET].'
	DROP FUNCTION [dbo].[SAC_ADDMINUTESTOOFFSET]
END
GO
PRINT 'INFO: Creating Function [SAC_ADDMINUTESTOOFFSET].'
GO
CREATE FUNCTION [dbo].[SAC_ADDMINUTESTOOFFSET](@Source varchar(5),@ExtMinute int)
RETURNS varchar(5)
AS
Begin
	Declare @MyMinute int
	Declare @Operator varchar(1)
	Declare @MyOffset varchar(5)
	Declare @Hour int
	Declare @Minute int
	if(len(@Source)=5) --[-0000]
	Begin
		Set @Operator='-'
		Set @MyMinute=(Convert(int,substring(@Source,2,2)*60)+Convert(int,substring(@Source,4,2)))*(-1)
	End
	else --[0000]
	Begin
		Set @Operator='' --'+'
		Set @MyMinute=(Convert(int,substring(@Source,1,2)*60)+Convert(int,substring(@Source,3,2)))
	End
	Set @MyMinute= @MyMinute+@ExtMinute
	if(@MyMinute<0)
	Begin
		Set @Operator='-'
	End		
	else
	Begin
		Set @Operator=''
	End		
	Set @MyMinute=abs(@MyMinute)
	Set @Hour=@MyMinute / 60
	Set @Minute=@MyMinute-(@Hour * 60)
	--Hour
	if(@Hour>0)
		Begin
			if(len(@Hour)=1)
			Begin
				Set @MyOffset= '0'+Convert(varchar(1),@Hour)
			End
			else
			Begin
				Set @MyOffset= Convert(varchar(2),@Hour)
			End
		End
	else
		Begin
			Set @MyOffset='00'
		End
	--Minute
	if(@Minute>0)
		Begin
			if(len(@Minute)=1)
				Begin
					Set @MyOffset=@MyOffset + '0'+Convert(varchar(1),@Minute)
				End
			else
				Begin
					Set @MyOffset= @MyOffset + Convert(varchar(2),@Minute)
				End
		End
	else
		Begin
			Set @MyOffset=@MyOffset+'00'
		End
	Set @MyOffset=@Operator+@MyOffset
	Return @MyOffset
End	
GO
/*
Declare @result varchar(5)
Set @result= [dbo].[SAC_ADDMINUTESTOOFFSET]('0020',30)
print @result
*/




-- ****** Object:  UserDefinedFunction [dbo].[SAC_MINUTECONVERTER]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_MINUTECONVERTER]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_MINUTECONVERTER].'
	DROP FUNCTION [dbo].[SAC_MINUTECONVERTER]
END
GO
PRINT 'INFO: Creating Function [SAC_MINUTECONVERTER].'
GO
CREATE FUNCTION [dbo].[SAC_MINUTECONVERTER](@OffsetValue varchar(5))
RETURNS int
AS
Begin
	Declare @TMinute int
	IF(LEN(@OffsetValue)=5)
	BEGIN
		Set @TMinute=(Convert(int,SUBSTRING(@OffsetValue,2,2))*60)+Convert(int,SUBSTRING(@OffsetValue,4,2))
	END
	ELSE
	BEGIN
		Set @TMinute= (Convert(int,SUBSTRING(@OffsetValue,1,2))*60)+Convert(int,SUBSTRING(@OffsetValue,3,2))
	END
	Return @TMinute
End
GO




-- ****** Object:  UserDefinedFunction [dbo].[SAC_OFFSETOPERATOR]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_OFFSETOPERATOR]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_OFFSETOPERATOR].'
	DROP FUNCTION [dbo].[SAC_OFFSETOPERATOR]
END
GO
PRINT 'INFO: Creating Function [SAC_OFFSETOPERATOR].'
GO
CREATE FUNCTION [dbo].[SAC_OFFSETOPERATOR](@Source varchar(4),@Destination varchar(5)) --@Source=''0945'',@Destination=''-0020'' || ''0020''
RETURNS varchar(4)
AS
Begin
	Declare @sHour int
	Declare @sMinute int
	Declare @dHour int
	Declare @dMinute int
	Declare @liveHour int
	Declare @liveMinute int
	Declare @totaldMinute int
	Declare @totalsMinute int
	Declare @totalbMinute int
	Declare @dOperator varchar(1)
	Declare @result varchar(4)
	--Default
	Set @sHour=0
	Set @sMinute=0
	Set @dHour=0
	Set @dMinute=0
	Set @liveHour=0
	Set @liveMinute=0
	Set @totaldMinute=0
	Set @totalsMinute=0
	Set @totalbMinute=0
	Set @dOperator='' --default +
	Set @result=''		

	--Source
	Set @sHour=Convert(int,substring(@Source,1,2))
	Set @sMinute=Convert(int,substring(@Source,3,2))
	--Destination
	if(len(@Destination)=4)
	Begin
		Set @dHour=Convert(int,substring(@Destination,1,2))
		Set @dMinute=Convert(int,substring(@Destination,3,2))
	--+ Normal
		Set @liveHour=@sHour+@dHour
		Set @liveMinute=@sMinute+@dMinute
	End
	Else
	Begin
		Set @dOperator='-'
		Set @dHour=Convert(int,substring(@Destination,2,2))
		Set @dMinute=Convert(int,substring(@Destination,4,2))
		Set @totaldMinute=(@dHour * 60)+@dMinute
		Set @totalsMinute=(@sHour * 60)+@sMinute
		Set @totalbMinute=@totalsMinute-@totaldMinute
		Set @liveHour=@totalbMinute / 60
		Set @liveMinute=@totalbMinute - (@liveHour * 60)
	End
	if(@liveHour>0)
		Begin		
			if(len(@liveHour)= 1)
				Begin
					Set @result='0' + Convert(varchar(1),@liveHour)
				End
			else
				Begin
					Set @result= Convert(varchar(2),@liveHour)
				End
		End
	else
		Begin
			Set @result='00'
		End
	if(@liveMinute>0)
		Begin
			if(len(@liveMinute)= 1)
				Begin
					Set @result=@result + '0' + Convert(varchar(1),@liveMinute)
				End
			else
				Begin
					Set @result= @result + Convert(varchar(2),@liveMinute)
				End
		End
	else
		Begin
			Set @result=@result+'00'
		End
	
	RETURN @result  --(HHMM)-->STO
END
GO


-- ****** Object:  UserDefinedFunction [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET]    Script Date: 09/10/2008 16:16:16 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SAC_SUBSTRACTMINUTESTOOFFSET]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [SAC_SUBSTRACTMINUTESTOOFFSET].'
	DROP FUNCTION [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET]
END
GO
PRINT 'INFO: Creating Function [SAC_SUBSTRACTMINUTESTOOFFSET].'
GO
CREATE FUNCTION [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET](@Source varchar(5),@ExtMinute int)
RETURNS varchar(5)
AS
Begin
	Declare @MyMinute bigint
	Declare @Operator varchar(1)
	Declare @MyOffset varchar(5)
	Declare @Hour int
	Declare @Minute bigint
	if(len(@Source)=5) --[-0000]
	Begin
		Set @Operator='-'
		Set @MyMinute=(Convert(int,substring(@Source,2,2)*60)+Convert(int,substring(@Source,4,2)))*(-1)
	End
	else --[0000]
	Begin
		Set @Operator='' --'+'
		Set @MyMinute=(Convert(int,substring(@Source,1,2)*60)+Convert(int,substring(@Source,3,2)))
	End
	Set @MyMinute= @MyMinute-@ExtMinute
	--Set @MyMinute = (-1) * @MyMinute
	if(@MyMinute<0)
	Begin
		Set @Operator='-'
	End		
	else
	Begin
		Set @Operator=''
	End		
	Set @MyMinute=abs(@MyMinute)
	Set @Hour=@MyMinute / 60
	Set @Minute=@MyMinute-(@Hour * 60)
	--Hour
	if(@Hour>0)
		Begin
			if(len(@Hour)=1)
			Begin
				Set @MyOffset= '0'+Convert(varchar(1),@Hour)
			End
			else
			Begin
				Set @MyOffset= Convert(varchar(2),@Hour)
			End
		End
	else
		Begin
			Set @MyOffset='00'
		End
	--Minute
	if(@Minute>0)
		Begin
			if(len(@Minute)=1)
				Begin
					Set @MyOffset=@MyOffset + '0'+Convert(varchar(1),@Minute)
				End
			else
				Begin
					Set @MyOffset= @MyOffset + Convert(varchar(2),@Minute)
				End
		End
	else
		Begin
			Set @MyOffset=@MyOffset+'00'
		End
	Set @MyOffset=@Operator+@MyOffset
	Return @MyOffset
End	
GO
/*
print [dbo].[SAC_SUBSTRACTMINUTESTOOFFSET]('-0050',70)
*/



PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: End of STEP2.2'
GO