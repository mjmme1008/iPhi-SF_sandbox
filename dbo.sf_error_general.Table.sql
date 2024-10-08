USE [SFdb_sandbox]
GO
/****** Object:  Table [dbo].[sf_error_general]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sf_error_general](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[inserted_datetime] [datetime] NULL,
	[sf_object] [varchar](100) NULL,
	[iphi_id] [varchar](100) NULL,
	[error_code] [int] NULL,
	[error_column] [int] NULL,
	[error_message] [varchar](2050) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sf_error_general] ADD  DEFAULT (getdate()) FOR [inserted_datetime]
GO
