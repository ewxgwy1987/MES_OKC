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
	@CARRIER VARCHAR(3),
	@TICKETING_CODE VARCHAR(4)
AS
DECLARE 
    @ERROR VARCHAR(100)
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @ERROR = ''

	IF NOT EXISTS(SELECT * FROM AIRLINES WHERE (CODE_IATA = @CARRIER OR TICKETING_CODE=@TICKETING_CODE))
	BEGIN
	    SET @ERROR = 'No Airline Information received for Airline # ' + @CARRIER

	    SELECT @ERROR AS ERROR,'' AS AIRLINE,'' AS TICKETING_CODE
		   
		RETURN 0   
	END
    ELSE
    BEGIN
		SELECT '' AS ERROR,CODE_IATA AS AIRLINE,TICKETING_CODE FROM AIRLINES 
		WHERE (CODE_IATA = @CARRIER OR TICKETING_CODE=@TICKETING_CODE)
	END
    	 
END
