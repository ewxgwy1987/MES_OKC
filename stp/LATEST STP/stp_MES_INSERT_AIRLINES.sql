CREATE PROCEDURE [dbo].[stp_MES_INSERT_AIRLINES]
	@AIRLINES_TABLETYPE AIRLINES_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM AIRLINES;
	
    INSERT INTO AIRLINES (CODE_IATA, CODE_ICAO, NAME, TICKETING_CODE, DESTINATION, DESTINATION1, RUSH, HANDLER, SORT_FLAG, IS_CHANGED) 
	SELECT CODE_IATA, CODE_ICAO, NAME, TICKETING_CODE, DESTINATION, DESTINATION1, RUSH, HANDLER, SORT_FLAG, 0 FROM @AIRLINES_TABLETYPE

END
GO