USE [BHSDB_CLT]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_ITEM_READY]    Script Date: 2014/4/5 11:32:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[stp_MES_INSERT_ITEM_READY]
       @GID varchar(10),
       @LOCATION varchar(10),
	   @PLC_INDEX varchar(10)
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Step 1 : Insert Item Ready bag event into event table [ITEM_READY]
	INSERT INTO [ITEM_READY]([TIME_STAMP],[GID],[LOCATION],[PLC_INDEX])
	VALUES (GETDATE(), @GID, @LOCATION, @PLC_INDEX)
	
	-- Step 2 : Insert / Update sortation working table (BAG_INFO)
	IF EXISTS(SELECT * FROM BAG_INFO WHERE GID=@GID)
	   BEGIN
	       UPDATE BAG_INFO SET TIME_STAMP = GETDATE(), [TYPE] = '2', LAST_LOCATION = @Location 
	       WHERE GID = @GID 
	   END
	ELSE 
	   BEGIN 
	       INSERT INTO BAG_INFO (GID, LAST_LOCATION, TIME_STAMP, [TYPE]) VALUES 
	       (@GID, @Location, GETDATE(), '2')  
	   END  
	
END


