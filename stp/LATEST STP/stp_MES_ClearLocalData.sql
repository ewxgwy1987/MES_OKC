USE [BHSDB_CLT_LOCAL]
GO
/****** Object:  StoredProcedure [dbo].[stp_MES_ClearLocalData]    Script Date: 04-04-2014 1:14:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[stp_MES_ClearLocalData]
AS
BEGIN
	SET NOCOUNT ON;
	
	DELETE FROM SYS_CONFIG
	DELETE FROM FUNCTION_ALLOC_GANTT
	DELETE FROM FUNCTION_ALLOC_LIST
	DELETE FROM FUNCTION_TYPES
	DELETE FROM AIRLINES
	DELETE FROM BAG_INFO 
	DELETE FROM BAG_SORTING
	DELETE FROM FALLBACK_MAPPING
	DELETE FROM FOUR_DIGITS_FALLBACK_MAPPING
	DELETE FROM FLIGHT_PLAN_ALLOC
	DELETE FROM FLIGHT_PLAN_SORTING
	DELETE FROM AIRPORTS
	DELETE FROM SECURITY_GROUP_TASK_MAPPING
	DELETE FROM SECURITY_GROUP_TASKS
	DELETE FROM SECURITY_USER_RIGHTS
	DELETE FROM SECURITY_GROUPS
	DELETE FROM SECURITY_TASKS
	DELETE FROM SECURITY_CATEGORIES
	DELETE FROM SECURITY_USERS
	DELETE FROM LOCATIONS 	 
	--DELETE FROM SORTATION_REASON
	DELETE FROM DESTINATIONS
	DELETE FROM DESTINATION_CHUTE_MAPPING
	DELETE FROM	DESTINATION_PATH_MAPPING

END
