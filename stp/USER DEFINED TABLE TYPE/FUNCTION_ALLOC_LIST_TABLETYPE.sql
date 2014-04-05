USE [BHSDB_OKCLOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_LIST_TABLETYPE]    Script Date: 04-04-2014 6:09:07 PM ******/
DROP TYPE [dbo].[FUNCTION_ALLOC_LIST_TABLETYPE]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_LIST_TABLETYPE]    Script Date: 04-04-2014 6:09:07 PM ******/
CREATE TYPE [dbo].[FUNCTION_ALLOC_LIST_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[IS_ENABLED] [bit] NOT NULL,
	[SYS_TAB_NAME] [varchar](20) NOT NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[IS_CHANGED] [bit] NOT NULL
)
GO


