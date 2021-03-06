USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_BAGINFO]    Script Date: 02-04-2014 9:16:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_FALLBACKMAPPING]
	@FALLBACK_MAPPING_TABLETYPE FALLBACK_MAPPING_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM FALLBACK_MAPPING;
	
    INSERT INTO FALLBACK_MAPPING([ID], [DESTINATION], [DESCRIPTION], [SYS_ACTION],[IS_CHANGED]) 
	SELECT [ID], [DESTINATION], [DESCRIPTION], [SYS_ACTION],0 FROM @FALLBACK_MAPPING_TABLETYPE

END
