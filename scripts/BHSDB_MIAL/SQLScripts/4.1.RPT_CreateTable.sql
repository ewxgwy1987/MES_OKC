-- ##########################################################################
-- Release#:    R1.0
-- Release On:  15 Mar 2010
-- Filename:    4.1.RPT_CreateTable.sql
-- Description: SQL Scripts of creating PALS reporting related tables in the 
--              Solution Database [BHSDB] (table, view, trigger, foreign keys, etc.)
--
--    Tables to be created by this script:
--    01. [DESTINATION_GROUPING]
--    02. [SUBSYSTEM_GROUPING]
--
--    Foreign Keys to be created by this script:
--    01. [FK_DESTINATION_GROUPING_NAME]
--    02. [FK_DESTINATION_GROUPING_LOCATION]
--
--    Functions to be created by this script:
--    01. [RPT_GETPARAMETERS]
--	  02. [GET_RPT_DECISION_POINT]
--    03. [GET_RPT_LPDETAILS]
--    04. [GET_RPT_SORTED_OUT_TABLE]
--    05. [GET_RPT_SORTED_TABLE_BYDATE]
--
-- Histories:
--				R1.0 - Released on 15 Mar 2010.
-- ##########################################################################


USE [BHSDB]
GO

PRINT 'INFO: STEP 4.1 - Creat reporting related tables.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Drop Existing Tables...'
GO

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]') AND type in (N'U'))
--	DROP TABLE [dbo].[DESTINATION_GROUPING]
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUBSYSTEM_GROUPING]') AND type in (N'U'))
--	DROP TABLE [dbo].[SUBSYSTEM_GROUPING]




PRINT 'INFO: End of Drop Existing Tables.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Tables...'
GO



---- ****** Object:  Table [dbo].[DESTINATION_GROUPING]    Script Date: 10/08/2007 13:18:35 ******
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--SET ANSI_PADDING ON
--GO
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]') AND type in (N'U'))
--BEGIN
--	PRINT 'INFO: Deleting existing table [DESTINATION_GROUPING]...'
--	DROP TABLE [dbo].[DESTINATION_GROUPING]
--END
--GO
--PRINT 'INFO: Creating table [DESTINATION_GROUPING]...'
--CREATE TABLE [dbo].[DESTINATION_GROUPING](
--	[GROUP_NAME] [varchar](10) NOT NULL,
--	[LOCATION] [varchar](20) NOT NULL,
--	[SUBSYSTEM] [varchar](10) NOT NULL,
--) ON [PRIMARY]
--GO
--SET ANSI_PADDING OFF
--GO


---- ****** Object:  Table [dbo].[SUBSYSTEM_GROUPING]    Script Date: 11/01/2007 11:29:45 ******
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
--SET ANSI_PADDING ON
--GO
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SUBSYSTEM_GROUPING]') AND type in (N'U'))
--BEGIN
--	PRINT 'INFO: Deleting existing table [SUBSYSTEM_GROUPING]...'
--	DROP TABLE [dbo].[SUBSYSTEM_GROUPING]
--END
--GO
--PRINT 'INFO: Creating table [SUBSYSTEM_GROUPING]...'
--CREATE TABLE [dbo].[SUBSYSTEM_GROUPING](
--	[GROUP_NAME] [varchar](10) NOT NULL,
--	[LOCATION] [varchar](20) NOT NULL,
--	[SUBSYSTEM] [varchar](10) NOT NULL,
--) ON [PRIMARY]
--GO
--SET ANSI_PADDING OFF





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




---- ****** Object:  ForeignKey [FK_DESTINATION_GROUPING_NAME]    Script Date: 10/08/2007 13:18:35 ******
--IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DESTINATION_GROUPING_NAME]') 
--		AND parent_object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]'))
--BEGIN
--	PRINT 'INFO: Deleting existing ForeignKey [FK_DESTINATION_GROUPING_NAME]...'
--	ALTER TABLE [dbo].[DESTINATION_GROUPING] DROP CONSTRAINT [FK_DESTINATION_GROUPING_NAME]
--END
--PRINT 'INFO: Creating ForeignKey [FK_DESTINATION_GROUPING_NAME]...'
--ALTER TABLE [dbo].[DESTINATION_GROUPING]  WITH CHECK ADD  CONSTRAINT [FK_DESTINATION_GROUPING_NAME] FOREIGN KEY([GROUP_NAME])
--REFERENCES [dbo].[DESTINATIONS] ([DESTINATION])
--GO
--ALTER TABLE [dbo].[DESTINATION_GROUPING] CHECK CONSTRAINT [FK_DESTINATION_GROUPING_NAME]
--GO


