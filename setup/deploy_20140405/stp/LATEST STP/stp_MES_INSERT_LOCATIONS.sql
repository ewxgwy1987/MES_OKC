USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_LOCATIONS]    Script Date: 04-04-2014 6:22:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_LOCATIONS]
	@LOCATIONS_TABLETYPE LOCATIONS_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM LOCATIONS;
	
    INSERT INTO LOCATIONS([SUBSYSTEM],[LOCATION],[PLC_ZONE],[DESCRIPTION],[ASSIGNABLE],[STATUS_TYPE],[TRACKED],[CONVEYOR_LEVEL],[LOCATION_ID],[INTERNAL_LOC]) 
	SELECT [SUBSYSTEM],[LOCATION],[PLC_ZONE],[DESCRIPTION],[ASSIGNABLE],[STATUS_TYPE],[TRACKED],[CONVEYOR_LEVEL],[LOCATION_ID],[INTERNAL_LOC]
    FROM @LOCATIONS_TABLETYPE

END
