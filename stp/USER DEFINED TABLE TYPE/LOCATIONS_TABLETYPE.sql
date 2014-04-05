USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[SECURITY_GROUP_TASK_MAPPING_TABLETYPE]    Script Date: 02-04-2014 2:33:16 PM ******/
CREATE TYPE [dbo].[LOCATIONS_TABLETYPE] AS TABLE(
	[SUBSYSTEM] [varchar](10) NOT NULL,
	[LOCATION] [varchar](20) NOT NULL,
	[PLC_ZONE] [varchar](10) NULL,
	[DESCRIPTION] [nvarchar](50) NOT NULL,
	[ASSIGNABLE] [char](1) NULL,
	[STATUS_TYPE] [varchar](2) NULL,
	[TRACKED] [bit] NOT NULL,
	[CONVEYOR_LEVEL] [varchar](10) NULL,
	[LOCATION_ID] [varchar](4) NULL,
	[INTERNAL_LOC] [varchar](20) NULL
)
GO


