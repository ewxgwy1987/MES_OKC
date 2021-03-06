USE [BHSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_ITEM_ENCODED]    Script Date: 20/02/2014 04:19:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[stp_MES_INSERT_ITEM_ENCODED]
       @GID varchar(10),
       @LOCATION varchar(10),
	   @LICENSE_PLATE varchar(10),
	   @AIRLINE varchar(3),
	   @FLIGHT_NUMBER varchar(5),
	   @ENCODING_TYPE varchar(2), 
	   @PLC_INDEX varchar(10),
	   @DEST varchar(10)

AS
BEGIN
    
    -- Step 1 : Insert Item Encoded bag event into event table [ITEM_ENCODED] 
	INSERT INTO [ITEM_ENCODED]([TIME_STAMP],[GID],[LOCATION],[LICENSE_PLATE],[AIRLINE],[FLIGHT_NUMBER],[ENCODING_TYPE],[PLC_INDEX],[DEST])
	VALUES(GETDATE(), @GID, @LOCATION,@LICENSE_PLATE, @AIRLINE, @FLIGHT_NUMBER, @ENCODING_TYPE, @PLC_INDEX, @DEST) 
			
END

