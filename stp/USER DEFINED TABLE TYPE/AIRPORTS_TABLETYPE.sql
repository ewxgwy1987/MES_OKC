USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE]    Script Date: 02-04-2014 11:39:26 AM ******/
CREATE TYPE [dbo].[AIRPORTS_TABLETYPE] AS TABLE(
    [CODE_IATA] [varchar](3) NOT NULL,
	[CODE_ICAO] [varchar](4) NULL,
	[NAME] [nvarchar](50) NOT NULL,
	[COUNTRY] [nvarchar](50) NOT NULL,
	[CITY] [nvarchar](30) NOT NULL
)
GO


