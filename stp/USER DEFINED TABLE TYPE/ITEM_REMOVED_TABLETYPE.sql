USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[ITEM_REMOVED_TABLETYPE]    Script Date: 04-04-2014 10:04:23 AM ******/
CREATE TYPE [dbo].[ITEM_REMOVED_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[PLC_INDEX] [nchar](10) NULL
)
GO


