-- ================================
-- Create User-defined Table Type
-- ================================
USE [BHSDB_CLT_LOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[MES_EVENT_TABLETYPE]    Script Date: 09/14/2012 09:32:20 ******/
CREATE TYPE [dbo].[BAG_INFO_TABLETYPE] AS TABLE(
    [GID] [VARCHAR](10) NOT NULL, 
	[LICENSE_PLATE1] [VARCHAR](10) NULL, 
	[LICENSE_PLATE2] [VARCHAR](10) NULL, 
    [HBS1_RESULT] [VARCHAR](2) NULL, 
	[HBS2_RESULT] [VARCHAR](2) NULL, 
	[HBS3_RESULT] [VARCHAR](2) NULL, 
	[LAST_LOCATION] [VARCHAR](10) NOT NULL, 
	[TIME_STAMP] [DATETIME] NOT NULL, 
	[TYPE] [NVARCHAR](1)

)
GO
