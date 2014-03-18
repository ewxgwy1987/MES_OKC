-- ##########################################################################
-- Release#:    R1.0
-- Release On:  20 Aug 2009
-- Filename:    5.2.CCTV_CreateSTP.sql
-- Description: SQL Scripts of creating MDS-CCTV interface related StoredProcedures.
--
--    Following StoredProcedures will be created:
--    01. [stp_CCTV_CLEARCCTVALARMQUEUE]
--    02. [stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE]
--    03. [stp_CCTV_GETMDSCURRENTALARMS]
--    04. [stp_CCTV_GETOUTGOINGMDSALARMS]
--    05. [stp_CCTV_REMOVESENTALARM]
--    06. [stp_CCTV_SENTALARMLOGGING]
--    07. [stp_CCTV_RECEIVEDCCTVDATALOGGING]
--    08. [stp_CCTV_AUTORESETCCTVFAULTS]
--
--
-- Histories:
--    R1.0 - Released on 05 Nov 2008.
--
--
-- Remarks:
--
--
-- ##########################################################################




PRINT 'INFO: STEP 5.2 - Create MDS-CCTV interface related Stored Procedures.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
USE [BHSDB]
GO



-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_CLEARCCTVALARMQUEUE]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_CLEARCCTVALARMQUEUE]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_CLEARCCTVALARMQUEUE]...'
	DROP PROCEDURE [dbo].[stp_CCTV_CLEARCCTVALARMQUEUE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_CLEARCCTVALARMQUEUE]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_CLEARCCTVALARMQUEUE] 
AS
BEGIN
	DELETE FROM [dbo].[CCTV_STATUS];
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE]...'
	DROP PROCEDURE [dbo].[stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_CLEAROUTGOINGMDSALARMQUEUE] 
AS
BEGIN
	DELETE FROM [dbo].[CCTV_MDS_OUTGOING_ALARMS];
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_GETMDSCURRENTALARMS]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_GETMDSCURRENTALARMS]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_GETMDSCURRENTALARMS]...'
	DROP PROCEDURE [dbo].[stp_CCTV_GETMDSCURRENTALARMS]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_GETMDSCURRENTALARMS]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_GETMDSCURRENTALARMS] 
AS
BEGIN
	SELECT [TIME_STAMP],[SUBSYSTEM],[EQUIPMENT_ID],[ALARM_TYPE],[ALARM_DESCRIPTION],
				[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID] 
		FROM [dbo].[CCTV_MDS_ACTIVATED_ALARMS];	
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_GETOUTGOINGMDSALARMS]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_GETOUTGOINGMDSALARMS]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_GETOUTGOINGMDSALARMS]...'
	DROP PROCEDURE [dbo].[stp_CCTV_GETOUTGOINGMDSALARMS]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_GETOUTGOINGMDSALARMS]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_GETOUTGOINGMDSALARMS] 
AS
BEGIN
	SELECT [ID],[ACTION],[TIME_STAMP],[SUBSYSTEM],[EQUIPMENT_ID],[ALARM_TYPE],
			[ALARM_DESCRIPTION],[CCTV_DEVICE_TYPE],[CCTV_DEVICE_ID],[CCTV_CAMERA_POSITION_ID]
		FROM [dbo].[CCTV_MDS_OUTGOING_ALARMS]
		
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_REMOVESENTALARM]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_REMOVESENTALARM]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_REMOVESENTALARM]...'
	DROP PROCEDURE [dbo].[stp_CCTV_REMOVESENTALARM]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_REMOVESENTALARM]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_REMOVESENTALARM] 
	@ID [bigint]
AS
BEGIN
	DELETE FROM [dbo].[CCTV_MDS_OUTGOING_ALARMS] WHERE [ID] = @ID;
END
GO



-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_SENTALARMLOGGING]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_SENTALARMLOGGING]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_SENTALARMLOGGING]...'
	DROP PROCEDURE [dbo].[stp_CCTV_SENTALARMLOGGING]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_SENTALARMLOGGING]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_SENTALARMLOGGING] 
	@Sender [varchar](8), 
	@Receiver [varchar](8), 
	@Action [varchar](11),
	@TimeStamp [datetime],
	@SubSystem [varchar](10),
	@EquipID [varchar](20), 
	@AlmType [varchar](10),
	@AlmDesc [nvarchar](50),
	@CCTVType [varchar](4),
	@CCTVID [varchar](4),
	@CCTVPosID [varchar](2)
AS
BEGIN
	INSERT INTO [CCTV_MDS_SENT_DATA_LOGGING] 
		([SENDER], [RECEIVER], [ACTION], [TIME_STAMP], [SUBSYSTEM], [EQUIPMENT_ID], [ALARM_TYPE], 
		 [ALARM_DESCRIPTION], [CCTV_DEVICE_TYPE], [CCTV_DEVICE_ID], [CCTV_CAMERA_POSITION_ID]) 
	VALUES 
		(@Sender, @Receiver, @Action, @TimeStamp, @SubSystem, @EquipID, @AlmType, 
		 @AlmDesc, @CCTVType, @CCTVID, @CCTVPosID)
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_RECEIVEDCCTVDATALOGGING]    Script Date: 16/06/2009 ******
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_RECEIVEDCCTVDATALOGGING]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_RECEIVEDCCTVDATALOGGING]...'
	DROP PROCEDURE [dbo].[stp_CCTV_RECEIVEDCCTVDATALOGGING]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_RECEIVEDCCTVDATALOGGING]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_RECEIVEDCCTVDATALOGGING] 
	@Sender [varchar](8), 
	@Receiver [varchar](8), 
	@Action [varchar](11),
	@TimeStamp [datetime],
	@CCTVStatusType [varchar](6),
	@CCTVStatusCode [varchar](6),
	@CCTVDevID [varchar](4),
	@CCTVStatus [varchar](50)
