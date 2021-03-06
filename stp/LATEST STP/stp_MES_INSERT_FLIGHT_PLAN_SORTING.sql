USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_FLIGHT_PLAN_SORTING]    Script Date: 04-04-2014 5:23:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_FLIGHT_PLAN_SORTING]
	@FLIGHT_PLAN_SORTING_TABLETYPE FLIGHT_PLAN_SORTING_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM FLIGHT_PLAN_SORTING;
	
    INSERT INTO FLIGHT_PLAN_SORTING ([TIME_STAMP],[DATA_ID],[AIRLINE],[FLIGHT_NUMBER],[FLIGHT_NUMBER_SUFFIX],[HANDLER],[SDO],
			[STO],[EDO],[ETO],[ADO],[ATO],[IDO],[ITO],[BLOCK_OFF_TIME],[FINAL_DEST],[DEST1],[DEST2],[DEST3],[DEST4],[DEST5],[CANCELLED],
			[AIRCRAFT_TYPE],[HANDLER_SPECIFIC_DESC],[AIRCRAFT_VERSION],[TERMINAL],[CHECKIN_AREA],[CHECKIN_STATUS],
			[PUBLIC_REMARK_CODE],[PIER],[GATE],[PARKING_STAND],[NATURE],[SORTING_DEST1],[SORTING_DEST2],[GENERAL_PURPOSE],
			[FI_EXCEPTION],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],[MASTER_FLIGHT_NUMBER_SUFFIX],[MASTER_SDO],[BOOKED_PAX],[HBS_LEVEL_REQUIRED],
			[WEEKDAY],[HOUR],[HIGH_RISK],[ALLOC_OPEN_TIME],[ALLOC_CLOSE_TIME],[CREATED_BY],[IS_ALLOCATED],[CUSTOMS_REQUIRED],[FLIGHT_TYPE]) 
	SELECT 	[TIME_STAMP],[DATA_ID],[AIRLINE],[FLIGHT_NUMBER],[FLIGHT_NUMBER_SUFFIX],[HANDLER],[SDO],
			[STO],[EDO],[ETO],[ADO],[ATO],[IDO],[ITO],[BLOCK_OFF_TIME],[FINAL_DEST],[DEST1],[DEST2],[DEST3],[DEST4],[DEST5],[CANCELLED],
			[AIRCRAFT_TYPE],[HANDLER_SPECIFIC_DESC],[AIRCRAFT_VERSION],[TERMINAL],[CHECKIN_AREA],[CHECKIN_STATUS],
			[PUBLIC_REMARK_CODE],[PIER],[GATE],[PARKING_STAND],[NATURE],[SORTING_DEST1],[SORTING_DEST2],[GENERAL_PURPOSE],
			[FI_EXCEPTION],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],[MASTER_FLIGHT_NUMBER_SUFFIX],[MASTER_SDO],[BOOKED_PAX],[HBS_LEVEL_REQUIRED],
			[WEEKDAY],[HOUR],[HIGH_RISK],[ALLOC_OPEN_TIME],[ALLOC_CLOSE_TIME],[CREATED_BY],[IS_ALLOCATED],[CUSTOMS_REQUIRED],[FLIGHT_TYPE]
    FROM @FLIGHT_PLAN_SORTING_TABLETYPE

END
