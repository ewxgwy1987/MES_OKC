USE [BHSDB_OKCLOCAL]
GO

/****** Object:  UserDefinedTableType [dbo].[FLIGHT_PLAN_ALLOC_TABLETYPE]    Script Date: 04-04-2014 5:02:16 PM ******/
DROP TYPE [dbo].[FLIGHT_PLAN_ALLOC_TABLETYPE]
GO

/****** Object:  UserDefinedTableType [dbo].[FLIGHT_PLAN_ALLOC_TABLETYPE]    Script Date: 04-04-2014 5:02:16 PM ******/
CREATE TYPE [dbo].[FLIGHT_PLAN_ALLOC_TABLETYPE] AS TABLE(
	[AIRLINE] [varchar](3) NOT NULL,
	[FLIGHT_NUMBER] [varchar](5) NOT NULL,
	[SDO] [datetime] NOT NULL,
	[STO] [varchar](4) NOT NULL,
	[RESOURCE] [varchar](10) NOT NULL,
	[WEEKDAY] [char](1) NOT NULL,
	[EDO] [datetime] NULL,
	[ETO] [varchar](4) NULL,
	[ADO] [datetime] NULL,
	[ATO] [varchar](4) NULL,
	[IDO] [datetime] NULL,
	[ITO] [varchar](4) NULL,
	[TRAVEL_CLASS] [varchar](1) NOT NULL,
	[FLIGHT_DESTINATION] [varchar](3) NOT NULL,
	[BAG_TYPE] [varchar](10) NOT NULL,
	[TRANSFER] [varchar](10) NOT NULL,
	[COMMENT_ID] [bigint] NULL,
	[HIGH_RISK] [char](1) NULL,
	[HBS_LEVEL_REQUIRED] [char](1) NULL,
	[EARLY_OPEN_OFFSET] [varchar](5) NULL,
	[EARLY_OPEN_ENABLED] [bit] NULL,
	[ALLOC_OPEN_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_OPEN_RELATED] [varchar](4) NOT NULL,
	[ALLOC_CLOSE_OFFSET] [varchar](5) NOT NULL,
	[ALLOC_CLOSE_RELATED] [varchar](4) NOT NULL,
	[RUSH_DURATION] [varchar](5) NULL,
	[SCHEME_TYPE] [varchar](2) NULL,
	[CREATED_BY] [varchar](15) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[HOUR] [varchar](2) NULL,
	[IS_MANUAL_CLOSE] [bit] NOT NULL,
	[IS_CLOSED] [bit] NOT NULL,
	[IS_MISS_TEMPLATE_FLIGHT] [bit] NOT NULL
)
GO


