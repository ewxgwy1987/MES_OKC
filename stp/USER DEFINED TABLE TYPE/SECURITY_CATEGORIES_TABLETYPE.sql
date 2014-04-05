USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE]    Script Date: 02-04-2014 11:39:26 AM ******/
CREATE TYPE [dbo].[SECURITY_CATEGORIES_TABLETYPE] AS TABLE(
    [SECU_CAT_CODE] [varchar](15) NOT NULL,
	[NAME] [varchar](50) NOT NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL
)
GO

