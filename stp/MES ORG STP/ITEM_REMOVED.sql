USE [BHSDB]
GO

/****** Object:  Table [dbo].[ITEM_REMOVED]    Script Date: 2014/3/31 10:04:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ITEM_REMOVED](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[TIME_STAMP] [datetime] NOT NULL,
	[GID] [varchar](10) NOT NULL,
	[LICENSE_PLATE] varchar(10) NULL,
	[LOCATION] [varchar](10) NOT NULL,
	[PLC_INDEX] [nchar](10) NULL,
 CONSTRAINT [PK_ITEM_REMOVED] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


