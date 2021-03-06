USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_FUNCTION_ALLOC_GANTT]    Script Date: 02-04-2014 11:39:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_FUNCTION_TYPES]
	@FUNCTION_TYPES_TABLETYPE FUNCTION_TYPES_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM FUNCTION_TYPES;
	
    INSERT INTO FUNCTION_TYPES( [TYPE], [GROUP], [DESCRIPTION], [IS_ALLOCATED], [IS_ENABLED]) 
	SELECT 	 [TYPE], [GROUP], [DESCRIPTION], [IS_ALLOCATED], [IS_ENABLED] 
    FROM @FUNCTION_TYPES_TABLETYPE

END
