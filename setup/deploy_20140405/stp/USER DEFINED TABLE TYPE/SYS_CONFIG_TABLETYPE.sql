USE [BHSDB_CLT_LOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE]    Script Date: 02-04-2014 11:39:26 AM ******/
CREATE TYPE [dbo].[SYS_CONFIG_TABLETYPE] AS TABLE(
    [SYS_KEY] [varchar](40) NOT NULL,
	[SYS_VALUE] [varchar](20) NOT NULL,
	[DEFAULT_VALUE] [varchar](20) NOT NULL,
	[LAST_VALUE] [varchar](20) NOT NULL,
	[DESCRIPTION] [nvarchar](80) NOT NULL,
	[VALUE_TOKEN] [varchar](80) NULL,
	[SYS_ACTION] [varchar](50) NULL,
	[GROUP_NAME] [varchar](20) NULL,
	[ORDER_FLAG] [varchar](1) NULL,
	[IS_ENABLED] [bit] NOT NULL,
	[IS_CHANGED] [bit] NOT NULL
)
GO


