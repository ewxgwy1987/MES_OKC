USE [BHSDB_CLT]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_GET_LOCATION_STATUS_TYPE]    Script Date: 24/04/2014 06:47:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		GUO WENYU
-- Create date: 24-04-2014
-- Description:	Get location status type used as conveyor legend on MES
-- =============================================
CREATE PROCEDURE [dbo].[stp_MES_GET_LOCATION_STATUS_TYPE]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [DESCRIPTION],COLOR_CODE FROM LOCATION_STATUS_TYPES WHERE LTRIM(RTRIM([DESCRIPTION]))<>'N.A.'
    	 
END
