USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[AIRLINES_TABLETYPE]    Script Date: 04-04-2014 1:44:17 PM ******/
DROP TYPE [dbo].[AIRLINES_TABLETYPE]
GO

/****** Object:  UserDefinedTableType [dbo].[AIRLINES_TABLETYPE]    Script Date: 04-04-2014 1:44:17 PM ******/
CREATE TYPE [dbo].[AIRLINES_TABLETYPE] AS TABLE(
	[CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](3) NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[TICKETING_CODE] [nvarchar](4) NOT NULL,
	[DESTINATION] [varchar](10) NULL,
	[DESTINATION1] [varchar](10) NULL,
	[RUSH] [varchar](10) NULL,
	[HANDLER] [varchar](3) NULL,
	[SORT_FLAG] [bit] NOT NULL
)
GO


