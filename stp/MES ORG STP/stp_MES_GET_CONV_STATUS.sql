-- =============================================

-- Author:		<Author,,PST>

-- Create date: <Create Date,19 March 2014,>

-- Description:	<Description, get conv status to show on MES GUI screen,>

-- =============================================

Create PROCEDURE [dbo].[stp_MES_GET_CONV_STATUS] 

	-- Add the parameters for the stored procedure here

	@SubSystm nvarchar(7)

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;


	select L.[LOCATION] 'Conv_Name',LSY.[BLINKING] 'Color_Blinking' ,LSY.[DESCRIPTION] 'Desc',LSY.[COLOR_CODE]  'Color_Code'

		   from LOCATIONS as L inner join LOCATION_STATUS_TYPES as LSY 

		   on L.STATUS_TYPE =LSY.TYPE  where L.SUBSYSTEM  =@SubSystm 



END
