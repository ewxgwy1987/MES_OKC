USE [BHSDB_OKC]
GO

/****** Object:  UserDefinedTableType [dbo].[FUNCTION_ALLOC_GANTT_TABLETYPE]    Script Date: 02-04-2014 11:39:26 AM ******/
CREATE TYPE [dbo].[DESTINATION_PATH_MAPPING_TABLETYPE] AS TABLE(
   [SUBSYSTEM] [varchar](10) NOT NULL,
   [PATH] [varchar](50) NOT NULL
)
GO


