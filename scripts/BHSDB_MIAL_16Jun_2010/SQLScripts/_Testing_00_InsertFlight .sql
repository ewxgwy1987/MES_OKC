/***************************************************************************************
 Description:	SQL Script to insert test Flight into table [FLIGHT_PLAN_SORTING]
 Created By:	HSC
 Date:			17 MAR 2010
***************************************************************************************/

USE [BHSDB]
GO

GO
DELETE FROM FLIGHT_PLAN_ERROR
DELETE FROM [FLIGHT_PLAN_SORTING] 
DELETE FROM [FLIGHT_PLANS] 
DELETE FROM FLIGHT_PLAN_ALLOC 
GO

BEGIN
	DECLARE	@FlightNumber int;
	
	DECLARE	@Hur int;
	DECLARE	@Hur_STR char(2);
	DECLARE	@Min int;
	DECLARE	@Min_STR char(2);

    SET @Hur = DATEPART(hh,GETDATE());
    SET @Min = 0;

	SET DATEFIRST 1;		
    SET @FlightNumber = 955;
	WHILE @FlightNumber < 999
	BEGIN
		SET @Min_STR = CASE 
			 WHEN @Min=0 THEN '00'
			 WHEN @Min=10 THEN '10'
			 WHEN @Min=20 THEN '20'
			 WHEN @Min=30 THEN '30'
			 WHEN @Min=40 THEN '40'
			 WHEN @Min=50 THEN '50'
			 WHEN @Min=60 THEN '00'
		END
		
		IF @Min=60
		BEGIN
			SET @Hur = @Hur + 1
			SET @Min = 0
		END
		
		SET @Hur_STR = CASE 
			 WHEN @Hur<10 THEN '0' + CAST(@Hur AS varchar(1))
			 WHEN @Hur>=0 AND @Hur<24 THEN CAST(@Hur AS varchar(2))
			 WHEN @Hur=24 THEN '00'
		END

		IF @Hur=24
		BEGIN
			SET @Hur = 0
		END
		
		SET @Min = @Min + 30; -- Every 20 minutes interval create one flight
		
		-- Insert into FLIGHT_PLANS table as the ID in FLIGHT_PLAN_SORTING is a FK to the ID here.
		DECLARE @ID BIGINT
		INSERT INTO [BHSDB].[dbo].[FLIGHT_PLANS]
				   ([TIME_STAMP], [RAW_DATA], [ERROR_INDICATOR])
			 VALUES
				   (GETDATE(),'testing data', '0');
				   
		DECLARE @TIME_STAMP DATETIME = (SELECT MAX(TIME_STAMP) FROM FLIGHT_PLANS)
		SELECT @ID = ID FROM FLIGHT_PLANS WHERE TIME_STAMP = @TIME_STAMP;		

		-- Insert Today's flight
		INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_SORTING] (
				[DATA_ID], [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[ADO],[ATO],[IDO],[ITO],
				[AIRCRAFT_TYPE],[AIRCRAFT_VERSION],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],[HIGH_RISK],
				[CANCELLED],[TERMINAL],[GATE],[BOOKED_PAX],[NATURE],[HANDLER],[FINAL_DEST],[DEST1],
				[DEST2],[DEST3],[DEST4],[DEST5],[SORTING_DEST1],[SORTING_DEST2],[CHECKIN_AREA],
				[HBS_LEVEL_REQUIRED],[WEEKDAY],[HOUR],[TIME_STAMP],[CREATED_BY],[FI_EXCEPTION])
			 VALUES (
				@ID,'SQ',CAST(@FlightNumber AS varchar(3)),CONVERT(nvarchar(30), GETDATE(), 111),
				   @Hur_STR + @Min_STR,null,null,null,null,null,null,null,null,null,null,null,'N','T3',null,
				   null,null,null,'CDU',null,null,null,null,null,null,null,null,null,DATEPART(dw,GETDATE()),
				   null,GETDATE(),'FIS','HIGHRISK');

		-- Insert Tomorrow's flight
		INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_SORTING] (
				[DATA_ID], [AIRLINE],[FLIGHT_NUMBER],[SDO],[STO],[EDO],[ETO],[ADO],[ATO],[IDO],[ITO],
				[AIRCRAFT_TYPE],[AIRCRAFT_VERSION],[MASTER_AIRLINE],[MASTER_FLIGHT_NUMBER],[HIGH_RISK],
				[CANCELLED],[TERMINAL],[GATE],[BOOKED_PAX],[NATURE],[HANDLER],[FINAL_DEST],[DEST1],
				[DEST2],[DEST3],[DEST4],[DEST5],[SORTING_DEST1],[SORTING_DEST2],[CHECKIN_AREA],
				[HBS_LEVEL_REQUIRED],[WEEKDAY],[HOUR],[TIME_STAMP],[CREATED_BY],[FI_EXCEPTION])
			 VALUES (
				@ID,'SQ',CAST(@FlightNumber AS varchar(3)),CONVERT(nvarchar(30), DATEADD(dd,1,GETDATE()), 111),
				   @Hur_STR + @Min_STR,null,null,null,null,null,null,null,null,null,null,null,'N','T3',null,
				   null,null,null,'CDU',null,null,null,null,null,null,null,null,null,DATEPART(dw,DATEADD(dd,1,GETDATE())),
		         null,GETDATE(),'FIS',null)

	    SET @FlightNumber = @FlightNumber + 1;
	END
END
GO
/*
SELECT * FROM [BHSDB].[dbo].[FLIGHT_PLANS]
SELECT * FROM [BHSDB].[dbo].[FLIGHT_PLAN_SORTING]  
GO
*/