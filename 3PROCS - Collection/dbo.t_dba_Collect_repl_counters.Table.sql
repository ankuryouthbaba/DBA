USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_Collect_repl_counters]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_Collect_repl_counters](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[date_time] [datetime] NOT NULL,
	[DatabaseName] [varchar](500) NULL,
	[Replicated_Transactions] [int] NULL,
	[Replication_rate_trans_sec] [varchar](500) NULL,
	[Replication_Latency_sec] [varchar](500) NULL,
	[replbeginlsn] [binary](10) NULL,
	[replnextlsn] [binary](10) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Row_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_Collect_repl_counters] ADD  DEFAULT (getdate()) FOR [date_time]
GO
