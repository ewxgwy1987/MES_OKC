USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_FUNCTION_ALLOC_GANTT]    Script Date: 02-04-2014 11:39:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_DESTINATIONS]
	@DESTINATIONS_TABLETYPE DESTINATIONS_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM DESTINATIONS;
	
    INSERT INTO DESTINATIONS( [DESTINATION], [SUBSYSTEM], [DESCRIPTION], [IS_AVAILABLE], [LOCATION_ID]) 
	SELECT [DESTINATION], [SUBSYSTEM], [DESCRIPTION], [IS_AVAILABLE], [LOCATION_ID] 
    FROM @DESTINATIONS_TABLETYPE

END
