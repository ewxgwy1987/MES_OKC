USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_INSERT_SORTATION_REASON]    Script Date: 04-04-2014 5:55:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_INSERT_SORTATION_REASON]
	@SORTATION_REASON_TABLETYPE SORTATION_REASON_TABLETYPE READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DELETE FROM ITEM_REDIRECT; 
	DELETE FROM SORTATION_REASON;
	
    INSERT INTO SORTATION_REASON([REASON], [DESCRIPTION]) 
	SELECT [REASON], [DESCRIPTION] 
    FROM @SORTATION_REASON_TABLETYPE

END
