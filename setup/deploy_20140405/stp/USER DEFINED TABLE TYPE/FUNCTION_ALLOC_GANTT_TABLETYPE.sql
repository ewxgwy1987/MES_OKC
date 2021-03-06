USE [BHSDB_CLT_LOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE]    Script Date: 02-04-2014 11:39:26 AM ******/
CREATE TYPE [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE] AS TABLE(
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[FUNCTION_TYPE] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[ALLOC_OPEN_DATETIME] [datetime] NOT NULL,
	[ALLOC_CLOSE_DATETIME] [datetime] NOT NULL,
	[IS_CLOSED] [bit] NOT NULL,
	[EXCEPTION] [varchar](10) NULL
)
GO


