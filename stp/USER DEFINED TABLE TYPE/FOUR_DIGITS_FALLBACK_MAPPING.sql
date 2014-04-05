USE [BHSDB_CLT_LOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[FOUR_DIGITS_FALLBACK_MAPPING]    Script Date: 04-04-2014 4:39:56 PM ******/
CREATE TYPE [dbo].[FOUR_DIGITS_FALLBACK_MAPPING] AS TABLE(
	[ID] [varchar](4) NOT NULL,
	[DESTINATION] [varchar](10) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[IS_CHANGED] [bit] NOT NULL
)
GO


