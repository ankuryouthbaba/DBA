USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_WaitingTasks_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_WaitingTasks_Stats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[date_time] [datetime] NOT NULL,
	[session_id] [int] NULL,
	[blocking_session_id] [int] NULL,
	[wait_duration_ms] [int] NULL,
	[wait_type] [varchar](1000) NULL,
	[Resource_description] [varchar](5000) NULL,
 CONSTRAINT [PK_DBA_t_dba_collect_WaitingTasks_Stats_Row_Number_1] PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_WaitingTasks_Stats] ADD  DEFAULT (getdate()) FOR [date_time]
GO
