USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[ITEM_ENCODED_TABLETYPE]    Script Date: 04-04-2014 10:02:28 AM ******/
CREATE TYPE [dbo].[ITEM_ENCODED_TABLETYPE] AS TABLE(
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[LICENSE_PLATE] [varchar](10) NOT NULL,
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[ENCODING_TYPE] [varchar](2) NOT NULL,
	[PLC_INDEX] [varchar](10) NOT NULL,
	[DEST] [varchar](10) NOT NULL
)
GO


