USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE]    Script Date: 02-04-2014 11:39:26 AM ******/
CREATE TYPE [dbo].[FUNCTION_TYPES_TABLETYPE] AS TABLE(
	[TYPE] [varchar](4) NOT NULL,
	[GROUP] [varchar](5) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
	[IS_ALLOCATED] [bit] NOT NULL,
	[IS_ENABLED] [bit] NOT NULL
)
GO


