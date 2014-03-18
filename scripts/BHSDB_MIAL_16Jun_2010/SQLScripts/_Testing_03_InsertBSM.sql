
/***************************************************************************************
 Description:	SQL Script to insert test BSM into table [BAGS]
 Created By:	XJ
 Date:			12 Jun 2008
***************************************************************************************/

USE BHSDB
GO

/* 
SELECT * FROM [BHSDB].[dbo].[BAGS]  
SELECT * FROM [BHSDB].[dbo].[BAG_SORTING]

DELETE FROM [BHSDB].[dbo].[BAGS]
DELETE FROM [BHSDB].[dbo].[BAG_SORTING] WHERE [LICENSE_PLATE] =  '3783123456'
*/
DELETE FROM BAG_ERROR_BSM
DELETE FROM [BHSDB].[dbo].[BAG_SORTING]
DELETE FROM [BHSDB].[dbo].[BAGS]

DECLARE @i int;
SET @i = 1;
WHILE @i <= 2 -- Number of test bags will be inserted into table [BAGS] and [BAG_SORTING]
BEGIN
	DECLARE @No [varchar] (6);
	
	-- Up to 999 test bags can be inserted
	SET @No = CASE 
         WHEN @i<10 THEN '00000' + CAST(@i AS varchar(6))
         WHEN @i>=10 AND @i<100 THEN '0000' + CAST(@i AS varchar(6))
         WHEN @i>=100 AND @i<1000 THEN '000' + CAST(@i AS varchar(6))
         WHEN @i>=1000 AND @i<10000 THEN '00' + CAST(@i AS varchar(6))
         WHEN @i>=10000 AND @i<100000 THEN '0' + CAST(@i AS varchar(6))
         WHEN @i>=100000 AND @i<1000000 THEN CAST(@i AS varchar(6))
	END;
	
	
	-- insert into BAGS
	DECLARE @ID BIGINT
	INSERT INTO [BHSDB].[dbo].[BAGS]
			   ([TIME_STAMP], [RAW_DATA], [ERROR_INDICATOR])
		 VALUES
			   (GETDATE(),'BSM test DATA', '0');
			   
	DECLARE @TIME_STAMP DATETIME = (SELECT MAX(TIME_STAMP) FROM BAGS)
	SELECT @ID = ID FROM BAGS WHERE TIME_STAMP = @TIME_STAMP;		
	




	
	-- insert up to 999 test bags for flight SQ123
	IF @No IS NOT NULL
		INSERT INTO [BHSDB].[dbo].[BAG_SORTING] (
				   [DATA_ID],[TIME_STAMP],[LICENSE_PLATE],[AIRLINE],[FLIGHT_NUMBER],[SDO], 
				   [NO_PASSENGER_SAME_SURNAME], [SURNAME], [GIVEN_NAME], [OTHERS_NAME],
				   [TRAVEL_CLASS],[SOURCE],[HIGH_RISK],[HBS_LEVEL_REQUIRED],[CREATED_BY],[INBOUND_AIRLINE],
				   [INBOUND_FLIGHT_NUMBER],[TAG_PRINTER_ID],[CHECK_IN_COUNTER],[BAG_EXCEPTION])
			 VALUES
				   (@ID,GETDATE(),'0617' + @No,'SQ','957',CONVERT(nvarchar(30), GETDATE(), 111),
				   0, 'AA', 'BB', '' ,'*','L',NULL,NULL,'BHS',NULL,NULL,NULL,NULL,'CREW');

		INSERT INTO [BHSDB].[dbo].[BAG_SORTING] (
				   [DATA_ID],[TIME_STAMP],[LICENSE_PLATE],[AIRLINE],[FLIGHT_NUMBER],[SDO],
				   [NO_PASSENGER_SAME_SURNAME], [SURNAME], [GIVEN_NAME], [OTHERS_NAME],
				   [TRAVEL_CLASS],[SOURCE],[HIGH_RISK],[HBS_LEVEL_REQUIRED],[CREATED_BY],[INBOUND_AIRLINE],
				   [INBOUND_FLIGHT_NUMBER],[TAG_PRINTER_ID],[CHECK_IN_COUNTER],[BAG_EXCEPTION])
			 VALUES
				   (@ID,GETDATE(),'0618' + @No,'SQ','958',CONVERT(nvarchar(30), GETDATE(), 111),
				   0, 'AA', 'BB', '' ,'*','L',NULL,NULL,'BHS',NULL,NULL,NULL,NULL,'CREW');
				   
		INSERT INTO [BHSDB].[dbo].[BAG_SORTING] (
				   [DATA_ID],[TIME_STAMP],[LICENSE_PLATE],[AIRLINE],[FLIGHT_NUMBER],[SDO],
				   [NO_PASSENGER_SAME_SURNAME], [SURNAME], [GIVEN_NAME], [OTHERS_NAME],
				   [TRAVEL_CLASS],[SOURCE],[HIGH_RISK],[HBS_LEVEL_REQUIRED],[CREATED_BY],[INBOUND_AIRLINE],
				   [INBOUND_FLIGHT_NUMBER],[TAG_PRINTER_ID],[CHECK_IN_COUNTER],[BAG_EXCEPTION])
			 VALUES
				   (@ID,GETDATE(),'0619' + @No,'SQ','959',CONVERT(nvarchar(30), GETDATE(), 111),
				   0, 'AA', 'BB', '' ,'F','L',NULL,NULL,'BHS',NULL,NULL,NULL,NULL,'CREW');
				   
	SET @i = @i + 1;
END
GO