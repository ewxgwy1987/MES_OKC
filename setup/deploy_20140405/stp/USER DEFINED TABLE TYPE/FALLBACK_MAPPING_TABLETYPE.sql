USE [BHSDB_CLT_LOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[BAG_INFO_TABLETYPE]    Script Date: 02-04-2014 9:13:53 AM ******/
CREATE TYPE [dbo].[FALLBACK_MAPPING_TABLETYPE] AS TABLE(
	[ID] [varchar](2) NOT NULL,
	[DESTINATION] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[IS_CHANGED] [bit] NOT NULL
)
GO


