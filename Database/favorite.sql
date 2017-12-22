USE [GeoWcf]
GO

/****** Object:  Table [dbo].[favorite]    Script Date: 2017/12/22 下午 03:11:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[favorite](
	[username] [nvarchar](100) NOT NULL,
	[locationName] [nvarchar](100) NOT NULL,
	[location] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_favorite] PRIMARY KEY CLUSTERED 
(
	[username] ASC,
	[locationName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


