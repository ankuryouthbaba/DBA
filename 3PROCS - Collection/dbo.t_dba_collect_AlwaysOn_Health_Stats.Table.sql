USE [admin]
GO
/****** Object:  Table [dbo].[t_dba_collect_AlwaysOn_Health_Stats]    Script Date: 30-11-2021 20:39:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[t_dba_collect_AlwaysOn_Health_Stats](
	[Row_Number] [int] IDENTITY(1,1) NOT NULL,
	[Execution_Count] [int] NULL,
	[Collection_date_time] [datetime] NOT NULL,
	[Primary_Replica] [varchar](500) NOT NULL,
	[AGGroupName] [varchar](500) NOT NULL,
	[replica_server_name] [varchar](500) NOT NULL,
	[DatabaseName] [varchar](500) NOT NULL,
	[role_desc] [varchar](500) NULL,
	[synchronization_state_desc] [varchar](500) NULL,
	[is_commit_participant] [bit] NULL,
	[synchronization_health_desc] [varchar](500) NULL,
	[database_state_desc] [varchar](500) NULL,
	[is_suspended] [bit] NULL,
	[suspend_reason_desc] [varchar](500) NULL,
	[recovery_lsn] [varchar](500) NULL,
	[truncation_lsn] [varchar](500) NULL,
	[last_sent_lsn] [varchar](500) NULL,
	[last_sent_time] [datetime] NULL,
	[last_received_lsn] [varchar](500) NULL,
	[last_received_time] [datetime] NULL,
	[last_hardened_lsn] [varchar](500) NULL,
	[last_hardened_time] [datetime] NULL,
	[last_redone_lsn] [varchar](500) NULL,
	[last_redone_time] [datetime] NULL,
	[log_send_queue_size] [int] NULL,
	[log_send_rate] [int] NULL,
	[redo_queue_size] [int] NULL,
	[redo_rate] [int] NULL,
	[end_of_log_lsn] [varchar](500) NULL,
	[last_commit_lsn] [varchar](500) NULL,
	[last_commit_time] [datetime] NULL,
	[secondary_lag_seconds] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[t_dba_collect_AlwaysOn_Health_Stats] ADD  CONSTRAINT [DF__t_dba_col__Colle__369C13AA]  DEFAULT (getdate()) FOR [Collection_date_time]
GO
