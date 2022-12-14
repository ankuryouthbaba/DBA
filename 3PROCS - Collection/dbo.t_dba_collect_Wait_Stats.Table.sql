USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_Wait_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_Wait_Stats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[date_time] [datetime] NOT NULL,
	[wait_type] [varchar](1000) NULL,
	[waiting_tasks_count] [bigint] NULL,
	[wait_time_ms] [bigint] NULL,
	[max_wait_time_ms] [bigint] NULL,
	[signal_wait_time_ms] [bigint] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_Wait_Stats] ADD  DEFAULT (getdate()) FOR [date_time]
GO
