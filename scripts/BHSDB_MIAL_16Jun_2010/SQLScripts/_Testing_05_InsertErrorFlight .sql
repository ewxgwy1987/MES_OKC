USE BHSDB

	DECLARE @ID BIGINT
	INSERT INTO [BHSDB].[dbo].[FLIGHT_PLANS]
			   ([TIME_STAMP], [RAW_DATA], [ERROR_INDICATOR])
		 VALUES
			   (GETDATE(),'100103041233   123     20091220                    20091220153000                                                        SIN                                                                                                                                                                                    ', '0');
			   
	DECLARE @TIME_STAMP DATETIME = (SELECT MAX(TIME_STAMP) FROM [FLIGHT_PLANS])
	SELECT @ID = ID FROM [FLIGHT_PLANS] WHERE TIME_STAMP = @TIME_STAMP;		
	
INSERT INTO [BHSDB].[dbo].[FLIGHT_PLAN_ERROR]
           ([DATA_ID]
           ,[TIME_STAMP]
           ,[DESCRIPTION])
     VALUES
           (@ID
           ,GETDATE()
           ,'No Airline Number')
           
           
           
UPDATE [BHSDB].[dbo].[FLIGHT_PLANS]
   SET [ERROR_INDICATOR] = '1'
 WHERE ID = @ID