---- ****** Object:  ForeignKey [FK_DESTINATION_GROUPING_LOCATION]    Script Date: 10/08/2007 13:18:35 ******
--IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DESTINATION_GROUPING_LOCATION]') 
--		AND parent_object_id = OBJECT_ID(N'[dbo].[DESTINATION_GROUPING]'))
--BEGIN
--	PRINT 'INFO: Deleting existing ForeignKey [FK_DESTINATION_GROUPING_LOCATION]...'
--	ALTER TABLE [dbo].[DESTINATION_GROUPING] DROP CONSTRAINT [FK_DESTINATION_GROUPING_LOCATION]
--END
--PRINT 'INFO: Creating ForeignKey [FK_DESTINATION_GROUPING_LOCATION]...'
--ALTER TABLE [dbo].[DESTINATION_GROUPING]  WITH CHECK ADD  CONSTRAINT [FK_DESTINATION_GROUPING_LOCATION] FOREIGN KEY([LOCATION], [SUBSYSTEM])
--REFERENCES [dbo].[LOCATIONS] ([LOCATION], [SUBSYSTEM])
--GO
--ALTER TABLE [dbo].[DESTINATION_GROUPING] CHECK CONSTRAINT [FK_DESTINATION_GROUPING_LOCATION]
--GO





PRINT 'INFO: End of Creating New Foreign Keys.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Triggers...'
GO


-- ...


PRINT 'INFO: End of Creating New Triggers.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO

PRINT 'INFO: End of Creating New Triggers.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
PRINT 'INFO: Begining of Creating New Functions...'
GO



USE [BHSDB]
GO

