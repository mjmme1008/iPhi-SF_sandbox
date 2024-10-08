USE [SFdb_sandbox]
GO
/****** Object:  Table [dbo].[sf_control_table]    Script Date: 1/16/2024 3:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sf_control_table](
	[source_object] [varchar](50) NOT NULL,
	[last_load_date] [datetime] NULL,
	[start_load_date] [datetime] NULL,
	[ignore_user_id] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[source_object] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sf_control_table] ADD  DEFAULT (NULL) FOR [last_load_date]
GO
ALTER TABLE [dbo].[sf_control_table] ADD  DEFAULT (NULL) FOR [start_load_date]
GO
ALTER TABLE [dbo].[sf_control_table] ADD  DEFAULT (NULL) FOR [ignore_user_id]
GO