AS
BEGIN
	IF @Action = 'ACTIVATED'
	BEGIN
		-- Insert new CCTV activated alarm into table [CCTV_STATUS].
		INSERT INTO [CCTV_STATUS] 
			([TIME_STAMP], [CCTV_STATUS_TYPE], [CCTV_STATUS_CODE], [CCTV_DEVICE_ID], [CCTV_STATUS_DESCRIPTION]) 
		VALUES 
			(@TimeStamp, @CCTVStatusType, @CCTVStatusCode, @CCTVDevID, @CCTVStatus)
	END
	ELSE IF @Action = 'EVENT'
	BEGIN
		-- Insert new CCTV event into table [CCTV_STATUS].
		INSERT INTO [CCTV_STATUS] 
			([TIME_STAMP], [CCTV_STATUS_TYPE], [CCTV_STATUS_CODE], [CCTV_DEVICE_ID], [CCTV_STATUS_DESCRIPTION]) 
		VALUES 
			(@TimeStamp, @CCTVStatusType, @CCTVStatusCode, @CCTVDevID, @CCTVStatus)
	END
	ELSE IF @Action = 'DEACTIVATED'
	BEGIN
		-- Insert new CCTV deactivated alarm into table [CCTV_DEACTIVATED_ALARMS].
		INSERT INTO [CCTV_DEACTIVATED_ALARMS] ([CCTV_DEVICE_ID], [CCTV_STATUS_CODE]) VALUES (@CCTVDevID, @CCTVStatusCode)
	END

	INSERT INTO [CCTV_RECEIVED_DATA_LOGGING] 
		([SENDER], [RECEIVER], [ACTION], [TIME_STAMP], [CCTV_STATUS_TYPE], [CCTV_STATUS_CODE], [CCTV_DEVICE_ID], [CCTV_STATUS_DESCRIPTION]) 
	VALUES 
		(@Sender, @Receiver, @Action, @TimeStamp, @CCTVStatusType, @CCTVStatusCode, @CCTVDevID, @CCTVStatus)
END
GO


-- ****** Object:  StoredProcedure [dbo].[stp_CCTV_AUTORESETCCTVFAULTS] ******
--
-- There are few alarms will be sent from CCTV server to MDS for notification BHS 
-- operators. There are few alarms amount them will not have the alarm normalized 
-- nortification sent by CCTV server to MDS. Hence, the auto alarm reset of these
-- CCTV alarms is needed. Otherwise, these CCTV alarms will be shown on MDS screen
-- permanently. 
--
-- Since MDS keeps monitoring the [CCTV_STATUS] table and generate CCTV alarm if
-- this table is not empty, reset of CCTV alarm is done by removing particular 
-- CCTV alarm, which [TIME_STAME] field value is older than the current time for 
-- per-set alarm auto reset timeout, from this table.
--
-- There is one integer parameters need to be passed to StoredProcedure:
-- @ResetTimeout -	the # of minutes timeout that CCTV faults need to be auto reset after it.
--                  valid range is 1min ~ 10080min(7days);
-- ***************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stp_CCTV_AUTORESETCCTVFAULTS]') 
	AND type in (N'P', N'PC'))
BEGIN
	PRINT 'INFO: Deleting existing StoredProcedure [stp_CCTV_AUTORESETCCTVFAULTS]...'
	DROP PROCEDURE [dbo].[stp_CCTV_AUTORESETCCTVFAULTS]
END
GO
PRINT 'INFO: Creating StoredProcedure [stp_CCTV_AUTORESETCCTVFAULTS]...'
GO
CREATE PROCEDURE [dbo].[stp_CCTV_AUTORESETCCTVFAULTS] 
	@ResetTimeout [int]
AS
BEGIN
	-- The minimum 1 minute or maximum 7 days (10080 minutes)
	IF @ResetTimeout < 1 
	BEGIN
		SET @ResetTimeout = 1
	END

	IF @ResetTimeout > 10080 
	BEGIN
		SET @ResetTimeout = 10080
	END

	DELETE FROM [dbo].[CCTV_STATUS] 
		WHERE ([dbo].[CCTV_STATUS].[CCTV_STATUS_CODE] in 
				(SELECT [CODE] FROM [dbo].[CCTV_STATUS_CODES] WHERE [IS_AUTO_RESET] = 1)) AND
			[dbo].[CCTV_STATUS].[TIME_STAMP] < DATEADD(minute, -(@ResetTimeout), GETDATE())				
END
GO






PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: End of STEP 5.2'
GO