GO
/****** Object:  UserDefinedFunction [dbo].[RPT_GETPARAMETERS]    Script Date: 04/17/2009 17:01:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RPT_GETPARAMETERS]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [RPT_GETPARAMETERS].'
	DROP FUNCTION [dbo].[RPT_GETPARAMETERS]
END
GO
PRINT 'INFO: Creating Function [RPT_GETPARAMETERS].'
GO
CREATE FUNCTION [dbo].[RPT_GETPARAMETERS]
(
 @parameter varchar(100)
)
RETURNS 
@temp  TABLE 
(
	PAR NVARCHAR(20)
)
AS
BEGIN

	DECLARE @d char(1)
	DECLARE @Start int
	DECLARE @End int
	SET @d = ',';

	WITH CSVCTE (StartPos, EndPos, Value) AS
	( SELECT 1 AS StartPos, CHARINDEX(@d , @Parameter + @d) AS EndPos,
		SUBSTRING(@Parameter,1,CHARINDEX(@d , @Parameter + @d)-1)
				 UNION ALL
	  SELECT EndPos + 1 AS StartPos , 
		CHARINDEX(@d,@Parameter + @d , EndPos + 1) AS EndPos,
		SUBSTRING(@Parameter,EndPos + 1, CHARINDEX(@d,@Parameter + @d , EndPos + 1)-(EndPos + 1))
	FROM CSVCTE WHERE CHARINDEX(@d, @Parameter + @d, EndPos + 1) <> 0)	      
	     
	 INSERT INTO @temp (PAR ) SELECT Value FROM CSVCTE
	 RETURN
END
GO



/****** Object:  UserDefinedFunction [dbo].[GET_RPT_DECISION_POINT]    Script Date: 04/17/2009 17:01:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GET_RPT_DECISION_POINT]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [GET_RPT_DECISION_POINT].'
	DROP FUNCTION [dbo].[GET_RPT_DECISION_POINT]
END
GO
PRINT 'INFO: Creating Function [GET_RPT_DECISION_POINT].'
GO
CREATE FUNCTION [dbo].[GET_RPT_DECISION_POINT]
(
)
RETURNS 
@DECISION_POINT_TABLE  TABLE 
(
	-- Add the column definitions for the TABLE variable here
	EQUIPID NVARCHAR(15),
	LOCATION NVARCHAR (15)
)
AS
BEGIN
	INSERT INTO @DECISION_POINT_TABLE VALUES('OB1-03', 'M1-07')
	INSERT INTO @DECISION_POINT_TABLE VALUES('TB-03', 'M1-08')
	INSERT INTO @DECISION_POINT_TABLE VALUES('OB2-03', 'M1-09')
	INSERT INTO @DECISION_POINT_TABLE VALUES('OB3-03', 'M1-09')
	
	RETURN 
END
GO


/****** Object:  UserDefinedFunction [dbo].[GET_RPT_LPDETAILS]    Script Date: 04/17/2009 17:01:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GET_RPT_LPDETAILS]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [GET_RPT_LPDETAILS].'
	DROP FUNCTION [dbo].[GET_RPT_LPDETAILS]
END
GO
PRINT 'INFO: Creating Function [GET_RPT_LPDETAILS].'
GO
CREATE FUNCTION [dbo].[GET_RPT_LPDETAILS]
(
	-- Add the parameters for the function here
	@LICENSE_PLATE NVARCHAR(10)
)
RETURNS 
	@LPDetails table (
		LP NVARCHAR(10),
		COUNT_LP INT,
		LAST_LOC NVARCHAR(10),
		TIME_OCCUR DATETIME)
AS
BEGIN
	DECLARE @COUNT_LP INT
	DECLARE @LAST_LOC NVARCHAR(10)
	DECLARE @TIME_OCCUR DATETIME
	
	SELECT @COUNT_LP = COUNT(LICENSE_PLATE1) FROM BAG_INFO WHERE LICENSE_PLATE1 = @LICENSE_PLATE
	SELECT TOP 1 @LAST_LOC = LAST_LOCATION, @TIME_OCCUR = TIME_STAMP  FROM BAG_INFO WHERE LICENSE_PLATE1 = @LICENSE_PLATE ORDER BY TIME_STAMP DESC
	INSERT INTO @LPDetails VALUES(@LICENSE_PLATE, @COUNT_LP, @LAST_LOC, @TIME_OCCUR)

	RETURN 
END
GO



/****** Object:  UserDefinedFunction [dbo].[GET_RPT_SORTED_OUT_TABLE]    Script Date: 04/17/2009 17:01:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GET_RPT_SORTED_OUT_TABLE]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [GET_RPT_SORTED_OUT_TABLE].'
	DROP FUNCTION [dbo].[GET_RPT_SORTED_OUT_TABLE]
END
GO
PRINT 'INFO: Creating Function [GET_RPT_SORTED_OUT_TABLE].'
GO
CREATE FUNCTION [dbo].[GET_RPT_SORTED_OUT_TABLE]
(
)
RETURNS 
@SORTED_TABLE  TABLE 
(
	PROCEED_LOCATION NVARCHAR(10),
	LICENSE_PLATE NVARCHAR(10)
)
AS
BEGIN
	INSERT INTO @SORTED_TABLE 
	SELECT PROCEED_LOCATION, LICENSE_PLATE FROM ITEM_PROCEEDED A WHERE PROCEED_LOCATION IN (SELECT EQUIPID FROM GET_RPT_DECISION_POINT()) 
	RETURN 
END
GO



/****** Object:  UserDefinedFunction [dbo].[GET_RPT_SORTED_TABLE_BYDATE]    Script Date: 04/17/2009 17:01:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GET_RPT_SORTED_TABLE_BYDATE]') 
		AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	PRINT 'INFO: Deleting existing Function [GET_RPT_SORTED_TABLE_BYDATE].'
	DROP FUNCTION [dbo].[GET_RPT_SORTED_TABLE_BYDATE]
END
GO
PRINT 'INFO: Creating Function [GET_RPT_SORTED_TABLE_BYDATE].'
GO
CREATE FUNCTION [dbo].[GET_RPT_SORTED_TABLE_BYDATE]
(
	-- Add the parameters for the function here
	@DateFrom datetime,
	@DateTo datetime
)
RETURNS 
@SORTED_TABLE  TABLE 
(
	-- Add the column definitions for the TABLE variable here
	SDO datetime,
	AIRLINE NVARCHAR(3),
	FLIGHT_NUMBER NVARCHAR(5),
	LICENSE_PLATE NVARCHAR(10)
)
AS
BEGIN
	INSERT INTO @SORTED_TABLE 
	SELECT SDO, AIRLINE, FLIGHT_NUMBER, LICENSE_PLATE FROM BAG_SORTING A WHERE (SDO between @DateFrom and @DateTo)
	RETURN 
END
GO



PRINT 'INFO: End of Creating New Functions.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO

PRINT 'INFO: End of STEP 4.1'
GO



