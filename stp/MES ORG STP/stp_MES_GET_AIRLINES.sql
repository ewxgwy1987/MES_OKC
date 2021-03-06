USE [BHSDB]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_AIRLINES]    Script Date: 2014/3/31 11:56:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SC Leong
-- Create date: 27-01-2014
-- Description:	Get Airlines to be displayed on buttons
-- =============================================
ALTER PROCEDURE [dbo].[stp_MES_GET_AIRLINES]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT A.CODE_IATA, A.TICKETING_CODE 
	FROM AIRLINES A 
	ORDER BY A.CODE_IATA
END

