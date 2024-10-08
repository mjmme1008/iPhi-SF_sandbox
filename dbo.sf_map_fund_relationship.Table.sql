USE [SFdb_sandbox]
GO
/****** Object:  Table [dbo].[sf_map_fund_relationship]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sf_map_fund_relationship](
	[IpId] [int] NOT NULL,
	[SfId] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[IpId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
