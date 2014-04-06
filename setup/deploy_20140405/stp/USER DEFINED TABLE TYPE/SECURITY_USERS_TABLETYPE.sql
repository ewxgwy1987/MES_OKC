USE [BHSDB_CLT_LOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[SECURITY_USERS_TABLETYPE]    Script Date: 02-04-2014 3:43:50 PM ******/
CREATE TYPE [dbo].[SECURITY_USERS_TABLETYPE] AS TABLE(
	[USER_NAME] [varchar](20) NOT NULL,
	[USER_PASSWORD] [varchar](200) NOT NULL,
	[AD_USER_GROUP] [varchar](200) NULL,
	[COMPANY] [varchar](50) NULL,
	[JOB_TITLE] [varchar](100) NULL,
	[AIRPORT_BADGE] [varchar](100) NULL,
	[IS_ACTIVE] [bit] NOT NULL,
	[DESCRIPTION] [varchar](200) NULL
)
GO


