USE [BHSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GETFLIGHTINFO]    Script Date: 13/03/2014 06:47:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		GUO WENYU
-- Create date: 23-03-2014
-- Description:	Get Flight Info to be displayed on MES : Encode by Flight
-- =============================================
ALTER PROCEDURE [dbo].[stp_MES_GETAIRLINEINFO]
	-- Add the parameters for the stored procedure here
	@CARRIER VARCHAR(3)
AS
DECLARE 
    @ERROR VARCHAR(100)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @ERROR = ''

	IF NOT EXISTS(SELECT * FROM AIRLINES WHERE CODE_IATA = @CARRIER)
	   BEGIN
	       SET @ERROR = 'No Airline Information received for Airline # ' + @CARRIER

	       SELECT @ERROR AS ERROR
		   
		   RETURN 0   
	   END
    ELSE
       BEGIN
		   SELECT @ERROR AS ERROR
	   END
    	 
END
