-- ##########################################################################
-- Release#:    R1.0
-- Release On:  20 Aug 2009
-- Filename:    6.0.MES_Update.sql
-- Description: SQL Scripts of creating SQL Server Agent schedule jobs.
--
--    Schedule jobs to be created by this script:
--    01. [DELETE_AIRLINES] - Update DELETE_AIRLINES trigger to update change monitoring table.
--    02. [INSERT_AIRLINES] - Update INSERT_AIRLINES trigger from airlines table to update change monitoring table.
--    03. [UPDATE_AIRLINES] - Update UPDATE_AIRLINES trigger from airlines table to update change monitoring table.
--    04. [BAG_INFO_CHANGE] - Add BAG_INFO_CHANGE trigger in Bag_Info table to update change monitoring table.
--    05. [BAG_SORTING_CHANGE] - Add BAG_SORTING_CHANGE trigger in Bag_Sorting table to update change monitoring table.
--    06. [CHUTE_MAPPING_CHANGE] - Add CHUTE_MAPPING_CHANGE trigger in Chute_Mapping table to update change monitoring table.
--    07. [MES_EVENT] - Add MES_EVENT table.
--
--
-- Histories:
--    R1.0 - Released on ?.
-- Remarks:
-- ##########################################################################




PRINT 'INFO: STEP 6.0 - Update MES tables and require tables.'
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO

USE [BHSDB]
GO

/****** Object:  Trigger [dbo].[DELETE_AIRLINES]    Script Date: 06/21/2010 16:38:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  TRIGGER [dbo].[DELETE_AIRLINES] ON [dbo].[AIRLINES] 
AFTER DELETE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'DEL','AIRLINES',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO +
			', NAME=' + NAME + ', TICKETING_CODE=' + TICKETING_CODE +
			', DESTINATION=' + ISNULL(DESTINATION,'')
		FROM DELETED;
		
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_AIRLINES';
END

GO

/****** Object:  Trigger [dbo].[INSERT_AIRLINES]    Script Date: 06/21/2010 16:39:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  TRIGGER [dbo].[INSERT_AIRLINES] ON [dbo].[AIRLINES] 
AFTER INSERT
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'INS','AIRLINES',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO +
			', NAME=' + NAME + ', TICKETING_CODE=' + TICKETING_CODE +
			', DESTINATION=' + ISNULL(DESTINATION,'')
		FROM INSERTED;
	
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_AIRLINES';
END

/****** Object:  Trigger [dbo].[UPDATE_AIRLINES]    Script Date: 06/21/2010 16:40:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  TRIGGER [dbo].[UPDATE_AIRLINES] ON [dbo].[AIRLINES] 
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[AUDIT_LOG] (TIME_STAMP,CREATED_BY,EVENT_TYPE,TABLE_NAME,DESCRIPTION) 
		SELECT CURRENT_TIMESTAMP,CURRENT_USER,'UPD','AIRLINES',
			'CODE_IATA=' + CODE_IATA + ', CODE_ICAO=' + CODE_ICAO +
			', NAME=' + NAME + ', TICKETING_CODE=' + TICKETING_CODE +
			', DESTINATION=' + ISNULL(DESTINATION,'')
		FROM INSERTED;
	
	UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_AIRLINES';
END

/****** Object:  Trigger [dbo].[BAG_INFO_CHANGE]    Script Date: 06/21/2010 16:41:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Albert Sun
-- Create date: 21-Jun-2010
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[BAG_INFO_CHANGE] 
   ON  [dbo].[BAG_INFO] 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_BAG_INFO';

END

GO

/****** Object:  Trigger [dbo].[BAG_SORTING_CHANGE]    Script Date: 06/21/2010 16:42:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Albert Sun	
-- Create date: 21-Jun-2010
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[BAG_SORTING_CHANGE]
   ON  [dbo].[BAG_SORTING]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_BAG_SORTING';

END

GO

/****** Object:  Trigger [dbo].[CHUTE_MAPPING_CHANGE]    Script Date: 06/21/2010 16:42:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Albert Sun
-- Create date: 21-Jun-2010
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[CHUTE_MAPPING_CHANGE]
   ON  [dbo].[CHUTE_MAPPING]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [dbo].[CHANGE_MONITORING] SET [IS_CHANGED] = 1 WHERE [STATE_CODE] = 'TB_CHUTE_MAPPING';

END

GO

/****** Object:  Table [dbo].[MES_EVENT]    Script Date: 08/03/2010 09:20:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MES_EVENT](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NULL,
	[ACTION] [varchar](10) NOT NULL,
	[ACTION_DESC] [varchar](25) NULL,
	[MES_STATION] [varchar](16) NULL,
 CONSTRAINT [PK_MES_EVENT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

PRINT 'INFO: End of Updating MES Tables.'
GO
PRINT 'INFO: .'
PRINT 'INFO: .'
PRINT 'INFO: .'
GO
