USE [BHSDB_CLT_LOCAL]
GO

DROP TYPE [dbo].[ITEM_READY_TABLETYPE]
GO

/****** Object:  UserDefinedTableType [dbo].[ITEM_READY_TABLETYPE]    Script Date: 04-04-2014 10:03:42 AM ******/
CREATE TYPE [dbo].[ITEM_READY_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[PLC_INDEX] [varchar](10) NOT NULL
)
GO


