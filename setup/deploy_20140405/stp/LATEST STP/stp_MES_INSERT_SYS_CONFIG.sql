USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_FUNCTION_ALLOC_GANTT]    Script Date: 02-04-2014 11:39:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_SYS_CONFIG]
	@SYS_CONFIG_TABLETYPE SYS_CONFIG_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM SYS_CONFIG;
	
    INSERT INTO SYS_CONFIG( [SYS_KEY], [SYS_VALUE], [DEFAULT_VALUE], [LAST_VALUE], [DESCRIPTION], 
		[VALUE_TOKEN], [SYS_ACTION], [GROUP_NAME], [ORDER_FLAG], [IS_ENABLED]) 
	SELECT 	[SYS_KEY], [SYS_VALUE], [DEFAULT_VALUE], [LAST_VALUE], [DESCRIPTION], 
		[VALUE_TOKEN], [SYS_ACTION], [GROUP_NAME], [ORDER_FLAG], [IS_ENABLED] 
    FROM @SYS_CONFIG_TABLETYPE

END
