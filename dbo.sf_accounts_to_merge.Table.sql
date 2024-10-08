USE [SFdb_sandbox]
GO
/****** Object:  Table [dbo].[sf_accounts_to_merge]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sf_accounts_to_merge](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[sfIdToDelete] [varchar](20) NULL,
	[sfIdToKeep] [varchar](20) NULL,
	[Processed] [int] NULL,
	[ProcessedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
