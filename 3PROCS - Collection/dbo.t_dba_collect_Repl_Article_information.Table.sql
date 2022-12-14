USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_Repl_Article_information]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_Repl_Article_information](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[date_time] [datetime] NOT NULL,
	[publication_server] [varchar](500) NULL,
	[publisher_db] [varchar](500) NULL,
	[publication_name] [varchar](500) NULL,
	[article] [varchar](500) NULL,
	[destination_object] [varchar](500) NULL,
	[subscription_server] [varchar](500) NULL,
	[subscriber_db] [varchar](500) NULL,
	[distribution_agent_job_name] [varchar](5000) NULL,
 CONSTRAINT [PK_DBA_RowN_] PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_Repl_Article_information] ADD  DEFAULT (getdate()) FOR [date_time]
GO
